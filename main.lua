local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Rivals Script | Force Lock Aim",
   Name = "Rivals Script | Skeleton & HP ESP",
   LoadingTitle = "Загрузка скрипта...",
   LoadingSubtitle = "by Assistant",
   ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("Главная", 4483362458)

-- Настройки
-- Переменные настроек
local AimbotEnabled = false
local AimFOV = 120
local ESPEnabled = false
local TargetFOV = 70
local FOVOverride = false
local IsTargeting = false

local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    Camera = workspace.CurrentCamera,
    LocalPlayer = game:GetService("Players").LocalPlayer,
    UserInputService = game:GetService("UserInputService")
    LocalPlayer = game:GetService("Players").LocalPlayer
}

-- Круг FOV Аимбота
@@ -52,11 +50,14 @@ local BonePairs = {
    {"RightLowerLeg", "RightFoot"}
}

-- Хранилище объектов рисования ESP для каждого игрока
local ESPData = {}

local function ClearESP(player)
    if ESPData[player] then
        for _, line in pairs(ESPData[player].Lines) do line:Remove() end
        for _, line in pairs(ESPData[player].Lines) do
            line:Remove()
        end
        if ESPData[player].HealthOutline then ESPData[player].HealthOutline:Remove() end
        if ESPData[player].HealthBar then ESPData[player].HealthBar:Remove() end
        ESPData[player] = nil
@@ -70,39 +71,32 @@ local function GetESP(player)
            HealthOutline = Drawing.new("Square"),
            HealthBar = Drawing.new("Square")
        }
        
        -- Инициализация линий скелета
        for i = 1, #BonePairs do
            local line = Drawing.new("Line")
            line.Color = Color3.fromRGB(255, 255, 255)
            line.Thickness = 1.5
            line.Visible = false
            table.insert(data.Lines, line)
        end
        
        -- Полоса здоровья (контур)
        data.HealthOutline.Color = Color3.fromRGB(0, 0, 0)
        data.HealthOutline.Thickness = 1
        data.HealthOutline.Filled = false
        data.HealthOutline.Visible = false

        -- Полоса здоровья (заполнение)
        data.HealthBar.Filled = true
        data.HealthBar.Visible = false
        
        ESPData[player] = data
    end
    return ESPData[player]
end

-- Отслеживание удерживания ПКМ
Services.UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        IsTargeting = true
    end
end)

Services.UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        IsTargeting = false
    end
end)

-- Поиск цели
-- Поиск цели для Аимбота
local function GetClosestTarget()
    local Mouse = Services.LocalPlayer:GetMouse()
    local ClosestPlayer = nil
@@ -130,37 +124,36 @@ local function GetClosestTarget()
    return ClosestPlayer
end

-- Принудительная наводка камеры
local function ForceAim()
    if AimbotEnabled and IsTargeting then
-- Главный Рендер-Цикл
Services.RunService.RenderStepped:Connect(function()
    local Mouse = Services.LocalPlayer:GetMouse()
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    
    -- 1. Аимбот (удержание головы)
    if AimbotEnabled then
        FOVCircle.Visible = true
        local Target = GetClosestTarget()
        if Target and Target.Character and Target.Character:FindFirstChild("Head") then
            local HeadPos = Target.Character.Head.Position
            Services.Camera.CFrame = CFrame.new(Services.Camera.CFrame.Position, HeadPos)
            Services.Camera.CFrame = CFrame.new(Services.Camera.CFrame.Position, Target.Character.Head.Position)
        end
    else
        FOVCircle.Visible = false
    end
end

-- Двойной перехват камеры в течение кадра
Services.RunService.RenderStepped:Connect(function()
    ForceAim()
    
    local Mouse = Services.LocalPlayer:GetMouse()
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    FOVCircle.Visible = AimbotEnabled

    -- 2. Растяжка FOV
    if FOVOverride then
        Services.Camera.FieldOfView = TargetFOV
    end

    -- Отрисовка ESP
    -- 3. Отрисовка Скелета и Полоски ХП
    for _, player in pairs(Services.Players:GetPlayers()) do
        if player ~= Services.LocalPlayer then
            local esp = GetESP(player)
            local char = player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")

            if ESPEnabled and char and hum and hum.Health > 0 then
                -- Отрисовка Скелета
                for idx, pair in ipairs(BonePairs) do
                    local partA = char:FindFirstChild(pair[1])
                    local partB = char:FindFirstChild(pair[2])
@@ -182,22 +175,28 @@ Services.RunService.RenderStepped:Connect(function()
                    end
                end

                -- Отрисовка HP Bar
                local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
                if root then
                    local rootPos, onScreen = Services.Camera:WorldToViewportPoint(root.Position)
                    if onScreen then
                        local head = char:FindFirstChild("Head")
                        local headPos = head and Services.Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0)) or rootPos
                        
                        local height = math.abs(rootPos.Y - headPos.Y) * 2.5
                        local width = height / 2
                        
                        local barX = rootPos.X - (width / 2) - 6
                        local barY = rootPos.Y - (height / 2)
                        
                        local healthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)

                        -- Контур полоски ХП
                        esp.HealthOutline.Size = Vector2.new(4, height)
                        esp.HealthOutline.Position = Vector2.new(barX, barY)
                        esp.HealthOutline.Visible = true

                        -- Заполнение полоски ХП
                        esp.HealthBar.Size = Vector2.new(2, (height - 2) * healthPercent)
                        esp.HealthBar.Position = Vector2.new(barX + 1, barY + 1 + ((height - 2) * (1 - healthPercent)))
                        esp.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
@@ -211,6 +210,7 @@ Services.RunService.RenderStepped:Connect(function()
                    esp.HealthBar.Visible = false
                end
            else
                -- Скрываем если выключено или игрок мёртв
                for _, line in pairs(esp.Lines) do line.Visible = false end
                esp.HealthOutline.Visible = false
                esp.HealthBar.Visible = false
@@ -219,17 +219,14 @@ Services.RunService.RenderStepped:Connect(function()
    end
end)

Services.RunService.Stepped:Connect(function()
    ForceAim()
end)

-- Очистка графика при выходе игроков
Services.Players.PlayerRemoving:Connect(function(player)
    ClearESP(player)
end)

-- UI
-- Элементы в Меню
MainTab:CreateToggle({
   Name = "Аимбот (Зажми ПКМ для залипания)",
   Name = "Аимбот (Фиксация в Голову)",
   CurrentValue = false,
   Callback = function(Value)
       AimbotEnabled = Value
