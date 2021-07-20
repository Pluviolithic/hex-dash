local initial_states = {}

function initial_states.get_initial_player_state()
    return {
        savable_data = {
            cash = 0;
            wins = 0;
            votes = 0;
            pets = {
                -- [pet_name] = true;
            };
            trails = {
                -- [trail_name = true;
            };
            equipped_items = {
                -- pet = pet_name
                -- trail = trail_name
            };
        };
        team = "Neutral";
        afk = false;
        in_round = false;
        is_loading = true; -- not sure if necessary
    }
end

function initial_states.get_initial_main_state()
    return {
        players = {};
        status = "";
        round_info = {
            in_progress = false;
            round_players = {};
            team_scores = {
                Blue = 0;
                Red = 0;
            };
        };
    }
end

return initial_states
