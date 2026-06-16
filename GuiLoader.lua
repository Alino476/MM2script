local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- CHANGE THIS: Set this to the actual Frame you want to move
local dragFrame = script.Parent 
-- CHANGE THIS: If you want a specific top bar to be the handle, set it here (e.g., dragFrame.TopBar)
local dragHandle = dragFrame 

local dragging = false
local dragStart = Vector3.new()
local startPos = UDim2.new()
local renderConnection = nil

local function update(dt)
	if not dragging then return end
	
	-- Get current mouse position
	local currentMousePos = UserInputService:GetMouseLocation()
	-- Calculate how much the mouse has moved since the drag started
	local delta = currentMousePos - dragStart
	
	-- Instantly snap the frame to the new position on the current frame
	dragFrame.Position = UDim2.new(
		startPos.X.Scale, 
		startPos.X.Offset + delta.X, 
		startPos.Y.Scale, 
		startPos.Y.Offset + delta.Y
	)
end

dragHandle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		
		-- Capture exact starting positions
		local mousePos = UserInputService:GetMouseLocation()
		dragStart = Vector3.new(mousePos.X, mousePos.Y, 0)
		startPos = dragFrame.Position
		
		-- Disconnect any old loops just in case
		if renderConnection then renderConnection:Disconnect() end
		
		-- Bind the movement directly to the frame rendering step (unbreakable lock)
		renderConnection = RunService.RenderStepped:Connect(update)
		
		-- Track when the user stops clicking, even if their mouse leaves the frame/window
		local inputEndedConnection
		inputEndedConnection = UserInputService.InputEnded:Connect(function(endInput)
			if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
				dragging = false
				if renderConnection then
					renderConnection:Disconnect()
					renderConnection = nil
				end
				inputEndedConnection:Disconnect()
			end
		end)
	end
end)
