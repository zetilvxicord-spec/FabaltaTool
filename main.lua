--[[
    Fabalta Tool v10.3 – Max Edition (Key Close Button Added)
    KEY IS HARDCODED INSIDE THE SCRIPT
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local AssetService = game:GetService("AssetService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- ================================================
--  CHANGE THIS KEY TO YOUR PREFERRED PASSWORD
-- ================================================
local CORRECT_KEY = "7YLhpY0bzXe9AyO5obJa2AOPhFmeIsMQ8sEG8XgE9SEbRJIW2grBBqeCTSb5viIi9d"
-- ================================================

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
    AnimPack = "Default",
    BundleID = "",
    AnimIdle = "",
    AnimWalk = "",
    AnimRun = "",
    AnimJump = "",
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
keyTitle.Size = UDim2.new(1, -40, 0, 45)
keyTitle.Position = UDim2.new(0, 12, 0, 0)
keyTitle.BackgroundTransparency = 1
keyTitle.Text = "🔐 Fabalta Kulcs Hitelesítés"
keyTitle.TextColor3 = THEME.Text
keyTitle.TextSize = 14
keyTitle.Font = THEME.FontBold
keyTitle.TextXAlignment = Enum.TextXAlignment.Left
keyTitle.Parent = keyFrame

local keyCloseBtn = Instance.new("TextButton")
keyCloseBtn.Size = UDim2.new(0, 22, 0, 22)
keyCloseBtn.Position = UDim2.new(1, -28, 0, 11)
keyCloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
keyCloseBtn.BorderSizePixel = 0
keyCloseBtn.Text = "X"
keyCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
keyCloseBtn.TextSize = 11
keyCloseBtn.Font = THEME.FontBold
keyCloseBtn.Parent = keyFrame
local kcCorner = Instance.new("UICorner") kcCorner.CornerRadius = UDim.new(0, 5) kcCorner.Parent = keyCloseBtn

keyCloseBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

local keyInput = Instance.new("TextBox")
keyInput.Size = UDim2.new(0.88, 0, 0, 36)
keyInput.Position = UDim2.new(0.06, 0, 0.35, 0)
keyInput.BackgroundColor3 = THEME.ContainerBg
keyInput.BorderSizePixel = 0
keyInput.PlaceholderText = "Add meg a kulcsot..."
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
panel.Size = UDim2.new(0, 580, 0, 460)
panel.Position = UDim2.new(0.1, 0, 0.15, 0)
panel.BackgroundColor3 = THEME.Background
panel.BorderSizePixel = 0
panel.ClipsDescendants = true
panel.Visible = false
panel.Parent = screenGui

local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 10) corner.Parent = panel
local border = Instance.new("UIStroke") border.Thickness = 1 border.Color = THEME.Border border.Parent = panel

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 38)
header.BackgroundColor3 = THEME.HeaderBg
header.BorderSizePixel = 0
header.Parent = panel

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⚙️ Fabalta Tool v10.3 (Max Edition)"
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
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 11
closeBtn.Font = THEME.FontBold
closeBtn.Parent = header
local cCorner = Instance.new("UICorner") cCorner.CornerRadius = UDim.new(0, 5) cCorner.Parent = closeBtn

makeDraggable(header, panel)

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

-- Forward declare animation functions
local applyAnimationPack

-- ========== UNLOCK ==========
local isUnlocked = false
local function unlockSuite()
    isUnlocked = true
    keyFrame:Destroy()
    panel.Visible = true
    notify("Sikeres Belépés", "Minden modul aktív.", 3)
    task.wait(0.5)
    applyAnimationPack()
end

submitKeyBtn.MouseButton1Click:Connect(function()
    if keyInput.Text == CORRECT_KEY then
        unlockSuite()
    else
        keyInput.Text = ""
        keyInput.PlaceholderText = "❌ Hibás kulcs!"
    end
end)

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

local function createTextBox(parentPage, configKey, labelText, placeholder, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 48)
    container.BackgroundColor3 = THEME.ContainerBg
    container.BorderSizePixel = 0
    container.Parent = parentPage
    local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 6) c.Parent = container

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = THEME.Text
    label.TextSize = 11
    label.Font = THEME.FontBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.5, -20, 0, 28)
    box.Position = UDim2.new(0.45, 0, 0, 12)
    box.BackgroundColor3 = THEME.Background
    box.BorderSizePixel = 0
    box.Text = Config[configKey] or ""
    box.PlaceholderText = placeholder
    box.TextColor3 = THEME.Text
    box.PlaceholderColor3 = THEME.TextSub
    box.TextSize = 11
    box.Font = THEME.FontRegular
    box.Parent = container
    local boxCorner = Instance.new("UICorner") boxCorner.CornerRadius = UDim.new(0, 4) boxCorner.Parent = box

    box:GetPropertyChangedSignal("Text"):Connect(function()
        Config[configKey] = box.Text
        saveConfig()
        pcall(callback)
    end)
end

-- ========== TABS ==========
local pageMovement = createTab("Mozgás")
local pageCombat = createTab("Harc")
local pageVisuals = createTab("Látvány")
local pageUtility = createTab("Eszközök")
local pageAnim = createTab("Animációk")
local pageSettings = createTab("Beállítások")

-- ========== FEATURES ==========

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

local function applyAllSettings()
    local hum = getHumanoid()
    if hum then
        pcall(function()
            hum.WalkSpeed = Config.WalkSpeed
            hum.JumpPower = Config.JumpPower
            hum.UseJumpPower = true
            if Config.Godmode then
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            else
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
            end
        end)
    end
    pcall(function()
        Camera.FieldOfView = Config.FOV
        Lighting.Brightness = Config.Fullbright and 3 or 1
        Lighting.ClockTime = Config.Fullbright and 14 or 12
        Lighting.GlobalShadows = not Config.Fullbright
    end)
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    applyAllSettings()
    applyAnimationPack()
end)

-- ========== ANIMATION PACK SYSTEM (BUNDLE & NATIVE OVERRIDE) ==========
applyAnimationPack = function()
    local char = getChar()
    if not char then return end
    local animate = char:FindFirstChild("Animate")
    if not animate then return end

    local pack = Config.AnimPack
    local idleId, walkId, runId, jumpId

    if Config.BundleID and Config.BundleID ~= "" then
        local bundleNum = tonumber(Config.BundleID:gsub("%D+", ""))
        if bundleNum then
            local success, assetIds = pcall(function()
                return AssetService:GetAssetIdsForPackage(bundleNum)
            end)
            if success and assetIds then
                for _, id in ipairs(assetIds) do
                    pcall(function()
                        local info = game:GetService("MarketplaceService"):GetProductInfo(id)
                        if info and info.AssetTypeId == 24 then
                            local nameLower = string.lower(info.Name)
                            if string.find(nameLower, "idle") then idleId = tostring(id)
                            elseif string.find(nameLower, "walk") then walkId = tostring(id)
                            elseif string.find(nameLower, "run") then runId = tostring(id)
                            elseif string.find(nameLower, "jump") then jumpId = tostring(id)
                            end
                        end
                    end)
                end
            end
        end
    end

    if not idleId or idleId == "" then
        if pack == "Ninja" then
            idleId, walkId, runId, jumpId = "12114635098", "12114635100", "12114635102", "12114635104"
        elseif pack == "Robot" then
            idleId, walkId, runId, jumpId = "6150272929", "6150272946", "6150272961", "6150272980"
        elseif pack == "Cartoon" then
            idleId, walkId, runId, jumpId = "5077696589", "5077696597", "5077696603", "5077696609"
        elseif pack == "Custom" then
            idleId, walkId, runId, jumpId = Config.AnimIdle, Config.AnimWalk, Config.AnimRun, Config.AnimJump
        end
    end

    pcall(function()
        if pack == "Default" and (not Config.BundleID or Config.BundleID == "") then
            return
        end

        if idleId and idleId ~= "" and animate:FindFirstChild("idle") then
            for _, anim in ipairs(animate.idle:GetChildren()) do
                if anim:IsA("Animation") then anim.AnimationId = "rbxassetid://" .. idleId:gsub("%D+", "") end
            end
        end
        if walkId and walkId ~= "" and animate:FindFirstChild("walk") then
            for _, anim in ipairs(animate.walk:GetChildren()) do
                if anim:IsA("Animation") then anim.AnimationId = "rbxassetid://" .. walkId:gsub("%D+", "") end
            end
        end
        if runId and runId ~= "" and animate:FindFirstChild("run") then
            for _, anim in ipairs(animate.run:GetChildren()) do
                if anim:IsA("Animation") then anim.AnimationId = "rbxassetid://" .. runId:gsub("%D+", "") end
            end
        end
        if jumpId and jumpId ~= "" and animate:FindFirstChild("jump") then
            for _, anim in ipairs(animate.jump:GetChildren()) do
                if anim:IsA("Animation") then anim.AnimationId = "rbxassetid://" .. jumpId:gsub("%D+", "") end
            end
        end
    end)
end

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
    if not enabled and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide == false then
                part.CanCollide = true
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if Config.Noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and not part.Anchored then
                part.CanCollide = false
            end
        end
    end
end)

local flyBodyVelocity = nil
local function setupFly()
    local root = getRoot()
    if not root then return end
    if not flyBodyVelocity then
        flyBodyVelocity = Instance.new("BodyVelocity")
        flyBodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        flyBodyVelocity.P = 1e5
        flyBodyVelocity.Parent = root
    end
end

local function removeFly()
    if flyBodyVelocity then
        flyBodyVelocity:Destroy()
        flyBodyVelocity = nil
    end
end

createToggle(pageMovement, "Fly", "✈️ Repülés (Szóköz/SHIFT)", false, function(enabled)
    Config.Fly = enabled
    if enabled then
        setupFly()
    else
        removeFly()
        local hum = getHumanoid()
        if hum then
            hum.PlatformStand = false
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if Config.Fly and LocalPlayer.Character then
        local root = getRoot()
        if not root then
            removeFly()
            return
        end
        if not flyBodyVelocity or flyBodyVelocity.Parent ~= root then
            setupFly()
        end
        local moveDir = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector * Vector3.new(1,0,1) end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector * Vector3.new(1,0,1) end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0,1,0) end
        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit * 60
            flyBodyVelocity.Velocity = moveDir
        else
            flyBodyVelocity.Velocity = Vector3.new(0,0,0)
        end
    elseif not Config.Fly and flyBodyVelocity then
        removeFly()
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

createToggle(pageCombat, "SilentAim", "🎯 Silent Aimbot (Auto-lock)", false, function(enabled)
    Config.SilentAim = enabled
end)

RunService.Heartbeat:Connect(function()
    if Config.SilentAim then
        local closestPlayer, closestDist = nil, math.huge
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
            pcall(function()
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestPlayer.Character.Head.Position)
            end)
        end
    end
end)

createToggle(pageCombat, "Godmode", "🛡️ Istenmód (Halhatatlanság)", false, function(enabled)
    Config.Godmode = enabled
    local hum = getHumanoid()
    if hum then
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, not enabled)
    end
end)

-- ===== LÁTVÁNY =====
createSlider(pageVisuals, "FOV", "👁️ Kamera FOV", 70, 120, 70, function(val)
    Config.FOV = val
    Camera.FieldOfView = val
end)

createToggle(pageVisuals, "Fullbright", "☀️ Teljes Fényerő (Fullbright)", false, function(enabled)
    Config.Fullbright = enabled
    Lighting.Brightness = enabled and 3 or 1
    Lighting.ClockTime = enabled and 14 or 12
    Lighting.GlobalShadows = not enabled
end)

local espHighlights = {}
createToggle(pageVisuals, "ESP", "👥 Játékos ESP (Kiemelés)", false, function(enabled)
    Config.ESP = enabled
    if not enabled then
        for _, hl in pairs(espHighlights) do
            if hl then hl:Destroy() end
        end
        espHighlights = {}
    end
end)

RunService.Heartbeat:Connect(function()
    if Config.ESP then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                if not espHighlights[p] then
                    local highlight = Instance.new("Highlight")
                    highlight.Adornee = p.Character
                    highlight.FillColor = THEME.Accent
                    highlight.OutlineColor = Color3.new(255, 255, 255)
                    highlight.FillTransparency = 0.5
                    highlight.Parent = p.Character
                    espHighlights[p] = highlight
                end
            elseif espHighlights[p] then
                espHighlights[p]:Destroy()
                espHighlights[p] = nil
            end
        end
    end
end)

-- ===== ESZKÖZÖK =====
createToggle(pageUtility, "AntiAFK", "💤 Anti-AFK (Rendszer)", true, function(enabled)
    Config.AntiAFK = enabled
end)

local vu = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    if Config.AntiAFK then
        vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        notify("Anti-AFK", "Kick megakadályozva.", 2)
    end
end)

createButton(pageUtility, "🔄 Újracsatlakozás (Rejoin)", function()
    local ts = game:GetService("TeleportService")
    ts:Teleport(game.PlaceId, LocalPlayer)
end)

createButton(pageUtility, "📦 Reset Karakter", function()
    local hum = getHumanoid()
    if hum then hum.Health = 0 end
end)

-- ===== ANIMÁCIÓK =====
createTextBox(pageAnim, "BundleID", "📦 Bundle ID (Csomag)", "Írd ide a Bundle ID-t...", function() applyAnimationPack() end)

createButton(pageAnim, "🔄 Animáció Csomag Frissítése", function()
    applyAnimationPack()
    notify("Animációk", "Csomag / Bundle betöltve.", 2)
end)

createTextBox(pageAnim, "AnimIdle", "Egyedi Idle ID", "Add meg az ID-t...", function() applyAnimationPack() end)
createTextBox(pageAnim, "AnimWalk", "Egyedi Walk ID", "Add meg az ID-t...", function() applyAnimationPack() end)
createTextBox(pageAnim, "AnimRun", "Egyedi Run ID", "Add meg az ID-t...", function() applyAnimationPack() end)
createTextBox(pageAnim, "AnimJump", "Egyedi Jump ID", "Add meg az ID-t...", function() applyAnimationPack() end)

-- ===== BEÁLLÍTÁSOK =====
createTextBox(pageSettings, "ToggleKey", "Menü Gyorsbillentyű", "Pl. F12", function()
    notify("Beállítások", "Gyorsbillentyű frissítve.", 2)
    footer.Text = "[" .. Config.ToggleKey .. "]"
end)

createButton(pageSettings, "💾 Konfiguráció Mentése", function()
    saveConfig()
    notify("Mentés", "A beállítások elmentve.", 2)
end)

applyAllSettings()
