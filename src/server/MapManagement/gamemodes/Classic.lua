local players = game:GetService("Players")
local tween_service = game:GetService("TweenService")
local server = game:GetService("ServerScriptService").Server
local tween_info = TweenInfo.new(0.5, Enum.EasingStyle.Linear)

local classic_gamemode = require(server.MapManagement.gamemode_base).new()
classic_gamemode.round_length = 60

function classic_gamemode:initialize(map, round_players)

    self.map = map
    self.players = round_players
    self.potential_early_end = false
    self:teleport_and_ready_players(map)

    self:countdown()

    for _, instance in ipairs(map:GetDescendants()) do
        if not instance:IsA("BasePart") then continue end
        local was_hit = false
        local tween = tween_service:Create(instance, tween_info, {Transparency = 1})
        instance.Touched:Connect(function(hit)
            if not self.running or was_hit then return end
            local player = players:GetPlayerFromCharacter(hit.Parent)
            if not player or not round_players[player] then return end
            was_hit = true
            tween:Play()
            tween.Completed:Wait()
            tween:Destroy()
            instance:Destroy()
        end)
    end

end

return classic_gamemode
