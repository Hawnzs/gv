--[[
=========================================================================
    GREENVILLE SERVICES — CINEMATIC INTRO SEQUENCE
    Place inside a LocalScript (StarterPlayerScripts / StarterGui)
=========================================================================
    LAYERS
      1. Vignette backdrop + cinematic letterbox bars
      2. Rotating volumetric light rays
      3. Radial core glow (pulsing)
      4. Expanding shockwave rings + screen shake
      5. Drifting particle field
      6. Per-character title with RGB chromatic ghosts
      7. Digital glitch burst
      8. Specular shimmer sweep (light bar + per-letter flash)
      9. Typewriter subtitle + expanding accent rule + loader bar
     10. Idle sine wave + float
     11. Explosive scatter exit
=========================================================================
]]

task.spawn(function()
pcall(function()

	local Players       = game:GetService("Players")
	local TweenService  = game:GetService("TweenService")
	local RunService    = game:GetService("RunService")

	local plr = Players.LocalPlayer or Players.PlayerAdded:Wait()
	local playerGui = plr:WaitForChild("PlayerGui", 10)
	if not playerGui then return end

	-- =====================================================================
	--  CONFIG — tweak everything here
	-- =====================================================================
	local CFG = {
		TITLE     = "Greenville Services",
		SUBTITLE  = "S Y S T E M S   O N L I N E",

		FONT      = "rbxasset://fonts/families/JosefinSans.json",

		ACCENT    = Color3.fromRGB(  0, 255, 170),   -- main glow
		ACCENT_2  = Color3.fromRGB(  0, 180, 255),   -- secondary glow
		GHOST_R   = Color3.fromRGB(255,  40, 120),   -- chromatic ghost A
		GHOST_B   = Color3.fromRGB(  0, 200, 255),   -- chromatic ghost B

		TEXT_SIZE = 66,      -- title glyph size (px)
		TRACKING  = 3,       -- extra px between letters
		SUB_SIZE  = 16,

		PARTICLES = 46,
		RAYS      = 10,
		RINGS     = 4,

		HOLD_TIME = 2.6,     -- how long it sits on screen before exiting
	}

	local FONT_BOLD  = Font.new(CFG.FONT, Enum.FontWeight.Bold,  Enum.FontStyle.Normal)
	local FONT_LIGHT = Font.new(CFG.FONT, Enum.FontWeight.Light, Enum.FontStyle.Normal)

	local rand = Random.new(os.clock() * 1000)
	local conns, running = {}, true
	local function bind(sig, fn) table.insert(conns, sig:Connect(fn)) end
	local function unbindAll()
		for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
		table.clear(conns)
	end

	-- small constructor helper
	local function new(class, props, parent)
		local inst = Instance.new(class)
		for k, v in pairs(props) do inst[k] = v end
		if parent then inst.Parent = parent end
		return inst
	end
	local function tw(obj, t, style, dir, goal, delayTime)
		local tween = TweenService:Create(obj, TweenInfo.new(t, style, dir, 0, false, delayTime or 0), goal)
		tween:Play()
		return tween
	end

	-- =====================================================================
	--  ROOT
	-- =====================================================================
	local gui = new("ScreenGui", {
		Name = "GVS_CinematicIntro",
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		DisplayOrder = 999999,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, playerGui)

	-- shake container (everything lives inside so shake moves the whole scene)
	local root = new("Frame", {
		Name = "Root",
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
	}, gui)

	-- ---------------------------------------------------------------- 1. BACKDROP
	local backdrop = new("Frame", {
		Size = UDim2.fromScale(1.2, 1.2),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(2, 8, 7),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 1,
	}, root)
	new("UIGradient", {
		Rotation = 90,
		Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 20, 16)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 6, 6)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 18, 20)),
		},
	}, backdrop)
	tw(backdrop, 0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {BackgroundTransparency = 0.12})

	-- cinematic letterbox bars
	local barTop = new("Frame", {
		Size = UDim2.new(1, 0, 0, 0), Position = UDim2.fromScale(0, 0),
		BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, ZIndex = 22,
	}, root)
	local barBot = new("Frame", {
		Size = UDim2.new(1, 0, 0, 0), Position = UDim2.fromScale(0, 1),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, ZIndex = 22,
	}, root)
	tw(barTop, 0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {Size = UDim2.new(1, 0, 0.07, 0)})
	tw(barBot, 0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {Size = UDim2.new(1, 0, 0.07, 0)})

	-- ------------------------------------------------------------- 2. LIGHT RAYS
	local rayHub = new("Frame", {
		Size = UDim2.fromOffset(0, 0),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1, ZIndex = 2,
	}, root)

	for i = 1, CFG.RAYS do
		local ray = new("Frame", {
			Size = UDim2.fromOffset(rand:NextInteger(3, 9), 2200),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Rotation = (360 / CFG.RAYS) * i + rand:NextNumber(-8, 8),
			BackgroundColor3 = (i % 2 == 0) and CFG.ACCENT or CFG.ACCENT_2,
			BackgroundTransparency = 1,
			BorderSizePixel = 0, ZIndex = 2,
		}, rayHub)
		new("UIGradient", {
			Rotation = 90,
			Transparency = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.42, 0.55),
				NumberSequenceKeypoint.new(0.5, 0.2),
				NumberSequenceKeypoint.new(0.58, 0.55),
				NumberSequenceKeypoint.new(1, 1),
			},
		}, ray)
		tw(ray, 1.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {BackgroundTransparency = 0.82}, 0.15)
	end

	-- ------------------------------------------------------------- 3. CORE GLOW
	-- faked radial falloff with stacked rounded frames (no external assets)
	local glowHub = new("Frame", {
		Size = UDim2.fromScale(1, 1), Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, ZIndex = 3,
	}, root)
	local glowLayers = {}
	for i = 1, 6 do
		local s = 120 + i * 130
		local g = new("Frame", {
			Size = UDim2.fromOffset(s * 2.4, s),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = CFG.ACCENT,
			BackgroundTransparency = 1,
			BorderSizePixel = 0, ZIndex = 3,
		}, glowHub)
		new("UICorner", {CornerRadius = UDim.new(1, 0)}, g)
		glowLayers[i] = {frame = g, base = 0.86 + (i * 0.02)}
		tw(g, 0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {BackgroundTransparency = glowLayers[i].base}, 0.1)
	end

	-- ------------------------------------------------------------ 4. SHOCKWAVES
	local function shockwave(delayTime, size, thick, color)
		task.delay(delayTime, function()
			if not running then return end
			local ring = new("Frame", {
				Size = UDim2.fromOffset(40, 40),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1, ZIndex = 4,
			}, root)
			new("UICorner", {CornerRadius = UDim.new(1, 0)}, ring)
			local stroke = new("UIStroke", {
				Color = color, Thickness = thick, Transparency = 0.05,
			}, ring)
			tw(ring, 1.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {Size = UDim2.fromOffset(size, size * 0.62)})
			tw(stroke, 1.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {Thickness = 0, Transparency = 1})
			task.delay(1.35, function() if ring then ring:Destroy() end end)
		end)
	end
	shockwave(0.10, 1500, 8, CFG.ACCENT)
	shockwave(0.22, 1100, 5, CFG.ACCENT_2)
	shockwave(0.36,  820, 3, Color3.new(1, 1, 1))
	shockwave(0.55, 1900, 4, CFG.ACCENT)

	-- ------------------------------------------------------------- 5. PARTICLES
	local particleHub = new("Frame", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 5,
	}, root)

	local function spawnParticle(instant)
		task.spawn(function()
			while running do
				local size = rand:NextInteger(2, 6)
				local p = new("Frame", {
					Size = UDim2.fromOffset(size, size),
					Position = UDim2.fromScale(rand:NextNumber(0, 1), rand:NextNumber(0.85, 1.15)),
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = (rand:NextNumber() > 0.35) and CFG.ACCENT or CFG.ACCENT_2,
					BackgroundTransparency = 1,
					BorderSizePixel = 0, ZIndex = 5,
				}, particleHub)
				new("UICorner", {CornerRadius = UDim.new(1, 0)}, p)

				local dur = rand:NextNumber(3.2, 7.0)
				local driftX = rand:NextNumber(-0.09, 0.09)
				tw(p, 0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {BackgroundTransparency = rand:NextNumber(0.15, 0.6)})
				tw(p, dur, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, {
					Position = p.Position + UDim2.fromScale(driftX, -rand:NextNumber(1.05, 1.4)),
				})
				tw(p, dur * 0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.In, {BackgroundTransparency = 1}, dur * 0.55)
				task.wait(dur)
				if p then p:Destroy() end
				if not running then break end
			end
		end)
	end
	for i = 1, CFG.PARTICLES do
		task.delay(rand:NextNumber(0, 2.2), function() if running then spawnParticle() end end)
	end

	-- ============================================================ 6. TITLE
	local titleHub = new("Frame", {
		Name = "TitleHub",
		Size = UDim2.fromOffset(10, CFG.TEXT_SIZE * 1.6),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1, ZIndex = 10,
	}, root)

	-- --- measure each glyph so we can lay letters out by hand ---
	local measureHub = new("Frame", {
		Size = UDim2.fromOffset(1, 1), BackgroundTransparency = 1,
		Visible = false,
	}, gui)

	local chars, measures = {}, {}
	for i = 1, #CFG.TITLE do
		local ch = CFG.TITLE:sub(i, i)
		chars[i] = ch
		if ch == " " then
			measures[i] = false
		else
			measures[i] = new("TextLabel", {
				Text = ch,
				FontFace = FONT_BOLD,
				TextSize = CFG.TEXT_SIZE,
				TextScaled = false,
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(0, 0),
			}, measureHub)
		end
	end
	task.wait() -- let AutomaticSize resolve
	task.wait()

	local widths, totalW = {}, 0
	for i = 1, #chars do
		local w
		if measures[i] then
			w = math.max(measures[i].AbsoluteSize.X, 4)
		else
			w = CFG.TEXT_SIZE * 0.30
		end
		widths[i] = w
		totalW += w + CFG.TRACKING
	end
	totalW -= CFG.TRACKING
	measureHub:Destroy()

	titleHub.Size = UDim2.fromOffset(totalW, CFG.TEXT_SIZE * 1.6)

	-- --- build letters ---
	local letters = {}
	local cursor = 0
	for i = 1, #chars do
		local ch, w = chars[i], widths[i]
		local slot = new("Frame", {
			Name = "L" .. i,
			Size = UDim2.fromOffset(w, CFG.TEXT_SIZE * 1.6),
			Position = UDim2.new(0, cursor + w / 2, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			ClipsDescendants = false,
			ZIndex = 10,
		}, titleHub)
		cursor += w + CFG.TRACKING

		if ch ~= " " then
			local function mk(color, z, trans)
				return new("TextLabel", {
					Size = UDim2.fromScale(1, 1),
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Text = ch,
					FontFace = FONT_BOLD,
					TextSize = 0,
					TextColor3 = color,
					TextTransparency = trans,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextYAlignment = Enum.TextYAlignment.Center,
					ZIndex = z,
				}, slot)
			end

			local ghostA = mk(CFG.GHOST_R, 9, 0.45)
			local ghostB = mk(CFG.GHOST_B, 9, 0.45)
			local main   = mk(Color3.new(1, 1, 1), 11, 1)

			local stroke = new("UIStroke", {
				Color = CFG.ACCENT, Thickness = 0, Transparency = 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
			}, main)

			ghostA.Position = UDim2.new(0.5, -26, 0.5, 6)
			ghostB.Position = UDim2.new(0.5,  26, 0.5, -6)

			letters[#letters + 1] = {
				slot = slot, main = main, a = ghostA, b = ghostB,
				stroke = stroke, index = #letters + 1,
			}
		end
	end

	-- --- staggered elastic entrance ---
	local N = #letters
	for i, L in ipairs(letters) do
		local d = 0.30 + (i - 1) * 0.035
		L.slot.Rotation = rand:NextNumber(-55, 55)

		tw(L.slot, 1.05, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {Rotation = 0}, d)

		for _, lbl in ipairs({L.main, L.a, L.b}) do
			tw(lbl, 0.95, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {TextSize = CFG.TEXT_SIZE}, d)
		end
		tw(L.main, 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {TextTransparency = 0}, d)
		tw(L.a, 0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {Position = UDim2.fromScale(0.5, 0.5), TextTransparency = 0.72}, d + 0.1)
		tw(L.b, 0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {Position = UDim2.fromScale(0.5, 0.5), TextTransparency = 0.72}, d + 0.1)
		tw(L.stroke, 0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {Thickness = 2.5, Transparency = 0.35}, d + 0.15)
	end

	-- ---------------------------------------------------------- 7. SCREEN SHAKE
	local shakePower = 0
	local function punch(p) shakePower = math.max(shakePower, p) end
	punch(14)
	task.delay(0.30, function() punch(9) end)

	bind(RunService.RenderStepped, function(dt)
		if not running then return end
		shakePower = math.max(0, shakePower - dt * 26)
		if shakePower > 0.05 then
			root.Position = UDim2.new(0.5, rand:NextNumber(-shakePower, shakePower), 0.5, rand:NextNumber(-shakePower, shakePower))
		else
			root.Position = UDim2.fromScale(0.5, 0.5)
		end
	end)

	-- ---------------------------------------------------- ROTATION + PULSE LOOP
	local t0 = os.clock()
	bind(RunService.RenderStepped, function()
		if not running then return end
		local t = os.clock() - t0
		rayHub.Rotation = t * 6
		for i, g in ipairs(glowLayers) do
			g.frame.BackgroundTransparency = g.base + math.sin(t * 1.6 + i * 0.5) * 0.035
		end
	end)

	-- ============================================================ 8. GLITCH BURST
	task.delay(1.05, function()
		if not running then return end
		punch(11)
		local glitchEnd = os.clock() + 0.42
		while running and os.clock() < glitchEnd do
			for _, L in ipairs(letters) do
				if rand:NextNumber() > 0.55 then
					local jx = rand:NextNumber(-16, 16)
					L.a.Position = UDim2.new(0.5, jx, 0.5, rand:NextNumber(-4, 4))
					L.b.Position = UDim2.new(0.5, -jx, 0.5, rand:NextNumber(-4, 4))
					L.main.Position = UDim2.new(0.5, rand:NextNumber(-6, 6), 0.5, 0)
					L.main.TextTransparency = (rand:NextNumber() > 0.85) and 0.75 or 0
				end
			end
			task.wait(0.035)
		end
		for _, L in ipairs(letters) do
			tw(L.a, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {Position = UDim2.fromScale(0.5, 0.5)})
			tw(L.b, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {Position = UDim2.fromScale(0.5, 0.5)})
			tw(L.main, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {Position = UDim2.fromScale(0.5, 0.5), TextTransparency = 0})
		end
	end)

	-- ========================================================= 9. SHIMMER SWEEP
	local sweep = new("Frame", {
		Size = UDim2.fromOffset(90, CFG.TEXT_SIZE * 3),
		Position = UDim2.new(0, -140, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Rotation = 14,
		ZIndex = 12,
	}, titleHub)
	new("UIGradient", {
		Transparency = NumberSequence.new{
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, 0.55),
			NumberSequenceKeypoint.new(1, 1),
		},
	}, sweep)

	local function doSweep()
		if not running then return end
		sweep.Position = UDim2.new(0, -140, 0.5, 0)
		sweep.BackgroundTransparency = 0
		tw(sweep, 0.85, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, {Position = UDim2.new(1, 140, 0.5, 0)})
		task.delay(0.85, function() sweep.BackgroundTransparency = 1 end)

		-- per-letter flash timed to the bar passing over it
		for i, L in ipairs(letters) do
			task.delay(0.07 + (i / math.max(N, 1)) * 0.72, function()
				if not running then return end
				L.main.TextColor3 = CFG.ACCENT
				L.stroke.Color = Color3.new(1, 1, 1)
				tw(L.stroke, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {Thickness = 5, Transparency = 0.1})
				task.delay(0.13, function()
					if not running then return end
					L.main.TextColor3 = Color3.new(1, 1, 1)
					L.stroke.Color = CFG.ACCENT
					tw(L.stroke, 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {Thickness = 2.5, Transparency = 0.35})
				end)
			end)
		end
	end
	task.delay(1.55, doSweep)
	task.delay(1.55 + CFG.HOLD_TIME * 0.55, doSweep)

	-- ================================================ 10. SUBTITLE / RULE / LOADER
	local underline = new("Frame", {
		Size = UDim2.fromOffset(0, 2),
		Position = UDim2.new(0.5, 0, 0.5, CFG.TEXT_SIZE * 0.92),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = CFG.ACCENT,
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0, ZIndex = 10,
	}, root)
	new("UIGradient", {
		Transparency = NumberSequence.new{
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, 0),
			NumberSequenceKeypoint.new(1, 1),
		},
	}, underline)
	tw(underline, 1.0, Enum.EasingStyle.Quint, Enum.EasingDirection.Out,
		{Size = UDim2.fromOffset(totalW + 90, 2)}, 0.95)

	local subtitle = new("TextLabel", {
		Size = UDim2.fromOffset(600, 26),
		Position = UDim2.new(0.5, 0, 0.5, CFG.TEXT_SIZE * 1.35),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Text = "",
		FontFace = FONT_LIGHT,
		TextSize = CFG.SUB_SIZE,
		TextColor3 = CFG.ACCENT,
		TextTransparency = 0.15,
		ZIndex = 10,
	}, root)

	task.delay(1.35, function()
		for i = 1, #CFG.SUBTITLE do
			if not running then return end
			subtitle.Text = CFG.SUBTITLE:sub(1, i)
			task.wait(0.022)
		end
	end)

	-- loader bar
	local loaderBG = new("Frame", {
		Size = UDim2.fromOffset(220, 3),
		Position = UDim2.new(0.5, 0, 0.5, CFG.TEXT_SIZE * 1.95),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.88,
		BorderSizePixel = 0, ZIndex = 10,
	}, root)
	new("UICorner", {CornerRadius = UDim.new(1, 0)}, loaderBG)
	local loaderFill = new("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = CFG.ACCENT,
		BorderSizePixel = 0, ZIndex = 11,
	}, loaderBG)
	new("UICorner", {CornerRadius = UDim.new(1, 0)}, loaderFill)
	new("UIGradient", {
		Color = ColorSequence.new(CFG.ACCENT_2, CFG.ACCENT),
	}, loaderFill)
	tw(loaderFill, CFG.HOLD_TIME + 0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut,
		{Size = UDim2.fromScale(1, 1)}, 1.4)

	-- ------------------------------------------------------------ SCANLINES
	local scan = new("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1, ZIndex = 15,
	}, root)
	for i = 0, 60 do
		new("Frame", {
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.fromScale(0, i / 60),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.9,
			BorderSizePixel = 0, ZIndex = 15,
		}, scan)
	end

	-- --------------------------------------------------- 11. IDLE WAVE + FLOAT
	task.delay(1.5, function()
		if not running then return end
		local w0 = os.clock()
		bind(RunService.RenderStepped, function()
			if not running then return end
			local t = os.clock() - w0
			for i, L in ipairs(letters) do
				local y = math.sin(t * 2.1 + i * 0.38) * 3.5
				L.main.Position = UDim2.new(0.5, 0, 0.5, y)
				L.a.Position    = UDim2.new(0.5, math.sin(t * 1.3 + i) * 1.2, 0.5, y)
				L.b.Position    = UDim2.new(0.5, -math.sin(t * 1.3 + i) * 1.2, 0.5, y)
			end
			titleHub.Position = UDim2.new(0.5, 0, 0.5, math.sin(t * 0.9) * 6)
		end)
	end)

	-- ================================================================ 12. EXIT
	task.delay(1.5 + CFG.HOLD_TIME, function()
		if not running then return end
		running = false
		unbindAll()
		punch(0)

		local OUT = TweenInfo.new(0.85, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

		-- letters scatter
		for i, L in ipairs(letters) do
			local ang = rand:NextNumber(0, math.pi * 2)
			local dist = rand:NextNumber(260, 620)
			local d = (i - 1) * 0.018
			TweenService:Create(L.slot, TweenInfo.new(0.9, Enum.EasingStyle.Back, Enum.EasingDirection.In, 0, false, d), {
				Position = L.slot.Position + UDim2.fromOffset(math.cos(ang) * dist, math.sin(ang) * dist),
				Rotation = rand:NextNumber(-160, 160),
			}):Play()
			for _, lbl in ipairs({L.main, L.a, L.b}) do
				TweenService:Create(lbl, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, d), {
					TextTransparency = 1, TextSize = CFG.TEXT_SIZE * 1.6,
				}):Play()
			end
			TweenService:Create(L.stroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, d), {
				Thickness = 0, Transparency = 1,
			}):Play()
		end

		-- everything else fades
		TweenService:Create(subtitle, OUT, {TextTransparency = 1}):Play()
		TweenService:Create(underline, OUT, {BackgroundTransparency = 1, Size = UDim2.fromOffset(0, 2)}):Play()
		TweenService:Create(loaderBG, OUT, {BackgroundTransparency = 1}):Play()
		TweenService:Create(loaderFill, OUT, {BackgroundTransparency = 1}):Play()
		TweenService:Create(backdrop, OUT, {BackgroundTransparency = 1}):Play()
		TweenService:Create(barTop, OUT, {Size = UDim2.new(1, 0, 0, 0)}):Play()
		TweenService:Create(barBot, OUT, {Size = UDim2.new(1, 0, 0, 0)}):Play()

		for _, obj in ipairs(rayHub:GetChildren()) do
			if obj:IsA("Frame") then TweenService:Create(obj, OUT, {BackgroundTransparency = 1}):Play() end
		end
		for _, g in ipairs(glowLayers) do
			TweenService:Create(g.frame, OUT, {BackgroundTransparency = 1}):Play()
		end
		for _, obj in ipairs(scan:GetChildren()) do
			if obj:IsA("Frame") then TweenService:Create(obj, OUT, {BackgroundTransparency = 1}):Play() end
		end
		for _, obj in ipairs(particleHub:GetChildren()) do
			if obj:IsA("Frame") then TweenService:Create(obj, OUT, {BackgroundTransparency = 1}):Play() end
		end

		task.delay(1.15, function()
			if gui then gui:Destroy() end
		end)
	end)

end)
end)
