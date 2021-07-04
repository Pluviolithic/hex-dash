local gamemodes = {}

for _, gamemode in ipairs(script:GetChildren()) do
    gamemodes[gamemode.Name] = require(gamemode)
end

return gamemodes
