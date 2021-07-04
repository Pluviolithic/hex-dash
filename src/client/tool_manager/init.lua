local player = game:GetService("Players").LocalPlayer
local tool_methods = {}
local current_tools = {}

for _, method in ipairs(script:GetChildren()) do
    tool_methods[method.Name] = require(method)
end

local function listen_for_tools()
    player.Backpack.ChildAdded:Connect(function(tool)
        if current_tools[tool] or not tool_methods[tool.Name] then return end
        -- the method returns a connection to userinputservice that needs cleaned up
        local connection = tool_methods[tool.Name](tool)
        current_tools[tool] = true
        tool:GetPropertyChangedSignal("Parent"):Connect(function()
            if tool.Parent then return end
            current_tools[tool] = nil
            connection:Disconnect()
        end)
    end)
end

if not player.Character then
    player.CharacterAdded:Wait()
end

listen_for_tools()
player.CharacterAdded:Connect(listen_for_tools)

return 0
