local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Rivals Script | Xeno",
   LoadingTitle = "Загрузка скрипта...",
   LoadingSubtitle = "by Assistant",
   ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("Главная", 4483362458)

-- Переменные функций
local AimbotEnabled = false
local AimFOV = 120
local ESPEnabled = false

local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    Camera = workspace.CurrentCamera,
    LocalPlayer = game:GetService("Players").LocalPlayer
}

-- Инициализация круга FOV для Аимбота
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 64
FOVCircle.Radius = AimFOV
FOVCircle.Filled = false
FOVCircle.Visible = false

-- Функция поиска ближайшей цели (в голову)
local function GetClosestTarget()
    local Mouse = Services.LocalPlayer:GetMouse()
    local ClosestPlayer = nil
    local ShortestDistance = AimFOV

    for _, player in pairs(Services.Players:GetPlayers()) do
        if player ~= Services.LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local Head = player.Character.Head
            local ScreenPos, OnScreen = Services.Camera:WorldToViewportPoint(Head.Position)
            
            if OnScreen then
                local MousePos = Vector2.new(Mouse.X, Mouse.Y)
                local Distance = (Vector2.new(ScreenPos.X, ScreenPos.Y) - MousePos).Magnitude
                
                if Distance < ShortestDistance then
                    ShortestDistance = Distance
                    ClosestPlayer = player
                end
            end
        end
    end
    return ClosestPlayer
end

-- Цикл Аимбота и обводки FOV
Services.RunService.RenderStepped:Connect(function()
    local Mouse = Services.LocalPlayer:GetMouse()
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    
    if AimbotEnabled then
        FOVCircle.Visible = true
        local Target = GetClosestTarget()
        if Target and Target.Character and Target.Character:FindFirstChild("Head") then
            Services.Camera.CFrame = CFrame.new(Services.Camera.CFrame.Position, Target.Character.Head.Position)
        end
    else
        FOVCircle.Visible = false
    end
end)

-- Создание элементов в Меню: Aimbot
MainTab:CreateToggle({
   Name = "Аимбот (в Голову)",
   CurrentValue = false,
   Callback = function(Value)
       AimbotEnabled = Value
   end,
})

MainTab:CreateSlider({
   Name = "Радиус FOV Аима",
   Range = {30, 300},
   Increment = 5,
   Suffix = "px",
   CurrentValue = 120,
   Callback = function(Value)
       AimFOV = Value
       FOVCircle.Radius = Value
   end,
})

-- Создание элементов в Меню: ESP
MainTab:CreateToggle({
   Name = "Full ESP (Тело, HP, Линии)",
   CurrentValue = false,
   Callback = function(Value)
       ESPEnabled = Value
       
       for _, v in pairs(Services.Players:GetPlayers()) do
           if v ~= Services.LocalPlayer and v.Character then
               local Highlight = v.Character:FindFirstChild("ESPHighlight")
               if Value then
                   if not Highlight then
                       Highlight = Instance.new("Highlight")
                       Highlight.Name = "ESPHighlight"
                       Highlight.FillColor = Color3.fromRGB(255, 0, 50)
                       Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                       Highlight.FillTransparency = 0.5
                       Highlight.Parent = v.Character
                   end
               else
                   if Highlight then Highlight:Destroy() end
               end
           end
       end
   end,
})

-- Создание элементов в Меню: FOV (Растяжка экрана)
MainTab:CreateSlider({
   Name = "FOV Камеры (Растяжка)",
   Range = {70, 130},
   Increment = 1,
   Suffix = "°",
   CurrentValue = 70,
   Callback = function(Value)
       Services.Camera.FieldOfView = Value
   end,
})
