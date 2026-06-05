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
    -- Visuals
    ShowESP = false,
    
    -- Farming
    AutoIdea = false,
    AutoSpillCleaner = false,
    AutoBankLog = false,
}

-- Window setup
local window = windUI:CreateWindow({
    Title = "sweetdreams.og",
    Icon = "door-open",
    Author = "cerebrum mortuus est emplastrum",
    Folder = "sweetdreams",
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
local visualsSection = visualsTab:Section({
    Title = "visuals",
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
-- HIGHLIGHT ESP
-- ============================

local function applyHighlight(character)
    local highlight = Instance.new("Highlight")
    highlight.Name = "DebugHighlight"
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character
end

local function removeHighlight(character)
    local highlight = character:FindFirstChild("DebugHighlight")
    if highlight then
        highlight:Destroy()
    end
end

local playerConnections = {}

local function onPlayer(player)
    if player == LP then return end

    if player.Character then
        if Configuration.ShowESP then
            applyHighlight(player.Character)
        end
    end

    playerConnections[player] = player.CharacterAdded:Connect(function(character)
        if Configuration.ShowESP then
            applyHighlight(character)
        end
    end)
end

local function enableESP()
    for _, player in ipairs(Players:GetPlayers()) do
        onPlayer(player)
    end
end

local function disableESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LP then continue end
        if player.Character then
            removeHighlight(player.Character)
        end
        if playerConnections[player] then
            playerConnections[player]:Disconnect()
            playerConnections[player] = nil
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    if Configuration.ShowESP then
        onPlayer(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if playerConnections[player] then
        playerConnections[player]:Disconnect()
        playerConnections[player] = nil
    end
end)

-- ============================
-- AUTO BANK LOG FARM
-- ============================

local bankLogThread = nil
local bankLogRunning = false

local function bankLogFarm()
    while bankLogRunning and Configuration.AutoBankLog do
        local success, err = pcall(function()
            local Event = game:GetService("ReplicatedStorage").PackDealer
            Event:FireServer("Banklog")
        end)
        if not success then warn("Banklog failed: ", err) end

        task.wait(0.5)

        success, err = pcall(function()
            local Event = game:GetService("ReplicatedStorage").UI.SwipeLog
            Event:FireServer()
        end)
        if not success then warn("SwipeLog failed: ", err) end

        task.wait(0.5)
    end
end

local function startBankLogFarm()
    if bankLogRunning then return end
    bankLogRunning = true
    bankLogThread = task.spawn(bankLogFarm)
    print("Auto Bank Log farm started")
end

local function stopBankLogFarm()
    bankLogRunning = false
    if bankLogThread then
        coroutine.close(bankLogThread)
        bankLogThread = nil
    end
    print("Auto Bank Log farm stopped")
end

-- ============================
-- SPORTS SHOP SPILL CLEANER
-- ============================

local spillCleanerThread = nil
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
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        humanoidRootPart.CFrame = CFrame.new(position)
        task.wait(0.3)
    end
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
                task.wait(3)
                task.wait(1)
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
    if spillCleanerThread then
        coroutine.close(spillCleanerThread)
        spillCleanerThread = nil
    end
end

-- ============================
-- AUTO IDEA (Farming)
-- ============================

local function AutoIdeaFunc()
    local replicatedStorage = game:GetService("ReplicatedStorage")
    local deliveryJob = replicatedStorage:FindFirstChild("UI") and
                       replicatedStorage.UI:FindFirstChild("DeliveryJob")

    if deliveryJob then
        pcall(function() deliveryJob:FireServer("StartJob") end)
    end

    wait(20)

    while Configuration.AutoIdea do
        local spot = nil
        local trackingBlocks = workspace:FindFirstChild("TrackingBlocks")
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

-- Visuals Tab
visualsSection:Toggle({
    Title = "Toggle ESP",
    Flag = "espElement",
    Callback = function(state)
        Configuration.ShowESP = state
        if state then
            enableESP()
        else
            disableESP()
        end
    end
})

-- Auto Farm Section
autoFarmSection:Toggle({
    Title = "Auto Bank Log Farm",
    Description = "Automatically farms Banklog and SwipeLog",
    Flag = "autoBankLogElement",
    Callback = function(state)
        Configuration.AutoBankLog = state
        if state then
            startBankLogFarm()
        else
            stopBankLogFarm()
        end
    end
})

-- Farming Tab
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

print("sweetdreams.og loaded - Farming & ESP only")
