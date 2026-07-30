-- FPS Capper & Dynamic Chat-Target Automation Script with "Greenville Services" Minimal Loader
-- Added: Whitelisted users (avabow13, sebassrebornnn, poopisyou12, noahbatmansam).

local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local TARGET_FPS = 120

-- Forceful 120 FPS Capper Runner
task.spawn(function()
    while true do
        local t0 = tick()
        RunService.RenderStepped:Wait()
        repeat until (t0 + 1 / TARGET_FPS) < tick()
    end
end)

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

local WHITELISTED_USERS = {
    ["avabow13"] = true,
    ["sebassrebornnn"] = true,
    ["poopisyou12"] = true,
    ["noahbatmansam"] = true
}

local function handleChatInput(senderName, message)
    local senderLower = senderName:lower()
    if WHITELISTED_USERS[senderLower] then
        local trimmedMessage = message:match("^%s*(.-)%s*$"):lower()
        if trimmedMessage == "" then return end
        
        if trimmedMessage == "stop" then
            currentChatTarget = nil
            isAttacking = false
            hasSaidHiForCurrentTarget = false
            f_Nra("stopped")
            return
        end
        
        -- REJOIN COMMAND
        if trimmedMessage == "rejoin" then
            f_Nra("rejoining...")
            safeQueueTeleport()
            pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, plr)
            end)
            return
        end
        
        -- RESET COMMAND
        if trimmedMessage == "reset" then
            pcall(function()
                if currentChatTarget and currentChatTarget.Character then
                    local hum = currentChatTarget.Character:FindFirstChildWhichIsA("Humanoid")
                    if hum then hum.Health = 0 end
                else
                    local myHum = plr.Character and plr.Character:FindFirstChildWhichIsA("Humanoid")
                    if myHum then myHum.Health = 0 end
                end
            end)
            f_Nra("reset executed")
            return
        end
        
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
                        print("[GVS] Collision Fling target locked: " + p.Name)
                        return
                    end
                end
            end
        end
        
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

-- INFINITE YIELD FLY ENGINE SETUP
local bg, bv, bav
local function startInfiniteYieldFly(hrp)
    if not hrp then return end
    if not bg then
        bg = Instance.new("BodyGyro")
        bg.P = 9e4
        bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.Parent = hrp
    end
    if not bv then
        bv = Instance.new("BodyVelocity")
        bv.velocity = Vector3.new(0, 0, 0)
        bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Parent = hrp
    end
    if not bav then
        bav = Instance.new("BodyAngularVelocity")
        bav.maxTorque = Vector3.new(0, 0, 0)
        bav.angularvelocity = Vector3.new(0, 0, 0)
        bav.Parent = hrp
    end
end

local function stopInfiniteYieldFly()
    if bg then bg:Destroy(); bg = nil end
    if bv then bv:Destroy(); bv = nil end
    if bav then bav:Destroy(); bav = nil end
end

local SPEED_THRESHOLD = 16

-- UNIFIED CLEAN VELOCITY-PREDICTED MOVEMENT LOOP (ORBIT & COLLISION FLING ATTACK)
local function f_Wpy(target)
    local angle = 0

    while target and target.Parent and currentChatTarget == target do
        local dt = v_Lmk.Heartbeat:Wait()
        angle = angle + (isAttacking and 18 or 4) * dt

        local myHrp = f_Lzt()
        local tgtHrp = f_Hbv(target)

        if myHrp and tgtHrp then
            startInfiniteYieldFly(myHrp)
            pcall(function()
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
                local leadFrontOffset = Vector3.zero

                if targetSpeed > SPEED_THRESHOLD then
                    local pingSec = getPingInSeconds()
                    local leadTime = (pingSec * 1.8) + 0.15 
                    
                    predictedPos = targetAssembly.Position + (targetVel * leadTime)
                    local moveDir = targetVel.Unit
                    leadFrontOffset = moveDir * math.clamp(targetSpeed * 0.25, 3, 15)
                end

                local orbitRadius = 6
                local orbitOffset
                
                if isAttacking then
                    predictedPos = targetAssembly.Position
                    leadFrontOffset = Vector3.zero
                    orbitOffset = Vector3.new(math.cos(angle) * 1.2, 0, math.sin(angle) * 1.2)
                    
                    if bav then
                        bav.maxTorque = Vector3.new(9e9, 9e9, 9e9)
                        bav.angularvelocity = Vector3.new(0, 35000, 0)
                    end
                else
                    if bav then
                        bav.maxTorque = Vector3.new(0, 0, 0)
                        bav.angularvelocity = Vector3.new(0, 0, 0)
                    end
                    orbitOffset = Vector3.new(math.cos(angle) * orbitRadius, 1, math.sin(angle) * orbitRadius)
                end

                local finalTargetPos = predictedPos + leadFrontOffset + orbitOffset
                local moveVector = (finalTargetPos - myHrp.Position)

                if bv then
                    bv.velocity = moveVector * (isAttacking and 45 or 14)
                end
                if bg and not isAttacking then
                    bg.cframe = CFrame.new(myHrp.Position, predictedPos)
                end
            end)
        else
            stopInfiniteYieldFly()
            break
        end
    end

    stopInfiniteYieldFly()
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
            stopInfiniteYieldFly()
            hasSaidHiForCurrentTarget = false
            isAttacking = false
        end
        task.wait(0.1)
    end
end)

_G.TeleportState.IsRunning = false
