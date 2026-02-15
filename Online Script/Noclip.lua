-- Noclip.lua
-- External module for noclip functionality

local Noclip = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Module variables
local LocalPlayer = Players.LocalPlayer
local noclipConnection = nil
local isEnabled = false

-- Apply noclip to character
local function applyNoclip(character)
    if not character or not isEnabled then return end
    
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
        end
    end
end

-- Main noclip update function
local function noclipUpdate()
    if not isEnabled then return end
    
    local character = LocalPlayer.Character
    if character then
        applyNoclip(character)
    end
end

-- Public function to enable/disable noclip
function Noclip.SetEnabled(state)
    isEnabled = state
    
    if state then
        -- Start noclip
        if not noclipConnection then
            noclipConnection = RunService.Stepped:Connect(noclipUpdate)
        end
        
        -- Apply immediately if character exists
        local character = LocalPlayer.Character
        if character then
            applyNoclip(character)
        end
        
        return true, "Noclip enabled"
    else
        -- Stop noclip
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        
        -- Restore collision for current character
        local character = LocalPlayer.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
        
        return true, "Noclip disabled"
    end
end

-- Clean up
function Noclip.Cleanup()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    isEnabled = false
end

-- Auto-reapply on character respawn if enabled
LocalPlayer.CharacterAdded:Connect(function()
    if isEnabled then
        task.wait(0.5)
        local character = LocalPlayer.Character
        if character then
            applyNoclip(character)
        end
    end
end)

return Noclip
