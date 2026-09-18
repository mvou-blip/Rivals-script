local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()

local Window = OrionLib:MakeWindow({
    Name = "Rivals Script | Orion UI",
    HidePremium = true,
    SaveConfig = false,
    ConfigFolder = "OrionTest"
})

local MainTab = Window:MakeTab({
    Name = "Главная",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

-- Настройки
local SmoothCamEnabled = false
local AimFOV = 120
local Smoothness = 0.2
local ESPEnabled = false
local TargetFOV = 70
local FOVOverride = false

local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    Camera = workspace.CurrentCamera,
    LocalPlayer = game:GetService("Players").LocalPlayer
}

-- Круг FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 64
FOVCircle.Radius = AimFOV
FOVCircle.Filled = false
FOVCircle.Visible = false

-- Кости R15
local BonePairs = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"}
}

local ESPData = {}

local function ClearESP(player)
    if ESPData[player] then
        for _, line in pairs(ESPData[player].Lines) do line:Remove() end
        if ESPData[player].HealthOutline then ESPData[player].HealthOutline:Remove() end
        if ESPData[player].HealthBar then ESPData[player].HealthBar:Remove() end
        ESPData[player] = nil
    end
end

local function GetESP(player)
    if not ESPData[player] then
        local data = {
            Lines = {},
            HealthOutline = Drawing.new("Square"),
            HealthBar = Drawing.new("Square")
        }
        for i = 1, #BonePairs do
            local line = Drawing.new("Line")
            line.Color = Color3.fromRGB(255, 255, 255)
            line.Thickness = 1.5
            line.Visible = false
            table.insert(data.Lines, line)
        end
        data.HealthOutline.Color = Color3.fromRGB(0, 0, 0)
        data.HealthOutline.Thickness = 1
        data.HealthOutline.Filled = false
        data.HealthOutline.Visible = false
        
        data.HealthBar.Filled = true
        data.HealthBar.Visible = false
        ESPData[player] = data
    end
    return ESPData[player]
end

local function GetClosestTarget()
    local Mouse = Services.LocalPlayer:GetMouse()
    local ClosestPlayer = nil
    local ShortestDistance = AimFOV

    for _, player in pairs(Services.Players:GetPlayers()) do
        if player ~= Services.LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local Humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if Humanoid and Humanoid.Health > 0 then
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
    end
    return ClosestPlayer
end

Services.RunService.RenderStepped:Connect(function()
    local Mouse = Services.LocalPlayer:GetMouse()
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    FOVCircle.Visible = SmoothCamEnabled

    if SmoothCamEnabled then
        local Target = GetClosestTarget()
        if Target and Target.Character and Target.Character:FindFirstChild("Head") then
            local TargetCFrame = CFrame.new(Services.Camera.CFrame.Position, Target.Character.Head.Position)
            Services.Camera.CFrame = Services.Camera.CFrame:Lerp(TargetCFrame, Smoothness)
        end
    end

    if FOVOverride then
        Services.Camera.FieldOfView = TargetFOV
    end

    for _, player in pairs(Services.Players:GetPlayers()) do
        if player ~= Services.LocalPlayer then
            local esp = GetESP(player)
            local char = player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            
            if ESPEnabled and char and hum and hum.Health > 0 then
                for idx, pair in ipairs(BonePairs) do
                    local partA = char:FindFirstChild(pair[1])
                    local partB = char:FindFirstChild(pair[2])
                    local line = esp.Lines[idx]
                    
                    if partA and partB then
                        local posA, onScreenA = Services.Camera:WorldToViewportPoint(partA.Position)
                        local posB, onScreenB = Services.Camera:WorldToViewportPoint(partB.Position)
                        
                        if onScreenA and onScreenB then
                            line.From = Vector2.new(posA.X, posA.Y)
                            line.To = Vector2.new(posB.X, posB.Y)
                            line.Visible = true
                        else
                            line.Visible = false
                        end
                    else
                        line.Visible = false
                    end
                end
                
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
                        
                        esp.HealthOutline.Size = Vector2.new(4, height)
                        esp.HealthOutline.Position = Vector2.new(barX, barY)
                        esp.HealthOutline.Visible = true
                        
                        esp.HealthBar.Size = Vector2.new(2, (height - 2) * healthPercent)
                        esp.HealthBar.Position = Vector2.new(barX + 1, barY + 1 + ((height - 2) * (1 - healthPercent)))
                        esp.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                        esp.HealthBar.Visible = true
                    else
                        esp.HealthOutline.Visible = false
                        esp.HealthBar.Visible = false
                    end
                else
                    esp.HealthOutline.Visible = false
                    esp.HealthBar.Visible = false
                end
            else
                for _, line in pairs(esp.Lines) do line.Visible = false end
                esp.HealthOutline.Visible = false
                esp.HealthBar.Visible = false
            end
        end
    end
end)

Services.Players.PlayerRemoving:Connect(function(player)
    ClearESP(player)
end)

-- Элементы управления
MainTab:AddToggle({
    Name = "Плавная камера (Smooth Target)",
    Default = false,
    Callback = function(Value)
        SmoothCamEnabled = Value
    end    
})

MainTab:AddSlider({
    Name = "Плавность",
    Min = 0.05,
    Max = 1,
    Default = 0.2,
    Color = Color3.fromRGB(255,255,255),
    Increment = 0.05,
    ValueName = "mult",
    Callback = function(Value)
        Smoothness = Value
    end    
})

MainTab:AddSlider({
    Name = "Радиус FOV",
    Min = 30,
    Max = 300,
    Default = 120,
    Color = Color3.fromRGB(255,255,255),
    Increment = 5,
    ValueName = "px",
    Callback = function(Value)
        AimFOV = Value
        FOVCircle.Radius = Value
    end    
})

MainTab:AddToggle({
    Name = "Skeleton ESP + HP Bar",
    Default = false,
    Callback = function(Value)
        ESPEnabled = Value
    end    
})

MainTab:AddSlider({
    Name = "FOV Камеры",
    Min = 70,
    Max = 130,
    Default = 70,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "°",
    Callback = function(Value)
        TargetFOV = Value
        FOVOverride = true
    end    
})

OrionLib:Init()
