local module = {}

local Player = game.Players.LocalPlayer
local mouse = Player:GetMouse()

local TextService = game:GetService('TextService')
local RunService = game:GetService("RunService")

function module.GetScreenMiddleCoordinates(): Vector2
	return Vector2.new(workspace.CurrentCamera.ViewportSize.X/2, workspace.CurrentCamera.ViewportSize.Y/2)
end

function module.CreateOption(holderFrame:Frame)

end

function module.CreateWindow(dat: {isDraggable:boolean, isResizable:boolean, nameProperty:string, defaultPosition:Vector2, defaultSize: Vector2, backgroundFrameProperties: {}, themeColor:Color3}): {NewScreenGui: ScreenGui, BackgroundFrame: Frame, insertObject: BindableFunction, removeObject: BindableFunction}
	local NewScreenGui = Instance.new("ScreenGui")
	NewScreenGui.DisplayOrder = 100000000
	NewScreenGui:GetPropertyChangedSignal("Enabled"):Connect(function()
		if not NewScreenGui.Enabled then
			NewScreenGui.Enabled = true
		end
	end)
	NewScreenGui.Enabled = true
	NewScreenGui:AddTag("sethGui")
	NewScreenGui.Name = dat.nameProperty or "genericWindow"
	NewScreenGui.IgnoreGuiInset = true

	local BackgroundFrame = Instance.new("CanvasGroup", NewScreenGui)
	BackgroundFrame.Size = UDim2.fromOffset(dat.defaultSize.X,dat.defaultSize.Y)
	BackgroundFrame.Position = UDim2.fromOffset(dat.defaultPosition.X, dat.defaultPosition.Y)
	if not dat.backgroundFrameProperties.BackgroundColor3 then
		BackgroundFrame.BackgroundColor3 = Color3.new(0.0941176, 0.0941176, 0.0941176)
	end

	local themeColor = dat.themeColor or Color3.new(0, 0.568627, 1)

	for i,v in pairs(dat.backgroundFrameProperties or {}) do
		local success, err = pcall(function()
			BackgroundFrame[i] = v
		end)
		if not success then
			warn("Error applying property: ", err, "(backgroundFrameProperties)")
		end
	end

	local UICorner = Instance.new("UICorner", BackgroundFrame)

	local Stroke = Instance.new("UIStroke", BackgroundFrame)
	Stroke.Color = BackgroundFrame.BackgroundColor3

	local Gradient = Instance.new("UIGradient", BackgroundFrame)
	Gradient.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(0.65098, 0.65098, 0.65098))
	Gradient.Rotation = 90

	--toolbar------------------------------------------------------------------------------------------------toolbar
	local topbarFrameSize = 25
	local toolbarSize = 14

	local topbarFrame = Instance.new("Frame", BackgroundFrame)

	local DragDetector = Instance.new("UIDragDetector", topbarFrame)
	DragDetector.ResponseStyle = Enum.UIDragDetectorResponseStyle.CustomOffset

	local startDragOffset = Vector2.new()
	DragDetector.DragStart:Connect(function(inputPosition)
		startDragOffset = Vector2.new(BackgroundFrame.AbsolutePosition.X - inputPosition.X, BackgroundFrame.AbsolutePosition.Y - inputPosition.Y)
		startDragOffset += Vector2.new(0,57)
	end)

	DragDetector.DragContinue:Connect(function(inputPosition)
		BackgroundFrame.Position = UDim2.fromOffset(startDragOffset.X + inputPosition.X, startDragOffset.Y + inputPosition.Y)
	end)

	topbarFrame.Interactable = true
	topbarFrame.Active = true
	topbarFrame.BackgroundColor3 = themeColor

	local topbarHolder = Instance.new("Frame", topbarFrame)

	topbarHolder.BackgroundTransparency = 1
	topbarHolder.Size = UDim2.new(1,-8,0,topbarFrameSize-5)
	topbarHolder.AnchorPoint = Vector2.new(.5,0)
	topbarHolder.Position = UDim2.new(0.5,0,0,4)

	local leftButtons = topbarHolder:Clone()
	leftButtons.Size = UDim2.new(1,0,1,0)

	local leftbtnListLayout = Instance.new("UIListLayout", leftButtons)
	leftbtnListLayout.Padding = UDim.new(0,5)
	leftbtnListLayout.FillDirection = Enum.FillDirection.Horizontal
	leftbtnListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	leftbtnListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

	local title = Instance.new("TextLabel", leftButtons)
	title.BackgroundTransparency = 1

	title.Size = UDim2.new(1,-10,1,-10)
	title.Text = dat.nameProperty or "Window"

	title.TextSize = 14
	title.TextYAlignment = Enum.TextYAlignment.Center
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Font = Enum.Font.RobotoMono

	local textsize = TextService:GetTextSize(title.Text, title.TextSize, title.Font, Vector2.new(10000,10000))
	title.Size = UDim2.new(0,textsize.X,0,textsize.Y)

	local rightButtons = topbarHolder:Clone()
	rightButtons.Size = UDim2.new(1,0,1,0)

	local rightbtnListLayout = Instance.new("UIListLayout", leftButtons)
	rightbtnListLayout.Padding = UDim.new(0,5)
	rightbtnListLayout.FillDirection = Enum.FillDirection.Horizontal
	rightbtnListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	rightbtnListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

	leftButtons.Parent = topbarHolder
	rightButtons.Parent = topbarHolder

	local corner = Instance.new("UICorner", topbarFrame)
	--corner.CornerRadius = UDim.new(0,4)

	--local stroke = Instance.new("UIStroke", topbarFrame)
	--stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	local ListLayout = Instance.new("UIListLayout", topbarHolder)
	ListLayout.FillDirection = Enum.FillDirection.Horizontal
	ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	ListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

	topbarFrame.Size = UDim2.new(1,0,0,topbarFrameSize+3+toolbarSize+3)
	topbarFrame.Position = UDim2.fromOffset(0,0)
	topbarFrame.BackgroundTransparency = 0

	--------------------------------------------------------------------

	local toolbarFrame = Instance.new("Frame", BackgroundFrame)

	local corner = Instance.new("UICorner", toolbarFrame)
	corner.CornerRadius = UDim.new(0,4)

	local stroke = Instance.new("UIStroke", toolbarFrame)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	local ListLayout = Instance.new("UIListLayout", toolbarFrame)
	ListLayout.FillDirection = Enum.FillDirection.Horizontal
	ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	ListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	ListLayout.Padding = UDim.new(0,5)


	toolbarFrame.Size = UDim2.new(1,-8,0,toolbarSize)
	toolbarFrame.Position = UDim2.fromOffset(4,topbarFrameSize+3)
	toolbarFrame.BackgroundColor3 = BackgroundFrame.BackgroundColor3
	toolbarFrame.BackgroundTransparency = 0

	

	local InsertToolbarButton = function(dat: {Text:string, Button1UpCallback: RBXScriptConnection})
		local newbutton = Instance.new("TextButton")
		newbutton.Text = dat.Text or "Toolbar Button"
		newbutton.BackgroundColor3 = BackgroundFrame.BackgroundColor3
		newbutton.TextSize = toolbarSize-2
		newbutton.Font = Enum.Font.RobotoMono
		newbutton.TextColor3 = themeColor

		local hoverHighlight = Instance.new("UIStroke")
		hoverHighlight.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		hoverHighlight.Color = themeColor

		newbutton.MouseEnter:Connect(function()
			hoverHighlight.Parent = newbutton
		end)

		newbutton.MouseLeave:Connect(function()
			hoverHighlight.Parent = nil
		end)


		--local stroke = Instance.new("UIStroke", newbutton)
		--stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		local corner = Instance.new("UICorner", newbutton)
		corner.CornerRadius = UDim.new(0,4)

		newbutton.MouseButton1Up:Connect(function()
			if dat.Button1UpCallback then
				dat.Button1UpCallback()
			end
		end)

		local textsize = TextService:GetTextSize(dat.Text, newbutton.TextSize, newbutton.Font, Vector2.new(1000,1000))
		newbutton.Size = UDim2.new(0,textsize.X+6,0,textsize.Y)

		newbutton.Parent = toolbarFrame
	end

	--toolbar------------------------------------------------------------------------------------------------toolbar

	

	local insertObject = function(dat: {Type:string})
		if not dat.Type then
			warn("No type specified")
			return
		end
		if dat.Type == "Toolbar" then
			return nil
		elseif dat.Type == "Page" then
			local holderFrame = Instance.new("Frame",BackgroundFrame)
			holderFrame.Parent = BackgroundFrame
			holderFrame.AnchorPoint = Vector2.new(.5,1)
			holderFrame.Position = UDim2.new(.5,0,1,-4)
			holderFrame.Size = UDim2.new(1,-8,1,-(topbarFrame.Size.Y.Offset + 8))
			holderFrame.BackgroundTransparency = 0
			holderFrame.BackgroundColor3 = Color3.new(0.101961, 0.101961, 0.101961)

			local corner = Instance.new("UICorner", holderFrame)
			corner.CornerRadius = UDim.new(0,10)

			local Scroller = Instance.new("ScrollingFrame", holderFrame)
			Scroller.Size = UDim2.new(1,0,1,0)
			Scroller.ScrollBarThickness = 0
			Scroller.BackgroundTransparency = 1

			local ListLayout = Instance.new("UIListLayout", Scroller)
			ListLayout.FillDirection = Enum.FillDirection.Vertical
			ListLayout.Padding = UDim.new(0,3)

			ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				Scroller.CanvasSize = UDim2.new(0,0,0,ListLayout.AbsoluteContentSize.Y)
			end)

			local Padding = Instance.new("UIPadding", Scroller)
			Padding.PaddingLeft = UDim.new(0,4)
			Padding.PaddingRight = UDim.new(0,4)
			Padding.PaddingTop = UDim.new(0,4)
			Padding.PaddingBottom = UDim.new(0,4)
			
			return holderFrame, Scroller
		elseif dat.Type == "Option" then
			local newOptionFrame = Instance.new("Frame")
			newOptionFrame.Size = UDim2.new(1,0,0,23)
			newOptionFrame.BackgroundColor3 = Color3.new(0.223529, 0.203922, 0.215686)

			local corner = Instance.new("UICorner", newOptionFrame)
			corner.CornerRadius = UDim.new(0,4)

			local newLabel = Instance.new("TextLabel", newOptionFrame)
			newLabel.Position = UDim2.fromOffset(7,0)
			newLabel.Font = Enum.Font.RobotoMono
			newLabel.Size = UDim2.new(.5,0,1,0)
			newLabel.TextColor3 = Color3.new(1, 1, 1)
			newLabel.BackgroundTransparency = 1
			newLabel.TextSize = 13
			newLabel.TextXAlignment = Enum.TextXAlignment.Left
			newLabel.TextYAlignment = Enum.TextYAlignment.Center

			newLabel.Text = dat.Name or "Option (no name?)"

			local textBox = Instance.new("TextBox", newOptionFrame)
			textBox.AnchorPoint = Vector2.new(1,.5)
			textBox.Position = UDim2.new(1,-2,.5,0)
			textBox.Size = UDim2.new(.5,0,1,-4)
			textBox.BackgroundColor3 = Color3.new(0.141176, 0.141176, 0.141176)
			textBox.TextColor3 = Color3.new(1, 1, 1)
			textBox.Text = ""
			textBox.TextSize = 13
			textBox.ClearTextOnFocus = false

			local corner = Instance.new("UICorner", textBox)
			corner.CornerRadius = UDim.new(0,2)

			if dat.onvaluechangeCallback then
				textBox.FocusLost:Connect(function()
					dat.onvaluechangeCallback(textBox.Text)
				end)
			end

			textBox.Font = Enum.Font.RobotoMono
			textBox.PlaceholderText = "Input value..."

			return newOptionFrame
		else
			return nil
		end
	end

	local removeObject = Instance.new("BindableEvent")


	NewScreenGui.Parent = Player.PlayerGui

	return {NewScreenGui = NewScreenGui, BackgroundFrame = BackgroundFrame, insertObject = insertObject, removeObject = removeObject, insertToolbarButton = InsertToolbarButton}
end

return module
