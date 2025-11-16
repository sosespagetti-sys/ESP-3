local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local OLD_GUI_NAME = "InfiniteYieldESP"
local oldGui = player.PlayerGui:FindFirstChild(OLD_GUI_NAME) or CoreGui:FindFirstChild(OLD_GUI_NAME)
if oldGui then oldGui:Destroy() print("[TEST] Alte Infinite Yield ESP gelöscht") end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = OLD_GUI_NAME
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999999
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 140)
frame.Position = UDim2.new(0.5, -140, 0.5, -70)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = frame

local shadow = Instance.new("Frame")
shadow.Size = UDim2.new(1, 10, 1, 10)
shadow.Position = UDim2.new(0, -5, 0, -5)
shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadow.BackgroundTransparency = 0.7
shadow.ZIndex = frame.ZIndex - 1
shadow.Parent = frame
local shadowCorner = Instance.new("UICorner")
shadowCorner.CornerRadius = UDim.new(0, 15)
shadowCorner.Parent = shadow

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.Text = "TeamESP"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.Parent = frame

local button = Instance.new("TextButton")
button.Size = UDim2.new(0.9, 0, 0, 40)
button.Position = UDim2.new(0.05, 0, 0.35, 0)
button.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
button.Text = "ON"
button.TextColor3 = Color3.new(1,1,1)
button.Font = Enum.Font.GothamBold
button.TextScaled = true
button.Parent = frame
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 10)
btnCorner.Parent = button

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 25)
status.Position = UDim2.new(0, 0, 0.8, 0)
status.BackgroundTransparency = 1
status.Text = "Status: OFF"
status.TextColor3 = Color3.fromRGB(200, 200, 200)
status.Font = Enum.Font.Gotham
status.TextScaled = true
status.Parent = frame

local espObjects = {}
local isEnabled = false
local ESP_SETTINGS = {
    TeamColor = Color3.fromRGB(0, 255, 0),
    EnemyColor = Color3.fromRGB(255, 0, 0),
    BoxTransparency = 0.7,
    TracerThickness = 2,
    TextSize = 14,
    MaxDistance = 3000
}

local function clearESP()
    for _, objects in pairs(espObjects) do
        for _, obj in pairs(objects) do
            if obj then obj:Destroy() end
        end
    end
    espObjects = {}
end

local function createESP(targetPlayer)
    if targetPlayer == player or not targetPlayer.Character then return end
    
    local character = targetPlayer.Character
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    
    if not humanoid or not rootPart or not head then return end
    
    local espFolder = Instance.new("Folder")
    espFolder.Name = targetPlayer.Name
    espFolder.Parent = screenGui

    local box = Instance.new("BoxHandleAdornment")
    box.Name = "3DBox"
    box.Size = Vector3.new(2, 5, 1)
    box.Color3 = ESP_SETTINGS.TeamColor
    box.Transparency = ESP_SETTINGS.BoxTransparency
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Adornee = rootPart
    box.Parent = espFolder
    
    -- 2D BOX (Screen Space)
    local box2D = Instance.new("Frame")
    box2D.Name = "2DBox"
    box2D.Size = UDim2.new(0, 0, 0, 0)
    box2D.Position = UDim2.new(0, 0, 0, 0)
    box2D.BackgroundTransparency = 1
    box2D.BorderSizePixel = 2
    box2D.BorderColor3 = ESP_SETTINGS.TeamColor
    box2D.Visible = false
    box2D.Parent = espFolder
    
    local nameTag = Instance.new("TextLabel")
    nameTag.Name = "Name"
    nameTag.Size = UDim2.new(0, 200, 0, 20)
    nameTag.BackgroundTransparency = 1
    nameTag.Text = targetPlayer.Name
    nameTag.TextColor3 = Color3.new(1,1,1)
    nameTag.Font = Enum.Font.GothamBold
    nameTag.TextSize = ESP_SETTINGS.TextSize
    nameTag.TextStrokeTransparency = 0
    nameTag.TextStrokeColor3 = Color3.new(0,0,0)
    nameTag.Visible = false
    nameTag.Parent = espFolder
    
    local healthBar = Instance.new("Frame")
    healthBar.Name = "HealthBar"
    healthBar.Size = UDim2.new(0, 4, 0, 40)
    healthBar.Position = UDim2.new(0, 0, 0, 0)
    healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthBar.BorderSizePixel = 0
    healthBar.Visible = false
    healthBar.Parent = espFolder
    
    local healthBarBG = Instance.new("Frame")
    healthBarBG.Size = UDim2.new(1, 0, 1, 0)
    healthBarBG.BackgroundColor3 = Color3.new(0,0,0)
    healthBarBG.BackgroundTransparency = 0.5
    healthBarBG.Parent = healthBar
    
    local tracer = Drawing.new("Line")
    tracer.Thickness = ESP_SETTINGS.TracerThickness
    tracer.Color = ESP_SETTINGS.TeamColor
    tracer.Transparency = 1
    tracer.Visible = false
    
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Name = "Distance"
    distanceLabel.Size = UDim2.new(0, 100, 0, 18)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = "0m"
    distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.TextSize = ESP_SETTINGS.TextSize - 2
    distanceLabel.TextStrokeTransparency = 0
    distanceLabel.TextStrokeColor3 = Color3.new(0,0,0)
    distanceLabel.Visible = false
    distanceLabel.Parent = espFolder
    
    espObjects[targetPlayer] = {box, box2D, nameTag, healthBar, distanceLabel, tracer}
end

local function worldToScreen(pos)
    local screenPos, onScreen = camera:WorldToViewportPoint(pos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen
end

local updateConnection
local function updateESP()
    for targetPlayer, objects in pairs(espObjects) do
        if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local character = targetPlayer.Character
            local humanoid = character.Humanoid
            local rootPart = character.HumanoidRootPart
            local head = character:FindFirstChild("Head")
            
            local distance = (rootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if distance > ESP_SETTINGS.MaxDistance then
                for i = 2, 6 do objects[i].Visible = false end
                objects[6].Visible = false
                continue
            end

            local isTeamMate = targetPlayer.Team == player.Team
            local color = isTeamMate and ESP_SETTINGS.TeamColor or ESP_SETTINGS.EnemyColor
            objects[1].Color3 = color  -- 3D Box
            objects[2].BorderColor3 = color  -- 2D Box

            local rootScreen, onScreen = worldToScreen(rootPart.Position)
            local headScreen = worldToScreen(head.Position + Vector3.new(0, 0.5, 0))
            local legScreen = worldToScreen(rootPart.Position - Vector3.new(0, 3, 0))
            
            if onScreen then
                local height = math.abs(headScreen.Y - legScreen.Y)
                local width = height * 0.6

                objects[2].Size = UDim2.new(0, width, 0, height)
                objects[2].Position = UDim2.new(0, rootScreen.X - width/2, 0, rootScreen.Y - height/2)
                objects[2].Visible = true

                objects[3].Position = UDim2.new(0, rootScreen.X - 100, 0, headScreen.Y - 25)
                objects[3].TextColor3 = color
                objects[3].Visible = true

                local healthPercent = humanoid.Health / humanoid.MaxHealth
                objects[4].Size = UDim2.new(0, 4, 0, height * healthPercent)
                objects[4].Position = UDim2.new(0, rootScreen.X - width/2 - 8, 0, rootScreen.Y + height/2 - (height * healthPercent))
                objects[4].BackgroundColor3 = Color3.new(1 - healthPercent, healthPercent, 0)
                objects[4].Visible = true

                objects[5].Position = UDim2.new(0, rootScreen.X - 50, 0, rootScreen.Y + height/2 + 5)
                objects[5].Text = math.floor(distance) .. "m"
                objects[5].Visible = true

                local screenCenter = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
                objects[6].From = screenCenter
                objects[6].To = Vector2.new(rootScreen.X, legScreen.Y)
                objects[6].Color = color
                objects[6].Visible = true
            else
                for i = 2, 6 do objects[i].Visible = false end
            end
        else
            for i = 2, 6 do objects[i].Visible = false end
        end
    end
end

button.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    if isEnabled then
        button.Text = "OFF"
        button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        status.Text = "Status: ON (Infinite Yield ESP)"        
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player then createESP(plr) end
        end       
        updateConnection = RunService.Heartbeat:Connect(updateESP)
    else
        button.Text = "ON"
        button.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
        status.Text = "Status: OFF"
        clearESP()
        if updateConnection then updateConnection:Disconnect() end
    end
end)

Players.PlayerAdded:Connect(function(newPlayer)
    if isEnabled and newPlayer ~= player then
        task.wait(2)
        createESP(newPlayer)
    end
end)

Players.PlayerRemoving:Connect(function(leavingPlayer)
    if espObjects[leavingPlayer] then
        for _, obj in pairs(espObjects[leavingPlayer]) do
            if obj then obj:Destroy() end
        end
        espObjects[leavingPlayer] = nil
    end
end)

spawn(function()
    while screenGui.Parent do
        screenGui.DisplayOrder = 999999
        task.wait(0.1)
    end
end)

print("[TEST] ESP Loaded!")
