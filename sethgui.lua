local thread
thread = task.spawn(function()
	local RunService = game:GetService("RunService")
	local TweenService = game:GetService("TweenService")
	
	local Settings = _G.SethGuiScriptSettings
	if not Settings then
		_G.SethGuiScriptSettings = {}
	end

	local AwesomeUIModule
	if RunService:IsStudio() then
		AwesomeUIModule = require(script.Parent:WaitForChild("AwesomeUIModule"))
	else
		-- you can go to this link it is not obfuscated :)
		AwesomeUIModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/sethjax/scripts/refs/heads/main/awesomeuimodule.lua"))()
	end
	-----------------------------------
	type windowObjects = {NewScreenGui: ScreenGui, BackgroundFrame: Frame, insertObject: BindableFunction, removeObject: BindableFunction}

	local windowObjs: windowObjects = AwesomeUIModule.CreateWindow({
		defaultPosition = AwesomeUIModule.GetScreenMiddleCoordinates(),
		defaultSize = Vector2.new(400,320),
		backgroundFrameProperties = {
			BackgroundTransparency = .3,
		},
		themeColor = Color3.new(0.721569, 0, 0),
		nameProperty = "Seth\'s gui",
	})

	local addItemToToolbar:BindableFunction = windowObjs.insertToolbarButton

	local allPageObjs = {}

	local page1Object, page1scroller = windowObjs.insertObject({Type = "Page"})

	allPageObjs = {page1Object}

	local function SetPageEnabled(index)
		for i,v in pairs(allPageObjs) do
			v.Visible = (i == index)
		end
	end

	SetPageEnabled(1)

	local ThisPage = page1scroller
	
	local Color = Color3.new(0.584314, 0, 1)
	local colorVal = Instance.new("Color3Value")
	colorVal.Value = Color
	
	local function checkobj(obj:Instance)
		if obj:IsA("Highlight") then
			colorVal:GetPropertyChangedSignal("Value"):Connect(function()
				obj.FillColor = Color
				local h,s,v = Color:ToHSV()
				obj.OutlineColor = Color3.fromHSV(h,s,math.clamp(v-.3, 0, 1))
			end)
			obj.FillColor = Color
			local h,s,v = Color:ToHSV()
			obj.OutlineColor = Color3.fromHSV(h,s,math.clamp(v-.3, 0, 1))
		
			obj:GetPropertyChangedSignal("FillColor"):Connect(function()
				obj.FillColor = Color
			end)
			
			obj:GetPropertyChangedSignal("OutlineColor"):Connect(function()
				local h,s,v = Color:ToHSV()
				obj.OutlineColor = Color3.fromHSV(h,s,math.clamp(v-.3, 0, 1))
			end)
		end
	end
	
	game.DescendantAdded:Connect(function(desc)
		checkobj(desc)
	end)
	
	for i, v in game:GetDescendants() do
		checkobj(v)
	end

	local testOption, onvaluechangeCallback = windowObjs.insertObject({Type = "Option", Name = "Highlight Color", onvaluechangeCallback = function(value)
		local rgb = string.split(tostring(value), ",")
		local r = tonumber(rgb[1])
		local g = tonumber(rgb[2])
		local b = tonumber(rgb[3])
		
		print(rgb)
		
		Color = Color3.fromRGB(r,g,b)
		colorVal.Value = Color
	end,})
	testOption.Parent = ThisPage
	

	addItemToToolbar({Text = "Close", Button1UpCallback = function()
		task.cancel(thread)
		for i, v in game.Players.LocalPlayer.PlayerGui:GetChildren() do
			if v:HasTag("sethGui") then
				v:Destroy()
			end
		end
	end,})

	local function tabletoString(tbl:{})
		local str = ""
		for i,v in pairs(tbl) do
			str = str .. i .. " = " .. tostring(v) .. "\n"
		end
		return str
	end

	local function InitMinesweeper()
		local minesweeperWindowObjs: windowObjects = AwesomeUIModule.CreateWindow({
			defaultPosition = AwesomeUIModule.GetScreenMiddleCoordinates(),
			defaultSize = Vector2.new(400,320),
			backgroundFrameProperties = {
				BackgroundTransparency = .3,
			},
			themeColor = Color3.new(0.0980392, 0.721569, 0),
			nameProperty = "Seth\'s gui // Minesweeper 💣🚩🟥",
		})

		minesweeperWindowObjs.BackgroundFrame.Visible = false

		addItemToToolbar({Text = "Minesweeper", Button1UpCallback = function()
			minesweeperWindowObjs.BackgroundFrame.Visible = not minesweeperWindowObjs.BackgroundFrame.Visible
		end,})
		local page2Object, page2scroller = minesweeperWindowObjs.insertObject({Type = "Page"})
		local minesweeperpage, minesweeperpagescroller = minesweeperWindowObjs.insertObject({Type = "Page"})
		minesweeperpagescroller:Destroy()
		minesweeperpage.AnchorPoint = Vector2.new(.5,1)

		local aspratio = Instance.new("UIAspectRatioConstraint", minesweeperpage)
		aspratio.AspectRatio = 1
		aspratio.DominantAxis = Enum.DominantAxis.Height
		aspratio.AspectType = Enum.AspectType.ScaleWithParentSize

		local currentObjects = {}

		local minePercent = .15
		local grid = 12

		local isReloading = false

		local appearTween = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

		local function ReloadMinesweeper()
			if not isReloading then
				isReloading = true
			else
				warn("Already reloading minesweeper.")
				return
			end
			for i,v in minesweeperpage:GetChildren() do
				if not v:IsA("UIAspectRatioConstraint") then
					v:Destroy()
				end
			end

		--[[local gridLayout = Instance.new("UIGridLayout", minesweeperpage)
		gridLayout.CellSize = UDim2.new(1/grid,0,1/grid,0)]]

			currentObjects = {}

			for i = 1, grid * grid do
				currentObjects[i] = {
					x = (i-1) % grid,
					y = math.floor((i-1) / grid),
					isMine = false,
					MinesNearby = 0,
					index = i,
					isRevealed = false,
					isFlagged = false,
				}
			end

			local currentObjsNoMines = table.clone(currentObjects)
			local mineIndexes = {}

			local minecount = 0

			local MineColors = {
				[0] = { 255, 255, 255 }, -- No mines (white or background color)
				[1] = {  25, 118, 210 }, -- Blue
				[2] = {  56, 142,  60 }, -- Green
				[3] = { 211,  47,  47 }, -- Red
				[4] = { 123,  31, 162 }, -- Purple
				[5] = { 255, 143,   0 }, -- Orange
				[6] = {  0, 151, 167 }, -- Cyan
				[7] = {  85,  85,  85 }, -- Dark gray
				[8] = {   0,   0,   0 }  -- Black
			}

			local function GetAdjacentTiles(tiledata: {})
				local neighboringTiles = {}
				for i, v in pairs(currentObjects) do
					if math.abs(v.x - tiledata.x) <= 1 and math.abs(v.y - tiledata.y) <= 1 and v.index ~= tiledata.index then
						table.insert(neighboringTiles, v)
					end
				end
				return neighboringTiles
			end

			local function GetNeighboringTiles(tiledata: {})
				local neighboringTiles = {}
				for i, v in pairs(currentObjects) do
					if math.abs(v.x - tiledata.x) <= 1 and math.abs(v.y - tiledata.y) <= 1 and v.index ~= tiledata.index then
						table.insert(neighboringTiles, v)
					end
				end
				return neighboringTiles
			end

			local function invertcolor(color:Color3)
				return Color3.new(1 - color.R, 1 - color.G, 1 - color.B)
			end

			local function makeColor(tiledata)
				return Color3.fromRGB(MineColors[tiledata.MinesNearby][1],MineColors[tiledata.MinesNearby][2],MineColors[tiledata.MinesNearby][3])
			end

			local function makeBGColor(tiledata)
				local noise = math.noise(tiledata.x/32, 0, tiledata.y/32)/1.3
				local noise2 = math.noise(tiledata.x/16, 0, tiledata.y/16)

				noise = noise * noise2
				return Color3.fromHSV((((tiledata.x+tiledata.y)/30)+(noise))%1, .5, 1)
			end

			local function makeDarkColor(tiledata)
				return Color3.fromHSV(((tiledata.x+tiledata.y)/30)%1, .3, 1)
			end


			local function UpdateTile(tiledata:{})
				local tile = tiledata.tileObject

				if tiledata.isRevealed then
					if tiledata.isMine then
						tile.Text = "💣"
					else
						if tiledata.MinesNearby > 0 then
							tile.Text = tostring(tiledata.MinesNearby)
							local color = makeColor(tiledata)
							tile.TextColor3 = color
							tile.BackgroundColor3 = makeDarkColor(tiledata)
						else
							tile.Text = ""
							local color = makeColor(tiledata)
							tile.TextColor3 = color
							tile.BackgroundColor3 = makeBGColor(tiledata)

						end
					end
				else
					if tiledata.isFlagged then
						tile.Text = "🚩"
					else
						tile.Text = ""
						tile.BackgroundColor3 = Color3.new(0.678431, 0.678431, 0.678431)
					end
				end
			end

			local function CreateTile(tiledata: {})
				local tile = Instance.new("TextButton", minesweeperpage)
				tiledata.tileObject = tile
				tile.BackgroundTransparency = 1
				tile.TextTransparency = 1
				tile.Text = ""
				tile.FontFace = Font.fromName("RobotoMono", Enum.FontWeight.Bold)
				tile.FontFace.Weight = Enum.FontWeight.Bold

				tile.MouseButton1Up:Connect(function()
					if not tiledata.isFlagged and not tiledata.isRevealed then
						if tiledata.isMine then
							print("You lose!")
						else
							tiledata.isRevealed = true
							UpdateTile(tiledata)	

							local function showadj(thisTileData)
								local adj = GetAdjacentTiles(thisTileData)
								task.wait()
								for i, v in pairs(adj) do
									if (not v.isRevealed) and (not v.isFlagged) and (not v.isMine) then
										v.isRevealed = true
										UpdateTile(v)
										if v.MinesNearby == 0 then
											showadj(v)
										end
									end
								end

							end

							local Adjacent = GetAdjacentTiles(tiledata)
							for i, v in pairs(Adjacent) do
								if v.MinesNearby == 0 then
									showadj(v)
								end
							end
						end
					end
				end)

				tile.MouseButton2Up:Connect(function()
					if not tiledata.isRevealed then
						tiledata.isFlagged = not tiledata.isFlagged
						UpdateTile(tiledata)
					end
				end)

				tile:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
					tile.TextSize = tile.AbsoluteSize.X / 1.2
				end)

				tile.Position = UDim2.new(tiledata.x*1/grid, 0, tiledata.y/grid, 0)
				tile.Size = UDim2.new(1/grid, 0, 1/grid, 0)	
				tile.Parent = minesweeperpage

				UpdateTile(tiledata)

				TweenService:Create(tile, appearTween, {BackgroundTransparency = 0, TextTransparency = 0}):Play()
			end



			for i = 1, math.floor(grid * grid * minePercent) do
				local randomIndex = math.random(1, #currentObjsNoMines)
				local ind = currentObjsNoMines[randomIndex].index
				currentObjects[ind].isMine = true
				table.remove(currentObjsNoMines, randomIndex)
				table.insert(mineIndexes, ind)
			end

			for i, v in pairs(currentObjects) do
				if v.isMine then
					minecount += 1
				end
			end

			for i, v in pairs(mineIndexes) do
				local neighboring = GetNeighboringTiles(currentObjects[v])
				for i, v in pairs(neighboring) do
					if not v.isMine then
						currentObjects[v.index].MinesNearby += 1
					end
				end
			end

			for i, v in pairs(currentObjects) do
				CreateTile(v)
				if i % math.floor(#currentObjects/30) == 0 then
					task.wait()
				end
			end

			print(#currentObjects)

			isReloading = false
		end

		ReloadMinesweeper()

		minesweeperWindowObjs.insertToolbarButton({Text = "Reload", Button1UpCallback = function()
			print("retry")
			ReloadMinesweeper()
		end,})

		minesweeperWindowObjs.insertToolbarButton({Text = "Close", Button1UpCallback = function()
			print("close")
			minesweeperWindowObjs.BackgroundFrame.Visible = false
		end,})


	end

	InitMinesweeper()
end)
