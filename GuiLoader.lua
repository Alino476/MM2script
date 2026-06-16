-- MM2 SCRIPT BY ANDHER (MOBILE & PC DRAGGABLE FIXED)
-- Features: Header-Bound Touch & Mouse Dragging, Fling All, Target Fling, Interactive Invisibility, Role-Based ESP

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- State Tracking Variables
local InvisibleActive = false
local InvisibleConnection = nil
local SavedCFrame = nil
local RealCharacter = nil
local FakeRig = nil
local EspActive = false

-- Color Configurations
local MurdererColor = Color3.fromRGB(255, 65, 65)  -- Vibrant Red
local SheriffColor = Color3.fromRGB(45, 140, 255)  -- Neon Blue
local InnocentColor = Color3.fromRGB(65, 230, 110) -- Emerald Green

-- ==========================================
-- CREATE THE REFINED UI ELEMENTS
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AndherMM2EliteGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Container
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 480)
MainFrame.Position = UDim2.new(0.5, -150, 0.4, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22) -- Slate Dark Theme
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1
MainStroke.Color = Color3.fromRGB(45, 45, 55)
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame

-- Premium Crimson Top Accent Bar
local TopBorder = Instance.new("Frame")
TopBorder.Name = "TopBorder"
TopBorder.Size = UDim2.new(1, 0, 0, 3)
TopBorder.BackgroundColor3 = Color3.fromRGB(235, 45, 45)
TopBorder.BorderSizePixel = 0
TopBorder.Parent = MainFrame

-- Title Header Banner (THIS IS NOW THE UNIVERSAL TOUCH HANDLE)
local HeaderFrame = Instance.new("Frame")
HeaderFrame.Name = "HeaderFrame"
HeaderFrame.Size = UDim2.new(1, 0, 0, 45)
HeaderFrame.Position = UDim2.new(0, 0, 0, 3)
HeaderFrame.BackgroundTransparency = 1
HeaderFrame.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "MM2 SCRIPT BY ANDHER"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 15
TitleLabel.Parent = HeaderFrame

local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(0, 260, 0, 1)
HeaderLine.Position = UDim2.new(0, 20, 1, -1)
HeaderLine.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = HeaderFrame

-- Button Utility Creation Function
local function createRefinedButton(name, text, pos, parent)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0, 260, 0, 42)
    button.Position = pos
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(230, 230, 240)
    button.Font = Enum.Font.GothamMedium
    button.TextSize = 13
    button.Parent = parent

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 8)
    bCorner.Parent = button

    local bStroke = Instance.new("UIStroke")
    bStroke.Thickness = 1
    bStroke.Color = Color3.fromRGB(50, 50, 65)
    bStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    bStroke.Parent = button

    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
        TweenService:Create(bStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(75, 75, 95)}):Play()
    end)
    button.MouseLeave:Connect(function()
        if button.Text:find("ON") or (button.Name:find("All") and button.Active == false) then return end
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 38)}):Play()
        TweenService:Create(bStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(50, 50, 65)}):Play()
    end)

    return button, bStroke
end

-- Action Toggles
local FlingAllButton, FlingStroke = createRefinedButton("FlingAllButton", "FLING ALL (ONCE)", UDim2.new(0, 20, 0, 65), MainFrame)
local InvisibleButton, InvisStroke = createRefinedButton("InvisibleButton", "INVISIBLE: OFF", UDim2.new(0, 20, 0, 117), MainFrame)
local EspButton, EspStroke = createRefinedButton("EspButton", "ROLE ESP: OFF", UDim2.new(0, 20, 0, 169), MainFrame)

-- Dropdown Roster Header
local SelectLabel = Instance.new("TextLabel")
SelectLabel.Name = "SelectLabel"
SelectLabel.Size = UDim2.new(0, 260, 0, 25)
SelectLabel.Position = UDim2.new(0, 20, 0, 222)
SelectLabel.BackgroundTransparency = 1
SelectLabel.Text = "TARGET PLAYER LIST (TAP TO FLING)"
SelectLabel.TextColor3 = Color3.fromRGB(140, 140, 160)
SelectLabel.Font = Enum.Font.GothamMedium
SelectLabel.TextSize = 11
SelectLabel.TextXAlignment = Enum.TextXAlignment.Left
SelectLabel.Parent = MainFrame

-- Premium Dropdown Container
local DropdownFrame = Instance.new("ScrollingFrame")
DropdownFrame.Name = "DropdownFrame"
DropdownFrame.Size = UDim2.new(0, 260, 0, 205)
DropdownFrame.Position = UDim2.new(0, 20, 0, 250)
DropdownFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
DropdownFrame.BorderSizePixel = 0
DropdownFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
DropdownFrame.ScrollBarThickness = 3
DropdownFrame.ScrollBarImageColor3 = Color3.fromRGB(235, 45, 45)
DropdownFrame.Parent = MainFrame

local DropdownCorner = Instance.new("UICorner")
DropdownCorner.CornerRadius = UDim.new(0, 8)
DropdownCorner.Parent = DropdownFrame

local DropdownStroke = Instance.new("UIStroke")
DropdownStroke.Thickness = 1
DropdownStroke.Color = Color3.fromRGB(30, 30, 40)
DropdownStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
DropdownStroke.Parent = DropdownFrame

local DropdownLayout = Instance.new("UIListLayout")
DropdownLayout.Parent = DropdownFrame
DropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
DropdownLayout.Padding = UDim.new(0, 5)

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingTop = UDim.new(0, 6)
UIPadding.PaddingLeft = UDim.new(0, 6)
UIPadding.PaddingRight = UDim.new(0, 6)
UIPadding.Parent = DropdownFrame

-- ==========================================
-- DUAL MOBILE + PC HARD-LOCKED DRAG ENGINE
-- ==========================================
local dragging = false
local dragStart = nil
local startPos = nil

-- Handle Touch (Mobile Screen Inputs)
HeaderFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

HeaderFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseBehavior or input.UserInputType == Enum.UserInputType.Touch then
        if dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end
end)

-- Universal Backup System for Mobile Trackpads
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseBehavior or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end)


-- ==========================================
-- FLING MECHANICS
-- ==========================================
local function flingTarget(targetPlayer)
    local myChar = LocalPlayer.Character
    local targetChar = targetPlayer.Character
    if not myChar or not targetChar then return end
    
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local myHumanoid = myChar:FindFirstChildOfClass("Humanoid")
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not myRoot or not targetRoot or not myHumanoid or myHumanoid.Health <= 0 then return end
    
    local oldVelocity = myRoot.Velocity
    local oldRotVelocity = myRoot.RotVelocity
    local oldCFrame = myRoot.CFrame
    
    local bg = Instance.new("BodyAngularVelocity")
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.AngularVelocity = Vector3.new(0, 99999, 0)
    bg.Parent = myRoot
    
    myHumanoid:ChangeState(Enum.HumanoidStateType.Physics)
    
    local startTime = tick()
    while tick() - startTime < 0.45 do
        if not targetRoot or not myRoot then break end
        myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0.5, 0)
        myRoot.Velocity = Vector3.new(99, 99, 99) 
        RunService.Heartbeat:Wait()
    end
    
    bg:Destroy()
    myHumanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    myRoot.Velocity = oldVelocity
    myRoot.RotVelocity = oldRotVelocity
    myRoot.CFrame = oldCFrame
end

FlingAllButton.MouseButton1Click:Connect(function()
    FlingAllButton.Text = "FLINGING PLAYERS..."
    FlingAllButton.Active = false
    TweenService:Create(FlingAllButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 20, 20)}):Play()
    TweenService:Create(FlingStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(150, 40, 40)}):Play()

    local snapshotPlayers = Players:GetPlayers()
    for _, target in ipairs(snapshotPlayers) do
        if target ~= LocalPlayer and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            flingTarget(target)
            task.wait(0.25)
        end
    end
    
    FlingAllButton.Text = "FLING ALL (ONCE)"
    FlingAllButton.Active = true
    TweenService:Create(FlingAllButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 38)}):Play()
    TweenService:Create(FlingStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(50, 50, 65)}):Play()
end)

-- ==========================================
-- INTERACTIVE INVISIBLE SYSTEM
-- ==========================================
local function toggleInvisibility()
    RealCharacter = LocalPlayer.Character
    if not RealCharacter then return end
    
    local RootPart = RealCharacter:FindFirstChild("HumanoidRootPart")
    local Humanoid = RealCharacter:FindFirstChildOfClass("Humanoid")
    if not RootPart or not Humanoid or Humanoid.Health <= 0 then return end
    
    InvisibleActive = not InvisibleActive
    
    if InvisibleActive then
        SavedCFrame = RootPart.CFrame
        InvisibleButton.Text = "INVISIBLE: ON"
        TweenService:Create(InvisibleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(55, 25, 25)}):Play()
        TweenService:Create(InvisStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(200, 45, 45)}):Play()
        
        RealCharacter.Archivable = true
        FakeRig = RealCharacter:Clone()
        RealCharacter.Archivable = false
        FakeRig.Name = "InvisibleVisualGhost"
        
        for _, obj in ipairs(FakeRig:GetDescendants()) do
            if obj:IsA("LocalScript") or obj:IsA("Script") then
                obj:Destroy()
            elseif obj:IsA("BasePart") then
                obj.CanCollide = false
                obj.Transparency = 1
            end
        end
        FakeRig.Parent = workspace
        
        for _, child in ipairs(RealCharacter:GetChildren()) do
            if child:IsA("BasePart") and child.Name ~= "HumanoidRootPart" then
                child.Transparency = 1
                child.CFrame = child.CFrame * CFrame.new(0, 5000, 0)
            elseif child:IsA("Accessory") then
                local handle = child:FindFirstChild("Handle")
                if handle then 
                    handle.Transparency = 1 
                    handle.CFrame = handle.CFrame * CFrame.new(0, 5000, 0)
                end
            end
        end
        
        InvisibleConnection = RunService.Heartbeat:Connect(function()
            if RealCharacter and RootPart and Humanoid and Humanoid.Health > 0 then
                if FakeRig and FakeRig:FindFirstChild("HumanoidRootPart") then
                    FakeRig.HumanoidRootPart.CFrame = RootPart.CFrame
                end
            else
                if InvisibleConnection then InvisibleConnection:Disconnect() end
            end
        end)
    else
        InvisibleButton.Text = "INVISIBLE: OFF"
        TweenService:Create(InvisibleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 38)}):Play()
        TweenService:Create(InvisStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(50, 50, 65)}):Play()
        
        if InvisibleConnection then InvisibleConnection:Disconnect() end
        if FakeRig then FakeRig:Destroy() end
        
        if RealCharacter and RootPart then
            for _, child in ipairs(RealCharacter:GetChildren()) do
                if child:IsA("BasePart") and child.Name ~= "HumanoidRootPart" then
                    child.Transparency = 0
                elseif child:IsA("Accessory") then
                    local handle = child:FindFirstChild("Handle")
                    if handle then handle.Transparency = 0 end
                end
            end
            RootPart.CFrame = RootPart.CFrame * CFrame.new(0, 0.1, 0)
        end
    end
end
InvisibleButton.MouseButton1Click:Connect(toggleInvisibility)

-- ==========================================
-- MM2 ROLE-BASED ESP SYSTEM
-- ==========================================
local function cleanESP(player)
    if player.Character then
        local box = player.Character:FindFirstChild("AndherBox")
        local nameTag = player.Character:FindFirstChild("AndherNameTag")
        if box then box:Destroy() end
        if nameTag then nameTag:Destroy() end
    end
end

local function applyESP(player, color, roleText)
    local char = player.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    if not root or not head then return end
    
    local box = char:FindFirstChild("AndherBox") or Instance.new("Highlight")
    box.Name = "AndherBox"
    box.FillColor = color
    box.FillTransparency = 0.6
    box.OutlineColor = Color3.fromRGB(255, 255, 255)
    box.OutlineTransparency = 0.2
    box.Adornee = char
    box.Parent = char
    
    local nameTag = char:FindFirstChild("AndherNameTag")
    if not nameTag then
        nameTag = Instance.new("BillboardGui")
        nameTag.Name = "AndherNameTag"
        nameTag.Size = UDim2.new(0, 200, 0, 50)
        nameTag.AlwaysOnTop = true
        nameTag.ExtentsOffset = Vector3.new(0, 3, 0)
        
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBold
        label.TextSize = 12
        label.TextStrokeTransparency = 0.3
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.Parent = nameTag
    end
    
    nameTag.Label.Text = player.DisplayName .. " • [" .. roleText .. "]"
    nameTag.Label.TextColor3 = color
    nameTag.Adornee = head
    nameTag.Parent = char
end

local function getPlayerRoleColor(player)
    local backpack = player:FindFirstChild("Backpack")
    local char = player.Character
    
    local hasKnife = (backpack and (backpack:FindFirstChild("Knife") or backpack:FindFirstChild("Blade"))) or (char and (char:FindFirstChild("Knife") or char:FindFirstChild("Blade")))
    local hasGun = (backpack and (backpack:FindFirstChild("Gun") or backpack:FindFirstChild("Revolver"))) or (char and (char:FindFirstChild("Gun") or char:FindFirstChild("Revolver")))
    
    if hasKnife then return MurdererColor, "MURDERER"
    elseif hasGun then return SheriffColor, "SHERIFF"
    else return InnocentColor, "INNOCENT" end
end

task.spawn(function()
    while true do
        task.wait(0.4)
        if EspActive then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local color, roleText = getPlayerRoleColor(player)
                    applyESP(player, color, roleText)
                else
                    cleanESP(player)
                end
            end
        else
            for _, player in ipairs(Players:GetPlayers()) do cleanESP(player) end
        end
    end
end)

EspButton.MouseButton1Click:Connect(function()
    EspActive = not EspActive
    if EspActive then
        EspButton.Text = "ROLE ESP: ON"
        TweenService:Create(EspButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 45, 30)}):Play()
        TweenService:Create(EspStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(65, 200, 100)}):Play()
    else
        EspButton.Text = "ROLE ESP: OFF"
        TweenService:Create(EspButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 38)}):Play()
        TweenService:Create(EspStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(50, 50, 65)}):Play()
    end
end)

-- ==========================================
-- PREMIUM DYNAMIC ROSTER DROPDOWN
-- ==========================================
local function updateDropdown()
    for _, child in ipairs(DropdownFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local PlayerButton = Instance.new("TextButton")
            PlayerButton.Name = player.Name
            PlayerButton.Size = UDim2.new(1, 0, 0, 34)
            PlayerButton.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
            PlayerButton.Text = "  " .. player.DisplayName .. " (@" .. player.Name .. ")"
            PlayerButton.TextColor3 = Color3.fromRGB(200, 200, 210)
            PlayerButton.Font = Enum.Font.Gotham
            PlayerButton.TextSize = 11
            PlayerButton.TextXAlignment = Enum.TextXAlignment.Left
            PlayerButton.Parent = DropdownFrame
            
            local pCorner = Instance.new("UICorner")
            pCorner.CornerRadius = UDim.new(0, 6)
            pCorner.Parent = PlayerButton

            local pStroke = Instance.new("UIStroke")
            pStroke.Thickness = 1
            pStroke.Color = Color3.fromRGB(40, 40, 50)
            pStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            pStroke.Parent = PlayerButton

            PlayerButton.MouseEnter:Connect(function()
                TweenService:Create(PlayerButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}):Play()
                TweenService:Create(pStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(235, 45, 45)}):Play()
            end)
            PlayerButton.MouseLeave:Connect(function()
                TweenService:Create(PlayerButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(24, 24, 30)}):Play()
                TweenService:Create(pStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(40, 40, 50)}):Play()
            end)
            
            PlayerButton.MouseButton1Click:Connect(function()
                flingTarget(player)
            end)
        end
    end
    DropdownFrame.CanvasSize = UDim2.new(0, 0, 0, DropdownLayout.AbsoluteContentSize.Y + 15)
end

Players.PlayerAdded:Connect(updateDropdown)
Players.PlayerRemoving:Connect(updateDropdown)
updateDropdown()
