--// MODERN GUI STYLE (ANDHER UI V2)

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 380)
Frame.Position = UDim2.new(0.5, -150, 0.5, -190)
Frame.BackgroundColor3 = Color3.fromRGB(18,18,18)
Frame.Active = true
Frame.Draggable = true

-- Rounded corners
local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 12)

-- Shadow
local UIStroke = Instance.new("UIStroke", Frame)
UIStroke.Color = Color3.fromRGB(60,60,60)
UIStroke.Thickness = 1.5

-- Title bar
local TitleBar = Instance.new("Frame", Frame)
TitleBar.Size = UDim2.new(1,0,0,40)
TitleBar.BackgroundColor3 = Color3.fromRGB(25,25,25)

local TitleCorner = Instance.new("UICorner", TitleBar)
TitleCorner.CornerRadius = UDim.new(0,12)

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1,0,1,0)
Title.BackgroundTransparency = 1
Title.Text = "MM2 SCRIPT BY ANDHER"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

-- Layout for spacing
local Layout = Instance.new("UIListLayout", Frame)
Layout.Padding = UDim.new(0,10)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.VerticalAlignment = Enum.VerticalAlignment.Top

TitleBar.LayoutOrder = 0

-- Function to create modern buttons
local function createButton(text, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.85, 0, 0, 35)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14

    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0,10)

    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(70,70,70)

    return btn
end

-- Example buttons (replace your old ones with these)
local TPAllBtn = createButton("TP ALL (OFF)", Color3.fromRGB(35,35,35))
TPAllBtn.Parent = Frame

local InvisBtn = createButton("INVIS OFF", Color3.fromRGB(35,35,35))
InvisBtn.Parent = Frame

local TPBtn = createButton("TP (NO PLAYER)", Color3.fromRGB(25,80,160))
TPBtn.Parent = Frame

local FlingBtn = createButton("FLING (SELECT PLAYER)", Color3.fromRGB(120,30,30))
FlingBtn.Parent = Frame

-- Scroll container (modern)
local Scroll = Instance.new("ScrollingFrame", Frame)
Scroll.Size = UDim2.new(0.85,0,0,100)
Scroll.BackgroundColor3 = Color3.fromRGB(22,22,22)

local ScrollCorner = Instance.new("UICorner", Scroll)
ScrollCorner.CornerRadius = UDim.new(0,10)

local ScrollStroke = Instance.new("UIStroke", Scroll)
ScrollStroke.Color = Color3.fromRGB(60,60,60)

local UIList = Instance.new("UIListLayout", Scroll)
UIList.Padding = UDim.new(0,5)
