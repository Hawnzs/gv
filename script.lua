-- ================= CONFIGURATION =================
_G.DiscordWebhook = "https://discord.com/api/webhooks/1532265932628561981/Pt0UCo-rtA9xGJ2HbQkUuXTwlZ9_6eAR5crHWPmF5muuhRlw8beBeE0V1N-zlgtLapgd"
-- ================================================

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

if type(_G.TeleportState) ~= "table" then
    _G.TeleportState = {
        TeleportCheck = false,
        TeleportRetries = 0,
        MaxRetries = 3,
        ServerHopTimer = false,
        ScriptFinished = false,
        IsRunning = false
    }
end

local v_QpZ = game:GetService("Players")
local v_Lmk = game:GetService("RunService")
local v_Wne = game:GetService("ReplicatedStorage")
local v_Rtd = game:GetService("TextChatService")
local v_Tps = game:GetService("TeleportService")
local v_Hts = game:GetService("HttpService")
local v_Gui = game:GetService("GuiService")
local v_Sgi = game:GetService("StarterGui")
local v_Stats = game:GetService("Stats")
local v_Lighting = game:GetService("Lighting")

local plr = v_QpZ.LocalPlayer
while not plr do task.wait(0.1); plr = v_QpZ.LocalPlayer end

-- Initial random stagger to prevent multi-account collision on start
task.wait(math.random(1, 4))

-- ================= FPS BOOST & MEMORY MANAGEMENT =================
task.spawn(function()
    pcall(function()
        v_Lighting.GlobalShadows = false
        v_Lighting.FogEnd = 9e9
        for _, v in ipairs(v_Lighting:GetChildren()) do
            if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Sky") then
                v:Destroy()
            end
        end

        local function cleanInstance(parent)
            for _, obj in ipairs(parent:GetDescendants()) do
                if obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") or obj:IsA("Trail") or obj:IsA("Beam") then
                    obj:Destroy()
                elseif obj:IsA("BasePart") then
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.Reflectance = 0
                end
            end
        end

        cleanInstance(workspace)

        workspace.DescendantAdded:Connect(function(obj)
            pcall(function()
                if obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") or obj:IsA("Trail") or obj:IsA("Beam") then
                    obj:Destroy()
                elseif obj:IsA("BasePart") then
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.Reflectance = 0
                end
            end)
        end)
    end)
end)

-- Periodic Garbage Collection to prevent RAM bloat on multi-account setups
task.spawn(function()
    while task.wait(300) do
        pcall(function()
            collectgarbage("collect")
        end)
    end
end)
-- =================================================================

-- ================= FORCED CHAT UI LOADER =================
task.spawn(function()
    pcall(function()
        v_Sgi:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
        
        pcall(function()
            v_Sgi:SetCore("ChatActive", true)
            v_Sgi:SetCore("ChatMakeSystemMessage", {
                Text = "[Greenville Services] FPS Boost & Chat Loaded Successfully.",
                Color = Color3.fromRGB(80, 250, 123),
            })
        end)

        local chatWindowConfig = v_Rtd:FindFirstChild("ChatWindowConfiguration")
        if chatWindowConfig then chatWindowConfig.Enabled = true end

        local chatInputBarConfig = v_Rtd:FindFirstChild("ChatInputBarConfiguration")
        if chatInputBarConfig then chatInputBarConfig.Enabled = true end

        if v_Rtd.ChatVersion == Enum.ChatVersion.TextChatService then
            local generalChannel = v_Rtd.TextChannels:FindFirstChild("RBXGeneral")
            if generalChannel then
                generalChannel:DisplaySystemMessage("<font color=\"#50fa7b\">[Greenville Services] Chat connected.</font>")
            end
        end
    end)
end)
-- ========================================================

-- ================= STYLISH WIDGET CREATION =================
task.spawn(function()
    pcall(function()
        local playerGui = plr:WaitForChild("PlayerGui", 10)
        if not playerGui then return end

        if playerGui:FindFirstChild("GreenvilleServicesWidget") then
            playerGui.GreenvilleServicesWidget:Destroy()
        end

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "GreenvilleServicesWidget"
        screenGui.ResetOnSpawn = false
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui.Parent = playerGui

        local frame = Instance.new("Frame")
        frame.Name = "MainFrame"
        frame.Size = UDim2.new(0, 180, 0, 36)
        frame.Position = UDim2.new(1, -195, 0, 15)
        frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
        frame.BorderSizePixel = 0
        frame.Parent = screenGui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = frame

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(45, 45, 55)
        stroke.Thickness = 1.5
        stroke.Parent = frame

        local dot = Instance.new("Frame")
        dot.Name = "StatusDot"
        dot.Size = UDim2.new(0, 8, 0, 8)
        dot.Position = UDim2.new(0, 12, 0.5, -4)
        dot.BackgroundColor3 = Color3.fromRGB(80, 250, 123)
        dot.BorderSizePixel = 0
        dot.Parent = frame

        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = dot

        local textLabel = Instance.new("TextLabel")
        textLabel.Name = "TitleText"
        textLabel.Size = UDim2.new(1, -30, 1, 0)
        textLabel.Position = UDim2.new(0, 26, 0, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Font = Enum.Font.GothamBold
        textLabel.Text = "greenville services"
        textLabel.TextColor3 = Color3.fromRGB(235, 235, 245)
        textLabel.TextSize = 12
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.Parent = frame
    end)
end)
-- ============================================================

local function sendWebhook(title, description, color)
    if not _G.DiscordWebhook or _G.DiscordWebhook == "YOUR_DISCORD_WEBHOOK_URL_HERE" then return end
    
    task.spawn(function()
        pcall(function()
            local data = {
                ["embeds"] = {{
                    ["title"] = title,
                    ["description"] = description,
                    ["color"] = color or 3447003,
                    ["footer"] = {
                        ["text"] = "Player: " .. plr.Name .. " | ID: " .. tostring(plr.UserId)
                    },
                    ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
                }}
            }
            local encodedData = v_Hts:JSONEncode(data)
            
            local reqFunc = syn and syn.request or http_request or request
            if reqFunc then
                reqFunc({
                    Url = _G.DiscordWebhook,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = encodedData
                })
            end
        end)
    end)
end

sendWebhook("🚀 Script Started", "Player **" .. plr.Name .. "** has started running the script with optimized multi-account handling.\nPlace ID: `" .. game.PlaceId .. "`", 65280)

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
    repeat task.wait(1) until not _G.TeleportState.IsRunning
end
_G.TeleportState.IsRunning = true

game.Players.LocalPlayer.OnTeleport:Connect(function(State)
    if State == Enum.TeleportState.InProgress then
        if _G.KeepInfYield and not _G.TeleportState.TeleportCheck and queueteleport then
            _G.TeleportState.TeleportCheck = true
            _G.TeleportState.TeleportRetries = 0
            local scriptUrl = "https://raw.githubusercontent.com/Hawnzs/gv/main/script.lua"

            local currentChats = type(_G.t_Fjd) == "table" and _G.t_Fjd or {"/gvse", "broke? /gvse", "slow cars? /gvse", "want to larp? /gvse"}
            local encodedChats = game:GetService("HttpService"):JSONEncode(currentChats)

            local payload = string.format([[
                _G.DiscordWebhook = "%s"
                if type(_G.TeleportState) ~= "table" then
                    _G.TeleportState = {TeleportCheck = false, TeleportRetries = 0, MaxRetries = 3, ServerHopTimer = false, ScriptFinished = false, IsRunning = false}
                else
                    _G.TeleportState.TeleportCheck = false
                    _G.TeleportState.TeleportRetries = 0
                    _G.TeleportState.ServerHopTimer = false
                    _G.TeleportState.ScriptFinished = false
                    _G.TeleportState.IsRunning = false
                end
                
                task.wait(3)
                
                task.delay(2, function()
                    _G.t_Fjd = game:GetService("HttpService"):JSONDecode([=[%s]=])
                    loadstring(game:HttpGet('%s', true))()
                end)
            ]], _G.DiscordWebhook, encodedChats, scriptUrl)

            queueteleport(payload)
        end
    elseif State == Enum.TeleportState.Failed then
        _G.TeleportState.TeleportCheck = false
    end
end)

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
        "want to larp? /gvse",
        "slow cars? /gvse",
        "broke? /gvse",
        "glv3away in /gvse"
    }
end
local t_Fjd = _G.t_Fjd

local b_Oek = v_Rtd.ChatVersion == Enum.ChatVersion.LegacyChatService

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if b_Oek then
                v_Sgi:SetCore("ChatActive", true)
            else
                local chatConfig = v_Rtd:FindFirstChild("ChatWindowConfiguration")
                if chatConfig then chatConfig.Enabled = true end
            end
        end)
    end
end)

local function f_Nra(s_Yui)
    s_Yui = tostring(s_Yui)
    if not b_Oek then
        v_Rtd.TextChannels.RBXGeneral:SendAsync(s_Yui)
    else
        v_Wne.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(s_Yui, "All")
    end
end

-- Enhanced server hopping with robust rate-limit catching and backoff logging
local function f_Sho()
    if _G.TeleportState.TeleportRetries >= _G.TeleportState.MaxRetries then
        _G.TeleportState.TeleportRetries = 0
        _G.TeleportState.TeleportCheck = false
        sendWebhook("⚠️ Rate Limit / Hop Limit", "Reached max retries or rate-limit block. Resetting hop state.", 16753920)
        return false
    end

    -- Staggered jitter delay per account
    task.wait(math.random(2, 6))

    local s_Req = httpRequest("https://games.roblox.com/v1/games/" .. id_Plc .. "/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true")
    if not s_Req then 
        _G.TeleportState.TeleportRetries = _G.TeleportState.TeleportRetries + 1
        local backoff = 3 * _G.TeleportState.TeleportRetries
        task.wait(backoff)
        return false 
    end

    local ok_Bod, t_Bod = pcall(function() return v_Hts:JSONDecode(s_Req) end)
    if not ok_Bod or not t_Bod or not t_Bod.data then 
        _G.TeleportState.TeleportRetries = _G.TeleportState.TeleportRetries + 1
        local backoff = 3 * _G.TeleportState.TeleportRetries
        task.wait(backoff)
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
        sendWebhook("🔄 Server Hopping", "Successfully found a new server. Teleporting now...", 16776960)
        v_Tps:TeleportToPlaceInstance(id_Plc, t_Srv[math.random(1, #t_Srv)], plr)
        return true
    end

    _G.TeleportState.TeleportRetries = _G.TeleportState.TeleportRetries + 1
    task.wait(3 * _G.TeleportState.TeleportRetries)
    return false
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
        sendWebhook("⚠️ Safety Net Triggered", "180-second timeout reached. Forcing a server hop.", 16753920)
        _G.TeleportState.ServerHopTimer = true
        _G.TeleportState.ScriptFinished = true
        _G.TeleportState.IsRunning = false
        f_Sho()
    end
end)

v_Tps.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
    _G.TeleportState.TeleportRetries = _G.TeleportState.TeleportRetries + 1

    if _G.TeleportState.TeleportRetries < _G.TeleportState.MaxRetries then
        task.wait(math.random(3, 5))
        f_Sho()
    else
        _G.TeleportState.TeleportRetries = 0
        _G.TeleportState.TeleportCheck = false
        _G.TeleportState.ServerHopTimer = false
        _G.TeleportState.ScriptFinished = false
        _G.TeleportState.IsRunning = false
    end
end)

v_Gui.ErrorMessageChanged:Connect(function(message)
    if message and (string.match(string.lower(message), "server is full") or string.match(string.lower(message), "another server")) then
        _G.TeleportState.TeleportRetries = _G.TeleportState.TeleportRetries + 1

        if _G.TeleportState.TeleportRetries < _G.TeleportState.MaxRetries then
            task.wait(math.random(3, 5))
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

local function f_Wpy(target, duration)
    if t_Fjd and #t_Fjd > 0 then f_Nra(t_Fjd[math.random(#t_Fjd)]) end
    local elapsed, angle = 0, 0
    while elapsed < duration do
        local dt = v_Lmk.Heartbeat:Wait()
        elapsed = elapsed + dt
        angle = angle + 3 * dt
        if not target or not target.Parent then break end
        
        local myHrp = f_Lzt() 
        local tgtHrp = f_Hbv(target)
        local tgtHumanoid = target.Character and target.Character:FindFirstChildWhichIsA("Humanoid")
        
        if myHrp and tgtHrp then
            pcall(function()
                local cen = tgtHrp.Position
                myHrp.AssemblyLinearVelocity = Vector3.zero
                myHrp.AssemblyAngularVelocity = Vector3.zero
                
                local baseRadius = 5
                if tgtHumanoid and tgtHumanoid.WalkSpeed > 16 then
                    local successPing, pingVal = pcall(function()
                        return v_Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
                    end)
                    local ping = (successPing and pingVal) or 0.1
                    
                    local extraSpeedBuffer = (tgtHumanoid.WalkSpeed - 16) * ping
                    baseRadius = math.max(2, baseRadius - extraSpeedBuffer)
                end
                
                local off = Vector3.new(math.cos(angle)*baseRadius, 0, math.sin(angle)*baseRadius)
                myHrp.CFrame = CFrame.new(cen+off, cen)
            end)
        else break end
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
    local found = 0
    local lastFound = os.clock()

    for _, p in ipairs(f_Kxs(visited)) do
        visited[p] = true; found = found + 1
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
    sendWebhook("❌ Script Error", "An error occurred:\n```" .. tostring(err) .. "```", 16711680)
end
