local windUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local cloneref = (cloneref or clonereference or function(instance) return instance end)

-- Services
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()
local Camera = workspace.CurrentCamera

-- Configuration
local Configuration = {
    ESP_Highlight = false,
    ESP_Box       = false,
    ESP_Skeleton  = false,
    ESP_Name      = false,
    ESP_Health    = false,
    AutoIdea        = false,
    AutoSpillCleaner = false,
    AutoBankLog     = false,
}

-- Window setup
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
    Color = ColorSequence.new(
        Color3.fromHex("FF0F7B"), Color3.fromHex("F89B29")),
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
    Position = UDim2.new(0.1, 0, 0.6, 0)
})

-- Tabs
local visualsTab = window:Tab({Title = "Visuals", Icon = "lucide:eye"})
local farmingTab = window:Tab({Title = "Farming", Icon = "lucide:cpu"})

visualsTab:Select()

-- Sections
local espSection = visualsTab:Section({
    Title = "esp",
    Box = true,
    TextTransparency = 0.05,
    TextXAlignment = "Left",
    TextSize = 17,
    Opened = true
})

local farmingSection = farmingTab:Section({
    Title = "farming",
    Box = true,
    TextTransparency = 0.05,
    TextXAlignment = "Left",
    TextSize = 17,
    Opened = true
})

local autoFarmSection = farmingTab:Section({
    Title = "auto farm",
    Box = true,
    TextTransparency = 0.05,
    TextXAlignment = "Left",
    TextSize = 17,
    Opened = true
})

-- ============================
-- ESP HELPERS
-- ============================

local ESPConnections    = {}
local ESPDrawings       = {}
local playerConnections = {}

local function newText(size, color)
    local t = Drawing.new("Text")
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
    local l = Drawing.new("Line")
    l.Visible   = false
    l.Color     = color
    l.Thickness = thickness or 1
    return l
end

local function newQuad(color, thickness)
    local q = Drawing.new("Quad")
    q.Visible   = false
    q.Color     = color
    q.Thickness = thickness or 1.5
    q.Filled    = false
    return q
end

local function healthColor(pct)
    if pct > 0.6 then
        return Color3.fromRGB(0, 255, 80)
    elseif pct > 0.3 then
        return Color3.fromRGB(255, 165, 0)
    else
        return Color3.fromRGB(255, 50, 50)
    end
end

local BONES = {
    {"Head",          "UpperTorso"},
    {"UpperTorso",    "LowerTorso"},
    {"UpperTorso",    "LeftUpperArm"},
    {"LeftUpperArm",  "LeftLowerArm"},
    {"LeftLowerArm",  "LeftHand"},
    {"UpperTorso",    "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso",    "LeftUpperLeg"},
    {"LeftUpperLeg",  "LeftLowerLeg"},
    {"LeftLowerLeg",  "LeftFoot"},
    {"LowerTorso",    "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"},
}

local function createESPDrawings(player)
    local boneLines = {}
    for i = 1, #BONES do
        boneLines[i] = newLine(Color3.fromRGB(255, 255, 255), 1)
    end

    local drawings = {
        Name   = newText(14, Color3.fromRGB(255, 255, 255)),
        Health = newText(12, Color3.fromRGB(0, 255, 80)),
        BarBG  = newLine(Color3.fromRGB(30, 30, 30), 4),
        BarFG  = newLine(Color3.fromRGB(0, 255, 80), 4),
        Box    = newQuad(Color3.fromRGB(255, 255, 255), 1.5),
        Bones  = boneLines,
    }

    ESPDrawings[player] = drawings
    return drawings
end

local function removeESPDrawings(player)
    local d = ESPDrawings[player]
    if not d then return end
    for k, v in pairs(d) do
        if k == "Bones" then
            for _, line in ipairs(v) do pcall(function() line:Remove() end) end
        else
            pcall(function() v:Remove() end)
        end
    end
    ESPDrawings[player] = nil
end

local function hideDrawings(d)
    d.Name.Visible   = false
    d.Health.Visible = false
    d.BarBG.Visible  = false
    d.BarFG.Visible  = false
    d.Box.Visible    = false
    for _, l in ipairs(d.Bones) do l.Visible = false end
end

local function anyESPActive()
    return Configuration.ESP_Highlight
        or Configuration.ESP_Box
        or Configuration.ESP_Skeleton
        or Configuration.ESP_Name
        or Configuration.ESP_Health
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
        if not anyESPActive() then
            hideDrawings(drawings)
            return
        end

        local char = player.Character
        if not char then hideDrawings(drawings) return end

        local hrp  = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        local hum  = char:FindFirstChildOfClass("Humanoid")

        if not hrp or not head or not hum or hum.Health <= 0 then
            hideDrawings(drawings)
            return
        end

        local headTopWorld = head.Position + Vector3.new(0, head.Size.Y / 2 + 0.3, 0)
        local feetWorld    = hrp.Position  - Vector3.new(0, 3, 0)

        local sHead, visHead = Camera:WorldToViewportPoint(headTopWorld)
        local sFeet          = Camera:WorldToViewportPoint(feetWorld)

        if not visHead then hideDrawings(drawings) return end

        local hV   = Vector2.new(sHead.X, sHead.Y)
        local fV   = Vector2.new(sFeet.X, sFeet.Y)
        local boxH = math.abs(fV.Y - hV.Y)
        local boxW = boxH * 0.5

        local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
        local col = healthColor(pct)

        -- Box
        if Configuration.ESP_Box then
            drawings.Box.Visible = true
            drawings.Box.PointA  = Vector2.new(hV.X - boxW / 2, hV.Y)
            drawings.Box.PointB  = Vector2.new(hV.X + boxW / 2, hV.Y)
            drawings.Box.PointC  = Vector2.new(fV.X + boxW / 2, fV.Y)
            drawings.Box.PointD  = Vector2.new(fV.X - boxW / 2, fV.Y)
        else
            drawings.Box.Visible = false
        end

        -- Health bar
        if Configuration.ESP_Health then
            local barX = hV.X + boxW / 2 + 5
            drawings.BarBG.Visible = true
            drawings.BarBG.From    = Vector2.new(barX, hV.Y)
            drawings.BarBG.To      = Vector2.new(barX, fV.Y)
            drawings.BarFG.Visible = true
            drawings.BarFG.Color   = col
            drawings.BarFG.From    = Vector2.new(barX, fV.Y)
            drawings.BarFG.To      = Vector2.new(barX, fV.Y - (fV.Y - hV.Y) * pct)
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
            drawings.Name.Position = Vector2.new(hV.X, hV.Y - 18)
        else
            drawings.Name.Visible = false
        end

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
                        line.Color   = col
                        line.From    = Vector2.new(sA.X, sA.Y)
                        line.To      = Vector2.new(sB.X, sB.Y)
                    else
                        line.Visible = false
                    end
                else
                    line.Visible = false
                end
            else
                line.Visible = false
            end
        end
    end)
end

-- ============================
-- HIGHLIGHT + PLAYER HOOKS
-- ============================

local function applyHighlight(character)
    local existing = character:FindFirstChild("DebugHighlight")
    if existing then existing:Destroy() end
    local highlight = Instance.new("Highlight")
    highlight.Name                = "DebugHighlight"
    highlight.FillTransparency    = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent              = character
end

local function removeHighlight(character)
    local h = character:FindFirstChild("DebugHighlight")
    if h then h:Destroy() end
end

local function refreshHighlights()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LP then continue end
        if player.Character then
            if Configuration.ESP_Highlight then
                applyHighlight(player.Character)
            else
                removeHighlight(player.Character)
            end
        end
    end
end

local function onPlayer(player)
    if player == LP then return end

    if player.Character and Configuration.ESP_Highlight then
        applyHighlight(player.Character)
    end

    startESPRender(player)

    playerConnections[player] = player.CharacterAdded:Connect(function(character)
        if Configuration.ESP_Highlight then applyHighlight(character) end
        startESPRender(player)
    end)
end

local function initAllPlayers()
    for _, player in ipairs(Players:GetPlayers()) do
        if not ESPConnections[player] then
            onPlayer(player)
        end
    end
end

local function cleanupPlayer(player)
    if player.Character then removeHighlight(player.Character) end
    if ESPConnections[player] then
        ESPConnections[player]:Disconnect()
        ESPConnections[player] = nil
    end
    removeESPDrawings(player)
    if playerConnections[player] then
        playerConnections[player]:Disconnect()
        playerConnections[player] = nil
    end
end

local function disableAllESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LP then continue end
        cleanupPlayer(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if anyESPActive() then onPlayer(player) end
end)

Players.PlayerRemoving:Connect(function(player)
    cleanupPlayer(player)
end)

-- ============================
-- AUTO BANK LOG FARM
-- ============================

local bankLogThread  = nil
local bankLogRunning = false

local function bankLogFarm()
    while bankLogRunning and Configuration.AutoBankLog do
        local success, err = pcall(function()
            game:GetService("ReplicatedStorage").PackDealer:FireServer("Banklog")
        end)
        if not success then warn("Banklog failed: ", err) end
        task.wait(0.5)
        success, err = pcall(function()
            game:GetService("ReplicatedStorage").UI.SwipeLog:FireServer()
        end)
        if not success then warn("SwipeLog failed: ", err) end
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

-- ============================
-- SPORTS SHOP SPILL CLEANER
-- ============================

local spillCleanerThread  = nil
local spillCleanerRunning = false

local function getCharacter()
    local character = LP.Character
    if not character or not character.Parent then
        LP.CharacterAdded:Wait()
        character = LP.Character
    end
    return character
end

local function teleportTo(position)
    local character = getCharacter()
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = CFrame.new(position) task.wait(0.3) end
end

local function cleanAllSpills()
    local spillSystem = workspace:FindFirstChild("SpillSystem")
    if not spillSystem then return end
    for _, child in ipairs(spillSystem:GetChildren()) do
        if not spillCleanerRunning then break end
        if child:IsA("BasePart") then
            local spillPrompt = child:FindFirstChild("Spill")
            if spillPrompt and spillPrompt:IsA("ProximityPrompt") then
                teleportTo(child.Position)
                fireproximityprompt(spillPrompt)
                task.wait(4)
            end
        end
    end
end

local function startSpillCleaner()
    spillCleanerRunning = true
    while spillCleanerRunning and Configuration.AutoSpillCleaner do
        cleanAllSpills()
        task.wait(5)
    end
end

local function stopSpillCleaner()
    spillCleanerRunning = false
    if spillCleanerThread then coroutine.close(spillCleanerThread) spillCleanerThread = nil end
end

-- ============================
-- AUTO IDEA
-- ============================

local function AutoIdeaFunc()
    local replicatedStorage = game:GetService("ReplicatedStorage")
    local deliveryJob = replicatedStorage:FindFirstChild("UI") and
                        replicatedStorage.UI:FindFirstChild("DeliveryJob")
    if deliveryJob then pcall(function() deliveryJob:FireServer("StartJob") end) end
    wait(20)

    while Configuration.AutoIdea do
        local spot = nil
        local trackingBlocks    = workspace:FindFirstChild("TrackingBlocks")
        local deliveryJobFolder = workspace:FindFirstChild("DeliveryJob")

        if trackingBlocks and deliveryJobFolder then
            for _, v in pairs(trackingBlocks:GetChildren()) do
                if v and v.Name == "IdeaTracking" then
                    for _, b in pairs(deliveryJobFolder:GetChildren()) do
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

local autoIdeaThread = nil

-- ============================
-- UI ELEMENTS
-- ============================

espSection:Toggle({
    Title = "Highlight",
    Description = "Renders a highlight through walls",
    Flag = "espHighlight",
    Callback = function(state)
        Configuration.ESP_Highlight = state
        if state then
            initAllPlayers()
            refreshHighlights()
        else
            refreshHighlights()
            if not anyESPActive() then disableAllESP() end
        end
    end
})

espSection:Toggle({
    Title = "Box",
    Description = "2D bounding box around players",
    Flag = "espBox",
    Callback = function(state)
        Configuration.ESP_Box = state
        if state then initAllPlayers() elseif not anyESPActive() then disableAllESP() end
    end
})

espSection:Toggle({
    Title = "Skeleton",
    Description = "Draws bones over the player rig",
    Flag = "espSkeleton",
    Callback = function(state)
        Configuration.ESP_Skeleton = state
        if state then initAllPlayers() elseif not anyESPActive() then disableAllESP() end
    end
})

espSection:Toggle({
    Title = "Name",
    Description = "Shows player name above head",
    Flag = "espName",
    Callback = function(state)
        Configuration.ESP_Name = state
        if state then initAllPlayers() elseif not anyESPActive() then disableAllESP() end
    end
})

espSection:Toggle({
    Title = "Health",
    Description = "Health bar and HP text",
    Flag = "espHealth",
    Callback = function(state)
        Configuration.ESP_Health = state
        if state then initAllPlayers() elseif not anyESPActive() then disableAllESP() end
    end
})

autoFarmSection:Toggle({
    Title = "Auto Bank Log Farm",
    Description = "Automatically farms Banklog and SwipeLog",
    Flag = "autoBankLogElement",
    Callback = function(state)
        Configuration.AutoBankLog = state
        if state then startBankLogFarm() else stopBankLogFarm() end
    end
})

farmingSection:Toggle({
    Title = "Auto Idea",
    Flag = "autoIdeaButtonElement",
    Callback = function(state)
        Configuration.AutoIdea = state
        if state then
            if autoIdeaThread == nil or coroutine.status(autoIdeaThread) == "dead" then
                autoIdeaThread = task.spawn(AutoIdeaFunc)
            end
        end
    end
})

farmingSection:Toggle({
    Title = "Auto Spill Cleaner",
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
    end
})

print("slurricane.dev loaded")
