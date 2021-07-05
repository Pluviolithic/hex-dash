local actions = {}
local make_action_creator = require(game:GetService("ReplicatedStorage").Common.Rodux).makeActionCreator

actions.switch_spectate = make_action_creator("switch_spectate", function()
    return {}
end)

actions.change_spectated = make_action_creator("change_spectated", function(direction)
    return {
        direction = direction;
    }
end)

actions.switch_shop = make_action_creator("switch_shop", function()
    return {}
end)

return actions
