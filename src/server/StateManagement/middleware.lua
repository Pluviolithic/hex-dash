local marketplace_service = game:GetService("MarketplaceService")
local replicated_storage = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local datastore = require(game:GetService("ServerScriptService").Server.DataStore2)
local replicate_action = replicated_storage.Remotes.ReplicateAction
local utils = require(replicated_storage.Common.utils)

local function save_and_display_middleware(next_dispatch, store)
    return function(action)
        local player = action.player and players[action.player]
        if action.type == "increment_cash" then
            datastore("cash", player):Increment(action.amount)
        elseif action.type == "increment_wins" then
            player.leaderstats.Wins.Value = utils.format_number(store:getState().players[player.Name].savable_data.wins + 1)
            datastore("wins", player):Increment(1)
        end
        return next_dispatch(action)
    end
end

local function gamepass_middleware(next_dispatch)
    return function(action)
        if action.type ~= "increment_cash" or action.raw then return next_dispatch(action) end
        local user_id = players[action.player].UserId
        if not marketplace_service:UserOwnsGamePassAsync(user_id, 8441242) then return next_dispatch(action) end
        action.amount *= 2
        return next_dispatch(action)
    end
end

local function update_client_middleware(next_dispatch)
    return function(action)
        replicate_action:FireAllClients(action)
        return next_dispatch(action)
    end
end

-- potentially add middleware to update leaderboard with team scores?

return {
    gamepass_middleware;
    save_and_display_middleware;
    update_client_middleware;
}
