-- FPS Capper & Dynamic Chat-Target Automation Script with "Greenville Services" Minimal Loader
-- Target-Specific Mode: Idles at spawn until "Sebassrebornnn" chats a target's name, dynamically streams/searches the map, and only says "hi [FullName]" once successfully orbiting them.

local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local TARGET_FPS = 15

-- Forceful 15 FPS Capper Runner
task.spawn(function()
    while true do
        local t0 = tick()
        RunService.RenderStepped:Wait()
        repeat until (t0 + 1 / TARGET_FPS) < tick()
    end
end)

local function missing(expectedType, value, fallback)
    if type(value) == expectedType then
        return value
    end
    return fallback
end

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

-- Universal function to set queue on teleport prior to hopping
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
            
            if v_Rtd.ChatVersion == Enum.ChatVersion.TextChatService then
                local windowConfig = v_Rtd:FindFirstChild("ChatWindowConfiguration")
                if windowConfig then
                    windowConfig.Enabled = true
                end
            end
        end)
    end
end)

-- ANTI-SIT & ANTI-RAGDOLL SYSTEM
local function setupAntiStates(char)
    if not char then return end
    local humanoid = char:WaitForChild("Humanoid", 5)
    if humanoid then
        humanoid:GetPropertyChangedSignal("Sit"):Connect(function()
            if humanoid.Sit then humanoid.Sit = false end
        end)
        humanoid.StateChanged:Connect(function(_, newState)
            if newState == Enum.HumanoidStateType.Seated or newState == Enum.HumanoidStateType.Ragdoll or newState == Enum.HumanoidStateType.FallingDown then
                humanoid.Sit = false
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end
        end)
    end

    char.DescendantAdded:Connect(function(descendant)
        pcall(function()
            if descendant:IsA("BallSocketConstraint") or descendant:IsA("HingeConstraint") or descendant:IsA("BodyVelocity") or descendant:IsA("BodyAngularVelocity") then
                if descendant.Name:lower():find("ragdoll") or descendant.Name:lower():find("joint") then
                    descendant:Destroy()
                end
            end
        end)
    end)
end

plr.CharacterAdded:Connect(setupAntiStates)
if plr.Character then task.spawn(function() setupAntiStates(plr.Character) end) end

local function httpRequest(url)
    local success, result = pcall(function() return game:HttpGet(url) end)
    if success and type(result) == "string" and #result > 0 then return result end

    success, result = pcall(function()
        local response = syn.request({Url = url, Method = "GET"})
        return response.Body
    end)
    if success and type(result) == "string" and #result > 0 then return result end

    for _, funcName in ipairs({"http_request", "request", "http.request"}) do
        local func = (syn and syn[funcName]) or http_request or request or (http and http.request)
        if func then
            success, result = pcall(function()
                return func({Url = url, Method = "GET"}).Body
            end)
            if success and type(result) == "string" and #result > 0 then return result end
        end
    end
    return nil
end

if _G.TeleportState.IsRunning then
    print("Script already running, waiting...")
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

local attempts = 0
repeat 
    task.wait(0.5)
    attempts = attempts + 1
    if attempts > 20 then
        plr.CharacterAdded:Wait()
        attempts = 0
    end
until plr.Character and plr.Character:FindFirstChildWhichIsA("Humanoid")

if not plr.Character then plr.CharacterAdded:Wait() end

local humanoid = plr.Character:FindFirstChildWhichIsA("Humanoid")
if humanoid then
    workspace.CurrentCamera.CameraSubject = humanoid
    workspace.CurrentCamera.CameraType = "Custom"
end
plr.CameraMinZoomDistance = 0.5
plr.CameraMaxZoomDistance = 400
plr.CameraMode = "Classic"

local head = plr.Character:FindFirstChild("Head")
if head then head.Anchored = false end

local id_Plc = game.PlaceId
local id_Job = game.JobId
local b_Oek = v_Rtd.ChatVersion == Enum.ChatVersion.LegacyChatService

local function f_Nra(s_Yui)
    s_Yui = tostring(s_Yui)
    if not b_Oek then
        v_Rtd.TextChannels.RBXGeneral:SendAsync(s_Yui)
    else
        v_Wne.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(s_Yui, "All")
    end
end

-- ENHANCED SERVER HOPPER
local function f_Sho()
    safeQueueTeleport()
    local s_Req = httpRequest("https://games.roblox.com/v1/games/" .. id_Plc .. "/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true")
    if s_Req then 
        local ok_Bod, t_Bod = pcall(function() return v_Hts:JSONDecode(s_Req) end)
        if ok_Bod and t_Bod and t_Bod.data then 
            local t_Srv = {}
            for _, v_Ent in ipairs(t_Bod.data) do
                if type(v_Ent) == "table" and tonumber(v_Ent.playing) and tonumber(v_Ent.maxPlayers) and v_Ent.playing < v_Ent.maxPlayers and v_Ent.id ~= id_Job then
                    table.insert(t_Srv, v_Ent.id)
                end
            end
            if #t_Srv > 0 then
                _G.TeleportState.ServerHopTimer = true
                _G.TeleportState.ScriptFinished = true
                _G.TeleportState.IsRunning = false
                local randomServer = t_Srv[math.random(1, #t_Srv)]
                if pcall(function() v_Tps:TeleportToPlaceInstance(id_Plc, randomServer, plr) end) then return true end
            end
        end
    end
    _G.TeleportState.ServerHopTimer = true
    _G.TeleportState.ScriptFinished = true
    _G.TeleportState.IsRunning = false
    pcall(function() v_Tps:Teleport(id_Plc, plr) end)
    return true
end

v_Tps.TeleportInitFailed:Connect(function() f_Sho() end)
v_Gui.ErrorMessageChanged:Connect(function(msg) if msg and #msg > 0 then f_Sho() end end)

local function f_Hbv(p) return p.Character and p.Character:FindFirstChild("HumanoidRootPart") end
local function f_Lzt() return f_Hbv(plr) end

local function getPingInSeconds()
    local ping = 0.1
    pcall(function()
        local dataPing = Stats.Network.ServerStatsItem["Data Ping"]
        if dataPing then ping = (dataPing:GetValue() / 1000) end
    end)
    return math.clamp(ping, 0.05, 0.5)
end

-- GLOBAL TARGET CACHE
local currentChatTarget = nil
local hasSaidHelloForTarget = false

-- CHAT LISTENER FOR SEBASSREBORNNN
local function handleChatInput(senderName, message)
    if senderName:lower() == "sebassrebornnn" then
        local trimmedMessage = message:match("^%s*(.-)%s*$")
        for _, p in ipairs(v_QpZ:GetPlayers()) do
            if p ~= plr and (p.Name:lower():sub(1, #trimmedMessage) == trimmedMessage:lower() or p.DisplayName:lower():sub(1, #trimmedMessage) == trimmedMessage:lower()) then
                currentChatTarget = p
                hasSaidHelloForTarget = false -- Reset confirmation so it checks and sends "hi" once locked in
                print("[GVS] Search initiated for target: " .. p.Name)
                break
            end
        end
    end
end

if b_Oek then
    for _, p in ipairs(v_QpZ:GetPlayers()) do
        p.Chatted:Connect(function(msg) handleChatInput(p.Name, msg) end)
    end
    v_QpZ.PlayerAdded:Connect(function(p)
        p.Chatted:Connect(function(msg) handleChatInput(p.Name, msg) end)
    end)
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

-- MAP SEARCH, STREAMING BYPASS & FAST SPIN ORBIT HOOK
local SPEED_THRESHOLD = 16

local function f_Wpy(target)
    local angle = 0

    while target and target.Parent and currentChatTarget == target do
        local dt = v_Lmk.Heartbeat:Wait()
        local myHrp = f_Lzt()
        local tgtHrp = f_Hbv(target)

        -- Bypass streaming boundaries by forcing client replication focus to target's position
        if tgtHrp then
            pcall(function() plr.ReplicationFocus = tgtHrp end)
        end

        if myHrp and tgtHrp then
            -- Successfully found, streamed in, and tracking! Send "hi" message once per target lock.
            if not hasSaidHelloForTarget then
                hasSaidHelloForTarget = true
                f_Nra("hi " .. target.Name)
            end

            angle = angle + 12 * dt
            pcall(function()
                local targetAssembly = tgtHrp.AssemblyRootPart or tgtHrp
                local targetVel = targetAssembly.AssemblyLinearVelocity
                local targetSpeed = targetVel.Magnitude

                local predictedPos = targetAssembly.Position
                local leadFrontOffset = Vector3.zero

                if targetSpeed > SPEED_THRESHOLD then
                    local pingSec = getPingInSeconds()
                    local leadTime = (pingSec * 1.8) + 0.15 
                    predictedPos = targetAssembly.Position + (targetVel * leadTime)
                    local moveDir = targetVel.Unit
                    leadFrontOffset = moveDir * math.clamp(targetSpeed * 0.25, 3, 15)
                end

                myHrp.AssemblyLinearVelocity = Vector3.zero
                myHrp.AssemblyAngularVelocity = Vector3.zero

                local orbitRadius = 5
                local orbitOffset = Vector3.new(math.cos(angle) * orbitRadius, 2, math.sin(angle) * orbitRadius)
                myHrp.CFrame = CFrame.new(predictedPos + leadFrontOffset + orbitOffset, predictedPos)
            end)
        else
            -- If the target is streamed out or hidden, wait safely without breaking
            task.wait(0.2)
        end
    end

    -- Reset replication focus when dropping target tracking
    pcall(function() plr.ReplicationFocus = nil end)
end

local function f_Ryn()
    while true do
        if currentChatTarget then
            if currentChatTarget.Parent then
                f_Wpy(currentChatTarget)
            else
                currentChatTarget = nil
                hasSaidHelloForTarget = false
            end
        end
        task.wait(0.5)
    end
end

pcall(function()
    if not (plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")) then
        plr.CharacterAdded:Wait()
        repeat task.wait(0.1) until plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        task.wait(1)
    end
    f_Ryn()
end)

_G.TeleportState.IsRunning = false
