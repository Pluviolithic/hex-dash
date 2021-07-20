local player = game:GetService("Players").LocalPlayer
local client = game:GetService("StarterPlayer").StarterPlayerScripts.Client
local common = game:GetService("ReplicatedStorage").Common
local marketplace_service = game:GetService("MarketplaceService")

local roact = require(common.Roact)
local roact_rodux = require(common.RoactRodux)
local store = require(client.StateManagement.store)
local actions = require(client.StateManagement.actions)
local product_info = require(client.product_info)

local function get_menu_component(name)
    return roact.createElement("Frame", {
        Size = UDim2.fromScale(0.2, 0.9);
    }, {
        Button = roact.createElement("TextButton", {
            AnchorPoint = Vector2.new(0.5, 0.5);
            Position = UDim2.fromScale(0.5, 0.5);
            Size = UDim2.fromScale(0.95, 0.7);
            [roact.Event.Activated] = function()
                store:dispatch(actions.change_shop_selection(name))
            end;
        }, {
            UICorner = roact.createElement("UICorner");
        });
    })
end

local function get_scrolling_frame_elements(props)
    if not props.shop_enabled then return nil end
    local elements = {
        UICorner = roact.createElement("UICorner");
    }
    return elements
end

local function get_shop_component(props)
    return roact.createElement("Frame", {
        Position = UDim2.fromScale(0.275, 0.211);
        Size = UDim2.fromScale(0.45, 0.576);
        Visible = props.shop_enabled;
    }, {
        Exit = roact.createElement("TextButton", {
            Position = UDim2.fromScale(1.05, 0);
            Size = UDim2.fromScale(0.1, 0.1);
            AnchorPoint = Vector2.new(1, 1);
            [roact.Event.Activated] = function()
                store:dispatch(actions.switch_shop())
            end;
        }, {
            UIAspectRatioConstraint = roact.createElement("UIAspectRatioConstraint");
            UICorner = roact.createElement("UICorner");
        });
        ScrollingFrame = roact.createElement("ScrollingFrame", {
            Size = UDim2.fromScale(1, 0.84);
            Position = UDim2.fromScale(0, 0.161);
        }, get_scrolling_frame_elements(props));
        Menu = roact.createElement("Frame", {
            Position = UDim2.new();
            Size = UDim2.fromScale(0.937, 0.16);
        }, {
            Cash = get_menu_component("Cash");
            Gamepasses = get_menu_component("Gamepasses");
            Trails = get_menu_component("Trails");
            Pets = get_menu_component("Pets");
            UIListLayout = roact.createElement("UIListLayout");
        });
    })
end

return roact_rodux.connect(
    function(state)
        return {
            shop_enabled = state.shop_enabled;
        }
    end
)(get_shop_component)
