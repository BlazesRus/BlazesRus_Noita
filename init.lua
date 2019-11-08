function OnPlayerSpawned( player_entity )--Apply Wand Editing feature to player (posted by kermit tears)
    local effect = GetGameEffectLoadTo( player_entity, "EDIT_WANDS_EVERYWHERE", true );
    if effect ~= nil then ComponentSetValue( effect, "frames", "-1" ); end
end

-- This code runs when all mods' filesystems are registered
--ModLuaFileAppend( "data/scripts/gun/gun_actions.lua", "files/actions.lua" )
ModMaterialsFileAdd( "files/materials_Addition.xml" )
ModLuaFileAppend( "data/scripts/gun/gun_actions.lua", "mods/BlazesRus/files/actions.lua" )