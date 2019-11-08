dofile( "data/scripts/lib/coroutines.lua" )
dofile( "data/scripts/lib/utilities.lua" )

-- enum for changing C++ logic state. keep this in sync with the values in limbboss_system.cpp

local states = {
	MoveAroundNest = 0,
	FollowTarget = 1,
	Escape = 2,
	DontMove = 3,
	MoveTo = 4,
	MoveDirectlyTowardsTarget = 5,
}

local TrackedTargetID = 0
local ForceTrackCursor = false
local details_hidden 	= false
local is_dead        	= false
local boss_chase		= 0

function init_boss()
	-- Turn on the limbs
	local children = EntityGetAllChildren( GetUpdatedEntityID() )
	
	if children ~= nil then
		for i,it in ipairs(children) do
			EntitySetComponentsWithTagEnabled( it, "disabled_at_start", true )
		end
	end
	
	--set_main_animation( get_idle_animation_name(), get_idle_animation_name() )
end

init_boss()

-- gather some data we're gonna reuse --------------
local herd_id = get_herd_id( GetUpdatedEntityID() )
local force_coeff_orig = component_get_value_float(  GetUpdatedEntityID(), "PhysicsAIComponent", "force_coeff", 10.0 )
local subphase = 0

-- Phase logic
function phase_chase_slow()
	--print("phase_chase_slow")
	set_logic_state( states.FollowTarget )
	boss_wait(2 * 60)
	choose_random_phase()
end

function phase_chase_direct()
	--print("phase_chase_slow")
	set_logic_state( states.MoveDirectlyTowardsTarget )
	boss_wait(2 * 80)
	choose_random_phase()
end

function phase_circleshot()
	local wait_duration = 50 - orbcount * 2
	local shot_count = 2 + math.floor(orbcount * 0.5)
	
	set_main_animation( "open", "opened" )
	
	boss_wait(70)
	for i=1,shot_count do
		circleshot()
		boss_wait(wait_duration)
	end
	
	boss_wait(25)
	
	set_main_animation( "close", get_idle_animation_name() )
	
	boss_wait(65)
	set_logic_state( states.FollowTarget )
	choose_random_phase()
end

function phase_chase()
	--print("phase_chase")
	set_logic_state( states.FollowTarget )
	prepare_chase()
	chase_start()
	boss_wait(140)
	chase_stop()
	choose_random_phase()
end

function phase_orb_mat()
	set_main_animation( "open", "opened" )
	boss_wait(40)
	
	orb_mat()
	
	boss_wait(20)
	set_main_animation( "close", get_idle_animation_name() )
	boss_wait(50)
	set_logic_state( states.FollowTarget )
	choose_random_phase()
end

function phase_firepillar()
	set_main_animation( "open", "opened" )
	
	boss_wait(50)
	firepillar()
	
	boss_wait(20)
	
	set_main_animation( "close", get_idle_animation_name() )
	
	boss_wait(80)
	
	set_logic_state( states.FollowTarget )
	choose_random_phase()
end

function phase_homingshot()
	set_main_animation( "open", "opened" )
	
	boss_wait(40)
	
	local shot_count = 2 + math.floor(orbcount * 0.5)
	for i=1,shot_count do
		homingshot()
		boss_wait(20)
	end
	
	set_main_animation( "close", get_idle_animation_name() )
	boss_wait(50)
	
	choose_random_phase()
end

function phase_clean_materials()
	--print("phase_clean_materials")
	set_logic_state( states.FollowTarget )
	boss_wait(10)
	clear_materials()
	choose_random_phase()
end

-- Function for picking the next phase
function choose_random_phase()
	local entity_id = GetUpdatedEntityID()
	local xe,ye = EntityGetTransform( entity_id )
	local xp,yp = 0,0
	if(TrackedTargetID~=0) then--Check if target still alive and in effective range
		xp,yp = EntityGetTransform( TrackedTargetID )
		local distance = math.abs(py - y) * 0.5 + math.abs(px - x)
		if (distance > 701) then
			TrackedTargetID = 0
		end
	end
	if(TrackedTargetID==0&&ForceTrackCursor==false) then
		local targets = EntityGetInRadius( xe, ye, 700,mortal)
		local distance = 0
		local ClosestDist = 701
		if targets ~= nil then
			local NumTargets = table.getn(targets)
			local target_id = 0
			for Index=1,Index<=NumTargets do--Find closest target
				target_id = targets[Index]
				if(target_id~=GetUpdatedEntityID()) then--Prevent finding self as closest
					px,py = EntityGetTransform( target_id )
					distance = math.abs(py - ye) * 0.5 + math.abs(px - xe)
					if (distance < ClosestDist) then
						ClosestDist = distance
						TrackedTargetID = target_id
					end
				end
			end
		end
	end
		
	if(TrackedTargetID~=0&&ForceTrackCursor==false) then
		local xp,yp = EntityGetTransform( TrackedTargetID )
		-- If near target, use normal phases
		if (dist < 700) then
			-- Every phase increases a 'subphase' variable, and at 10 subphase forces the boss to use the clean_materials phase
			if (subphase < 9) then
				local r = math.random(0,6)
				print("Boss subphase: " .. tostring(subphase) .. ", phase: " .. tostring(r))
				if     r == 0 then phase = phase_chase_slow
				elseif r == 1 then phase = phase_circleshot
				elseif r == 2 then phase = phase_chase
				elseif r == 3 then phase = phase_orb_mat
				elseif r == 4 then phase = phase_firepillar
				elseif r == 5 then phase = phase_homingshot
				end
				
				subphase = subphase + 1
			else
				subphase = 0
				phase = phase_clean_materials
			end
		else
			-- If further from target, start chasin'
			phase = phase_chase_direct
		end
	end
		
	-- If target is way too far, boss assumes they have left the arena entirely and sets up phase 2
	if (ForceTrackCursor||(dist > 1300 and boss_chase == 0)) then--Default to chasing cursor if force tracking cursor
		boss_chase = 1
		
		local celleater = EntityGetFirstComponent( GetUpdatedEntityID(), "CellEaterComponent" )
	
		if (celleater ~= nil) then
			ComponentSetValue( celleater, "eat_probability", tostring(100.0) )
			ComponentSetValue( celleater, "radius", tostring(64.0) )
		end
		
		local physics_ai = EntityGetFirstComponent( GetUpdatedEntityID(), "PhysicsAIComponent" )
		
		if (physics_ai ~= nil) then
			ComponentSetValue( physics_ai, "force_coeff", tostring( force_coeff_orig * 5.0 ) )
		end
		
		phase = phase_chase_direct
	end
end


-- actual boss attacks -----------------

function circleshot()
	boss_wait(15)

	local this         = GetUpdatedEntityID()
	local pos_x, pos_y = EntityGetTransform( this )

	local angle  = 0
	local amount = 8 + orbcount
	local space  = math.floor(360 / amount)
	local speed  = 130
	
	for i=1,amount do
		local vel_x = math.cos( math.rad(angle) ) * speed
		local vel_y = math.sin( math.rad(angle) ) * speed
		angle = angle + space

		local orb = shoot_projectile( this, "data/entities/animals/boss_centipede/orb_circleshot.xml", pos_x, pos_y, vel_x, vel_y )
	end
end

function homingshot()
	local this         = GetUpdatedEntityID()
	local pos_x, pos_y = EntityGetTransform( this )

	local vel_x = 0
	local vel_y = -30

	shoot_projectile( this, "data/entities/animals/boss_centipede/orb_homing.xml", pos_x, pos_y, vel_x, vel_y )
end

function firepillar()
	boss_wait(15)

	local this         = GetUpdatedEntityID()
	local pos_x, pos_y = EntityGetTransform( this )

	local amount = 8 + math.floor(orbcount * 0.2)
	local space  = math.floor(180 / amount)
	local speed  = 40 + orbcount * 5
	local angle  = space * 0.5
	
	for i=1,amount do
		local vel_x = math.cos( math.rad(angle) ) * speed
		local vel_y = math.sin( math.rad(angle) ) * speed
		angle = angle + space

		local pillar = shoot_projectile( this, "data/entities/animals/boss_centipede/firepillar.xml", pos_x, pos_y, vel_x, vel_y )
	end
end

function orb_mat()
	boss_wait(15)

	local this         = GetUpdatedEntityID()
	local pos_x, pos_y = EntityGetTransform( this )
	
	local dir = math.random(0,1) * 2 - 1
	local vel_x = dir * math.random(50,100)
	local vel_y = math.random(-50,50)

	local names = {"radioactive","oil","acid", "gunpowder_unstable"}

	local rnd = math.random(#names)
	local pillar = shoot_projectile( this, "mods/BlazesRus/files/projectiles/CentiOrb_" .. names[rnd] .. ".xml", pos_x, pos_y, vel_x, vel_y )
end

function clear_materials()
	boss_wait(15)

	local this         = GetUpdatedEntityID()
	local pos_x, pos_y = EntityGetTransform( this )

	local pillar = shoot_projectile( this, "data/entities/animals/boss_centipede/clear_materials.xml", pos_x, pos_y, 0, 0 )
end

function prepare_chase()
	boss_wait(40)
end

function chase_start()
	local physics_ai = EntityGetFirstComponent( GetUpdatedEntityID(), "PhysicsAIComponent" )
	
	if (physics_ai ~= nil) then
		ComponentSetValue( physics_ai, "force_coeff", tostring( force_coeff_orig * 5.0 ) )
	end
	
--[[	local celleater = EntityGetFirstComponent( GetUpdatedEntityID(), "CellEaterComponent" )
	
	if (celleater ~= nil) then
		--ComponentSetValue( celleater, "eat_probability", tostring(100.0) )
	end]]
end

function chase_stop()
	local physics_ai = EntityGetFirstComponent( GetUpdatedEntityID(), "PhysicsAIComponent" )
	
	if (physics_ai ~= nil) then
		ComponentSetValue( physics_ai, "force_coeff", tostring( force_coeff_orig ) )
	end
	
--[[	local celleater = EntityGetFirstComponent( GetUpdatedEntityID(), "CellEaterComponent" )]]
end

-- Setting the boss movement logic state
function set_logic_state( state )
	local ai = EntityGetFirstComponent( GetUpdatedEntityID(), "LimbBossComponent" )
	local old = 0
	
	if (ai ~= nil) then
		old = tonumber(ComponentGetValue( ai, "state" ))
	end
	
	edit_component( GetUpdatedEntityID(), "LimbBossComponent", function(comp,vars)
		vars.state = state
	end)
	
	local on,nn = "",""
	
	for i,v in pairs(states) do
		if (v == old) then
			on = i
		end
		
		if (v == state) then
			nn = i
		end
	end
	
	print("Changing state from " .. tostring(on) .. " to " .. tostring(nn))
end

function move_to( x, y )
	set_logic_state( states.MoveTo )

	edit_component( GetUpdatedEntityID(), "LimbBossComponent", function(comp,vars)
		vars.mMoveToPositionX = x
		vars.mMoveToPositionY = y
	end)
end

-- The boss can't die normally; if their HP is zero, this does stuff instead
function check_death()
	local comp = EntityGetFirstComponent( GetUpdatedEntityID(), "DamageModelComponent" )
	if( comp ~= nil ) then
		local hp = ComponentGetValueFloat( comp, "hp" )
		if ( hp <= 0.0 ) then
			-- NOTE( Petri ): This function gets called twice in the boss death sequence

			for i = 1,40 do
				local rand = function() return Random( -10, 10 ) end
				local x,y = EntityGetTransform( GetUpdatedEntityID() )
				GameScreenshake( i * 1, x, y )
				GameCreateParticle( "slime_green",            x + rand(), y + rand(), 10, i * 5.5, i * 5.5, true, false )
				if i > 20 then
					GameCreateParticle( "gunpowder_unstable", x + rand(), y + rand(), 3,  40.0,    40.0,    true, false )
				end
				wait( 3 )
			end

			-- kill
			comp = EntityGetFirstComponent( GetUpdatedEntityID(), "DamageModelComponent" )
			if( comp ~= nil ) then
				ComponentSetValue( comp, "kill_now", "1" )
			end
			is_dead = true

			return
		end
	end
end

-- Basic idle function
function boss_wait( frames )
	check_death()
	wait( frames )
	check_death()
end

function animate_sprite( sprite, current_name, next_name )
	GamePlayAnimation( GetUpdatedEntityID(), current_name, 0, next_name, 0 )
end

function get_idle_animation_name()
	return "stand"
end

function set_main_animation( current_name, next_name )
	local sprite = EntityGetFirstComponent( GetUpdatedEntityID(), "SpriteComponent" )
	if ( sprite ~= nil ) then
		animate_sprite( sprite, current_name, next_name )
	end
end

-- run phase state machine -----------------

phase = phase_circleshot
async_loop(function()

	-- alive
	if is_dead then
		wait(60 * 10)
	else
		phase()
	end

end)