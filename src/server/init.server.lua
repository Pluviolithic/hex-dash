local players = game:GetService("Players")
local replicated_storage = game:GetService("ReplicatedStorage")
local server = game:GetService("ServerScriptService").Server

local replicate_store = replicated_storage.Remotes.ReplicateStore

local initial_states = require(replicated_storage.Common.initial_states)
local utils = require(replicated_storage.Common.utils)
local store = require(server.StateManagement.store)
local actions = require(server.StateManagement.actions)
local datastore = require(server.DataStore2)
local datastore_name = "Main-Data-Store"

datastore.PatchGlobalSettings({
    SavingMethod = "Standard"
})

datastore.Combine(
    datastore_name,
    "cash",
    "votes",
    "afk",
    "pets",
    "trails",
    "titles"
)

local function create_leaderboard_display(player, initial_value)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"

    local wins = Instance.new("StringValue")
    wins.Name = "Wins"
    wins.Value = utils.format_number(initial_value)

    wins.Parent = leaderstats
    leaderstats.Parent = player
end

players.PlayerAdded:Connect(function(player)
    replicate_store:FireClient(player, store:getState())
    store:dispatch(actions.add_player(player.Name))
    local initial_player_state = initial_states.get_initial_player_state()
    for key, default_value in pairs(initial_player_state.savable_data) do
        initial_player_state.savable_data[key] = datastore(key, player):Get(default_value)
    end
    create_leaderboard_display(player, initial_player_state.savable_data.wins)
    initial_player_state.is_loading = false
    store:dispatch(actions.player_data_loaded(player.Name, initial_player_state))
end)

players.PlayerRemoving:Connect(function(player)
    store:dispatch(actions.remove_player(player.Name))
end)

require(server.remote_hub)
require(server.MapManagement.round_runner)
