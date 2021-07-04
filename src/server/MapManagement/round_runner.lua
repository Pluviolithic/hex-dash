local replicated_storage = game:GetService("ReplicatedStorage")
local server = game:GetService("ServerScriptService").Server
local utils = require(replicated_storage.Common.utils)
local store = require(server.StateManagement.store)
local actions = require(server.StateManagement.actions)
local player_manager = require(server.player_manager)
local map_pool_info = require(server.MapManagement.map_pool_info)
local gamemodes = require(server.MapManagement.gamemodes)

--local gamemodes = require(server.MapManagement.gamemoes)

utils.spawn(function()
    while true do
        local playing_players = player_manager:get_playing_players()
        for i = 15, 1, -1 do
            if not playing_players then break end
            store:dispatch(actions.update_status("Intermission("..i..")..."))
            utils.wait(1)
            playing_players = player_manager:get_playing_players()
        end
        if not playing_players then
            store:dispatch(actions.update_status("Not enough players. Ask a friend to join!"))
            utils.wait(1)
            continue
        end

        local map_name, gamemode = table.unpack(map_pool_info:get_next_map_gamemode_pair())
        local map_model = map_pool_info:get_map_model(map_name)
        store:dispatch(actions.update_status("Next map: "..map_name.." - "..gamemode))
        map_model.Parent = workspace
        utils.wait(3)
        playing_players = player_manager:get_playing_players()
        store:dispatch(actions.set_round_player_list(playing_players))
        store:dispatch(actions.set_round_status(true))
        gamemodes[gamemode]:initialize(map_model, playing_players)
        --TODO: add a clock/timer

        -- should be rare enough that a special message should be unnecessary
        if not playing_players then
            gamemodes[gamemode]:cleanup()
            continue
        end

        gamemodes[gamemode].finished.Event:Wait()

    end
end)

return 0
