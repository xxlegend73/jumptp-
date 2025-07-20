--// Jump-To-Teleport w/ ON/OFF Toggle + Distance Slider
--// Fully functional + "Made by Hotdog" label
--// Mobile-friendly. Drag to reposition.

-- === CONFIG ===
local MIN_DIST = 5
local MAX_DIST = 200
local START_DIST = 50
local TELE_COOLDOWN = 0.1
local USE_CAMERA_DIR = false

local TOGGLE_SIZE = UDim2.new(0, 48, 0, 48)
local COLOR_ON = Color3.fromRGB(0, 200, 0)
local COLOR_OFF = Color3.fromRGB(200, 0, 0)

-- === SERVICES ===
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local localPlayer = Players.LocalPlayer

-- Helpers
local function getHRP()
	return localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
end
local function getHumanoid()
	return localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
end
local currentHumanoid
local function onCharacterAdded(char)
	currentHumanoid = char:WaitForChild("Humanoid", 5)
end
localPlayer.CharacterAdded:Connect(onCharacterAdded)
if localPlayer.Character then onCharacterAdded(localPlayer.Character) end

-- GUI parent
local function getGuiParent()
	return localPlayer:FindFirstChildOfClass("PlayerGui") or game:GetService("CoreGui")
end
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JumpTPGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = getGuiParent()

-- Slider Frame
local SliderFrame = Instance.new("Frame")
SliderFrame.Size = UDim2.new(0, 220, 0, 80)
SliderFrame.Position = UDim2.new(0, 20, 0.8, 0)
SliderFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
SliderFrame.BackgroundTransparency = 0.2
SliderFrame.BorderSizePixel = 0
SliderFrame.Parent = ScreenGui
Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0,10)

-- Label
local SliderLabel = Instance.new("TextLabel")
SliderLabel.Size = UDim2.new(1, -10, 0, 20)
SliderLabel.Position = UDim2.new(0, 5, 0, 0)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Text = "TP Distance: "..START_DIST
SliderLabel.TextColor3 = Color3.new(1,1,1)
SliderLabel.Font = Enum.Font.GothamBold
SliderLabel.TextSize = 14
SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
SliderLabel.Parent = SliderFrame

-- Bar
local Bar = Instance.new("Frame")
Bar.Size = UDim2.new(1, -20, 0, 6)
Bar.Position = UDim2.new(0, 10, 0, 30)
Bar.BackgroundColor3 = Color3.fromRGB(80,80,80)
Bar.BorderSizePixel = 0
Bar.Parent = SliderFrame
Instance.new("UICorner", Bar).CornerRadius = UDim.new(0,3)

-- Fill
local Fill = Instance.new("Frame")
Fill.Size = UDim2.new(0, 0, 1, 0)
Fill.BackgroundColor3 = Color3.fromRGB(0,170,255)
Fill.BorderSizePixel = 0
Fill.Parent = Bar
Instance.new("UICorner", Fill).CornerRadius = UDim.new(0,3)

-- Handle
local Handle = Instance.new("Frame")
Handle.Size = UDim2.new(0, 16, 0, 16)
Handle.AnchorPoint = Vector2.new(0.5, 0.5)
Handle.Position = UDim2.new(0, 0, 0.5, 0)
Handle.BackgroundColor3 = Color3.fromRGB(255,255,255)
Handle.BorderSizePixel = 0
Handle.Parent = Bar
Instance.new("UICorner", Handle).CornerRadius = UDim.new(1,0)

-- Value label
local ValueLabel = Instance.new("TextLabel")
ValueLabel.Size = UDim2.new(0, 50, 0, 20)
ValueLabel.Position = UDim2.new(1, -55, 0, 40)
ValueLabel.BackgroundTransparency = 1
ValueLabel.Text = tostring(START_DIST)
ValueLabel.TextColor3 = Color3.new(1,1,1)
ValueLabel.Font = Enum.Font.Gotham
ValueLabel.TextSize = 14
ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
ValueLabel.Parent = SliderFrame

-- Made by Hotdog label
local HotdogLabel = Instance.new("TextLabel")
HotdogLabel.Size = UDim2.new(1, -10, 0, 20)
HotdogLabel.Position = UDim2.new(0, 5, 1, -20)
HotdogLabel.BackgroundTransparency = 1
HotdogLabel.Text = "Made by Hotdog"
HotdogLabel.TextColor3 = Color3.fromRGB(255, 170, 0)
HotdogLabel.Font = Enum.Font.GothamBold
HotdogLabel.TextSize = 14
HotdogLabel.TextXAlignment = Enum.TextXAlignment.Center
HotdogLabel.Parent = SliderFrame

-- Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = TOGGLE_SIZE
ToggleButton.Position = UDim2.new(0, 250, 0.8, 6)
ToggleButton.Text = "OFF"
ToggleButton.TextColor3 = Color3.new(1,1,1)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 14
ToggleButton.BackgroundColor3 = COLOR_OFF
ToggleButton.BorderSizePixel = 0
ToggleButton.Parent = ScreenGui
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(1,0)

-- Drag function
local function makeDraggable(guiObj, dragHandle)
	dragHandle = dragHandle or guiObj
	local dragging, dragStart, startPos = false
	local function update(input)
		local delta = input.Position - dragStart
		guiObj.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = guiObj.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	dragHandle.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			update(input)
		end
	end)
end
makeDraggable(SliderFrame)
makeDraggable(ToggleButton)

-- Slider Logic
local currentDistance = START_DIST
local function setDistanceFromPercent(p)
	p = math.clamp(p, 0, 1)
	currentDistance = math.floor(MIN_DIST + (MAX_DIST - MIN_DIST) * p + 0.5)
	SliderLabel.Text = "TP Distance: "..currentDistance
	ValueLabel.Text = tostring(currentDistance)
	Fill.Size = UDim2.new(p, 0, 1, 0)
	Handle.Position = UDim2.new(p, 0, 0.5, 0)
end
setDistanceFromPercent((START_DIST - MIN_DIST) / (MAX_DIST - MIN_DIST))

local sliderDragging = false
local function updateFromInputPos(xPos)
	local barAbsPos = Bar.AbsolutePosition.X
	local barAbsSize = Bar.AbsoluteSize.X
	local rel = (xPos - barAbsPos) / barAbsSize
	setDistanceFromPercent(rel)
end
local function beginSliderDrag(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		sliderDragging = true
		updateFromInputPos(input.Position.X)
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then sliderDragging = false end
		end)
	end
end
Bar.InputBegan:Connect(beginSliderDrag)
Handle.InputBegan:Connect(beginSliderDrag)
local function continueSliderDrag(input)
	if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		updateFromInputPos(input.Position.X)
	end
end
Bar.InputChanged:Connect(continueSliderDrag)
Handle.InputChanged:Connect(continueSliderDrag)

-- Toggle
local JumpTPEnabled = false
local function updateToggleVisual()
	ToggleButton.Text = JumpTPEnabled and "ON" or "OFF"
	ToggleButton.BackgroundColor3 = JumpTPEnabled and COLOR_ON or COLOR_OFF
end
updateToggleVisual()
ToggleButton.MouseButton1Click:Connect(function()
	JumpTPEnabled = not JumpTPEnabled
	updateToggleVisual()
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = "JumpTP",
			Text = JumpTPEnabled and "Enabled" or "Disabled",
			Duration = 2
		})
	end)
end)

-- Teleport
local lastTP = 0
local function canTP()
	return (time() - lastTP) >= TELE_COOLDOWN
end
local function getForwardVector()
	if USE_CAMERA_DIR and workspace.CurrentCamera then
		return workspace.CurrentCamera.CFrame.LookVector
	end
	local hrp = getHRP()
	return hrp and hrp.CFrame.LookVector or Vector3.new(0,0,-1)
end
local function findSafeCF(hrp, dist)
	if not hrp then return end
	local origin = hrp.Position
	local dir = getForwardVector().Unit * dist
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {localPlayer.Character}
	params.FilterType = Enum.RaycastFilterType.Blacklist
	local result = workspace:Raycast(origin, dir, params)
	local targetPos = result and result.Position - dir.Unit * 3 or origin + dir
	local downResult = workspace:Raycast(targetPos + Vector3.new(0,5,0), Vector3.new(0,-50,0), params)
	if downResult then targetPos = Vector3.new(targetPos.X, downResult.Position.Y + 3, targetPos.Z) end
	return CFrame.new(targetPos, targetPos + getForwardVector())
end
local function doTeleport(dist)
	if not JumpTPEnabled then return end
	if not canTP() then return end
	local hrp = getHRP()
	if hrp then
		local safeCF = findSafeCF(hrp, dist)
		if safeCF then
			hrp.CFrame = safeCF
			lastTP = time()
		end
	end
end

-- Jump hook
UIS.JumpRequest:Connect(function()
	doTeleport(currentDistance)
end)
local function hookHumanoid()
	local hum = getHumanoid()
	if hum then
		hum.Jumping:Connect(function(active)
			if active then doTeleport(currentDistance) end
		end)
	end
end
hookHumanoid()
localPlayer.CharacterAdded:Connect(function()
	task.wait(0.2)
	hookHumanoid()
end)
