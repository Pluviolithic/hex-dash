local common = game:GetService("ReplicatedStorage").Common
local initial_state = require(common.initial_states).get_initial_main_state()

return require(common.Rodux).createReducer(initial_state, require(common.reducer_methods))
