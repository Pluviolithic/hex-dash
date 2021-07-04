local utils = {}

local run_service = game:GetService("RunService")
local stepped = run_service:IsServer() and run_service.Heartbeat or run_service.RenderStepped
local suffixes = require(game:GetService("ReplicatedStorage").Common.suffixes)
local random_object = Random.new()

function utils.wait(n)
    n = n or 0.03
    local waited_time = 0
    repeat
        waited_time += stepped:Wait()
    until waited_time >= n
    return waited_time
end

function utils.spawn(f, ...)
    return coroutine.wrap(f)(...)
end

function utils.delay(t, f)-- just in case, will probably remove
    return utils.spawn(function() -- not sure if I really want to return, but why not?
        utils.wait(t)
        f()
    end)
end

local function get_power(n)
    return math.floor(math.log(math.abs(n) + 1)/math.log(10))
end

function utils.format_number(n)
    local power = math.floor(get_power(n)/3)
    local s = tostring(n/10^(power*3))
    local truncated_s = s:match("%.") and s:sub(1, 4) or s:sub(1, 3)
    return truncated_s:gsub("%.?0+$", "")..(suffixes[power] or "")
end

function utils.get_dictionary_length(t)
    local length = 0
    for _ in pairs(t) do
        length += 1
    end
    return length
end

function utils.clock_format(t)
    local minutes = math.floor(t/60)
    local seconds = t%60
    return (minutes < 10 and "0"..minutes or minutes)..":"..(seconds < 10 and "0"..seconds or seconds)
end

function utils.shuffle(t)
    for n = #t, 1, -1 do
        local k = random_object:NextInteger(1, n)
        t[n], t[k] = t[k], t[n]
    end
    return t
end

function utils.weighted_random(weights) -- save for later
    -- do something
end

function utils.shallow_copy(t)
    local new_t = {}
    for key, value in pairs(t) do
        new_t[key] = value
    end
    return new_t
end

function utils.deep_copy(t)
    if type(t) ~= "table" then return t end
    local new_t = {}
    for key, value in pairs(t) do
        new_t[utils.deep_copy(key)] = utils.deep_copy(value)
    end
    return new_t
end

function utils.create_queue()
    local queue = {
        last = 0;
        first = 1;
    }
    local observers = {}
    function queue:enqueue(value)
        self.last += 1
        self[self.last] = value
        for f in pairs(observers) do
            utils.spawn(function()
                pcall(f, value)
            end)
        end
    end
    function queue:dequeue()
        if self.first > self.last then
            self.first = 1
            self.last = 0
            return nil
        end
        local value = self[self.first]
        self[self.first] = nil
        self.first += 1
        return value
    end
    function queue:iterator()
        local i = self.first - 1
        local n = self.last
        return function()
            i += 1
            if i <= n then
                return self[i]
            end
        end
    end
    function queue.on_queue(f)
        observers[f] = true
        return {
            disconnect = function()
                observers[f] = nil
            end
        }
    end
    return queue
end

return utils
