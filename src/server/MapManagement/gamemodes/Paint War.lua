local players = game:GetService("Players")
local server = game:GetService("ServerScriptService").Server
local actions = require(server.StateManagement.actions)
local store = require(server.StateManagement.store)

local paint_gamemode = require(server.MapManagement.gamemode_base).new()
paint_gamemode.round_length = 90

local team_colors = {
    -- will likely have completely different colors in in the final version
    -- might even be sensible to randomize potential colors
    Blue = Color3.fromRGB(0, 0, 255);
    Red = Color3.fromRGB(255, 0, 0);
}

local function get_other_team_color(color)
    return team_colors.Blue == color and team_colors.Red or team_colors.Blue
end

local function get_other_team(team)
    return team == "Blue" and "Red" or "Blue"
end

local function format_results(scores, winning_team)
    if winning_team then
        return winning_team.." team won! "..scores[winning_team].." - "..scores[get_other_team(winning_team)]
    end
    return "The game was a tie! "..scores.Blue.." - "..scores.Red
end

function paint_gamemode:set_teams()
    local i = 1
    for player in pairs(self.players) do
        store:dispatch(actions.update_team(player.Name, i%2 < 1 and "Blue" or "Red"))
        i += 1
    end
end

--TODO: adjust this to behave differently if all players on one team die
-- message can be x team won! The other team lost all its players!
function paint_gamemode:finish(player_removal)
    if player_removal then
        local winning_team = store:getState().players[next(self.players).Name].team
        store:dispatch(actions.update_status(winning_team.." team won! Blue lost all its players!"))
        self.potential_early_end = true
        self:cleanup()
        return
    end
    local team_scores = store:getState().round_info.team_scores
    self.running = false
    if team_scores.Blue == team_scores.Red then
        store:dispatch(actions.update_status(format_results(team_scores)))
        self:cleanup()
        return
    end
    local winning_team = team_scores.Blue > team_scores.Red and "Blue" or "Red"
    local player_info = store:getState().players
    for player in pairs(self.players) do
        if player_info[player.Name].team ~= winning_team then continue end
        store:dispatch(actions.increment_cash(player.Name, 25))
        store:dispatch(actions.increment_wins(player.Name))
    end
    store:dispatch(actions.update_status(format_results(team_scores, winning_team)))
    self:cleanup()
end

function paint_gamemode:check_for_end()
    local player_info = store:getState().players
    local team_counts = {Blue = 0; Red = 0;}
    for player in pairs(self.players) do
        team_counts[player_info[player.Name].team] += 1
    end
    return not (team_counts.Blue > 0 and team_counts.Red > 0) or not self.running
end

function paint_gamemode:initialize(map, round_players)

    self.map = map
    self.players = round_players
    self.potential_early_end = false

    self:teleport_and_ready_players(map)
    self:set_teams()

    self:countdown()

    for _, instance in ipairs(map:GetDescendants()) do
        if not instance:IsA("BasePart") then continue end
        local last_hit = -1
        instance.Touched:Connect(function(hit)
            if not self.running or os.time() - last_hit < 1 then return end
            local player = players:GetPlayerFromCharacter(hit.Parent)
            if not player or not round_players[player] then return end
            last_hit = os.time()
            local team = store:getState().players[player.Name].team
            local instance_color = instance.Color
            if instance_color == team_colors[team] then return end
            local other_team = get_other_team_color(team)
            instance.Color = team_colors[team]
            store:dispatch(actions.increment_team_points(team, 1))
            if instance_color ~= team_colors[other_team] then return end
            store:dispatch(actions.increment_team_points(other_team, -1))
        end)
    end

end

return paint_gamemode
