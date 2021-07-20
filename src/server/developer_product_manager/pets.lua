local pets = {}
local pet_model_folder = game:GetService("ServerStorage").Pets
local state_management = game:GetService("ServerScriptService").Server.StateManagement

local store = require(state_management.store)
local actions = require(state_management.actions)

-- remember to add a player.CharacterAdded connection somewhere
-- that iterates over the equipped items table and attaches them
-- to the new character so I don't have to handle that behavior here

function pets.get_equipped_pet(player)
    return store:getState().players[player.Name].savable_data.equipped_items.pet
end

function pets.equip_to_player(player, pet_name)
    local pet_model = pet_model_folder:FindFirstChild(pet_name)
    if not pet_model then return end
    local equipped_pet = pets.get_equipped_pet(player)
    if equipped_pet then
        pets.unequip_from_player(player)
    end
    store:dispatch(actions.equip_pet(pet_name))
    if not player.Character then return end
    -- don't do or player.CharacterAdded:Wait()
    -- because there is another event listening for that
    -- to add the equipped pet anyway
    pet_model:Clone().Parent = player.Character
end

function pets.unequip_from_player(player)
    local equipped_pet = pets.get_equipped_pet(player)
    if not equipped_pet then return end
    local equipped_pet_model = player.Character and player.Character:FindFirstChild(equipped_pet)
    store:dispatch(actions.unequip_pet())
    if equipped_pet_model then
        equipped_pet_model:Destroy()
    end
end

return pets
