local interfaces = {}

for _, interface in ipairs(script:GetChildren()) do
    interfaces[interface.Name] = require(interface)
end

return interfaces
