local players = game:GetService("Players")
local client = game:GetService("StarterPlayer").StarterPlayerScripts.Client
local common = game:GetService("ReplicatedStorage").Common
local player = players.LocalPlayer
local camera = workspace.CurrentCamera

local roact = require(common.Roact)
local roact_rodux = require(common.RoactRodux)
local store = require(client.StateManagement.store)
local actions = require(client.StateManagement.actions)

store.changed:connect(function(new_state, old_state)
    if not new_state.round_info.in_progress and old_state.round_info.in_progress then
        store:dispatch(actions.switch_spectate())
        return
    end
    if new_state.client_info.spectate_index ~= old_state.client_info.spectate_index then
        local spectated_player = players[new_state.round_info.round_players[new_state.client_info.spectate_index]]
        camera.CameraSubject = spectated_player.Character.Humanoid
        return
    end
    local spectate_enabled = new_state.client_info.spectate_enabled
    if spectate_enabled == old_state.client_info.spectate_enabled then return end
    if spectate_enabled then
        local spectated_player = players[new_state.round_info.round_players[1]]
        camera.CameraSubject = spectated_player.Character.Humanoid
    else
        camera.CameraSubject = (player.Character or player.CharacterAdded:Wait()):WaitForChild("Humanoid")
    end
end)

local function get_spectate_component(props)
    return roact.createElement("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5);
        Position = UDim2.fromScale(0.5, 0.8);
        Size = UDim2.fromScale(0.2, 0.15);
        Visible = props.round_in_progress and props.spectating;
        --BackgroundTransparency = 1;
    }, {
        UICorner = roact.createElement("UICorner");
        Left = roact.createElement("TextButton", {
            AutoButtonColor = false;
            BorderSizePixel = 0;
            Position = UDim2.fromScale(0.025, 0.18);
            Size = UDim2.fromScale(0.149, 0.64);
            --TextSize = 65;
            TextScaled = true;
            Text = "<";
            [roact.Event.Activated] = function()
                store:dispatch(actions.change_spectated(-1))
            end;
        });
        Right = roact.createElement("TextButton", {
            AutoButtonColor = false;
            BorderSizePixel = 0;
            --TextSize = 65;
            TextScaled = true;
            Position = UDim2.fromScale(0.83, 0.18);
            Size = UDim2.fromScale(0.149, 0.64);
            Text = ">";
            [roact.Event.Activated] = function()
                store:dispatch(actions.change_spectated(1))
            end;
        });
        Stop = roact.createElement("TextButton", {
            AnchorPoint = Vector2.new(0.5, 0.5);
            AutoButtonColor = false;
            Text = "Stop Spectating";
            Position = UDim2.fromScale(0.497, 0.793);
            Size = UDim2.fromScale(0.316, 0.412);
            BackgroundColor3 = Color3.fromRGB(85, 170, 255);
            [roact.Event.Activated] = function()
                store:dispatch(actions.switch_spectate())
            end;
        }, {
            UICorner = roact.createElement("UICorner");
        });
        CurrentDisplay = roact.createElement("TextLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5);
            Position = UDim2.fromScale(0.5, 0.4);
            Size = UDim2.fromScale(0.6, 0.4);
            Text = props.spectated_player_name;
            TextScaled = true;
            BorderSizePixel = 0;
        });
    })
end

return roact_rodux.connect(
    function(state)
        return {
            spectating = state.client_info.spectate_enabled;
            round_in_progress = state.round_info.in_progress;
            spectated_player_name = state.round_info.round_players[state.client_info.spectate_index];
        }
    end
)(get_spectate_component)
