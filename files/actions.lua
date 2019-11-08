table.insert( actions,
--{
--		id          = "SELFPOLYMORPH01",
--		name 		= "SelfPolymorph",
--		description = "Transform caster into other entity",
--		sprite 		= "data/ui_gfx/gun_actions/polymorph.png",
--		type 		= ACTION_TYPE_OTHER,
--		spawn_level                       = "", -- POLYMORPH
--		spawn_probability                        = "", -- POLYMORPH
--		price = 100,
--		mana = 100,
--		custom_xml_file = "mods/BlazesRus/files/SelfPolymorphCard01.xml",
--		action 		= function()
--			local SelfID = GetUpdatedEntityID()
--			GetGameEffectLoadTo( SelfID, "mods/BlazesRus/files/SelfPolymorphEffect01", true )
--		end,
--},
--{
--		id          = "SELFPOLYMORPH02",
--		name 		= "SelfPolymorph 02",
--		description = "Transform caster into other entity",
--		sprite 		= "data/ui_gfx/gun_actions/polymorph.png",
--		type 		= ACTION_TYPE_OTHER,
--		spawn_level                       = "", -- POLYMORPH
--		spawn_probability                        = "", -- POLYMORPH
--		price = 100,
--		mana = 100,
--		custom_xml_file = "mods/BlazesRus/files/SelfPolymorphCard01.xml",
--		action 		= function()
--			local SelfID = GetUpdatedEntityID()
--			
--		end,
--}
	{
		id          = "BlazesDAMAGE_FRIENDLY",
		name 		= "Friendly Fire Damage Boost",
		description = "Effected projectiles damage allies and get 1.1x modifier to damage",
		sprite 		= "data/ui_gfx/gun_actions/damage_friendly.png",
		sprite_unidentified = "data/ui_gfx/gun_actions/damage_friendly_unidentified.png",
		type 		= ACTION_TYPE_MODIFIER,
		spawn_level                       = "1,6", -- DAMAGE_FRIENDLY
		spawn_probability                 = "10,10", -- DAMAGE_FRIENDLY
		price = 100,
		mana = 3,
		custom_xml_file = "data/entities/misc/custom_cards/damage_friendly.xml",
		action 		= function()
			local SelfEntity_id = GetUpdatedEntityID()
			c.damage_projectile = c.damage_projectile * 1.1
			c.friendly_fire		= true
			c.gore_particles    = c.gore_particles + 5
			c.fire_rate_wait    = c.fire_rate_wait + 5
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
	},
	{
		id          = "BlazesPolymorph_GhostWorm",
		name 		= "Transformation Gate: GhostWorm",
		description = "Transform first to enter field into GhostWorm",
		sprite 		= "data/ui_gfx/gun_actions/polymorph_field.png",
		sprite_unidentified = "data/ui_gfx/gun_actions/polymorph_field_unidentified.png",
		type 		= ACTION_TYPE_STATIC_PROJECTILE,
		spawn_level                       = "0", -- POLYMORPH_FIELD
		spawn_probability                 = "0", -- POLYMORPH_FIELD
		price = 5000,
		mana = 1000,
		action 		= function()
			local SelfID = GetUpdatedEntityID()
			add_projectile("files/SelfPolymorphSpell01.xml")
			c.fire_rate_wait = c.fire_rate_wait + 40
		end,
	}
)