local windUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local cloneref = (cloneref or clonereference or function(instance) return instance end)
local LP = game:GetService("Players").LocalPlayer

local window = windUI:CreateWindow({
    Title = "latae.villam",
    Icon = "door-open", -- lucide icon
    Author = "cerebrum mortuus est emplastrum",
    Folder = "tiber",
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
    Color = ColorSequence.new( -- gradient
    Color3.fromHex("FF0F7B"), Color3.fromHex("F89B29")),
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
    Position = UDim2.new(0.1, 0, 0.6, 0)
})


local mainTab = window:Tab({Title = "main", Icon = "lucide:cpu"})
mainTab:Select()

local mainSection = mainTab:Section({
    Title = "main",
    Box = true,
    TextTransparency = 0.05,
    TextXAlignment = "Left",
    TextSize = 17, -- Default Size
    Opened = true
})

local settings = {
    unload = false,
    autoIdea = false,
    smartTweenY = 10,
    tweenSpeedX = 10,
    tweenSpeedY = 10
}

window:OnDestroy(function() settings.unload = true end)

local utils = {
    tween,
    noclipState = false,
    noclipConnection,
    floatConnection,
    breakVelocity = function(self)
        local velocity = Vector3.new(0, 0, 0)
        for i, v in pairs(LP.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Velocity, v.RotVelocity = velocity, velocity
            end
        end
    end,
    noclip = function(self)
        self.noclipState = true
        wait(0.1)
        local function noclipLoop()
            if self.noclipState and LP.Character ~= nil then
                for i, v in pairs(LP.Character:GetDescendants()) do
                    if v:IsA("BasePart") and v.CanCollide == true then
                        v.CanCollide = false
                    end
                end
            end
        end
        self.noclipConnection = game:GetService("RunService").Stepped:Connect(noclipLoop)
    end,
    clip = function(self)
        self.noclipState = false
        if self.noclipConnection then self.noclipConnection:Disconnect() end
    end,
    float = function(self)
        if self.floatConnection then
            if self.floatConnection.Connected then return end
        end
        local floatPart = Instance.new('Part')
        floatPart.Name = "floatPart"
        floatPart.Parent = LP.Character
        floatPart.Transparency = 1
        floatPart.Size = Vector3.new(2, 0.2, 1.5)
        floatPart.Anchored = true
        local floatValue = -4
        floatPart.CFrame = LP.Character.HumanoidRootPart.CFrame * CFrame.new(0, floatValue, 0)
        self.floatConnection = RS.Stepped:Connect(function()
            if floatPart and floatPart.Parent and LP.Character and
                LP.Character:FindFirstChild("HumanoidRootPart") then
                floatPart.CFrame = LP.Character.HumanoidRootPart.CFrame * CFrame.new(0, floatValue, 0)
            else
                self.floatConnection:Disconnect()
            end
        end)
    end,
    unfloat = function(self)
        if self.floatConnection then self.floatConnection:Disconnect() end
        if LP.Character:FindFirstChild("floatPart") then
            LP.Character.floatPart:Destroy()
        end
    end,
    tweenToPosition = function(self, position, speed)
        local info = TweenInfo.new((LP.Character.HumanoidRootPart.Position - position).Magnitude / speed,
                                   Enum.EasingStyle.Linear,
                                   Enum.EasingDirection.Out, 0, false)
        self.tween = TS:Create(LP.Character.HumanoidRootPart, info, {CFrame = CFrame.new(position.X, position.Y, position.Z)})
        self.tween:Play()
        self:float()
        self:breakVelocity()

        local diedConnection = LP.Character.Humanoid.Died:Connect(function()
            if self.tween then
                self.tween:Cancel()
            end
        end)

        self.tween.Completed:Wait()
        diedConnection:Disconnect()
        self:breakVelocity()
        self:unfloat()
        print(LP.Character.Humanoid:GetState(), self.tween.PlaybackState)
        if self.tween.PlaybackState ~= Enum.PlaybackState.Completed then
            return false
        else
            return true
        end
    end,
    tweenSmart = function(self, position)
        if not self:tweenToPosition(Vector3.new(LP.Character.HumanoidRootPart.Position.X, settings.smartTweenY, LP.Character.HumanoidRootPart.Position.Z), settings.tweenSpeedY) then
            return false
        end
        if not self:tweenToPosition(Vector3.new(position.X, settings.smartTweenY, position.Z), settings.tweenSpeedX) then
            return false
        end
        if not self:tweenToPosition(position, settings.tweenSpeedY) then
            return false
        end
        return true
    end
}



function autoIdeaFunc()
    game:GetService("ReplicatedStorage"):WaitForChild("UI"):WaitForChild("DeliveryJob"):FireServer("StartJob")
    wait(20)
    while not settings.unload and settings.autoIdea do
        local spot = nil
        for i, v in pairs(workspace.TrackingBlocks:GetChildren()) do
            if v and v.Name == "IdeaTracking" then
                for a, b in pairs(workspace.DeliveryJob:GetChildren()) do
                    if b and string.find(b.Name, "Dest") then
                        -- print(v.CFrame.Position)
                        if (v.CFrame.Position - b.CFrame.Position).Magnitude < 50 then
                            --print("spot is " .. b.Name)
                            spot = b.CFrame.Position
                        end
                    end
                end
            end
        end
        if not spot then
            wait(20)
            continue
        end
        for i, v in pairs(workspace.Cars:GetChildren()) do
            if v.Owner.Value == game:GetService("Players").LocalPlayer.Name then
                for a, b in v:GetDescendants() do
                    --print(b.ClassName)
                    if b.ClassName == "Model" then
                        -- b.Anchored = true
                        b.WorldPivot = CFrame.new(spot)
                    elseif b.ClassName == "MeshPart" or b.ClassName == "Part" or
                        b.ClassName == "DriveSeat" then
                        -- b.Anchored = true
                        b.CFrame = CFrame.new(spot)
                    end
                end
            end
        end
        wait(20)
    end
end
local autoIdeaThread = nil
mainSection:Toggle({
    Title = "Auto Idea",
    Flag = "autoIdeaButtonElement",
    Callback = function(state)
        if autoIdeaThread == nil and state then
            autoIdeaThread = task.spawn(autoIdeaFunc)
        elseif autoIdeaThread and state then
            if coroutine.status(autoIdeaThread) == "dead" then
                autoIdeaThread = task.spawn(autoIdeaFunc)
            end
        end
        settings.autoIdea = state
    end
})
