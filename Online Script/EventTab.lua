-- ==================== EXTERNAL EVENT TAB MODULE ====================
-- Название файла: EventTab.lua
-- Путь: https://raw.githubusercontent.com/Lapwpkddm/Hacks/refs/heads/main/Online%20Script/EventTab.lua

return function(Window, Fluent, Options, RunService, Players, LocalPlayer)
    
    -- Проверяем, существует ли уже вкладка Event
    local existingTab = nil
    for i, tab in ipairs(Window.Tabs or {}) do
        if tab.Title == "Event" then
            existingTab = tab
            break
        end
    end
    
    -- Если вкладка уже существует, используем её
    local EventTab = existingTab or Window:AddTab({ 
        Title = "Event", 
        Icon = "calendar" 
    })
    
    -- Убеждаемся, что вкладка видима
    if EventTab and EventTab.TabButton then
        EventTab.TabButton.Visible = true
    end
    
    -- ==================== BATTLEPASS MODIFICATIONS ====================
    
    EventTab:AddSection("Battlepass Modifications")
    
    -- Переменные для хранения состояний
    local featureStates = featureStates or {}
    
    -- Первый тумблер: Unlocked Pass
    local UnlockedPassToggle = EventTab:AddToggle("UnlockedPassToggle", {
        Title = "Unlocked Time Pass",
        Default = false,
        Callback = function(state)
            if state then
                -- Включаем скрытие
                if not featureStates.UnlockedPassLoop then
                    featureStates.UnlockedPassLoop = RunService.Heartbeat:Connect(function()
                        pcall(function()
                            local menu = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Menu")
                            if menu and menu.Views and menu.Views.Battlepass and menu.Views.Battlepass.ViewPass then
                                local center = menu.Views.Battlepass.ViewPass:FindFirstChild("Center")
                                if center and center.ViewPass and center.ViewPass.Unlocked then
                                    center.ViewPass.Unlocked.Visible = false
                                end
                            end
                        end)
                    end)
                end
            else
                -- Отключаем скрытие
                if featureStates.UnlockedPassLoop then
                    featureStates.UnlockedPassLoop:Disconnect()
                    featureStates.UnlockedPassLoop = nil
                    
                    -- Восстанавливаем видимость
                    pcall(function()
                        local menu = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Menu")
                        if menu and menu.Views and menu.Views.Battlepass and menu.Views.Battlepass.ViewPass then
                            local center = menu.Views.Battlepass.ViewPass:FindFirstChild("Center")
                            if center and center.ViewPass and center.ViewPass.Unlocked then
                                center.ViewPass.Unlocked.Visible = true
                            end
                        end
                    end)
                end
            end
        end
    })
    
    -- Второй тумблер: Exchange Open
    local ExchangeOpenToggle = EventTab:AddToggle("ExchangeOpenToggle", {
        Title = "Open Exchange",
        Default = false,
        Callback = function(state)
            if state then
                -- Включаем открытие Exchange
                if not featureStates.ExchangeOpenLoop then
                    featureStates.ExchangeOpenLoop = RunService.Heartbeat:Connect(function()
                        pcall(function()
                            local menu = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Menu")
                            if menu and menu.Views and menu.Views.Battlepass then
                                -- Показываем Exchange
                                if menu.Views.Battlepass:FindFirstChild("Exchange") then
                                    menu.Views.Battlepass.Exchange.Visible = true
                                end
                                
                                -- Скрываем ViewPass
                                if menu.Views.Battlepass:FindFirstChild("ViewPass") then
                                    menu.Views.Battlepass.ViewPass.Visible = false
                                end
                            end
                        end)
                    end)
                end
            else
                -- Отключаем
                if featureStates.ExchangeOpenLoop then
                    featureStates.ExchangeOpenLoop:Disconnect()
                    featureStates.ExchangeOpenLoop = nil
                    
                    -- Восстанавливаем стандартный вид
                    pcall(function()
                        local menu = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Menu")
                        if menu and menu.Views and menu.Views.Battlepass then
                            -- Восстанавливаем Exchange
                            if menu.Views.Battlepass:FindFirstChild("Exchange") then
                                menu.Views.Battlepass.Exchange.Visible = false
                            end
                            
                            -- Восстанавливаем ViewPass
                            if menu.Views.Battlepass:FindFirstChild("ViewPass") then
                                menu.Views.Battlepass.ViewPass.Visible = true
                            end
                        end
                    end)
                end
            end
        end
    })
    
    -- ==================== INFO SECTION ====================
    
    EventTab:AddSection("Info Unlocked Time Pass")
    
    EventTab:AddParagraph({
        Title = "Pass 1-9",
        Content = "Buy Items 5"
    })
    
    EventTab:AddParagraph({
        Title = "Pass 10-18", 
        Content = "Buy Items 5"
    })
    
    EventTab:AddParagraph({
        Title = "Pass 19-25",
        Content = "Buy Items 5"
    })
    
    -- ==================== CLEANUP FUNCTIONS ====================
    
    -- Функция для остановки всех лупов
    local function stopAllLoops()
        if featureStates.UnlockedPassLoop then
            featureStates.UnlockedPassLoop:Disconnect()
            featureStates.UnlockedPassLoop = nil
        end
        if featureStates.ExchangeOpenLoop then
            featureStates.ExchangeOpenLoop:Disconnect()
            featureStates.ExchangeOpenLoop = nil
        end
    end
    
    -- Функция для восстановления видимости
    local function restoreVisibility()
        pcall(function()
            local menu = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Menu")
            if menu and menu.Views and menu.Views.Battlepass then
                -- Восстанавливаем Unlocked если был изменен
                if menu.Views.Battlepass.ViewPass and menu.Views.Battlepass.ViewPass.Center and 
                   menu.Views.Battlepass.ViewPass.Center.ViewPass and menu.Views.Battlepass.ViewPass.Center.ViewPass.Unlocked then
                    menu.Views.Battlepass.ViewPass.Center.ViewPass.Unlocked.Visible = true
                end
                
                -- Восстанавливаем видимость ViewPass
                if menu.Views.Battlepass:FindFirstChild("ViewPass") then
                    menu.Views.Battlepass.ViewPass.Visible = true
                end
                
                -- Скрываем Exchange
                if menu.Views.Battlepass:FindFirstChild("Exchange") then
                    menu.Views.Battlepass.Exchange.Visible = false
                end
            end
        end)
    end
    
    -- Обработка респавна персонажа
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(2)
        
        -- Восстанавливаем состояние после респавна
        if Options.UnlockedPassToggle and Options.UnlockedPassToggle.Value then
            if not featureStates.UnlockedPassLoop then
                featureStates.UnlockedPassLoop = RunService.Heartbeat:Connect(function()
                    pcall(function()
                        local menu = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Menu")
                        if menu and menu.Views and menu.Views.Battlepass and menu.Views.Battlepass.ViewPass then
                            local center = menu.Views.Battlepass.ViewPass:FindFirstChild("Center")
                            if center and center.ViewPass and center.ViewPass.Unlocked then
                                center.ViewPass.Unlocked.Visible = false
                            end
                        end
                    end)
                end)
            end
        end
        
        if Options.ExchangeOpenToggle and Options.ExchangeOpenToggle.Value then
            if not featureStates.ExchangeOpenLoop then
                featureStates.ExchangeOpenLoop = RunService.Heartbeat:Connect(function()
                    pcall(function()
                        local menu = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Menu")
                        if menu and menu.Views and menu.Views.Battlepass then
                            if menu.Views.Battlepass:FindFirstChild("Exchange") then
                                menu.Views.Battlepass.Exchange.Visible = true
                            end
                            if menu.Views.Battlepass:FindFirstChild("ViewPass") then
                                menu.Views.Battlepass.ViewPass.Visible = false
                            end
                        end
                    end)
                end)
            end
        end
    end)
    
    -- Очистка при выходе из игры
    game:GetService("Players").PlayerRemoving:Connect(function(player)
        if player == LocalPlayer then
            stopAllLoops()
        end
    end)
    
    -- Возвращаем созданные элементы для возможного использования
    return {
        Tab = EventTab,
        UnlockedPassToggle = UnlockedPassToggle,
        ExchangeOpenToggle = ExchangeOpenToggle,
        StopAllLoops = stopAllLoops,
        RestoreVisibility = restoreVisibility
    }
end
