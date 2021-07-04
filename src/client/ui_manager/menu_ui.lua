local player = game:GetService("Players").LocalPlayer
local client = game:GetService("StarterPlayer").StarterPlayerScripts.Client
local replicated_storage = game:GetService("ReplicatedStorage")

local common = replicated_storage.Common
local switch_afk = replicated_storage.Remotes.SwitchAFK

local roact = require(common.Roact)
local roact_rodux = require(common.RoactRodux)
local store = require(client.StateManagement.store)
local actions = require(client.StateManagement.actions)

local last_switched = -1

local function get_menu(props)
    return roact.createElement("Frame", {
        BackgroundTransparency = 1;
        Size = UDim2.fromScale(0.059, 0.5);
        Position = UDim2.fromScale(0, 0.249);
    }, {
        GridLayout = roact.createElement("UIGridLayout", {
            CellSize = UDim2.fromScale(1, 0.3);
        });
        -- The weird names are for the grid layout to sort them.
        ASpectateButton = roact.createElement("TextButton", {
            TextScaled = true;
            Text = "Spectate";
            BackgroundColor3 = Color3.fromRGB(170, 255, 255);
            [roact.Event.Activated] = function()
                store:dispatch(actions.switch_spectate())
            end;
        }, {
            UICorner = roact.createElement("UICorner");
        });
        BAFKButton = roact.createElement("TextButton", {
            TextScaled = true;
            Text = props.afk_status;
            BackgroundColor3 = Color3.fromRGB(170, 255, 255);
            [roact.Event.Activated] = function()
                if os.time() - last_switched < 0.5 then return end
                last_switched = os.time()
                switch_afk:FireServer()
            end;
        }, {
            UICorner = roact.createElement("UICorner");
        });
        CShop = roact.createElement("TextButton", {
            TextScaled = true;
            Text = "Shop";
            BackgroundColor3 = Color3.fromRGB(170, 255, 255);
            [roact.Event.Activated] = function()
                print("Opening shop.")
            end;
        }, {
            UICorner = roact.createElement("UICorner");
        })
    })
end

return roact_rodux.connect(
    function(state)
        return {
            afk_status = state.players[player.Name].afk and "AFK" or "Not AFK"
        }
    end
)(get_menu)
