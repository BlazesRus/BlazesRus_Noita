dofile( "data/scripts/lib/coroutines.lua" )
dofile( "data/scripts/lib/utilities.lua" )

-- animate eyes and skull randomly -----------------

local limb_positions = {}
local nearestTargetID = 0


async_loop(function()
	local x,y = EntityGetTransform( GetUpdatedEntityID() )
	
	local enemy_nearby	 = false
	
	local targets = EntityGetInRadius( x, y, 128,mortal)
	local ClosestDist = 129
	if targets ~= nil then
		local NumTargets = table.getn(targets)
		local px,py,distance = 0,0,0
		local target_id = 0
		for Index=1,Index<=NumTargets do--Find closest target
			target_id = targets[Index]
			if(target_id~=GetUpdatedEntityID()) then--Prevent finding self as closest
				px,py = EntityGetTransform( target_id )
				distance = math.abs(py - y) * 0.5 + math.abs(px - x)
				if (distance < ClosestDist) then
					ClosestDist = distance
					nearestTargetID = target_id
				end
			end
		end
		enemy_nearby	 = true
	end

	local children = EntityGetAllChildren( GetUpdatedEntityID() )

	if children ~= nil then

		for i,it in ipairs(children) do
			if (limb_positions[i] == nil) then
				limb_positions[i] = {x, y}
			end
	
			-- this actually needs to be done only once, not every update
			edit_component( it, "IKLimbWalkerComponent", function(comp,vars)
				EntitySetComponentIsEnabled( it, comp, false )
			end)

			if (math.random(1, 50) == 2) or enemy_nearby then
				local ox,oy = 0,0

				edit_component( it, "IKLimbComponent", function(comp,vars)
					ox,oy = ComponentGetValueVector2( comp, "end_position")
				end)
			
				ox = ox - x
				oy = oy - y
				
				if (enemy_nearby == false) then
					ox = math.min(math.max(ox + math.random(-24, 24), -32), 32)
					oy = math.min(math.max(oy + math.random(-48, 80), 32), 100)
				else
					ox = math.cos(i * 30) * 128
					oy = 0 - math.sin(i * 30) * 128
				end

				local nx = x + ox
				local ny = y + oy
				
				limb_positions[i][3] = nx
				limb_positions[i][4] = ny
			end

			local x_source = limb_positions[i][1]
			local y_source = limb_positions[i][2]
			
			local x_target = x_source
			local y_target = y_source

			if( limb_positions[i][3] ~= nil ) then x_target = limb_positions[i][3] end
			if( limb_positions[i][4] ~= nil ) then y_target = limb_positions[i][4] end

			local x_interpolation = (x_target - x_source) * 0.2
			local y_interpolation = (y_target - y_source) * 0.2
			
			limb_positions[i][1] = x_source + x_interpolation
			limb_positions[i][2] = y_source + y_interpolation

			edit_component( it, "IKLimbComponent", function(comp,vars)
				ComponentSetValueVector2( comp, "end_position", x_source + x_interpolation, y_source + y_interpolation )
			end)

		end
	end

	wait(0)
end)