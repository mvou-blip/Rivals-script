local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Ждем загрузку игрока
if not LocalPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Удаляем старое меню, если оно было создано
if PlayerGui:FindFirstChild("RivalsCustomMenu") then
    PlayerGui.RivalsCustomMenu:Destroy()
end

-- Переменные настроек
local ESPEnabled = false
local FOVOverride = false
local TargetFOV = 90
local ESPHighlights = {}

-- === ОЧИСТКА ESP ===
local function ClearESP(player)
    if ESPHighlights[player] then
        if ESPHighlights[player].Highlight and ESPHighlights[player].Highlight.Parent then
            ESPHighlights[player].Highlight:Destroy()
        end
        ESPHighlights[player] = nil
    end
end

-- === СОЗДАНИЕ ИНТЕРФЕЙСА (GUI) ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RivalsCustomMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Главная рамка
local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.Size = UDim2.new(0, 240, 0, 180)
Frame.Position = UDim2.new(0.05, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = Frame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 170, 255)
UIStroke.Thickness = 2
UIStroke.Parent = Frame

-- Шапка окна
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "RIVALS MENU"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Title.BorderSizePixel = 0
Title.Parent = Frame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

-- Контейнер для кнопок
local Container = Instance.new("Frame")
Container.Name = "Container"
Container.Size = UDim2.new(1, 0, 1, -40)
Container.Position = UDim2.new(0, 0, 0, 40)
Container.BackgroundTransparency = 1
Container.Parent = Frame

local UIList = Instance.new("UIListLayout")
UIList.Parent = Container
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 10)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIList.VerticalAlignment = Enum.VerticalAlignment.Center

-- Функция создания стильных кнопок
local function CreateToggleButton(text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.85, 0, 0, 38)
    Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Btn.Text = text .. ": ВЫКЛ"
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.TextSize = 13
    Btn.Font = Enum.Font.GothamSemibold
    Btn.Parent = Container

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = Btn

    local state = false
    Btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            Btn.Text = text .. ": ВКЛ"
            Btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            Btn.Text = text .. ": ВЫКЛ"
            Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        callback(state)
    end)
end

-- Кнопки управления
CreateToggleButton("Подсветка игроков (ESP)", function(val)
    ESPEnabled = val
    if not val then
        for plr, _ in pairs(ESPHighlights) do
            ClearESP(plr)
        end
    end
end)

CreateToggleButton("Растяжка кадра (FOV 90°)", function(val)
    FOVOverride = val
    if not val then
        Camera.FieldOfView = 70
    end
end)

-- === ОСНОВНОЙ ЦИКЛ (ESP + FOV) ===
RunService.RenderStepped:Connect(function()
    if FOVOverride then
        Camera.FieldOfView = TargetFOV
    end

    if ESPEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local char = player.Character
                local hum = char:FindFirstChildOfClass("Humanoid")

                if hum and hum.Health > 0 then
                    if not ESPHighlights[player] then
                        local hl = Instance.new("Highlight")
                        hl.Name = "RivalsHighlight"
                        hl.FillColor = Color3.fromRGB(255, 40, 40)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.4
                        hl.OutlineTransparency = 0
                        hl.Parent = char

                        ESPHighlights[player] = { Highlight = hl }
                    end
                else
                    ClearESP(player)
                end
            else
                ClearESP(player)
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    ClearESP(player)
end)
