-- BarriersVisible.lua
-- External module for making invisible barriers visible in Evade game

local BarriersVisible = {}

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- Module variables
local LocalPlayer = Players.LocalPlayer
local transparencyConnection = nil
local isEnabled = false
local currentTransparency = 0 -- 0 = visible, 1 = invisible

-- Find InvisParts folder
local function findInvisParts()
    local gameFolder = Workspace:FindFirstChild("Game")
    if not gameFolder then return nil end
    
    local mapFolder = gameFolder:FindFirstChild("Map")
    if not mapFolder then return nil end
    
    return mapFolder:FindFirstChild("InvisParts")
end

-- Set transparency for all objects in InvisParts
local function setInvisPartsTransparency(transparent)
    local invisParts = findInvisParts()
    
    if not invisParts then
        return false, "InvisParts folder not found!"
    end
    
    local changed = 0
    local targetTransparency = transparent and 0 or 1
    
    for _, obj in ipairs(invisParts:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = targetTransparency
            changed = changed + 1
        end
    end
    
    currentTransparency = targetTransparency
    
    return true, changed
end

-- Monitor for new objects added to InvisParts
local function setupMonitor()
    if transparencyConnection then
        transparencyConnection:Disconnect()
    end
    
    local invisParts = findInvisParts()
    if invisParts and isEnabled then
        transparencyConnection = invisParts.DescendantAdded:Connect(function(obj)
            if isEnabled then
                -- Small delay to ensure object is fully loaded
                task.wait(0.05)
                if obj:IsA("BasePart") or obj:IsA("Decal") or obj:IsA("Texture") then
                    obj.Transparency = currentTransparency
                end
            end
        end)
    end
end

-- Public function to enable/disable barriers visibility
function BarriersVisible.SetEnabled(state)
    isEnabled = state
    
    local success, result = setInvisPartsTransparency(state)
    
    if success then
        if state then
            setupMonitor()
        else
            if transparencyConnection then
                transparencyConnection:Disconnect()
                transparencyConnection = nil
            end
        end
        
        -- Return result for notifications
        return true, string.format("Set Transparency = %s for %d objects", 
            state and "0 (visible)" or "1 (invisible)", 
            result)
    else
        return false, result
    end
end

-- Check current state
function BarriersVisible.IsEnabled()
    return isEnabled
end

-- Manual refresh (useful after map changes)
function BarriersVisible.Refresh()
    if isEnabled then
        return setInvisPartsTransparency(true)
    end
    return false, "Feature is not enabled"
end

-- Get current transparency value
function BarriersVisible.GetTransparency()
    return currentTransparency
end

-- Get status information
function BarriersVisible.GetInfo()
    local invisParts = findInvisParts()
    local objectCount = 0
    local affectedObjects = {}
    
    if invisParts then
        for _, obj in ipairs(invisParts:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("Decal") or obj:IsA("Texture") then
                objectCount = objectCount + 1
                table.insert(affectedObjects, {
                    name = obj.Name,
                    class = obj.ClassName,
                    transparency = obj.Transparency
                })
            end
        end
    end
    
    return {
        enabled = isEnabled,
        folderFound = invisParts ~= nil,
        objectCount = objectCount,
        currentTransparency = currentTransparency,
        affectedObjects = affectedObjects
    }
end

-- Set custom transparency value (0-1)
function BarriersVisible.SetCustomTransparency(value)
    if value < 0 or value > 1 then
        return false, "Transparency must be between 0 and 1"
    end
    
    local invisParts = findInvisParts()
    if not invisParts then
        return false, "InvisParts folder not found!"
    end
    
    local changed = 0
    currentTransparency = value
    
    for _, obj in ipairs(invisParts:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = value
            changed = changed + 1
        end
    end
    
    return true, changed
end

-- Auto-reapply on character respawn if enabled
LocalPlayer.CharacterAdded:Connect(function()
    if isEnabled then
        task.wait(1) -- Wait for map to load
        setInvisPartsTransparency(true)
        setupMonitor()
    end
end)

-- Cleanup on game leave
game:GetService("Players").PlayerRemoving:Connect(function(player)
    if player == LocalPlayer and isEnabled then
        setInvisPartsTransparency(false)
    end
end)

-- Cleanup function
function BarriersVisible.Cleanup()
    if isEnabled then
        setInvisPartsTransparency(false)
    end
    
    if transparencyConnection then
        transparencyConnection:Disconnect()
        transparencyConnection = nil
    end
    
    isEnabled = false
end

return BarriersVisible
