local remotes = game:GetService("ReplicatedStorage").Remotes
local server = game:GetService("ServerScriptService").Server

local player_manager = require(server.player_manager)

--[[
local store = require(server.StateManagement.store)
local actions = require(server.StateManagement.actions)
local map_pool_info = require(server.MapManagement.map_pool_info)

-- map voting is disabled until I want it or
-- decide on a different/better system

remotes.Vote.OnServerEvent:Connect(function(player, map_name, gamemode_name)
    if not map_pool_info:verify_vote(map_name, gamemode_name) then return end
    local player_state = store:getState().players[player.Name]
    if player_state.savable_data.votes < 1 then return end
    map_pool_info:submit_vote({map_name, gamemode_name})
    store:dispatch(actions.increment_vote(player, -1))
end)
--]]

remotes.SwitchAFK.OnServerEvent:Connect(player_manager.switch_afk)

return 0
