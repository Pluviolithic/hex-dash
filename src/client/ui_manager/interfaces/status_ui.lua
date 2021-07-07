local common = game:GetService("ReplicatedStorage").Common
local roact = require(common.Roact)
local roact_rodux = require(common.RoactRodux)

local function get_status_component(props)
    return roact.createElement("TextLabel", {
        Position = UDim2.fromScale(0.4, 0.03);
        Size = UDim2.fromScale(0.2, 0.1);
        BackgroundColor3 = Color3.fromRGB(255, 170, 0);
        TextScaled = true;
        Text = props.status;
    }, {
        UICorner = roact.createElement("UICorner");
    })
end

return roact_rodux.connect(
    function(state)
        return {
            status = state.status
        }
    end
)(get_status_component)

