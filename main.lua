-- [[ SENZY HUB - STANDALONE UI FRAMEWORK ENGINE ]] --
-- GitHub Raw Ready Script Library

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local RAW_LOGO_URL   = "https://raw.githubusercontent.com/senzxyz2xxx/SenzyHub/refs/heads/main/senz2.png"
local RAW_BANNER_URL = "https://raw.githubusercontent.com/senzxyz2xxx/SenzyHub/refs/heads/main/banners1.png"

local Library = {
    Flags = {},
    Connections = {},
    ConfigFolder = "SenzyHubConfigs",
    Theme = {
        BG_Dark        = Color3.fromRGB(8, 8, 13),
        BG_Panel       = Color3.fromRGB(13, 13, 20),
        BG_Surface     = Color3.fromRGB(17, 17, 25),
        BG_Container   = Color3.fromRGB(23, 23, 32),
        Accent_Main    = Color3.fromRGB(255, 79, 163),
        Accent_Hover   = Color3.fromRGB(255, 92, 173),
        Accent_Glow    = Color3.fromRGB(255, 119, 183),
        Accent_Dark    = Color3.fromRGB(232, 62, 140),
        Text_Primary   = Color3.fromRGB(255, 255, 255),
        Text_Secondary = Color3.fromRGB(232, 232, 237),
        Text_Dark      = Color3.fromRGB(167, 167, 179),
        Border         = Color3.fromRGB(38, 38, 52),
        Status_Green   = Color3.fromRGB(53, 229, 140),
        Status_Yellow  = Color3.fromRGB(255, 204, 102),
        Status_Red     = Color3.fromRGB(255, 92, 108)
    },
    Keybinds = { ToggleUI = Enum.KeyCode.LeftControl }
}

-- Asset Cache
local cachedAssets = {}
local function createCachedImage(url, filename, parent)
    local img = Instance.new("ImageLabel")
    img.BackgroundTransparency = 1
    img.ScaleType = Enum.ScaleType.Fit
    img.Parent = parent

    if cachedAssets[filename] then
        img.Image = cachedAssets[filename]
        return img
    end

    task.spawn(function()
        if getcustomasset and writefile and isfile then
            if not isfile(filename) then
                local success, data = pcall(function() return game:HttpGet(url) end)
                if success and data then pcall(function() writefile(filename, data) end) end
            end
            if isfile(filename) then
                local success, asset = pcall(function() return getcustomasset(filename) end)
                if success and asset then
                    cachedAssets[filename] = asset
                    img.Image = asset
                    return
                end
            end
        end
        img.Image = url
    end)
    return img
end

-- Vector Generators
local function createStatusDot(color, parent)
    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.fromOffset(8, 8)
    Dot.BackgroundColor3 = color
    Dot.BorderSizePixel = 0
    Dot.Parent = parent
    Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
    return Dot
end

local function createHamburgerIcon(parent)
    local IconFrame = Instance.new("Frame")
    IconFrame.Size = UDim2.fromOffset(18, 14)
    IconFrame.BackgroundTransparency = 1
    IconFrame.Parent = parent

    for i = 1, 3 do
        local Line = Instance.new("Frame")
        Line.Size = UDim2.new(1, 0, 0, 2)
        Line.Position = UDim2.new(0, 0, 0, (i - 1) * 6)
        Line.BackgroundColor3 = Library.Theme.Text_Primary
        Line.BorderSizePixel = 0
        Line.Parent = IconFrame
        Instance.new("UICorner", Line).CornerRadius = UDim.new(1, 0)
    end
    return IconFrame
end

local function createArrowVector(isUp, parent)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.fromOffset(10, 10)
    Container.BackgroundTransparency = 1
    Container.Parent = parent

    local Line1 = Instance.new("Frame")
    Line1.Size = UDim2.new(0, 6, 0, 2)
    Line1.BackgroundColor3 = Library.Theme.Accent_Main
    Line1.BorderSizePixel = 0
    Line1.Parent = Container
    Instance.new("UICorner", Line1).CornerRadius = UDim.new(1, 0)

    local Line2 = Instance.new("Frame")
    Line2.Size = UDim2.new(0, 6, 0, 2)
    Line2.BackgroundColor3 = Library.Theme.Accent_Main
    Line2.BorderSizePixel = 0
    Line2.Parent = Container
    Instance.new("UICorner", Line2).CornerRadius = UDim.new(1, 0)

    if isUp then
        Line1.Position = UDim2.new(0, 0, 0.5, 0) Line1.Rotation = -45
        Line2.Position = UDim2.new(0, 4, 0.5, 0) Line2.Rotation = 45
    else
        Line1.Position = UDim2.new(0, 0, 0.5, 0) Line1.Rotation = 45
        Line2.Position = UDim2.new(0, 4, 0.5, 0) Line2.Rotation = -45
    end
    return Container
end

-- ScreenGui Setup
local RootGui = Instance.new("ScreenGui")
RootGui.Name = "SENZY_STANDALONE_UI"
RootGui.ResetOnSpawn = false
RootGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
RootGui.Parent = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

-- Toast Notifications Container
local ToastContainer = Instance.new("Frame")
ToastContainer.Name = "ToastContainer"
ToastContainer.Size = UDim2.new(0, 320, 1, -40)
ToastContainer.Position = UDim2.new(1, -330, 0, 20)
ToastContainer.BackgroundTransparency = 1
ToastContainer.Parent = RootGui

local ToastList = Instance.new("UIListLayout")
ToastList.SortOrder = Enum.SortOrder.LayoutOrder
ToastList.Padding = UDim.new(0, 10)
ToastList.VerticalAlignment = Enum.VerticalAlignment.Bottom
ToastList.Parent = ToastContainer

function Library:Notify(title, desc, duration, statusType)
    duration = duration or 3.5
    statusType = statusType or "Info"

    local borderColor = self.Theme.Accent_Main
    if statusType == "Success" then borderColor = self.Theme.Status_Green
    elseif statusType == "Warning" then borderColor = self.Theme.Status_Yellow
    elseif statusType == "Error" then borderColor = self.Theme.Status_Red end

    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, 0, 0, 64)
    Card.BackgroundColor3 = self.Theme.BG_Panel
    Card.BorderSizePixel = 0
    Card.Position = UDim2.new(1, 350, 0, 0)
    Card.Parent = ToastContainer
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = borderColor
    Stroke.Thickness = 1.5
    Stroke.Parent = Card

    local IndicatorDot = createStatusDot(borderColor, Card)
    IndicatorDot.Position = UDim2.new(0, 12, 0, 16)

    local TxtTitle = Instance.new("TextLabel")
    TxtTitle.Size = UDim2.new(1, -32, 0, 22)
    TxtTitle.Position = UDim2.new(0, 26, 0, 8)
    TxtTitle.Text = title
    TxtTitle.Font = Enum.Font.GothamBlack
    TxtTitle.TextSize = 13
    TxtTitle.TextColor3 = self.Theme.Text_Primary
    TxtTitle.TextXAlignment = Enum.TextXAlignment.Left
    TxtTitle.BackgroundTransparency = 1
    TxtTitle.Parent = Card

    local TxtDesc = Instance.new("TextLabel")
    TxtDesc.Size = UDim2.new(1, -32, 0, 22)
    TxtDesc.Position = UDim2.new(0, 26, 0, 30)
    TxtDesc.Text = desc
    TxtDesc.Font = Enum.Font.GothamMedium
    TxtDesc.TextSize = 11
    TxtDesc.TextColor3 = self.Theme.Text_Secondary
    TxtDesc.TextXAlignment = Enum.TextXAlignment.Left
    TxtDesc.BackgroundTransparency = 1
    TxtDesc.Parent = Card

    TweenService:Create(Card, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    task.delay(duration, function()
        if Card and Card.Parent then
            local tw = TweenService:Create(Card, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 350, 0, 0)})
            tw:Play()
            tw.Completed:Connect(function() Card:Destroy() end)
        end
    end)
end

-- Splash Screen Engine
function Library:PlaySplash(onComplete)
    local Overlay = Instance.new("Frame")
    Overlay.Size = UDim2.fromScale(1, 1)
    Overlay.BackgroundColor3 = self.Theme.BG_Dark
    Overlay.ZIndex = 200
    Overlay.Parent = RootGui

    local Banner = createCachedImage(RAW_BANNER_URL, "SENZY_BANNER_CACHE.png", Overlay)
    Banner.Size = UDim2.fromScale(1.03, 1.03)
    Banner.Position = UDim2.fromScale(-0.015, -0.015)
    Banner.ScaleType = Enum.ScaleType.Crop
    Banner.ImageTransparency = 1
    Banner.ZIndex = 201

    local TintLayer = Instance.new("Frame")
    TintLayer.Size = UDim2.fromScale(1, 1)
    TintLayer.BackgroundColor3 = Color3.fromRGB(10, 8, 15)
    TintLayer.BackgroundTransparency = 1
    TintLayer.ZIndex = 202
    TintLayer.Parent = Overlay

    local IntroLogo = createCachedImage(RAW_LOGO_URL, "SENZY_LOGO_CACHE.png", Overlay)
    IntroLogo.Size = UDim2.fromOffset(110, 110)
    IntroLogo.Position = UDim2.new(0.5, -55, 0.35, -55)
    IntroLogo.ImageTransparency = 1
    IntroLogo.ZIndex = 204

    local IntroTitle = Instance.new("TextLabel")
    IntroTitle.Size = UDim2.new(0, 320, 0, 32)
    IntroTitle.Position = UDim2.new(0.5, -160, 0.35, 70)
    IntroTitle.Text = "SENZY HUB"
    IntroTitle.Font = Enum.Font.GothamBlack
    IntroTitle.TextSize = 28
    IntroTitle.TextColor3 = self.Theme.Text_Primary
    IntroTitle.TextTransparency = 1
    IntroTitle.BackgroundTransparency = 1
    IntroTitle.ZIndex = 204
    IntroTitle.Parent = Overlay

    local IntroSubtitle = Instance.new("TextLabel")
    IntroSubtitle.Size = UDim2.new(0, 320, 0, 20)
    IntroSubtitle.Position = UDim2.new(0.5, -160, 0.35, 104)
    IntroSubtitle.Text = "Free Script"
    IntroSubtitle.Font = Enum.Font.GothamBold
    IntroSubtitle.TextSize = 13
    IntroSubtitle.TextColor3 = self.Theme.Accent_Main
    IntroSubtitle.TextTransparency = 1
    IntroSubtitle.BackgroundTransparency = 1
    IntroSubtitle.ZIndex = 204
    IntroSubtitle.Parent = Overlay

    local ProgressBG = Instance.new("Frame")
    ProgressBG.Size = UDim2.new(0, 240, 0, 3)
    ProgressBG.Position = UDim2.new(0.5, -120, 0.35, 148)
    ProgressBG.BackgroundColor3 = Color3.fromRGB(30, 25, 40)
    ProgressBG.BackgroundTransparency = 1
    ProgressBG.ZIndex = 204
    ProgressBG.Parent = Overlay
    Instance.new("UICorner", ProgressBG).CornerRadius = UDim.new(1, 0)

    local ProgressFill = Instance.new("Frame")
    ProgressFill.Size = UDim2.new(0, 0, 1, 0)
    ProgressFill.BackgroundColor3 = self.Theme.Accent_Main
    ProgressFill.ZIndex = 205
    ProgressFill.Parent = ProgressBG
    Instance.new("UICorner", ProgressFill).CornerRadius = UDim.new(1, 0)

    local StatusTxt = Instance.new("TextLabel")
    StatusTxt.Size = UDim2.new(0, 320, 0, 20)
    StatusTxt.Position = UDim2.new(0, 0.5, -160, 0.35, 158)
    StatusTxt.Text = "Initializing UI Library..."
    StatusTxt.Font = Enum.Font.GothamMedium
    StatusTxt.TextSize = 10
    StatusTxt.TextColor3 = self.Theme.Text_Secondary
    StatusTxt.TextTransparency = 1
    StatusTxt.BackgroundTransparency = 1
    StatusTxt.ZIndex = 204
    StatusTxt.Parent = Overlay

    task.spawn(function()
        TweenService:Create(Banner, TweenInfo.new(0.7), {ImageTransparency = 0.2, Size = UDim2.fromScale(1, 1), Position = UDim2.fromScale(0, 0)}):Play()
        TweenService:Create(TintLayer, TweenInfo.new(0.7), {BackgroundTransparency = 0.85}):Play()
        task.wait(0.7)
        TweenService:Create(IntroLogo, TweenInfo.new(1.1), {ImageTransparency = 0, Size = UDim2.fromOffset(125, 125), Position = UDim2.new(0.5, -62.5, 0.35, -62.5)}):Play()
        task.wait(1.1)
        TweenService:Create(IntroTitle, TweenInfo.new(0.6), {TextTransparency = 0}):Play()
        TweenService:Create(IntroSubtitle, TweenInfo.new(0.6), {TextTransparency = 0}):Play()
        TweenService:Create(ProgressBG, TweenInfo.new(0.6), {BackgroundTransparency = 0.5}):Play()
        TweenService:Create(StatusTxt, TweenInfo.new(0.6), {TextTransparency = 0}):Play()
        
        task.wait(1.0)
        StatusTxt.Text = "Loading components..."
        TweenService:Create(ProgressFill, TweenInfo.new(1.5), {Size = UDim2.new(0.5, 0, 1, 0)}):Play()
        task.wait(1.5)
        StatusTxt.Text = "Preparing interface..."
        TweenService:Create(ProgressFill, TweenInfo.new(1.5), {Size = UDim2.new(0.9, 0, 1, 0)}):Play()
        task.wait(1.5)
        StatusTxt.Text = "Ready."
        TweenService:Create(ProgressFill, TweenInfo.new(0.4), {Size = UDim2.new(1.0, 0, 1, 0)}):Play()
        task.wait(0.4)

        if onComplete then onComplete() end

        TweenService:Create(Overlay, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(Banner, TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
        TweenService:Create(IntroLogo, TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
        TweenService:Create(IntroTitle, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(IntroSubtitle, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(ProgressBG, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(StatusTxt, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        task.wait(0.3)
        Overlay:Destroy()
    end)
end

-- Config System Functions
function Library:SaveConfig(filename)
    filename = filename or "default_config.json"
    if writefile and isfolder and makefolder then
        if not isfolder(self.ConfigFolder) then makefolder(self.ConfigFolder) end
        pcall(function()
            writefile(self.ConfigFolder .. "/" .. filename, HttpService:JSONEncode(self.Flags))
        end)
    end
end

function Library:LoadConfig(filename)
    filename = filename or "default_config.json"
    if readfile and isfile then
        local path = self.ConfigFolder .. "/" .. filename
        if isfile(path) then
            pcall(function()
                local decoded = HttpService:JSONDecode(readfile(path))
                if type(decoded) == "table" then self.Flags = decoded end
            end)
        end
    end
end

-- CreateWindow Engine
function Library:CreateWindow(config)
    config = config or {}
    local winTitle = config.Title or "SENZY HUB"
    local winSubtitle = config.Subtitle or "Free Script"
    local defaultSize = config.Size or UDim2.fromOffset(1120, 720)

    local WindowObj = {
        CurrentTab = nil,
        IsMinimized = false,
        IsFullyClosed = false,
        SidebarCollapsed = false,
        SidebarCards = {}
    }

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = defaultSize
    MainFrame.Position = UDim2.new(0.5, -defaultSize.X.Offset/2, 0.5, -defaultSize.Y.Offset/2)
    MainFrame.BackgroundColor3 = Library.Theme.BG_Dark
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Visible = false
    MainFrame.Parent = RootGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Library.Theme.Border
    MainStroke.Thickness = 1.5
    MainStroke.Parent = MainFrame

    -- Floating Minimize Logo
    local FloatingWidget = Instance.new("TextButton")
    FloatingWidget.Size = UDim2.fromOffset(95, 95)
    FloatingWidget.Position = UDim2.new(0, 20, 0.5, -47)
    FloatingWidget.BackgroundColor3 = Library.Theme.BG_Panel
    FloatingWidget.Text = ""
    FloatingWidget.Visible = false
    FloatingWidget.Parent = RootGui
    Instance.new("UICorner", FloatingWidget).CornerRadius = UDim.new(1, 0)
    
    local WidgetStroke = Instance.new("UIStroke")
    WidgetStroke.Color = Library.Theme.Accent_Main
    WidgetStroke.Thickness = 2
    WidgetStroke.Parent = FloatingWidget

    local WidgetLogo = createCachedImage(RAW_LOGO_URL, "SENZY_LOGO_CACHE.png", FloatingWidget)
    WidgetLogo.Size = UDim2.new(0.75, 0, 0.75, 0)
    WidgetLogo.Position = UDim2.new(0.125, 0, 0.125, 0)

    -- Top Header
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 52)
    TopBar.BackgroundColor3 = Library.Theme.BG_Panel
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame

    local HamburgerBtn = Instance.new("TextButton")
    HamburgerBtn.Size = UDim2.fromOffset(36, 36)
    HamburgerBtn.Position = UDim2.new(0, 10, 0, 8)
    HamburgerBtn.BackgroundColor3 = Library.Theme.BG_Surface
    HamburgerBtn.Text = ""
    HamburgerBtn.Parent = TopBar
    Instance.new("UICorner", HamburgerBtn).CornerRadius = UDim.new(0, 6)

    local HamIcon = createHamburgerIcon(HamburgerBtn)
    HamIcon.Position = UDim2.new(0.5, -9, 0.5, -7)

    local HeaderTitleFrame = Instance.new("Frame")
    HeaderTitleFrame.Size = UDim2.new(0, 300, 1, 0)
    HeaderTitleFrame.Position = UDim2.new(0, 56, 0, 0)
    HeaderTitleFrame.BackgroundTransparency = 1
    HeaderTitleFrame.Parent = TopBar

    local HeaderTitle = Instance.new("TextLabel")
    HeaderTitle.Size = UDim2.new(1, 0, 0, 22)
    HeaderTitle.Position = UDim2.new(0, 0, 0, 8)
    HeaderTitle.Text = winTitle
    HeaderTitle.Font = Enum.Font.GothamBlack
    HeaderTitle.TextSize = 16
    HeaderTitle.TextColor3 = Library.Theme.Text_Primary
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Parent = HeaderTitleFrame

    local HeaderSubTitle = Instance.new("TextLabel")
    HeaderSubTitle.Size = UDim2.new(1, 0, 0, 16)
    HeaderSubTitle.Position = UDim2.new(0, 0, 0, 28)
    HeaderSubTitle.Text = winSubtitle
    HeaderSubTitle.Font = Enum.Font.GothamBold
    HeaderSubTitle.TextSize = 10
    HeaderSubTitle.TextColor3 = Library.Theme.Accent_Main
    HeaderSubTitle.TextXAlignment = Enum.TextXAlignment.Left
    HeaderSubTitle.BackgroundTransparency = 1
    HeaderSubTitle.Parent = HeaderTitleFrame

    -- Controls (Minimize/Close)
    local WindowControls = Instance.new("Frame")
    WindowControls.Size = UDim2.new(0, 80, 1, 0)
    WindowControls.Position = UDim2.new(1, -85, 0, 0)
    WindowControls.BackgroundTransparency = 1
    WindowControls.Parent = TopBar

    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 32, 0, 32)
    MinimizeBtn.Position = UDim2.new(0, 4, 0.5, -16)
    MinimizeBtn.BackgroundColor3 = Library.Theme.BG_Surface
    MinimizeBtn.Text = ""
    MinimizeBtn.Parent = WindowControls
    Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 6)

    local MinIcon = Instance.new("Frame")
    MinIcon.Size = UDim2.new(0, 10, 0, 2)
    MinIcon.Position = UDim2.new(0.5, -5, 0.5, -1)
    MinIcon.BackgroundColor3 = Library.Theme.Text_Secondary
    MinIcon.Parent = MinimizeBtn

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 32, 0, 32)
    CloseBtn.Position = UDim2.new(0, 42, 0.5, -16)
    CloseBtn.BackgroundColor3 = Library.Theme.BG_Surface
    CloseBtn.Text = ""
    CloseBtn.Parent = WindowControls
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

    local CloseX1 = Instance.new("Frame")
    CloseX1.Size = UDim2.new(0, 12, 0, 2)
    CloseX1.Position = UDim2.new(0.5, -6, 0.5, -1)
    CloseX1.Rotation = 45
    CloseX1.BackgroundColor3 = Library.Theme.Accent_Dark
    CloseX1.Parent = CloseBtn

    local CloseX2 = Instance.new("Frame")
    CloseX2.Size = UDim2.new(0, 12, 0, 2)
    CloseX2.Position = UDim2.new(0.5, -6, 0.5, -1)
    CloseX2.Rotation = -45
    CloseX2.BackgroundColor3 = Library.Theme.Accent_Dark
    CloseX2.Parent = CloseBtn

    -- Window Drag mechanics
    local dragging, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true dragStart = input.Position startPos = MainFrame.Position
        end
    end)
    TopBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    table.insert(Library.Connections, UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))

    local function setMinimizeState(minimize)
        WindowObj.IsMinimized = minimize
        if minimize then
            MainFrame.Visible = false FloatingWidget.Visible = true
        else
            FloatingWidget.Visible = false MainFrame.Visible = true
        end
    end

    MinimizeBtn.MouseButton1Click:Connect(function() setMinimizeState(true) end)
    FloatingWidget.MouseButton1Click:Connect(function() setMinimizeState(false) end)

    CloseBtn.MouseButton1Click:Connect(function()
        WindowObj.IsFullyClosed = true
        for _, conn in ipairs(Library.Connections) do if conn and conn.Connected then conn:Disconnect() end end
        Library.Connections = {}
        RootGui:Destroy()
    end)

    -- Sidebar Container
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 310, 1, -52)
    Sidebar.Position = UDim2.new(0, 0, 0, 52)
    Sidebar.BackgroundColor3 = Library.Theme.BG_Panel
    Sidebar.BorderSizePixel = 0
    Sidebar.ClipsDescendants = true
    Sidebar.Parent = MainFrame

    local SidebarScroll = Instance.new("ScrollingFrame")
    SidebarScroll.Size = UDim2.new(1, 0, 1, 0)
    SidebarScroll.BackgroundTransparency = 1
    SidebarScroll.ScrollBarThickness = 3
    SidebarScroll.ScrollBarImageColor3 = Library.Theme.Accent_Main
    SidebarScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    SidebarScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    SidebarScroll.Parent = Sidebar

    local SidebarList = Instance.new("UIListLayout")
    SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarList.Padding = UDim.new(0, 10)
    SidebarList.Parent = SidebarScroll

    local SidebarPad = Instance.new("UIPadding")
    SidebarPad.PaddingTop = UDim.new(0, 12)
    SidebarPad.PaddingLeft = UDim.new(0, 12)
    SidebarPad.PaddingRight = UDim.new(0, 12)
    SidebarPad.PaddingBottom = UDim.new(0, 12)
    SidebarPad.Parent = SidebarScroll

    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -310, 1, -52)
    ContentArea.Position = UDim2.new(0, 310, 0, 52)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainFrame

    -- Sidebar Collapse Mechanism
    HamburgerBtn.MouseButton1Click:Connect(function()
        WindowObj.SidebarCollapsed = not WindowObj.SidebarCollapsed
        local targetWidth = WindowObj.SidebarCollapsed and 0 or 310
        TweenService:Create(Sidebar, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, targetWidth, 1, -52)}):Play()
        TweenService:Create(ContentArea, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = WindowObj.SidebarCollapsed and UDim2.new(1, 0, 1, -52) or UDim2.new(1, -310, 1, -52),
            Position = WindowObj.SidebarCollapsed and UDim2.new(0, 0, 0, 52) or UDim2.new(0, 310, 0, 52)
        }):Play()
    end)

    local TopNav = Instance.new("ScrollingFrame")
    TopNav.Size = UDim2.new(1, 0, 0, 42)
    TopNav.BackgroundColor3 = Library.Theme.BG_Panel
    TopNav.BorderSizePixel = 0
    TopNav.ScrollBarThickness = 0
    TopNav.CanvasSize = UDim2.new(0, 0, 0, 0)
    TopNav.Parent = ContentArea

    local TopNavList = Instance.new("UIListLayout")
    TopNavList.FillDirection = Enum.FillDirection.Horizontal
    TopNavList.SortOrder = Enum.SortOrder.LayoutOrder
    TopNavList.Padding = UDim.new(0, 8)
    TopNavList.Parent = TopNav

    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, 0, 1, -42)
    PageContainer.Position = UDim2.new(0, 0, 0, 42)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = ContentArea

    function WindowObj:CreateTab(tabConfig)
        tabConfig = tabConfig or {}
        local tabName = type(tabConfig) == "string" and tabConfig or (tabConfig.Name or "Tab")
        local TabObj = {}

        local NavBtn = Instance.new("TextButton")
        NavBtn.Size = UDim2.new(0, 125, 0, 32)
        NavBtn.BackgroundColor3 = Library.Theme.BG_Surface
        NavBtn.Text = tabName
        NavBtn.Font = Enum.Font.GothamBlack
        NavBtn.TextSize = 12
        NavBtn.TextColor3 = Library.Theme.Text_Secondary
        NavBtn.Parent = TopNav
        Instance.new("UICorner", NavBtn).CornerRadius = UDim.new(0, 6)

        local PageScroll = Instance.new("ScrollingFrame")
        PageScroll.Size = UDim2.new(1, 0, 1, 0)
        PageScroll.BackgroundTransparency = 1
        PageScroll.ScrollBarThickness = 3
        PageScroll.ScrollBarImageColor3 = Library.Theme.Accent_Main
        PageScroll.Visible = false
        PageScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        PageScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        PageScroll.Parent = PageContainer

        local PageList = Instance.new("UIListLayout")
        PageList.SortOrder = Enum.SortOrder.LayoutOrder
        PageList.Padding = UDim.new(0, 14)
        PageList.Parent = PageScroll

        local PagePad = Instance.new("UIPadding")
        PagePad.PaddingTop = UDim.new(0, 14)
        PagePad.PaddingLeft = UDim.new(0, 16)
        PagePad.PaddingRight = UDim.new(0, 16)
        PagePad.PaddingBottom = UDim.new(0, 16)
        PagePad.Parent = PageScroll

        if WindowObj.CurrentTab == nil then
            WindowObj.CurrentTab = PageScroll
            PageScroll.Visible = true
            NavBtn.BackgroundColor3 = Library.Theme.Accent_Main
            NavBtn.TextColor3 = Library.Theme.Text_Primary
        end

        NavBtn.MouseButton1Click:Connect(function()
            for _, p in pairs(PageContainer:GetChildren()) do if p:IsA("ScrollingFrame") then p.Visible = false end end
            for _, b in pairs(TopNav:GetChildren()) do if b:IsA("TextButton") then b.BackgroundColor3 = Library.Theme.BG_Surface b.TextColor3 = Library.Theme.Text_Secondary end end
            PageScroll.Visible = true
            NavBtn.BackgroundColor3 = Library.Theme.Accent_Main
            NavBtn.TextColor3 = Library.Theme.Text_Primary
        end)

        function TabObj:AddSection(secTitle, layoutType)
            secTitle = secTitle or "Section"
            local SecObj = {}

            local SecHeader = Instance.new("TextLabel")
            SecHeader.Size = UDim2.new(1, 0, 0, 22)
            SecHeader.Text = secTitle:upper()
            SecHeader.Font = Enum.Font.GothamBlack
            SecHeader.TextSize = 12
            SecHeader.TextColor3 = Library.Theme.Accent_Glow
            SecHeader.TextXAlignment = Enum.TextXAlignment.Left
            SecHeader.BackgroundTransparency = 1
            SecHeader.Parent = PageScroll

            local Container = Instance.new("Frame")
            Container.Size = UDim2.new(1, 0, 0, 0)
            Container.BackgroundTransparency = 1
            Container.Parent = PageScroll

            local Layout = Instance.new("UIListLayout")
            Layout.SortOrder = Enum.SortOrder.LayoutOrder
            Layout.Padding = UDim.new(0, 10)
            Layout.Parent = Container

            Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Container.Size = UDim2.new(1, 0, 0, Layout.AbsoluteContentSize.Y)
            end)

            function SecObj:AddButton(cfg)
                cfg = cfg or {} local name = type(cfg) == "string" and cfg or (cfg.Name or "Button")
                local callback = cfg.Callback or function() end

                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 0, 40)
                Btn.BackgroundColor3 = Library.Theme.BG_Surface
                Btn.Text = name Btn.Font = Enum.Font.GothamBlack Btn.TextSize = 12 Btn.TextColor3 = Library.Theme.Text_Primary
                Btn.Parent = Container Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

                Btn.MouseButton1Click:Connect(function()
                    TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Library.Theme.Accent_Main}):Play()
                    task.delay(0.1, function() TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.BG_Surface}):Play() end)
                    pcall(callback)
                end)
            end

            function SecObj:AddToggle(cfg)
                cfg = cfg or {} local name = cfg.Name or "Toggle" local desc = cfg.Description or ""
                local flag = cfg.Flag or name local default = cfg.Default or false local callback = cfg.Callback or function() end
                Library.Flags[flag] = default

                local Card = Instance.new("Frame")
                Card.Size = UDim2.new(1, 0, 0, 58) Card.BackgroundColor3 = Library.Theme.BG_Surface Card.Parent = Container
                Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)

                local TxtTitle = Instance.new("TextLabel")
                TxtTitle.Size = UDim2.new(1, -70, 0, 22) TxtTitle.Position = UDim2.new(0, 12, 0, 8) TxtTitle.Text = name
                TxtTitle.Font = Enum.Font.GothamBlack TxtTitle.TextSize = 12 TxtTitle.TextColor3 = Library.Theme.Text_Primary
                TxtTitle.TextXAlignment = Enum.TextXAlignment.Left TxtTitle.BackgroundTransparency = 1 TxtTitle.Parent = Card

                local Switch = Instance.new("Frame")
                Switch.Size = UDim2.new(0, 44, 0, 22) Switch.Position = UDim2.new(1, -54, 0.5, -11)
                Switch.BackgroundColor3 = default and Library.Theme.Accent_Main or Library.Theme.BG_Container Switch.Parent = Card
                Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

                local Knob = Instance.new("Frame")
                Knob.Size = UDim2.new(0, 18, 0, 18) Knob.Position = default and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
                Knob.BackgroundColor3 = Library.Theme.Text_Primary Knob.Parent = Switch Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 1, 0) Btn.BackgroundTransparency = 1 Btn.Text = "" Btn.Parent = Card

                Btn.MouseButton1Click:Connect(function()
                    Library.Flags[flag] = not Library.Flags[flag] local active = Library.Flags[flag]
                    TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = active and Library.Theme.Accent_Main or Library.Theme.BG_Container}):Play()
                    TweenService:Create(Knob, TweenInfo.new(0.2), {Position = active and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}):Play()
                    pcall(callback, active)
                end)
            end

            function SecObj:AddSlider(cfg)
                cfg = cfg or {} local name = cfg.Name or "Slider" local flag = cfg.Flag or name local min = cfg.Min or 0 local max = cfg.Max or 100
                local default = cfg.Default or min local callback = cfg.Callback or function() end
                Library.Flags[flag] = default

                local Card = Instance.new("Frame") Card.Size = UDim2.new(1, 0, 0, 54) Card.BackgroundColor3 = Library.Theme.BG_Surface Card.Parent = Container
                Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)

                local Txt = Instance.new("TextLabel") Txt.Size = UDim2.new(1, -80, 0, 20) Txt.Position = UDim2.new(0, 12, 0, 6) Txt.Text = name
                Txt.Font = Enum.Font.GothamBold Txt.TextSize = 12 Txt.TextColor3 = Library.Theme.Text_Primary Txt.TextXAlignment = Enum.TextXAlignment.Left Txt.BackgroundTransparency = 1 Txt.Parent = Card

                local ValTxt = Instance.new("TextLabel") ValTxt.Size = UDim2.new(0, 70, 0, 20) ValTxt.Position = UDim2.new(1, -82, 0, 6) ValTxt.Text = tostring(default)
                ValTxt.Font = Enum.Font.GothamBlack ValTxt.TextSize = 12 ValTxt.TextColor3 = Library.Theme.Accent_Glow ValTxt.TextXAlignment = Enum.TextXAlignment.Right ValTxt.BackgroundTransparency = 1 ValTxt.Parent = Card

                local BarBG = Instance.new("Frame") BarBG.Size = UDim2.new(1, -24, 0, 8) BarBG.Position = UDim2.new(0, 12, 0, 34) BarBG.BackgroundColor3 = Library.Theme.BG_Container BarBG.Parent = Card Instance.new("UICorner", BarBG).CornerRadius = UDim.new(1, 0)
                local BarFill = Instance.new("Frame") BarFill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0) BarFill.BackgroundColor3 = Library.Theme.Accent_Main BarFill.Parent = BarBG Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)
                local SldBtn = Instance.new("TextButton") SldBtn.Size = UDim2.new(1, 0, 1, 0) SldBtn.BackgroundTransparency = 1 SldBtn.Text = "" SldBtn.Parent = BarBG

                local sliding = false
                local function update(input)
                    local pos = math.clamp((input.Position.X - BarBG.AbsolutePosition.X) / BarBG.AbsoluteSize.X, 0, 1)
                    local val = math.floor(min + ((max - min) * pos)) Library.Flags[flag] = val ValTxt.Text = tostring(val) BarFill.Size = UDim2.new(pos, 0, 1, 0) pcall(callback, val)
                end
                SldBtn.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true update(inp) end end)
                UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end end)
                UserInputService.InputChanged:Connect(function(inp) if sliding and inp.UserInputType == Enum.UserInputType.MouseMovement then update(inp) end end)
            end

            function SecObj:AddDropdown(cfg)
                cfg = cfg or {} local name = cfg.Name or "Dropdown" local options = cfg.Options or {} local default = cfg.Default or options[1] or "" local flag = cfg.Flag or name local callback = cfg.Callback or function() end
                Library.Flags[flag] = default local isExpanded = false

                local Card = Instance.new("Frame") Card.Size = UDim2.new(1, 0, 0, 44) Card.BackgroundColor3 = Library.Theme.BG_Surface Card.ClipsDescendants = true Card.Parent = Container Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)
                local Txt = Instance.new("TextLabel") Txt.Size = UDim2.new(0, 140, 0, 44) Txt.Position = UDim2.new(0, 12, 0, 0) Txt.Text = name Txt.Font = Enum.Font.GothamBold Txt.TextSize = 12 Txt.TextColor3 = Library.Theme.Text_Primary Txt.TextXAlignment = Enum.TextXAlignment.Left Txt.BackgroundTransparency = 1 Txt.Parent = Card
                
                local SelectedVal = Instance.new("TextLabel") SelectedVal.Size = UDim2.new(0, 180, 0, 30) SelectedVal.Position = UDim2.new(1, -212, 0, 7) SelectedVal.BackgroundColor3 = Library.Theme.BG_Container SelectedVal.Text = default SelectedVal.Font = Enum.Font.GothamBold SelectedVal.TextSize = 11 SelectedVal.TextColor3 = Library.Theme.Accent_Glow SelectedVal.Parent = Card Instance.new("UICorner", SelectedVal).CornerRadius = UDim.new(0, 6)
                local DropBtn = Instance.new("TextButton") DropBtn.Size = UDim2.new(1, 0, 0, 44) DropBtn.BackgroundTransparency = 1 DropBtn.Text = "" DropBtn.Parent = Card

                local OptContainer = Instance.new("Frame") OptContainer.Size = UDim2.new(1, -24, 0, #options * 28) OptContainer.Position = UDim2.new(0, 12, 0, 48) OptContainer.BackgroundTransparency = 1 OptContainer.Parent = Card
                local OptList = Instance.new("UIListLayout") OptList.SortOrder = Enum.SortOrder.LayoutOrder OptList.Padding = UDim.new(0, 4) OptList.Parent = OptContainer

                for _, opt in ipairs(options) do
                    local OptBtn = Instance.new("TextButton") OptBtn.Size = UDim2.new(1, 0, 0, 24) OptBtn.BackgroundColor3 = Library.Theme.BG_Container OptBtn.Text = opt OptBtn.Font = Enum.Font.GothamMedium OptBtn.TextSize = 11 OptBtn.TextColor3 = Library.Theme.Text_Secondary OptBtn.Parent = OptContainer Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0, 4)
                    OptBtn.MouseButton1Click:Connect(function()
                        Library.Flags[flag] = opt SelectedVal.Text = opt isExpanded = false
                        TweenService:Create(Card, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 44)}):Play()
                        pcall(callback, opt)
                    end)
                end
                DropBtn.MouseButton1Click:Connect(function()
                    isExpanded = not isExpanded
                    local targetHeight = isExpanded and (54 + (#options * 28)) or 44
                    TweenService:Create(Card, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, targetHeight)}):Play()
                end)
            end

            function SecObj:AddTextbox(cfg)
                cfg = cfg or {} local name = cfg.Name or "Textbox" local placeholder = cfg.Placeholder or "Enter text..." local flag = cfg.Flag or name local callback = cfg.Callback or function() end
                local Card = Instance.new("Frame") Card.Size = UDim2.new(1, 0, 0, 44) Card.BackgroundColor3 = Library.Theme.BG_Surface Card.Parent = Container Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)
                local Txt = Instance.new("TextLabel") Txt.Size = UDim2.new(0, 140, 1, 0) Txt.Position = UDim2.new(0, 12, 0, 0) Txt.Text = name Txt.Font = Enum.Font.GothamBold Txt.TextSize = 12 Txt.TextColor3 = Library.Theme.Text_Primary Txt.TextXAlignment = Enum.TextXAlignment.Left Txt.BackgroundTransparency = 1 Txt.Parent = Card
                local Input = Instance.new("TextBox") Input.Size = UDim2.new(0, 220, 0, 28) Input.Position = UDim2.new(1, -232, 0.5, -14) Input.BackgroundColor3 = Library.Theme.BG_Container Input.PlaceholderText = placeholder Input.Text = "" Input.Font = Enum.Font.GothamMedium Input.TextSize = 11 Input.TextColor3 = Library.Theme.Text_Primary Input.Parent = Card Instance.new("UICorner", Input).CornerRadius = UDim.new(0, 6)
                Input.FocusLost:Connect(function(enter) Library.Flags[flag] = Input.Text pcall(callback, Input.Text, enter) end)
            end

            function SecObj:AddLabel(text)
                local Lbl = Instance.new("TextLabel") Lbl.Size = UDim2.new(1, 0, 0, 20) Lbl.Text = text or "Label" Lbl.Font = Enum.Font.GothamMedium Lbl.TextSize = 11 Lbl.TextColor3 = Library.Theme.Text_Secondary Lbl.TextXAlignment = Enum.TextXAlignment.Left Lbl.BackgroundTransparency = 1 Lbl.Parent = Container
            end

            function SecObj:AddParagraph(title, desc)
                local Card = Instance.new("Frame") Card.Size = UDim2.new(1, 0, 0, 60) Card.BackgroundColor3 = Library.Theme.BG_Surface Card.Parent = Container Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)
                local TxtTitle = Instance.new("TextLabel") TxtTitle.Size = UDim2.new(1, -24, 0, 22) TxtTitle.Position = UDim2.new(0, 12, 0, 8) TxtTitle.Text = title or "Title" TxtTitle.Font = Enum.Font.GothamBlack TxtTitle.TextSize = 12 TxtTitle.TextColor3 = Library.Theme.Text_Primary TxtTitle.TextXAlignment = Enum.TextXAlignment.Left TxtTitle.BackgroundTransparency = 1 TxtTitle.Parent = Card
                local TxtDesc = Instance.new("TextLabel") TxtDesc.Size = UDim2.new(1, -24, 0, 24) TxtDesc.Position = UDim2.new(0, 12, 0, 28) TxtDesc.Text = desc or "Description" TxtDesc.Font = Enum.Font.GothamMedium TxtDesc.TextSize = 10 TxtDesc.TextColor3 = Library.Theme.Text_Dark TxtDesc.TextXAlignment = Enum.TextXAlignment.Left TxtDesc.TextWrapped = true TxtDesc.BackgroundTransparency = 1 TxtDesc.Parent = Card
            end

            function SecObj:AddKeybind(cfg)
                cfg = cfg or {} local name = cfg.Name or "Keybind" local defaultKey = cfg.Default or Enum.KeyCode.LeftControl local callback = cfg.Callback or function() end
                local Card = Instance.new("Frame") Card.Size = UDim2.new(1, 0, 0, 44) Card.BackgroundColor3 = Library.Theme.BG_Surface Card.Parent = Container Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)
                local Txt = Instance.new("TextLabel") Txt.Size = UDim2.new(0, 140, 1, 0) Txt.Position = UDim2.new(0, 12, 0, 0) Txt.Text = name Txt.Font = Enum.Font.GothamBold Txt.TextSize = 12 Txt.TextColor3 = Library.Theme.Text_Primary Txt.TextXAlignment = Enum.TextXAlignment.Left Txt.BackgroundTransparency = 1 Txt.Parent = Card
                local KeyBtn = Instance.new("TextButton") KeyBtn.Size = UDim2.new(0, 120, 0, 28) KeyBtn.Position = UDim2.new(1, -132, 0.5, -14) KeyBtn.BackgroundColor3 = Library.Theme.BG_Container KeyBtn.Text = defaultKey.Name KeyBtn.Font = Enum.Font.GothamBold KeyBtn.TextSize = 11 KeyBtn.TextColor3 = Library.Theme.Accent_Glow KeyBtn.Parent = Card Instance.new("UICorner", KeyBtn).CornerRadius = UDim.new(0, 6)
                KeyBtn.MouseButton1Click:Connect(function()
                    KeyBtn.Text = "Press Key..." local conn
                    conn = UserInputService.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.Keyboard then KeyBtn.Text = input.KeyCode.Name conn:Disconnect() pcall(callback, input.KeyCode) end
                    end)
                end)
            end

            return SecObj
        end
        return TabObj
    end

    MainFrame.Visible = true
    return WindowObj
end

return Library
