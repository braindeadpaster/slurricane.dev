local windUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local cloneref = (cloneref or clonereference or function(instance) return instance end)

-- Services
local HttpService      = game:GetService("HttpService")
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local Lighting         = game:GetService("Lighting")
local TeleportService  = game:GetService("TeleportService")
local LP               = Players.LocalPlayer
local Mouse            = LP:GetMouse()
local Camera           = workspace.CurrentCamera

-- Configuration
local Configuration = {
    ESP_Highlight   = false,
    ESP_Box         = false,
    ESP_Skeleton    = false,
    ESP_Name        = false,
    ESP_Health      = false,
    ESP_Tracers     = false,
    ESP_Distance    = false,
    ESP_Chams       = false,
    ESP_VisibleOnly = false,
    ESP_MaxDist     = 1000,
    ESP_Color       = Color3.fromRGB(255, 255, 255),
    Crosshair       = false,
    CrosshairStyle  = "Cross",
    CrosshairSize   = 10,
    CrosshairColor  = Color3.fromRGB(255, 255, 255),
    FOVCircle       = false,
    FOVRadius       = 80,
    Fullbright      = false,
    Aimbot          = false,
    AimbotFOV       = 80,
    AimbotSmooth    = 0.3,
    AimbotPart      = "Head",
    ReachExtender   = false,
    ReachValue      = 10,
    Noclip          = false,
    Fly             = false,
    FlySpeed        = 50,
    SpeedHack       = false,
    SpeedValue      = 25,
    AntiAFK         = false,
    AutoRejoin      = false,
    ChatNotify      = false,
    ChatKeyword     = "",
    AutoIdea        = false,
    AutoSpillCleaner = false,
    AutoBankLog     = false,
}

-- ============================
-- WINDOW
-- ============================

local window = windUI:CreateWindow({
    Title = "slurricane.dev",
    Icon = "door-open",
    Author = "cerebrum mortuus est emplastrum",
    Folder = "slurricane",
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = true,
    ScrollBarEnabled = false
})

window:EditOpenButton({
    Title = "Open",
    Icon = "monitor",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromHex("FF0F7B"), Color3.fromHex("F89B29")),
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
    Position = UDim2.new(0.1, 0, 0.6, 0)
})

local function Notify(title, content, icon, duration)
    windUI:Notify({
        Title = title,
        Content = content,
        Duration = duration or 3,
        Icon = icon or "bell",
    })
end

-- ============================
-- TABS
-- ============================

local visualsTab  = window:Tab({Title = "Visuals",  Icon = "lucide:eye"})
local combatTab   = window:Tab({Title = "Combat",   Icon = "lucide:crosshair"})
local movementTab = window:Tab({Title = "Movement", Icon = "lucide:wind"})
local utilityTab  = window:Tab({Title = "Utility",  Icon = "lucide:settings"})
local farmingTab  = window:Tab({Title = "Farming",  Icon = "lucide:cpu"})

visualsTab:Select()

-- ============================
-- SECTIONS
-- ============================

local espSection = visualsTab:Section({
    Title = "esp", Box = true, TextTransparency = 0.05,
    TextXAlignment = "Left", TextSize = 17, Opened = true
})
local screenSection = visualsTab:Section({
    Title = "screen", Box = true, TextTransparency = 0.05,
    TextXAlignment = "Left", TextSize = 17, Opened = true
})
local combatSection = combatTab:Section({
    Title = "combat", Box = true, TextTransparency = 0.05,
    TextXAlignment = "Left", TextSize = 17, Opened = true
})
local movementSection = movementTab:Section({
    Title = "movement", Box = true, TextTransparency = 0.05,
    TextXAlignment = "Left", TextSize = 17, Opened = true
})
local utilitySection = utilityTab:Section({
    Title = "utility", Box = true, TextTransparency = 0.05,
    TextXAlignment = "Left", TextSize = 17, Opened = true
})
local playerSection = utilityTab:Section({
    Title = "player", Box = true, TextTransparency = 0.05,
    TextXAlignment = "Left", TextSize = 17, Opened = true
})
local configSection = utilityTab:Section({
    Title = "config", Box = true, TextTransparency = 0.05,
    TextXAlignment = "Left", TextSize = 17, Opened = true
})
local farmingSection = farmingTab:Section({
    Title = "farming", Box = true, TextTransparency = 0.05,
    TextXAlignment = "Left", TextSize = 17, Opened = true
})
local autoFarmSection = farmingTab:Section({
    Title = "auto farm", Box = true, TextTransparency = 0.05,
    TextXAlignment = "Left", TextSize = 17, Opened = true
})

-- ============================
-- ESP HELPERS
-- ============================

local ESPConnections    = {}
local ESPDrawings       = {}
local playerConnections = {}
local ChamObjects       = {}

local function newText(size, color)
    local t        = Drawing.new("Text")
    t.Visible      = false
    t.Size         = size
    t.Color        = color
    t.Center       = true
    t.Outline      = true
    t.OutlineColor = Color3.fromRGB(0, 0, 0)
    t.Font         = Drawing.Fonts.UI
    return t
end

local function newLine(color, thickness)
    local l     = Drawing.new("Line")
    l.Visible   = false
    l.Color     = color
    l.Thickness = thickness or 1
    return l
end

local function newQuad(color, thickness)
    local q     = Drawing.new("Quad")
    q.Visible   = false
    q.Color     = color
    q.Thickness = thickness or 1.5
    q.Filled    = false
    return q
end

local function newCircle(color, thickness)
    local c     = Drawing.new("Circle")
    c.Visible   = false
    c.Color     = color
    c.Thickness = thickness or 1
    c.Filled    = false
    return c
end

local function healthColor(pct)
    if pct > 0.6 then return Color3.fromRGB(0, 255, 80)
    elseif pct > 0.3 then return Color3.fromRGB(255, 165, 0)
    else return Color3.fromRGB(255, 50, 50) end
end

local BONES = {
    {"Head","UpperTorso"},
    {"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}

local function createESPDrawings(player)
    local boneLines = {}
    for i = 1, #BONES do boneLines[i] = newLine(Configuration.ESP_Color, 1) end
    local d = {
        Name   = newText(14, Color3.fromRGB(255, 255, 255)),
        Health = newText(12, Color3.fromRGB(0, 255, 80)),
        Dist   = newText(11, Color3.fromRGB(200, 200, 200)),
        BarBG  = newLine(Color3.fromRGB(30, 30, 30), 4),
        BarFG  = newLine(Color3.fromRGB(0, 255, 80), 4),
        Box    = newQuad(Configuration.ESP_Color, 1.5),
        Tracer = newLine(Configuration.ESP_Color, 1),
        Bones  = boneLines,
    }
    ESPDrawings[player] = d
    return d
end

local function removeESPDrawings(player)
    local d = ESPDrawings[player]
    if not d then return end
    for k, v in pairs(d) do
        if k == "Bones" then for _, l in ipairs(v) do pcall(function() l:Remove() end) end
        else pcall(function() v:Remove() end) end
    end
    ESPDrawings[player] = nil
end

local function hideDrawings(d)
    d.Name.Visible   = false
    d.Health.Visible = false
    d.Dist.Visible   = false
    d.BarBG.Visible  = false
    d.BarFG.Visible  = false
    d.Box.Visible    = false
    d.Tracer.Visible = false
    for _, l in ipairs(d.Bones) do l.Visible = false end
end

local function anyESPActive()
    return Configuration.ESP_Highlight or Configuration.ESP_Box
        or Configuration.ESP_Skeleton  or Configuration.ESP_Name
        or Configuration.ESP_Health    or Configuration.ESP_Tracers
        or Configuration.ESP_Distance  or Configuration.ESP_Chams
end

local function isVisible(character)
    if not character then return false end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local origin    = Camera.CFrame.Position
    local direction = hrp.Position - origin
    local ray       = Ray.new(origin, direction)
    local hit       = workspace:FindPartOnRayWithIgnoreList(ray, {LP.Character, Camera})
    if not hit then return true end
    return hit:IsDescendantOf(character)
end

-- ============================
-- CHAMS
-- ============================

local function applyChams(player)
    if player == LP then return end
    local char = player.Character
    if not char then return end
    ChamObjects[player] = {}
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            local sel = Instance.new("SelectionBox")
            sel.Adornee             = part
            sel.Color3              = Configuration.ESP_Color
            sel.LineThickness       = 0
            sel.SurfaceColor3       = Configuration.ESP_Color
            sel.SurfaceTransparency = 0.5
            sel.Parent              = game:GetService("CoreGui")
            table.insert(ChamObjects[player], sel)
        end
    end
end

local function removeChams(player)
    if ChamObjects[player] then
        for _, obj in ipairs(ChamObjects[player]) do pcall(function() obj:Destroy() end) end
        ChamObjects[player] = nil
    end
end

local function refreshChams()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LP then continue end
        removeChams(player)
        if Configuration.ESP_Chams then applyChams(player) end
    end
end

-- ============================
-- ESP RENDER LOOP
-- ============================

local function startESPRender(player)
    if ESPConnections[player] then
        ESPConnections[player]:Disconnect()
        ESPConnections[player] = nil
    end

    local drawings = ESPDrawings[player] or createESPDrawings(player)

    ESPConnections[player] = RunService.RenderStepped:Connect(function()
        if not anyESPActive() then hideDrawings(drawings) return end

        local char = player.Character
        if not char then hideDrawings(drawings) return end

        local hrp  = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        local hum  = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not head or not hum or hum.Health <= 0 then
            hideDrawings(drawings) return
        end

        local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        local dist  = myHRP and math.floor((myHRP.Position - hrp.Position).Magnitude) or 0
        if dist > Configuration.ESP_MaxDist then hideDrawings(drawings) return end

        if Configuration.ESP_VisibleOnly and not isVisible(char) then
            hideDrawings(drawings) return
        end

        local headTopWorld   = head.Position + Vector3.new(0, head.Size.Y / 2 + 0.3, 0)
        local feetWorld      = hrp.Position  - Vector3.new(0, 3, 0)
        local sHead, visHead = Camera:WorldToViewportPoint(headTopWorld)
        local sFeet          = Camera:WorldToViewportPoint(feetWorld)
        if not visHead then hideDrawings(drawings) return end

        local hV   = Vector2.new(sHead.X, sHead.Y)
        local fV   = Vector2.new(sFeet.X, sFeet.Y)
        local boxH = math.abs(fV.Y - hV.Y)
        local boxW = boxH * 0.5
        local pct  = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
        local col  = healthColor(pct)
        local eCol = Configuration.ESP_Color
        local vp   = Camera.ViewportSize
        local mid  = Vector2.new(vp.X / 2, vp.Y)

        -- Box
        if Configuration.ESP_Box then
            drawings.Box.Visible = true
            drawings.Box.Color   = eCol
            drawings.Box.PointA  = Vector2.new(hV.X - boxW/2, hV.Y)
            drawings.Box.PointB  = Vector2.new(hV.X + boxW/2, hV.Y)
            drawings.Box.PointC  = Vector2.new(fV.X + boxW/2, fV.Y)
            drawings.Box.PointD  = Vector2.new(fV.X - boxW/2, fV.Y)
        else drawings.Box.Visible = false end

        -- Health bar
        if Configuration.ESP_Health then
            local barX = hV.X + boxW/2 + 5
            drawings.BarBG.Visible   = true
            drawings.BarBG.From      = Vector2.new(barX, hV.Y)
            drawings.BarBG.To        = Vector2.new(barX, fV.Y)
            drawings.BarFG.Visible   = true
            drawings.BarFG.Color     = col
            drawings.BarFG.From      = Vector2.new(barX, fV.Y)
            drawings.BarFG.To        = Vector2.new(barX, fV.Y - (fV.Y - hV.Y) * pct)
            drawings.Health.Visible  = true
            drawings.Health.Color    = col
            drawings.Health.Text     = string.format("%d / %d", math.floor(hum.Health), math.floor(hum.MaxHealth))
            drawings.Health.Position = Vector2.new(hV.X, fV.Y + 4)
        else
            drawings.BarBG.Visible  = false
            drawings.BarFG.Visible  = false
            drawings.Health.Visible = false
        end

        -- Name
        if Configuration.ESP_Name then
            drawings.Name.Visible  = true
            drawings.Name.Text     = player.Name
            drawings.Name.Color    = eCol
            drawings.Name.Position = Vector2.new(hV.X, hV.Y - 18)
        else drawings.Name.Visible = false end

        -- Distance
        if Configuration.ESP_Distance then
            drawings.Dist.Visible  = true
            drawings.Dist.Text     = string.format("[%d]", dist)
            drawings.Dist.Color    = eCol
            local yOff = Configuration.ESP_Name and (hV.Y - 30) or (hV.Y - 18)
            drawings.Dist.Position = Vector2.new(hV.X, yOff)
        else drawings.Dist.Visible = false end

        -- Tracer
        if Configuration.ESP_Tracers then
            drawings.Tracer.Visible = true
            drawings.Tracer.Color   = eCol
            drawings.Tracer.From    = mid
            drawings.Tracer.To      = Vector2.new(fV.X, fV.Y)
        else drawings.Tracer.Visible = false end

        -- Skeleton
        for i, bone in ipairs(BONES) do
            local line = drawings.Bones[i]
            if Configuration.ESP_Skeleton then
                local partA = char:FindFirstChild(bone[1])
                local partB = char:FindFirstChild(bone[2])
                if partA and partB then
                    local sA, visA = Camera:WorldToViewportPoint(partA.Position)
                    local sB, visB = Camera:WorldToViewportPoint(partB.Position)
                    if visA and visB then
                        line.Visible = true
                        line.Color   = eCol
                        line.From    = Vector2.new(sA.X, sA.Y)
                        line.To      = Vector2.new(sB.X, sB.Y)
                    else line.Visible = false end
                else line.Visible = false end
            else line.Visible = false end
        end
    end)
end

-- ============================
-- HIGHLIGHT + PLAYER HOOKS
-- ============================

local function applyHighlight(character)
    local existing = character:FindFirstChild("DebugHighlight")
    if existing then existing:Destroy() end
    local h = Instance.new("Highlight")
    h.Name                = "DebugHighlight"
    h.FillColor           = Configuration.ESP_Color
    h.OutlineColor        = Configuration.ESP_Color
    h.FillTransparency    = 0.5
    h.OutlineTransparency = 0
    h.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent              = character
end

local function removeHighlight(character)
    local h = character:FindFirstChild("DebugHighlight")
    if h then h:Destroy() end
end

local function refreshHighlights()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LP then continue end
        if player.Character then
            if Configuration.ESP_Highlight then applyHighlight(player.Character)
            else removeHighlight(player.Character) end
        end
    end
end

local function updateHighlightColors()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LP then continue end
        if player.Character then
            local h = player.Character:FindFirstChild("DebugHighlight")
            if h then
                h.FillColor    = Configuration.ESP_Color
                h.OutlineColor = Configuration.ESP_Color
            end
        end
    end
end

local function onPlayer(player)
    if player == LP then return end
    if player.Character and Configuration.ESP_Highlight then applyHighlight(player.Character) end
    if Configuration.ESP_Chams and player.Character then applyChams(player) end
    startESPRender(player)
    playerConnections[player] = player.CharacterAdded:Connect(function(character)
        if Configuration.ESP_Highlight then applyHighlight(character) end
        if Configuration.ESP_Chams then task.wait(0.1) applyChams(player) end
        startESPRender(player)
    end)
end

local function initAllPlayers()
    for _, player in ipairs(Players:GetPlayers()) do
        if not ESPConnections[player] then onPlayer(player) end
    end
end

local function cleanupPlayer(player)
    if player.Character then removeHighlight(player.Character) end
    removeChams(player)
    if ESPConnections[player] then ESPConnections[player]:Disconnect() ESPConnections[player] = nil end
    removeESPDrawings(player)
    if playerConnections[player] then playerConnections[player]:Disconnect() playerConnections[player] = nil end
end

local function disableAllESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LP then continue end
        cleanupPlayer(player)
    end
end

-- ============================
-- SCREEN DRAWINGS
-- ============================

local chLines = {
    newLine(Color3.fromRGB(255,255,255), 1.5),
    newLine(Color3.fromRGB(255,255,255), 1.5),
    newLine(Color3.fromRGB(255,255,255), 1.5),
    newLine(Color3.fromRGB(255,255,255), 1.5),
}
local chDot     = newCircle(Color3.fromRGB(255,255,255), 1.5)
local chCirc    = newCircle(Color3.fromRGB(255,255,255), 1.5)
local fovCircle = newCircle(Color3.fromRGB(255,255,255), 1)

RunService.RenderStepped:Connect(function()
    local vp  = Camera.ViewportSize
    local cx  = vp.X / 2
    local cy  = vp.Y / 2
    local sz  = Configuration.CrosshairSize
    local col = Configuration.CrosshairColor

    if Configuration.Crosshair then
        local style = Configuration.CrosshairStyle
        for _, l in ipairs(chLines) do l.Visible = false end
        chDot.Visible  = false
        chCirc.Visible = false

        if style == "Cross" then
            chLines[1].Visible = true chLines[1].Color = col
            chLines[1].From    = Vector2.new(cx - sz, cy)
            chLines[1].To      = Vector2.new(cx + sz, cy)
            chLines[2].Visible = true chLines[2].Color = col
            chLines[2].From    = Vector2.new(cx, cy - sz)
            chLines[2].To      = Vector2.new(cx, cy + sz)
        elseif style == "Dot" then
            chDot.Visible  = true
            chDot.Color    = col
            chDot.Position = Vector2.new(cx, cy)
            chDot.Radius   = 3
            chDot.Filled   = true
        elseif style == "Circle" then
            chCirc.Visible  = true
            chCirc.Color    = col
            chCirc.Position = Vector2.new(cx, cy)
            chCirc.Radius   = sz
        elseif style == "X" then
            chLines[1].Visible = true chLines[1].Color = col
            chLines[1].From    = Vector2.new(cx - sz, cy - sz)
            chLines[1].To      = Vector2.new(cx + sz, cy + sz)
            chLines[2].Visible = true chLines[2].Color = col
            chLines[2].From    = Vector2.new(cx + sz, cy - sz)
            chLines[2].To      = Vector2.new(cx - sz, cy + sz)
        end
    else
        for _, l in ipairs(chLines) do l.Visible = false end
        chDot.Visible  = false
        chCirc.Visible = false
    end

    if Configuration.FOVCircle then
        fovCircle.Visible  = true
        fovCircle.Color    = Color3.fromRGB(255, 255, 255)
        fovCircle.Position = Vector2.new(cx, cy)
        fovCircle.Radius   = Configuration.FOVRadius
    else
        fovCircle.Visible = false
    end
end)

-- ============================
-- FULLBRIGHT
-- ============================

local origAmbient        = Lighting.Ambient
local origBrightness     = Lighting.Brightness
local origOutdoorAmbient = Lighting.OutdoorAmbient

local function enableFullbright()
    origAmbient        = Lighting.Ambient
    origBrightness     = Lighting.Brightness
    origOutdoorAmbient = Lighting.OutdoorAmbient
    Lighting.Ambient        = Color3.fromRGB(255, 255, 255)
    Lighting.Brightness     = 2
    Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
end

local function disableFullbright()
    Lighting.Ambient        = origAmbient
    Lighting.Brightness     = origBrightness
    Lighting.OutdoorAmbient = origOutdoorAmbient
end

-- ============================
-- COMBAT — TARGET FINDER
-- ============================

-- Gets closest player to mouse cursor within given FOV radius
local function getClosestPlayer(fov)
    local mousePos  = UserInputService:GetMouseLocation()
    local closest   = nil
    local closestDist = fov

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LP then continue end
        local char = player.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then continue end

        local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen then continue end

        -- Use GetMouseLocation() for accurate screen position
        -- Subtract gui inset (36px) from Y to match viewport coords
        local sv   = Vector2.new(screenPos.X, screenPos.Y)
        local mp   = Vector2.new(mousePos.X, mousePos.Y + 36)
        local dist = (sv - mp).Magnitude

        if dist < closestDist then
            closestDist = dist
            closest     = player
        end
    end

    return closest
end

local function getAimPart(character, partName)
    return character:FindFirstChild(partName)
        or character:FindFirstChild("Head")
        or character:FindFirstChild("HumanoidRootPart")
end

-- ============================
-- AIMBOT
-- Based on dev79kz/AimbotScript approach:
-- - Persistent locked target (stops shaking from re-evaluating every frame)
-- - TweenService Camera.CFrame for smooth, sticky first-person lock
-- - Only drops lock when target leaves FOV or dies
-- - mousemoverel used as fallback for third-person
-- ============================

local aimbotLocked    = nil  -- persistent lock target
local aimbotRunning   = false
local aimbotAnimation = nil

local function cancelAimbotLock()
    aimbotLocked = nil
    if aimbotAnimation then
        aimbotAnimation:Cancel()
        aimbotAnimation = nil
    end
end

local function getAimbotTarget()
    -- If we already have a lock, validate it first
    if aimbotLocked then
        local char = aimbotLocked.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        local part = char and char:FindFirstChild(Configuration.AimbotPart)

        -- Drop lock if target died, left, or walked out of FOV
        if not char or not hum or hum.Health <= 0 or not part then
            cancelAimbotLock() 
        else
            local vec, onScreen = Camera:WorldToViewportPoint(part.Position)
            local mousePos      = UserInputService:GetMouseLocation()
            local screenDist    = (Vector2.new(vec.X, vec.Y) - Vector2.new(mousePos.X, mousePos.Y + 36)).Magnitude
            if not onScreen or screenDist > Configuration.AimbotFOV * 2 then
                cancelAimbotLock()
            end
        end
    end

    -- Find new target if we don't have one
    if not aimbotLocked then
        local bestDist = Configuration.AimbotFOV
        local mousePos = UserInputService:GetMouseLocation()

        for _, player in ipairs(Players:GetPlayers()) do
            if player == LP then continue end
            local char = player.Character
            if not char then continue end
            local part = char:FindFirstChild(Configuration.AimbotPart)
                      or char:FindFirstChild("Head")
                      or char:FindFirstChild("HumanoidRootPart")
            local hum  = char:FindFirstChildOfClass("Humanoid")
            if not part or not hum or hum.Health <= 0 then continue end

            local vec, onScreen = Camera:WorldToViewportPoint(part.Position)
            if not onScreen then continue end

            -- Distance from mouse to target on screen
            -- Add 36 to mousePos.Y to account for GUI inset
            local screenDist = (
                Vector2.new(vec.X, vec.Y) -
                Vector2.new(mousePos.X, mousePos.Y + 36)
            ).Magnitude

            if screenDist < bestDist then
                bestDist      = screenDist
                aimbotLocked  = player
            end
        end
    end

    return aimbotLocked
end

RunService.RenderStepped:Connect(function()
    if not Configuration.Aimbot then
        cancelAimbotLock()
        return
    end
    if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        cancelAimbotLock()
        return
    end

    local target = getAimbotTarget()
    if not target or not target.Character then return end

    local aimPart = target.Character:FindFirstChild(Configuration.AimbotPart)
                 or target.Character:FindFirstChild("Head")
                 or target.Character:FindFirstChild("HumanoidRootPart")
    if not aimPart then return end

    -- Use TweenService Camera CFrame for smooth sticky lock
    -- This is the same approach as dev79kz — smooth and doesn't shake
    local sensitivity = Configuration.AimbotSmooth

    if sensitivity <= 0.05 then
        -- Instant snap
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, aimPart.Position)
    else
        -- Smooth tween toward target
        if aimbotAnimation then aimbotAnimation:Cancel() end
        aimbotAnimation = TweenService:Create(
            Camera,
            TweenInfo.new(sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
            {CFrame = CFrame.new(Camera.CFrame.Position, aimPart.Position)}
        )
        aimbotAnimation:Play()
    end
end)

-- ============================
-- SILENT AIM
-- Learned from open source (Averiias, Stefanuk12):
-- Hook __index on Mouse.Hit and Mouse.Target
-- This is NOT namecall — completely different metamethod
-- checkcaller() ensures we only intercept external game reads
-- Velocity prediction added for moving targets
-- ============================


-- ============================
-- REACH EXTENDER
-- Directly patch ProximityPrompt MaxActivationDistance
-- No metamethod hook needed — just set the property
-- ============================

local function patchPrompt(prompt)
    if not prompt:IsA("ProximityPrompt") then return end
    RunService.Heartbeat:Connect(function()
        if Configuration.ReachExtender then
            pcall(function() prompt.MaxActivationDistance = Configuration.ReachValue end)
        end
    end)
end

workspace.DescendantAdded:Connect(function(desc)
    if desc:IsA("ProximityPrompt") then patchPrompt(desc) end
end)

-- Patch all existing prompts on load
for _, desc in ipairs(workspace:GetDescendants()) do
    if desc:IsA("ProximityPrompt") then patchPrompt(desc) end
end

-- ============================
-- MOVEMENT
-- ============================

local noclipConn = nil

local function enableNoclip()
    noclipConn = RunService.Stepped:Connect(function()
        if not Configuration.Noclip then return end
        local char = LP.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end)
end

local function disableNoclip()
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    local char = LP.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = true end
    end
end

local flyConn = nil
local flyBody = nil
local flyGyro = nil

local function enableFly()
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    hum.PlatformStand = true
    flyBody           = Instance.new("BodyVelocity")
    flyBody.Velocity  = Vector3.zero
    flyBody.MaxForce  = Vector3.new(1e5, 1e5, 1e5)
    flyBody.Parent    = hrp
    flyGyro           = Instance.new("BodyGyro")
    flyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    flyGyro.D         = 50
    flyGyro.Parent    = hrp
    flyConn = RunService.RenderStepped:Connect(function()
        if not Configuration.Fly then return end
        local speed = Configuration.FlySpeed
        local cf    = Camera.CFrame
        local vel   = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.yAxis end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vel = vel - Vector3.yAxis end
        flyBody.Velocity = vel.Magnitude > 0 and vel.Unit * speed or Vector3.zero
        flyGyro.CFrame   = cf
    end)
end

local function disableFly()
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if flyBody then flyBody:Destroy()    flyBody = nil end
    if flyGyro then flyGyro:Destroy()    flyGyro = nil end
    local char = LP.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end

local function setSpeed(val)
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = val end
end

LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    if Configuration.SpeedHack then setSpeed(Configuration.SpeedValue) end
end)

-- ============================
-- UTILITY
-- ============================

local antiAFKConn = nil

local function enableAntiAFK()
    antiAFKConn = RunService.Heartbeat:Connect(function()
        if not Configuration.AntiAFK then return end
        pcall(function()
            game:GetService("VirtualInputManager"):SendKeyEvent(true, "Q", false, game)
        end)
    end)
end

local function disableAntiAFK()
    if antiAFKConn then antiAFKConn:Disconnect() antiAFKConn = nil end
end

local function enableAutoRejoin()
    LP.AncestryChanged:Connect(function()
        if not Configuration.AutoRejoin then return end
        pcall(function() TeleportService:Teleport(game.PlaceId, LP) end)
    end)
end

local function serverHop()
    local url = string.format(
        "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100",
        game.PlaceId
    )
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)
    if not success or not result or not result.data then
        Notify("Server Hop", "Failed to fetch servers.", "alert-triangle", 3)
        return
    end
    local servers = {}
    for _, server in ipairs(result.data) do
        if server.id ~= game.JobId and server.playing < server.maxPlayers then
            table.insert(servers, server.id)
        end
    end
    if #servers == 0 then
        Notify("Server Hop", "No available servers found.", "alert-triangle", 3)
        return
    end
    Notify("Server Hop", "Hopping to a new server...", "arrow-right", 2)
    task.wait(1.5)
    TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LP)
end

local function rejoinServer()
    Notify("Rejoin", "Rejoining same server...", "refresh-cw", 2)
    task.wait(1.5)
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
end

local function enableChatNotify()
    local function hookChat(player)
        if player == LP then return end
        player.Chatted:Connect(function(msg)
            if not Configuration.ChatNotify then return end
            local keyword = Configuration.ChatKeyword:lower()
            if keyword ~= "" and msg:lower():find(keyword, 1, true) then
                Notify("Chat Alert", player.Name .. ": " .. msg, "message-circle", 5)
            end
        end)
    end
    for _, p in ipairs(Players:GetPlayers()) do hookChat(p) end
    Players.PlayerAdded:Connect(hookChat)
end

local function copyOutfit(target)
    if not target or not target.Character then
        Notify("Copy Outfit", "Player not found.", "alert-triangle", 3) return
    end
    local char   = target.Character
    local myChar = LP.Character
    if not myChar then return end
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Accessory") or obj:IsA("Shirt") or obj:IsA("Pants")
            or obj:IsA("ShirtGraphic") or obj:IsA("BodyColors") then
            pcall(function() obj:Clone().Parent = myChar end)
        end
    end
    Notify("Copy Outfit", "Copied " .. target.Name .. "'s outfit!", "user-check", 3)
end

local spectateConn = nil

local function spectatePlayer(target)
    if spectateConn then spectateConn:Disconnect() spectateConn = nil end
    if not target or not target.Character then return end
    Camera.CameraType = Enum.CameraType.Scriptable
    spectateConn = RunService.RenderStepped:Connect(function()
        if not target or not target.Character then return end
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if hrp then Camera.CFrame = hrp.CFrame * CFrame.new(0, 2, 6) end
    end)
end

local function stopSpectate()
    if spectateConn then spectateConn:Disconnect() spectateConn = nil end
    Camera.CameraType = Enum.CameraType.Custom
end

local function teleportToPlayer(target)
    if not target or not target.Character then return end
    local hrp   = target.Character:FindFirstChild("HumanoidRootPart")
    local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if hrp and myHRP then myHRP.CFrame = hrp.CFrame * CFrame.new(0, 0, 3) end
end

local function bringPlayer(target)
    if not target or not target.Character then return end
    local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
    local myHRP     = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if targetHRP and myHRP then
        targetHRP.CFrame = myHRP.CFrame * CFrame.new(0, 0, -3)
    end
end

-- ============================
-- FARMING
-- ============================

local bankLogThread  = nil
local bankLogRunning = false

local function bankLogFarm()
    while bankLogRunning and Configuration.AutoBankLog do
        local s, e = pcall(function()
            game:GetService("ReplicatedStorage").PackDealer:FireServer("Banklog")
        end)
        if not s then warn("Banklog failed:", e) end
        task.wait(0.5)
        s, e = pcall(function()
            game:GetService("ReplicatedStorage").UI.SwipeLog:FireServer()
        end)
        if not s then warn("SwipeLog failed:", e) end
        task.wait(0.5)
    end
end

local function startBankLogFarm()
    if bankLogRunning then return end
    bankLogRunning = true
    bankLogThread  = task.spawn(bankLogFarm)
end

local function stopBankLogFarm()
    bankLogRunning = false
    if bankLogThread then coroutine.close(bankLogThread) bankLogThread = nil end
end

local spillCleanerThread  = nil
local spillCleanerRunning = false

local function getCharacter()
    local char = LP.Character
    if not char or not char.Parent then LP.CharacterAdded:Wait() char = LP.Character end
    return char
end

local function teleportTo(pos)
    local char = getCharacter()
    local hrp  = char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = CFrame.new(pos) task.wait(0.3) end
end

local function cleanAllSpills()
    local sys = workspace:FindFirstChild("SpillSystem")
    if not sys then return end
    for _, child in ipairs(sys:GetChildren()) do
        if not spillCleanerRunning then break end
        if child:IsA("BasePart") then
            local prompt = child:FindFirstChild("Spill")
            if prompt and prompt:IsA("ProximityPrompt") then
                teleportTo(child.Position)
                fireproximityprompt(prompt)
                task.wait(4)
            end
        end
    end
end

local function startSpillCleaner()
    spillCleanerRunning = true
    while spillCleanerRunning and Configuration.AutoSpillCleaner do
        cleanAllSpills() task.wait(5)
    end
end

local function stopSpillCleaner()
    spillCleanerRunning = false
    if spillCleanerThread then coroutine.close(spillCleanerThread) spillCleanerThread = nil end
end

local autoIdeaThread = nil

local function AutoIdeaFunc()
    local rs = game:GetService("ReplicatedStorage")
    local dj = rs:FindFirstChild("UI") and rs.UI:FindFirstChild("DeliveryJob")
    if dj then pcall(function() dj:FireServer("StartJob") end) end
    wait(20)
    while Configuration.AutoIdea do
        local spot = nil
        local tb   = workspace:FindFirstChild("TrackingBlocks")
        local djf  = workspace:FindFirstChild("DeliveryJob")
        if tb and djf then
            for _, v in pairs(tb:GetChildren()) do
                if v and v.Name == "IdeaTracking" then
                    for _, b in pairs(djf:GetChildren()) do
                        if b and string.find(b.Name, "Dest") then
                            if (v.CFrame.Position - b.CFrame.Position).Magnitude < 50 then
                                spot = b.CFrame.Position
                            end
                        end
                    end
                end
            end
        end
        if spot then
            local cars = workspace:FindFirstChild("Cars")
            if cars then
                for _, v in pairs(cars:GetChildren()) do
                    if v:FindFirstChild("Owner") and v.Owner.Value == LP.Name then
                        for _, b in v:GetDescendants() do
                            if b.ClassName == "Model" then
                                pcall(function() b:SetPrimaryPartCFrame(CFrame.new(spot)) end)
                            elseif b:IsA("BasePart") and b.Name ~= "HumanoidRootPart" then
                                pcall(function() b.CFrame = CFrame.new(spot) end)
                            end
                        end
                    end
                end
            end
        end
        wait(20)
    end
end

-- ============================
-- PLAYER EVENTS
-- ============================

Players.PlayerAdded:Connect(function(player)
    if anyESPActive() then onPlayer(player) end
end)

Players.PlayerRemoving:Connect(function(player)
    cleanupPlayer(player)
end)

-- ============================
-- CONFIG MANAGER
-- ============================

local ConfigManager = window.ConfigManager
local mainConfig    = ConfigManager:CreateConfig("slurricane_config")

-- ============================
-- UI — VISUALS TAB
-- ============================

utilityTab:Keybind({
    Title = "Toggle UI",
    Desc = "Keybind to show/hide the UI",
    Value = "RightShift",
    Callback = function(v)
        window:SetToggleKey(Enum.KeyCode[v])
    end
})

visualsTab:Colorpicker({
    Title = "ESP Color",
    Desc = "Color for box, highlight, skeleton, tracers and name",
    Default = Color3.fromRGB(255, 255, 255),
    Transparency = 0,
    Locked = false,
    Callback = function(color)
        Configuration.ESP_Color = color
        updateHighlightColors()
    end
})

espSection:Toggle({
    Title = "Highlight",
    Desc = "Renders a highlight through walls",
    Flag = "espHighlight",
    Callback = function(state)
        Configuration.ESP_Highlight = state
        if state then initAllPlayers() refreshHighlights()
        else refreshHighlights() if not anyESPActive() then disableAllESP() end end
        Notify("ESP", "Highlight " .. (state and "enabled" or "disabled"), "eye", 2)
    end
})

espSection:Toggle({
    Title = "Box",
    Desc = "2D bounding box around players",
    Flag = "espBox",
    Callback = function(state)
        Configuration.ESP_Box = state
        if state then initAllPlayers() elseif not anyESPActive() then disableAllESP() end
        Notify("ESP", "Box " .. (state and "enabled" or "disabled"), "square", 2)
    end
})

espSection:Toggle({
    Title = "Skeleton",
    Desc = "Draws bones over the player rig",
    Flag = "espSkeleton",
    Callback = function(state)
        Configuration.ESP_Skeleton = state
        if state then initAllPlayers() elseif not anyESPActive() then disableAllESP() end
    end
})

espSection:Toggle({
    Title = "Name",
    Desc = "Shows player name above head",
    Flag = "espName",
    Callback = function(state)
        Configuration.ESP_Name = state
        if state then initAllPlayers() elseif not anyESPActive() then disableAllESP() end
    end
})

espSection:Toggle({
    Title = "Health",
    Desc = "Health bar and HP text",
    Flag = "espHealth",
    Callback = function(state)
        Configuration.ESP_Health = state
        if state then initAllPlayers() elseif not anyESPActive() then disableAllESP() end
    end
})

espSection:Toggle({
    Title = "Tracers",
    Desc = "Line from screen bottom to each player",
    Flag = "espTracers",
    Callback = function(state)
        Configuration.ESP_Tracers = state
        if state then initAllPlayers() elseif not anyESPActive() then disableAllESP() end
    end
})

espSection:Toggle({
    Title = "Distance",
    Desc = "Shows stud distance next to name",
    Flag = "espDistance",
    Callback = function(state)
        Configuration.ESP_Distance = state
        if state then initAllPlayers() elseif not anyESPActive() then disableAllESP() end
    end
})

espSection:Toggle({
    Title = "Chams",
    Desc = "Flat color overlay on player parts",
    Flag = "espChams",
    Callback = function(state)
        Configuration.ESP_Chams = state
        if state then initAllPlayers() refreshChams()
        else refreshChams() if not anyESPActive() then disableAllESP() end end
    end
})

espSection:Toggle({
    Title = "Visible Only",
    Desc = "Only show ESP on players you can see",
    Flag = "espVisibleOnly",
    Callback = function(state)
        Configuration.ESP_VisibleOnly = state
    end
})

visualsTab:Slider({
    Title = "Max ESP Distance",
    Desc = "Maximum stud range for ESP",
    Step = 50,
    Value = {Min = 50, Max = 2000, Default = 1000},
    Callback = function(value)
        Configuration.ESP_MaxDist = value
    end
})

screenSection:Toggle({
    Title = "Crosshair",
    Desc = "Draw a crosshair on screen",
    Flag = "crosshair",
    Callback = function(state)
        Configuration.Crosshair = state
        Notify("Visuals", "Crosshair " .. (state and "enabled" or "disabled"), "crosshair", 2)
    end
})

screenSection:Dropdown({
    Title = "Crosshair Style",
    Desc = "Shape of the crosshair",
    Values = {"Cross", "Dot", "Circle", "X"},
    Multi = false,
    Default = "Cross",
    Callback = function(value)
        Configuration.CrosshairStyle = value
    end
})

visualsTab:Colorpicker({
    Title = "Crosshair Color",
    Desc = "Color of the crosshair",
    Default = Color3.fromRGB(255, 255, 255),
    Transparency = 0,
    Locked = false,
    Callback = function(color)
        Configuration.CrosshairColor = color
        for _, l in ipairs(chLines) do l.Color = color end
        chDot.Color  = color
        chCirc.Color = color
    end
})

visualsTab:Slider({
    Title = "Crosshair Size",
    Desc = "Size of the crosshair",
    Step = 1,
    Value = {Min = 2, Max = 30, Default = 10},
    Callback = function(value)
        Configuration.CrosshairSize = value
    end
})

screenSection:Toggle({
    Title = "FOV Circle",
    Desc = "Shows aimbot/silent aim FOV radius on screen",
    Flag = "fovCircle",
    Callback = function(state)
        Configuration.FOVCircle = state
    end
})

screenSection:Toggle({
    Title = "Fullbright",
    Desc = "Removes all shadows and darkness",
    Flag = "fullbright",
    Callback = function(state)
        Configuration.Fullbright = state
        if state then enableFullbright() else disableFullbright() end
        Notify("Visuals", "Fullbright " .. (state and "enabled" or "disabled"), "sun", 2)
    end
})

-- ============================
-- UI — COMBAT TAB
-- ============================

combatSection:Toggle({
    Title = "Aimbot",
    Desc = "Auto aim at nearest player in FOV (hold RMB)",
    Flag = "aimbot",
    Callback = function(state)
        Configuration.Aimbot = state
        Notify("Combat", "Aimbot " .. (state and "enabled" or "disabled"), "crosshair", 2)
    end
})

combatTab:Slider({
    Title = "Aimbot FOV",
    Desc = "Screen radius to detect targets",
    Step = 5,
    Value = {Min = 10, Max = 500, Default = 80},
    Callback = function(value)
        Configuration.AimbotFOV = value
        Configuration.FOVRadius = value
    end
})

-- Replace the Aimbot Smoothness slider with this:
combatTab:Slider({
    Title = "Aimbot Smoothness",
    Desc = "Tween time in seconds — lower = snappier, higher = floaty",
    Step = 0.05,
    Value = {Min = 0, Max = 1, Default = 0.1},
    Callback = function(value)
        Configuration.AimbotSmooth = value
        cancelAimbotLock() -- cancel any active tween when changed
    end
})

combatTab:Dropdown({
    Title = "Aimbot Target Part",
    Desc = "Which body part to aim at",
    Values = {"Head", "HumanoidRootPart", "UpperTorso"},
    Multi = false,
    Default = "Head",
    Callback = function(value)
        Configuration.AimbotPart = value
    end
})



combatSection:Toggle({
    Title = "Reach Extender",
    Desc = "Increases tool interaction distance",
    Flag = "reachExtender",
    Callback = function(state)
        Configuration.ReachExtender = state
        Notify("Combat", "Reach Extender " .. (state and "enabled" or "disabled"), "hand", 2)
    end
})

combatTab:Slider({
    Title = "Reach Distance",
    Desc = "How far tools can reach in studs",
    Step = 1,
    Value = {Min = 5, Max = 100, Default = 10},
    Callback = function(value)
        Configuration.ReachValue = value
    end
})

-- ============================
-- UI — MOVEMENT TAB
-- ============================

movementSection:Toggle({
    Title = "Noclip",
    Desc = "Walk through walls",
    Flag = "noclip",
    Callback = function(state)
        Configuration.Noclip = state
        if state then enableNoclip() else disableNoclip() end
        Notify("Movement", "Noclip " .. (state and "enabled" or "disabled"), "layers", 2)
    end
})

movementSection:Toggle({
    Title = "Fly",
    Desc = "Fly with WASD + Space/Shift",
    Flag = "fly",
    Callback = function(state)
        Configuration.Fly = state
        if state then enableFly() else disableFly() end
        Notify("Movement", "Fly " .. (state and "enabled" or "disabled"), "wind", 2)
    end
})

movementTab:Slider({
    Title = "Fly Speed",
    Desc = "Speed when flying",
    Step = 5,
    Value = {Min = 10, Max = 300, Default = 50},
    Callback = function(value)
        Configuration.FlySpeed = value
    end
})

movementSection:Toggle({
    Title = "Speed Hack",
    Desc = "Increases walk speed",
    Flag = "speedHack",
    Callback = function(state)
        Configuration.SpeedHack = state
        if state then setSpeed(Configuration.SpeedValue) else setSpeed(16) end
        Notify("Movement", "Speed Hack " .. (state and "enabled" or "disabled"), "zap", 2)
    end
})

movementTab:Slider({
    Title = "Walk Speed",
    Desc = "Speed when speed hack is on",
    Step = 1,
    Value = {Min = 16, Max = 300, Default = 25},
    Callback = function(value)
        Configuration.SpeedValue = value
        if Configuration.SpeedHack then setSpeed(value) end
    end
})

-- ============================
-- UI — UTILITY TAB
-- ============================

utilitySection:Toggle({
    Title = "Anti AFK",
    Desc = "Prevents being kicked for inactivity",
    Flag = "antiAFK",
    Callback = function(state)
        Configuration.AntiAFK = state
        if state then enableAntiAFK() else disableAntiAFK() end
        Notify("Utility", "Anti AFK " .. (state and "enabled" or "disabled"), "clock", 2)
    end
})

utilitySection:Toggle({
    Title = "Auto Rejoin",
    Desc = "Automatically rejoins on kick or disconnect",
    Flag = "autoRejoin",
    Callback = function(state)
        Configuration.AutoRejoin = state
        if state then enableAutoRejoin() end
    end
})

utilitySection:Toggle({
    Title = "Chat Notifications",
    Desc = "Notifies when someone says your keyword",
    Flag = "chatNotify",
    Callback = function(state)
        Configuration.ChatNotify = state
        if state then enableChatNotify() end
        Notify("Utility", "Chat Notify " .. (state and "enabled" or "disabled"), "message-circle", 2)
    end
})

utilityTab:Input({
    Title = "Chat Keyword",
    Desc = "Word to listen for in chat",
    Value = "",
    Placeholder = "e.g. your name...",
    Callback = function(input)
        Configuration.ChatKeyword = input
    end
})

utilitySection:Button({
    Title = "Server Hop",
    Desc = "Jump to a random different server",
    Callback = function()
        serverHop()
    end
})

utilitySection:Button({
    Title = "Rejoin Server",
    Desc = "Rejoin the same server",
    Callback = function()
        rejoinServer()
    end
})

utilityTab:Slider({
    Title = "FPS Cap",
    Desc = "Unlock or cap your framerate",
    Step = 10,
    Value = {Min = 30, Max = 360, Default = 60},
    Callback = function(value)
        pcall(function() setfpscap(value) end)
    end
})

local function getPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then table.insert(names, p.Name) end
    end
    return names
end

local spectateDropdown = playerSection:Dropdown({
    Title = "Spectate Player",
    Desc = "Attach camera to a player",
    Values = getPlayerNames(),
    Multi = false,
    Default = nil,
    Callback = function(value)
        if not value or value == "None" then stopSpectate() return end
        local target = Players:FindFirstChild(value)
        if target then
            spectatePlayer(target)
            Notify("Utility", "Spectating " .. value, "eye", 2)
        end
    end
})

playerSection:Button({
    Title = "Stop Spectating",
    Desc = "Return camera to normal",
    Callback = function()
        stopSpectate()
        Notify("Utility", "Stopped spectating", "eye-off", 2)
    end
})

local teleportDropdown = playerSection:Dropdown({
    Title = "Teleport to Player",
    Desc = "Instantly teleport to a player",
    Values = getPlayerNames(),
    Multi = false,
    Default = nil,
    Callback = function(value)
        if not value or value == "None" then return end
        local target = Players:FindFirstChild(value)
        if target then
            teleportToPlayer(target)
            Notify("Utility", "Teleported to " .. value, "map-pin", 2)
        end
    end
})

local bringDropdown = playerSection:Dropdown({
    Title = "Bring Player",
    Desc = "Teleport a player to you",
    Values = getPlayerNames(),
    Multi = false,
    Default = nil,
    Callback = function(value)
        if not value or value == "None" then return end
        local target = Players:FindFirstChild(value)
        if target then
            bringPlayer(target)
            Notify("Utility", "Brought " .. value .. " to you", "user-plus", 2)
        end
    end
})

local outfitDropdown = playerSection:Dropdown({
    Title = "Copy Outfit",
    Desc = "Copy another player's appearance",
    Values = getPlayerNames(),
    Multi = false,
    Default = nil,
    Callback = function(value)
        if not value or value == "None" then return end
        local target = Players:FindFirstChild(value)
        if target then copyOutfit(target) end
    end
})

local function refreshDropdowns()
    local names = getPlayerNames()
    pcall(function() spectateDropdown:SetValues(names) end)
    pcall(function() teleportDropdown:SetValues(names) end)
    pcall(function() bringDropdown:SetValues(names) end)
    pcall(function() outfitDropdown:SetValues(names) end)
end

Players.PlayerAdded:Connect(function(player)
    if anyESPActive() then onPlayer(player) end
    refreshDropdowns()
end)

Players.PlayerRemoving:Connect(function(player)
    cleanupPlayer(player)
    refreshDropdowns()
end)

-- ============================
-- UI — CONFIG SECTION
-- ============================

configSection:Button({
    Title = "Save Config",
    Desc = "Save current settings to disk",
    Callback = function()
        mainConfig:Save()
        Notify("Config", "Config saved!", "save", 3)
    end
})

configSection:Button({
    Title = "Load Config",
    Desc = "Load saved settings from disk",
    Callback = function()
        mainConfig:Load()
        Notify("Config", "Config loaded!", "upload", 3)
    end
})

-- ============================
-- UI — FARMING TAB
-- ============================

autoFarmSection:Toggle({
    Title = "Auto Bank Log Farm",
    Desc = "Automatically farms Banklog and SwipeLog",
    Flag = "autoBankLogElement",
    Callback = function(state)
        Configuration.AutoBankLog = state
        if state then startBankLogFarm() else stopBankLogFarm() end
        Notify("Farming", "Bank Log Farm " .. (state and "started" or "stopped"), "cpu", 2)
    end
})

farmingSection:Toggle({
    Title = "Auto Idea",
    Desc = "Automatically completes the IDEA delivery job",
    Flag = "autoIdeaButtonElement",
    Callback = function(state)
        Configuration.AutoIdea = state
        if state then
            if autoIdeaThread == nil or coroutine.status(autoIdeaThread) == "dead" then
                autoIdeaThread = task.spawn(AutoIdeaFunc)
            end
        end
        Notify("Farming", "Auto Idea " .. (state and "started" or "stopped"), "truck", 2)
    end
})

farmingSection:Toggle({
    Title = "Auto Spill Cleaner",
    Desc = "Automatically cleans spills in the sports shop",
    Flag = "autoSpillCleanerElement",
    Callback = function(state)
        Configuration.AutoSpillCleaner = state
        if state then
            if spillCleanerThread == nil or coroutine.status(spillCleanerThread) == "dead" then
                spillCleanerThread = task.spawn(startSpillCleaner)
            end
        else
            stopSpillCleaner()
        end
        Notify("Farming", "Spill Cleaner " .. (state and "started" or "stopped"), "droplets", 2)
    end
})

-- Auto load config on start
pcall(function() mainConfig:Load() end)

Notify("slurricane.dev", "Script loaded successfully!", "check-circle", 4)
print("slurricane.dev loaded")
