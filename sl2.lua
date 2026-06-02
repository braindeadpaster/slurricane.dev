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

-- ESP Settings
local espSettings = {
    Color = Color3.fromRGB(0, 255, 0),
    Size = 15,
    Transparency = 1,
    AutoScale = true
}

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
-- AUTO BANK LOG FARM
-- ============================

local bankLogThread = nil
local bankLogRunning = false

local function bankLogFarm()
    while bankLogRunning and Configuration.AutoBankLog do
        -- First event: Banklog
        local success, err = pcall(function()
            local Event = game:GetService("ReplicatedStorage").PackDealer
            Event:FireServer("Banklog")
        end)
        
        if not success then
            warn("Banklog failed: ", err)
        end
        
        -- Wait 0.5 seconds
        task.wait(0.5)
        
        -- Second event: SwipeLog
        success, err = pcall(function()
            local Event = game:GetService("ReplicatedStorage").UI.SwipeLog
            Event:FireServer()
        end)
        
        if not success then
            warn("SwipeLog failed: ", err)
        end
        
        -- Wait before next cycle (adjustable)
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
-- PROFESSIONAL ESP (Drawing Library)
-- ============================

local Drawing = Drawing or game:GetService("Drawing")
local ESPObjects = {}

local function NewText(color, size, transparency)
    local text = Drawing.new("Text")
    text.Visible = false
    text.Text = ""
    text.Position = Vector2.new(0, 0)
    text.Color = color
    text.Size = size
    text.Center = true
    text.Transparency = transparency
    text.Outline = true
    text.OutlineColor = Color3.fromRGB(0, 0, 0)
    return text
end

local function NewBox()
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = espSettings.Color
    box.Thickness = 1.5
    box.Transparency = 0.6
    box.Filled = false
    return box
end

local function NewHealthBar()
    local health = Drawing.new("Line")
    health.Visible = false
    health.Color = Color3.fromRGB(0, 255, 0)
    health.Thickness = 3
    health.Transparency = 0.8
    return health
end

local ESPList = {}

local function CreateESP(player)
    if not Configuration.ShowESP then return end
    if player == LP then return end
    
    local esp = {
        NameTag = NewText(espSettings.Color, espSettings.Size, 0.5),
        Box = NewBox(),
        HealthBar = NewHealthBar(),
        DistanceTag = NewText(Color3.fromRGB(255, 255, 255), 12, 0.4),
        Player = player
    }
    
    table.insert(ESPList, esp)
    
    -- Update loop for this player
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not Configuration.ShowESP then 
            esp.NameTag.Visible = false
            esp.Box.Visible = false
            esp.HealthBar.Visible = false
            esp.DistanceTag.Visible = false
            return 
        end
        
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or 
           not player.Character:FindFirstChild("Humanoid") or player.Character.Humanoid.Health <= 0 then
            esp.NameTag.Visible = false
            esp.Box.Visible = false
            esp.HealthBar.Visible = false
            esp.DistanceTag.Visible = false
            return
        end
        
        local rootPart = player.Character.HumanoidRootPart
        local head = player.Character:FindFirstChild("Head") or rootPart
        local humanoid = player.Character.Humanoid
        
        local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1.5, 0))
        local feetPos = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
        
        if onScreen then
            -- Calculate distance
            local distance = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") and 
                           math.floor((LP.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude) or 0
            
            -- Scale size based on distance
            local scale = espSettings.AutoScale and (200 / math.max(distance, 20)) or 1
            local boxWidth = 60 * scale
            local boxHeight = (feetPos.Y - headPos.Y) * 1.2
            
            -- Update Box ESP
            esp.Box.Visible = true
            esp.Box.Size = Vector2.new(boxWidth, boxHeight)
            esp.Box.Position = Vector2.new(headPos.X - boxWidth/2, headPos.Y)
            
            -- Update Health Bar
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            esp.HealthBar.Visible = true
            local healthBarHeight = boxHeight * healthPercent
            esp.HealthBar.From = Vector2.new(headPos.X - boxWidth/2 - 8, headPos.Y + boxHeight - healthBarHeight)
            esp.HealthBar.To = Vector2.new(headPos.X - boxWidth/2 - 8, headPos.Y + boxHeight)
            
            -- Health bar color
            if healthPercent > 0.6 then
                esp.HealthBar.Color = Color3.fromRGB(0, 255, 0)
            elseif healthPercent > 0.3 then
                esp.HealthBar.Color = Color3.fromRGB(255, 165, 0)
            else
                esp.HealthBar.Color = Color3.fromRGB(255, 0, 0)
            end
            
            -- Update Name Tag
            esp.NameTag.Visible = true
            esp.NameTag.Text = player.Name
            esp.NameTag.Position = Vector2.new(headPos.X, headPos.Y - 25)
            
            -- Update Distance Tag
            esp.DistanceTag.Visible = true
            esp.DistanceTag.Text = string.format("%d studs", distance)
            esp.DistanceTag.Position = Vector2.new(headPos.X, headPos.Y + boxHeight + 10)
            
            -- Team color check
            if player.Team and LP.Team and player.Team == LP.Team then
                esp.Box.Color = Color3.fromRGB(0, 255, 255)
                esp.NameTag.Color = Color3.fromRGB(0, 255, 255)
            else
                esp.Box.Color = espSettings.Color
                esp.NameTag.Color = espSettings.Color
            end
        else
            esp.NameTag.Visible = false
            esp.Box.Visible = false
            esp.HealthBar.Visible = false
            esp.DistanceTag.Visible = false
        end
    end)
    
    -- Store connection for cleanup
    esp.Connection = connection
end

local function RemoveAllESP()
    for _, esp in pairs(ESPList) do
        if esp.NameTag then esp.NameTag:Remove() end
        if esp.Box then esp.Box:Remove() end
        if esp.HealthBar then esp.HealthBar:Remove() end
        if esp.DistanceTag then esp.DistanceTag:Remove() end
        if esp.Connection then esp.Connection:Disconnect() end
    end
    ESPList = {}
end

local function EnableESP()
    RemoveAllESP()
    for _, player in ipairs(Players:GetPlayers()) do
        CreateESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if Configuration.ShowESP then
        CreateESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    for i, esp in pairs(ESPList) do
        if esp.Player == player then
            if esp.NameTag then esp.NameTag:Remove() end
            if esp.Box then esp.Box:Remove() end
            if esp.HealthBar then esp.HealthBar:Remove() end
            if esp.DistanceTag then esp.DistanceTag:Remove() end
            if esp.Connection then esp.Connection:Disconnect() end
            table.remove(ESPList, i)
        end
    end
end)

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
    -- Find the SpillSystem folder
    local spillSystem = workspace:FindFirstChild("SpillSystem")
    if not spillSystem then
        return
    end
    
    -- Loop through all children in SpillSystem
    for _, child in ipairs(spillSystem:GetChildren()) do
        if not spillCleanerRunning then break end
        
        -- Check if it's a part (spill)
        if child:IsA("BasePart") then
            -- Look for a ProximityPrompt named "Spill"
            local spillPrompt = child:FindFirstChild("Spill")
            if spillPrompt and spillPrompt:IsA("ProximityPrompt") then
                -- Teleport to the spill
                teleportTo(child.Position)
                
                -- Trigger the proximity prompt
                fireproximityprompt(spillPrompt)
                
                -- Wait for cleaning to complete
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
        task.wait(5) -- Check for new spills every 5 seconds
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
            EnableESP()
        else
            RemoveAllESP()
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
