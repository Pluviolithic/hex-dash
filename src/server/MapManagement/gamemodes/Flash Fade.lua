local utils = require(game:GetService("ReplicatedStorage").Common.utils)
local server = game:GetService("ServerScriptService").Server

local fade_gamemode = require(server.MapManagement.gamemode_base).new()
fade_gamemode.round_length = 60

function fade_gamemode:start()
    self.running = true
    utils.spawn(self.run_clock, self)

    local map_parts = utils.shuffle(self.map_parts)
    local part_count = #map_parts

    for i = 1, 3 do
        utils.spawn(function()
            for j = math.ceil(part_count*(i - 1)/3) + 1, math.ceil(part_count*i/3) do
                map_parts[j]:Destroy()
                utils.wait()
            end
        end)
    end

end

function fade_gamemode:initialize(map, round_players)

    self.map = map
    self.map_parts = {}
    self.players = round_players
    self.potential_early_end = false
    self:teleport_and_ready_players(map)

    self:countdown()

    for _, map_part in ipairs(map:GetDescendants()) do
        if not map_part:IsA("BasePart") then continue end
        table.insert(self.map_parts, map_part)
    end

end


return fade_gamemode
