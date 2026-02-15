-- OpenExchange.lua
-- External module for opening exchange in Evade game

local OpenExchange = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Module variables
local LocalPlayer = Players.LocalPlayer
local exchangeConnection = nil
local isEnabled = false

-- Show exchange and hide viewpass
local function showExchange()
    local menu = LocalPlayer.PlayerGui:FindFirstChild("Menu")
    if not menu then return end
    
    local battlepass = menu:FindFirstChild("Views") and menu.Views:FindFirstChild("Battlepass")
    if not battlepass then return end
    
    -- Show Exchange
    local exchange = battlepass:FindFirstChild("Exchange")
    if exchange then
        exchange.Visible = true
    end
    
    -- Hide ViewPass
    local viewPass = battlepass:FindFirstChild("ViewPass")
    if viewPass then
        viewPass.Visible = false
    end
end

-- Restore default view (hide exchange, show viewpass)
local function restoreDefault()
    local menu = LocalPlayer.PlayerGui:FindFirstChild("Menu")
    if not menu then return end
    
    local battlepass = menu:FindFirstChild("Views") and menu.Views:FindFirstChild("Battlepass")
    if not battlepass then return end
    
    -- Hide Exchange
    local exchange = battlepass:FindFirstChild("Exchange")
    if exchange then
        exchange.Visible = false
    end
    
    -- Show ViewPass
    local viewPass = battlepass:FindFirstChild("ViewPass")
    if viewPass then
        viewPass.Visible = true
    end
end

-- Main update function
local function exchangeUpdate()
    if not isEnabled then return end
    showExchange()
end

-- Public function to enable/disable open exchange
function OpenExchange.SetEnabled(state)
    isEnabled = state
    
    if state then
        -- Start monitoring
        if not exchangeConnection then
            exchangeConnection = RunService.Heartbeat:Connect(exchangeUpdate)
        end
        
        -- Apply immediately
        showExchange()
        
        return true, "Exchange opened"
    else
        -- Stop monitoring
        if exchangeConnection then
            exchangeConnection:Disconnect()
            exchangeConnection = nil
        end
        
        -- Restore default
        restoreDefault()
        
        return true, "Exchange closed"
    end
end

-- Clean up
function OpenExchange.Cleanup()
    if isEnabled then
        restoreDefault()
    end
    
    if exchangeConnection then
        exchangeConnection:Disconnect()
        exchangeConnection = nil
    end
    
    isEnabled = false
end

-- Auto-reapply on character respawn if enabled
LocalPlayer.CharacterAdded:Connect(function()
    if isEnabled then
        task.wait(1)
        showExchange()
    end
end)

return OpenExchange
