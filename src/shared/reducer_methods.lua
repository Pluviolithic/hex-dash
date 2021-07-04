local common = game:GetService("ReplicatedStorage").Common
local initial_states = require(common.initial_states)
local shallow_copy = require(common.utils).shallow_copy

local function copy_for_player_modification(state, player)
    local new_state = shallow_copy(state)
    new_state.players = shallow_copy(state.players)
    new_state.players[player] = shallow_copy(new_state.players[player])
    return new_state
end

return {
    add_player = function(state, action)
        local new_state = shallow_copy(state)
        new_state.players = shallow_copy(state.players)
        new_state.players[action.player] = initial_states.get_initial_player_state()
        return new_state
    end;
    remove_player = function(state, action)
        local new_state = shallow_copy(state)
        new_state.players = {}
        for player, player_state in pairs(state.players) do
            if player == action.player then continue end
            new_state.players[player] = player_state
        end
        return new_state
    end;
    player_data_loaded = function(state, action)
        local new_state = shallow_copy(state)
        new_state.players = shallow_copy(state.players)
        new_state.players[action.player] = action.data
        return new_state
    end;
    increment_cash = function(state, action)
        local new_state = copy_for_player_modification(state, action.player)
        new_state.players[action.player].savable_data = shallow_copy(new_state.players[action.player].savable_data)
        new_state.players[action.player].savable_data.cash += action.amount
        return new_state
    end;
    increment_team_points = function(state, action)
        local new_state = shallow_copy(state)
        new_state.round_info = shallow_copy(new_state.round_info)
        new_state.round_info.team_scores = shallow_copy(new_state.round_info.team_scores)
        new_state.round_info.team_scores[action.team] += action.amount
        return new_state
    end;
    switch_afk = function(state, action)
        local new_state = copy_for_player_modification(state, action.player)
        new_state.players[action.player].afk = not new_state.players[action.player].afk
        return new_state
    end;
    update_status = function(state, action)
        if state.status == action.new_status then return state end
        local new_state = shallow_copy(state)
        new_state.status = action.new_status
        return new_state
    end;
    update_team = function(state, action)
        if state.players[action.player].team == action.new_team then return state end
        local new_state = copy_for_player_modification(state, action.player)
        new_state.players[action.player].team = action.new_team
        return new_state
    end;
    update_team_score = function(state, action)
        local new_state = shallow_copy(state)
        new_state.round_info = shallow_copy(new_state.round_info)
        new_state.round_info.team_scores = shallow_copy(new_state.round_info.team_scores)
        new_state.round_info.team_scores[action.team] += action.amount
        return new_state
    end;
    increment_wins = function(state, action)
        local new_state = copy_for_player_modification(state, action.player)
        new_state.players[action.player].savable_data.wins += 1
        return new_state
    end;
    set_round_player_list = function(state, action)
        local new_state = shallow_copy(state)
        new_state.round_info = shallow_copy(new_state.round_info)
        new_state.round_info.round_players = action.round_players
        return new_state
    end;
    update_round_player_list = function(state, action)
        local new_round_player_list = {}
        local new_state = shallow_copy(state)
        new_state.round_info = shallow_copy(new_state.round_info)
        for _, player in ipairs(new_state.round_info.round_players) do
            if  not action.round_players[player] then continue end
            table.insert(new_round_player_list, player.Name)
        end
        new_state.round_info.round_players = new_round_player_list
        return new_state
    end;
    set_player_round_status = function(state, action)
        local new_state = copy_for_player_modification(state, action.player)
        new_state.players[action.player].in_round = action.in_round
        return new_state
    end;
    set_round_status = function(state, action)
        local new_state = shallow_copy(state)
        new_state.round_info = shallow_copy(new_state.round_info)
        new_state.round_info.in_progress = action.in_progress
        return new_state
    end;
}
