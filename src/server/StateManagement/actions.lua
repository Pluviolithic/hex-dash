local actions = {}
local make_action_creator = require(game:GetService("ReplicatedStorage").Common.Rodux).makeActionCreator

actions.add_player = make_action_creator("add_player", function(player)
    return {
        player = player;
    }
end)

actions.remove_player = make_action_creator("remove_player", function(player)
    return {
        player = player;
    }
end)

actions.player_data_loaded = make_action_creator("player_data_loaded", function(player, data)
    return {
        player = player;
        data = data;
    }
end)

actions.increment_vote = make_action_creator("increment_vote", function(player, amount)
    return {
        player = player;
        amount = amount;
    }
end)

actions.increment_cash = make_action_creator("increment_cash", function(player, amount, raw)
    return {
        player = player;
        amount = amount;
        raw = raw;
    }
end)

actions.increment_team_points = make_action_creator("increment_team_points", function(team, amount)
    return {
        team = team;
        amount = amount;
    }
end)

actions.switch_afk = make_action_creator("switch_afk", function(player)
    return {
        player = player;
    }
end)

actions.update_status = make_action_creator("update_status", function(new_status)
    return {
        new_status = new_status;
    }
end)

actions.update_team = make_action_creator("update_team", function(player, new_team)
    return {
        player = player;
        new_team = new_team;
    }
end)

actions.update_team_score = make_action_creator("update_team_score", function(team, amount)
    return {
        team = team;
        amount = amount;
    }
end)

actions.increment_wins = make_action_creator("increment_wins", function(player)
    return {
        player = player;
    }
end)

actions.set_round_player_list = make_action_creator("set_round_player_list", function(round_players)
    local round_players_list = {}
    for player in pairs(round_players) do
        table.insert(round_players_list, player.Name)
    end
    return {
        round_players = round_players_list;
    }
end)

actions.update_round_player_list = make_action_creator("update_round_player_list", function(round_players)
    return {
        round_players = round_players;
    }
end)

actions.set_player_round_status = make_action_creator("set_player_round_status", function(player, in_round)
    return {
        player = player;
        in_round = in_round;
    }
end)

actions.set_round_status = make_action_creator("set_round_status", function(in_progress)
    return {
        in_progress = in_progress;
    }
end)

return actions
