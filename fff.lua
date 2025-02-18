if not game:IsLoaded() then game.Loaded:Wait() end

getgenv().consoleclear = function() end
getgenv().consolecreate = function() end
getgenv().consoledestroy = function() end
getgenv().consoleinput = function() end
getgenv().consoleprint = function() end
getgenv().consolesettitle = function() end
getgenv().rconsolename = function() end

local testdebug = table.clone(debug)

-- Assign debug functions
local debugFunctions = {
    "getconstant", "getconstants", "getinfo", "setconstant",
    "getproto", "getprotos", "getstack", "setstack",
    "getupvalue", "getupvalues", "setupvalue", "getregistry"
}

for _, func in ipairs(debugFunctions) do
    testdebug[func] = getgenv()[func]
end

debug = testdebug

-- Bitwise operations
getgenv().bit = {}
for i, v in next, bit32 do
    getgenv().bit[i] = v
end

-- Define bitwise functions
getgenv().bit.badd = function(a, b) return a + b end
getgenv().bit.bsub = function(a, b) return a - b end
getgenv().bit.bdiv = function(a, b) return a / b end
getgenv().bit.bmul = function(a, b) return a * b end

getgenv().bit.tobit = function(x)
    x = x % (2^32)
    if x >= 0x80000000 then x = x - (2^32) end
    return x
end

getgenv().bit.tohex = function(x, n)
    n = n or 8
    local up
    if n <= 0 then
        if n == 0 then return '' end
        up = true
        n = -n
    end
    x = bit.band(x, 16^n-1)
    return ('%0'..n..(up and 'X' or 'x')):format(x)
end

getgenv().bit.bswap = function(x)
    local a = bit.band(x, 0xff)
    x = bit.rshift(x, 8)
    local b = bit.band(x, 0xff)
    x = bit.rshift(x, 8)
    local c = bit.band(x, 0xff)
    x = bit.rshift(x, 8)
    local d = bit.band(x, 0xff)
    return bit.lshift(bit.lshift(bit.lshift(a, 8) + b, 8) + c, 8) + d
end

-- Thread identity functions
getgenv().setthreadidentity = function(identity)
    _setidentity(identity)
    task.wait()
end

getgenv().setidentity = getgenv().setthreadidentity
getgenv().setthreadcontext = getgenv().setthreadidentity

-- Get instances function
getgenv().getinstances = function()
    local objs = {}
    for i, v in next, getreg() do
        if type(v) == 'table' then
            for o, b in next, v do
                if typeof(b) == "Instance" then
                    table.insert(objs, b)
                end
            end
        end
    end
    return objs
end

-- CoreGui communication channels
do
    local CoreGui = game:GetService('CoreGui')
    local HttpService = game:GetService('HttpService')

    local comm_channels = CoreGui:FindFirstChild('comm_channels') or Instance.new('Folder', CoreGui)
    if comm_channels.Name ~= 'comm_channels' then
        comm_channels.Name = 'comm_channels'
    end

    getgenv().create_comm_channel = newcclosure(function() 
        local id = HttpService:GenerateGUID()
        local event = Instance.new('BindableEvent', comm_channels)
        event.Name = id
        return id, event
    end)

    getgenv().get_comm_channel = newcclosure(function(id) 
        assert(type(id) == 'string', 'string expected as argument #1')
        return comm_channels:FindFirstChild(id)
    end)
end

-- Additional functions omitted for brevity...

-- Notification example
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "[Surge]",
    Icon = "rbxassetid://101069853971193",
    Text = "Surge Premium Attached!",
    Duration = 5
})
