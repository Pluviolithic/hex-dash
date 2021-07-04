local gamemode_base = {}
gamemode_base.__index = gamemode_base

local utils = require(game:GetService("ReplicatedStorage").Common.utils)
local state_management = game:GetService("ServerScriptService").Server.StateManagement
local actions = require(state_management.actions)
local store = require(state_management.store)
local offset = Vector3.new(0, 5, 0)

function gamemode_base:start()
    if self.potential_early_end then return end
    self.running = true
    self:run_clock()
end

function gamemode_base:check_for_end()
    return utils.get_dictionary_length(self.players) < 2 or not self.running
end

function gamemode_base:cleanup()
    for _, connection in ipairs(self.connections) do
        if not connection.Connected then continue end
        connection:Disconnect()
    end
    for player in pairs(self.players) do
        store:dispatch(actions.set_player_round_status(player.Name, false))
    end
    --[[
    -- may add this if players are annoyed by dying from falling
    for player in pairs(self.players) do
        player:LoadCharacter()
    end
    --]]
    self.running = false -- this is in case it's called externally
    self.players = nil
    self.map:Destroy()
    store:dispatch(actions.set_round_status(false))
    utils.wait(3) -- so that players can read the results
    self.finished:Fire()
end

function gamemode_base:finish(caused_by_player)
    local qualifier = ""
    local winning_players = {}
    if utils.get_dictionary_length(self.players) > 1 then
        qualifier = "s"
    end
    for player in pairs(self.players) do
        table.insert(winning_players, player.Name)
        store:dispatch(actions.increment_cash(player.Name, 25))
        store:dispatch(actions.increment_wins(player.Name))
    end
    store:dispatch(actions.update_status("Winner"..qualifier..": "..table.concat(winning_players, ", ")))
    self.potential_early_end = caused_by_player
    self:cleanup()
end

function gamemode_base:countdown()
    return utils.spawn(function()
        for i = 3, 1, -1 do
            if self.potential_early_end then return end
            store:dispatch(actions.update_status("Starting in "..i.."..."))
            utils.wait(1)
        end
        self:start()
    end)
end

function gamemode_base:run_clock()
    for i = self.round_length - 1, 0, -1 do
        utils.wait(1)
        if not self.running then return end
        store:dispatch(actions.update_status(utils.clock_format(i)))
    end
    self:finish()
end

function gamemode_base:remove_player(player)
    store:dispatch(actions.update_team(player.Name, "Neutral"))
    self.players[player] = nil
    store:dispatch(actions.update_round_player_list(self.players))
    store:dispatch(actions.set_player_round_status(player.Name, false))
    if not self:check_for_end() then return end
    self:finish(true)
    -- true signifies finish called due to removal of player
end

function gamemode_base:teleport_player(player, spawn)
    player.Character:SetPrimaryPartCFrame(CFrame.new(spawn.Position + offset))
end

function gamemode_base:teleport_and_ready_players(map)
    local spawns = utils.shuffle(map.Spawns:GetChildren())
    for player in pairs(self.players) do
        table.insert(self.connections, player.Character.Humanoid.Died:Connect(function()
            self:remove_player(player)
        end))
        self:teleport_player(player, table.remove(spawns))
        store:dispatch(actions.set_player_round_status(player.Name, true))
    end
    table.insert(self.connections, game:GetService("Players").PlayerRemoving:Connect(function(player)
        self:remove_player(player)
    end))
end

function gamemode_base.new()
    local new_gamemode = {
        connections = {};
        running = false;
        finished = Instance.new("BindableEvent");
    }
    setmetatable(new_gamemode, gamemode_base)
    return new_gamemode
end

return gamemode_base
