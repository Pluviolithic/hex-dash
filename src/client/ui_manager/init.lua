local client = game:GetService("StarterPlayer").StarterPlayerScripts.Client
local player_gui = game:GetService("Players").LocalPlayer.PlayerGui
local common = game:GetService("ReplicatedStorage").Common
local roact_rodux = require(common.RoactRodux)
local roact = require(common.Roact)
local store = require(client.StateManagement.store)

local main_app = roact.createElement(roact_rodux.StoreProvider, {
    store = store;
}, {
    Main = roact.createElement(
        "ScreenGui",
        {ResetOnSpawn = false},
        require(client.ui_manager.interfaces)
    );
})

roact.mount(main_app, player_gui)

return 0
