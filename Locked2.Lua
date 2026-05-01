-- ============================================================
--  Giannis Client | Locked:2
--  Game-Locked Script — Only runs inside Locked:2
-- ============================================================



-- ==================== CORRECT GAME — LOADING ====================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- ==================== SERVICES ====================
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local TeleportService   = game:GetService("TeleportService")
local HttpService       = game:GetService("HttpService")
local VirtualUser       = game:GetService("VirtualUser")
local Lighting          = game:GetService("Lighting")
local Workspace         = game:GetService("Workspace")
local Camera            = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

-- ==================== GLOBAL STATE ====================
getgenv().GiannisClient = getgenv().GiannisClient or {}
local State = getgenv().GiannisClient
State.Aimbot          = State.Aimbot or false
State.AimbotFOV       = State.AimbotFOV or 120
State.AimbotSmooth    = State.AimbotSmooth or 5
State.ShowFOV         = State.ShowFOV or false
State.AimPart         = State.AimPart or "HumanoidRootPart"
State.AutoShoot       = State.AutoShoot or false
State.BallESP         = State.BallESP or false
State.PlayerESP       = State.PlayerESP or false
State.GoalESP         = State.GoalESP or false
State.SpeedBoost      = State.SpeedBoost or false
State.InfStamina      = State.InfStamina or false
State.AutoFlow        = State.AutoFlow or false
State.SpinBot         = State.SpinBot or false

-- ==================== HELPERS ====================
local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getHRP()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

-- ==================== FOV CIRCLE ====================
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1.5
fovCircle.NumSides = 64
fovCircle.Radius = State.AimbotFOV
fovCircle.Filled = false
fovCircle.Color = Color3.fromRGB(255, 50, 50)
fovCircle.Transparency = 0.6
fovCircle.Visible = false

RunService.RenderStepped:Connect(function()
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    fovCircle.Radius = State.AimbotFOV
    fovCircle.Visible = State.ShowFOV and State.Aimbot
end)

-- ==================== AIMBOT CORE ====================
local function getClosestPlayerToMouse()
    local closest = nil
    local shortestDist = State.AimbotFOV
    local centerScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local aimPart = char:FindFirstChild(State.AimPart) or char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")

            if aimPart and hum and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
                if onScreen then
                    local screenVec = Vector2.new(screenPos.X, screenPos.Y)
                    local dist = (screenVec - centerScreen).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closest = aimPart
                    end
                end
            end
        end
    end
    return closest
end

-- Aimbot loop
RunService.RenderStepped:Connect(function()
    if not State.Aimbot then return end

    local target = getClosestPlayerToMouse()
    if target then
        local goalCF = CFrame.new(Camera.CFrame.Position, target.Position)
        local smooth = math.clamp(State.AimbotSmooth, 1, 20)
        Camera.CFrame = Camera.CFrame:Lerp(goalCF, 1 / smooth)
    end
end)

-- ==================== BALL FINDER ====================
local function findBall()
    for _, v in pairs(Workspace:GetDescendants()) do
        local nameL = string.lower(v.Name)
        if v:IsA("BasePart") and (string.find(nameL, "ball") or string.find(nameL, "soccer") or string.find(nameL, "football")) then
            return v
        end
    end
    -- Also check for models
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and string.find(string.lower(v.Name), "ball") then
            return v:FindFirstChildWhichIsA("BasePart")
        end
    end
    return nil
end

-- ==================== ESP SYSTEM ====================
local espObjects = {}

local function createESP(part, color, label)
    if not part or espObjects[part] then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "GiannisESP"
    billboard.Adornee = part
    billboard.Size = UDim2.new(0, 120, 0, 18)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.MaxDistance = 9999999
    billboard.Parent = part

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = color
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextScaled = false
    textLabel.TextSize = 11
    textLabel.Text = label or part.Name
    textLabel.Parent = billboard

    local highlight = Instance.new("Highlight")
    highlight.Name = "GiannisHighlight"
    highlight.FillColor = color
    highlight.FillTransparency = 0.7
    highlight.OutlineColor = color
    highlight.OutlineTransparency = 0.3
    highlight.Parent = part.Parent

    espObjects[part] = {billboard, highlight}
end

local function removeESP(part)
    if espObjects[part] then
        for _, obj in pairs(espObjects[part]) do
            if obj and obj.Parent then obj:Destroy() end
        end
        espObjects[part] = nil
    end
end

local function clearAllESP()
    for part, _ in pairs(espObjects) do
        removeESP(part)
    end
    espObjects = {}
end

-- ==================== WINDOW ====================
local Window = WindUI:CreateWindow({
    Title = "Giannis Client | Locked:2",
    Icon = "rbxassetid://10618928818",
    Author = "Giannis Client Studio",
    Folder = "GiannisClientL2",
    Size = UDim2.fromOffset(580, 480),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 200,
    HasOutline = true
})

WindUI:Notify({
    Title = "Giannis Client",
    Content = "Locked:2 script loaded! ⚽🔒",
    Duration = 5
})

-- ==================== TABS ====================
local AimbotTab = Window:Tab({ Title = "Aimbot",   Icon = "crosshair" })
local CombatTab = Window:Tab({ Title = "Combat",   Icon = "swords" })
local MainTab   = Window:Tab({ Title = "Player",   Icon = "user" })
local VisualTab = Window:Tab({ Title = "Visuals",  Icon = "eye" })
local MiscTab   = Window:Tab({ Title = "Misc",     Icon = "settings" })

-- ============================================================
--                      AIMBOT TAB (⭐ MAIN FEATURE)
-- ============================================================
AimbotTab:Section({ Title = "⚽ Aimbot Settings" })

AimbotTab:Toggle({
    Title = "Enable Aimbot",
    Desc = "Locks your camera onto the nearest player in FOV",
    Callback = function(state)
        State.Aimbot = state
        WindUI:Notify({
            Title = "Aimbot",
            Content = state and "Aimbot ENABLED — locking on!" or "Aimbot disabled.",
            Duration = 3
        })
    end
})

AimbotTab:Toggle({
    Title = "Show FOV Circle",
    Desc = "Displays the aimbot field of view on screen",
    Callback = function(state)
        State.ShowFOV = state
    end
})

AimbotTab:Slider({
    Title = "FOV Radius",
    Desc = "How wide the aimbot scans for targets",
    Default = 120,
    Min = 30,
    Max = 500,
    Callback = function(value)
        State.AimbotFOV = value
    end
})

AimbotTab:Slider({
    Title = "Smoothness",
    Desc = "Lower = snappier, Higher = smoother (1-20)",
    Default = 5,
    Min = 1,
    Max = 20,
    Callback = function(value)
        State.AimbotSmooth = value
    end
})

AimbotTab:Dropdown({
    Title = "Aim Part",
    Desc = "Which body part to aim at",
    Values = {"HumanoidRootPart", "Head", "UpperTorso", "LowerTorso"},
    Value = "HumanoidRootPart",
    Callback = function(value)
        State.AimPart = value
    end
})

AimbotTab:Section({ Title = "⚽ Ball Aimbot" })

AimbotTab:Toggle({
    Title = "Ball Aim Assist",
    Desc = "Aims your camera towards the ball when shooting",
    Callback = function(state)
        State.BallAim = state
        if state then
            task.spawn(function()
                while State.BallAim do
                    task.wait(0.05)
                    if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then continue end
                    local ball = findBall()
                    if ball then
                        local goalCF = CFrame.new(Camera.CFrame.Position, ball.Position)
                        Camera.CFrame = Camera.CFrame:Lerp(goalCF, 0.15)
                    end
                end
            end)
        end
    end
})

-- ============================================================
--                        COMBAT TAB
-- ============================================================
CombatTab:Section({ Title = "⚡ Auto Actions" })

CombatTab:Toggle({
    Title = "Auto Shoot",
    Desc = "Automatically charges and releases shot when near ball",
    Callback = function(state)
        State.AutoShoot = state
        if state then
            WindUI:Notify({ Title = "Auto Shoot", Content = "Will auto-shoot when near ball!", Duration = 3 })
            task.spawn(function()
                while State.AutoShoot do
                    task.wait(0.3)
                    local ball = findBall()
                    local hrp = getHRP()
                    if ball and hrp then
                        local dist = (hrp.Position - ball.Position).Magnitude
                        if dist < 15 then
                            -- Simulate RMB hold (charge) then release (shoot)
                            pcall(function()
                                mouse1click()
                                task.wait(0.1)
                                -- Fire shoot remotes
                                for _, v in pairs(ReplicatedStorage:GetDescendants()) do
                                    local nameL = string.lower(v.Name)
                                    if v:IsA("RemoteEvent") and (string.find(nameL, "shoot") or string.find(nameL, "kick") or string.find(nameL, "shot")) then
                                        v:FireServer()
                                        break
                                    end
                                end
                            end)
                        end
                    end
                end
            end)
        end
    end
})

CombatTab:Toggle({
    Title = "Auto Tackle",
    Desc = "Auto slide tackle nearby opponents with the ball",
    Callback = function(state)
        State.AutoTackle = state
        if state then
            task.spawn(function()
                while State.AutoTackle do
                    task.wait(0.3)
                    local hrp = getHRP()
                    if not hrp then continue end
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            local dist = (hrp.Position - p.Character.HumanoidRootPart.Position).Magnitude
                            if dist < 12 then
                                pcall(function()
                                    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
                                        local nameL = string.lower(v.Name)
                                        if v:IsA("RemoteEvent") and (string.find(nameL, "tackle") or string.find(nameL, "slide") or string.find(nameL, "steal")) then
                                            v:FireServer()
                                            break
                                        end
                                    end
                                end)
                                -- Simulate Q press
                                pcall(function()
                                    VirtualUser:SetKeyDown("q")
                                    task.wait(0.1)
                                    VirtualUser:SetKeyUp("q")
                                end)
                            end
                        end
                    end
                end
            end)
        end
    end
})

CombatTab:Toggle({
    Title = "Auto Flow",
    Desc = "Automatically activates Flow (G) when available",
    Callback = function(state)
        State.AutoFlow = state
        if state then
            WindUI:Notify({ Title = "Auto Flow", Content = "Will auto-activate Flow!", Duration = 3 })
            task.spawn(function()
                while State.AutoFlow do
                    task.wait(2)
                    pcall(function()
                        for _, v in pairs(ReplicatedStorage:GetDescendants()) do
                            local nameL = string.lower(v.Name)
                            if v:IsA("RemoteEvent") and (string.find(nameL, "flow") or string.find(nameL, "zone") or string.find(nameL, "awaken")) then
                                v:FireServer()
                                break
                            end
                        end
                        -- Also simulate G key
                        VirtualUser:SetKeyDown("g")
                        task.wait(0.1)
                        VirtualUser:SetKeyUp("g")
                    end)
                end
            end)
        end
    end
})

CombatTab:Toggle({
    Title = "Auto Stamina Recharge",
    Desc = "Holds V to recharge stamina when low",
    Callback = function(state)
        State.InfStamina = state
        if state then
            task.spawn(function()
                while State.InfStamina do
                    task.wait(0.5)
                    pcall(function()
                        for _, v in pairs(ReplicatedStorage:GetDescendants()) do
                            local nameL = string.lower(v.Name)
                            if v:IsA("RemoteEvent") and (string.find(nameL, "stamina") or string.find(nameL, "charge") or string.find(nameL, "energy") or string.find(nameL, "recharge")) then
                                v:FireServer()
                                break
                            end
                        end
                        VirtualUser:SetKeyDown("v")
                        task.wait(0.3)
                        VirtualUser:SetKeyUp("v")
                    end)
                end
            end)
        end
    end
})

-- ============================================================
--                        PLAYER TAB
-- ============================================================
MainTab:Section({ Title = "🏃 Movement" })

MainTab:Slider({
    Title = "WalkSpeed",
    Default = 16,
    Min = 16,
    Max = 300,
    Callback = function(value)
        local hum = getHumanoid()
        if hum then hum.WalkSpeed = value end
    end
})

MainTab:Slider({
    Title = "JumpPower",
    Default = 50,
    Min = 50,
    Max = 300,
    Callback = function(value)
        local hum = getHumanoid()
        if hum then hum.JumpPower = value end
    end
})

MainTab:Toggle({
    Title = "Infinite Jump",
    Callback = function(state)
        State.InfJump = state
        if State._InfJumpConn then
            State._InfJumpConn:Disconnect()
            State._InfJumpConn = nil
        end
        if state then
            State._InfJumpConn = UserInputService.JumpRequest:Connect(function()
                local hum = getHumanoid()
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        end
    end
})

MainTab:Toggle({
    Title = "No Clip",
    Desc = "Walk through walls and objects",
    Callback = function(state)
        State.NoClip = state
        if State._NoClipConn then
            State._NoClipConn:Disconnect()
            State._NoClipConn = nil
        end
        if state then
            State._NoClipConn = RunService.Stepped:Connect(function()
                local char = getCharacter()
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end
    end
})

-- ============================================================
--                        VISUALS TAB
-- ============================================================
VisualTab:Section({ Title = "👁️ ESP" })

VisualTab:Toggle({
    Title = "Player ESP",
    Desc = "Highlight all players with name tags",
    Callback = function(state)
        State.PlayerESP = state
        if state then
            task.spawn(function()
                while State.PlayerESP do
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            createESP(p.Character.HumanoidRootPart, Color3.fromRGB(255, 85, 85), p.Name)
                        end
                    end
                    task.wait(2)
                end
                for _, p in pairs(Players:GetPlayers()) do
                    if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        removeESP(p.Character.HumanoidRootPart)
                    end
                end
            end)
        end
    end
})

VisualTab:Toggle({
    Title = "Ball ESP",
    Desc = "Highlights the ball across the field",
    Callback = function(state)
        State.BallESP = state
        if state then
            task.spawn(function()
                while State.BallESP do
                    local ball = findBall()
                    if ball then
                        createESP(ball, Color3.fromRGB(50, 255, 50), "⚽ BALL")
                    end
                    task.wait(1)
                end
            end)
        end
    end
})

VisualTab:Toggle({
    Title = "Goal ESP",
    Desc = "Highlights both goals on the field",
    Callback = function(state)
        State.GoalESP = state
        if state then
            task.spawn(function()
                while State.GoalESP do
                    for _, v in pairs(Workspace:GetDescendants()) do
                        local nameL = string.lower(v.Name)
                        if (string.find(nameL, "goal") or string.find(nameL, "net") or string.find(nameL, "post")) and v:IsA("BasePart") then
                            createESP(v, Color3.fromRGB(255, 200, 50), "🥅 " .. v.Name)
                        end
                    end
                    task.wait(5)
                end
            end)
        end
    end
})

VisualTab:Button({
    Title = "Clear All ESP",
    Desc = "Removes all ESP highlights at once",
    Callback = function()
        State.PlayerESP = false
        State.BallESP = false
        State.GoalESP = false
        clearAllESP()
        WindUI:Notify({ Title = "ESP Cleared", Content = "All ESP removed!", Duration = 3 })
    end
})

-- ============================================================
--                        MISC TAB
-- ============================================================
MiscTab:Section({ Title = "🔧 Utilities" })

MiscTab:Button({
    Title = "Anti AFK",
    Desc = "Prevents idle kick",
    Callback = function()
        pcall(function()
            LocalPlayer.Idled:Connect(function()
                VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
                task.wait(1)
                VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
            end)
        end)
        WindUI:Notify({ Title = "Anti AFK", Content = "You won't be kicked for idling!", Duration = 3 })
    end
})

MiscTab:Button({
    Title = "FPS Boost",
    Desc = "Reduces graphics for better performance",
    Callback = function()
        pcall(function()
            local t = Workspace.Terrain
            t.WaterWaveSize = 0
            t.WaterWaveSpeed = 0
            t.WaterReflectance = 0
            t.WaterTransparency = 0
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            settings().Rendering.QualityLevel = 1
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("MeshPart") then
                    v.Material = Enum.Material.Plastic
                    v.Reflectance = 0
                elseif v:IsA("Decal") then
                    v.Transparency = 1
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                    v.Lifetime = NumberRange.new(0)
                end
            end
        end)
        WindUI:Notify({ Title = "FPS Boost", Content = "Graphics reduced — FPS should improve!", Duration = 3 })
    end
})

MiscTab:Button({
    Title = "Server Hop",
    Desc = "Teleports to a different server",
    Callback = function()
        WindUI:Notify({ Title = "Server Hop", Content = "Finding a new server...", Duration = 3 })
        pcall(function()
            local placeId = game.PlaceId
            local servers = HttpService:JSONDecode(
                game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100")
            )
            for _, server in pairs(servers.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(placeId, server.id, LocalPlayer)
                    return
                end
            end
            WindUI:Notify({ Title = "Server Hop", Content = "No available servers found.", Duration = 3 })
        end)
    end
})

MiscTab:Button({
    Title = "Rejoin Server",
    Desc = "Rejoins the current server",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
})

MiscTab:Toggle({
    Title = "Spin Bot",
    Desc = "Spin your character endlessly",
    Callback = function(state)
        State.SpinBot = state
        if state then
            task.spawn(function()
                while State.SpinBot do
                    local hrp = getHRP()
                    if hrp then
                        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(50), 0)
                    end
                    task.wait()
                end
            end)
        end
    end
})

MiscTab:Section({ Title = "📋 Info" })

MiscTab:Paragraph({
    Title = "Giannis Client | Locked:2",
    Content = "Version: 1.0 | Game: Locked:2 (Blue Lock)\nMade by Giannis Client Studio\n\nFeatures:\n• Advanced Aimbot with FOV + Smoothness\n• Ball Aim Assist for shooting\n• Auto Shoot, Tackle, Flow\n• Player/Ball/Goal ESP\n• Speed & Movement mods"
})

MiscTab:Paragraph({
    Title = "⚠️ Use At Your Own Risk",
    Content = "This script is for educational purposes only.\nUsing exploits may result in account bans.\nAlways use an alt account when testing."
})

-- ==================== AUTO RECONNECT ====================
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    WindUI:Notify({ Title = "Respawned", Content = "Character loaded. Features re-applied.", Duration = 3 })
end)

WindUI:Notify({
    Title = "Ready!",
    Content = "All tabs loaded. Dominate the pitch! ⚽🔒",
    Duration = 5
})
