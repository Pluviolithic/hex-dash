local server_storage = game:GetService("ServerStorage")
local replicated_storage = game:GetService("ReplicatedStorage")
local utils = require(replicated_storage.Common.utils)
local server = game:GetService("ServerScriptService").Server

local remote_detonator = server_storage.Tools.C4
local place_explosive = replicated_storage.Remotes.PlaceExplosive
local explosive = server_storage.Miscellaneous.Explosive
local explosive_material = explosive.Material
local neon_material = Enum.Material.Neon
local region_size = Vector3.new(1, 1, 1)*12.5 -- must be half the total size
local range = 100

local explosion = Instance.new("Explosion")
explosion.BlastRadius = 30
explosion.BlastPressure = 0
explosion.ExplosionType = Enum.ExplosionType.NoCraters

local demolition_gamemode = require(server.MapManagement.gamemode_base).new()
demolition_gamemode.round_length = 60

function demolition_gamemode:initialize(map, round_players)

    self.map = map
    self.map_parts = {}
    self.debounces = {}
    self.potential_early_end = false
    self.players = round_players
    self:teleport_and_ready_players(map)

    for player in pairs(self.players) do
        remote_detonator:Clone().Parent = player.Backpack
    end

    self:countdown()

    local ignore_list = {}

    for player in pairs(self.players) do
        table.insert(ignore_list, player.Character)
    end

    table.insert(self.connections, place_explosive.OnServerEvent:Connect(function(player, position)
        if not self.running then return end
        local root_part = player.Character.Humanoid.RootPart
        if (position - root_part.Position).Magnitude > range or os.time() - (self.debounces[player] or -1) < 5 then return end
        self.debounces[player] = os.time()

        -- will want to add beeping to the bomb later
        local new_explosive = explosive:Clone()
        local new_explosion = explosion:Clone()
        local region = Region3.new(position - region_size, position + region_size)
        local parts_to_destroy = workspace:FindPartsInRegion3WithIgnoreList(region, ignore_list, math.huge)

        new_explosive.Position = position
        new_explosive.Parent = workspace

        for i = 1, 6 do
            utils.wait(0.5)
            new_explosive.Material = i%2 < 1 and explosive_material or neon_material
        end

        new_explosion.Position = position
        new_explosion.Parent = workspace
        utils.wait()
        new_explosive:Destroy()

        for _, part in ipairs(parts_to_destroy) do
            part:Destroy()
        end

    end))

end


return demolition_gamemode
