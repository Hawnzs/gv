--[[
    GV Script - Ultra-Refined Version
    - Multiple self-healing layers
    - Execution verification
    - State recovery
    - Anti-stuck protection
    - Teleport reliability
]]

-----------------------------------------------------------------------
-- 1. CORE FUNCTIONS & INITIALIZATION
-----------------------------------------------------------------------

local function missing(expectedType, value, fallback)
    if type(value) == expectedType then
        return value
    end
    return fallback
end

local queueteleport = missing("function",
    queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
)

if type(_G.KeepInfYield) ~= "boolean" then
    _G.KeepInfYield = true
end

-- Initialize teleport state with all protection flags
if type(_G.TeleportState) ~= "table" then
    _G.TeleportState = {
        -- Core state
        TeleportCheck = false,
        TeleportRetries = 0,
        MaxRetries = 3,
        ServerHopTimer = false,
        ScriptFinished = false,
        IsRunning = false,
        Initialized = false,
        
        -- Self-healing state
        ExecutionAttempts = 0,
        MaxExecutionAttempts = 5,
        LastHeartbeat = os.time(),
        RecoveryAttempts = 0,
        MaxRecoveryAttempts = 3,
        
        -- Protection flags
        IsRecovering = false,
        ForceRestart = false,
        ExecutionVerified = false
    }
end

-----------------------------------------------------------------------
-- 2. SELF-HEALING SYSTEM
-----------------------------------------------------------------------

--[[
    LAYER 1: Heartbeat Monitor
    Checks if script is still responsive every 5 seconds
]]
local function heartbeatMonitor()
    task.spawn(function()
        while task.wait(5) do
            if _G.TeleportState.Initialized then
                _G.TeleportState.LastHeartbeat = os.time()
            end
        end
    end)
end
heartbeatMonitor()

--[[
    LAYER 2: Execution Verifier
    Verifies script actually executed and is running
]]
local function executionVerifier()
    task.spawn(function()
        local checkCount = 0
        
        while task.wait(10) do
            checkCount = checkCount + 1
            
            -- Check if script never initialized
            if not _G.TeleportState.Initialized and not _G.TeleportState.IsRecovering then
                if _G.TeleportState.ExecutionAttempts < _G.TeleportState.MaxExecutionAttempts then
                    print("[HEAL] Script not initialized, restarting (attempt " .. (_G.TeleportState.ExecutionAttempts + 1) .. "/" .. _G.TeleportState.MaxExecutionAttempts .. ")")
                    _G.TeleportState.ExecutionAttempts = _G.TeleportState.ExecutionAttempts + 1
                    _G.TeleportState.IsRunning = false
                    _G.TeleportState.IsRecovering = true
                    
                    task.wait(2)
                    pcall(function()
                        loadstring(game:HttpGet("https://raw.githubusercontent.com/Hawnzs/gv/main/script.lua", true))()
                    end)
                    
                    task.wait(5)
                    _G.TeleportState.IsRecovering = false
                    break
                else
                    print("[HEAL] Max execution attempts reached, forcing reset...")
                    _G.TeleportState.ExecutionAttempts = 0
                    _G.TeleportState.IsRunning = false
                    _G.TeleportState.Initialized = false
                    _G.TeleportState.IsRecovering = true
                    
                    task.wait(5)
                    pcall(function()
                        loadstring(game:HttpGet("https://raw.githubusercontent.com/Hawnzs/gv/main/script.lua", true))()
                    end)
                    
                    task.wait(5)
                    _G.TeleportState.IsRecovering = false
                    break
                end
            end
            
            -- Check if script stopped unexpectedly
            if _G.TeleportState.Initialized and not _G.TeleportState.IsRunning 
                and not _G.TeleportState.ScriptFinished 
                and not _G.TeleportState.ServerHopTimer
                and not _G.TeleportState.IsRecovering then
                
                print("[HEAL] Script stopped unexpectedly, restarting...")
                _G.TeleportState.IsRecovering = true
                _G.TeleportState.IsRunning = false
                _G.TeleportState.Initialized = false
                
                task.wait(3)
                pcall(function()
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/Hawnzs/gv/main/script.lua", true))()
                end)
                
                task.wait(5)
                _G.TeleportState.IsRecovering = false
                break
            end
            
            -- Check if script is stuck (no heartbeat for 30+ seconds)
            if _G.TeleportState.Initialized and _G.TeleportState.IsRunning then
                local timeSinceHeartbeat = os.time() - _G.TeleportState.LastHeartbeat
                if timeSinceHeartbeat > 30 and not _G.TeleportState.IsRecovering then
                    print("[HEAL] Script heartbeat stopped (" .. timeSinceHeartbeat .. "s), restarting...")
                    _G.TeleportState.IsRecovering = true
                    _G.TeleportState.IsRunning = false
                    _G.TeleportState.Initialized = false
                    
                    task.wait(3)
                    pcall(function()
                        loadstring(game:HttpGet("https://raw.githubusercontent.com/Hawnzs/gv/main/script.lua", true))()
                    end)
                    
                    task.wait(5)
                    _G.TeleportState.IsRecovering = false
                    break
                end
            end
        end
    end)
end
executionVerifier()

--[[
    LAYER 3: Recovery Coordinator
    Coordinates recovery attempts across all layers
]]
local function recoveryCoordinator()
    task.spawn(function()
        while task.wait(60) do
            -- Check if recovery is needed
            if _G.TeleportState.IsRecovering then
                _G.TeleportState.RecoveryAttempts = _G.TeleportState.RecoveryAttempts + 1
                
                if _G.TeleportState.RecoveryAttempts > _G.TeleportState.MaxRecoveryAttempts then
                    print("[HEAL] Max recovery attempts reached, performing hard reset...")
                    _G.TeleportState.RecoveryAttempts = 0
                    _G.TeleportState.IsRecovering = false
                    _G.TeleportState.IsRunning = false
                    _G.TeleportState.Initialized = false
                    _G.TeleportState.ForceRestart = true
                    
                    -- Hard reset - clear and reload
                    task.wait(5)
                    pcall(function()
                        loadstring(game:HttpGet("https://raw.githubusercontent.com/Hawnzs/gv/main/script.lua", true))()
                    end)
                end
            else
                -- Reset recovery attempts if stable
                if _G.TeleportState.Initialized and _G.TeleportState.IsRunning then
                    _G.TeleportState.RecoveryAttempts = 0
                end
            end
        end
    end)
end
recoveryCoordinator()

--[[
    LAYER 4: Teleport Recovery
    Ensures script reloads after teleport even if payload fails
]]
local function teleportRecovery()
    task.spawn(function()
        local lastJobId = game.JobId
        
        while task.wait(2) do
            local currentJobId = game.JobId
            
            -- Check if we teleported
            if currentJobId ~= lastJobId then
                print("[HEAL] Teleport detected, ensuring script is running...")
                lastJobId = currentJobId
                
                -- Reset state for new server
                _G.TeleportState.TeleportCheck = false
                _G.TeleportState.ServerHopTimer = false
                _G.TeleportState.ScriptFinished = false
                _G.TeleportState.IsRunning = false
                _G.TeleportState.Initialized = false
                
                -- Wait for character to load
                task.wait(5)
                
                -- Ensure script reloads
                if not _G.TeleportState.Initialized then
                    print("[HEAL] Script didn't reload after teleport, forcing...")
                    pcall(function()
                        loadstring(game:HttpGet("https://raw.githubusercontent.com/Hawnzs/gv/main/script.lua", true))()
                    end)
                end
            end
        end
    end)
end
teleportRecovery()

-----------------------------------------------------------------------
-- 3. TELEPORT HANDLER
-----------------------------------------------------------------------

local function setupTeleportHandler()
    local handlerSuccess, handlerErr = pcall(function()
        game.Players.LocalPlayer.OnTeleport:Connect(function(State)
            if State == Enum.TeleportState.InProgress then
                if _G.KeepInfYield and not _G.TeleportState.TeleportCheck and queueteleport then
                    _G.TeleportState.TeleportCheck = true
                    _G.TeleportState.TeleportRetries = 0
                    
                    local scriptUrl = "https://raw.githubusercontent.com/Hawnzs/gv/main/script.lua"
                    
                    local currentChats = type(_G.t_Fjd) == "table" and _G.t_Fjd or {"/gvse", "broke? /gvse", "slow cars? /gvse", "want to larp? /gvse"}
                    local encodedChats = game:GetService("HttpService"):JSONEncode(currentChats)
                    
                    local payload = string.format([[
                        -- Reset state
                        if type(_G.TeleportState) ~= "table" then
                            _G.TeleportState = {
                                TeleportCheck = false,
                                TeleportRetries = 0,
                                MaxRetries = 3,
                                ServerHopTimer = false,
                                ScriptFinished = false,
                                IsRunning = false,
                                Initialized = false,
                                ExecutionAttempts = 0,
                                MaxExecutionAttempts = 5,
                                LastHeartbeat = os.time(),
                                RecoveryAttempts = 0,
                                MaxRecoveryAttempts = 3,
                                IsRecovering = false,
                                ForceRestart = false,
                                ExecutionVerified = false
                            }
                        else
                            _G.TeleportState.TeleportCheck = false
                            _G.TeleportState.TeleportRetries = 0
                            _G.TeleportState.ServerHopTimer = false
                            _G.TeleportState.ScriptFinished = false
                            _G.TeleportState.IsRunning = false
                            _G.TeleportState.Initialized = false
                            _G.TeleportState.ExecutionAttempts = 0
                            _G.TeleportState.IsRecovering = false
                        end
                        
                        -- Self-healing on new server
                        local function heartbeatMonitor()
                            task.spawn(function()
                                while task.wait(5) do
                                    if _G.TeleportState.Initialized then
                                        _G.TeleportState.LastHeartbeat = os.time()
                                    end
                                end
                            end)
                        end
                        heartbeatMonitor()
                        
                        local function executionVerifier()
                            task.spawn(function()
                                while task.wait(10) do
                                    if not _G.TeleportState.Initialized and not _G.TeleportState.IsRecovering then
                                        if _G.TeleportState.ExecutionAttempts < _G.TeleportState.MaxExecutionAttempts then
                                            _G.TeleportState.ExecutionAttempts = _G.TeleportState.ExecutionAttempts + 1
                                            _G.TeleportState.IsRunning = false
                                            _G.TeleportState.IsRecovering = true
                                            task.wait(2)
                                            pcall(function()
                                                loadstring(game:HttpGet('%s', true))()
                                            end)
                                            task.wait(5)
                                            _G.TeleportState.IsRecovering = false
                                            break
                                        end
                                    end
                                end
                            end)
                        end
                        executionVerifier()
                        
                        -- Wait for character
                        local waitTime = 0
                        while waitTime < 15 do
                            local plr = game.Players.LocalPlayer
                            if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                                local humanoid = plr.Character:FindFirstChildWhichIsA("Humanoid")
                                if humanoid and humanoid.Health > 0 then
                                    break
                                end
                            end
                            task.wait(0.5)
                            waitTime = waitTime + 0.5
                        end
                        
                        task.wait(2)
                        
                        -- Load script with retry
                        local function loadScript()
                            local success, err = pcall(function()
                                loadstring(game:HttpGet('%s', true))()
                            end)
                            if not success then
                                print("Failed to reload script: " .. tostring(err))
                                return false
                            end
                            return true
                        end
                        
                        local loaded = loadScript()
                        if not loaded then
                            task.wait(3)
                            loadScript()
                        end
                    ]], encodedChats, scriptUrl, scriptUrl)
                    
                    queueteleport(payload)
                end
            elseif State == Enum.TeleportState.Failed then
                _G.TeleportState.TeleportCheck = false
            end
        end)
    end)
    
    if not handlerSuccess then
        print("Failed to setup teleport handler: " .. tostring(handlerErr))
    end
end

setupTeleportHandler()

-----------------------------------------------------------------------
-- 4. SERVICE REFERENCES
-----------------------------------------------------------------------

local v_QpZ = game:GetService("Players")
local v_Lmk = game:GetService("RunService")
local v_Wne = game:GetService("ReplicatedStorage")
local v_Rtd = game:GetService("TextChatService")
local v_Tps = game:GetService("TeleportService")
local v_Hts = game:GetService("HttpService")
local v_Gui = game:GetService("GuiService")
local v_Sgi = game:GetService("StarterGui")
local v_Input = game:GetService("VirtualUser")
local v_UIS = game:GetService("UserInputService")
local v_Http = game:GetService("HttpService")

-----------------------------------------------------------------------
-- 5. ANTI-AFK
-----------------------------------------------------------------------

local function antiAFK()
    if v_Input then
        task.spawn(function()
            while task.wait(45) do
                pcall(function()
                    v_Input:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    task.wait(0.1)
                    v_Input:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    v_Input:MouseMove(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    task.wait(0.1)
                    v_Input:MouseMove(Vector2.new(100,100), workspace.CurrentCamera.CFrame)
                end)
            end
        end)
        return true
    end
    
    if v_UIS then
        task.spawn(function()
            while task.wait(60) do
                pcall(function()
                    v_UIS:MouseMove(Vector2.new(0, 0))
                    task.wait(0.1)
                    v_UIS:MouseMove(Vector2.new(100, 100))
                end)
            end
        end)
        return true
    end
    
    task.spawn(function()
        while task.wait(60) do
            pcall(function()
                local mouse = game.Players.LocalPlayer:GetMouse()
                if mouse then
                    mouse.Move(Vector2.new(0, 0))
                    task.wait(0.1)
                    mouse.Move(Vector2.new(100, 100))
                end
            end)
        end
    end)
    
    return true
end

-----------------------------------------------------------------------
-- 6. HTTP REQUEST
-----------------------------------------------------------------------

local function httpRequest(url)
    local success, result
    
    success, result = pcall(function() 
        return game:HttpGet(url, true) 
    end)
    if success and type(result) == "string" and #result > 0 then 
        return result 
    end
    
    success, result = pcall(function()
        local response = syn.request({Url = url, Method = "GET"})
        return response.Body
    end)
    if success and type(result) == "string" and #result > 0 then 
        return result 
    end
    
    success, result = pcall(function()
        local response = request({Url = url, Method = "GET"})
        return response.Body
    end)
    if success and type(result) == "string" and #result > 0 then 
        return result 
    end
    
    success, result = pcall(function()
        local response = http.request({Url = url, Method = "GET"})
        return response.Body
    end)
    if success and type(result) == "string" and #result > 0 then 
        return result 
    end
    
    success, result = pcall(function()
        local response = http_request({Url = url, Method = "GET"})
        return response.Body
    end)
    if success and type(result) == "string" and #result > 0 then 
        return result 
    end
    
    return nil
end

-----------------------------------------------------------------------
-- 7. MAIN SCRIPT EXECUTION
-----------------------------------------------------------------------

local function main()
    --[[
        INSTANCE CHECK
    ]]
    if _G.TeleportState.IsRunning then
        print("Script already running, waiting...")
        local waitCount = 0
        repeat 
            task.wait(0.5)
            waitCount = waitCount + 1
            if waitCount > 60 then
                print("Force starting script...")
                _G.TeleportState.IsRunning = false
                break
            end
        until not _G.TeleportState.IsRunning
    end
    
    _G.TeleportState.IsRunning = true
    _G.TeleportState.Initialized = true
    _G.TeleportState.ExecutionAttempts = 0
    _G.TeleportState.LastHeartbeat = os.time()
    _G.TeleportState.ExecutionVerified = true
    
    antiAFK()
    
    --[[
        PLAYER SETUP
    ]]
    local plr = v_QpZ.LocalPlayer
    if not plr then
        print("Waiting for LocalPlayer...")
        local waitCount = 0
        repeat 
            task.wait(0.1)
            plr = v_QpZ.LocalPlayer
            waitCount = waitCount + 1
            if waitCount > 50 then
                print("Failed to get LocalPlayer, exiting...")
                _G.TeleportState.IsRunning = false
                _G.TeleportState.Initialized = false
                return
            end
        until plr
    end
    
    --[[
        CHARACTER LOADING
    ]]
    local function waitForCharacter()
        local attempts = 0
        local maxAttempts = 40
        
        while attempts < maxAttempts do
            attempts = attempts + 1
            
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local humanoid = plr.Character:FindFirstChildWhichIsA("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    return true
                end
            end
            
            if not plr.Character or not plr.Character:FindFirstChildWhichIsA("Humanoid") 
                or plr.Character:FindFirstChildWhichIsA("Humanoid").Health <= 0 then
                print("Character dead or missing, waiting for respawn...")
                local respawnSuccess, _ = pcall(function()
                    plr.CharacterAdded:Wait()
                end)
                if not respawnSuccess then
                    task.wait(1)
                end
            end
            
            task.wait(0.5)
            _G.TeleportState.LastHeartbeat = os.time()
        end
        
        print("Timeout waiting for character")
        return false
    end
    
    if not waitForCharacter() then
        print("Failed to load character, will retry...")
        _G.TeleportState.IsRunning = false
        _G.TeleportState.Initialized = false
        return
    end
    
    if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then
        print("Character failed to load, exiting...")
        _G.TeleportState.IsRunning = false
        _G.TeleportState.Initialized = false
        return
    end
    
    --[[
        UI CLEANUP
    ]]
    pcall(function()
        local title = plr:FindFirstChild("PlayerGui") and plr.PlayerGui:FindFirstChild("Title")
        if title then 
            title:Destroy() 
        end
    end)
    
    --[[
        REMOTE TRIGGER
    ]]
    pcall(function()
        local remote = v_Wne:FindFirstChild("Remote")
        if remote then
            local spawnChar = remote:FindFirstChild("SpawnChar")
            if spawnChar then 
                spawnChar:FireServer()
            end
        end
    end)
    
    --[[
        CAMERA SETUP
    ]]
    pcall(function()
        if workspace.CurrentCamera then 
            workspace.CurrentCamera:Destroy() 
        end
    end)
    
    task.wait(0.5)
    _G.TeleportState.LastHeartbeat = os.time()
    
    if not plr.Character or not plr.Character:FindFirstChildWhichIsA("Humanoid") then
        print("Character lost after camera setup, waiting for respawn...")
        pcall(function()
            plr.CharacterAdded:Wait()
        end)
        task.wait(0.5)
    end
    
    pcall(function()
        local humanoid = plr.Character and plr.Character:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            workspace.CurrentCamera.CameraSubject = humanoid
            workspace.CurrentCamera.CameraType = "Custom"
        end
    end)
    
    pcall(function()
        plr.CameraMinZoomDistance = 0.5
        plr.CameraMaxZoomDistance = 400
        plr.CameraMode = "Classic"
    end)
    
    pcall(function()
        local head = plr.Character and plr.Character:FindFirstChild("Head")
        if head then 
            head.Anchored = false 
        end
    end)
    
    --[[
        CONFIGURATION
    ]]
    local n_Gxb = 120
    local n_Vcs = 0.06
    local n_Iuw = 40
    local n_Ptl = 5
    local n_Zmq2 = 50
    local n_Tmo = 60
    
    local id_Plc = game.PlaceId
    local id_Job = game.JobId
    
    --[[
        CHAT MESSAGES
    ]]
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
    
    --[[
        CHAT KEEPER
    ]]
    task.spawn(function()
        while task.wait(0.5) do
            pcall(function()
                if b_Oek then
                    v_Sgi:SetCore("ChatActive", true)
                else
                    local chatConfig = v_Rtd:FindFirstChild("ChatWindowConfiguration")
                    if chatConfig then
                        chatConfig.Enabled = true
                    end
                end
                _G.TeleportState.LastHeartbeat = os.time()
            end)
        end
    end)
    
    --[[
        SEND CHAT MESSAGE
    ]]
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
    
    --[[
        SERVER HOP FUNCTION
    ]]
    local function f_Sho()
        if _G.TeleportState.TeleportRetries >= _G.TeleportState.MaxRetries then
            _G.TeleportState.TeleportRetries = 0
            _G.TeleportState.TeleportCheck = false
            return false
        end
        
        local s_Req = httpRequest("https://games.roblox.com/v1/games/" .. id_Plc .. "/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true")
        if not s_Req then 
            _G.TeleportState.TeleportRetries = _G.TeleportState.TeleportRetries + 1
            return false 
        end
        
        local ok_Bod, t_Bod = pcall(function() 
            return v_Hts:JSONDecode(s_Req) 
        end)
        if not ok_Bod or not t_Bod or not t_Bod.data then 
            _G.TeleportState.TeleportRetries = _G.TeleportState.TeleportRetries + 1
            return false 
        end
        
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
            _G.TeleportState.TeleportRetries = 0
            _G.TeleportState.ServerHopTimer = true
            _G.TeleportState.ScriptFinished = true
            _G.TeleportState.IsRunning = false
            
            local teleportSuccess, teleportErr = pcall(function()
                v_Tps:TeleportToPlaceInstance(id_Plc, t_Srv[math.random(1, #t_Srv)], plr)
            end)
            
            if not teleportSuccess then
                print("Teleport failed: " .. tostring(teleportErr))
                _G.TeleportState.TeleportRetries = _G.TeleportState.TeleportRetries + 1
                return false
            end
            return true
        end
        
        _G.TeleportState.TeleportRetries = _G.TeleportState.TeleportRetries + 1
        return false
    end
    
    --[[
        FORCE SERVER HOP
    ]]
    local function f_ForceHop()
        if not _G.TeleportState.ServerHopTimer and not _G.TeleportState.ScriptFinished then
            print("Forcing server hop...")
            _G.TeleportState.ScriptFinished = true
            _G.TeleportState.ServerHopTimer = true
            _G.TeleportState.IsRunning = false
            return f_Sho()
        end
        return true
    end
    
    --[[
        TIMERS
    ]]
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
    
    task.spawn(function()
        task.wait(600)
        if not _G.TeleportState.ServerHopTimer and not _G.TeleportState.ScriptFinished then
            print("10 MINUTES PASSED - FORCE HOPPING FALLBACK!")
            _G.TeleportState.ServerHopTimer = true
            _G.TeleportState.ScriptFinished = true
            _G.TeleportState.IsRunning = false
            
            local success = f_Sho()
            if not success then
                local servers = httpRequest("https://games.roblox.com/v1/games/" .. id_Plc .. "/servers/Public?sortOrder=Desc&limit=100")
                if servers then
                    local decoded = v_Hts:JSONDecode(servers)
                    if decoded and decoded.data and #decoded.data > 0 then
                        for _, server in ipairs(decoded.data) do
                            if server and server.id and server.id ~= id_Job then
                                if not server.playing or server.playing < (server.maxPlayers or 100) then
                                    pcall(function()
                                        v_Tps:TeleportToPlaceInstance(id_Plc, server.id, plr)
                                    end)
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
    
    --[[
        TELEPORT EVENT HANDLERS
    ]]
    local teleportFailedConnection = v_Tps.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
        _G.TeleportState.TeleportRetries = _G.TeleportState.TeleportRetries + 1
        
        if _G.TeleportState.TeleportRetries < _G.TeleportState.MaxRetries then
            task.wait(2)
            f_Sho()
        else
            _G.TeleportState.TeleportRetries = 0
            _G.TeleportState.TeleportCheck = false
            _G.TeleportState.ServerHopTimer = false
            _G.TeleportState.ScriptFinished = false
            _G.TeleportState.IsRunning = false
        end
    end)
    
    local errorMessageConnection = v_Gui.ErrorMessageChanged:Connect(function(message)
        if message and (string.match(string.lower(message), "server is full") or string.match(string.lower(message), "another server")) then
            _G.TeleportState.TeleportRetries = _G.TeleportState.TeleportRetries + 1
            
            if _G.TeleportState.TeleportRetries < _G.TeleportState.MaxRetries then
                task.wait(2)
                f_Sho()
            else
                _G.TeleportState.TeleportRetries = 0
                _G.TeleportState.TeleportCheck = false
                _G.TeleportState.ServerHopTimer = false
                _G.TeleportState.ScriptFinished = false
                _G.TeleportState.IsRunning = false
            end
        end
    end)
    
    --[[
        MOVEMENT FUNCTIONS
    ]]
    local function f_Hbv(p) 
        if p and p.Character then
            return p.Character:FindFirstChild("HumanoidRootPart") 
        end
        return nil
    end
    
    local function f_Lzt() 
        return f_Hbv(plr) 
    end
    
    local function f_Mqe(pos)
        local hrp = f_Lzt()
        if not hrp then return end
        pcall(function()
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            hrp.CFrame = CFrame.new(pos)
        end)
        task.wait(n_Vcs)
        _G.TeleportState.LastHeartbeat = os.time()
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
    
    local function f_Wpy(target, duration)
        if t_Fjd and #t_Fjd > 0 then 
            f_Nra(t_Fjd[math.random(#t_Fjd)]) 
        end
        
        local elapsed, angle = 0, 0
        
        while elapsed < duration do
            local dt = v_Lmk.Heartbeat:Wait()
            elapsed = elapsed + dt
            angle = angle + 3 * dt
            _G.TeleportState.LastHeartbeat = os.time()
            
            if not target or not target.Parent then 
                break 
            end
            
            local myHrp = f_Lzt() 
            local tgtHrp = f_Hbv(target)
            
            if myHrp and tgtHrp then
                pcall(function()
                    local cen = tgtHrp.Position
                    myHrp.AssemblyLinearVelocity = Vector3.zero
                    myHrp.AssemblyAngularVelocity = Vector3.zero
                    local off = Vector3.new(math.cos(angle)*5, 0, math.sin(angle)*5)
                    myHrp.CFrame = CFrame.new(cen+off, cen)
                end)
            else 
                break 
            end
        end
    end
    
    local function f_Kxs(visited)
        local t = {}
        local players = v_QpZ:GetPlayers()
        for i = 1, #players do
            local p = players[i]
            if p ~= plr and not visited[p] and f_Hbv(p) then
                table.insert(t, p)
            end
        end
        _G.TeleportState.LastHeartbeat = os.time()
        return t
    end
    
    --[[
        MAIN LOOP
    ]]
    local function f_Ryn()
        local hrp = f_Lzt()
        if not hrp then
            print("Waiting for HumanoidRootPart...")
            local attempts = 0
            repeat 
                task.wait(0.5)
                hrp = f_Lzt()
                attempts = attempts + 1
                _G.TeleportState.LastHeartbeat = os.time()
                if attempts > 30 then
                    print("Timeout waiting for HumanoidRootPart, force hopping...")
                    f_ForceHop()
                    return
                end
            until hrp
        end
        
        local startHrp = hrp
        if not startHrp then 
            print("Failed to get HumanoidRootPart, force hopping...")
            f_ForceHop()
            return 
        end
        
        local origin = startHrp.Position
        local total = #v_QpZ:GetPlayers() - 1
        local visited = {}
        local found = 0
        local lastFound = os.clock()
        
        for _, p in ipairs(f_Kxs(visited)) do
            visited[p] = true
            found = found + 1
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
                _G.TeleportState.LastHeartbeat = os.time()
                
                local foundPlayers = f_Kxs(visited)
                for _, p in ipairs(foundPlayers) do
                    visited[p] = true
                    found = found + 1
                    f_Wpy(p, n_Ptl)
                    lastFound = os.clock()
                    
                    local curHrp = f_Lzt()
                    if curHrp then 
                        origin = curHrp.Position 
                    end
                    
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
    
    --[[
        EXECUTE MAIN LOOP
    ]]
    local success, err = pcall(function()
        f_Ryn()
    end)
    
    if not success then
        print("Script error: " .. tostring(err))
        task.wait(2)
        f_ForceHop()
    end
    
    pcall(function()
        teleportFailedConnection:Disconnect()
        errorMessageConnection:Disconnect()
    end)
    
    _G.TeleportState.IsRunning = false
    _G.TeleportState.Initialized = false
end

-----------------------------------------------------------------------
-- 8. START SCRIPT
-----------------------------------------------------------------------

local mainSuccess, mainErr = pcall(main)

if not mainSuccess then
    print("Fatal error: " .. tostring(mainErr))
    _G.TeleportState.IsRunning = false
    _G.TeleportState.TeleportCheck = false
    _G.TeleportState.Initialized = false
    
    -- Attempt recovery from fatal error
    task.wait(5)
    print("Attempting to recover from fatal error...")
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Hawnzs/gv/main/script.lua", true))()
    end)
end
