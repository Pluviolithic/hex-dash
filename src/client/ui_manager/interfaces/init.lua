local roact = require(game:GetService("ReplicatedStorage").Common.Roact)
local interfaces = {}

for _, interface in ipairs(script:GetChildren()) do
    interfaces[interface.Name] = roact.createElement(require(interface))
end

return interfaces
