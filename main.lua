local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Настройки
local ESPEnabled = false
local FOVOverride = false
local TargetFOV = 90

-- Хранилище объектов подсветки
local ESPHighlights = {}

local function ClearESP(player)
    if ESPHighlights[player] then
        if ESPHighlights[player].Highlight then ESPHighlights[player].Highlight:Destroy() end
        if ESPHighlights[player].Billboard then ESPHighlights[player].Billboard:Destroy() end
        ESPHighlights[player] = nil
    end
end

-- === ИНТЕРФЕЙС (ScreenGui) ===
if CoreGui:FindFirstChild("SimpleRivalsMenu") then
    CoreGui.SimpleRivalsMenu:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimpleRivalsMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 150)
Frame.Position = UDim2.new(0.02, 0, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "Rivals Menu"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 15
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Parent = Frame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

local UIList = Instance.new("UIListLayout")
UIList.Parent = Frame
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 8)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

Title.LayoutOrder = 0

local function CreateBtn(text, order, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 13
    btn.Font = Enum.Font.SourceSans
    btn.LayoutOrder = order
    btn.Parent = Frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        if active then
            btn.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        callback(active)
    end)
    return btn
end

CreateBtn("Включить ESP (Подсветка)", 1, function(val)
    ESPEnabled = val
    if not val then
        for plr, _ in pairs(ESPHighlights) do
            ClearESP(plr)
        end
    end
end)

CreateBtn("Растяжка FOV (90°)", 2, function(val)
    FOVOverride = val
    if not val then
        Camera.FieldOfView = 70
    end
end)

-- === ОБРАБОТКА ЛОГИКИ ===
RunService.RenderStepped:Connect(function()
    if FOVOverride then
        Camera.FieldOfView = TargetFOV
    end

    if ESPEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local char = player.Character
                local hum = char:FindFirstChildOfClass("Humanoid")
                
                if hum and hum.Health > 0 then
                    if not ESPHighlights[player] then
                        local hl = Instance.new("Highlight")
                        hl.Name = "ESPHighlight"
                        hl.FillColor = Color3.fromRGB(255, 50, 50)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.5
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
