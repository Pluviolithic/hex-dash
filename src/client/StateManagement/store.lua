local replicated_storage = game:GetService("ReplicatedStorage")
local client = game:GetService("StarterPlayer").StarterPlayerScripts.Client
local remotes = replicated_storage.Remotes
local initial_state = remotes.ReplicateStore.OnClientEvent:Wait()

local rodux = require(replicated_storage.Common.Rodux)
local reducer = require(client.StateManagement.reducer)

initial_state.client_info = require(client.StateManagement.initial_state)

local store = rodux.Store.new(reducer, initial_state) --, {rodux.loggerMiddleware})
remotes.ReplicateAction.OnClientEvent:Connect(function(action)
    store:dispatch(action)
end)

return store
