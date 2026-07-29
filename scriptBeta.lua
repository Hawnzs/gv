-- ULTRA-HIGH-END "AURA" THEMED TOP-RIGHT WIDGET ("Greenville Services")
task.spawn(function()
    pcall(function()
        local playerGui = plr:WaitForChild("PlayerGui", 10)
        if not playerGui then return end

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "GreenvilleServicesWidget"
        screenGui.IgnoreGuiInset = true
        screenGui.DisplayOrder = 99999
        screenGui.Parent = playerGui

        -- Main Container (Top Right)
        local container = Instance.new("Frame")
        container.Name = "WidgetContainer"
        container.Size = UDim2.new(0, 230, 0, 50)
        container.Position = UDim2.new(1, -25, 0, 25)
        container.AnchorPoint = Vector2.new(1, 0)
        container.BackgroundColor3 = Color3.fromRGB(8, 12, 10)
        container.BackgroundTransparency = 1
        container.Parent = screenGui

        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(0, 12)
        uiCorner.Parent = container

        -- Outer Glow / Aura Frame Layer
        local auraGlow = Instance.new("Frame")
        auraGlow.Name = "AuraGlow"
        auraGlow.Size = UDim2.new(1, 8, 1, 8)
        auraGlow.Position = UDim2.new(0, -4, 0, -4)
        auraGlow.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
        auraGlow.BackgroundTransparency = 1
        auraGlow.ZIndex = container.ZIndex - 1
        auraGlow.Parent = container

        local glowCorner = Instance.new("UICorner")
        glowCorner.CornerRadius = UDim.new(0, 15)
        glowCorner.Parent = auraGlow

        -- Dynamic Gradient Border Stroke
        local containerStroke = Instance.new("UIStroke")
        containerStroke.Color = Color3.fromRGB(0, 255, 170)
        containerStroke.Thickness = 1.8
        containerStroke.Transparency = 1
        containerStroke.Parent = container

        local strokeGradient = Instance.new("UIGradient")
        strokeGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 170)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 255, 220)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 180, 120))
        })
        strokeGradient.Parent = containerStroke

        -- Glowing Pulsing Aura Core Dot
        local statusDot = Instance.new("Frame")
        statusDot.Name = "StatusDot"
        statusDot.Size = UDim2.new(0, 10, 0, 10)
        statusDot.Position = UDim2.new(0, 18, 0.5, -5)
        statusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
        statusDot.BackgroundTransparency = 1
        statusDot.Parent = container

        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = statusDot

        -- Soft Backlight behind the dot
        local dotGlow = Instance.new("Frame")
        dotGlow.Size = UDim2.new(0, 20, 0, 20)
        dotGlow.Position = UDim2.new(0, 13, 0.5, -10)
        dotGlow.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
        dotGlow.BackgroundTransparency = 1
        dotGlow.ZIndex = statusDot.ZIndex - 1
        dotGlow.Parent = container

        local dotGlowCorner = Instance.new("UICorner")
        dotGlowCorner.CornerRadius = UDim.new(1, 0)
        dotGlowCorner.Parent = dotGlow

        -- High-End Typography (Clean, Modern, Sharp)
        local textLabel = Instance.new("TextLabel")
        textLabel.Name = "WidgetText"
        textLabel.Size = UDim2.new(1, -45, 1, 0)
        textLabel.Position = UDim2.new(0, 38, 0, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = "Greenville Services"
        textLabel.TextColor3 = Color3.fromRGB(240, 255, 252)
        textLabel.TextSize = 16
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.TextTransparency = 1
        textLabel.Parent = container

        -- Smooth Cinematic Fade In
        local fadeInInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

        TweenService:Create(container, fadeInInfo, {BackgroundTransparency = 0.2}):Play()
        TweenService:Create(auraGlow, fadeInInfo, {BackgroundTransparency = 0.85}):Play()
        TweenService:Create(containerStroke, fadeInInfo, {Transparency = 0.15}):Play()
        TweenService:Create(textLabel, fadeInInfo, {TextTransparency = 0}):Play()
        TweenService:Create(statusDot, fadeInInfo, {BackgroundTransparency = 0}):Play()
        TweenService:Create(dotGlow, fadeInInfo, {BackgroundTransparency = 0.6}):Play()

        -- Infinite Aura Pulse Loop (Breathing Glow Effect)
        task.spawn(function()
            while screenGui.Parent do
                -- Breath In (Deep Aura Glow)
                TweenService:Create(auraGlow, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.6, Size = UDim2.new(1, 14, 1, 14), Position = UDim2.new(0, -7, 0, -7)}):Play()
                TweenService:Create(dotGlow, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.3, Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(0, 10, 0.5, -13)}):Play()
                TweenService:Create(statusDot, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.2}):Play()
                task.wait(1.4)

                -- Breath Out
                TweenService:Create(auraGlow, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.88, Size = UDim2.new(1, 8, 1, 8), Position = UDim2.new(0, -4, 0, -4)}):Play()
                TweenService:Create(dotGlow, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.75, Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0, 14, 0.5, -9)}):Play()
                TweenService:Create(statusDot, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0}):Play()
                task.wait(1.4)
            end
        end)

        -- Seamless Border Gradient Rotation / Shimmer Loop
        task.spawn(function()
            local rotation = 0
            while screenGui.Parent do
                rotation = (rotation + 2) % 360
                strokeGradient.Rotation = rotation
                task.wait(0.05)
            end
        end)
    end)
end)
