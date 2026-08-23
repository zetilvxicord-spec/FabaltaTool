-- =====================================================================
--  FABALTA TOOL v7.1 – Magyar Kiadás
--  Téma: Obsidian Glass UI | Alapértelmezett gomb: F12 | Kulcs: TOOLSUITE2026
-- =====================================================================

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

-- ----------------------------------------------------------------
--  BEÁLLÍTÁSOK ÉS TÉMA RENDSZER
-- ----------------------------------------------------------------
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

-- ----------------------------------------------------------------
--  FŐ KÉPERNYŐ GUI ÉS ÉRTESÍTÉSEK
-- ----------------------------------------------------------------
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

-- ----------------------------------------------------------------
--  SEGÉDFUNKCIÓK: MOZGATHATÓ ABLAKOK
-- ----------------------------------------------------------------
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

-- ----------------------------------------------------------------
--  KULCS RENDSZER ABLAK
-- ----------------------------------------------------------------
local CORRECT_KEY = "TOOLSUITE2026"

local keyFrame = Instance.new("Frame")
keyFrame.Name = "KeyLock"
keyFrame.Size = UDim2.new(0, 320, 0, 180)
keyFrame.Position = UDim2.new(0.5, -160, 0.4, -90)
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
keyInput.TextSize = 13
keyInput.Font = THEME.FontRegular
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

-- ----------------------------------------------------------------
--  FŐPANEL
-- ----------------------------------------------------------------
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
titleLabel.Text = "⚙️ Fabalta Tool v7.1"
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
    notify("Rendszer Feloldva", "Üdvözöl a Fabalta Tool!", 4)
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

-- ----------------------------------------------------------------
--  UI ELEMEK KERETRENDSZERE
-- ----------------------------------------------------------------
local tabs = {}
local currentTab = nil

local function createTab(name)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0.235, 0, 1, 0)
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
    scroll.ScrollBarThickness = 3
    registerAccent(scroll, "ScrollBarImageColor3")
    scroll.Visible = false
    scroll.Parent = contentArea

    local list = Instance.new("UIListLayout")
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 8)
    list.Parent = scroll

    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 10)
    end)

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

-- Fő kategóriák (Tabs)
local pageMovement = createTab("Mozgás")
local pageVisuals = createTab("Látvány")
local pageUtility = createTab("Ezközök")
local pageSettings = createTab("Beállítások")

-- ----------------------------------------------------------------
--  FUNKCIÓK MEGVALÓSÍTÁSA
-- ----------------------------------------------------------------

-- --- MOZGÁS FUNKCIÓK ---
createSlider(pageMovement, "WalkSpeed", "⚡ Járási Sebesség", 16, 200, 16, function(val)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = val end
end)

createSlider(pageMovement, "JumpPower", "🦘 Ugrási Erő", 50, 300, 50, function(val)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.UseJumpPower = true hum.JumpPower = val end
end)

-- Repülés (Fly Engine)
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

-- Teleportálás Játékosokhoz
local tpContainer = Instance.new("Frame")
tpContainer.Size = UDim2.new(1, 0, 0, 75)
tpContainer.BackgroundTransparency = 1
tpContainer.Parent = pageMovement

local tpLabel = Instance.new("TextLabel")
tpLabel.Size = UDim2.new(1, 0, 0, 18)
tpLabel.BackgroundTransparency = 1
tpLabel.Text = "📍 Játékos Teleport"
tpLabel.TextColor3 = THEME.Text
tpLabel.TextSize = 13
tpLabel.Font = THEME.FontRegular
tpLabel.TextXAlignment = Enum.TextXAlignment.Left
tpLabel.Parent = tpContainer

local selectedPlayer = nil
local tpDropdownBtn = Instance.new("TextButton")
tpDropdownBtn.Size = UDim2.new(1, 0, 0, 26)
tpDropdownBtn.Position = UDim2.new(0, 0, 0, 22)
tpDropdownBtn.BackgroundColor3 = THEME.AccentInactive
tpDropdownBtn.Text = "Válassz Célpontot..."
tpDropdownBtn.TextColor3 = THEME.TextSub
tpDropdownBtn.TextSize = 11
tpDropdownBtn.Font = THEME.FontRegular
tpDropdownBtn.Parent = tpContainer
local tpdCorner = Instance.new("UICorner") tpdCorner.CornerRadius = UDim.new(0, 6) tpdCorner.Parent = tpDropdownBtn

local executeTpBtn = Instance.new("TextButton")
executeTpBtn.Size = UDim2.new(1, 0, 0, 24)
executeTpBtn.Position = UDim2.new(0, 0, 0, 52)
executeTpBtn.BackgroundColor3 = THEME.Accent
executeTpBtn.Text = "Teleportálás Most"
executeTpBtn.TextColor3 = THEME.Text
executeTpBtn.TextSize = 11
executeTpBtn.Font = THEME.FontBold
executeTpBtn.Parent = tpContainer
local etpCorner = Instance.new("UICorner") etpCorner.CornerRadius = UDim.new(0, 6) etpCorner.Parent = executeTpBtn
registerAccent(executeTpBtn, "BackgroundColor3")

local dropdownList = Instance.new("ScrollingFrame")
dropdownList.Size = UDim2.new(1, 0, 0, 100)
dropdownList.Position = UDim2.new(0, 0, 0, 48)
dropdownList.BackgroundColor3 = THEME.Background
dropdownList.BorderSizePixel = 1
dropdownList.BorderColor3 = THEME.Border
dropdownList.Visible = false
dropdownList.ZIndex = 10
dropdownList.Parent = tpContainer

local dListLayout = Instance.new("UIListLayout") dListLayout.Parent = dropdownList

tpDropdownBtn.MouseButton1Click:Connect(function()
    dropdownList.Visible = not dropdownList.Visible
    if dropdownList.Visible then
        for _, child in ipairs(dropdownList:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local pBtn = Instance.new("TextButton")
                pBtn.Size = UDim2.new(1, 0, 0, 22)
                pBtn.BackgroundColor3 = THEME.AccentInactive
                pBtn.Text = p.DisplayName .. " (@" .. p.Name .. ")"
                pBtn.TextColor3 = THEME.Text
                pBtn.TextSize = 10
                pBtn.Font = THEME.FontRegular
                pBtn.ZIndex = 11
                pBtn.Parent = dropdownList
                pBtn.MouseButton1Click:Connect(function()
                    selectedPlayer = p
                    tpDropdownBtn.Text = p.DisplayName
                    dropdownList.Visible = false
                end)
            end
        end
        dropdownList.CanvasSize = UDim2.new(0, 0, 0, #Players:GetPlayers() * 22)
    end
end)

executeTpBtn.MouseButton1Click:Connect(function()
    if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myRoot then
            myRoot.CFrame = selectedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
            notify("Teleport", "Sikeres teleportálás hozzá: " .. selectedPlayer.DisplayName, 2)
        end
    else
        notify("Teleport Hiba", "Érvénytelen vagy hiányzó célpont.", 2)
    end
end)

-- Szabad kamera (Freecam)
local freecamEnabled, freecamConn = false, nil
createToggle(pageMovement, "Freecam", "🎥 Szabad Kamera", false, function(enabled)
    freecamEnabled = enabled
    if enabled then
        Camera.CameraType = Enum.CameraType.Scriptable
        freecamConn = RunService.RenderStepped:Connect(function()
            if not freecamEnabled then return end
            local speed = 1.5
            local camCF = Camera.CFrame
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then camCF = camCF * CFrame.new(0,0,-speed) end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then camCF = camCF * CFrame.new(0,0,speed) end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then camCF = camCF * CFrame.new(-speed,0,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then camCF = camCF * CFrame.new(speed,0,0) end
            Camera.CFrame = camCF
        end)
    else
        if freecamConn then freecamConn:Disconnect() freecamConn = nil end
        Camera.CameraType = Enum.CameraType.Custom
    end
end)


-- --- LÁTVÁNY FUNKCIÓK ---

-- Látószög (FOV)
createSlider(pageVisuals, "FOV", "🔍 Látószög (FOV)", 60, 120, 70, function(val) Camera.FieldOfView = val end)

-- Player ESP & Chams
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

-- Nyomvonal Vonalak (Tracers)
local tracersEnabled, tracerLines, tracerConn = false, {}
createToggle(pageVisuals, "Tracers", "📐 Nyomvonalak (Tracers)", false, function(enabled)
    tracersEnabled = enabled
    if enabled then
        tracerConn = RunService.RenderStepped:Connect(function()
            for _, line in pairs(tracerLines) do line.Visible = false end
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local targetPos, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                    if onScreen then
                        local line = tracerLines[p]
                        if not line then
                            line = Instance.new("Frame")
                            line.AnchorPoint = Vector2.new(0.5, 0.5)
                            line.BackgroundColor3 = THEME.Accent
                            line.BorderSizePixel = 0
                            line.Parent = screenGui
                            tracerLines[p] = line
                        end
                        local startPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        local endPos = Vector2.new(targetPos.X, targetPos.Y)
                        local distance = (endPos - startPos).Magnitude
                        local angle = math.atan2(endPos.Y - startPos.Y, endPos.X - startPos.X)

                        line.Size = UDim2.new(0, distance, 0, 1.5)
                        line.Position = UDim2.new(0, (startPos.X + endPos.X) / 2, 0, (startPos.Y + endPos.Y) / 2)
                        line.Rotation = math.deg(angle)
                        line.Visible = true
                    end
                end
            end
        end)
    else
        if tracerConn then tracerConn:Disconnect() tracerConn = nil end
        for _, line in pairs(tracerLines) do line:Destroy() end
        table.clear(tracerLines)
    end
end)

-- Világítás Módosítása
createSlider(pageVisuals, "TimeOfDay", "☀️ Napszak (Óra)", 0, 24, 14, function(val)
    Lighting.ClockTime = val
end)

createToggle(pageVisuals, "NoFog", "🌫️ Köd & Árnyékok Törlése", false, function(enabled)
    Lighting.FogEnd = enabled and 1e6 or 10000
    Lighting.GlobalShadows = not enabled
end)


-- --- ESZKÖZÖK (UTILITY) ---

-- Server Hop & Rejoin
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

-- Btools (Kattintásos Törlés)
local btoolsEnabled = false
createToggle(pageUtility, "Btools", "🔨 Btools (Alt+Kattintás a Törléshez)", false, function(enabled) btoolsEnabled = enabled end)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed or not btoolsEnabled then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) then
        local mousePos = UserInputService:GetMouseLocation()
        local ray = Camera:ViewportPointToRay(mousePos.X, mousePos.Y)
        local res = workspace:Raycast(ray.Origin, ray.Direction * 2000)
        if res and res.Instance and not res.Instance:IsA("Terrain") then
            res.Instance:Destroy()
            notify("Btools", "Elem törölve helyileg.", 2)
        end
    end
end)

-- Makró Rögzítő (Macro Player)
local macroRecording, macroPlaying = false, false
local recordedInputs = {}

createButton(pageUtility, "🔴 Makró Rögzítése", function()
    if macroRecording then
        macroRecording = false
        notify("Makró Rögzítő", #recordedInputs .. " billentyűleütés elmentve.", 3)
    else
        table.clear(recordedInputs)
        macroRecording = true
        notify("Makró Rögzítő", "Rögzítés... Nyomj meg billentyűket.", 3)
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if macroRecording and not processed and input.UserInputType == Enum.UserInputType.Keyboard then
        table.insert(recordedInputs, { Key = input.KeyCode, Delay = 0.2 })
    end
end)

createButton(pageUtility, "▶️ Makró Lejátszása", function()
    if #recordedInputs == 0 then notify("Makró Rögzítő", "Nincs rögzített makró!", 2) return end
    if macroPlaying then return end
    macroPlaying = true
    notify("Makró Rögzítő", "Makró lejátszása...", 2)
    task.spawn(function()
        for _, action in ipairs(recordedInputs) do
            VirtualUser:CaptureController()
            VirtualUser:SetKeyDown(action.Key.Name)
            task.wait(0.05)
            VirtualUser:SetKeyUp(action.Key.Name)
            task.wait(action.Delay)
        end
        macroPlaying = false
        notify("Makró Rögzítő", "Makró befejeződött.", 2)
    end)
end)

-- Auto-Clicker
local autoClicking, clickCps, clickTask = false, 10, nil
createSlider(pageUtility, "ClickCPS", "🖱️ Auto-Clicker Gyorsaság (CPS)", 1, 30, 10, function(val) clickCps = val end)
createToggle(pageUtility, "AutoClicker", "🖱️ Auto-Clicker Kapcsoló", false, function(enabled)
    autoClicking = enabled
    if enabled then
        clickTask = task.spawn(function()
            while autoClicking do
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2))
                task.wait(1 / clickCps)
            end
        end)
    else
        if clickTask then task.cancel(clickTask) clickTask = nil end
    end
end)

-- Anti-AFK
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


-- --- BEÁLLÍTÁSOK ---

-- Téma Színválasztó
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

-- Menü Gomb Átállítása
local keybindContainer = Instance.new("Frame")
keybindContainer.Size = UDim2.new(1, 0, 0, 36)
keybindContainer.BackgroundTransparency = 1
keybindContainer.Parent = pageSettings

local kbLabel = Instance.new("TextLabel")
kbLabel.Size = UDim2.new(0.5, 0, 1, 0)
kbLabel.BackgroundTransparency = 1
kbLabel.Text = "⌨️ UI Megnyitása Gomb"
kbLabel.TextColor3 = THEME.Text
kbLabel.TextSize = 13
kbLabel.Font = THEME.FontRegular
kbLabel.TextXAlignment = Enum.TextXAlignment.Left
kbLabel.Parent = keybindContainer

local kbBtn = Instance.new("TextButton")
kbBtn.Size = UDim2.new(0.45, 0, 0.8, 0)
kbBtn.Position = UDim2.new(0.55, 0, 0.1, 0)
kbBtn.BackgroundColor3 = THEME.AccentInactive
kbBtn.Text = mainToggleKey.Name
kbBtn.TextColor3 = THEME.Text
kbBtn.TextSize = 12
kbBtn.Font = THEME.FontBold
kbBtn.Parent = keybindContainer
local kbCorner = Instance.new("UICorner") kbCorner.CornerRadius = UDim.new(0, 6) kbCorner.Parent = kbBtn

local listeningForToggle = false
kbBtn.MouseButton1Click:Connect(function()
    kbBtn.Text = "Nyomj gombot..."
    listeningForToggle = true
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if not listeningForToggle or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    mainToggleKey = input.KeyCode
    kbBtn.Text = mainToggleKey.Name
    footer.Text = "Nyomd meg a [" .. mainToggleKey.Name .. "] gombot az elrejtéshez"
    Config.ToggleKey = mainToggleKey.Name
    saveConfig()
    listeningForToggle = false
end)
