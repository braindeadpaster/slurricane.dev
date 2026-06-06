-- ============================
-- SlurricaneUI — Custom Roblox UI Library
-- Blue/dark theme, CoreGui, dual-panel layout
-- ============================

local SlurricaneUI = {}
SlurricaneUI.__index = SlurricaneUI

-- Services
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local CoreGui          = game:GetService("CoreGui")
local LP               = Players.LocalPlayer

-- Constants
local COLORS = {
    BG          = Color3.fromRGB(8,  16,  32),
    SIDEBAR     = Color3.fromRGB(6,  12,  24),
    PANEL       = Color3.fromRGB(11, 22,  44),
    PANEL_RIGHT = Color3.fromRGB(9,  18,  36),
    TOPBAR      = Color3.fromRGB(7,  14,  28),
    ACCENT      = Color3.fromRGB(58, 120, 255),
    ACCENT2     = Color3.fromRGB(30, 80,  200),
    TEXT        = Color3.fromRGB(220,235,255),
    TEXT_DIM    = Color3.fromRGB(120,150,200),
    TEXT_MUTED  = Color3.fromRGB(70, 100, 150),
    TOGGLE_ON   = Color3.fromRGB(58, 120, 255),
    TOGGLE_OFF  = Color3.fromRGB(30, 45,  75),
    SLIDER_BG   = Color3.fromRGB(20, 35,  65),
    SLIDER_FILL = Color3.fromRGB(58, 120, 255),
    INPUT_BG    = Color3.fromRGB(14, 26,  52),
    DIVIDER     = Color3.fromRGB(20, 40,  80),
    HOVER       = Color3.fromRGB(20, 40,  85),
    BORDER      = Color3.fromRGB(25, 50,  100),
    BUTTON_BG   = Color3.fromRGB(20, 42,  90),
    BUTTON_HV   = Color3.fromRGB(35, 65,  130),
}

local FONT       = Enum.Font.GothamBold
local FONT_REG   = Enum.Font.Gotham
local WIN_W      = 620
local WIN_H      = 420
local SIDEBAR_W  = 46
local TOPBAR_H   = 36
local PANEL_W    = 260
local ELEM_H     = 32
local PAD        = 10
local CORNER     = 6

-- Utility
local function tween(obj, props, t, style, dir)
    style = style or Enum.EasingStyle.Quad
    dir   = dir   or Enum.EasingDirection.Out
    TweenService:Create(obj, TweenInfo.new(t or 0.15, style, dir), props):Play()
end

local function corner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or CORNER)
    c.Parent = parent
    return c
end

local function pad(parent, t, b, l, r)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, t or PAD)
    p.PaddingBottom = UDim.new(0, b or PAD)
    p.PaddingLeft   = UDim.new(0, l or PAD)
    p.PaddingRight  = UDim.new(0, r or PAD)
    p.Parent = parent
    return p
end

local function stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color        = color or COLORS.BORDER
    s.Thickness    = thickness or 1
    s.Transparency = transparency or 0.5
    s.Parent = parent
    return s
end

local function label(parent, text, size, color, font, xa, ya)
    local l = Instance.new("TextLabel")
    l.Text               = text or ""
    l.TextSize           = size or 13
    l.TextColor3         = color or COLORS.TEXT
    l.Font               = font or FONT_REG
    l.TextXAlignment     = xa or Enum.TextXAlignment.Left
    l.TextYAlignment     = ya or Enum.TextYAlignment.Center
    l.BackgroundTransparency = 1
    l.Size               = UDim2.new(1, 0, 0, 20)
    l.Parent             = parent
    return l
end

local function frame(parent, bg, size, pos)
    local f = Instance.new("Frame")
    f.BackgroundColor3   = bg or Color3.new(0,0,0)
    f.BackgroundTransparency = bg and 0 or 1
    f.Size               = size or UDim2.new(1,0,1,0)
    f.Position           = pos or UDim2.new(0,0,0,0)
    f.BorderSizePixel    = 0
    f.ClipsDescendants   = false
    f.Parent             = parent
    return f
end

local function btn(parent, bg)
    local b = Instance.new("TextButton")
    b.BackgroundColor3   = bg or Color3.new(0,0,0)
    b.BackgroundTransparency = bg and 0 or 1
    b.BorderSizePixel    = 0
    b.Text               = ""
    b.Size               = UDim2.new(1,0,1,0)
    b.Parent             = parent
    return b
end

-- ============================
-- WINDOW
-- ============================

function SlurricaneUI:CreateWindow(options)
    options = options or {}
    local title   = options.Title   or "slurricane.dev"
    local subtitle = options.Subtitle or "v1.0.0"
    local toggleKey = options.ToggleKey or Enum.KeyCode.RightShift

    -- Destroy existing
    local existing = CoreGui:FindFirstChild("SlurricaneUI")
    if existing then existing:Destroy() end

    -- Root ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name              = "SlurricaneUI"
    gui.ResetOnSpawn      = false
    gui.ZIndexBehavior    = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder      = 999
    gui.Parent            = CoreGui

    -- Main window frame
    local win = frame(gui, COLORS.BG, UDim2.fromOffset(WIN_W, WIN_H))
    win.Position          = UDim2.fromScale(0.5, 0.5)
    win.AnchorPoint       = Vector2.new(0.5, 0.5)
    win.ClipsDescendants  = true
    corner(win, 10)
    stroke(win, COLORS.BORDER, 1, 0.3)

    -- Drop shadow
    local shadow = frame(gui, Color3.new(0,0,0), UDim2.fromOffset(WIN_W+20, WIN_H+20))
    shadow.Position    = UDim2.new(0.5,0,0.5,0)
    shadow.AnchorPoint = Vector2.new(0.5,0.5)
    shadow.ZIndex      = 0
    shadow.BackgroundTransparency = 0.6
    corner(shadow, 14)
    shadow.ZIndex = win.ZIndex - 1

    -- ============================
    -- SIDEBAR
    -- ============================
    local sidebar = frame(win, COLORS.SIDEBAR, UDim2.fromOffset(SIDEBAR_W, WIN_H))
    sidebar.ZIndex = 2
    stroke(sidebar, COLORS.BORDER, 1, 0.6)

    -- Logo area at top of sidebar
    local logoFrame = frame(sidebar, nil, UDim2.fromOffset(SIDEBAR_W, 44))
    local logoBtn = btn(logoFrame, nil)
    local logoLabel = Instance.new("TextLabel")
    logoLabel.Text = "S"
    logoLabel.Font = FONT
    logoLabel.TextSize = 18
    logoLabel.TextColor3 = COLORS.ACCENT
    logoLabel.BackgroundTransparency = 1
    logoLabel.Size = UDim2.new(1,0,1,0)
    logoLabel.TextXAlignment = Enum.TextXAlignment.Center
    logoLabel.Parent = logoBtn

    -- Sidebar icon list
    local sidebarList = frame(sidebar, nil, UDim2.new(1,0,1,-44), UDim2.fromOffset(0,44))
    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.FillDirection = Enum.FillDirection.Vertical
    sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sidebarLayout.Padding = UDim.new(0,4)
    sidebarLayout.Parent = sidebarList

    -- Settings cog at bottom of sidebar
    local settingsFrame = frame(sidebar, nil, UDim2.fromOffset(SIDEBAR_W, 36))
    settingsFrame.Position = UDim2.new(0,0,1,-36)
    settingsFrame.AnchorPoint = Vector2.new(0,1)
    local settingsLabel = Instance.new("TextLabel")
    settingsLabel.Text = "⚙"
    settingsLabel.Font = FONT
    settingsLabel.TextSize = 14
    settingsLabel.TextColor3 = COLORS.TEXT_MUTED
    settingsLabel.BackgroundTransparency = 1
    settingsLabel.Size = UDim2.new(1,0,1,0)
    settingsLabel.TextXAlignment = Enum.TextXAlignment.Center
    settingsLabel.Parent = settingsFrame

    -- ============================
    -- MAIN AREA (right of sidebar)
    -- ============================
    local mainArea = frame(win, nil, UDim2.new(1,-SIDEBAR_W,1,0), UDim2.fromOffset(SIDEBAR_W,0))

    -- TOPBAR
    local topbar = frame(mainArea, COLORS.TOPBAR, UDim2.new(1,0,0,TOPBAR_H))
    stroke(topbar, COLORS.BORDER, 1, 0.6)

    -- Tab breadcrumbs container
    local tabCrumbs = frame(topbar, nil, UDim2.new(1,-40,1,0))
    local crumbLayout = Instance.new("UIListLayout")
    crumbLayout.FillDirection = Enum.FillDirection.Horizontal
    crumbLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    crumbLayout.Padding = UDim.new(0,4)
    crumbLayout.Parent = tabCrumbs
    pad(tabCrumbs, 0, 0, 10, 0)

    -- Accent line under topbar
    local accentLine = frame(topbar, COLORS.ACCENT, UDim2.new(0,60,0,2), UDim2.new(0,10,1,-2))

    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.fromOffset(28,28)
    closeBtn.Position = UDim2.new(1,-34,0,4)
    closeBtn.BackgroundColor3 = COLORS.HOVER
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = COLORS.TEXT_DIM
    closeBtn.Font = FONT
    closeBtn.TextSize = 12
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = topbar
    corner(closeBtn, 5)

    closeBtn.MouseEnter:Connect(function()
        tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(180,50,50)}, 0.1)
        tween(closeBtn, {TextColor3 = Color3.fromRGB(255,255,255)}, 0.1)
    end)
    closeBtn.MouseLeave:Connect(function()
        tween(closeBtn, {BackgroundColor3 = COLORS.HOVER}, 0.1)
        tween(closeBtn, {TextColor3 = COLORS.TEXT_DIM}, 0.1)
    end)
    closeBtn.MouseButton1Click:Connect(function()
        gui.Enabled = false
    end)

    -- Content area below topbar
    local contentArea = frame(mainArea, nil, UDim2.new(1,0,1,-TOPBAR_H), UDim2.fromOffset(0,TOPBAR_H))

    -- LEFT PANEL (controls)
    local leftPanel = frame(contentArea, COLORS.PANEL, UDim2.fromOffset(PANEL_W, 0))
    leftPanel.ClipsDescendants = true

    local leftScroll = Instance.new("ScrollingFrame")
    leftScroll.Size = UDim2.new(1,0,1,0)
    leftScroll.BackgroundTransparency = 1
    leftScroll.BorderSizePixel = 0
    leftScroll.ScrollBarThickness = 3
    leftScroll.ScrollBarImageColor3 = COLORS.ACCENT
    leftScroll.ScrollBarImageTransparency = 0.4
    leftScroll.CanvasSize = UDim2.new(0,0,0,0)
    leftScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    leftScroll.Parent = leftPanel

    local leftList = Instance.new("UIListLayout")
    leftList.FillDirection = Enum.FillDirection.Vertical
    leftList.Padding = UDim.new(0,0)
    leftList.Parent = leftScroll

    -- RIGHT PANEL (description)
    local rightPanel = frame(contentArea, COLORS.PANEL_RIGHT, UDim2.new(1,-PANEL_W,1,0), UDim2.fromOffset(PANEL_W,0))
    stroke(rightPanel, COLORS.BORDER, 1, 0.7)

    local rightPad = frame(rightPanel, nil)
    pad(rightPad, 16, 16, 14, 14)

    local rightTitle = Instance.new("TextLabel")
    rightTitle.Text = title
    rightTitle.Font = FONT
    rightTitle.TextSize = 15
    rightTitle.TextColor3 = COLORS.TEXT
    rightTitle.BackgroundTransparency = 1
    rightTitle.Size = UDim2.new(1,0,0,22)
    rightTitle.TextXAlignment = Enum.TextXAlignment.Left
    rightTitle.Parent = rightPad

    local rightSub = Instance.new("TextLabel")
    rightSub.Text = subtitle
    rightSub.Font = FONT_REG
    rightSub.TextSize = 11
    rightSub.TextColor3 = COLORS.TEXT_MUTED
    rightSub.BackgroundTransparency = 1
    rightSub.Size = UDim2.new(1,0,0,16)
    rightSub.Position = UDim2.fromOffset(0,24)
    rightSub.TextXAlignment = Enum.TextXAlignment.Left
    rightSub.Parent = rightPad

    local rightDivider = frame(rightPad, COLORS.DIVIDER, UDim2.new(1,0,0,1), UDim2.fromOffset(0,46))

    local rightDesc = Instance.new("TextLabel")
    rightDesc.Text = "Hover over an element to see its description."
    rightDesc.Font = FONT_REG
    rightDesc.TextSize = 12
    rightDesc.TextColor3 = COLORS.TEXT_MUTED
    rightDesc.BackgroundTransparency = 1
    rightDesc.Size = UDim2.new(1,0,0,200)
    rightDesc.Position = UDim2.fromOffset(0,56)
    rightDesc.TextXAlignment = Enum.TextXAlignment.Left
    rightDesc.TextYAlignment = Enum.TextYAlignment.Top
    rightDesc.TextWrapped = true
    rightDesc.Parent = rightPad

    local function setRightDesc(name, desc)
        rightTitle.Text = name or title
        rightDesc.Text  = desc or "Hover over an element to see its description."
    end

    -- ============================
    -- DRAG
    -- ============================
    local dragging, dragStart, startPos = false, nil, nil
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = input.Position
            startPos  = win.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            win.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
            shadow.Position = win.Position
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- ============================
    -- TOGGLE KEYBIND
    -- ============================
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == toggleKey then
            gui.Enabled = not gui.Enabled
        end
    end)

    -- ============================
    -- WINDOW OBJECT
    -- ============================
    local Window = {}
    Window._gui         = gui
    Window._win         = win
    Window._sidebar     = sidebar
    Window._sidebarList = sidebarList
    Window._crumbs      = tabCrumbs
    Window._accentLine  = accentLine
    Window._leftScroll  = leftScroll
    Window._leftList    = leftList
    Window._rightPanel  = rightPanel
    Window._setDesc     = setRightDesc
    Window._tabs        = {}
    Window._activeTab   = nil

    -- ============================
    -- TAB
    -- ============================
    function Window:Tab(options)
        options = options or {}
        local tabName = options.Title or "Tab"
        local tabIcon = options.Icon or "◆"

        -- Sidebar icon button
        local iconHolder = frame(self._sidebarList, nil, UDim2.fromOffset(36, 36))
        local iconBtn = btn(iconHolder, COLORS.TOGGLE_OFF)
        iconBtn.Size = UDim2.new(1,0,1,0)
        corner(iconBtn, 7)

        local iconLabel = Instance.new("TextLabel")
        iconLabel.Text = tabIcon
        iconLabel.Font = FONT
        iconLabel.TextSize = 13
        iconLabel.TextColor3 = COLORS.TEXT_MUTED
        iconLabel.BackgroundTransparency = 1
        iconLabel.Size = UDim2.new(1,0,1,0)
        iconLabel.TextXAlignment = Enum.TextXAlignment.Center
        iconLabel.Parent = iconBtn

        -- Topbar crumb button
        local crumb = Instance.new("TextButton")
        crumb.Text = tabName
        crumb.Font = FONT
        crumb.TextSize = 13
        crumb.TextColor3 = COLORS.TEXT_MUTED
        crumb.BackgroundTransparency = 1
        crumb.BorderSizePixel = 0
        crumb.AutomaticSize = Enum.AutomaticSize.X
        crumb.Size = UDim2.fromOffset(0, TOPBAR_H)
        crumb.Parent = self._crumbs

        -- Content container in left panel
        local content = frame(self._leftScroll, nil)
        content.Visible = false
        content.AutomaticSize = Enum.AutomaticSize.Y
        content.Size = UDim2.new(1,0,0,0)

        local contentList = Instance.new("UIListLayout")
        contentList.FillDirection = Enum.FillDirection.Vertical
        contentList.Padding = UDim.new(0,0)
        contentList.Parent = content

        local Tab = {}
        Tab._window  = self
        Tab._content = content
        Tab._name    = tabName

        local function activate()
            -- Deactivate all tabs
            for _, t in ipairs(Window._tabs) do
                t._content.Visible = false
                tween(t._iconBtn, {BackgroundColor3 = COLORS.TOGGLE_OFF}, 0.15)
                tween(t._iconLabel, {TextColor3 = COLORS.TEXT_MUTED}, 0.15)
                tween(t._crumb, {TextColor3 = COLORS.TEXT_MUTED}, 0.15)
            end
            -- Activate this tab
            content.Visible = true
            tween(iconBtn, {BackgroundColor3 = COLORS.ACCENT2}, 0.15)
            tween(iconLabel, {TextColor3 = COLORS.TEXT}, 0.15)
            tween(crumb, {TextColor3 = COLORS.TEXT}, 0.15)
            Window._activeTab = Tab
            -- Move accent line
            local pos = crumb.AbsolutePosition.X - tabCrumbs.AbsolutePosition.X
            tween(Window._accentLine, {
                Size = UDim2.new(0, crumb.AbsoluteSize.X, 0, 2),
                Position = UDim2.new(0, pos - 10, 1, -2)
            }, 0.2)
        end

        Tab._iconBtn   = iconBtn
        Tab._iconLabel = iconLabel
        Tab._crumb     = crumb

        iconBtn.MouseButton1Click:Connect(activate)
        crumb.MouseButton1Click:Connect(activate)

        iconBtn.MouseEnter:Connect(function()
            if Window._activeTab ~= Tab then
                tween(iconBtn, {BackgroundColor3 = COLORS.HOVER}, 0.1)
                tween(iconLabel, {TextColor3 = COLORS.TEXT_DIM}, 0.1)
            end
        end)
        iconBtn.MouseLeave:Connect(function()
            if Window._activeTab ~= Tab then
                tween(iconBtn, {BackgroundColor3 = COLORS.TOGGLE_OFF}, 0.1)
                tween(iconLabel, {TextColor3 = COLORS.TEXT_MUTED}, 0.1)
            end
        end)

        table.insert(self._tabs, Tab)

        -- Auto-select first tab
        if #self._tabs == 1 then activate() end

        -- ============================
        -- SECTION
        -- ============================
        function Tab:Section(options)
            options = options or {}
            local sectionTitle = options.Title or "Section"

            local sectionHolder = frame(self._content, nil)
            sectionHolder.AutomaticSize = Enum.AutomaticSize.Y
            sectionHolder.Size = UDim2.new(1,0,0,0)

            -- Section header
            local header = frame(sectionHolder, COLORS.SIDEBAR, UDim2.new(1,0,0,28))
            pad(header, 0, 0, 12, 8)
            local headerLabel = label(header, sectionTitle:upper(), 10, COLORS.TEXT_MUTED, FONT)
            headerLabel.Size = UDim2.new(1,0,1,0)
            headerLabel.TextXAlignment = Enum.TextXAlignment.Left
            stroke(header, COLORS.BORDER, 1, 0.7)

            -- Items list
            local items = frame(sectionHolder, nil, UDim2.new(1,0,0,0), UDim2.fromOffset(0,28))
            items.AutomaticSize = Enum.AutomaticSize.Y

            local itemsList = Instance.new("UIListLayout")
            itemsList.FillDirection = Enum.FillDirection.Vertical
            itemsList.Padding = UDim.new(0,0)
            itemsList.Parent = items

            local Section = {}
            Section._items   = items
            Section._window  = self._window

            local function makeRow(desc)
                local row = frame(items, nil, UDim2.new(1,0,0,ELEM_H))
                row.ClipsDescendants = false

                row.MouseEnter:Connect(function()
                    tween(row, {BackgroundColor3 = COLORS.HOVER}, 0.1)
                    row.BackgroundTransparency = 0
                    if desc and desc ~= "" then
                        self._window._setDesc(sectionTitle, desc)
                    end
                end)
                row.MouseLeave:Connect(function()
                    tween(row, {BackgroundColor3 = COLORS.HOVER}, 0.05)
                    row.BackgroundTransparency = 1
                end)

                local divLine = frame(row, COLORS.DIVIDER, UDim2.new(1,-24,0,1), UDim2.new(0,12,1,-1))
                divLine.BackgroundTransparency = 0.6

                return row
            end

            -- ============================
            -- TOGGLE
            -- ============================
            function Section:Toggle(options)
                options = options or {}
                local title   = options.Title    or "Toggle"
                local desc    = options.Desc     or ""
                local default = options.Default  or false
                local cb      = options.Callback or function() end

                local row = makeRow(desc)
                pad(row, 0, 0, 12, 12)

                local rowLabel = label(row, title, 13, COLORS.TEXT, FONT_REG)
                rowLabel.Size = UDim2.new(1,-52,1,0)

                -- Toggle pill
                local pillHolder = frame(row, nil, UDim2.fromOffset(42,22), UDim2.new(1,-46,0.5,-11))
                local pill = frame(pillHolder, default and COLORS.TOGGLE_ON or COLORS.TOGGLE_OFF, UDim2.new(1,0,1,0))
                corner(pill, 11)
                stroke(pill, COLORS.BORDER, 1, 0.5)

                local knob = frame(pill, COLORS.TEXT, UDim2.fromOffset(16,16), UDim2.new(default and 1 or 0, default and -18 or 2, 0.5,-8))
                corner(knob, 8)

                local state = default
                local clickBtn = btn(row, nil)
                clickBtn.Size = UDim2.new(1,0,1,0)
                clickBtn.ZIndex = 5

                local function setState(s)
                    state = s
                    tween(pill,  {BackgroundColor3 = s and COLORS.TOGGLE_ON or COLORS.TOGGLE_OFF}, 0.15)
                    tween(knob,  {Position = s and UDim2.new(1,0,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)}, 0.15)
                    cb(s)
                end

                -- Fix knob position immediately for default
                knob.Position = default and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)

                clickBtn.MouseButton1Click:Connect(function()
                    setState(not state)
                end)

                local Toggle = {}
                function Toggle:Set(s) setState(s) end
                function Toggle:Get() return state end
                return Toggle
            end

            -- ============================
            -- SLIDER
            -- ============================
            function Section:Slider(options)
                options = options or {}
                local title   = options.Title    or "Slider"
                local desc    = options.Desc     or ""
                local min     = options.Min      or 0
                local max     = options.Max      or 100
                local default = options.Default  or min
                local step    = options.Step     or 1
                local cb      = options.Callback or function() end

                local row = makeRow(desc)
                row.Size = UDim2.new(1,0,0,ELEM_H + 18)
                pad(row, 6, 6, 12, 12)

                local topRow = frame(row, nil, UDim2.new(1,0,0,18))
                local rowLabel = label(topRow, title, 13, COLORS.TEXT, FONT_REG)
                rowLabel.Size = UDim2.new(1,-40,1,0)

                local valLabel = label(topRow, tostring(default), 12, COLORS.ACCENT, FONT)
                valLabel.Size = UDim2.fromOffset(38,18)
                valLabel.Position = UDim2.new(1,-38,0,0)
                valLabel.TextXAlignment = Enum.TextXAlignment.Right

                -- Track
                local trackHolder = frame(row, nil, UDim2.new(1,0,0,14), UDim2.fromOffset(0,20))
                local track = frame(trackHolder, COLORS.SLIDER_BG, UDim2.new(1,0,0,4), UDim2.new(0,0,0.5,-2))
                corner(track, 2)

                local fill = frame(track, COLORS.SLIDER_FILL, UDim2.new(0,0,1,0))
                corner(fill, 2)

                local handle = frame(trackHolder, COLORS.TEXT, UDim2.fromOffset(12,12), UDim2.new(0,-6,0.5,-6))
                corner(handle, 6)
                stroke(handle, COLORS.ACCENT, 1, 0)

                local value = default
                local function snap(v)
                    if step > 0 then
                        v = math.round(v / step) * step
                    end
                    return math.clamp(v, min, max)
                end

                local function setValue(v)
                    value = snap(v)
                    local pct = (value - min) / (max - min)
                    tween(fill,   {Size = UDim2.new(pct, 0, 1, 0)}, 0.05)
                    tween(handle, {Position = UDim2.new(pct, -6, 0.5, -6)}, 0.05)
                    local display = (step < 1) and string.format("%.2f", value) or tostring(math.floor(value))
                    valLabel.Text = display
                    cb(value)
                end

                setValue(default)

                local sliding = false
                local trackBtn = btn(trackHolder, nil)
                trackBtn.Size = UDim2.new(1,0,1,0)
                trackBtn.ZIndex = 5

                local function updateFromMouse()
                    local rel = UserInputService:GetMouseLocation().X - track.AbsolutePosition.X
                    local pct = math.clamp(rel / track.AbsoluteSize.X, 0, 1)
                    setValue(min + (max - min) * pct)
                end

                trackBtn.MouseButton1Down:Connect(function()
                    sliding = true
                    updateFromMouse()
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateFromMouse()
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliding = false
                    end
                end)

                local Slider = {}
                function Slider:Set(v) setValue(v) end
                function Slider:Get() return value end
                return Slider
            end

            -- ============================
            -- DROPDOWN
            -- ============================
            function Section:Dropdown(options)
                options = options or {}
                local title   = options.Title    or "Dropdown"
                local desc    = options.Desc     or ""
                local values  = options.Values   or {}
                local default = options.Default  or values[1]
                local cb      = options.Callback or function() end

                local row = makeRow(desc)
                pad(row, 0, 0, 12, 12)

                local rowLabel = label(row, title, 13, COLORS.TEXT, FONT_REG)
                rowLabel.Size = UDim2.new(0.45,0,1,0)

                -- Selected display
                local selHolder = frame(row, COLORS.INPUT_BG, UDim2.new(0.5,-4,0,24), UDim2.new(0.5,0,0.5,-12))
                corner(selHolder, 5)
                stroke(selHolder, COLORS.BORDER, 1, 0.4)
                pad(selHolder, 0, 0, 8, 24)

                local selLabel = label(selHolder, default or "Select...", 12, COLORS.TEXT, FONT_REG)
                selLabel.Size = UDim2.new(1,0,1,0)

                local arrow = label(selHolder, "▾", 12, COLORS.TEXT_MUTED, FONT)
                arrow.Size = UDim2.fromOffset(20,24)
                arrow.Position = UDim2.new(1,-20,0,0)
                arrow.TextXAlignment = Enum.TextXAlignment.Center

                local selected = default
                local open = false
                local dropFrame

                local clickBtn = btn(row, nil)
                clickBtn.Size = UDim2.new(1,0,1,0)
                clickBtn.ZIndex = 5

                clickBtn.MouseButton1Click:Connect(function()
                    open = not open
                    if open then
                        dropFrame = frame(gui, COLORS.PANEL, UDim2.fromOffset(selHolder.AbsoluteSize.X, #values * 28 + 4))
                        dropFrame.Position = UDim2.fromOffset(
                            selHolder.AbsolutePosition.X,
                            selHolder.AbsolutePosition.Y + selHolder.AbsoluteSize.Y + 2
                        )
                        dropFrame.ZIndex = 20
                        corner(dropFrame, 6)
                        stroke(dropFrame, COLORS.BORDER, 1, 0.3)

                        local dList = Instance.new("UIListLayout")
                        dList.Padding = UDim.new(0,0)
                        dList.Parent = dropFrame

                        for _, v in ipairs(values) do
                            local item = Instance.new("TextButton")
                            item.Size = UDim2.new(1,0,0,28)
                            item.BackgroundTransparency = 1
                            item.Text = v
                            item.Font = FONT_REG
                            item.TextSize = 12
                            item.TextColor3 = v == selected and COLORS.ACCENT or COLORS.TEXT
                            item.TextXAlignment = Enum.TextXAlignment.Left
                            item.BorderSizePixel = 0
                            item.ZIndex = 21
                            pad(item, 0, 0, 10, 8)
                            item.Parent = dropFrame

                            item.MouseEnter:Connect(function()
                                tween(item, {BackgroundTransparency = 0}, 0.1)
                                item.BackgroundColor3 = COLORS.HOVER
                            end)
                            item.MouseLeave:Connect(function()
                                tween(item, {BackgroundTransparency = 1}, 0.1)
                            end)
                            item.MouseButton1Click:Connect(function()
                                selected = v
                                selLabel.Text = v
                                cb(v)
                                open = false
                                if dropFrame then dropFrame:Destroy() dropFrame = nil end
                            end)
                        end
                    else
                        if dropFrame then dropFrame:Destroy() dropFrame = nil end
                    end
                end)

                local Dropdown = {}
                function Dropdown:Set(v)
                    selected = v
                    selLabel.Text = v
                    cb(v)
                end
                function Dropdown:Get() return selected end
                function Dropdown:SetValues(v)
                    values = v
                end
                return Dropdown
            end

            -- ============================
            -- BUTTON
            -- ============================
            function Section:Button(options)
                options = options or {}
                local title   = options.Title    or "Button"
                local desc    = options.Desc     or ""
                local cb      = options.Callback or function() end

                local row = makeRow(desc)
                pad(row, 0, 0, 12, 12)

                local btnFrame = frame(row, COLORS.BUTTON_BG, UDim2.new(1,0,0,26), UDim2.new(0,0,0.5,-13))
                corner(btnFrame, 6)
                stroke(btnFrame, COLORS.BORDER, 1, 0.4)

                local btnLabel = label(btnFrame, title, 12, COLORS.TEXT, FONT)
                btnLabel.Size = UDim2.new(1,0,1,0)
                btnLabel.TextXAlignment = Enum.TextXAlignment.Center

                local clickBtn = btn(row, nil)
                clickBtn.Size = UDim2.new(1,0,1,0)
                clickBtn.ZIndex = 5

                clickBtn.MouseEnter:Connect(function()
                    tween(btnFrame, {BackgroundColor3 = COLORS.BUTTON_HV}, 0.1)
                end)
                clickBtn.MouseLeave:Connect(function()
                    tween(btnFrame, {BackgroundColor3 = COLORS.BUTTON_BG}, 0.1)
                end)
                clickBtn.MouseButton1Click:Connect(function()
                    tween(btnFrame, {BackgroundColor3 = COLORS.ACCENT}, 0.05)
                    task.delay(0.1, function()
                        tween(btnFrame, {BackgroundColor3 = COLORS.BUTTON_BG}, 0.15)
                    end)
                    cb()
                end)
            end

            -- ============================
            -- INPUT
            -- ============================
            function Section:Input(options)
                options = options or {}
                local title       = options.Title       or "Input"
                local desc        = options.Desc        or ""
                local placeholder = options.Placeholder or "Type here..."
                local default     = options.Default     or ""
                local cb          = options.Callback    or function() end

                local row = makeRow(desc)
                row.Size = UDim2.new(1,0,0,ELEM_H + 18)
                pad(row, 6, 6, 12, 12)

                local topRow = frame(row, nil, UDim2.new(1,0,0,18))
                local rowLabel = label(topRow, title, 13, COLORS.TEXT, FONT_REG)
                rowLabel.Size = UDim2.new(1,0,1,0)

                local inputFrame = frame(row, COLORS.INPUT_BG, UDim2.new(1,0,0,24), UDim2.fromOffset(0,20))
                corner(inputFrame, 5)
                stroke(inputFrame, COLORS.BORDER, 1, 0.4)
                pad(inputFrame, 0, 0, 8, 8)

                local inputBox = Instance.new("TextBox")
                inputBox.Size = UDim2.new(1,0,1,0)
                inputBox.BackgroundTransparency = 1
                inputBox.Text = default
                inputBox.PlaceholderText = placeholder
                inputBox.PlaceholderColor3 = COLORS.TEXT_MUTED
                inputBox.TextColor3 = COLORS.TEXT
                inputBox.Font = FONT_REG
                inputBox.TextSize = 12
                inputBox.TextXAlignment = Enum.TextXAlignment.Left
                inputBox.BorderSizePixel = 0
                inputBox.ClearTextOnFocus = false
                inputBox.Parent = inputFrame

                inputBox.FocusLost:Connect(function()
                    cb(inputBox.Text)
                end)

                inputFrame.MouseEnter:Connect(function()
                    tween(inputFrame, {BackgroundColor3 = COLORS.HOVER}, 0.1)
                end)
                inputFrame.MouseLeave:Connect(function()
                    tween(inputFrame, {BackgroundColor3 = COLORS.INPUT_BG}, 0.1)
                end)

                local Input = {}
                function Input:Set(v) inputBox.Text = v cb(v) end
                function Input:Get() return inputBox.Text end
                return Input
            end

            -- ============================
            -- LABEL
            -- ============================
            function Section:Label(options)
                options = options or {}
                local text  = options.Title or options.Text or ""
                local desc  = options.Desc  or ""
                local color = options.Color or COLORS.TEXT_DIM

                local row = makeRow(desc)
                pad(row, 0, 0, 12, 12)

                local rowLabel = label(row, text, 12, color, FONT_REG)
                rowLabel.Size = UDim2.new(1,0,1,0)
                rowLabel.TextWrapped = true

                local Lbl = {}
                function Lbl:Set(t) rowLabel.Text = t end
                return Lbl
            end

            -- ============================
            -- DIVIDER
            -- ============================
            function Section:Divider(options)
                options = options or {}
                local text = options.Title or options.Text or ""

                local row = frame(self._items, nil, UDim2.new(1,0,0,24))
                pad(row, 0, 0, 12, 12)

                local line1 = frame(row, COLORS.DIVIDER, UDim2.new(0.3,0,0,1), UDim2.new(0,0,0.5,0))
                local line2 = frame(row, COLORS.DIVIDER, UDim2.new(0.3,0,0,1), UDim2.new(0.7,0,0.5,0))
                local divLabel = label(row, text, 10, COLORS.TEXT_MUTED, FONT)
                divLabel.Size = UDim2.new(0.4,0,1,0)
                divLabel.Position = UDim2.new(0.3,0,0,0)
                divLabel.TextXAlignment = Enum.TextXAlignment.Center
            end

            -- ============================
            -- COLORPICKER (simple)
            -- ============================
            function Section:Colorpicker(options)
                options = options or {}
                local title   = options.Title    or "Color"
                local desc    = options.Desc     or ""
                local default = options.Default  or Color3.fromRGB(255,255,255)
                local cb      = options.Callback or function() end

                local row = makeRow(desc)
                pad(row, 0, 0, 12, 12)

                local rowLabel = label(row, title, 13, COLORS.TEXT, FONT_REG)
                rowLabel.Size = UDim2.new(1,-36,1,0)

                local swatch = frame(row, default, UDim2.fromOffset(24,24), UDim2.new(1,-28,0.5,-12))
                corner(swatch, 5)
                stroke(swatch, COLORS.BORDER, 1, 0.3)

                local color = default
                local CP = {}
                function CP:Set(c)
                    color = c
                    swatch.BackgroundColor3 = c
                    cb(c)
                end
                function CP:Get() return color end
                return CP
            end

            return Section
        end

        return Tab
    end

    -- ============================
    -- NOTIFY (top-right toast)
    -- ============================
    function Window:Notify(options)
        options = options or {}
        local title    = options.Title    or "Notification"
        local content  = options.Content  or ""
        local duration = options.Duration or 3

        local notif = frame(gui, COLORS.PANEL, UDim2.fromOffset(220, 56))
        notif.Position = UDim2.new(1,-230,1,-70)
        notif.AnchorPoint = Vector2.new(0,0)
        notif.ZIndex = 50
        corner(notif, 8)
        stroke(notif, COLORS.ACCENT, 1, 0.5)
        pad(notif, 8, 8, 12, 12)

        local accentBar = frame(notif, COLORS.ACCENT, UDim2.fromOffset(3, 40), UDim2.fromOffset(0,0))
        corner(accentBar, 2)

        local nTitle = label(notif, title, 13, COLORS.TEXT, FONT)
        nTitle.Position = UDim2.fromOffset(12, 0)
        nTitle.Size = UDim2.new(1,-12,0,20)

        local nContent = label(notif, content, 11, COLORS.TEXT_DIM, FONT_REG)
        nContent.Position = UDim2.fromOffset(12, 20)
        nContent.Size = UDim2.new(1,-12,0,16)
        nContent.TextWrapped = true

        -- Slide in
        notif.BackgroundTransparency = 1
        notif.Position = UDim2.new(1,10,1,-70)
        tween(notif, {Position = UDim2.new(1,-230,1,-70), BackgroundTransparency = 0}, 0.3, Enum.EasingStyle.Back)

        task.delay(duration, function()
            tween(notif, {Position = UDim2.new(1,10,1,-70), BackgroundTransparency = 1}, 0.3)
            task.delay(0.35, function() notif:Destroy() end)
        end)
    end

    return Window
end

return SlurricaneUI
