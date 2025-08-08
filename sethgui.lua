local RunService = game:GetService("RunService")

local AwesomeUIModule
if RunService:IsStudio() then
	AwesomeUIModule = require(script.Parent:WaitForChild("AwesomeUIModule"))
else
	AwesomeUIModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/sethjax/scripts/refs/heads/main/awesomeuimodule.lua"))
end

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

print(windowObjs[3])

local addItemToToolbar:BindableFunction = windowObjs.insertToolbarButton

local allPageObjs = {}

local page1Object, page1scroller = windowObjs.insertObject:Invoke({Type = "Page"})
local page2Object, page2scroller = windowObjs.insertObject:Invoke({Type = "Page"})

allPageObjs = {page1Object, page2Object}

local function SetPageEnabled(index)
	for i,v in pairs(allPageObjs) do
		v.Visible = (i == index)
	end
end

SetPageEnabled(1)

local ThisPage = page1scroller

local testOption, onvaluechangeCallback = windowObjs.insertObject:Invoke({Type = "Option", Name = "OptionTestYay"})
testOption.Parent = ThisPage

ThisPage = page2scroller

local testOption, onvaluechangeCallback = windowObjs.insertObject:Invoke({Type = "Option", Name = "OptionTestYay 2.0", onvaluechangeCallback = function(value)
	print(value)
end,})
testOption.Parent = ThisPage


addItemToToolbar:Invoke({Text = "Page 1", Button1UpCallback = function()
	SetPageEnabled(1)
end,})

addItemToToolbar:Invoke({Text = "Page 2", Button1UpCallback = function()
	SetPageEnabled(2)
end,})
