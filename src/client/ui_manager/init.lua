local client = game:GetService("StarterPlayer").StarterPlayerScripts.Client
local player_gui = game:GetService("Players").LocalPlayer.PlayerGui
local common = game:GetService("ReplicatedStorage").Common
local roact_rodux = require(common.RoactRodux)
local roact = require(common.Roact)
local store = require(client.StateManagement.store)

local main_app = roact.createElement(roact_rodux.StoreProvider, {
    store = store;
}, {
    Main = roact.createElement("ScreenGui", {ResetOnSpawn = false}, {
        MenuFrame = roact.createElement(require(script.menu_ui));
        StatusUI = roact.createElement(require(script.status_ui));
        SpectateUI = roact.createElement(require(script.spectate_ui));
    });
})

roact.mount(main_app, player_gui)

return 0
