--=====================================================================
-- [1] SERVICES & CORE REFERENCES
--=====================================================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

--=====================================================================
-- [2] LOGO / ASSET CONFIG
--=====================================================================
local LOGO_IMAGE_NAME = "Senz1.png"
local LOGO_URL = "https://raw.githubusercontent.com/senzxyz2xxx/Ui/refs/heads/main/Senz1.png"

if writefile and getgenv and LOGO_URL ~= "" then
    if not isfile(LOGO_IMAGE_NAME) then
        pcall(function() writefile(LOGO_IMAGE_NAME, game:HttpGet(LOGO_URL)) end)
    end
end

-- ล้าง GUI เก่าก่อนสร้างใหม่ (กันซ้อนเวลารันสคริปต์ซ้ำ)
for _, name in ipairs({ "SenzyHub_Main", "SenzyHub_Float" }) do
    if playerGui:FindFirstChild(name) then playerGui[name]:Destroy() end
end

--=====================================================================
-- [3] THEME: COLORS / FONTS / DEVICE DETECTION
--=====================================================================
local COLORS = {
    Bg      = Color3.fromRGB(16, 13, 22),
    Panel   = Color3.fromRGB(26, 19, 34),
    PanelHi = Color3.fromRGB(34, 25, 44),
    Stroke  = Color3.fromRGB(120, 60, 170),
    Accent  = Color3.fromRGB(178, 70, 210),
    Accent2 = Color3.fromRGB(255, 105, 180),
    Text    = Color3.fromRGB(240, 230, 245),
    SubText = Color3.fromRGB(160, 145, 180),
    Off     = Color3.fromRGB(65, 55, 78),
}

local FONT_HEADER = Enum.Font.GothamBold      -- หัวข้อ/ชื่อ
local FONT_BODY   = Enum.Font.GothamSemibold  -- เนื้อหาทั่วไป (หนากว่า Gotham ปกติ)

local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
local isSmallScreen = viewport.X < 700

--=====================================================================
-- [4] UI UTILITY FUNCTIONS (tween / corner / stroke / gradient)
--=====================================================================
local function tween(obj, props, time, style)
    return TweenService:Create(obj, TweenInfo.new(time or 0.18, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
end
local function corner(inst, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 10); c.Parent = inst; return c end
local function strokeOn(inst, thick, trans) local s = Instance.new("UIStroke"); s.Color = COLORS.Stroke; s.Thickness = thick or 1; s.Transparency = trans or 0.4; s.Parent = inst; return s end
local function gradientOn(inst, rot) local g = Instance.new("UIGradient"); g.Color = ColorSequence.new(COLORS.Accent, COLORS.Accent2); g.Rotation = rot or 45; g.Parent = inst; return g end

--=====================================================================
-- [5] LANGUAGE SYSTEM (i18n: EN / TH)
--=====================================================================
local LANG = {
    en = {
        settings_tab      = "Settings",
        display_section   = "Display",
        ui_scale          = "UI Scale",
        keybind_section    = "Keybind",
        keybind_label     = "Toggle Keybind: ",
        keybind_listen    = "Press a key...",
        special_section   = "Special Mode",
        nickname_toggle   = 'Nickname overlay: "Senzy on Top" (visible only to you)',
        language_section  = "Language",
        language_toggle   = "Language: English",
        nick_on           = 'Nickname overlay enabled',
        nick_off          = "Nickname overlay disabled",
    },
    th = {
        settings_tab      = "ตั้งค่า",
        display_section   = "การแสดงผล",
        ui_scale          = "ขนาด UI",
        keybind_section    = "คีย์ลัด",
        keybind_label     = "คีย์ลัดเปิด/ปิด: ",
        keybind_listen    = "กดปุ่มที่ต้องการ...",
        special_section   = "โหมดพิเศษ",
        nickname_toggle   = 'ป้ายชื่อ "Senzy on Top" (เห็นเฉพาะคุณ)',
        language_section  = "ภาษา",
        language_toggle   = "ภาษา: ไทย",
        nick_on           = "เปิดป้ายชื่อแล้ว",
        nick_off          = "ปิดป้ายชื่อแล้ว",
    }
}

local currentLang = "en"
local function t(key) return LANG[currentLang][key] end

-- เก็บ element ที่ต้องอัปเดตข้อความตอนสลับภาษา: { inst = TextLabel/Button, key = "keyname" }
local translatable = {}
local function registerText(inst, key)
    table.insert(translatable, { inst = inst, key = key })
    inst.Text = t(key)
end

--=====================================================================
-- [6] DRAG & CLICK SYSTEM (แยก state ต่อปุ่ม ไม่ชนกัน)
--=====================================================================
local activeDrag = nil

UserInputService.InputChanged:Connect(function(input)
    if activeDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - activeDrag.startInput
        if delta.Magnitude > 4 then activeDrag.moved = true end
        activeDrag.target.Position = UDim2.new(
            activeDrag.startPos.X.Scale, activeDrag.startPos.X.Offset + delta.X,
            activeDrag.startPos.Y.Scale, activeDrag.startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if activeDrag and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        local drag = activeDrag
        activeDrag = nil
        if not drag.moved and drag.onClick then
            drag.onClick()
        end
    end
end)

-- handle = ปุ่ม/พื้นที่ที่กดเพื่อลาก, target = frame ที่จะถูกขยับ, onClick = callback เมื่อ "คลิกล้วนๆ" ไม่ลาก
local function bindDrag(handle, target, onClick)
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            activeDrag = {
                target = target,
                startInput = input.Position,
                startPos = target.Position,
                moved = false,
                onClick = onClick,
            }
        end
    end)
end

--=====================================================================
-- [7] MAIN WINDOW SHELL (frame / topbar / close-minimize buttons)
--=====================================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SenzyHub_Main"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 9999
screenGui.Parent = playerGui

local winW = isSmallScreen and math.floor(viewport.X * 0.92) or 560
local winH = isSmallScreen and math.floor(viewport.Y * 0.6) or 420

local main = Instance.new("Frame")
main.Name = "MainWindow"
main.Size = UDim2.fromOffset(winW, winH)
main.Position = UDim2.new(0.5, -winW / 2, 0.5, -winH / 2)
main.BackgroundColor3 = COLORS.Bg
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = screenGui
corner(main, 16)
strokeOn(main, 1.5, 0.1)

local uiScale = Instance.new("UIScale")
uiScale.Scale = isSmallScreen and 0.9 or 1
uiScale.Parent = main

local topBarH = isMobile and 56 or 50
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, topBarH)
topBar.BackgroundColor3 = COLORS.Panel
topBar.BorderSizePixel = 0
topBar.Parent = main
corner(topBar, 16)

local accentLine = Instance.new("Frame")
accentLine.Size = UDim2.new(1, 0, 0, 3)
accentLine.Position = UDim2.new(0, 0, 1, -3)
accentLine.BorderSizePixel = 0
accentLine.Parent = topBar
gradientOn(accentLine, 0)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -110, 1, 0)
titleLabel.Position = UDim2.new(0, 16, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "SENZY HUB"
titleLabel.TextColor3 = COLORS.Text
titleLabel.Font = FONT_HEADER
titleLabel.TextSize = isMobile and 20 or 18
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = topBar

local function makeTopBtn(text, xOffset, size)
    size = size or (isMobile and 34 or 28)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(size, size)
    btn.Position = UDim2.new(1, xOffset, 0.5, -size / 2)
    btn.BackgroundColor3 = COLORS.Panel
    btn.Text = text
    btn.TextColor3 = COLORS.SubText
    btn.Font = FONT_HEADER
    btn.TextSize = 15
    btn.AutoButtonColor = false
    btn.Parent = topBar
    corner(btn, 8)
    strokeOn(btn, 1, 0.4)
    return btn
end

local btnSize = isMobile and 34 or 28
local closeBtn = makeTopBtn("X", -(btnSize + 8))
local minimizeBtn = makeTopBtn("-", -(btnSize * 2 + 14))

closeBtn.MouseEnter:Connect(function() tween(closeBtn, { BackgroundColor3 = Color3.fromRGB(200, 60, 90) }):Play() end)
closeBtn.MouseLeave:Connect(function() tween(closeBtn, { BackgroundColor3 = COLORS.Panel }):Play() end)
minimizeBtn.MouseEnter:Connect(function() tween(minimizeBtn, { BackgroundColor3 = COLORS.Accent }):Play() end)
minimizeBtn.MouseLeave:Connect(function() tween(minimizeBtn, { BackgroundColor3 = COLORS.Panel }):Play() end)

bindDrag(topBar, main) -- ลากอย่างเดียว ไม่มี onClick

--=====================================================================
-- [8] SIDEBAR (Tab buttons container)
--=====================================================================
local sideW = isSmallScreen and 100 or 140
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, sideW, 1, -topBarH)
sidebar.Position = UDim2.new(0, 0, 0, topBarH)
sidebar.BackgroundColor3 = COLORS.Panel
sidebar.BorderSizePixel = 0
sidebar.Parent = main

local tabList = Instance.new("UIListLayout")
tabList.Padding = UDim.new(0, 6)
tabList.SortOrder = Enum.SortOrder.LayoutOrder
tabList.Parent = sidebar

local sidePad = Instance.new("UIPadding")
sidePad.PaddingTop = UDim.new(0, 10)
sidePad.PaddingLeft = UDim.new(0, 8)
sidePad.PaddingRight = UDim.new(0, 8)
sidePad.Parent = sidebar

--=====================================================================
-- [9] CONTENT / TAB SYSTEM (page switching)
--=====================================================================
local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, -sideW, 1, -topBarH)
content.Position = UDim2.new(0, sideW, 0, topBarH)
content.BackgroundColor3 = COLORS.Bg
content.BorderSizePixel = 0
content.Parent = main

local tabs = {}

local function createTab(tabKey)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, 0, 0, isMobile and 42 or 36)
    tabBtn.BackgroundColor3 = COLORS.Bg
    tabBtn.Text = ""
    tabBtn.AutoButtonColor = false
    tabBtn.Parent = sidebar
    corner(tabBtn, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = COLORS.SubText
    label.Font = FONT_HEADER
    label.TextSize = isMobile and 14 or 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = tabBtn
    registerText(label, tabKey)

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = COLORS.Accent
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = false
    page.Parent = content

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 14)
    pad.PaddingLeft = UDim.new(0, 14)
    pad.PaddingRight = UDim.new(0, 14)
    pad.PaddingBottom = UDim.new(0, 14)
    pad.Parent = page

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 10)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = page

    local function select()
        for _, tb in ipairs(tabs) do
            tb.page.Visible = false
            tween(tb.btn, { BackgroundColor3 = COLORS.Bg }, 0.15):Play()
            tb.label.TextColor3 = COLORS.SubText
        end
        page.Visible = true
        tween(tabBtn, { BackgroundColor3 = COLORS.PanelHi }, 0.15):Play()
        label.TextColor3 = COLORS.Accent2
    end

    tabBtn.MouseButton1Click:Connect(select)
    tabBtn.MouseEnter:Connect(function() if not page.Visible then tween(tabBtn, { BackgroundColor3 = COLORS.PanelHi }, 0.12):Play() end end)
    tabBtn.MouseLeave:Connect(function() if not page.Visible then tween(tabBtn, { BackgroundColor3 = COLORS.Bg }, 0.12):Play() end end)

    table.insert(tabs, { btn = tabBtn, page = page, label = label })
    if #tabs == 1 then select() end

    return page
end

--=====================================================================
-- [10] REUSABLE UI COMPONENTS (section / button / toggle / slider)
--=====================================================================
local function addSection(page, key)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = COLORS.Accent2
    lbl.Font = FONT_HEADER
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = page
    registerText(lbl, key)
    return lbl
end

local function addButton(page, key, callback)
    local h = isMobile and 44 or 38
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, h)
    btn.BackgroundColor3 = COLORS.Panel
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = page
    corner(btn, 8)
    strokeOn(btn, 1, 0.5)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -16, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = COLORS.Text
    lbl.Font = FONT_BODY
    lbl.TextSize = isMobile and 14 or 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = btn
    if key then registerText(lbl, key) end

    btn.MouseEnter:Connect(function() tween(btn, { BackgroundColor3 = COLORS.Accent }, 0.12):Play() end)
    btn.MouseLeave:Connect(function() tween(btn, { BackgroundColor3 = COLORS.Panel }, 0.12):Play() end)
    btn.MouseButton1Click:Connect(function() if callback then task.spawn(callback) end end)
    return btn, lbl
end

local function addToggle(page, key, default, callback)
    local state = default or false
    local h = isMobile and 44 or 38
    local holder = Instance.new("TextButton")
    holder.Size = UDim2.new(1, 0, 0, h)
    holder.BackgroundColor3 = COLORS.Panel
    holder.Text = ""
    holder.AutoButtonColor = false
    holder.Parent = page
    corner(holder, 8)
    strokeOn(holder, 1, 0.5)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -70, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = COLORS.Text
    lbl.Font = FONT_BODY
    lbl.TextSize = isMobile and 14 or 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextWrapped = true
    lbl.Parent = holder
    if key then registerText(lbl, key) end

    local track = Instance.new("Frame")
    track.Size = UDim2.fromOffset(40, 20)
    track.Position = UDim2.new(1, -52, 0.5, -10)
    track.BackgroundColor3 = COLORS.Off
    track.BorderSizePixel = 0
    track.Parent = holder
    corner(track, 10)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(16, 16)
    knob.Position = UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = track
    corner(knob, 8)

    local function render()
        if state then
            tween(track, { BackgroundColor3 = COLORS.Accent }, 0.15):Play()
            tween(knob, { Position = UDim2.new(1, -18, 0.5, -8) }, 0.15):Play()
        else
            tween(track, { BackgroundColor3 = COLORS.Off }, 0.15):Play()
            tween(knob, { Position = UDim2.new(0, 2, 0.5, -8) }, 0.15):Play()
        end
    end
    render()

    holder.MouseButton1Click:Connect(function()
        state = not state
        render()
        if callback then task.spawn(callback, state) end
    end)

    return { Set = function(v) state = v; render() end, Get = function() return state end }
end

local function addSlider(page, key, min, max, default, callback)
    local value = default or min
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 52)
    holder.BackgroundColor3 = COLORS.Panel
    holder.BorderSizePixel = 0
    holder.Parent = page
    corner(holder, 8)
    strokeOn(holder, 1, 0.5)
    local hp = Instance.new("UIPadding")
    hp.PaddingTop = UDim.new(0, 10)
    hp.PaddingLeft = UDim.new(0, 10)
    hp.PaddingRight = UDim.new(0, 10)
    hp.Parent = holder

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, 0, 0, 16)
    titleLbl.BackgroundTransparency = 1
    titleLbl.TextColor3 = COLORS.Text
    titleLbl.Font = FONT_BODY
    titleLbl.TextSize = 13
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = holder

    local function refreshTitle()
        titleLbl.Text = t(key) .. ": " .. tostring(value)
    end
    refreshTitle()
    table.insert(translatable, { custom = refreshTitle })

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1, 0, 0, 10)
    barBg.Position = UDim2.new(0, 0, 0, 28)
    barBg.BackgroundColor3 = COLORS.Off
    barBg.BorderSizePixel = 0
    barBg.Parent = holder
    corner(barBg, 5)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    fill.BorderSizePixel = 0
    fill.Parent = barBg
    corner(fill, 5)
    gradientOn(fill, 0)

    local dragging = false
    local function updateFromInput(inputPos)
        local rel = math.clamp((inputPos.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
        value = min + (max - min) * rel
        if max - min <= 2 then value = math.floor(value * 100) / 100 else value = math.floor(value) end
        fill.Size = UDim2.new(rel, 0, 1, 0)
        refreshTitle()
        if callback then task.spawn(callback, value) end
    end

    barBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromInput(input.Position)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromInput(input.Position)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return { Set = function(v) value = v; local rel = (v - min) / (max - min); fill.Size = UDim2.new(rel, 0, 1, 0); refreshTitle() end }
end

--=====================================================================
-- [11] NOTIFICATION SYSTEM (toast, มุมขวาล่าง)
--=====================================================================
local notifHolder = Instance.new("Frame")
notifHolder.AnchorPoint = Vector2.new(1, 1)
notifHolder.Size = UDim2.new(0, isMobile and 220 or 250, 1, -20)
notifHolder.Position = UDim2.new(1, -12, 1, -12)
notifHolder.BackgroundTransparency = 1
notifHolder.Parent = screenGui

local notifList = Instance.new("UIListLayout")
notifList.Padding = UDim.new(0, 8)
notifList.HorizontalAlignment = Enum.HorizontalAlignment.Right
notifList.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifList.SortOrder = Enum.SortOrder.LayoutOrder
notifList.Parent = notifHolder

local function Notify(text, duration)
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(1, 0, 0, 50)
    notif.BackgroundColor3 = COLORS.Panel
    notif.BackgroundTransparency = 1
    notif.BorderSizePixel = 0
    notif.ClipsDescendants = true
    notif.Parent = notifHolder
    corner(notif, 10)
    local s = strokeOn(notif, 1, 1)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 4, 1, 0)
    bar.BackgroundTransparency = 1
    bar.BorderSizePixel = 0
    bar.Parent = notif
    gradientOn(bar, 90)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 1, -10)
    lbl.Position = UDim2.new(0, 14, 0, 5)
    lbl.BackgroundTransparency = 1
    lbl.TextTransparency = 1
    lbl.Text = text or ""
    lbl.TextColor3 = COLORS.Text
    lbl.Font = FONT_BODY
    lbl.TextSize = 13
    lbl.TextWrapped = true
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = notif

    tween(notif, { BackgroundTransparency = 0 }, 0.2):Play()
    tween(s, { Transparency = 0.3 }, 0.2):Play()
    tween(lbl, { TextTransparency = 0 }, 0.2):Play()

    task.delay(duration or 3, function()
        tween(notif, { BackgroundTransparency = 1 }, 0.25):Play()
        tween(lbl, { TextTransparency = 1 }, 0.25):Play()
        tween(s, { Transparency = 1 }, 0.25):Play()
        task.wait(0.25)
        notif:Destroy()
    end)
end

--=====================================================================
-- [12] TAB CONTENT: SETTINGS
--=====================================================================
local settingsPage = createTab("settings_tab")

-- 12.1 Display
addSection(settingsPage, "display_section")
addSlider(settingsPage, "ui_scale", 0.7, 1.3, uiScale.Scale, function(value)
    uiScale.Scale = value
end)

-- 12.2 Keybind
addSection(settingsPage, "keybind_section")
local currentKeybind = Enum.KeyCode.RightControl
local keybindListening = false
local keybindBtn, keybindLabel = addButton(settingsPage, nil, function() end)
keybindLabel.Text = t("keybind_label") .. currentKeybind.Name

keybindBtn.MouseButton1Click:Connect(function()
    if keybindListening then return end
    keybindListening = true
    keybindLabel.Text = t("keybind_listen")
    local conn
    conn = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            currentKeybind = input.KeyCode
            keybindLabel.Text = t("keybind_label") .. currentKeybind.Name
            keybindListening = false
            conn:Disconnect()
        end
    end)
end)
table.insert(translatable, { custom = function()
    if not keybindListening then
        keybindLabel.Text = t("keybind_label") .. currentKeybind.Name
    end
end })

-- 12.3 Special mode (local-only nickname overlay)
addSection(settingsPage, "special_section")
local nicknameEnabled = false
local nicknameBillboard = nil

local function applyNickname(character)
    if nicknameBillboard then nicknameBillboard:Destroy() end
    if not nicknameEnabled or not character then return end
    local head = character:FindFirstChild("Head")
    if not head then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "SenzyNicknameOverlay"
    billboard.Size = UDim2.new(0, 200, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.fromScale(1, 1)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = "Senzy on Top"
    nameLbl.TextColor3 = COLORS.Accent2
    nameLbl.Font = FONT_HEADER
    nameLbl.TextSize = 18
    nameLbl.TextStrokeTransparency = 0.5
    nameLbl.Parent = billboard

    nicknameBillboard = billboard
end

addToggle(settingsPage, "nickname_toggle", false, function(state)
    nicknameEnabled = state
    local char = LocalPlayer.Character
    if char then applyNickname(char) end
    Notify(state and t("nick_on") or t("nick_off"), 2)
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    if nicknameEnabled then
        task.wait(0.5)
        applyNickname(character)
    end
end)

-- 12.4 Language switch
addSection(settingsPage, "language_section")
local langBtn, langLabel = addButton(settingsPage, "language_toggle", nil)
langBtn.MouseButton1Click:Connect(function()
    currentLang = (currentLang == "en") and "th" or "en"
    for _, entry in ipairs(translatable) do
        if entry.custom then
            entry.custom()
        elseif entry.inst then
            entry.inst.Text = t(entry.key)
        end
    end
end)

--=====================================================================
-- [13] FLOATING LOGO BUTTON (แสดงตอนย่อ)
--=====================================================================
local floatGui = Instance.new("ScreenGui")
floatGui.Name = "SenzyHub_Float"
floatGui.ResetOnSpawn = false
floatGui.DisplayOrder = 10000
floatGui.Parent = playerGui

local floatSize = isMobile and 58 or 50
local floatBtn = Instance.new("ImageButton")
floatBtn.Name = "LogoButton"
floatBtn.Size = UDim2.fromOffset(floatSize, floatSize)
floatBtn.Position = UDim2.new(0, 15, 0.5, -floatSize / 2)
floatBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
floatBtn.BorderSizePixel = 0
floatBtn.Visible = false
floatBtn.Parent = floatGui

if getcustomasset and isfile and isfile(LOGO_IMAGE_NAME) then
    floatBtn.Image = getcustomasset(LOGO_IMAGE_NAME)
elseif LOGO_URL ~= "" then
    floatBtn.Image = LOGO_URL
end

corner(floatBtn, floatSize / 2)
strokeOn(floatBtn, 2, 0.1)

-- พื้นที่แตะขยายรอบปุ่มลอย ช่วยลากง่ายขึ้นบนมือถือ
local floatHitArea = Instance.new("TextButton")
floatHitArea.Size = UDim2.new(1, 20, 1, 20)
floatHitArea.Position = UDim2.new(0, -10, 0, -10)
floatHitArea.BackgroundTransparency = 1
floatHitArea.Text = ""
floatHitArea.AutoButtonColor = false
floatHitArea.ZIndex = 5
floatHitArea.Parent = floatBtn

--=====================================================================
-- [14] OPEN / CLOSE / MINIMIZE LOGIC + KEYBIND HOOK
--=====================================================================
local function setMinimized(minimized)
    if minimized then
        main.Visible = false
        floatBtn.Visible = true
        floatBtn.Size = UDim2.fromOffset(0, 0)
        tween(floatBtn, { Size = UDim2.fromOffset(floatSize, floatSize) }, 0.22, Enum.EasingStyle.Back):Play()
    else
        main.Visible = true
        floatBtn.Visible = false
    end
end

minimizeBtn.MouseButton1Click:Connect(function() setMinimized(true) end)
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    floatGui:Destroy()
end)

-- ผูก drag + click (แก้บั๊กเดิม) — onClick จะยิงก็ต่อเมื่อ "ไม่ได้ลาก" เท่านั้น และใช้ state ของตัวเองล้วนๆ
bindDrag(floatHitArea, floatBtn, function()
    setMinimized(false)
end)

-- Keybind toggle เปิด/ปิดหน้าต่างหลัก
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == currentKeybind then
        setMinimized(main.Visible)
    end
end)

if camera then
    camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        local vp = camera.ViewportSize
        if vp.X < 700 then
            uiScale.Scale = math.clamp(uiScale.Scale, 0.7, 0.95)
        end
    end)
end

--=====================================================================
-- [15] ENTRY POINT LOG
--=====================================================================
print("[SenzyHub] Loaded v4 successfully ✧ (mobile=" .. tostring(isMobile) .. ")")
