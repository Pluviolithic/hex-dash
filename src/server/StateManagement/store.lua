local replicated_storage = game:GetService("ReplicatedStorage")
local server = game:GetService("ServerScriptService").Server

local rodux = require(replicated_storage.Common.Rodux)
local reducer = require(replicated_storage.Common.reducer)
local middleware = require(server.StateManagement.middleware)
local initial_states = require(replicated_storage.Common.initial_states)

return rodux.Store.new(reducer, initial_states.get_initial_main_state(), middleware)
