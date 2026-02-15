-- UnlockedTimePass.lua
-- External module for unlocking time pass in Evade game

local UnlockedTimePass = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Module variables
local LocalPlayer = Players.LocalPlayer
local unlockedPassConnection = nil
local isEnabled = false

-- Hide unlocked pass
local function hideUnlockedPass()
    local menu = LocalPlayer.PlayerGui:FindFirstChild("Menu")
    if not menu then return end
    
    local battlepass = menu:FindFirstChild("Views") and menu.Views:FindFirstChild("Battlepass")
    if not battlepass then return end
    
    local viewPass = battlepass:FindFirstChild("ViewPass")
    if not viewPass then return end
    
    local center = viewPass:FindFirstChild("Center")
    if not center then return end
    
    local viewPassCenter = center:FindFirstChild("ViewPass")
    if not viewPassCenter then return end
    
    local unlocked = viewPassCenter:FindFirstChild("Unlocked")
    if unlocked then
        unlocked.Visible = false
    end
end

-- Show unlocked pass (restore)
local function showUnlockedPass()
    local menu = LocalPlayer.PlayerGui:FindFirstChild("Menu")
    if not menu then return end
    
    local battlepass = menu:FindFirstChild("Views") and menu.Views:FindFirstChild("Battlepass")
    if not battlepass then return end
    
    local viewPass = battlepass:FindFirstChild("ViewPass")
    if not viewPass then return end
    
    local center = viewPass:FindFirstChild("Center")
    if not center then return end
    
    local viewPassCenter = center:FindFirstChild("ViewPass")
    if not viewPassCenter then return end
    
    local unlocked = viewPassCenter:FindFirstChild("Unlocked")
    if unlocked then
        unlocked.Visible = true
    end
end

-- Main update function
local function unlockedPassUpdate()
    if not isEnabled then return end
    hideUnlockedPass()
end

-- Public function to enable/disable unlocked time pass
function UnlockedTimePass.SetEnabled(state)
    isEnabled = state
    
    if state then
        -- Start monitoring
        if not unlockedPassConnection then
            unlockedPassConnection = RunService.Heartbeat:Connect(unlockedPassUpdate)
        end
        
        -- Apply immediately
        hideUnlockedPass()
        
        return true, "Unlocked Time Pass hidden"
    else
        -- Stop monitoring
        if unlockedPassConnection then
            unlockedPassConnection:Disconnect()
            unlockedPassConnection = nil
        end
        
        -- Show pass
        showUnlockedPass()
        
        return true, "Unlocked Time Pass shown"
    end
end

-- Clean up
function UnlockedTimePass.Cleanup()
    if isEnabled then
        showUnlockedPass()
    end
    
    if unlockedPassConnection then
        unlockedPassConnection:Disconnect()
        unlockedPassConnection = nil
    end
    
    isEnabled = false
end

-- Auto-reapply on character respawn if enabled
LocalPlayer.CharacterAdded:Connect(function()
    if isEnabled then
        task.wait(1)
        hideUnlockedPass()
    end
end)

return UnlockedTimePass
