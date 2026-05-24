local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local plr = Players.LocalPlayer
local char = plr.Character
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

-- Load LimbExtender
getgenv().le = getgenv().le or loadstring(game:HttpGet('https://raw.githubusercontent.com/AAPVdev/scripts/refs/heads/main/LimbExtender.lua'))()
local LimbExtender = getgenv().le

-- Initialize LimbExtender
local le = LimbExtender({
    LISTEN_FOR_INPUT = false,
    USE_HIGHLIGHT = false,
})

-- Remotes
local ChatEvent = RS.Remotes.Server.Chat
local EmoteEvent = RS.Remotes.Character.Emote
local RagdollEvent = RS.Remotes.Character.Ragdoll
local ResetEvent = RS.Remotes.Character.Reset
local ShakeEvent = RS.Remotes.Character.Shake
local CuffEvent = RS.Remotes.Character.Cuff
local JailEvent = RS.Remotes.Character.Jail
local TeamEvent = RS.Remotes.Teams.Change
local AlertEvent = RS.Remotes.Server.Alert
local ToggleRain = RS.ToggleRain
local NotifEvent = RS.NotificationPlr

local function getPlayerNames()
    local names = {"None"}
    for _, p in pairs(Players:GetPlayers()) do
        table.insert(names, p.Name)
    end
    return names
end

local Window = WindUI:CreateWindow({
    Title = "tiberius.dev",
    Icon = "sword",
    Author = "Tiberian Development",
    Size = UDim2.fromOffset(420, 550),
})

-- =====================
-- CHAT TAB
-- =====================
local ChatTab = Window:Tab({
    Title = "Chat",
    Icon = "message-circle",
})

local color = "#ff0000"
local message = "hello world"

ChatTab:Colorpicker({
    Title = "Chat Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(val)
        local r = math.floor(val.R * 255)
        local g = math.floor(val.G * 255)
        local b = math.floor(val.B * 255)
        color = string.format("#%02x%02x%02x", r, g, b)
    end
})

ChatTab:Input({
    Title = "Message",
    Placeholder = "Enter message...",
    Callback = function(val)
        message = val
    end
})

ChatTab:Button({
    Title = "Send",
    Callback = function()
        ChatEvent:FireServer('<font color="' .. color .. '">' .. message .. '</font>')
    end
})

-- Emojis
local emojiList = {}
local Emojis = require(RS.Modules.Emojis)
for name, emoji in pairs(Emojis) do
    table.insert(emojiList, name .. " " .. emoji)
end
table.sort(emojiList)

local selectedEmoji = ""
ChatTab:Dropdown({
    Title = "Insert Emoji",
    Values = emojiList,
    Default = emojiList[1],
    Callback = function(val)
        local emoji = val:match(".+ (.+)")
        selectedEmoji = emoji
    end
})

ChatTab:Button({
    Title = "Send With Emoji",
    Callback = function()
        ChatEvent:FireServer('<font color="' .. color .. '">' .. selectedEmoji .. " " .. message .. '</font>')
    end
})

-- =====================
-- FAKE MESSAGE TAB
-- =====================
local FakeTab = Window:Tab({
    Title = "Fake",
    Icon = "ghost",
})

local fakeSender = "None"
local fakeMessage = "hello"
local fakeColor = "#e12323"

FakeTab:Dropdown({
    Title = "Fake Sender",
    Values = getPlayerNames(),
    Default = "None",
    Callback = function(val)
        fakeSender = val
    end
})

FakeTab:Colorpicker({
    Title = "Name Color",
    Default = Color3.fromRGB(225, 35, 35),
    Callback = function(val)
        local r = math.floor(val.R * 255)
        local g = math.floor(val.G * 255)
        local b = math.floor(val.B * 255)
        fakeColor = string.format("#%02x%02x%02x", r, g, b)
    end
})

FakeTab:Input({
    Title = "Fake Message",
    Placeholder = "Enter fake message...",
    Callback = function(val)
        fakeMessage = val
    end
})

FakeTab:Button({
    Title = "Send Fake Message",
    Callback = function()
        if fakeSender == "None" then
            warn("Select a player first!")
            return
        end
        local target = Players:FindFirstChild(fakeSender)
        if not target then
            warn("Player not found!")
            return
        end
        local displayString = '<font color="' .. fakeColor .. '">' .. fakeSender .. '</font>: ' .. fakeMessage
        firesignal(ChatEvent.OnClientEvent, displayString, target, fakeMessage)
    end
})

-- =====================
-- EMOTES TAB
-- =====================
local EmoteTab = Window:Tab({
    Title = "Emotes",
    Icon = "smile",
})

local emotes = {"Sit", "Kneel", "Beg", "Halt", "AtEase"}
local currentEmote = nil

for _, emoteName in pairs(emotes) do
    EmoteTab:Button({
        Title = emoteName,
        Callback = function()
            if currentEmote == emoteName then
                EmoteEvent:FireServer(emoteName)
                currentEmote = nil
                print("Stopped: " .. emoteName)
            else
                EmoteEvent:FireServer(emoteName)
                currentEmote = emoteName
                print("Playing: " .. emoteName)
            end
        end
    })
end

-- =====================
-- LIMB EXTENDER TAB
-- =====================
local LimbTab = Window:Tab({
    Title = "Limb Ex",
    Icon = "scale-3d",
})

-- Main Toggle
local mainToggle = nil

LimbTab:Toggle({
    Text = "Modify Limbs",
    Desc = "Enable/disable limb extender",
    Default = false,
    Callback = function(value)
        le:Toggle(value)
    end
})

LimbTab:Divider()

-- Team Check
LimbTab:Toggle({
    Text = "Team Check",
    Desc = "Only target enemies",
    Default = le:Get("TEAM_CHECK"),
    Callback = function(value)
        le:Set("TEAM_CHECK", value)
    end
})

-- ForceField Check
LimbTab:Toggle({
    Text = "ForceField Check",
    Desc = "Ignore players with forcefield",
    Default = le:Get("FORCEFIELD_CHECK"),
    Callback = function(value)
        le:Set("FORCEFIELD_CHECK", value)
    end
})

-- Limb Collisions (Warning!)
LimbTab:Toggle({
    Text = "Limb Collisions",
    Desc = "⚠️ CAUTION: May cause floating!",
    Default = le:Get("LIMB_CAN_COLLIDE"),
    Callback = function(value)
        le:Set("LIMB_CAN_COLLIDE", value)
        if value then
            WindUI:Notify("Warning", "Limb collisions enabled - you may float!", 3)
        end
    end
})

LimbTab:Divider()

-- Limb Transparency
LimbTab:Slider({
    Title = "Limb Transparency",
    Desc = "Transparency of extended limbs",
    Step = 0.05,
    Value = {
        Min = 0,
        Max = 1,
        Default = le:Get("LIMB_TRANSPARENCY")
    },
    Callback = function(value)
        le:Set("LIMB_TRANSPARENCY", value)
    end
})

-- Limb Size
LimbTab:Slider({
    Title = "Limb Size",
    Desc = "Size of extended limbs (studs)",
    Step = 0.5,
    Value = {
        Min = 5,
        Max = 50,
        Default = le:Get("LIMB_SIZE")
    },
    Callback = function(value)
        le:Set("LIMB_SIZE", value)
    end
})

LimbTab:Divider()

-- Target Limb Dropdown (auto-populates)
local targetLimbDropdown = nil

-- Collect available limbs
local limbs = {}
local function addLimbIfNew(limbName)
    if not limbName then return end
    local found = false
    for _, name in ipairs(limbs) do
        if name == limbName then
            found = true
            break
        end
    end
    if not found then
        table.insert(limbs, limbName)
        table.sort(limbs)
        if targetLimbDropdown then
            targetLimbDropdown:Refresh(limbs)
        end
    end
end

-- Scan character for limbs
local function scanCharacter(character)
    if not character then return end
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("BasePart") then
            addLimbIfNew(child.Name)
        end
    end
    character.ChildAdded:Connect(function(child)
        if child:IsA("BasePart") then
            addLimbIfNew(child.Name)
        end
    end)
end

-- Target Limb Dropdown
targetLimbDropdown = LimbTab:Dropdown({
    Title = "Target Limb",
    Desc = "Select which limb to extend",
    Values = #limbs > 0 and limbs or {"Head", "Torso"},
    Default = le:Get("TARGET_LIMB") or "Head",
    Callback = function(value)
        le:Set("TARGET_LIMB", value)
    end
})

-- Scan local player
if plr.Character then
    scanCharacter(plr.Character)
end
plr.CharacterAdded:Connect(function(character)
    task.wait(0.5)
    scanCharacter(character)
end)

-- Keybind
LimbTab:Keybind({
    Text = "Toggle Keybind",
    Desc = "Key to toggle limb extender on/off",
    Default = le:Get("TOGGLE") or "None",
    Callback = function(key)
        le:Set("TOGGLE", key)
    end
})

LimbTab:Divider()

-- Reset Button
LimbTab:Button({
    Text = "Reset Limb Settings",
    Desc = "Reset all limb extender settings",
    Callback = function()
        le:Set("LIMB_SIZE", 10)
        le:Set("LIMB_TRANSPARENCY", 0.5)
        le:Set("TEAM_CHECK", false)
        le:Set("FORCEFIELD_CHECK", false)
        le:Set("LIMB_CAN_COLLIDE", false)
        le:Set("TARGET_LIMB", "Head")
        WindUI:Notify("LimbExtender", "Settings reset!", 2)
    end
})

-- =====================
-- PLAYER TAB
-- =====================
local PlayerTab = Window:Tab({
    Title = "Player",
    Icon = "user",
})

local selectedPlayer = "None"

PlayerTab:Dropdown({
    Title = "Select Player",
    Values = getPlayerNames(),
    Default = "None",
    Callback = function(val)
        selectedPlayer = val
    end
})

PlayerTab:Button({
    Title = "Ragdoll Self",
    Callback = function()
        RagdollEvent:FireServer()
        print("Ragdolled!")
    end
})

PlayerTab:Button({
    Title = "Reset Self",
    Callback = function()
        ResetEvent:FireServer()
        print("Reset!")
    end
})

PlayerTab:Button({
    Title = "Shake Screen",
    Callback = function()
        ShakeEvent:FireServer()
        print("Shook!")
    end
})

PlayerTab:Button({
    Title = "Cuff Player",
    Callback = function()
        if selectedPlayer == "None" then warn("Select a player!") return end
        local target = Players:FindFirstChild(selectedPlayer)
        if target then
            CuffEvent:FireServer(target)
            print("Cuffed: " .. selectedPlayer)
        end
    end
})

PlayerTab:Button({
    Title = "Jail Player",
    Callback = function()
        if selectedPlayer == "None" then warn("Select a player!") return end
        local target = Players:FindFirstChild(selectedPlayer)
        if target then
            JailEvent:FireServer(target)
            print("Jailed: " .. selectedPlayer)
        end
    end
})

-- =====================
-- TEAMS TAB
-- =====================
local TeamTab = Window:Tab({
    Title = "Teams",
    Icon = "users",
})

local teams = {
    "Rome",
    "Legionary",
    "Urbanae",
    "Lictor",
    "Chassis",
    "Gallic",
    "Athenai",
    "Makedonia",
    "Lacedaemon",
    "Carthago",
    "CoG",
    "Prisoners",
}

local selectedTeam = "Rome"

TeamTab:Dropdown({
    Title = "Select Team",
    Values = teams,
    Default = "Rome",
    Callback = function(val)
        selectedTeam = val
        print("Selected team: " .. val)
    end
})

TeamTab:Button({
    Title = "Switch Team",
    Callback = function()
        TeamEvent:FireServer(selectedTeam)
        print("Switched to: " .. selectedTeam)
    end
})

-- =====================
-- SERVER TAB
-- =====================
local ServerTab = Window:Tab({
    Title = "Server",
    Icon = "globe",
})

local alertMsg = ""

ServerTab:Input({
    Title = "Alert Message",
    Placeholder = "Enter alert...",
    Callback = function(val)
        alertMsg = val
    end
})

ServerTab:Button({
    Title = "Send Alert",
    Callback = function()
        AlertEvent:FireServer(alertMsg)
        print("Alert sent: " .. alertMsg)
    end
})

ServerTab:Button({
    Title = "Toggle Rain",
    Callback = function()
        ToggleRain:FireServer()
        print("Rain toggled!")
    end
})

local notifMsg = ""
local notifTitle = ""

ServerTab:Input({
    Title = "Notification Title",
    Placeholder = "Enter title...",
    Callback = function(val)
        notifTitle = val
    end
})

ServerTab:Input({
    Title = "Notification Message",
    Placeholder = "Enter message...",
    Callback = function(val)
        notifMsg = val
    end
})

ServerTab:Button({
    Title = "Send Notification",
    Callback = function()
        NotifEvent:FireServer(notifTitle, notifMsg)
        print("Notification sent!")
    end
})

-- =====================
-- LOAD COMPLETE
-- =====================
task.wait(1)
WindUI:Notify("Roman Tools", "LimbExtender tab added!", 3)

print("✅ Roman Tools + LimbExtender Loaded!")
