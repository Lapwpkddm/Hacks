-- SimpleTimer.lua
-- External module for creating FPS and session timer in Evade game

local SimpleTimer = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StatsService = game:GetService("Stats")

-- Module variables
local LocalPlayer = Players.LocalPlayer
local timerInstance = nil
local isEnabled = false
local gradientAnimation = nil

-- Create the timer GUI
local function createTimer()
    -- Check if timer already exists
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    
    local existingTimer = playerGui:FindFirstChild("DraconicFPS")
    if existingTimer then
        return existingTimer
    end
    
    -- Создаём GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DraconicFPS"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui
    
    -- Основной контейнер
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 165, 0, 48)
    container.Position = UDim2.new(0, 10, 0, 10)
    container.BackgroundTransparency = 1
    container.Parent = screenGui
    
    -- Основной фон с градиентом
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.BackgroundTransparency = 0.7  -- Полупрозрачный
    mainFrame.Parent = container
    
    -- Градиент для фона
    local backgroundGradient = Instance.new("UIGradient")
    backgroundGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),      -- Красный
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 0, 0)),     -- Черный
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))      -- Красный
    }
    backgroundGradient.Rotation = 0
    backgroundGradient.Parent = mainFrame
    
    -- Анимация вращения для градиента фона
    gradientAnimation = RunService.RenderStepped:Connect(function(delta)
        backgroundGradient.Rotation = (backgroundGradient.Rotation + 90 * delta) % 360
    end)
    
    -- Обычный контур (не градиентный)
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(139, 0, 0)  -- Темно-красный
    stroke.Thickness = 2
    stroke.Parent = mainFrame
    
    -- Закругленные углы
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    -- Контейнер для текста
    local textFrame = Instance.new("Frame")
    textFrame.Size = UDim2.new(1, -8, 1, -8)
    textFrame.Position = UDim2.new(0, 4, 0, 4)
    textFrame.BackgroundTransparency = 1
    textFrame.Parent = mainFrame
    
    -- Добавляем возможность перетаскивания
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    -- Функция для начала перетаскивания
    local function update(input)
        local delta = input.Position - dragStart
        container.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, 
                                      startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    -- Обработчики событий для перетаскивания
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = container.Position
            
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    connection:Disconnect()
                end
            end)
        end
    end)
    
    mainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    -- Обработка перемещения мыши/тача
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    
    -- Тексты FPS, Ping и таймера
    local statsText = Instance.new("TextLabel")
    statsText.Size = UDim2.new(1, -10, 0.5, 0)
    statsText.Position = UDim2.new(0, 5, 0, 0)
    statsText.BackgroundTransparency = 1
    statsText.TextColor3 = Color3.fromRGB(255, 255, 255)
    statsText.Font = Enum.Font.GothamBold
    statsText.TextSize = 13
    statsText.TextXAlignment = Enum.TextXAlignment.Center
    statsText.Text = "FPS: 60 | Ping: 0ms"
    statsText.Parent = textFrame
    
    local timerText = Instance.new("TextLabel")
    timerText.Size = UDim2.new(1, -10, 0.5, 0)
    timerText.Position = UDim2.new(0, 5, 0.5, 0)
    timerText.BackgroundTransparency = 1
    timerText.TextColor3 = Color3.fromRGB(255, 255, 255)
    timerText.Font = Enum.Font.GothamBold
    timerText.TextSize = 13
    timerText.TextXAlignment = Enum.TextXAlignment.Center
    timerText.Text = "Time: 0h 0m 0s"
    timerText.Parent = textFrame
    
    -- Эффекты при наведении
    mainFrame.MouseEnter:Connect(function()
        stroke.Color = Color3.fromRGB(255, 50, 50)  -- Ярко-красный при наведении
        backgroundGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 50)),      -- Ярче
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 20, 20)),     -- Светлее
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 50, 50))       -- Ярче
        }
    end)
    
    mainFrame.MouseLeave:Connect(function()
        stroke.Color = Color3.fromRGB(139, 0, 0)  -- Темно-красный обычный
        backgroundGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 0, 0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
        }
    end)
    
    -- Таймер для обновления
    local startTime = tick()
    local frameCount = 0
    local lastUpdate = tick()
    local currentFPS = 0
    
    -- Функция для получения пинга
    local function getPing()
        local ping = 0
        
        -- Метод 1: Через Stats (стандартный метод Roblox)
        pcall(function()
            local stats = StatsService
            local networkStats = stats:FindFirstChild("Network")
            if networkStats then
                local serverStats = networkStats:FindFirstChild("ServerStatsItem")
                if serverStats then
                    ping = math.floor(serverStats:GetValue())
                end
            end
        end)
        
        -- Метод 2: Если первый не сработал, используем альтернативный
        if ping == 0 then
            pcall(function()
                local performanceStats = StatsService:FindFirstChild("PerformanceStats")
                if performanceStats then
                    local pingStat = performanceStats:FindFirstChild("Ping")
                    if pingStat then
                        ping = math.floor(pingStat:GetValue())
                    end
                end
            end)
        end
        
        -- Метод 3: Запасной вариант
        if ping == 0 then
            ping = 50
        end
        
        return ping
    end
    
    -- Обновление
    local renderConnection = RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        
        local currentTime = tick()
        
        -- Обновляем FPS и Ping каждые 0.5 секунды
        if currentTime - lastUpdate >= 0.5 then
            currentFPS = math.floor(frameCount / (currentTime - lastUpdate))
            frameCount = 0
            lastUpdate = currentTime
            
            local ping = getPing()
            statsText.Text = string.format("FPS: %d | Ping: %dms", currentFPS, ping)
        end
        
        -- Обновляем таймер
        local elapsed = currentTime - startTime
        local hours = math.floor(elapsed / 3600)
        local minutes = math.floor((elapsed % 3600) / 60)
        local seconds = math.floor(elapsed % 60)
        
        timerText.Text = string.format("Time: %dh %dm %ds", hours, minutes, seconds)
    end)
    
    -- Очистка анимации при удалении
    container.Destroying:Connect(function()
        if gradientAnimation then
            gradientAnimation:Disconnect()
            gradientAnimation = nil
        end
        if renderConnection then
            renderConnection:Disconnect()
        end
    end)
    
    -- Функция для изменения позиции
    function screenGui:SetPosition(x, y)
        container.Position = UDim2.new(0, x, 0, y)
    end
    
    -- Функция для скрытия/показа
    function screenGui:SetVisible(visible)
        screenGui.Enabled = visible
    end
    
    print("SimpleTimer: Created with gradient background and normal border!")
    return screenGui
end

-- Destroy timer
local function destroyTimer()
    if timerInstance and timerInstance.Parent then
        timerInstance:Destroy()
        timerInstance = nil
    end
    
    if gradientAnimation then
        gradientAnimation:Disconnect()
        gradientAnimation = nil
    end
end

-- Public function to enable/disable timer
function SimpleTimer.SetEnabled(state)
    isEnabled = state
    
    if state then
        -- Create timer if it doesn't exist
        if not timerInstance or not timerInstance.Parent then
            timerInstance = createTimer()
        else
            timerInstance.Enabled = true
        end
        
        return true, "Timer enabled"
    else
        -- Hide timer
        if timerInstance and timerInstance.Parent then
            timerInstance.Enabled = false
        end
        
        return true, "Timer disabled"
    end
end

-- Create timer permanently (for auto-start)
function SimpleTimer.Create()
    if not timerInstance or not timerInstance.Parent then
        timerInstance = createTimer()
    end
    isEnabled = true
    return timerInstance
end

-- Check if timer exists
function SimpleTimer.Exists()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return false end
    return playerGui:FindFirstChild("DraconicFPS") ~= nil
end

-- Get timer instance
function SimpleTimer.GetInstance()
    if not timerInstance or not timerInstance.Parent then
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            timerInstance = playerGui:FindFirstChild("DraconicFPS")
        end
    end
    return timerInstance
end

-- Clean up
function SimpleTimer.Cleanup()
    destroyTimer()
    isEnabled = false
end

-- Auto-reapply on character respawn if enabled
LocalPlayer.CharacterAdded:Connect(function()
    if isEnabled then
        task.wait(0.5)
        if not timerInstance or not timerInstance.Parent then
            timerInstance = createTimer()
        else
            timerInstance.Enabled = true
        end
    end
end)

return SimpleTimer
