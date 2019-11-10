--table.insert( actions,
--{
--	id          = "BlazesGateMorph_GhostWorm",
--	name 		= "Transformation Gate: GhostWorm",
--	description = "Transform first to enter field into GhostWorm",
--	sprite 		= "files/BasicIcon.png",
--	type 		= ACTION_TYPE_STATIC_PROJECTILE,
--	spawn_level                       = "0", -- POLYMORPH_FIELD
--	spawn_probability                 = "0", -- POLYMORPH_FIELD
--	price = 5000,
--	mana = 1000,
--	custom_xml_file = "files/GhostWormGateMorphCard.xml",
--	action 		= function()
--		add_projectile("files/SelfPolymorphSpell01.xml")
--		c.fire_rate_wait = c.fire_rate_wait + 40
--	end,
--})

table.insert( actions,
{
		id          = "BLAZESGATEMORPHGHOSTWORM",
		name 		= "Transformation Gate: GhostWorm",
		description = "Transform first to enter field into GhostWorm",
		sprite 		= "files/BasicIcon.png",
		type 		= ACTION_TYPE_OTHER,
		spawn_level                       = "", -- POLYMORPH
		spawn_probability                        = "", -- POLYMORPH
		price = 100,
		mana = 100,
		custom_xml_file = "files/base_custom_card.xml",
		action 		= function()
			add_projectile("files/SelfPolymorphSpell01.xml")
			c.fire_rate_wait = c.fire_rate_wait + 40
		end,
})

--table.insert( actions,
--{
--		id          = "SELFPOLYMORPH01",
--		name 		= "SelfPolymorph",
--		description = "Transform caster into other entity",
--		sprite 		= "files/BasicIcon.png",
--		type 		= ACTION_TYPE_OTHER,
--		spawn_level                       = "", -- POLYMORPH
--		spawn_probability                        = "", -- POLYMORPH
--		price = 100,
--		mana = 100,
--		custom_xml_file = "files/SelfPolymorphCard01.xml",
--		action 		= function()
--			local SelfID = GetUpdatedEntityID()
--			GetGameEffectLoadTo( SelfID, "mods/BlazesRus/files/SelfPolymorphEffect01", true )
--		end,
--})

table.insert( actions,
{
		id          = "BLAZESDAMAGEFRIENDLY",
		name 		= "Friendly Fire Boost",
		description = "Effected projectiles damage allies and get 1.1x modifier to damage",
		sprite 		= "files/BasicIcon.png",
		type 		= ACTION_TYPE_OTHER,
		spawn_level                       = "", -- POLYMORPH
		spawn_probability                        = "", -- POLYMORPH
		price = 100,
		mana = 100,
		custom_xml_file = "files/base_custom_card.xml",
		action 		= function()
			--local SelfEntity_id = GetUpdatedEntityID()
			if(c.damage_projectile~=nil) then c.damage_projectile = c.damage_projectile * 1.1 end
			c.friendly_fire		= true
			c.gore_particles    = c.gore_particles + 5
			c.fire_rate_wait    = c.fire_rate_wait + 15
			for entity_id in c.extra_entities do
				local nn = 0
				local comps = EntityGetComponent( entity_id, "ProjectileComponent" )
				if comps ~= nil then
					local comp = comps[n - 1]
					if comp then
						ComponentSetValue( comp, "friendly_fire", "1" )
					end	
				end
			end
		end,
})