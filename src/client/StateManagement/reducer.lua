local player = game:GetService("Players").LocalPlayer
local replicated_storage = game:GetService("ReplicatedStorage")

local reducer_methods = require(replicated_storage.Common.reducer_methods)
local rodux = require(replicated_storage.Common.Rodux)
local shallow_copy = require(replicated_storage.Common.utils).shallow_copy
local initial_state = require(replicated_storage.Common.initial_states).get_initial_main_state()

function reducer_methods.switch_spectate(state) -- action isn't important here
    local new_state = shallow_copy(state)
    new_state.client_info = shallow_copy(new_state.client_info)
    if state.client_info.spectate_enabled then
        new_state.client_info.spectate_enabled = false
        return new_state
    end
    if state.round_info.in_progress and not table.find(state.round_info.round_players, player.Name) then
        new_state.client_info.spectate_enabled = true
    end
    return new_state
end

function reducer_methods.change_spectated(state, action)
    local new_state = shallow_copy(state)
    local new_spectate_index = state.client_info.spectate_index + action.direction
    new_state.client_info = shallow_copy(new_state.client_info)
    if new_spectate_index < 1 then
        new_state.client_info.spectate_index = #state.round_info.round_players
    elseif new_spectate_index > #state.round_info.round_players then
        new_state.client_info.spectate_index = 1
    else
        new_state.client_info.spectate_index = new_spectate_index
    end
    return new_state
end

return rodux.createReducer(initial_state, reducer_methods)
