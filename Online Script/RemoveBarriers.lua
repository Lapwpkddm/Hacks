-- RemoveBarriers.lua
-- External module for removing barriers/invisible walls in Evade game

local RemoveBarriers = {}

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- Module variables
local LocalPlayer = Players.LocalPlayer
local barrierConnection = nil
local isEnabled = false

-- Find InvisParts folder
local function findInvisParts()
    local gameFolder = Workspace:FindFirstChild("Game")
    if not gameFolder then return nil end
    
    local mapFolder = gameFolder:FindFirstChild("Map")
    if not mapFolder then return nil end
    
    return mapFolder:FindFirstChild("InvisParts")
end

-- Toggle collision for all objects in InvisParts
local function toggleInvisPartsCollision(state)
    local invisParts = findInvisParts()
    
    if not invisParts then
        return false, "InvisParts folder not found!"
    end
    
    local objectsChanged = 0
    
    -- Process all descendants
    for _, obj in ipairs(invisParts:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.CanCollide = not state -- If state = true, disable collision
            objectsChanged = objectsChanged + 1
        end
    end
    
    return true, objectsChanged
end

-- Monitor for new objects added to InvisParts
local function setupMonitor()
    if barrierConnection then
        barrierConnection:Disconnect()
    end
    
    local invisParts = findInvisParts()
    if invisParts and isEnabled then
        barrierConnection = invisParts.DescendantAdded:Connect(function(obj)
            if isEnabled and obj:IsA("BasePart") then
                -- Small delay to ensure object is fully loaded
                task.wait(0.05)
                obj.CanCollide = false
            end
        end)
    end
end

-- Public function to enable/disable barrier removal
function RemoveBarriers.SetEnabled(state)
    isEnabled = state
    
    local success, result = toggleInvisPartsCollision(state)
    
    if success then
        if state then
            setupMonitor()
        else
            if barrierConnection then
                barrierConnection:Disconnect()
                barrierConnection = nil
            end
        end
        
        -- Return result for notifications
        return true, string.format("%s collision for %d objects", 
            state and "Disabled" or "Enabled", 
            result)
    else
        return false, result
    end
end

-- Check current state
function RemoveBarriers.IsEnabled()
    return isEnabled
end

-- Manual refresh (useful after map changes)
function RemoveBarriers.Refresh()
    if isEnabled then
        return toggleInvisPartsCollision(true)
    end
    return false, "Feature is not enabled"
end

-- Get status information
function RemoveBarriers.GetInfo()
    local invisParts = findInvisParts()
    local objectCount = 0
    
    if invisParts then
        for _ in ipairs(invisParts:GetDescendants()) do
            objectCount = objectCount + 1
        end
    end
    
    return {
        enabled = isEnabled,
        folderFound = invisParts ~= nil,
        objectCount = objectCount
    }
end

-- Auto-reapply on character respawn if enabled
LocalPlayer.CharacterAdded:Connect(function()
    if isEnabled then
        task.wait(1) -- Wait for map to load
        toggleInvisPartsCollision(true)
        setupMonitor()
    end
end)

-- Cleanup
function RemoveBarriers.Cleanup()
    if barrierConnection then
        barrierConnection:Disconnect()
        barrierConnection = nil
    end
    isEnabled = false
end

return RemoveBarriers
