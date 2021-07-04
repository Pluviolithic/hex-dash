local player = game:GetService("Players").LocalPlayer
local place_explosive = game:GetService("ReplicatedStorage").Remotes.PlaceExplosive
local user_input_service = game:GetService("UserInputService")

local camera = workspace.CurrentCamera
local raycast_parameters = RaycastParams.new()
local enabled = false
local range = 100
local last_fired = -1

local function handle_input_position(position)
    if os.time() - last_fired < 5 then return end
    local unit_ray = camera:ViewportPointToRay(position.X, position.Y)
    local raycast_result = workspace:Raycast(unit_ray.Origin, unit_ray.Direction*range, raycast_parameters)
    if not raycast_result.Instance then return end
    last_fired = os.time()
    place_explosive:FireServer(raycast_result.Position)
end

return function(tool) -- returns the event connection
    raycast_parameters.FilterDescendantsInstances = {player.Character}
    tool.Equipped:Connect(function()
        enabled = true
    end)
    tool.Unequipped:Connect(function()
        enabled = false
    end)
    if user_input_service.TouchEnabled and not user_input_service.KeyboardEnabled and not user_input_service.MouseEnabled then
        return user_input_service.TouchTapInWorld:Connect(function(position, ui_event)
            if ui_event or not enabled then return end
            handle_input_position(position)
        end)
    end
    return user_input_service.InputBegan:Connect(function(input_object, game_event)
        if game_event or not enabled then return end
        if input_object.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        handle_input_position(user_input_service:GetMouseLocation())
    end)
end
