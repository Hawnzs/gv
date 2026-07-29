-- FPS Capper & Dynamic Chat-Target Automation Script with "Greenville Services" Minimal Loader
-- Added: "attack [username]" command for violent spazzing behavior.

local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local TARGET_FPS = 120

-- Forceful 120 FPS Capper Runner
task.spawn(function()
    while true do
        local t0 = tick()
        RunService.RenderStepped:Wait()
        repeat until (t0 + 1 / TARGET_FPS) < tick()
    end
end)

-- Bulletproof queue_on_teleport function resolver
local queueteleport = queue_on_teleport 
    or (syn and syn.queue_on_teleport) 
    or (fluxus and fluxus.queue_on_teleport) 
    or queueonteleport 
    or (identifyexecutor and select(1, identifyexecutor()) == "Delta" and nil)

if type(_G.KeepInfYield) ~= "boolean" then
    _G.KeepInfYield = true
end

if type(_G.TeleportState) ~= "table" then
    _G.TeleportState = {
        TeleportCheck = false,
        TeleportRetries = 0,
        MaxRetries = 5,
        ServerHopTimer = false,
        ScriptFinished = false,
        IsRunning = false
    }
end

local SCRIPT_URL = "https://raw.githubusercontent.com/Hawnzs/gv/main/script.lua"

local function safeQueueTeleport()
    if queueteleport then
        pcall(function()
            queueteleport(string.format([[
                task.wait(1)
                pcall(function()
                    loadstring(game:HttpGet("%s", true))()
                end)
            ]], SCRIPT_URL))
        end)
    end
end

game.Players.LocalPlayer.OnTeleport:Connect(function(State)
    if State == Enum.TeleportState.InProgress then
        if _G.KeepInfYield and not _G.TeleportState.TeleportCheck then
            _G.TeleportState.TeleportCheck = true
            safeQueueTeleport()
        end
    elseif State == Enum.TeleportState.Failed then
        _G.TeleportState.TeleportCheck = false
        _G.TeleportState.IsRunning = false
    end
end)

local v_QpZ = game:GetService("Players")
local v_Lmk = game:GetService("RunService")
local v_Wne = game:GetService("ReplicatedStorage")
local v_Rtd = game:GetService("TextChatService")
local v_Tps = game:GetService("TeleportService")
local v_Hts = game:GetService("HttpService")
local v_Gui = game:GetService("GuiService")
local v_Sgi = game:GetService("StarterGui")
local plr = v_QpZ.LocalPlayer or v_QpZ.PlayerAdded:Wait()

-- GREENVILLE SERVICES — MINIMAL LOADER UI
task.spawn(function()
    pcall(function()
        local playerGui = plr:WaitForChild("PlayerGui", 10)
        if not playerGui then return end

        local TITLE  = "Greenville Services"
        local FONT   = "rbxasset://fonts/families/JosefinSans.json"
        local ACCENT = Color3.fromRGB(0, 255, 170)
        local TIME   = 2.6
        local WIDGET = true

        local FONT_B = Font.new(FONT, Enum.FontWeight.Bold, Enum.FontStyle.Normal)

        local function new(c, p, parent)
            local i = Instance.new(c)
            for k, v in pairs(p) do i[k] = v end
            if parent then i.Parent = parent end
            return i
        end
        local function tw(o, t, s, d, g, dl)
            local x = TweenService:Create(o, TweenInfo.new(t, s, d, 0, false, dl or 0), g)
            x:Play(); return x
        end
        local Q, OUT, IN = Enum.EasingStyle.Quint, Enum.EasingDirection.Out, Enum.EasingDirection.In

        local gui = new("ScreenGui", {
            Name = "GVSLoader",
            IgnoreGuiInset = true,
            ResetOnSpawn = false,
            DisplayOrder = 999999,
        }, playerGui)

        local dim = new("Frame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
        }, gui)

        local label = new("TextLabel", {
            Size = UDim2.fromOffset(400, 26),
            Position = UDim2.new(0.5, 0, 0.5, -10),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Text = TITLE,
            FontFace = FONT_B,
            TextSize = 20,
            TextColor3 = Color3.fromRGB(245, 248, 246),
            TextTransparency = 1,
        }, gui)

        local track = new("Frame", {
            Size = UDim2.fromOffset(140, 1),
            Position = UDim2.new(0.5, 0, 0.5, 16),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
        }, gui)

        local fill = new("Frame", {
            Size = UDim2.fromScale(0, 1),
            BackgroundColor3 = ACCENT,
            BorderSizePixel = 0,
        }, track)

        tw(dim,   0.4, Q, OUT, { BackgroundTransparency = 0.55 })
        tw(label, 0.5, Q, OUT, { TextTransparency = 0 }, 0.1)
        tw(track, 0.5, Q, OUT, { BackgroundTransparency = 0.88 }, 0.15)
        tw(fill, TIME, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, { Size = UDim2.fromScale(1, 1) }, 0.4)

        task.wait(TIME + 0.7)

        tw(dim,   0.35, Q, IN, { BackgroundTransparency = 1 })
        tw(label, 0.3,  Q, IN, { TextTransparency = 1 })
        tw(track, 0.3,  Q, IN, { BackgroundTransparency = 1 })
        tw(fill,  0.3,  Q, IN, { BackgroundTransparency = 1 })

        task.delay(0.45, function()
            dim:Destroy(); label:Destroy(); track:Destroy()
        end)

        if not WIDGET then return end
        task.wait(0.35)

        local pill = new("Frame", {
            Name = "WidgetContainer",
            Size = UDim2.fromOffset(210, 45),
            Position = UDim2.new(1, -20, 0, 8),
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = Color3.fromRGB(12, 16, 14),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
        }, gui)
        new("UICorner", { CornerRadius = UDim.new(0.5, 0) }, pill)
        local pillStroke = new("UIStroke", { Color = ACCENT, Thickness = 1.5, Transparency = 1 }, pill)

        local dot = new("Frame", {
            Name = "StatusDot",
            Size = UDim2.fromOffset(10, 10),
            Position = UDim2.new(0, 16, 0.5, -5),
            BackgroundColor3 = ACCENT,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
        }, pill)
        new("UICorner", { CornerRadius = UDim.new(1, 0) }, dot)

        local text = new("TextLabel", {
            Name = "WidgetText",
            Size = UDim2.new(1, -46, 1, 0),
            Position = UDim2.fromOffset(35, 0),
            BackgroundTransparency = 1,
            Text = TITLE,
            FontFace = FONT_B,
            TextSize = 18,
            TextColor3 = Color3.fromRGB(240, 255, 250),
            TextTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, pill)

        tw(pill, 0.5, Q, OUT, { BackgroundTransparency = 0.15, Position = UDim2.new(1, -20, 0, 20) })
        tw(pillStroke, 0.5, Q, OUT, { Transparency = 0.2 })
        tw(text, 0.5, Q, OUT, { TextTransparency = 0 })
        tw(dot,  0.5, Q, OUT, { BackgroundTransparency = 0 })

        task.spawn(function()
            while gui.Parent do
                tw(dot, 0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, { BackgroundTransparency = 0.6 })
                task.wait(0.8)
                tw(dot, 0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, { BackgroundTransparency = 0 })
                task.wait(0.8)
            end
        end)
    end)
end)

-- ULTRA AGGRESSIVE CHAT UI RESTORATION
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            v_Sgi:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
            v_Sgi:SetCore("ChatWindowVisible", true)
            v_Sgi:SetCore("ChatActive", true)
            
            local playerGui = plr:FindFirstChild("PlayerGui")
            if playerGui then
                local chatGui = playerGui:FindFirstChild("Chat")
                if chatGui then
                    chatGui.Enabled = true
                    for _, child in ipairs(chatGui:GetDescendants()) do
                        if child:IsA("Frame") or child:IsA("ScrollingFrame") or child:IsA("TextBox") then
                            child.Visible = true
                        end
                    end
                end
            end
        end)
    end
end)

local function setupAntiStates(char)
    if not char then return end
    local humanoid = char:WaitForChild("Humanoid", 5)
    if humanoid then
        humanoid:GetPropertyChangedSignal("Sit"):Connect(function()
            if humanoid.Sit then humanoid.Sit = false end
        end)
        humanoid.StateChanged:Connect(function(_, newState)
            if newState == Enum.HumanoidStateType.Seated then
                humanoid.Sit = false
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
            elseif newState == Enum.HumanoidStateType.Ragdoll or newState == Enum.HumanoidStateType.FallingDown then
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end
        end)
    end
end

plr.CharacterAdded:Connect(setupAntiStates)
if plr.Character then
    task.spawn(function() setupAntiStates(plr.Character) end)
end

if _G.TeleportState.IsRunning then
    local waitStart = tick()
    repeat task.wait(1) until not _G.TeleportState.IsRunning or (tick() - waitStart > 10)
end
_G.TeleportState.IsRunning = true

while not plr do task.wait(0.1); plr = v_QpZ.LocalPlayer end
task.wait(2)

local title = plr:FindFirstChild("PlayerGui") and plr.PlayerGui:FindFirstChild("Title")
if title then title:Destroy() end

local remote = v_Wne:FindFirstChild("Remote")
if remote then
    local spawnChar = remote:FindFirstChild("SpawnChar")
    if spawnChar then spawnChar:FireServer() end
end

if workspace.CurrentCamera then workspace.CurrentCamera:Destroy() end
task.wait(0.1)

repeat task.wait(0.5) until plr.Character and plr.Character:FindFirstChildWhichIsA("Humanoid")
local humanoid = plr.Character:FindFirstChildWhichIsA("Humanoid")
if humanoid then
    workspace.CurrentCamera.CameraSubject = humanoid
    workspace.CurrentCamera.CameraType = "Custom"
end
plr.CameraMinZoomDistance = 0.5
plr.CameraMaxZoomDistance = 400
plr.CameraMode = "Classic"

local id_Plc = game.PlaceId
local b_Oek = v_Rtd.ChatVersion == Enum.ChatVersion.LegacyChatService

local function f_Nra(s_Yui)
    s_Yui = tostring(s_Yui)
    pcall(function()
        if not b_Oek then
            v_Rtd.TextChannels.RBXGeneral:SendAsync(s_Yui)
        else
            v_Wne.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(s_Yui, "All")
        end
    end)
end

local function f_Hbv(p) 
    if not p or not p.Parent then return nil end
    if p.Character then
        local hrp = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChild("Head")
        if hrp then return hrp end
    end
    return nil
end
local function f_Lzt() return f_Hbv(plr) end

local function getPingInSeconds()
    local ping = 0.1
    pcall(function()
        local dataPing = Stats.Network.ServerStatsItem["Data Ping"]
        if dataPing then ping = (dataPing:GetValue() / 1000) end
    end)
    return math.clamp(ping, 0.05, 0.5)
end

-- TARGET STATES
local currentChatTarget = nil
local isAttacking = false
local hasSaidHiForCurrentTarget = false

local function handleChatInput(senderName, message)
    if senderName:lower() == "avabow13" then
        local trimmedMessage = message:match("^%s*(.-)%s*$"):lower()
        if trimmedMessage == "" then return end
        
        if trimmedMessage == "stop" then
            currentChatTarget = nil
            isAttacking = false
            hasSaidHiForCurrentTarget = false
            f_Nra("stopped")
            return
        end
        
        -- Check for "attack [username]" command format
        local attackQuery = trimmedMessage:match("^attack%s+(.+)$")
        if attackQuery then
            for _, p in ipairs(v_QpZ:GetPlayers()) do
                if p ~= plr then
                    local pName = p.Name:lower()
                    local pDisplayName = p.DisplayName:lower()
                    if pName:sub(1, #attackQuery) == attackQuery or pDisplayName:sub(1, #attackQuery) == attackQuery or pName:find(attackQuery) then
                        currentChatTarget = p
                        isAttacking = true
                        hasSaidHiForCurrentTarget = false 
                        print("[GVS] Violent attack target locked: " .. p.Name)
                        return
                    end
                end
            end
        end
        
        -- Default target lock via chat name
        for _, p in ipairs(v_QpZ:GetPlayers()) do
            if p ~= plr then
                local pName = p.Name:lower()
                local pDisplayName = p.DisplayName:lower()
                if pName:sub(1, #trimmedMessage) == trimmedMessage or pDisplayName:sub(1, #trimmedMessage) == trimmedMessage or pName:find(trimmedMessage) then
                    currentChatTarget = p
                    isAttacking = false
                    hasSaidHiForCurrentTarget = false 
                    break
                end
            end
        end
    end
end

local function hookPlayerChat(p)
    pcall(function()
        p.Chatted:Connect(function(msg) handleChatInput(p.Name, msg) end)
    end)
end

if b_Oek then
    for _, p in ipairs(v_QpZ:GetPlayers()) do hookPlayerChat(p) end
    v_QpZ.PlayerAdded:Connect(hookPlayerChat)
else
    pcall(function()
        v_Rtd.MessageReceived:Connect(function(textMessage)
            if textMessage.TextSource then
                local senderPlayer = v_QpZ:GetPlayerByUserId(textMessage.TextSource.UserId)
                if senderPlayer then handleChatInput(senderPlayer.Name, textMessage.Text) end
            end
        end)
    end)
end

local SPEED_THRESHOLD = 16
local mapGridPoints = {}
for _, x in ipairs({-1200, -800, -400, 0, 400, 800, 1200}) do
    for _, z in ipairs({-1200, -800, -400, 0, 400, 800, 1200}) do
        table.insert(mapGridPoints, Vector3.new(x, 50, z))
        table.insert(mapGridPoints, Vector3.new(x, 250, z))
    end
end

-- ORBIT & VIOLENT ATTACK LOOP
local function f_Wpy(target)
    local angle = 0
    local gridIndex = 1

    while target and target.Parent and currentChatTarget == target do
        local dt = v_Lmk.Heartbeat:Wait()
        angle = angle + (isAttacking and 35 or 8) * dt -- Hyper-fast rotation if attacking

        local myHrp = f_Lzt()
        local tgtHrp = f_Hbv(target)

        if myHrp then
            pcall(function()
                if tgtHrp and tgtHrp.Parent then
                    if not hasSaidHiForCurrentTarget and not isAttacking then
                        hasSaidHiForCurrentTarget = true
                        f_Nra("hi " .. target.Name)
                    end

                    plr.ReplicationFocus = tgtHrp
                    pcall(function() plr:RequestStreamAroundAsync(tgtHrp.Position, 16) end)

                    local targetAssembly = tgtHrp.AssemblyRootPart or tgtHrp
                    local targetVel = targetAssembly.AssemblyLinearVelocity
                    local targetSpeed = targetVel.Magnitude

                    local predictedPos = targetAssembly.Position
                    if targetSpeed > SPEED_THRESHOLD then
                        local pingSec = getPingInSeconds()
                        local leadTime = (pingSec * 1.8) + 0.15 
                        predictedPos = targetAssembly.Position + (targetVel * leadTime)
                    end

                    myHrp.AssemblyLinearVelocity = Vector3.zero
                    myHrp.AssemblyAngularVelocity = Vector3.zero

                    local finalTargetCFrame
                    if isAttacking then
                        -- VIOLENT SPAZZ MOTION: Random high-frequency positional shaking + rapid spinning around target
                        local randomJitter = Vector3.new(math.random(-4, 4), math.random(-2, 4), math.random(-4, 4))
                        local spazzRadius = 3
                        local orbitOffset = Vector3.new(math.cos(angle) * spazzRadius, math.sin(tick() * 25) * 2, math.sin(angle) * spazzRadius)
                        finalTargetCFrame = CFrame.new(predictedPos + orbitOffset + randomJitter, predictedPos + Vector3.new(math.random(-1,1), 0, math.random(-1,1)))
                    else
                        -- Standard smooth floating orbit
                        local floatHeight = 2 + math.sin(tick() * 3) * 0.75
                        local orbitRadius = 6
                        local orbitOffset = Vector3.new(math.cos(angle) * orbitRadius, floatHeight, math.sin(angle) * orbitRadius)
                        finalTargetCFrame = CFrame.new(predictedPos + orbitOffset, predictedPos)
                    end

                    myHrp.CFrame = myHrp.CFrame:Lerp(finalTargetCFrame, math.clamp(dt * (isAttacking and 30 or 12), 0, 1))
                else
                    local sweepPos = mapGridPoints[gridIndex]
                    if sweepPos then
                        plr.ReplicationFocus = myHrp
                        pcall(function() plr:RequestStreamAroundAsync(sweepPos, 500) end)
                        myHrp.AssemblyLinearVelocity = Vector3.zero
                        myHrp.AssemblyAngularVelocity = Vector3.zero
                        myHrp.CFrame = CFrame.new(sweepPos)

                        gridIndex = gridIndex + 1
                        if gridIndex > #mapGridPoints then gridIndex = 1 end
                    end
                end
            end)
        end
    end

    pcall(function()
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            plr.ReplicationFocus = plr.Character.HumanoidRootPart
        end
    end)
end

pcall(function()
    if not (plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")) then
        plr.CharacterAdded:Wait()
        repeat task.wait(0.1) until plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        task.wait(1)
    end
    
    while true do
        if currentChatTarget then
            f_Wpy(currentChatTarget)
        else
            hasSaidHiForCurrentTarget = false
            isAttacking = false
        end
        task.wait(0.1)
    end
end)

_G.TeleportState.IsRunning = false
