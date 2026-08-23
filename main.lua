local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

local CONFIG_FILE = "FabaltaTool_Config.json"
local Config = {
    ToggleKey = "F12",
    AccentColor = {90, 160, 255}
}

local function loadConfig()
    if readfile and isfile and isfile(CONFIG_FILE) then
        pcall(function()
            local decoded = HttpService:JSONDecode(readfile(CONFIG_FILE))
            for k, v in pairs(decoded) do Config[k] = v end
        end)
    end
end

local function saveConfig()
    if writefile then
        pcall(function()
            writefile(CONFIG_FILE, HttpService:JSONEncode(Config))
        end)
    end
end

loadConfig()

local THEME = {
    Background = Color3.fromRGB(15, 17, 26),
    Accent = Color3.fromRGB(Config.AccentColor[1], Config.AccentColor[2], Config.AccentColor[3]),
    AccentInactive = Color3.fromRGB(45, 50, 70),
    TabActive = Color3.fromRGB(30, 35, 55),
    Text = Color3.fromRGB(240, 240, 255),
    TextSub = Color3.fromRGB(140, 145, 170),
    Border = Color3.fromRGB(120, 150, 220),
    FontBold = Enum.Font.GothamBold,
    FontRegular = Enum.Font.Gotham,
}

local accentElements = {}
local function registerAccent(instance, prop)
    table.insert(accentElements, {Instance = instance, Property = prop})
    instance[prop] = THEME.Accent
end

local function setAccentColor(col)
    THEME.Accent = col
    Config.AccentColor = {math.floor(col.R * 255), math.floor(col.G * 255), math.floor(col.B * 255)}
    saveConfig()
    for _, item in ipairs(accentElements) do
        if item.Instance and item.Instance.Parent then
            item.Instance[item.Property] = col
        end
    end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FabaltaTool"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local notifContainer = Instance.new("Frame")
notifContainer.Size = UDim2.new(0, 220, 1, -20)
notifContainer.Position = UDim2.new(1, -230, 0, 10)
notifContainer.BackgroundTransparency = 1
notifContainer.Parent = screenGui

local notifLayout = Instance.new("UIListLayout")
notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifLayout.Padding = UDim.new(0, 6)
notifLayout.Parent = notifContainer

local function notify(title, msg, duration)
    duration = duration or 3
    local toast = Instance.new("Frame")
    toast.Size = UDim2.new(1, 0, 0, 48)
    toast.BackgroundColor3 = THEME.Background
    toast.BorderSizePixel = 0
    toast.BackgroundTransparency = 0.1
    toast.Parent = notifContainer

    local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 8) corner.Parent = toast
    local stroke = Instance.new("UIStroke") stroke.Color = THEME.Border stroke.Transparency = 0.5 stroke.Parent = toast

    local tLabel = Instance.new("TextLabel")
    tLabel.Size = UDim2.new(1, -10, 0, 18)
    tLabel.Position = UDim2.new(0, 8, 0, 4)
    tLabel.BackgroundTransparency = 1
    tLabel.Text = title
    tLabel.TextColor3 = THEME.Accent
    tLabel.TextSize = 12
    tLabel.Font = THEME.FontBold
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.Parent = toast
    registerAccent(tLabel, "TextColor3")

    local mLabel = Instance.new("TextLabel")
    mLabel.Size = UDim2.new(1, -10, 0, 20)
    mLabel.Position = UDim2.new(0, 8, 0, 22)
    mLabel.BackgroundTransparency = 1
    mLabel.Text = msg
    mLabel.TextColor3 = THEME.Text
    mLabel.TextSize = 11
    mLabel.Font = THEME.FontRegular
    mLabel.TextXAlignment = Enum.TextXAlignment.Left
    mLabel.Parent = toast

    task.delay(duration, function()
        TweenService:Create(toast, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
        TweenService:Create(tLabel, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
        TweenService:Create(mLabel, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
        task.wait(0.3)
        toast:Destroy()
    end)
end

local function makeDraggable(dragHandle, targetFrame)
    local dragging, dragInput, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            TweenService:Create(targetFrame, TweenInfo.new(0.08, Enum.EasingStyle.Linear), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }):Play()
        end
    end)
end

local CORRECT_KEY = "7YLhpY0bzXe9AyO5obJa2AOPhFmeIsMQ8sEG8XgE9SEbRJIW2grBBqeCTSb5viIi9d"

local keyFrame = Instance.new("Frame")
keyFrame.Name = "KeyLock"
keyFrame.Size = UDim2.new(0, 360, 0, 180)
keyFrame.Position = UDim2.new(0.5, -180, 0.4, -90)
keyFrame.BackgroundColor3 = THEME.Background
keyFrame.BorderSizePixel = 0
keyFrame.Parent = screenGui

local kCorner = Instance.new("UICorner") kCorner.CornerRadius = UDim.new(0, 12) kCorner.Parent = keyFrame
local kBorder = Instance.new("UIStroke") kBorder.Thickness = 1.5 kBorder.Color = THEME.Border kBorder.Transparency = 0.5 kBorder.Parent = keyFrame

local keyTitle = Instance.new("TextLabel")
keyTitle.Size = UDim2.new(1, 0, 0, 40)
keyTitle.BackgroundTransparency = 1
keyTitle.Text = "🔐 Kulcs Hitelesítés Szükséges"
keyTitle.TextColor3 = THEME.Text
keyTitle.TextSize = 14
keyTitle.Font = THEME.FontBold
keyTitle.Parent = keyFrame

local keyInput = Instance.new("TextBox")
keyInput.Size = UDim2.new(0.85, 0, 0, 36)
keyInput.Position = UDim2.new(0.075, 0, 0.32, 0)
keyInput.BackgroundColor3 = THEME.AccentInactive
keyInput.BorderSizePixel = 0
keyInput.PlaceholderText = "Írd be a kulcsot..."
keyInput.Text = ""
keyInput.TextColor3 = THEME.Text
keyInput.PlaceholderColor3 = THEME.TextSub
keyInput.TextSize = 11
keyInput.Font = THEME.FontRegular
keyInput.ClearTextOnFocus = false
keyInput.Parent = keyFrame
local kiCorner = Instance.new("UICorner") kiCorner.CornerRadius = UDim.new(0, 6) kiCorner.Parent = keyInput

local submitKeyBtn = Instance.new("TextButton")
submitKeyBtn.Size = UDim2.new(0.85, 0, 0, 34)
submitKeyBtn.Position = UDim2.new(0.075, 0, 0.62, 0)
submitKeyBtn.BackgroundColor3 = THEME.Accent
submitKeyBtn.BorderSizePixel = 0
submitKeyBtn.Text = "Feloldás"
submitKeyBtn.TextColor3 = THEME.Text
submitKeyBtn.TextSize = 13
submitKeyBtn.Font = THEME.FontBold
submitKeyBtn.Parent = keyFrame
local skCorner = Instance.new("UICorner") skCorner.CornerRadius = UDim.new(0, 6) skCorner.Parent = submitKeyBtn
registerAccent(submitKeyBtn, "BackgroundColor3")

makeDraggable(keyTitle, keyFrame)

local panel = Instance.new("Frame")
panel.Name = "MainPanel"
panel.Size = UDim2.new(0, 370, 0, 540)
panel.Position = UDim2.new(0.05, 0, 0.1, 0)
panel.BackgroundColor3 = THEME.Background
panel.BackgroundTransparency = 0.15
panel.BorderSizePixel = 0
panel.ClipsDescendants = true
panel.Visible = false
panel.Parent = screenGui

local uiScale = Instance.new("UIScale") uiScale.Scale = 1 uiScale.Parent = panel
local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 14) corner.Parent = panel
local border = Instance.new("UIStroke") border.Thickness = 1.5 border.Color = THEME.Border border.Transparency = 0.6 border.Parent = panel

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 45)
header.BackgroundTransparency = 1
header.Parent = panel

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⚙️ Fabalta Tool v8.0"
titleLabel.TextColor3 = THEME.Text
titleLabel.TextSize = 16
titleLabel.Font = THEME.FontBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = header

local hideBtn = Instance.new("TextButton")
hideBtn.Size = UDim2.new(0, 26, 0, 26)
hideBtn.Position = UDim2.new(1, -36, 0.5, -13)
hideBtn.BackgroundColor3 = THEME.AccentInactive
hideBtn.BackgroundTransparency = 0.5
hideBtn.BorderSizePixel = 0
hideBtn.Text = "✕"
hideBtn.TextColor3 = THEME.Text
hideBtn.TextSize = 12
hideBtn.Font = THEME.FontBold
hideBtn.Parent = header
local hCorner = Instance.new("UICorner") hCorner.CornerRadius = UDim.new(0, 13) hCorner.Parent = hideBtn

makeDraggable(header, panel)

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -20, 0, 32)
tabBar.Position = UDim2.new(0, 10, 0, 45)
tabBar.BackgroundTransparency = 1
tabBar.Parent = panel

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 4)
tabLayout.Parent = tabBar

local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -20, 1, -115)
contentArea.Position = UDim2.new(0, 10, 0, 85)
contentArea.BackgroundTransparency = 1
contentArea.ClipsDescendants = true
contentArea.Parent = panel

local mainToggleKey = Enum.KeyCode[Config.ToggleKey] or Enum.KeyCode.F12
local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, 0, 0, 25)
footer.Position = UDim2.new(0, 0, 1, -25)
footer.BackgroundTransparency = 1
footer.Text = "Nyomd meg a [" .. mainToggleKey.Name .. "] gombot az elrejtéshez"
footer.TextColor3 = THEME.TextSub
footer.TextSize = 11
footer.Font = THEME.FontRegular
footer.Parent = panel

local isUnlocked = false
local function unlockSuite()
    isUnlocked = true
    keyFrame:Destroy()
    panel.Visible = true
    notify("Rendszer Feloldva", "Üdvözöl a Fabalta Tool v8.0!", 4)
end

submitKeyBtn.MouseButton1Click:Connect(function()
    if keyInput.Text == CORRECT_KEY then unlockSuite() else keyInput.Text = "" keyInput.PlaceholderText = "❌ Helytelen kulcs!" end
end)

local isVisible = true
local function setPanelVisibility(state)
    if not isUnlocked then return end
    isVisible = state
    if not state then
        TweenService:Create(uiScale, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In), { Scale = 0.001 }):Play()
        task.wait(0.2)
        panel.Visible = false
    else
        panel.Visible = true
        TweenService:Create(uiScale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
    end
end

hideBtn.MouseButton1Click:Connect(function() setPanelVisibility(false) end)
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == mainToggleKey then setPanelVisibility(not isVisible) end
end)

local tabs = {}
local currentTab = nil

local function createTab(name)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0.19, 0, 1, 0)
    tabBtn.BackgroundColor3 = THEME.AccentInactive
    tabBtn.BorderSizePixel = 0
    tabBtn.Text = name
    tabBtn.TextColor3 = THEME.Text
    tabBtn.TextSize = 11
    tabBtn.Font = THEME.FontBold
    tabBtn.Parent = tabBar
    
    local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 6) c.Parent = tabBtn

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 5
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ScrollingDirection = Enum.ScrollingDirection.Y
    scroll.Active = true
    registerAccent(scroll, "ScrollBarImageColor3")
    scroll.Visible = false
    scroll.Parent = contentArea

    local list = Instance.new("UIListLayout")
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 8)
    list.Parent = scroll

    local pad = Instance.new("UIPadding")
    pad.PaddingRight = UDim.new(0, 6)
    pad.PaddingTop = UDim.new(0, 4)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.Parent = scroll

    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do t.Btn.BackgroundColor3 = THEME.AccentInactive t.Page.Visible = false end
        tabBtn.BackgroundColor3 = THEME.TabActive
        scroll.Visible = true
        currentTab = scroll
    end)

    tabs[name] = { Btn = tabBtn, Page = scroll }
    if not currentTab then tabBtn.BackgroundColor3 = THEME.TabActive scroll.Visible = true currentTab = scroll end
    return scroll
end

local function createToggle(parentPage, configKey, labelText, defaultOn, callback)
    local savedState = Config[configKey]
    if savedState == nil then savedState = defaultOn end

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 38)
    container.BackgroundTransparency = 1
    container.Parent = parentPage

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = THEME.Text
    label.TextSize = 13
    label.Font = THEME.FontRegular
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local track = Instance.new("TextButton")
    track.Size = UDim2.new(0, 44, 0, 22)
    track.Position = UDim2.new(1, -44, 0.5, -11)
    track.BackgroundColor3 = savedState and THEME.Accent or THEME.AccentInactive
    track.BorderSizePixel = 0
    track.Text = ""
    track.AutoButtonColor = false
    track.Parent = container
    if savedState then registerAccent(track, "BackgroundColor3") end

    local trackCorner = Instance.new("UICorner") trackCorner.CornerRadius = UDim.new(1, 0) trackCorner.Parent = track

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new(savedState and 1 or 0, savedState and -20 or 2, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = track

    local knobCorner = Instance.new("UICorner") knobCorner.CornerRadius = UDim.new(1, 0) knobCorner.Parent = knob

    local state = savedState
    local function setState(newState)
        state = newState
        Config[configKey] = state
        saveConfig()
        TweenService:Create(track, TweenInfo.new(0.2), { BackgroundColor3 = state and THEME.Accent or THEME.AccentInactive }):Play()
        TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(state and 1 or 0, state and -20 or 2, 0.5, -9)
        }):Play()
        callback(state)
    end

    track.MouseButton1Click:Connect(function() setState(not state) end)
    if savedState then callback(true) end
end

local function createSlider(parentPage, configKey, labelText, minVal, maxVal, defaultVal, callback)
    local savedValue = Config[configKey] or defaultVal

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 45)
    container.BackgroundTransparency = 1
    container.Parent = parentPage

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 0, 18)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = THEME.Text
    label.TextSize = 13
    label.Font = THEME.FontRegular
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local valueDisplay = Instance.new("TextLabel")
    valueDisplay.Size = UDim2.new(0.3, 0, 0, 18)
    valueDisplay.Position = UDim2.new(0.7, 0, 0, 0)
    valueDisplay.BackgroundTransparency = 1
    valueDisplay.Text = tostring(math.floor(savedValue))
    valueDisplay.TextColor3 = THEME.TextSub
    valueDisplay.TextSize = 12
    valueDisplay.Font = THEME.FontBold
    valueDisplay.TextXAlignment = Enum.TextXAlignment.Right
    valueDisplay.Parent = container

    local sliderTrack = Instance.new("TextButton")
    sliderTrack.Size = UDim2.new(1, 0, 0, 8)
    sliderTrack.Position = UDim2.new(0, 0, 0, 26)
    sliderTrack.BackgroundColor3 = THEME.AccentInactive
    sliderTrack.BorderSizePixel = 0
    sliderTrack.Text = ""
    sliderTrack.AutoButtonColor = false
    sliderTrack.Parent = container
    local stCorner = Instance.new("UICorner") stCorner.CornerRadius = UDim.new(1, 0) stCorner.Parent = sliderTrack

    local startRatio = math.clamp((savedValue - minVal) / (maxVal - minVal), 0, 1)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(startRatio, 0, 1, 0)
    fill.BackgroundColor3 = THEME.Accent
    fill.BorderSizePixel = 0
    fill.Parent = sliderTrack
    local fCorner = Instance.new("UICorner") fCorner.CornerRadius = UDim.new(1, 0) fCorner.Parent = fill
    registerAccent(fill, "BackgroundColor3")

    local dragging = false
    local function updateSlider(input)
        local posX = math.clamp(input.Position.X - sliderTrack.AbsolutePosition.X, 0, sliderTrack.AbsoluteSize.X)
        local ratio = posX / sliderTrack.AbsoluteSize.X
        local val = math.floor(minVal + (maxVal - minVal) * ratio)
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        valueDisplay.Text = tostring(val)
        Config[configKey] = val
        saveConfig()
        callback(val)
    end

    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true updateSlider(input) end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then updateSlider(input) end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    callback(savedValue)
end

local function createButton(parentPage, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = THEME.AccentInactive
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = THEME.Text
    btn.TextSize = 12
    btn.Font = THEME.FontBold
    btn.Parent = parentPage

    local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 6) c.Parent = btn

    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), { BackgroundColor3 = THEME.Accent }):Play()
        task.wait(0.1)
        TweenService:Create(btn, TweenInfo.new(0.2), { BackgroundColor3 = THEME.AccentInactive }):Play()
        callback()
    end)
end

local pageMovement = createTab("Mozgás")
local pageVisuals = createTab("Látvány")
local pageCombat = createTab("Harcos")
local pageUtility = createTab("Ezközök")
local pageSettings = createTab("Beállítások")

createSlider(pageMovement, "WalkSpeed", "⚡ Járási Sebesség", 16, 200, 16, function(val)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = val end
end)

createSlider(pageMovement, "JumpPower", "🦘 Ugrási Erő", 50, 300, 50, function(val)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.UseJumpPower = true hum.JumpPower = val end
end)

local infJumpEnabled = false
createToggle(pageMovement, "InfJump", "🦘 Végtelen Ugrás", false, function(enabled)
    infJumpEnabled = enabled
end)

UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

local flying, flySpeed, flyConn = false, 50, nil
createSlider(pageMovement, "FlySpeed", "✈️ Repülési Sebesség", 20, 200, 50, function(val) flySpeed = val end)
createToggle(pageMovement, "FlyMode", "✈️ Repülés Mód", false, function(enabled)
    flying = enabled
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if enabled and root then
        local bg = Instance.new("BodyGyro") bg.Name = "FlyGyro" bg.P = 9e4 bg.maxTorque = Vector3.new(9e9, 9e9, 9e9) bg.cframe = root.CFrame bg.Parent = root
        local bv = Instance.new("BodyVelocity") bv.Name = "FlyVelocity" bv.velocity = Vector3.new() bv.maxForce = Vector3.new(9e9, 9e9, 9e9) bv.Parent = root

        flyConn = RunService.RenderStepped:Connect(function()
            if not flying or not root then return end
            bg.cframe = Camera.CFrame
            local moveDir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
            bv.velocity = moveDir * flySpeed
        end)
    else
        if flyConn then flyConn:Disconnect() flyConn = nil end
        if root then
            if root:FindFirstChild("FlyGyro") then root.FlyGyro:Destroy() end
            if root:FindFirstChild("FlyVelocity") then root.FlyVelocity:Destroy() end
        end
    end
end)

local aimbotEnabled, aimbotConn = false, nil
createToggle(pageCombat, "Aimbot", "🎯 Aimbot (Jobb Egérgomb Tartás)", false, function(enabled)
    aimbotEnabled = enabled
    if enabled then
        aimbotConn = RunService.RenderStepped:Connect(function()
            if aimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                local closestPlayer, closestDist = nil, math.huge
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                        local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                        if onScreen then
                            local dist = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                            if dist < closestDist then
                                closestDist = dist
                                closestPlayer = p
                            end
                        end
                    end
                end
                if closestPlayer and closestPlayer.Character:FindFirstChild("Head") then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestPlayer.Character.Head.Position)
                end
            end
        end)
    else
        if aimbotConn then aimbotConn:Disconnect() aimbotConn = nil end
    end
end)

local selectedFlingTarget, flinging, flingConn = nil, false, nil

local flingContainer = Instance.new("Frame")
flingContainer.Size = UDim2.new(1, 0, 0, 75)
flingContainer.BackgroundTransparency = 1
flingContainer.Parent = pageCombat

local flingLabel = Instance.new("TextLabel")
flingLabel.Size = UDim2.new(1, 0, 0, 18)
flingLabel.BackgroundTransparency = 1
flingLabel.Text = "🌀 Fling (Játékos Kilövése)"
flingLabel.TextColor3 = THEME.Text
flingLabel.TextSize = 13
flingLabel.Font = THEME.FontRegular
flingLabel.TextXAlignment = Enum.TextXAlignment.Left
flingLabel.Parent = flingContainer

local flingDropdownBtn = Instance.new("TextButton")
flingDropdownBtn.Size = UDim2.new(1, 0, 0, 26)
flingDropdownBtn.Position = UDim2.new(0, 0, 0, 22)
flingDropdownBtn.BackgroundColor3 = THEME.AccentInactive
flingDropdownBtn.Text = "Célpont Kiválasztása..."
flingDropdownBtn.TextColor3 = THEME.TextSub
flingDropdownBtn.TextSize = 11
flingDropdownBtn.Font = THEME.FontRegular
flingDropdownBtn.Parent = flingContainer

local executeFlingBtn = Instance.new("TextButton")
executeFlingBtn.Size = UDim2.new(1, 0, 0, 24)
executeFlingBtn.Position = UDim2.new(0, 0, 0, 52)
executeFlingBtn.BackgroundColor3 = THEME.Accent
executeFlingBtn.Text = "🚀 Fling Indítása"
executeFlingBtn.TextColor3 = THEME.Text
executeFlingBtn.TextSize = 11
executeFlingBtn.Font = THEME.FontBold
executeFlingBtn.Parent = flingContainer
registerAccent(executeFlingBtn, "BackgroundColor3")

local flingDropdownList = Instance.new("ScrollingFrame")
flingDropdownList.Size = UDim2.new(1, 0, 0, 90)
flingDropdownList.Position = UDim2.new(0, 0, 0, 48)
flingDropdownList.BackgroundColor3 = THEME.Background
flingDropdownList.BorderSizePixel = 1
flingDropdownList.BorderColor3 = THEME.Border
flingDropdownList.Visible = false
flingDropdownList.ZIndex = 12
flingDropdownList.AutomaticCanvasSize = Enum.AutomaticSize.Y
flingDropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
flingDropdownList.Parent = flingContainer

local fListLayout = Instance.new("UIListLayout") fListLayout.Parent = flingDropdownList

flingDropdownBtn.MouseButton1Click:Connect(function()
    flingDropdownList.Visible = not flingDropdownList.Visible
    if flingDropdownList.Visible then
        for _, child in ipairs(flingDropdownList:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local pBtn = Instance.new("TextButton")
                pBtn.Size = UDim2.new(1, 0, 0, 22)
                pBtn.BackgroundColor3 = THEME.AccentInactive
                pBtn.Text = p.DisplayName
                pBtn.TextColor3 = THEME.Text
                pBtn.TextSize = 10
                pBtn.Font = THEME.FontRegular
                pBtn.ZIndex = 13
                pBtn.Parent = flingDropdownList
                pBtn.MouseButton1Click:Connect(function()
                    selectedFlingTarget = p
                    flingDropdownBtn.Text = p.DisplayName
                    flingDropdownList.Visible = false
                end)
            end
        end
    end
end)

executeFlingBtn.MouseButton1Click:Connect(function()
    if flinging then
        flinging = false
        if flingConn then flingConn:Disconnect() flingConn = nil end
        executeFlingBtn.Text = "🚀 Fling Indítása"
        notify("Fling", "Fling leállítva.", 2)
        return
    end

    if selectedFlingTarget and selectedFlingTarget.Character and selectedFlingTarget.Character:FindFirstChild("HumanoidRootPart") then
        flinging = true
        executeFlingBtn.Text = "🛑 Fling Leállítása"
        notify("Fling", "Fling aktív rajta: " .. selectedFlingTarget.DisplayName, 3)

        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local angle = 0
        flingConn = RunService.Heartbeat:Connect(function()
            if not flinging or not myRoot or not selectedFlingTarget.Character or not selectedFlingTarget.Character:FindFirstChild("HumanoidRootPart") then
                flinging = false
                if flingConn then flingConn:Disconnect() end
                executeFlingBtn.Text = "🚀 Fling Indítása"
                return
            end
            local targetRoot = selectedFlingTarget.Character.HumanoidRootPart
            angle = angle + 100
            myRoot.Velocity = Vector3.new(10000, 10000, 10000)
            myRoot.CFrame = targetRoot.CFrame * CFrame.Angles(0, math.rad(angle), 0) * CFrame.new(0, 0, 1.5)
        end)
    else
        notify("Fling Hiba", "Érvénytelen célpont!", 2)
    end
end)

createToggle(pageCombat, "Godmode", "🛡️ Godmode (Halhatatlanság)", false, function(enabled)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        if enabled then
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            notify("Godmode", "Godmode Aktiválva.", 2)
        else
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
            notify("Godmode", "Godmode Deaktiválva.", 2)
        end
    end
end)

local isInvisible = false
createToggle(pageCombat, "Invisibility", "👻 Láthatatlanság", false, function(enabled)
    isInvisible = enabled
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then
                part.Transparency = enabled and 1 or 0
            end
        end
        notify("Láthatatlanság", enabled and "Most láthatatlan vagy!" or "Újra látható vagy.", 2)
    end
end)

createSlider(pageVisuals, "FOV", "🔍 Látószög (FOV)", 60, 120, 70, function(val) Camera.FieldOfView = val end)

local espEnabled, espCache = false, {}
local function removeEsp(player)
    if espCache[player] then
        if espCache[player].Highlight then espCache[player].Highlight:Destroy() end
        if espCache[player].Billboard then espCache[player].Billboard:Destroy() end
        espCache[player] = nil
    end
end

local function applyEsp(player)
    if player == LocalPlayer or not espEnabled then return end
    removeEsp(player)
    local function setupCharacter(character)
        if not character then return end
        local head = character:WaitForChild("Head", 5)
        if not head or not espEnabled then return end

        local highlight = Instance.new("Highlight") highlight.Adornee = character highlight.FillColor = Color3.fromRGB(255, 80, 80) highlight.FillTransparency = 0.6 highlight.OutlineColor = Color3.fromRGB(255, 255, 255) highlight.Parent = character
        local billboard = Instance.new("BillboardGui") billboard.Adornee = head billboard.Size = UDim2.new(0, 150, 0, 40) billboard.StudsOffset = Vector3.new(0, 2.5, 0) billboard.AlwaysOnTop = true

        local nameLabel = Instance.new("TextLabel") nameLabel.Size = UDim2.new(1, 0, 1, 0) nameLabel.BackgroundTransparency = 1 nameLabel.Text = player.DisplayName nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255) nameLabel.TextStrokeTransparency = 0.2 nameLabel.TextSize = 13 nameLabel.Font = THEME.FontBold nameLabel.Parent = billboard
        billboard.Parent = character
        espCache[player] = { Highlight = highlight, Billboard = billboard }
    end
    if player.Character then setupCharacter(player.Character) end
    player.CharacterAdded:Connect(setupCharacter)
end

createToggle(pageVisuals, "ESP", "👁️ Játékos ESP (Kiemelés)", false, function(enabled)
    espEnabled = enabled
    if enabled then
        for _, p in ipairs(Players:GetPlayers()) do applyEsp(p) end
        Players.PlayerAdded:Connect(applyEsp)
        Players.PlayerRemoving:Connect(removeEsp)
    else
        for p, _ in pairs(espCache) do removeEsp(p) end
    end
end)

createSlider(pageVisuals, "TimeOfDay", "☀️ Napszak (Óra)", 0, 24, 14, function(val) Lighting.ClockTime = val end)

createButton(pageUtility, "🔄 Újracsatlakozás (Rejoin)", function()
    notify("Szerver", "Újracsatlakozás a szerverre...", 2)
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

createButton(pageUtility, "🌐 Szerver Váltás (Server Hop)", function()
    notify("Szerver", "Új szerver keresése...", 2)
    pcall(function()
        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        for _, server in ipairs(servers.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                break
            end
        end
    end)
end)

local afkConn
createToggle(pageUtility, "AntiAfk", "💤 Anti-AFK (Kidobás Elleni Védelem)", false, function(enabled)
    if enabled then
        afkConn = LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
            notify("Anti-AFK", "Inaktivitási kidobás megakadályozva.", 2)
        end)
    elseif afkConn then afkConn:Disconnect() afkConn = nil end
end)

local themePaletteContainer = Instance.new("Frame")
themePaletteContainer.Size = UDim2.new(1, 0, 0, 40)
themePaletteContainer.BackgroundTransparency = 1
themePaletteContainer.Parent = pageSettings

local tpLabel = Instance.new("TextLabel")
tpLabel.Size = UDim2.new(0.4, 0, 1, 0)
tpLabel.BackgroundTransparency = 1
tpLabel.Text = "🎨 Téma Szín"
tpLabel.TextColor3 = THEME.Text
tpLabel.TextSize = 13
tpLabel.Font = THEME.FontRegular
tpLabel.TextXAlignment = Enum.TextXAlignment.Left
tpLabel.Parent = themePaletteContainer

local colors = {
    {Name = "Cian", Color = Color3.fromRGB(90, 160, 255)},
    {Name = "Piros", Color = Color3.fromRGB(255, 80, 80)},
    {Name = "Zöld", Color = Color3.fromRGB(80, 220, 120)},
    {Name = "Lila", Color = Color3.fromRGB(180, 100, 255)}
}

for i, colData in ipairs(colors) do
    local cBtn = Instance.new("TextButton")
    cBtn.Size = UDim2.new(0, 22, 0, 22)
    cBtn.Position = UDim2.new(0.45 + ((i-1) * 0.13), 0, 0.2, 0)
    cBtn.BackgroundColor3 = colData.Color
    cBtn.BorderSizePixel = 0
    cBtn.Text = ""
    cBtn.Parent = themePaletteContainer
    local cCorner = Instance.new("UICorner") cCorner.CornerRadius = UDim.new(1, 0) cCorner.Parent = cBtn
    cBtn.MouseButton1Click:Connect(function() setAccentColor(colData.Color) end)
end
