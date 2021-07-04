-- create pool of maps and associated gamemodes
-- the maps will be shuffled and then the associated array of gamemeodes will be used till gone

local maps = game:GetService("ServerStorage").Maps
local utils = require(game:GetService("ReplicatedStorage").Common.utils)
local vote_queue = utils.create_queue()

local pool = {}
local map_pool_info = {
    current_map = 0;
    last_map_name = "";
}

map_pool_info.pool = pool

for _, map in ipairs(maps:GetChildren()) do
    local associated_gamemodes = {}
    for _, gamemode in ipairs(map.Gamemodes:GetChildren()) do
        table.insert(associated_gamemodes, gamemode.Name)
    end
    table.insert(pool, {[map.Name] = utils.shuffle(associated_gamemodes)})
end

map_pool_info.temp = utils.shuffle(utils.deep_copy(pool))

function map_pool_info:get_random_map_gamemode_pair() -- employ this method if no votes have been made
    if #map_pool_info.temp < 1 then
        map_pool_info.temp = utils.shuffle(utils.deep_copy(pool))
        if next(map_pool_info.temp[1]) == self.last_map_name then
            map_pool_info.temp[1], map_pool_info.temp[#map_pool_info.temp] = map_pool_info.temp[#map_pool_info.temp], map_pool_info.temp[1]
        end
    end
    self.current_map = self.current_map < #map_pool_info.temp and self.current_map + 1 or 1
    local map_selection = next(map_pool_info.temp[self.current_map])
    local gamemode_selection = table.remove(map_pool_info.temp[self.current_map][map_selection])
    if #map_pool_info.temp[self.current_map][map_selection] < 1 then
        table.remove(map_pool_info.temp, self.current_map)
        self.current_map -= 1
    end
    self.last_map_name = map_selection
    return {map_selection, gamemode_selection}
end

function map_pool_info:verify_vote(map_name, gamemode_name) -- I will probably have the client send two args to the server and it will put them in a table
    if type(map_name) ~= "string" or type(gamemode_name) ~= "string" then return false end
    return maps:FindFirstChild(map_name) and maps[map_name].Gamemodes:FindFirstChild(gamemode_name) and true
    -- not as clean as I'd like, but abstracted version would be more resource-heavy
end

-- devproducts handler will decide if they can vote; this just processes the vote
function map_pool_info:submit_vote(vote) -- vote is an array: {map_name, gamemode_name}
    vote_queue:queue(vote)
end

function map_pool_info:get_next_map_gamemode_pair()
    return vote_queue:dequeue() or self:get_random_map_gamemode_pair()
end

function map_pool_info:get_map_model(map_name)
    return maps[map_name]:Clone()
end

return map_pool_info
