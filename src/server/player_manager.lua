local players = game:GetService("Players")
local state_management = game:GetService("ServerScriptService").Server.StateManagement
local store = require(state_management.store)
local actions = require(state_management.actions)
local player_manager = {
    minimum = 2;
}

function player_manager:get_playing_players()
    local playing_players = {}
    local counter = 0
    for _, player in ipairs(players:GetPlayers()) do
        -- see if I need better checks for players being alive than "not player.Character"
        if not player.Character or store:getState().players[player.Name].afk then continue end
        counter += 1
        playing_players[player] = true
    end
    if counter < self.minimum then
        return false
    end
    return playing_players
end

local switch_debounces = {}
function player_manager.switch_afk(player)
    if switch_debounces[player] and os.time() - switch_debounces[player] < 0.5 then return end
    switch_debounces[player] = os.time()
    store:dispatch(actions.switch_afk(player.Name))
end

players.PlayerRemoving:Connect(function(player)
    switch_debounces[player] = nil
end)

return player_manager
