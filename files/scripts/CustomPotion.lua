 dofile( "data/scripts/lib/utilities.lua" )

-- so that all the potions will be the same in every position with the same seed
-- local potion = random_from_array( potions )
local potion_material =  "GhostWorm Transformative"

-- AddMaterialInventoryMaterial( entity_id, potion.material, 1000 )
AddMaterialInventoryMaterial( entity_id, potion_material, 1000 )