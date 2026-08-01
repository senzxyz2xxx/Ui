local Library = {}

local UserInputService = game:GetService('UserInputService')
local TweenService = game:GetService('TweenService')
local RunService = game:GetService('RunService')
local Players = game:GetService('Players')
local CoreGui = game:GetService('CoreGui')

local Mobile = if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then true else false

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local EasingStyle = Enum.EasingStyle
local EasingDirection = Enum.EasingDirection

-- ป้องกัน error กรณี Font.new / GothamSSm ไม่รองรับใน executor บางตัว
local function SafeFont(weight, style)
    local ok, result = pcall(function()
        return Font.new("rbxasset://fonts/families/GothamSSm.json", weight, style)
    end)
    if ok then
        return result
    end
    return Enum.Font.Gotham
end

-- ป้องกัน error กรณี Content.fromUri ไม่มีใน executor/เวอร์ชันที่ใช้
local function SafeContent(assetId)
    local ok, result = pcall(function()
        return Content.fromUri(assetId)
    end)
    if ok then
        return result
    end
    return nil
end

function Library:Parent()
    if not RunService:IsStudio() then
        return (gethui and gethui()) or CoreGui
    end
    return PlayerGui
end

function Library:Create(Class, Properties)
    local Creations = Instance.new(Class)

    for prop, value in Properties do
        Creations[prop] = value
    end

    return Creations
end

function Library:Draggable(a)
    local Dragging, DragInput, DragStart, StartPosition = nil, nil, nil, nil

    local function Update(input)
        local Delta = input.Position - DragStart
        local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
        TweenService:Create(a, TweenInfo.new(0.3), {Position = pos}):Play()
    end

    a.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPosition = a.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    a.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            Update(input)
        end
    end)
end

function Library:Button(Parent): TextButton
    return Library:Create("TextButton", {
        Name = "Click",
        Parent = Parent,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.SourceSans,
        Text = "",
        TextColor3 = Color3.fromRGB(0, 0, 0),
        TextSize = 14,
        ZIndex = Parent.ZIndex + 3
    })
end

function Library:Tween(Object, Info)
    return TweenService:Create(Object,TweenInfo.new(Info.Time, Info.Style, Info.Direction), Info.Goal)
end

function Library:Asset(rbx)
    if typeof(rbx) == 'number' then
        return "rbxassetid://" .. rbx
    end
    if typeof(rbx) == 'string' and rbx:find('rbxassetid://') then
        return rbx
    end
    return rbx
end

function Library:Row(Parent, Args, Hidden)
    Hidden = Hidden or {}
    
    local Title = Args.Title
    local Desc = Args.Desc

    local Row_1 = Instance.new("Frame")
    local UICorner_1 = Instance.new("UICorner")
    local Scale_1 = Instance.new("Frame")
    local Left_1 = Instance.new("Frame")
    local Text_1 = Instance.new("Frame")
    local UIListLayout_1 = Instance.new("UIListLayout")
    local Title_1 = Instance.new("TextLabel")
    local Footer_1 = Instance.new("TextLabel")
    local UIPadding_1 = Instance.new("UIPadding")
    local Right_1 = Instance.new("Frame")
    local UIListLayout_2 = Instance.new("UIListLayout")
    local UIPadding_2 = Instance.new("UIPadding")

    Row_1.BackgroundColor3 = Color3.fromRGB(255, 170, 255)
    Row_1.BackgroundTransparency = 0.9750000238418579
    Row_1.Name = "Row"
    Row_1.Parent = Parent
    Row_1.Size = UDim2.new(1, 0, 0, 0)
    Row_1.AutomaticSize = Enum.AutomaticSize.Y
    Row_1.Selectable = false
    
    UICorner_1.Parent = Row_1
    UICorner_1.BottomRightRadius = UDim.new(0, 16)
    UICorner_1.TopRightRadius = UDim.new(0, 16)
    
    Scale_1.BackgroundTransparency = 1
    Scale_1.Name = "Scale"
    Scale_1.Parent = Row_1
    Scale_1.Size = UDim2.new(1, 0, 0, 0)
    Scale_1.AutomaticSize = Enum.AutomaticSize.Y
    Scale_1.Selectable = false

    Left_1.BackgroundTransparency = 1
    Left_1.Name = "Left"
    Left_1.Parent = Scale_1
    Left_1.Size = UDim2.new(1, 0, 0, 0)
    Left_1.AutomaticSize = Enum.AutomaticSize.Y
    Left_1.Selectable = false

    Text_1.BackgroundTransparency = 1
    Text_1.Name = "Text"
    Text_1.Parent = Left_1
    Text_1.Size = UDim2.new(1, 0, 0, 0)
    Text_1.AutomaticSize = Enum.AutomaticSize.Y
    Text_1.Selectable = false

    UIListLayout_1.Padding = UDim.new(0, 2)
    UIListLayout_1.Parent = Text_1
    UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

    local UIPadding_Text = Instance.new("UIPadding")
    UIPadding_Text.PaddingTop = UDim.new(0, 10)
    UIPadding_Text.PaddingBottom = UDim.new(0, 10)
    UIPadding_Text.Parent = Text_1

    Title_1.BackgroundTransparency = 1
    Title_1.Name = "Title"
    Title_1.Parent = Text_1
    Title_1.Size = UDim2.new(1, 0, 0, 14)
    Title_1.Selectable = false
    Title_1.FontFace = SafeFont(Enum.FontWeight.Medium, Enum.FontStyle.Normal)
    Title_1.RichText = true
    Title_1.Text = Title
    Title_1.TextColor3 = Color3.fromRGB(234, 234, 234)
    Title_1.TextSize = 15
    Title_1.TextXAlignment = Enum.TextXAlignment.Left

    if Desc then
        Footer_1.BackgroundTransparency = 1
        Footer_1.Name = "Footer"
        Footer_1.Parent = Text_1
        Footer_1.Size = UDim2.new(1, 0, 0, 0)
        Footer_1.AutomaticSize = Enum.AutomaticSize.Y
        Footer_1.Selectable = false
        Footer_1.FontFace = SafeFont(Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        Footer_1.RichText = true
        Footer_1.Text = Desc
        Footer_1.TextColor3 = Color3.fromRGB(255, 255, 255)
        Footer_1.TextSize = 9
        Footer_1.TextTransparency = 0.5
        Footer_1.TextXAlignment = Enum.TextXAlignment.Left
        Footer_1.TextYAlignment = Enum.TextYAlignment.Top
        Footer_1.TextWrapped = true
    end
    
    UIPadding_1.PaddingTop = UDim.new(0, Hidden.Y or 5)
    UIPadding_1.PaddingBottom = UDim.new(0, Hidden.Y or 5)

    UIPadding_1.Parent = Left_1
    UIPadding_1.PaddingLeft = UDim.new(0, 15)
    UIPadding_1.PaddingRight = UDim.new(0, 15)

    Right_1.BackgroundTransparency = 1
    Right_1.Name = "Right"
    Right_1.Parent = Scale_1
    Right_1.Size = UDim2.new(1, 0, 1, 0)
    Right_1.Selectable = false

    UIListLayout_2.Parent = Right_1
    UIListLayout_2.FillDirection = Enum.FillDirection.Horizontal
    UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout_2.HorizontalAlignment = Enum.HorizontalAlignment.Right
    UIListLayout_2.VerticalAlignment = Enum.VerticalAlignment.Center

    UIPadding_2.Parent = Right_1
    UIPadding_2.PaddingRight = UDim.new(0, 15)

    return {
        Template = Row_1,
        Right = Right_1,
        Title = Title_1,
        Desc = Footer_1,
        Padding = UIPadding_1
    }
end

function Library:Window(Info)
    local Window = {}
    local self = Library
    
    local Title = Info.Title or "Senzy"
    local Footer = Info.Footer or "Premium Script"
    local Logo = Info.Logo or 111116339097216
    
    local Senzy = Instance.new('ScreenGui') do
        Senzy.Name = "Senzy"
        Senzy.Parent = self:Parent()
        Senzy.IgnoreGuiInset = true
        
        local Background_1 = Instance.new("Frame")
        local UICorner_1 = Instance.new("UICorner")
        local UIShadow_1 = Instance.new("UIShadow")
        local Layers2_1 = Instance.new("ImageLabel")
        local UICorner_2 = Instance.new("UICorner")
        local Layers1_1 = Instance.new("ImageLabel")
        local UICorner_3 = Instance.new("UICorner")

        Background_1.AnchorPoint = Vector2.new(0.5, 0.5)
        Background_1.BackgroundColor3 = Color3.fromRGB(13, 13, 13)
        Background_1.BackgroundTransparency = 0.005
        Background_1.Name = "Background"
        Background_1.Parent = Senzy
        Background_1.Position = UDim2.new(0.5, 0, 0.5, 0)
        Background_1.Size = UDim2.new(0, 500, 0, 360)
        Background_1.Selectable = false

        UICorner_1.Parent = Background_1

        Layers2_1.AnchorPoint = Vector2.new(0.5, 0.5)
        Layers2_1.BackgroundTransparency = 1
        Layers2_1.Name = "Layers2"
        Layers2_1.Parent = Background_1
        Layers2_1.Position = UDim2.new(0.5, 0, 0.5, 0)
        Layers2_1.Size = UDim2.new(1, 0, 1, 0)
        Layers2_1.Image = "rbxassetid://105837725217811"
        Layers2_1.ImageColor3 = Color3.fromRGB(255, 85, 255)
        local Layers2_Content = SafeContent("rbxassetid://105837725217811")
        if Layers2_Content then Layers2_1.ImageContent = Layers2_Content end
        Layers2_1.ImageTransparency = 0.9750000238418579
        Layers2_1.ScaleType = Enum.ScaleType.Crop

        UICorner_2.Parent = Layers2_1

        Layers1_1.AnchorPoint = Vector2.new(0.5, 0.5)
        Layers1_1.BackgroundTransparency = 1
        Layers1_1.Name = "Layers1"
        Layers1_1.Parent = Background_1
        Layers1_1.Position = UDim2.new(0.5, 0, 0.5, 0)
        Layers1_1.Size = UDim2.new(1, 0, 1, 0)
        Layers1_1.Image = "rbxassetid://140229099079933"
        Layers1_1.ImageColor3 = Color3.fromRGB(255, 85, 255)
        local Layers1_Content = SafeContent("rbxassetid://140229099079933")
        if Layers1_Content then Layers1_1.ImageContent = Layers1_Content end
        Layers1_1.ImageTransparency = 0.8999999761581421
        Layers1_1.ScaleType = Enum.ScaleType.Crop

        UICorner_3.Parent = Layers1_1
        
        Window.Senzy = Senzy
        Window.Background = Background_1
        
        Library:Draggable(Background_1)
        
        function Library:IsDropdownOpen()
            for _, v in Background_1:GetChildren() do
                if v.Name == 'NewDropdown' and v.Visible then
                    return true
                end
            end
        end
    end
    
    local Header = Instance.new("Frame") do
        local Left_1 = Instance.new("Frame")
        local UIListLayout_1 = Instance.new("UIListLayout")
        local UIPadding_1 = Instance.new("UIPadding")
        local Logo_1 = Instance.new("ImageLabel")
        local Text_1 = Instance.new("Frame")
        local UIListLayout_2 = Instance.new("UIListLayout")
        local Title_1 = Instance.new("TextLabel")
        local Footer_1 = Instance.new("TextLabel")

        Header.BackgroundTransparency = 1
        Header.Name = "Header"
        Header.Parent = Window.Background
        Header.Size = UDim2.new(1, 0, 0, 50)
        Header.Selectable = false

        Left_1.BackgroundTransparency = 1
        Left_1.Name = "Left"
        Left_1.Parent = Header
        Left_1.Size = UDim2.new(1, 0, 1, 0)
        Left_1.Selectable = false

        UIListLayout_1.Padding = UDim.new(0, 10)
        UIListLayout_1.Parent = Left_1
        UIListLayout_1.FillDirection = Enum.FillDirection.Horizontal
        UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

        UIPadding_1.Parent = Left_1
        UIPadding_1.PaddingLeft = UDim.new(0, 15)

        Logo_1.AnchorPoint = Vector2.new(0.5, 0.5)
        Logo_1.BackgroundTransparency = 1
        Logo_1.Name = "Logo"
        Logo_1.Parent = Left_1
        Logo_1.Size = UDim2.new(0, 25, 0, 25)
        Logo_1.Image = self:Asset(Logo)
        Text_1.BackgroundTransparency = 1
        Text_1.Name = "Text"
        Text_1.Parent = Left_1
        Text_1.Size = UDim2.new(1, -50, 0, 50)
        Text_1.Selectable = false

        UIListLayout_2.Padding = UDim.new(0, 1)
        UIListLayout_2.Parent = Text_1
        UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout_2.VerticalAlignment = Enum.VerticalAlignment.Center

        Title_1.BackgroundTransparency = 1
        Title_1.Name = "Title"
        Title_1.Parent = Text_1
        Title_1.Size = UDim2.new(1, 0, 0, 14)
        Title_1.Selectable = false
        Title_1.FontFace = SafeFont(Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        Title_1.RichText = true
        Title_1.Text = Title
        Title_1.TextColor3 = Color3.fromRGB(234, 234, 234)
        Title_1.TextSize = 14
        Title_1.TextXAlignment = Enum.TextXAlignment.Left

        Footer_1.BackgroundTransparency = 1
        Footer_1.Name = "Footer"
        Footer_1.Parent = Text_1
        Footer_1.Size = UDim2.new(1, 0, 0, 9)
        Footer_1.Selectable = false
        Footer_1.FontFace = SafeFont(Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        Footer_1.RichText = true
        Footer_1.Text = Footer
        Footer_1.TextColor3 = Color3.fromRGB(255, 255, 255)
        Footer_1.TextSize = 9
        Footer_1.TextTransparency = 0.5
        Footer_1.TextXAlignment = Enum.TextXAlignment.Left
    end
    
    local Inner = Instance.new("Frame") do
        local Tabs_1 = Instance.new("Frame")
        local Scrolling_1 = Instance.new("ScrollingFrame")
        local UIListLayout_1 = Instance.new("UIListLayout")
        local UIPadding_1 = Instance.new("UIPadding")
        local UIPadding_2 = Instance.new("UIPadding")

        Inner.BackgroundTransparency = 1
        Inner.Name = "Inner"
        Inner.Parent = Window.Background
        Inner.Size = UDim2.new(1, 0, 1, 0)
        Inner.Selectable = false

        Tabs_1.BackgroundTransparency = 1
        Tabs_1.Name = "Tabs"
        Tabs_1.Parent = Inner
        Tabs_1.Size = UDim2.new(0, 140, 1, 0)
        Tabs_1.Selectable = false

        Scrolling_1.BackgroundTransparency = 1
        Scrolling_1.Name = "Scrolling"
        Scrolling_1.Parent = Tabs_1
        Scrolling_1.Size = UDim2.new(1, 0, 1, 0)
        Scrolling_1.ScrollBarThickness = 0

        UIListLayout_1.Parent = Scrolling_1
        UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder

        UIPadding_1.Parent = Scrolling_1

        UIPadding_2.Parent = Inner
        UIPadding_2.PaddingBottom = UDim.new(0, 15)
        UIPadding_2.PaddingLeft = UDim.new(0, 15)
        UIPadding_2.PaddingRight = UDim.new(0, 15)
        UIPadding_2.PaddingTop = UDim.new(0, 50)
        
        Window.TabScrolling = Scrolling_1
        
        UIListLayout_1:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
            Scrolling_1.CanvasSize = UDim2.new(0, 0, 0, UIListLayout_1.AbsoluteContentSize.Y + 10)
        end)
    end
    
    local Pages = Instance.new("Frame") do
        local Line_1 = Instance.new("Frame")
        local RealPage_1 = Instance.new("Frame")
        local UIPageLayout_1 = Instance.new("UIPageLayout")

        Pages.AnchorPoint = Vector2.new(1, 0)
        Pages.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
        Pages.BackgroundTransparency = 1
        Pages.Name = "Pages"
        Pages.Parent = Window.Background
        Pages.Position = UDim2.new(1, 0, 0, 0)
        Pages.Size = UDim2.new(1, -165, 1, 0)
        Pages.Selectable = false

        Line_1.BackgroundColor3 = Color3.fromRGB(199, 153, 255)
        Line_1.BackgroundTransparency = 0.9649999737739563
        Line_1.Name = "Line"
        Line_1.Parent = Pages
        Line_1.Size = UDim2.new(0, 1, 1, 0)
        Line_1.Selectable = false

        RealPage_1.AnchorPoint = Vector2.new(0.5, 0.5)
        RealPage_1.BackgroundTransparency = 1
        RealPage_1.Name = "RealPage"
        RealPage_1.Parent = Pages
        RealPage_1.Position = UDim2.new(0.5, 0, 0.5, 0)
        RealPage_1.Size = UDim2.new(1, 0, 1, -30)
        RealPage_1.Selectable = false
        RealPage_1.ClipsDescendants = true

        UIPageLayout_1.EasingStyle = Enum.EasingStyle.Exponential
        UIPageLayout_1.TweenTime = 0.4
        UIPageLayout_1.Parent = RealPage_1
        UIPageLayout_1.FillDirection = Enum.FillDirection.Vertical
        UIPageLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
        
        UIPageLayout_1.GamepadInputEnabled = false
        UIPageLayout_1.ScrollWheelInputEnabled = false
        UIPageLayout_1.TouchInputEnabled = false 
        
        Window.Pages = RealPage_1
        Window.PageLayout = UIPageLayout_1
    end
    
    function Window:MakeTab(Info)
        local Tab = {}
        
        local Title = Info.Title or "Unknow"
        local Icon = Info.Icon or 115960025411300
        
        local NewTab = Instance.new("Frame") do
            local UICorner_1 = Instance.new("UICorner")
            local Innerable_1 = Instance.new("Frame")
            local UIListLayout_1 = Instance.new("UIListLayout")
            local Icon_1 = Instance.new("ImageLabel")
            local UIGradient_1 = Instance.new("UIGradient")
            local UIGradient_2 = Instance.new("UIGradient")
            local UIPadding_1 = Instance.new("UIPadding")
            local Title_1 = Instance.new("TextLabel")

            NewTab.BackgroundColor3 = Color3.fromRGB(204, 85, 255)
            NewTab.BackgroundTransparency = 1 --0.75
            NewTab.Name = "NewTab"
            NewTab.Parent = Window.TabScrolling
            NewTab.Size = UDim2.new(1, 0, 0, 35)
            NewTab.Selectable = false

            UICorner_1.Parent = NewTab

            Innerable_1.BackgroundTransparency = 1
            Innerable_1.Name = "Innerable"
            Innerable_1.Parent = NewTab
            Innerable_1.Size = UDim2.new(1, 0, 1, 0)
            Innerable_1.Selectable = false

            UIListLayout_1.Padding = UDim.new(0, 8)
            UIListLayout_1.Parent = Innerable_1
            UIListLayout_1.FillDirection = Enum.FillDirection.Horizontal
            UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

            Icon_1.AnchorPoint = Vector2.new(0.5, 0.5)
            Icon_1.BackgroundTransparency = 1
            Icon_1.Name = "Icon"
            Icon_1.Parent = Innerable_1
            Icon_1.Size = UDim2.new(0, 18, 0, 18)
            Icon_1.Image = Library:Asset(Icon)
            local Icon_Content = SafeContent("rbxassetid://130970470497096")
            if Icon_Content then Icon_1.ImageContent = Icon_Content end

            UIGradient_1.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(233, 207, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(170, 85, 255)), }
            UIGradient_1.Rotation = 90
            UIGradient_1.Parent = Icon_1

            UIPadding_1.Parent = Innerable_1
            UIPadding_1.PaddingLeft = UDim.new(0, 10)

            Title_1.BackgroundTransparency = 1
            Title_1.Name = "Title"
            Title_1.Parent = Innerable_1
            Title_1.Size = UDim2.new(1, 0, 0, 14)
            Title_1.Selectable = false
            Title_1.FontFace = SafeFont(Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
            Title_1.RichText = true
            Title_1.Text = Title
            Title_1.TextColor3 = Color3.fromRGB(255, 255, 255)
            Title_1.TextSize = 12
            Title_1.TextXAlignment = Enum.TextXAlignment.Left
            
            UIGradient_2.Parent = NewTab
            UIGradient_2.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1)
            }) 
        end
        
        local NewPage = Instance.new("ScrollingFrame") do
            local UIListLayout_1 = Instance.new("UIListLayout")
            local UIPadding_1 = Instance.new("UIPadding")

            NewPage.BackgroundTransparency = 1
            NewPage.Name = "NewPage"
            NewPage.Parent = Window.Pages
            NewPage.Size = UDim2.new(1, 0, 1, 0)
            NewPage.ScrollBarImageTransparency = 1
            NewPage.ScrollBarThickness = 0

            UIListLayout_1.Padding = UDim.new(0, 7)
            UIListLayout_1.Parent = NewPage
            UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout_1.HorizontalAlignment = Enum.HorizontalAlignment.Center

            UIPadding_1.Parent = NewPage
            UIPadding_1.PaddingBottom = UDim.new(0, 15)
            UIPadding_1.PaddingLeft = UDim.new(0, 15)
            UIPadding_1.PaddingRight = UDim.new(0, 15)
            UIPadding_1.PaddingTop = UDim.new(0, 15)
            
            UIListLayout_1:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                NewPage.CanvasSize = UDim2.new(0, 0, 0, UIListLayout_1.AbsoluteContentSize.Y + 15)
            end)
        end
        
        local TabButton = Library:Button(NewTab) do
            local function OnNavative()
                for _, v in Window.TabScrolling:GetChildren() do
                    if v.Name == 'NewTab' and v.BackgroundTransparency == 0.75 then
                        Library:Tween(v, {
                            Time = 0.1,
                            Style = EasingStyle.Linear,
                            Direction = EasingDirection.Out,
                            Goal = {
                                BackgroundTransparency = 1
                            }
                        }):Play()
                    end
                end
                
                Library:Tween(NewTab, {
                    Time = 0.1,
                    Style = EasingStyle.Linear,
                    Direction = EasingDirection.Out,
                    Goal = {
                        BackgroundTransparency = 0.75
                    }
                }):Play()
                
                Window.PageLayout:JumpTo(NewPage)
            end
            
            TabButton.MouseButton1Click:Connect(OnNavative)
            
            function Tab:Navative()
                OnNavative()
            end
        end
        
        function Tab:Section(Text)
            local Section_1 = Instance.new("TextLabel")

            Section_1.AutomaticSize = Enum.AutomaticSize.Y
            Section_1.BackgroundTransparency = 1
            Section_1.Name = "Section"
            Section_1.Parent = NewPage
            Section_1.Size = UDim2.new(1, 0, 0, 14)
            Section_1.Selectable = false
            Section_1.FontFace = SafeFont(Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
            Section_1.RichText = true
            Section_1.Text = " " .. Text
            Section_1.TextColor3 = Color3.fromRGB(234, 234, 234)
            Section_1.TextSize = 20
            Section_1.TextWrapped = true
            Section_1.TextXAlignment = Enum.TextXAlignment.Left
        end
        
        function Tab:Label(Info)
            local LabelModule = {}
            local Title = Info.Title
            local Desc = Info.Desc
            
            local Row = Library:Row(NewPage, {
                Title = Title,
                Desc = Desc
            })
            
            function LabelModule:SetDesc(Text)
                Row.Desc.Text = Text
            end
            
            function LabelModule:SetTitle(Text)
                Row.Title.Text = Text
            end
            
            return LabelModule
        end
        
        function Tab:Toggle(Info)
            local ToggleModule = {}
            
            local Title = Info.Title
            local Desc = Info.Desc
            local Value = Info.Value or false
            local Callback = Info.Callback or function() return end
            
            local Row = Library:Row(NewPage, {
                Title = Title,
                Desc = Desc
            })
            
            Row.Padding.PaddingRight = UDim.new(0, 35)
            
            local UnEnabled_1 = Instance.new("Frame")
            local UICorner_1 = Instance.new("UICorner")
            local Enabled_1 = Instance.new("Frame")
            local UICorner_2 = Instance.new("UICorner")
            local Check_1 = Instance.new("ImageLabel")
            local Button = Library:Button(Row.Template)

            UnEnabled_1.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            UnEnabled_1.BackgroundTransparency = 0.5
            UnEnabled_1.Name = "UnEnabled"
            UnEnabled_1.Parent = Row.Right
            UnEnabled_1.Size = UDim2.new(0, 27, 0, 27)
            UnEnabled_1.Selectable = false

            UICorner_1.Parent = UnEnabled_1

            Enabled_1.BackgroundColor3 = Color3.fromRGB(174, 75, 255)
            Enabled_1.Name = "Enabled"
            Enabled_1.Parent = UnEnabled_1
            Enabled_1.BackgroundTransparency = 1
            Enabled_1.Size = UDim2.new(0, 27, 0, 27)
            Enabled_1.Selectable = false

            UICorner_2.Parent = Enabled_1

            Check_1.AnchorPoint = Vector2.new(0.5, 0.5)
            Check_1.BackgroundTransparency = 1
            Check_1.ImageTransparency = 1
            Check_1.Name = "Check"
            Check_1.Parent = Enabled_1
            Check_1.Position = UDim2.new(0.5, 0, 0.5, 0)
            Check_1.Size = UDim2.new(0.5, 0, 0.5, 0)
            Check_1.Image = "rbxassetid://93349826813564"
            Check_1.ImageColor3 = Color3.fromRGB(0, 0, 0)
            local Check_Content = SafeContent("rbxassetid://93349826813564")
            if Check_Content then Check_1.ImageContent = Check_Content end
            
            local function OnChanged(value)
                Library:Tween(Enabled_1, {
                    Time = 0.1,
                    Style = EasingStyle.Linear,
                    Direction = EasingDirection.Out,
                    Goal = {
                        BackgroundTransparency = value and 0 or 1
                    }
                }):Play()

                Library:Tween(Check_1, {
                    Time = 0.1,
                    Style = EasingStyle.Linear,
                    Direction = EasingDirection.Out,
                    Goal = {
                        ImageTransparency = value and 0 or 1
                    }
                }):Play()

                Callback(Value)
            end

            local function Init()
                if Library:IsDropdownOpen() then return end
                
                Value = not Value
                OnChanged(Value)
            end

            function ToggleModule:SetValue(value)
                Value = value
                OnChanged(Value)
            end

            OnChanged(Value)
            Button.MouseButton1Click:Connect(Init)
            
            return ToggleModule
        end
        
        function Tab:Button(Info)
            local ButtonModule = {}

            local Title = Info.Title
            local Desc = Info.Desc
            local Callback = Info.Callback or function() return end

            local Row = Library:Row(NewPage, {
                Title = Title,
                Desc = Desc
            })

            Row.Padding.PaddingRight = UDim.new(0, 40)
            
            local Button = Library:Button(Row.Template)
            
            local Check_1 = Instance.new("ImageLabel")
            Check_1.BackgroundTransparency = 1
            Check_1.ImageTransparency = 0.5
            Check_1.Name = "Check"
            Check_1.Parent = Row.Right
            Check_1.Size = UDim2.new(0, 20, 0, 20)
            Check_1.Image = Library:Asset(114050567449611)
            
            Button.MouseButton1Click:Connect(function()
                if Library:IsDropdownOpen() then return end
                
                task.spawn(Callback)
                
                Library:Tween(Row.Template, {
                    Time = 0.1,
                    Style = EasingStyle.Linear,
                    Direction = EasingDirection.Out,
                    Goal = {
                        BackgroundTransparency = 0.9
                    }
                }):Play()
                
                delay(0.05, function()
                    Library:Tween(Row.Template, {
                        Time = 0.1,
                        Style = EasingStyle.Linear,
                        Direction = EasingDirection.Out,
                        Goal = {
                            BackgroundTransparency = 0.975
                        }
                    }):Play()
                end)
            end)

            return ButtonModule
        end
        
        function Tab:Textbox(Info)
            local TextboxModule = {}

            local Title = Info.Title
            local Desc = Info.Desc
            local Value = Info.Value or "None"
            local ClearOnFocus = Info.ClearOnFocus or true
            local Callback = Info.Callback or function() return end

            local Row = Library:Row(NewPage, {
                Title = Title,
                Desc = Desc
            })

            Row.Padding.PaddingRight = UDim.new(0, 100)
            
            local BoxFrame_1 = Instance.new("Frame")
            local UICorner_1 = Instance.new("UICorner")
            local Bottom_1 = Instance.new("Frame")
            local TextBox_1 = Instance.new("TextBox")

            BoxFrame_1.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            BoxFrame_1.BackgroundTransparency = 0.75
            BoxFrame_1.Name = "BoxFrame"
            BoxFrame_1.Parent = Row.Right
            BoxFrame_1.Size = UDim2.new(0, 80, 0, 25)
            BoxFrame_1.Selectable = false

            UICorner_1.Parent = BoxFrame_1

            Bottom_1.AnchorPoint = Vector2.new(0, 1)
            Bottom_1.BackgroundColor3 = Color3.fromRGB(170, 85, 255)
            Bottom_1.Name = "Bottom"
            Bottom_1.Parent = BoxFrame_1
            Bottom_1.Position = UDim2.new(0, 0, 1, 0)
            Bottom_1.Size = UDim2.new(1, 0, 0, 1)
            Bottom_1.Selectable = false

            TextBox_1.AnchorPoint = Vector2.new(0.5, 0.5)
            TextBox_1.BackgroundTransparency = 1
            TextBox_1.Parent = BoxFrame_1
            TextBox_1.Position = UDim2.new(0.5, 0, 0.5, 0)
            TextBox_1.Size = UDim2.new(1, -20, 1, 0)
            TextBox_1.FontFace = SafeFont(Enum.FontWeight.Medium, Enum.FontStyle.Normal)
            TextBox_1.PlaceholderColor3 = Color3.fromRGB(128, 128, 128)
            TextBox_1.Text = tostring(Value)
            TextBox_1.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextBox_1.TextSize = 11
            TextBox_1.TextTransparency = 0.5
            TextBox_1.TextTruncate = Enum.TextTruncate.AtEnd
            TextBox_1.ClearTextOnFocus = ClearOnFocus
            
            TextBox_1.FocusLost:Connect(function()
                Value = TextBox_1.Text
                
                if Callback then Callback(Value) end
            end)
            
            return TextboxModule
        end
        
        function Tab:Slider(Info)
            local SliderModule = {}
            
            local Title = Info.Title
            local Desc = Info.Desc
            local Min = Info.Min or 1
            local Max = Info.Max or 100
            local Rounding = Info.Rounding or 0
            local Value = Info.Value or Min
            local Callback = Info.Callback or function() return end
            
            local Row = Library:Row(NewPage, {
                Title = Title,
                Desc = Desc
            })
            
            Row.Right.UIListLayout.Padding = UDim.new(0, 15)
            Row.Padding.PaddingRight = UDim.new(0, 150)
            
            local ScaleSlider_1 = Library:Create("Frame", {
                BackgroundTransparency = 1,
                LayoutOrder = 100,
                Name = "ScaleSlider",
                Parent = Row.Right,
                Size = UDim2.new(0, 100, 0, 20),
                Selectable = false,
            })

            local Slider_1 = Library:Create("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(16, 16, 16),
                LayoutOrder = 999,
                Name = "Slider",
                Parent = ScaleSlider_1,
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(0, 90, 0, 3),
                Selectable = false,
            })

            Library:Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = Slider_1,
            })

            local Value_1 = Library:Create("Frame", {
                BackgroundColor3 = Color3.fromRGB(170, 85, 255),
                Name = "Value",
                Parent = Slider_1,
                Size = UDim2.new(0.4609929025173187, 0, 1, 0),
                Selectable = false,
            })

            Library:Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = Value_1,
            })

            local Circle_1 = Library:Create("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(22, 22, 22),
                Name = "Circle",
                Parent = Value_1,
                Position = UDim2.new(1, 0, 0.5, 0),
                Size = UDim2.new(0, 15, 0, 15),
                Selectable = false,
            })

            Library:Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = Circle_1,
            })

            local White_1 = Library:Create("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(170, 85, 255),
                Name = "White",
                Parent = Circle_1,
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(0.800000011920929, 0, 0.800000011920929, 0),
                Selectable = false,
            })

            Library:Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = White_1,
            })

            Library:Create("UIStroke", {
                Color = Color3.fromRGB(22, 22, 22),
                Thickness = 1.5,
                Parent = Circle_1,
            })

            local Slide = Library:Button(Row.Template)
            
            local TextValue_1 = Library:Create("TextBox", {
                BackgroundTransparency = 1,
                LayoutOrder = -1,
                Name = "TextValue",
                Parent = Row.Right,
                Size = UDim2.new(0, 30, 0, 20),
                FontFace = SafeFont(Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                PlaceholderColor3 = Color3.fromRGB(128, 128, 128),
                Text = tostring(Value),
                TextColor3 = Color3.fromRGB(100, 100, 100),
                TextSize = 10,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextXAlignment = Enum.TextXAlignment.Right,
                ZIndex = Slide.ZIndex + 1
            })
            
            local dragging = false

            local function Round(n, decimals)
                local factor = 10 ^ decimals
                return math.floor(n * factor + 0.5) / factor
            end

            local function UpdateSlider(val)
                val = math.clamp(val, Min, Max)
                val = Round(val, Rounding)
                local ratio = (val - Min) / (Max - Min)
                
                
                Library:Tween(Value_1, {
                    Time = 0.1,
                    Style = EasingStyle.Linear,
                    Direction = EasingDirection.Out,
                    Goal = {
                        Size = UDim2.new(ratio, 0, 1, 0)
                    }
                }):Play()
                
                TextValue_1.Text = tostring(val)
                Callback(val)
                return val
            end

            local function GetValueFromInput(input)
                local absX = Slider_1.AbsolutePosition.X
                local absW = Slider_1.AbsoluteSize.X
                local ratio = math.clamp((input.Position.X - absX) / absW, 0, 1)
                return ratio * (Max - Min) + Min
            end

            Slide.InputBegan:Connect(function(input)
                if Library:IsDropdownOpen() then return end
                
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    UpdateSlider(GetValueFromInput(input))
                end
            end)

            Slide.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if Library:IsDropdownOpen() then return end
                
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSlider(GetValueFromInput(input))
                end
            end)

            TextValue_1.FocusLost:Connect(function()
                local val = tonumber(TextValue_1.Text) or Value
                Value = UpdateSlider(val)
            end)

            UpdateSlider(Value)
            
            return SliderModule
        end
        
        function Tab:Dropdown(Info)
            local DropdownModule = {}

            local Title = Info.Title
            local List = Info.List or {}
            local Value = Info.Value or "N/A"
            local IsMulti = typeof(Value) == 'table' and true or false
            local Callback = Info.Callback or function() return end

            local Row = Library:Row(NewPage, {
                Title = Title,
                Desc = "None"
            })

            local Description = Row.Desc
            Row.Padding.PaddingRight = UDim.new(0, 50)

            Library:Create("ImageLabel", {
                BackgroundTransparency = 1,
                Name = "Asset",
                Parent = Row.Right,
                Size = UDim2.new(0, 20, 0, 20),
                Image = Library:Asset(132291592681506),
                ImageTransparency = 0.5,
            })

            local ClickOpen = Library:Button(Row.Template)

            local NewDropdown_1 = Library:Create("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(9, 0, 13),
                BackgroundTransparency = 0.3,
                Name = "NewDropdown",
                Parent = Window.Background,
                Position = UDim2.new(0.5, 0, 0.3, 0),
                Size = UDim2.new(0, 300, 0, 250),
                Selectable = false,
                Visible = false,
            })
            
            

            do
                local UICorner = Library:Create("UICorner", {
                    CornerRadius = UDim.new(0, 20),
                    Parent = NewDropdown_1,
                })
                
                UICorner.BottomRightRadius = UDim.new(0, 8)
                UICorner.BottomLeftRadius = UDim.new(0, 8)
            end

            Library:Create("UIListLayout", {
                Padding = UDim.new(0, 5),
                Parent = NewDropdown_1,
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
            })

            -- Head
            local Head_1 = Library:Create("Frame", {
                BackgroundTransparency = 1,
                Name = "Head",
                Parent = NewDropdown_1,
                Size = UDim2.new(1, 0, 0, 35),
                Selectable = false,
            })

            Library:Create("UIPadding", {
                Parent = Head_1,
                PaddingTop = UDim.new(0, 7),
            })

            local Search_1 = Library:Create("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 0.95,
                Name = "Search",
                Parent = Head_1,
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(1, -16, 1, 0),
                Selectable = false,
            })

            do
                local UICorner = Library:Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = Search_1,
                })
                
                UICorner.BottomRightRadius = UDim.new(0, 0)
                UICorner.BottomLeftRadius = UDim.new(0, 0)
            end

            Library:Create("Frame", {
                AnchorPoint = Vector2.new(0, 1),
                BackgroundColor3 = Color3.fromRGB(170, 85, 255),
                Name = "Bottom",
                Parent = Search_1,
                Position = UDim2.new(0, 0, 1, 0),
                Size = UDim2.new(1, 0, 0, 1),
                Selectable = false,
            })

            local TextBox_1 = Library:Create("TextBox", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                CursorPosition = -1,
                Parent = Search_1,
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(1, -20, 1, 0),
                FontFace = SafeFont(Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                PlaceholderColor3 = Color3.fromRGB(128, 128, 128),
                PlaceholderText = "Search",
                Text = "",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 13,
                TextTransparency = 0.5,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextXAlignment = Enum.TextXAlignment.Left,
            })

            local List_1 = Library:Create("ScrollingFrame", {
                BackgroundTransparency = 1,
                Name = "List",
                Parent = NewDropdown_1,
                Size = UDim2.new(1, -15, 0, 200),
                ScrollBarImageTransparency = 1,
                ScrollBarThickness = 0,
            })

            local UIListLayout_list = Library:Create("UIListLayout", {
                Padding = UDim.new(0, 5),
                Parent = List_1,
                SortOrder = Enum.SortOrder.LayoutOrder,
            })

            UIListLayout_list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                List_1.CanvasSize = UDim2.new(0, 0, 0, UIListLayout_list.AbsoluteContentSize.Y + 10)
            end)

            local selectedValues = {}
            local selectedOrder = 0
            local isOpen = false

            local function isValueInTable(val, tbl)
                if type(tbl) ~= "table" then return false end
                for _, v in pairs(tbl) do
                    if v == val then return true end
                end
                return false
            end

            local function GetText()
                if IsMulti then
                    local keys = {}
                    for k in pairs(selectedValues) do table.insert(keys, k) end
                    table.sort(keys)
                    return #keys > 0 and table.concat(keys, ", ") or "N/A"
                end
                return Value and tostring(Value) or "N/A"
            end

            local function Settext()
                if Description then
                    Description.Text = GetText()
                end
            end

            if Description then
                Description.Text = GetText()
            end

            TextBox_1:GetPropertyChangedSignal("Text"):Connect(function()
                local SearchT = string.lower(TextBox_1.Text)
                for _, v in pairs(List_1:GetChildren()) do
                    if v:IsA("Frame") and v.Name == "NewList" then
                        v.Visible = string.find(string.lower(v.Section.Text), SearchT, 1, true) ~= nil
                    end
                end
            end)

            UserInputService.InputBegan:Connect(function(A)
                if not isOpen then return end
                local mouse = LocalPlayer:GetMouse()
                local mx, my = mouse.X, mouse.Y
                local DBP, DBS = NewDropdown_1.AbsolutePosition, NewDropdown_1.AbsoluteSize
                if A.UserInputType == Enum.UserInputType.MouseButton1 or A.UserInputType == Enum.UserInputType.Touch then
                    if not (mx >= DBP.X and mx <= DBP.X + DBS.X and my >= DBP.Y and my <= DBP.Y + DBS.Y) then
                        isOpen = false
                        NewDropdown_1.Visible = false
                        NewDropdown_1.Position = UDim2.new(0.5, 0, 0.3, 0)
                    end
                end
            end)

            ClickOpen.MouseButton1Click:Connect(function()
                if Library:IsDropdownOpen() then return end

                isOpen = not isOpen

                if isOpen then
                    NewDropdown_1.Visible = true
                    Library:Tween(NewDropdown_1, {
                        Time = 0.3,
                        Style = EasingStyle.Back,
                        Direction = EasingDirection.Out,
                        Goal = { Position = UDim2.new(0.5, 0, 0.5, 0) }
                    }):Play()
                else
                    NewDropdown_1.Visible = false
                    NewDropdown_1.Position = UDim2.new(0.5, 0, 0.3, 0)
                end
            end)

            function DropdownModule:Clear(filter)
                for _, v in ipairs(List_1:GetChildren()) do
                    if v:IsA("Frame") and v.Name == "NewList" then
                        local shouldClear = filter == nil
                            or (type(filter) == "string" and v.Section.Text == filter)
                            or (type(filter) == "table" and isValueInTable(v.Section.Text, filter))
                        if shouldClear then v:Destroy() end
                    end
                end

                if filter == nil then
                    Value = IsMulti and {} or nil
                    selectedValues = {}
                    selectedOrder = 0
                    if Description then Description.Text = "N/A" end
                end
            end

            function DropdownModule:AddList(Name)
                local NewList_1 = Library:Create("Frame", {
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    Name = "NewList",
                    Parent = List_1,
                    Size = UDim2.new(1, 0, 0, 30),
                    Selectable = false,
                })

                Library:Create("UICorner", {
                    CornerRadius = UDim.new(0, 5),
                    Parent = NewList_1,
                })

                local Section_1 = Library:Create("TextLabel", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundTransparency = 1,
                    Name = "Section",
                    Parent = NewList_1,
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Size = UDim2.new(1, -20, 1, 0),
                    Selectable = false,
                    FontFace = SafeFont(Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                    RichText = true,
                    Text = tostring(Name),
                    TextColor3 = Color3.fromRGB(234, 234, 234),
                    TextSize = 12,
                    TextTransparency = 0.5,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })

                local function OnVisual(selected)
                    Library:Tween(NewList_1, {
                        Time = 0.2,
                        Style = EasingStyle.Linear,
                        Direction = EasingDirection.Out,
                        Goal = { BackgroundTransparency = selected and 0.95 or 1 }
                    }):Play()
                    Library:Tween(Section_1, {
                        Time = 0.2,
                        Style = EasingStyle.Linear,
                        Direction = EasingDirection.Out,
                        Goal = { TextTransparency = selected and 0 or 0.5 }
                    }):Play()
                end

                local Click = Library:Button(NewList_1)

                local function OnSelected()
                    if IsMulti then
                        if selectedValues[Name] then
                            selectedValues[Name] = nil
                            NewList_1.LayoutOrder = 0
                            OnVisual(false)
                        else
                            selectedOrder = selectedOrder - 1
                            selectedValues[Name] = selectedOrder
                            NewList_1.LayoutOrder = selectedOrder
                            OnVisual(true)
                        end

                        local selectedList = {}
                        for k in pairs(selectedValues) do table.insert(selectedList, k) end
                        table.sort(selectedList)
                        Value = selectedList
                        Settext()
                        pcall(Callback, selectedList)
                    else
                        for _, v in pairs(List_1:GetChildren()) do
                            if v:IsA("Frame") and v.Name == "NewList" and v ~= NewList_1 then
                                Library:Tween(v, {
                                    Time = 0.2,
                                    Style = EasingStyle.Linear,
                                    Direction = EasingDirection.Out,
                                    Goal = { BackgroundTransparency = 1 }
                                }):Play()
                                Library:Tween(v.Section, {
                                    Time = 0.2,
                                    Style = EasingStyle.Linear,
                                    Direction = EasingDirection.Out,
                                    Goal = { TextTransparency = 0.5 }
                                }):Play()
                            end
                        end

                        OnVisual(true)
                        Value = Name
                        Settext()
                        pcall(Callback, Value)
                    end
                end

                task.defer(function()
                    if IsMulti then
                        if isValueInTable(Name, Value) then
                            selectedOrder = selectedOrder - 1
                            selectedValues[Name] = selectedOrder
                            NewList_1.LayoutOrder = selectedOrder
                            OnVisual(true)
                            local selectedList = {}
                            for k in pairs(selectedValues) do table.insert(selectedList, k) end
                            table.sort(selectedList)
                            Settext()
                            pcall(Callback, selectedList)
                        end
                    else
                        if Name == Value then
                            OnVisual(true)
                            Settext()
                            pcall(Callback, Value)
                        end
                    end
                end)

                Click.MouseButton1Click:Connect(OnSelected)
            end

            for _, name in ipairs(List) do
                DropdownModule:AddList(name)
            end

            return DropdownModule
        end
        
        return Tab
    end
    
    do
        local ToggleScreen = Library:Create("ScreenGui", {
            Name = "Senzy Pillow",
            Parent = Library:Parent(),
            ZIndexBehavior = Enum.ZIndexBehavior.Global,
            IgnoreGuiInset = true,
        })

        local Pillow_1 = Library:Create("TextButton", {
            Name = "Pillow",
            Parent = ToggleScreen,
            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
            BorderSizePixel = 0,
            Position = UDim2.new(0.06, 0, 0.15, 0),
            Size = UDim2.new(0, 50, 0, 50),
            Text = "",
        })

        Library:Create("UICorner", {
            Parent = Pillow_1,
            CornerRadius = UDim.new(0, 15),
        })

        Library:Create("ImageLabel", {
            Name = "Logo",
            Parent = Pillow_1,
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0.5, 0, 0.5, 0),
            Image = Library:Asset(Logo),
        })

        Library:Draggable(Pillow_1)
        
        local Background_1 = Window.Background

        Pillow_1.MouseButton1Click:Connect(function()
            Background_1.Visible = not Background_1.Visible
        end)

        local holdingSpace = false

        UserInputService.InputBegan:Connect(function(Input, Processed)
            if Processed then return end
            if Input.KeyCode == Enum.KeyCode.Space then
                holdingSpace = true
            end
            if holdingSpace and Input.KeyCode == Enum.KeyCode.LeftShift then
                Background_1.Visible = not Background_1.Visible
            end
        end)

        UserInputService.InputEnded:Connect(function(Input)
            if Input.KeyCode == Enum.KeyCode.Space then
                holdingSpace = false
            end
        end)
    end
    
    return Window
end

-- ============================================================
-- Auto Demo: ทำให้รัน loadstring(...)() แล้วขึ้น UI ได้เลย
-- ถ้าจะใช้ Library เองแบบ custom ให้ลบส่วนนี้ทิ้ง
-- แล้วเขียน Library:Window({...}) เองแทน
-- ============================================================
do
    local Window = Library:Window({
        Title = "Senzy",
        Footer = "Premium Script",
    })

    local MainTab = Window:MakeTab({
        Title = "Main",
    })

    MainTab:Section("ตัวอย่างการใช้งาน")

    MainTab:Label({
        Title = "ยินดีต้อนรับ",
        Desc = "กด Space + Left Shift หรือปุ่มลอยมุมจอ เพื่อเปิด/ปิดหน้าต่างนี้"
    })

    MainTab:Toggle({
        Title = "Toggle ตัวอย่าง",
        Desc = "เปิด/ปิดอะไรบางอย่าง",
        Value = false,
        Callback = function(v)
            print("Toggle เปลี่ยนเป็น:", v)
        end
    })

    MainTab:Button({
        Title = "ปุ่มตัวอย่าง",
        Desc = "กดเพื่อรันฟังก์ชัน",
        Callback = function()
            print("กดปุ่มแล้ว!")
        end
    })

    MainTab:Slider({
        Title = "Slider ตัวอย่าง",
        Desc = "เลื่อนเพื่อปรับค่า",
        Min = 0,
        Max = 100,
        Value = 50,
        Callback = function(val)
            print("ค่า Slider:", val)
        end
    })

    MainTab:Dropdown({
        Title = "Dropdown ตัวอย่าง",
        List = {"ตัวเลือก 1", "ตัวเลือก 2", "ตัวเลือก 3"},
        Value = "ตัวเลือก 1",
        Callback = function(selected)
            print("เลือก:", selected)
        end
    })

    local SettingsTab = Window:MakeTab({
        Title = "Settings",
    })

    SettingsTab:Section("การตั้งค่า")

    SettingsTab:Toggle({
        Title = "โหมดตัวอย่าง",
        Desc = "คำอธิบาย",
        Value = true,
        Callback = function(v)
            print("โหมด:", v)
        end
    })
end

return Library
