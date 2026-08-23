local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

local CONFIG_FILE = "FabaltaTool_Config.json"
local Config = { ToggleKey = "F12", AccentColor = {90, 160, 255} }

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

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FabaltaTool"
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
            TweenService:Create(targetFrame, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }):Play()
        end
    end)
end

local CORRECT_KEY = "7YLhpY0bzXe9AyO5obJa2AOPhFmeIsMQ8sEG8XgE9SEbRJIW2grBBqeCTSb5viIi9d"

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
keyTitle.Text = "🔐 Kulcs Hitelesítés"
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
keyInput.ClearTextOnFocus = false
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

-- Fő Panel (Szélesebb kialakítás a bal oldali menü miatt)
local panel = Instance.new("Frame")
panel.Name = "MainPanel"
panel.Size = UDim2.new(0, 500, 0, 380)
panel.Position = UDim2.new(0.1, 0, 0.15, 0)
panel.BackgroundColor3 = THEME.Background
panel.BorderSizePixel = 0
panel.ClipsDescendants = true
panel.Visible = false
panel.Parent = screenGui

local uiScale = Instance.new("UIScale") uiScale.Scale = 1 uiScale.Parent = panel
local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 10) corner.Parent = panel
local border = Instance.new("UIStroke") border.Thickness = 1 border.Color = THEME.Border border.Parent = panel

-- Fejléc
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 38)
header.BackgroundColor3 = THEME.HeaderBg
header.BorderSizePixel = 0
header.Parent = panel

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⚙️ Fabalta Tool v8.5"
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

-- Bal oldali Menü sáv (Sidebar)
local sidebar = Instance.new("ScrollingFrame")
sidebar.Size = UDim2.new(0, 130, 1, -68)
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

-- Tartalom Terület (Jobb oldalon)
local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -140, 1, -48)
contentArea.Position = UDim2.new(0, 135, 0, 43)
contentArea.BackgroundTransparency = 1
contentArea.ClipsDescendants = false
contentArea.Parent = panel

local mainToggleKey = Enum.KeyCode[Config.ToggleKey] or Enum.KeyCode.F12
local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(0, 130, 0, 30)
footer.Position = UDim2.new(0, 0, 1, -30)
footer.BackgroundColor3 = THEME.HeaderBg
footer.BackgroundTransparency = 0.5
footer.BorderSizePixel = 0
footer.Text = "[" .. mainToggleKey.Name .. "]"
footer.TextColor3 = THEME.TextSub
footer.TextSize = 10
footer.Font = THEME.FontRegular
footer.Parent = panel

local cleanupConnections = {}
local isUnlocked = false

local function unlockSuite()
    isUnlocked = true
    keyFrame:Destroy()
    panel.Visible = true
    notify("Sikeres Belépés", "Üdvözöl a Fabalta Tool!", 3)
end

submitKeyBtn.MouseButton1Click:Connect(function()
    if keyInput.Text == CORRECT_KEY then unlockSuite() else keyInput.Text = "" keyInput.PlaceholderText = "❌ Érvénytelen kulcs!" end
end)

local isVisible = true
local function setPanelVisibility(state)
    if not isUnlocked then return end
    isVisible = state
    if not state then
        TweenService:Create(uiScale, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.In), { Scale = 0.001 }):Play()
        task.wait(0.15)
        panel.Visible = false
    else
        panel.Visible = true
        TweenService:Create(uiScale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
    end
end

closeBtn.MouseButton1Click:Connect(function()
    for _, conn in ipairs(cleanupConnections) do if conn and conn.Disconnect then conn:Disconnect() end end
    screenGui:Destroy()
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == mainToggleKey then setPanelVisibility(not isVisible) end
end)

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
    scroll.ClipsDescendants = false
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
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = THEME.Text
    label.TextSize = 11
    label.Font = THEME.FontRegular
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local track = Instance.new("TextButton")
    track.Size = UDim2.new(0, 36, 0, 18)
    track.Position = UDim2.new(1, -44, 0.5, -9)
    track.BackgroundColor3 = savedState and THEME.Accent or THEME.AccentInactive
    track.BorderSizePixel = 0
    track.Text = ""
    track.AutoButtonColor = false
    track.Parent = container
    if savedState then registerAccent(track, "BackgroundColor3") end

    local trackCorner = Instance.new("UICorner") trackCorner.CornerRadius = UDim.new(1, 0) trackCorner.Parent = track

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new(savedState and 1 or 0, savedState and -16 or 2, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = track

    local knobCorner = Instance.new("UICorner") knobCorner.CornerRadius = UDim.new(1, 0) knobCorner.Parent = knob

    local state = savedState
    local function setState(newState)
        state = newState
        Config[configKey] = state
        saveConfig()
        TweenService:Create(track, TweenInfo.new(0.15), { BackgroundColor3 = state and THEME.Accent or THEME.AccentInactive }):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), { Position = UDim2.new(state and 1 or 0, state and -16 or 2, 0.5, -7) }):Play()
        callback(state)
    end

    track.MouseButton1Click:Connect(function() setState(not state) end)
    if savedState then callback(true) end
end

local function createSlider(parentPage, configKey, labelText, minVal, maxVal, defaultVal, callback)
    local savedValue = Config[configKey] or defaultVal

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 42)
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
    sliderTrack.Position = UDim2.new(0, 10, 0, 26)
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
    btn.BackgroundColor3 = THEME.ContainerBg
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = THEME.Text
    btn.TextSize = 11
    btn.Font = THEME.FontBold
    btn.Parent = parentPage

    local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 6) c.Parent = btn

    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.08), { BackgroundColor3 = THEME.Accent }):Play()
        task.wait(0.08)
        TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = THEME.ContainerBg }):Play()
        callback()
    end)
end

local pageMovement = createTab("Mozgás")
local pageAnim = createTab("Anim")
local pageVisuals = createTab("Látvány")
local pageCombat = createTab("Harcos")
local pageUtility = createTab("Ezközök")
local pageSettings = createTab("Beállítások")

-- ================= ANIMÁCIÓS CSOMAG MENÜ =================
local animationPacks = {
    { Name = "🕺 Zombie Pack", Id = "rbxassetid://616158082" },
    { Name = "🥷 Ninja Pack", Id = "rbxassetid://656117400" },
    { Name = "🦸 Hero Pack", Id = "rbxassetid://616111295" },
    { Name = "🤖 Robot Pack", Id = "rbxassetid://616088211" },
    { Name = "💃 Dance Pack", Id = "rbxassetid://507771019" }
}

local currentTrack = nil
local selectedAnimId = animationPacks[1].Id

local animContainer = Instance.new("Frame")
animContainer.Size = UDim2.new(1, 0, 0, 75)
animContainer.BackgroundColor3 = THEME.ContainerBg
animContainer.BorderSizePixel = 0
animContainer.ZIndex = 5
animContainer.Parent = pageAnim
local acCorner = Instance.new("UICorner") acCorner.CornerRadius = UDim.new(0, 6) acCorner.Parent = animContainer

local animLabel = Instance.new("TextLabel")
animLabel.Size = UDim2.new(1, -20, 0, 18)
animLabel.Position = UDim2.new(0, 10, 0, 4)
animLabel.BackgroundTransparency = 1
animLabel.Text = "🎭 Animáció Csomagok"
animLabel.TextColor3 = THEME.Text
animLabel.TextSize = 11
animLabel.Font = THEME.FontRegular
animLabel.TextXAlignment = Enum.TextXAlignment.Left
animLabel.Parent = animContainer

local animDropdownBtn = Instance.new("TextButton")
animDropdownBtn.Size = UDim2.new(0.5, -12, 0, 26)
animDropdownBtn.Position = UDim2.new(0, 10, 0, 38)
animDropdownBtn.BackgroundColor3 = THEME.AccentInactive
animDropdownBtn.BorderSizePixel = 0
animDropdownBtn.Text = animationPacks[1].Name
animDropdownBtn.TextColor3 = THEME.Text
animDropdownBtn.TextSize = 10
animDropdownBtn.Font = THEME.FontRegular
animDropdownBtn.ZIndex = 6
animDropdownBtn.Parent = animContainer
local adbCorner = Instance.new("UICorner") adbCorner.CornerRadius = UDim.new(0, 5) adbCorner.Parent = animDropdownBtn

local toggleAnimBtn = Instance.new("TextButton")
toggleAnimBtn.Size = UDim2.new(0.5, -12, 0, 26)
toggleAnimBtn.Position = UDim2.new(0.5, 4, 0, 38)
toggleAnimBtn.BackgroundColor3 = THEME.Accent
toggleAnimBtn.BorderSizePixel = 0
toggleAnimBtn.Text = "▶ Indítás"
toggleAnimBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleAnimBtn.TextSize = 10
toggleAnimBtn.Font = THEME.FontBold
toggleAnimBtn.ZIndex = 6
toggleAnimBtn.Parent = animContainer
local tabCorner = Instance.new("UICorner") tabCorner.CornerRadius = UDim.new(0, 5) tabCorner.Parent = toggleAnimBtn
registerAccent(toggleAnimBtn, "BackgroundColor3")

local animDropdownList = Instance.new("ScrollingFrame")
animDropdownList.Size = UDim2.new(0.5, -12, 0, 100)
animDropdownList.Position = UDim2.new(0, 10, 0, 66)
animDropdownList.BackgroundColor3 = THEME.HeaderBg
animDropdownList.BorderSizePixel = 0
animDropdownList.Visible = false
animDropdownList.ZIndex = 20
animDropdownList.AutomaticCanvasSize = Enum.AutomaticSize.Y
animDropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
animDropdownList.ScrollBarThickness = 2
animDropdownList.Parent = animContainer
local adlCorner = Instance.new("UICorner") adlCorner.CornerRadius = UDim.new(0, 5) adlCorner.Parent = animDropdownList
local adlStroke = Instance.new("UIStroke") adlStroke.Color = THEME.Border adlStroke.Parent = animDropdownList

local animListLayout = Instance.new("UIListLayout") animListLayout.Parent = animDropdownList

animDropdownBtn.MouseButton1Click:Connect(function()
    animDropdownList.Visible = not animDropdownList.Visible
    if animDropdownList.Visible then
        for _, child in ipairs(animDropdownList:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
        for _, pack in ipairs(animationPacks) do
            local pBtn = Instance.new("TextButton")
            pBtn.Size = UDim2.new(1, 0, 0, 24)
            pBtn.BackgroundTransparency = 1
            pBtn.Text = pack.Name
            pBtn.TextColor3 = THEME.Text
            pBtn.TextSize = 10
            pBtn.Font = THEME.FontRegular
            pBtn.ZIndex = 21
            pBtn.Parent = animDropdownList
            pBtn.MouseButton1Click:Connect(function()
                selectedAnimId = pack.Id
                animDropdownBtn.Text = pack.Name
                animDropdownList.Visible = false
                if currentTrack then
                    currentTrack:Stop()
                    currentTrack = nil
                    toggleAnimBtn.Text = "▶ Indítás"
                end
            end)
        end
    end
end)

toggleAnimBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if currentTrack then
        currentTrack:Stop()
        currentTrack = nil
        toggleAnimBtn.Text = "▶ Indítás"
        notify("Animáció", "Animáció leállítva.", 2)
    else
        local anim = Instance.new("Animation")
        anim.AnimationId = selectedAnimId
        currentTrack = hum:LoadAnimation(anim)
        currentTrack:Play()
        toggleAnimBtn.Text = "⏹ Leállítás"
        notify("Animáció", "Animáció elindítva!", 2)
    end
end)
-- =========================================================

createSlider(pageMovement, "WalkSpeed", "⚡ Járási Sebesség", 16, 200, 16, function(val)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = val end
end)

createSlider(pageMovement, "JumpPower", "🦘 Ugrási Erő", 50, 300, 50, function(val)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.UseJumpPower = true hum.JumpPower = val end
end)

local infJumpEnabled = false
createToggle(pageMovement, "InfJump", "🦘 Végtelen Ugrás", false, function(enabled) infJumpEnabled = enabled end)

local jumpConn = UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)
table.insert(cleanupConnections, jumpConn)

local noclipEnabled, noclipConn = false, nil
createToggle(pageMovement, "Noclip", "🧱 Noclip (Falon Átjárás)", false, function(enabled)
    noclipEnabled = enabled
    if enabled then
        noclipConn = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
        table.insert(cleanupConnections, noclipConn)
    else
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
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
        table.insert(cleanupConnections, flyConn)
    else
        if flyConn then flyConn:Disconnect() flyConn = nil end
        if root then
            if root:FindFirstChild("FlyGyro") then root.FlyGyro:Destroy() end
            if root:FindFirstChild("FlyVelocity") then root.FlyVelocity:Destroy() end
        end
    end
end)

local aimbotEnabled, aimbotConn, aimSmoothness = false, nil, 0.2
createSlider(pageCombat, "AimSmooth", "🎯 Aimbot Simítás", 1, 10, 2, function(val) aimSmoothness = val / 10 end)

createToggle(pageCombat, "Aimbot", "🎯 Aimbot (RMB Hold)", false, function(enabled)
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
                    local targetCFrame = CFrame.new(Camera.CFrame.Position, closestPlayer.Character.Head.Position)
                    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, aimSmoothness)
                end
            end
        end)
        table.insert(cleanupConnections, aimbotConn)
    else
        if aimbotConn then aimbotConn:Disconnect() aimbotConn = nil end
    end
end)

local selectedFlingTarget, flinging, flingConn = nil, false, nil

local flingContainer = Instance.new("Frame")
flingContainer.Size = UDim2.new(1, 0, 0, 75)
flingContainer.BackgroundColor3 = THEME.ContainerBg
flingContainer.BorderSizePixel = 0
flingContainer.ZIndex = 5
flingContainer.Parent = pageCombat
local fcCorner = Instance.new("UICorner") fcCorner.CornerRadius = UDim.new(0, 6) fcCorner.Parent = flingContainer

local flingLabel = Instance.new("TextLabel")
flingLabel.Size = UDim2.new(1, -20, 0, 18)
flingLabel.Position = UDim2.new(0, 10, 0, 4)
flingLabel.BackgroundTransparency = 1
flingLabel.Text = "🌀 Fling (Kilövés)"
flingLabel.TextColor3 = THEME.Text
flingLabel.TextSize = 11
flingLabel.Font = THEME.FontRegular
flingLabel.TextXAlignment = Enum.TextXAlignment.Left
flingLabel.Parent = flingContainer

local flingDropdownBtn = Instance.new("TextButton")
flingDropdownBtn.Size = UDim2.new(0.5, -12, 0, 26)
flingDropdownBtn.Position = UDim2.new(0, 10, 0, 38)
flingDropdownBtn.BackgroundColor3 = THEME.AccentInactive
flingDropdownBtn.BorderSizePixel = 0
flingDropdownBtn.Text = "Célpont..."
flingDropdownBtn.TextColor3 = THEME.TextSub
flingDropdownBtn.TextSize = 10
flingDropdownBtn.Font = THEME.FontRegular
flingDropdownBtn.ZIndex = 6
flingDropdownBtn.Parent = flingContainer
local fdbCorner = Instance.new("UICorner") fdbCorner.CornerRadius = UDim.new(0, 5) fdbCorner.Parent = flingDropdownBtn

local executeFlingBtn = Instance.new("TextButton")
executeFlingBtn.Size = UDim2.new(0.5, -12, 0, 26)
executeFlingBtn.Position = UDim2.new(0.5, 4, 0, 38)
executeFlingBtn.BackgroundColor3 = THEME.Accent
executeFlingBtn.BorderSizePixel = 0
executeFlingBtn.Text = "🚀 Indítás"
executeFlingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
executeFlingBtn.TextSize = 10
executeFlingBtn.Font = THEME.FontBold
executeFlingBtn.ZIndex = 6
executeFlingBtn.Parent = flingContainer
local efCorner = Instance.new("UICorner") efCorner.CornerRadius = UDim.new(0, 5) efCorner.Parent = executeFlingBtn
registerAccent(executeFlingBtn, "BackgroundColor3")

local flingDropdownList = Instance.new("ScrollingFrame")
flingDropdownList.Size = UDim2.new(0.5, -12, 0, 90)
flingDropdownList.Position = UDim2.new(0, 10, 0, 66)
flingDropdownList.BackgroundColor3 = THEME.HeaderBg
flingDropdownList.BorderSizePixel = 0
flingDropdownList.Visible = false
flingDropdownList.ZIndex = 20
flingDropdownList.AutomaticCanvasSize = Enum.AutomaticSize.Y
flingDropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
flingDropdownList.ScrollBarThickness = 2
flingDropdownList.Parent = flingContainer
local fdlCorner = Instance.new("UICorner") fdlCorner.CornerRadius = UDim.new(0, 5) fdlCorner.Parent = flingDropdownList
local fdlStroke = Instance.new("UIStroke") fdlStroke.Color = THEME.Border fdlStroke.Parent = flingDropdownList

local fListLayout = Instance.new("UIListLayout") fListLayout.Parent = flingDropdownList

flingDropdownBtn.MouseButton1Click:Connect(function()
    flingDropdownList.Visible = not flingDropdownList.Visible
    if flingDropdownList.Visible then
        for _, child in ipairs(flingDropdownList:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local pBtn = Instance.new("TextButton")
                pBtn.Size = UDim2.new(1, 0, 0, 22)
                pBtn.BackgroundTransparency = 1
                pBtn.Text = p.DisplayName
                pBtn.TextColor3 = THEME.Text
                pBtn.TextSize = 10
                pBtn.Font = THEME.FontRegular
                pBtn.ZIndex = 21
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
        executeFlingBtn.Text = "🚀 Indítás"
        notify("Fling", "Fling leállítva.", 2)
        return
    end

    if selectedFlingTarget and selectedFlingTarget.Character and selectedFlingTarget.Character:FindFirstChild("HumanoidRootPart") then
        flinging = true
        executeFlingBtn.Text = "🛑 Leállítás"
        notify("Fling", "Fling aktív: " .. selectedFlingTarget.DisplayName, 3)

        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local angle = 0
        flingConn = RunService.Heartbeat:Connect(function()
            if not flinging or not myRoot or not selectedFlingTarget.Character or not selectedFlingTarget.Character:FindFirstChild("HumanoidRootPart") then
                flinging = false
                if flingConn then flingConn:Disconnect() end
                executeFlingBtn.Text = "🚀 Indítás"
                return
            end
            local targetRoot = selectedFlingTarget.Character.HumanoidRootPart
            angle = angle + 100
            myRoot.Velocity = Vector3.new(10000, 10000, 10000)
            myRoot.CFrame = targetRoot.CFrame * CFrame.Angles(0, math.rad(angle), 0) * CFrame.new(0, 0, 1.5)
        end)
        table.insert(cleanupConnections, flingConn)
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

createToggle(pageCombat, "Invisibility", "👻 Láthatatlanság", false, function(enabled)
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

        local highlight = Instance.new("Highlight")
        highlight.Adornee = character
        highlight.FillColor = THEME.Accent
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.Parent = character

        local billboard = Instance.new("BillboardGui")
        billboard.Adornee = head
        billboard.Size = UDim2.new(0, 100, 0, 30)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.AlwaysOnTop = true

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = player.DisplayName
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 10
        label.Font = THEME.FontBold
        label.Parent = billboard
        billboard.Parent = head

        espCache[player] = { Highlight = highlight, Billboard = billboard }
    end

    if player.Character then setupCharacter(player.Character) end
    player.CharacterAdded:Connect(setupCharacter)
end

createToggle(pageVisuals, "ESP", "👁️ Játékos ESP (Kiemelés)", false, function(enabled)
    espEnabled = enabled
    if enabled then
        for _, p in ipairs(Players:GetPlayers()) do applyEsp(p) end
    else
        for p, _ in pairs(espCache) do removeEsp(p) end
    end
end)

createButton(pageUtility, "🌀 Szerver Újracsatlakozás", function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)

createButton(pageSettings, "🎨 Kék Téma", function() setAccentColor(Color3.fromRGB(90, 160, 255)) end)
createButton(pageSettings, "🎨 Piros Téma", function() setAccentColor(Color3.fromRGB(255, 80, 80)) end)
createButton(pageSettings, "🎨 Zöld Téma", function() setAccentColor(Color3.fromRGB(80, 220, 120)) end)
createButton(pageSettings, "🎨 Lila Téma", function() setAccentColor(Color3.fromRGB(180, 100, 255)) end)
