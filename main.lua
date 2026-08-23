--[[
    Fabalta Tool v10.0 – Max Edition (Enhanced)
    Improved by AI Assistant
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- ========== CONFIG ==========
local CONFIG_FILE = "FabaltaTool_Max.json"
local Config = {
    ToggleKey = "F12",
    AccentColor = {90, 160, 255},
    WalkSpeed = 16,
    JumpPower = 50,
    InfJump = false,
    Noclip = false,
    Aimbot = false,
    AimSmooth = 2,
    Godmode = false,
    FOV = 70,
    Fullbright = false,
    AntiAFK = true,
    Fly = false,
    ESP = false,
    SilentAim = false,
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
        pcall(function() writefile(CONFIG_FILE, HttpService:JSONEncode(Config)) end)
    end
end
loadConfig()

-- ========== KEY VALIDATION ==========
local CORRECT_KEY = "7YLhpY0bzXe9AyO5obJa2AOPhFmeIsMQ8sEG8XgE9SEbRJIW2grBBqeCTSb5viIi9d"  -- fallback
-- Optionally load from file:
if isfile and isfile("key.txt") then
    pcall(function()
        local loadedKey = readfile("key.txt"):gsub("%s+", "")
        if loadedKey ~= "" then CORRECT_KEY = loadedKey end
    end)
end

-- ========== THEME ==========
local THEME = {
    Background = Color3.fromRGB(16, 18, 24),
    HeaderBg = Color3.fromRGB(20, 22, 30),
    SidebarBg = Color3.fromRGB(20, 22, 30),
    ContainerBg = Color3.fromRGB(25, 28, 38),
    Accent = Color3.fromRGB(Config.AccentColor[1], Config.AccentColor[2], Config.AccentColor[3]),
    AccentInactive = Color3.fromRGB(30, 34, 46),
    Text = Color3.fromRGB(240, 240, 250),
    TextSub = Color3.fromRGB(140, 145, 170),
    Border = Color3.fromRGB(40, 45, 65),
    FontBold = Enum.Font.GothamBold,
    FontRegular = Enum.Font.GothamMedium,
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

-- ========== UI HELPERS ==========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FabaltaToolMax"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

-- Notification container
local notifContainer = Instance.new("Frame")
notifContainer.Size = UDim2.new(0, 240, 1, -20)
notifContainer.Position = UDim2.new(1, -250, 0, 10)
notifContainer.BackgroundTransparency = 1
notifContainer.Parent = screenGui

local notifLayout = Instance.new("UIListLayout")
notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifLayout.Padding = UDim.new(0, 8)
notifLayout.Parent = notifContainer

local function notify(title, msg, duration)
    duration = duration or 3
    local toast = Instance.new("Frame")
    toast.Size = UDim2.new(1, 0, 0, 50)
    toast.BackgroundColor3 = THEME.ContainerBg
    toast.BorderSizePixel = 0
    toast.Parent = notifContainer

    local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 8) corner.Parent = toast
    local stroke = Instance.new("UIStroke") stroke.Color = THEME.Border stroke.Thickness = 1 stroke.Parent = toast

    local tLabel = Instance.new("TextLabel")
    tLabel.Size = UDim2.new(1, -16, 0, 20)
    tLabel.Position = UDim2.new(0, 10, 0, 6)
    tLabel.BackgroundTransparency = 1
    tLabel.Text = title
    tLabel.TextColor3 = THEME.Accent
    tLabel.TextSize = 12
    tLabel.Font = THEME.FontBold
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.Parent = toast
    registerAccent(tLabel, "TextColor3")

    local mLabel = Instance.new("TextLabel")
    mLabel.Size = UDim2.new(1, -16, 0, 20)
    mLabel.Position = UDim2.new(0, 10, 0, 24)
    mLabel.BackgroundTransparency = 1
    mLabel.Text = msg
    mLabel.TextColor3 = THEME.TextSub
    mLabel.TextSize = 11
    mLabel.Font = THEME.FontRegular
    mLabel.TextXAlignment = Enum.TextXAlignment.Left
    mLabel.Parent = toast

    task.delay(duration, function()
        if toast.Parent then toast:Destroy() end
    end)
end

local function makeDraggable(dragHandle, targetFrame)
    local dragging, dragInput, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            targetFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ========== KEY UI ==========
local keyFrame = Instance.new("Frame")
keyFrame.Size = UDim2.new(0, 340, 0, 170)
keyFrame.Position = UDim2.new(0.5, -170, 0.4, -85)
keyFrame.BackgroundColor3 = THEME.Background
keyFrame.BorderSizePixel = 0
keyFrame.Parent = screenGui

local kCorner = Instance.new("UICorner") kCorner.CornerRadius = UDim.new(0, 10) kCorner.Parent = keyFrame
local kBorder = Instance.new("UIStroke") kBorder.Thickness = 1 kBorder.Color = THEME.Border kBorder.Parent = keyFrame

local keyTitle = Instance.new("TextLabel")
keyTitle.Size = UDim2.new(1, 0, 0, 45)
keyTitle.BackgroundTransparency = 1
keyTitle.Text = "🔐 Fabalta Kulcs Hitelesítés"
keyTitle.TextColor3 = THEME.Text
keyTitle.TextSize = 14
keyTitle.Font = THEME.FontBold
keyTitle.Parent = keyFrame

local keyInput = Instance.new("TextBox")
keyInput.Size = UDim2.new(0.88, 0, 0, 36)
keyInput.Position = UDim2.new(0.06, 0, 0.35, 0)
keyInput.BackgroundColor3 = THEME.ContainerBg
keyInput.BorderSizePixel = 0
keyInput.PlaceholderText = "Illeszd be a kulcsot..."
keyInput.Text = ""
keyInput.TextColor3 = THEME.Text
keyInput.PlaceholderColor3 = THEME.TextSub
keyInput.TextSize = 11
keyInput.Font = THEME.FontRegular
keyInput.Parent = keyFrame
local kiCorner = Instance.new("UICorner") kiCorner.CornerRadius = UDim.new(0, 6) kiCorner.Parent = keyInput

local submitKeyBtn = Instance.new("TextButton")
submitKeyBtn.Size = UDim2.new(0.88, 0, 0, 34)
submitKeyBtn.Position = UDim2.new(0.06, 0, 0.65, 0)
submitKeyBtn.BackgroundColor3 = THEME.Accent
submitKeyBtn.BorderSizePixel = 0
submitKeyBtn.Text = "Belépés"
submitKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
submitKeyBtn.TextSize = 12
submitKeyBtn.Font = THEME.FontBold
submitKeyBtn.Parent = keyFrame
local skCorner = Instance.new("UICorner") skCorner.CornerRadius = UDim.new(0, 6) skCorner.Parent = submitKeyBtn
registerAccent(submitKeyBtn, "BackgroundColor3")

makeDraggable(keyTitle, keyFrame)

-- ========== MAIN PANEL ==========
local panel = Instance.new("Frame")
panel.Name = "MainPanel"
panel.Size = UDim2.new(0, 580, 0, 420)  -- slightly wider
panel.Position = UDim2.new(0.1, 0, 0.15, 0)
panel.BackgroundColor3 = THEME.Background
panel.BorderSizePixel = 0
panel.ClipsDescendants = true
panel.Visible = false
panel.Parent = screenGui

local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 10) corner.Parent = panel
local border = Instance.new("UIStroke") border.Thickness = 1 border.Color = THEME.Border border.Parent = panel

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 38)
header.BackgroundColor3 = THEME.HeaderBg
header.BorderSizePixel = 0
header.Parent = panel

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⚙️ Fabalta Tool v10.0 (Max Edition)"
titleLabel.TextColor3 = THEME.Text
titleLabel.TextSize = 13
titleLabel.Font = THEME.FontBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 22, 0, 22)
closeBtn.Position = UDim2.new(1, -28, 0.5, -11)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 11
closeBtn.Font = THEME.FontBold
closeBtn.Parent = header
local cCorner = Instance.new("UICorner") cCorner.CornerRadius = UDim.new(0, 5) cCorner.Parent = closeBtn

makeDraggable(header, panel)

-- Sidebar
local sidebar = Instance.new("ScrollingFrame")
sidebar.Size = UDim2.new(0, 140, 1, -68)
sidebar.Position = UDim2.new(0, 0, 0, 38)
sidebar.BackgroundColor3 = THEME.SidebarBg
sidebar.BorderSizePixel = 0
sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
sidebar.ScrollBarThickness = 2
sidebar.Parent = panel

local sidebarLayout = Instance.new("UIListLayout")
sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
sidebarLayout.Padding = UDim.new(0, 4)
sidebarLayout.Parent = sidebar

local sidebarPadding = Instance.new("UIPadding")
sidebarPadding.PaddingTop = UDim.new(0, 8)
sidebarPadding.PaddingBottom = UDim.new(0, 8)
sidebarPadding.PaddingLeft = UDim.new(0, 8)
sidebarPadding.PaddingRight = UDim.new(0, 8)
sidebarPadding.Parent = sidebar

-- Content
local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -150, 1, -48)
contentArea.Position = UDim2.new(0, 145, 0, 43)
contentArea.BackgroundTransparency = 1
contentArea.Parent = panel

local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(0, 140, 0, 30)
footer.Position = UDim2.new(0, 0, 1, -30)
footer.BackgroundColor3 = THEME.HeaderBg
footer.BackgroundTransparency = 0.5
footer.BorderSizePixel = 0
footer.Text = "[" .. Config.ToggleKey .. "]"
footer.TextColor3 = THEME.TextSub
footer.TextSize = 10
footer.Font = THEME.FontRegular
footer.Parent = panel

-- ========== UNLOCK ==========
local isUnlocked = false
local function unlockSuite()
    isUnlocked = true
    keyFrame:Destroy()
    panel.Visible = true
    notify("Sikeres Belépés", "Minden modul aktív.", 3)
end

submitKeyBtn.MouseButton1Click:Connect(function()
    if keyInput.Text == CORRECT_KEY then
        unlockSuite()
    else
        keyInput.Text = ""
        keyInput.PlaceholderText = "❌ Hibás kulcs!"
    end
end)

-- Toggle panel visibility
local isVisible = true
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and isUnlocked and input.KeyCode == Enum.KeyCode[Config.ToggleKey] then
        isVisible = not isVisible
        panel.Visible = isVisible
    end
end)

closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

-- ========== UI BUILDING SYSTEM ==========
local tabs = {}
local currentTab = nil

local function createTab(name)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, 0, 0, 32)
    tabBtn.BackgroundColor3 = THEME.AccentInactive
    tabBtn.BorderSizePixel = 0
    tabBtn.Text = "  " .. name
    tabBtn.TextColor3 = THEME.TextSub
    tabBtn.TextSize = 11
    tabBtn.Font = THEME.FontBold
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    tabBtn.Parent = sidebar
    local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 6) c.Parent = tabBtn

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -10, 1, 0)
    scroll.Position = UDim2.new(0, 0, 0, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.Visible = false
    scroll.Parent = contentArea
    registerAccent(scroll, "ScrollBarImageColor3")

    local list = Instance.new("UIListLayout")
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 6)
    list.Parent = scroll

    local pad = Instance.new("UIPadding")
    pad.PaddingRight = UDim.new(0, 8)
    pad.PaddingTop = UDim.new(0, 2)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.Parent = scroll

    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.Btn.BackgroundColor3 = THEME.AccentInactive
            t.Btn.TextColor3 = THEME.TextSub
            t.Page.Visible = false
        end
        tabBtn.BackgroundColor3 = THEME.ContainerBg
        tabBtn.TextColor3 = THEME.Text
        scroll.Visible = true
        currentTab = scroll
    end)

    tabs[name] = { Btn = tabBtn, Page = scroll }
    if not currentTab then
        tabBtn.BackgroundColor3 = THEME.ContainerBg
        tabBtn.TextColor3 = THEME.Text
        scroll.Visible = true
        currentTab = scroll
    end
    return scroll
end

-- Animated toggle
local function createToggle(parentPage, configKey, labelText, defaultOn, callback)
    local savedState = Config[configKey]
    if savedState == nil then savedState = defaultOn end

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 36)
    container.BackgroundColor3 = THEME.ContainerBg
    container.BorderSizePixel = 0
    container.Parent = parentPage
    local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 6) c.Parent = container

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = THEME.Text
    label.TextSize = 11
    label.Font = THEME.FontRegular
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local track = Instance.new("TextButton")
    track.Size = UDim2.new(0, 40, 0, 20)
    track.Position = UDim2.new(1, -48, 0.5, -10)
    track.BackgroundColor3 = savedState and THEME.Accent or THEME.AccentInactive
    track.BorderSizePixel = 0
    track.Text = ""
    track.Parent = container
    if savedState then registerAccent(track, "BackgroundColor3") end

    local trackCorner = Instance.new("UICorner") trackCorner.CornerRadius = UDim.new(1, 0) trackCorner.Parent = track

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(savedState and 1 or 0, savedState and -18 or 2, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = track

    local knobCorner = Instance.new("UICorner") knobCorner.CornerRadius = UDim.new(1, 0) knobCorner.Parent = knob

    local state = savedState
    local function setState(newState)
        state = newState
        Config[configKey] = state
        saveConfig()
        -- Animate
        local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local targetColor = state and THEME.Accent or THEME.AccentInactive
        local targetPos = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        TweenService:Create(track, tweenInfo, {BackgroundColor3 = targetColor}):Play()
        TweenService:Create(knob, tweenInfo, {Position = targetPos}):Play()
        task.spawn(function() pcall(function() callback(state) end) end)
    end

    track.MouseButton1Click:Connect(function() setState(not state) end)
    if savedState then task.spawn(function() pcall(function() callback(true) end) end) end
end

-- Slider with value label
local function createSlider(parentPage, configKey, labelText, minVal, maxVal, defaultVal, callback)
    local savedValue = Config[configKey] or defaultVal

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 48)
    container.BackgroundColor3 = THEME.ContainerBg
    container.BorderSizePixel = 0
    container.Parent = parentPage
    local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 6) c.Parent = container

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 0, 18)
    label.Position = UDim2.new(0, 10, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = THEME.Text
    label.TextSize = 11
    label.Font = THEME.FontRegular
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local valueDisplay = Instance.new("TextLabel")
    valueDisplay.Size = UDim2.new(0.3, 0, 0, 18)
    valueDisplay.Position = UDim2.new(0.65, 0, 0, 4)
    valueDisplay.BackgroundTransparency = 1
    valueDisplay.Text = tostring(math.floor(savedValue))
    valueDisplay.TextColor3 = THEME.TextSub
    valueDisplay.TextSize = 10
    valueDisplay.Font = THEME.FontBold
    valueDisplay.TextXAlignment = Enum.TextXAlignment.Right
    valueDisplay.Parent = container

    local sliderTrack = Instance.new("TextButton")
    sliderTrack.Size = UDim2.new(1, -20, 0, 6)
    sliderTrack.Position = UDim2.new(0, 10, 0, 30)
    sliderTrack.BackgroundColor3 = THEME.AccentInactive
    sliderTrack.BorderSizePixel = 0
    sliderTrack.Text = ""
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
        pcall(function() callback(val) end)
    end

    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSlider(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    pcall(function() callback(savedValue) end)
end

local function createButton(parentPage, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = THEME.ContainerBg
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = THEME.Text
    btn.TextSize = 11
    btn.Font = THEME.FontBold
    btn.Parent = parentPage
    local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 6) c.Parent = btn
    btn.MouseButton1Click:Connect(function() task.spawn(callback) end)
end

-- ========== TABS ==========
local pageMovement = createTab("Mozgás")
local pageCombat = createTab("Harc")
local pageVisuals = createTab("Látvány")
local pageUtility = createTab("Eszközök")
local pageSettings = createTab("Beállítások")

-- ========== FEATURES ==========

-- Helpers for character access
local function getChar()
    return LocalPlayer.Character
end

local function getHumanoid()
    local char = getChar()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    local char = getChar()
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- Apply settings on respawn
local function applyAllSettings()
    local hum = getHumanoid()
    if hum then
        hum.WalkSpeed = Config.WalkSpeed
        hum.JumpPower = Config.JumpPower
        hum.UseJumpPower = true
        if Config.Godmode then
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        else
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        end
    end
    Camera.FieldOfView = Config.FOV
    Lighting.Brightness = Config.Fullbright and 3 or 1
    Lighting.ClockTime = Config.Fullbright and 14 or 12
    Lighting.GlobalShadows = not Config.Fullbright
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5) -- wait for humanoid to load
    applyAllSettings()
end)

-- ===== MOZGÁS =====
createSlider(pageMovement, "WalkSpeed", "⚡ Járási Sebesség", 16, 200, 16, function(val)
    Config.WalkSpeed = val
    local hum = getHumanoid()
    if hum then hum.WalkSpeed = val end
end)

createSlider(pageMovement, "JumpPower", "🦘 Ugrási Erő", 50, 300, 50, function(val)
    Config.JumpPower = val
    local hum = getHumanoid()
    if hum then hum.JumpPower = val end
end)

createToggle(pageMovement, "InfJump", "🦘 Végtelen Ugrás", false, function(enabled)
    Config.InfJump = enabled
end)

UserInputService.JumpRequest:Connect(function()
    if Config.InfJump then
        local hum = getHumanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

createToggle(pageMovement, "Noclip", "🧱 Noclip (Falon átjárás)", false, function(enabled)
    Config.Noclip = enabled
end)

RunService.Heartbeat:Connect(function()
    if Config.Noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

createToggle(pageMovement, "Fly", "✈️ Repülés (Szóköz/SHIFT)", false, function(enabled)
    Config.Fly = enabled
    if not enabled then
        local hum = getHumanoid()
        if hum then
            hum.PlatformStand = false
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        end
    end
end)

-- Fly logic
local flyConnection
UserInputService.InputBegan:Connect(function(input)
    if Config.Fly then
        local hum = getHumanoid()
        if not hum then return end
        if input.KeyCode == Enum.KeyCode.Space then
            hum.PlatformStand = true
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        elseif input.KeyCode == Enum.KeyCode.LeftShift then
            hum.PlatformStand = true
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        end
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if Config.Fly then
        local hum = getHumanoid()
        if not hum then return end
        if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.LeftShift then
            hum.PlatformStand = false
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if Config.Fly and LocalPlayer.Character then
        local root = getRoot()
        local hum = getHumanoid()
        if root and hum then
            local moveDir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector * Vector3.new(1,0,1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector * Vector3.new(1,0,1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0,1,0) end
            if moveDir.Magnitude > 0 then
                moveDir = moveDir.Unit * 50
                root.Velocity = Vector3.new(moveDir.X, root.Velocity.Y + (moveDir.Y - root.Velocity.Y) * 0.1, moveDir.Z)
            else
                root.Velocity = Vector3.new(0, root.Velocity.Y, 0)
            end
        end
    end
end)

createButton(pageMovement, "📍 TP Tool (Ctrl + Kattintás)", function()
    local mouse = LocalPlayer:GetMouse()
    mouse.Button1Down:Connect(function()
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and LocalPlayer.Character then
            local root = getRoot()
            if root then
                root.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
            end
        end
    end)
    notify("TP Tool", "Aktív: Ctrl + Bal klikk a pályán.", 3)
end)

-- ===== HARC =====
local aimbotEnabled = false
local aimSmoothness = 0.2
createSlider(pageCombat, "AimSmooth", "🎯 Aimbot Simítás", 1, 10, 2, function(val)
    aimSmoothness = val / 10
end)
createToggle(pageCombat, "Aimbot", "🎯 Aimbot (Jobb klikk tartás)", false, function(enabled)
    aimbotEnabled = enabled
end)

RunService.RenderStepped:Connect(function()
    if aimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local closestPlayer, closestDist = nil, math.huge
        local mouseLoc = UserInputService:GetMouseLocation()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - mouseLoc).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestPlayer = p
                    end
                end
            end
        end
        if closestPlayer and closestPlayer.Character:FindFirstChild("Head") then
            local targetCFrame = CFrame.new(Camera.CFrame.Position, closestPlayer.Character.Head.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, aimSmoothness)
        end
    end
end)

-- Silent Aim (optional)
createToggle(pageCombat, "SilentAim", "🎯 Silent Aimbot (Auto-lock)", false, function(enabled)
    Config.SilentAim = enabled
end)

RunService.Heartbeat:Connect(function()
    if Config.SilentAim then
        local closestPlayer, closestDist = nil, math.huge
        local char = LocalPlayer.Character
        if not char then return end
        local root = getRoot()
        if not root then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local dist = (root.Position - p.Character.Head.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closestPlayer = p
                end
            end
        end
        if closestPlayer and closestPlayer.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestPlayer.Character.Head.Position)
        end
    end
end)

createToggle(pageCombat, "Godmode", "🛡️ Godmode (Halhatatlanság)", false, function(enabled)
    Config.Godmode = enabled
    local hum = getHumanoid()
    if hum then
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, not enabled)
    end
end)

-- ===== LÁTVÁNY =====
createSlider(pageVisuals, "FOV", "🔍 Látószög (FOV)", 60, 120, 70, function(val)
    Config.FOV = val
    Camera.FieldOfView = val
end)

createToggle(pageVisuals, "Fullbright", "☀️ Fullbright (Sötétség ellen)", false, function(enabled)
    Config.Fullbright = enabled
    Lighting.Brightness = enabled and 3 or 1
    Lighting.ClockTime = enabled and 14 or 12
    Lighting.GlobalShadows = not enabled
end)

-- ESP (simple box)
createToggle(pageVisuals, "ESP", "👁️ ESP (Ládák/játékosok)", false, function(enabled)
    Config.ESP = enabled
end)

local espConnections = {}
RunService.RenderStepped:Connect(function()
    if Config.ESP then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local head = player.Character.Head
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    -- create a simple billboard GUI if not exists
                    local espGui = head:FindFirstChild("ESP_Gui")
                    if not espGui then
                        espGui = Instance.new("BillboardGui")
                        espGui.Name = "ESP_Gui"
                        espGui.Size = UDim2.new(0, 40, 0, 20)
                        espGui.AlwaysOnTop = true
                        espGui.Parent = head

                        local label = Instance.new("TextLabel")
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.BackgroundTransparency = 1
                        label.Text = player.Name
                        label.TextColor3 = THEME.Accent
                        label.TextSize = 12
                        label.Font = THEME.FontBold
                        label.Parent = espGui
                    end
                    espGui.Enabled = true
                elseif head:FindFirstChild("ESP_Gui") then
                    head.ESP_Gui.Enabled = false
                end
            end
        end
    else
        -- remove all ESP guis
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                local esp = player.Character:FindFirstChild("ESP_Gui")
                if esp then esp:Destroy() end
            end
        end
    end
end)

-- ===== ESZKÖZÖK =====
createToggle(pageUtility, "AntiAFK", "🛡️ Anti-AFK (Kitiltás ellen)", true, function(enabled)
    Config.AntiAFK = enabled
    if enabled then
        LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

createButton(pageUtility, "🔄 Szerver Újracsatlakozás", function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

createButton(pageUtility, "📋 Másolás (Clipboard)", function()
    if setclipboard then
        setclipboard("Fabalta v10.0 – engedélyezve!")
        notify("Másolva", "Szöveg a vágólapra került.", 2)
    else
        notify("Hiba", "setclipboard nem támogatott.", 2)
    end
end)

-- ===== BEÁLLÍTÁSOK =====
createButton(pageSettings, "🎨 Kék Téma", function() setAccentColor(Color3.fromRGB(90, 160, 255)) end)
createButton(pageSettings, "🎨 Piros Téma", function() setAccentColor(Color3.fromRGB(255, 80, 80)) end)
createButton(pageSettings, "🎨 Zöld Téma", function() setAccentColor(Color3.fromRGB(80, 220, 120)) end)
createButton(pageSettings, "🎨 Lila Téma", function() setAccentColor(Color3.fromRGB(180, 100, 255)) end)
createButton(pageSettings, "🔁 Minden visszaállítása", function()
    -- reset config to defaults
    for k, v in pairs({
        WalkSpeed=16, JumpPower=50, InfJump=false, Noclip=false,
        Aimbot=false, AimSmooth=2, Godmode=false, FOV=70,
        Fullbright=false, AntiAFK=true, Fly=false, ESP=false, SilentAim=false
    }) do
        Config[k] = v
    end
    saveConfig()
    applyAllSettings()
    notify("Alaphelyzet", "Minden beállítás visszaállítva.", 3)
end)

-- Apply initial settings
applyAllSettings()

notify("Fabalta v10.0", "Fejlesztett verzió betöltve!", 3)
