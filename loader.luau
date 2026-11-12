repeat
	task.wait()
until game:IsLoaded()

local cloneref = cloneref or function(Input)
	return Input
end

local CoreGui = cloneref(game:GetService("CoreGui"))
local HttpService = cloneref(game:GetService("HttpService"))
local RunService = cloneref(game:GetService("RunService"))
local TextService = cloneref(game:GetService("TextService"))
local TweenService = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local Workspace = cloneref(game:GetService("Workspace"))

local InstanceNew = Instance.new

local IsMobile = UserInputService.TouchEnabled and (not UserInputService.KeyboardEnabled or not UserInputService.MouseEnabled)

local GameId = tostring(game.GameId)

local Directory = "solixhub"
local Folders = {"/Configs", "/Themes", "/Fonts", "/Luas", "/Assets", "/Images", "/polsec"}

local Request = request or http_request or (syn and syn.request)

local FontFaces = {
	SemiBold = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
}

local FontCatalog = {
	["Inter"] = {
		Id = "InterSemibold.ttf",
		Url = "https://raw.githubusercontent.com/sametexe001/luas/main/fonts/InterSemibold.ttf",
		Weight = 200,
		Style = "normal"
	},
}

local LogoFiles = {
	Accent = {
		Name = "solix-logo-accent.png",
		Data = "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"
	},
	Base = {
		Name = "solix-logo.png",
		Data = "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"
	},
}
local function DecodeBase64(Input)
	local Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	local Values = {}
	local Bytes = {}
	local Bits, Count = 0, 0

	for Index = 1, 64 do
		Values[string.byte(Alphabet, Index)] = Index - 1
	end

	for Index = 1, #Input do
		local Value = Values[string.byte(Input, Index)]

		if Value then
			Bits = Bits * 64 + Value
			Count += 6

			if Count >= 8 then
				Count -= 8
				Bytes[#Bytes + 1] = string.char(math.floor(Bits / 2 ^ Count) % 256)
				Bits %= 2 ^ Count
			end
		end
	end

	return table.concat(Bytes)
end

local function GetLogoAssets()
	assert(type(getcustomasset) == "function", "Solix Hub requires getcustomasset for the logo")

	local Assets = {}

	for Index, Value in LogoFiles do
		local Path = Directory .. "/Images/" .. Value.Name
		local Data = DecodeBase64(Value.Data)

		if not isfile(Path)
			or readfile(Path) ~= Data
		then
			writefile(Path, Data)
		end

		Assets[Index] = getcustomasset(Path)
	end

	return Assets
end

local function PrepareWorkspace()
	assert(isfolder and makefolder and isfile and readfile and writefile, "Solix Hub requires executor filesystem support")

	if not isfolder(Directory) then
		makefolder(Directory)
	end

	for Index, Value in Folders do
		local Path = Directory .. Value

		if not isfolder(Path) then
			makefolder(Path)
		end
	end

	for Index, Value in {"Autoload.txt", "ThemeAutoload.txt"} do
		local Path = Directory .. "/" .. Value

		if not isfile(Path) then
			writefile(Path, "")
		end
	end
end

local function CacheFont(Input1, Input2)
	local Path = Directory .. "/Fonts/" .. Input2.Id

	if not isfile(Path) then
		if not Input2.Url then return end

		local Source = game:HttpGet(Input2.Url)
		assert(type(Source) == "string" and #Source > 4, "Empty font: " .. Input1)

		local Signature = Source:sub(1, 4)
		assert(Signature == "\0\1\0\0" or Signature == "OTTO" or Signature == "ttcf" or Signature == "true", "Invalid font: " .. Input1)

		writefile(Path, Source)
	end

	if not getcustomasset then return end

	local Family = {
		name = Input1,
		faces = {
			{
				name = "Regular",
				weight = Input2.Weight,
				style = Input2.Style,
				assetId = getcustomasset(Path),
			}
		},
	}

	writefile(Directory .. "/Fonts/" .. Input1 .. ".font", HttpService:JSONEncode(Family))
end

local GameList = {
	["578392296"] = { Id = "9c36af272e9edcab", Keyless = false }, -- ABA
	["10770933473"] = { Id = "570960567ae9ee68", Keyless = false }, -- Anime Eyes
	["10512942223"] = { Id = "578395010f8c4716", Keyless = false }, -- Anime Zero
	["4658598196"] = { Id = "086646721d0da59e", Keyless = false }, -- Attack on Titan Revolution
	["4777817887"] = { Id = "cf1e81c5fb14d3bc", Keyless = false }, -- Blade Ball
	["994732206"] = { Id = "ce2e40f0bc2b1720", Keyless = false }, -- Blox Fruits
	["10769957062"] = { Id = "f7a5694f13d13f89", Keyless = false }, -- Bug Evolution
	["10767386157"] = { Id = "22068f1924bfbd48", Keyless = false }, -- Chop A Forest
	["648454481"] = { Id = "a873ec9f40a25c5c", Keyless = false }, -- Grand Piece Online
	["66654135"] = { Id = "e45bba6c0dc08fad", Keyless = false }, -- Murder Mystery 2
	["10035204815"] = { Id = "85a577643f806078", Keyless = false }, -- Ride A Pet
	["6035872082"] = { Id = "9d318b57c43ebd9d", Keyless = false }, -- Rivals
	["7219654364"] = { Id = "b056f96b43a4a4e2", Keyless = false }, -- Sheriff VS Murderer
	["1511883870"] = { Id = "5ac16739ff2ef735", Keyless = false }, -- Shindo Life
	["5595353122"] = { Id = "d7305ba1bbb3bd7b", Keyless = false }, -- Slayers 2
	["10563114921"] = { Id = "d3b0a2eaf4a1522a", Keyless = false }, -- Steal An Egg
	["1946714362"] = { Id = "2f231342cca70549", Keyless = false }, -- Bloodlines

	-- Universal Games
	["504035427"] = { Id = "52eedbdc867c3387", Keyless = false }, -- Zombie Attack
	["111958650"] = { Id = "52eedbdc867c3387", Keyless = false }, -- Arsenal
	["10769552054"] = { Id = "52eedbdc867c3387", Keyless = false }, -- Urban Reload
	["10769850944"] = { Id = "52eedbdc867c3387", Keyless = false }, -- KOBALT / DROPZONE
	["73885730"] = { Id = "52eedbdc867c3387", Keyless = false }, -- Prison Life
	["6765805766"] = { Id = "52eedbdc867c3387", Keyless = false }, -- BlockSpin
	["5091490171"] = { Id = "52eedbdc867c3387", Keyless = false }, -- Jailbird
	["4750561026"] = { Id = "52eedbdc867c3387", Keyless = false }, -- Cold War
	["10767708641"] = { Id = "52eedbdc867c3387", Keyless = false }, -- Pistol Duels
	["6993600665"] = { Id = "52eedbdc867c3387", Keyless = false }, -- Defusal
	["10750223358"] = { Id = "52eedbdc867c3387", Keyless = false }, -- ZHD
	["5000084391"] = { Id = "52eedbdc867c3387", Keyless = false }, -- Decay
	["1281592938"] = { Id = "52eedbdc867c3387", Keyless = false }, -- ENTRENCHED
	["8468366390"] = { Id = "52eedbdc867c3387", Keyless = false }, -- Infected Lands
	["3021395192"] = { Id = "52eedbdc867c3387", Keyless = false }, -- RiotFall
	["6583326485"] = { Id = "52eedbdc867c3387", Keyless = false }, -- Ground War
	["5995470825"] = { Id = "52eedbdc867c3387", Keyless = false }, -- Hypershot
	["9534705677"] = { Id = "52eedbdc867c3387", Keyless = false }, -- Arcade
	["10138624079"] = { Id = "52eedbdc867c3387", Keyless = false }, -- Arena
	["9294074907"] = { Id = "52eedbdc867c3387", Keyless = false }, -- [FPS] One Tap
	["10057403337"] = { Id = "52eedbdc867c3387", Keyless = false }, -- Deagle Arena
	["7633926880"] = { Id = "52eedbdc867c3387", Keyless = false }, -- BloxStrike
}

local SdkUrl = "https://api.polsec.net/sdk"
local LoaderBaseUrl = "https://api.polsec.net/loader"

local Config = {
	DiscordUrl = "https://discord.gg/solixhub",
	KeyFile = "solixhub/polsec/license.key.json",
	KeyUrl = "https://solixhub.com/free/get-key",
	ProjectId = "7d45ec1510769529",
	ShopUrl = "https://solixhub.com/free",
}

local ErrorMessages = {
	enter_a_key = "Enter a key",
	error = "Something broke. Join Discord for help.",
	hwid_mismatch = "HWID not valid! Reset HWID on the panel.",
	invalid_executor = "Your executor isnt supported.",
	invalid_fingerprint = "HWID not valid! Reset HWID on the panel.",
	invalid_key = "Wrong key. Check it and try again.",
	invalid_script_id = "Script not found.",
	key_banned = "This key is banned. Join Discord for help.",
	key_blacklisted = "This key is banned. Join Discord for help.",
	key_disabled = "This key is disabled. Join Discord for help.",
	key_expired = "Your key is expired!",
	key_hwid_locked = "HWID not valid! Reset HWID on the panel.",
	key_incorrect = "Wrong key. Check it and try again.",
	key_invalid = "That doesnt look like a key.",
	network_error = "Could not reach license server. Try again.",
	rate_limited = "Too many tries. Wait a bit and try again.",
	script_id_incorrect = "Script not found.",
	script_id_invalid = "Script deleted.",
	security_error = "Something went wrong. Try again.",
	time_error = "Fix your PC clock and try again.",
	unknown_error = "Something broke. Join Discord for help.",
}

if getgenv().SolixKeyUIUnload then
	getgenv().SolixKeyUIUnload()
end

local Theme = {
	Accent = Color3.fromRGB(209, 37, 109),
	Background = Color3.fromRGB(14, 13, 14),
	Danger = Color3.fromRGB(255, 72, 72),
	HighContrast = Color3.fromRGB(78, 72, 84),
	Inactive = Color3.fromRGB(118, 116, 122),
	LowContrast = Color3.fromRGB(33, 29, 36),
	OtherBackgrounds = Color3.fromRGB(36, 32, 39),
	Outline = Color3.fromRGB(41, 37, 45),
	Placeholder = Color3.fromRGB(185, 185, 185),
	SectionBackground = Color3.fromRGB(22, 20, 24),
	TextColor = Color3.fromRGB(255, 255, 255),
	Unselected = Color3.fromRGB(165, 164, 165),
	Warning = Color3.fromRGB(255, 196, 64),
}

local Gradients = {
	Bar = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(135, 135, 135)),
	Button = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(227, 227, 227)),
	Element = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(227, 223, 229)),
	Fill = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(176, 176, 176)),
	Panel = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(215, 215, 215)),
}

local Animation = {
	Duration = 0.4,
	EasingStyle = Enum.EasingStyle.Exponential,
}

local Connections = {}
local ActiveTweens = setmetatable({}, {__mode = "k"})
local Closed = false
local Closing = false
local Validating = false

local Notifications = {}
local NotificationIndex = 0
local NotificationOnly = true
local ScreenGui

local SetIdentity = setthreadidentity or setidentity or setthreadcontext
local GetIdentity = getthreadidentity or getidentity or getthreadcontext

local function RunCallback(Input, ...)
	local Identity = GetIdentity and GetIdentity() or 2

	if SetIdentity then
		SetIdentity(8)
	end

	local Success, Error = pcall(Input, ...)

	if SetIdentity then
		SetIdentity(Identity)
	end

	if not Success then
		warn("[Solix Hub] UI callback failed: " .. tostring(Error))
	end
end

local function Connect(Input1, Input2)
	local Connection = Input1:Connect(function(...)
		if Closed then return end

		RunCallback(Input2, ...)
	end)

	table.insert(Connections, Connection)
	return Connection
end

local Tweens = {} do
	Tweens.__index = Tweens

	Tweens.Create = function(self, Item, Info, Goal, RawItem)
		Item = RawItem and Item or Item.Instance

		local Previous = ActiveTweens[Item]

		if Previous then
			Previous:Destroy()
		end

		Info = Info or TweenInfo.new(Animation.Duration, Animation.EasingStyle, Enum.EasingDirection.Out)

		local NewTween = setmetatable({
			Goal = Goal,
			Info = Info,
			Item = Item,
			Tween = TweenService:Create(Item, Info, Goal),
		}, Tweens)

		ActiveTweens[Item] = NewTween

		NewTween.Tween:Play()
		return NewTween
	end

	Tweens.Wait = function(self)
		self.Tween.Completed:Wait()
		return self
	end

	Tweens.Pause = function(self)
		self.Tween:Pause()
		return self
	end

	Tweens.Resume = function(self)
		self.Tween:Play()
		return self
	end

	Tweens.Cancel = function(self)
		if not self.Tween then return self end

		self.Tween:Cancel()

		if ActiveTweens[self.Item] == self then
			ActiveTweens[self.Item] = nil
		end

		return self
	end

	Tweens.Destroy = function(self)
		if not self.Tween then return end

		self:Cancel()
		self.Tween:Destroy()

		self.Item = nil
		self.Tween = nil
	end
end

local Instances = {} do
	Instances.__index = Instances

	Instances.Create = function(self, Class, Properties)
		local NewItem = setmetatable({Instance = InstanceNew(Class)}, Instances)

		if NewItem.Instance:IsA("GuiObject") then
			NewItem.Instance.BorderSizePixel = 0
		end

		if NewItem.Instance:IsA("TextLabel")
			or NewItem.Instance:IsA("TextButton")
			or NewItem.Instance:IsA("TextBox")
		then
			NewItem.Instance.FontFace = FontFaces.SemiBold
			NewItem.Instance.TextColor3 = Theme.TextColor
			NewItem.Instance.TextSize = 15
		end

		if NewItem.Instance:IsA("GuiButton") then
			NewItem.Instance.AutoButtonColor = false
		end

		for Index, Value in Properties do
			if Index ~= "Parent" then
				NewItem.Instance[Index] = Value
			end
		end

		NewItem.Instance.Name = "\0"
		NewItem.Instance.Parent = Properties.Parent
		return NewItem
	end

	Instances.Connect = function(self, Event, Callback)
		if IsMobile
			and (Event == "MouseButton1Down"
				or Event == "MouseButton1Click")
		then
			Event = "TouchTap"
		end

		return Connect(self.Instance[Event], Callback)
	end

	Instances.Tweens = function(self, Info, Goal)
		return Tweens:Create(self, Info, Goal)
	end

	Instances.Clean = function(self)
		if not self.Instance then return end

		local Previous = ActiveTweens[self.Instance]

		if Previous then
			Previous:Destroy()
		end

		self.Instance:Destroy()

		self.Instance = nil
	end
end

local function PreloadFonts()
	task.spawn(function()
		for Index, Value in FontFaces do
			local Params = Instances:Create("GetTextBoundsParams", {
				Font = Value,
				Size = 15,
				Text = "Ag",
				Width = 1000,
			})

			pcall(TextService.GetTextBoundsAsync, TextService, Params.Instance)
			Params:Clean()
		end
	end)

	task.spawn(function()
		for Index, Value in FontCatalog do
			if not Value.Url
				and not isfile(Directory .. "/Fonts/" .. Value.Id)
			then
				continue
			end

			local Success, Error = pcall(CacheFont, Index, Value)

			if not Success then
				warn("[Solix Hub] Font cache failed: " .. tostring(Error))
			end
		end
	end)
end

local function Box(Input1, Input2, Input3)
	Instances:Create("UICorner", {Parent = Input1.Instance, CornerRadius = UDim.new(0, Input2 and 6 or 4)})

	Instances:Create("UIGradient", {
		Parent = Input1.Instance,
		Rotation = 90,
		Color = Input2 and Gradients.Panel or Input3 and Gradients.Fill or Gradients.Element,
	})

	Instances:Create("UIShadow", {
		Parent = Input1.Instance,
		BlurRadius = UDim.new(0, 20),
		Transparency = Input2 and 0.82 or 0.86,
	})

	if Input3 then
		local Glow = Instances:Create("UIShadow", {
			Parent = Input1.Instance,
			BlurRadius = UDim.new(0, 10),
			Color = Theme.Accent,
			Transparency = 0.85,
		})
		return nil, Glow
	end

	local Stroke = Instances:Create("UIStroke", {
		Parent = Input1.Instance,
		ApplyStrokeMode = Input2 and Enum.ApplyStrokeMode.Contextual or Enum.ApplyStrokeMode.Border,
		BorderOffset = UDim.new(0, Input2 and 0 or -1),
		Color = Theme.Outline,
		Transparency = 0.5,
	})

	if not Input2 then
		Instances:Create("UIStroke", {
			Parent = Input1.Instance,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			BorderOffset = UDim.new(0, -2),
			Color = Theme.Outline,
			Transparency = 0.88,
		})
	end

	return Stroke
end

local function Cleanup()
	if Closed then return end

	Closed = true

	for Index, Value in Connections do
		Value:Disconnect()
	end

	table.clear(Connections)

	for Index, Value in ActiveTweens do
		Value:Destroy()
	end

	table.clear(ActiveTweens)

	if ScreenGui then
		ScreenGui:Clean()
	end

	if getgenv().SolixKeyUIUnload == Cleanup then
		getgenv().SolixKeyUIUnload = nil
	end
end

getgenv().SolixKeyUIUnload = Cleanup

local UIParent = CoreGui

if gethui then
	local Success, Result = pcall(gethui)

	if Success
		and Result
	then
		UIParent = Result
	end
end

ScreenGui = Instances:Create("ScreenGui", {
	Parent = UIParent,
	DisplayOrder = 999,
	ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})

local function GetAvailableSize()
	local Size = ScreenGui.Instance.AbsoluteSize
	local Camera = Workspace.CurrentCamera

	if Camera then
		local Viewport = Camera.ViewportSize
		Size = Vector2.new(math.min(Viewport.X, Size.X), math.min(Viewport.Y, Size.Y))
	end

	local Width = math.max(1, Size.X)
	local Height = math.max(1, Size.Y)
	local KeyboardPosition = UserInputService.OnScreenKeyboardPosition
	local KeyboardSize = UserInputService.OnScreenKeyboardSize

	if UserInputService.OnScreenKeyboardVisible
		and KeyboardPosition.Y > 0
		and KeyboardSize.Y > 0
	then
		Height = math.min(Height, math.max(1, KeyboardPosition.Y - ScreenGui.Instance.AbsolutePosition.Y))
	end

	return Vector2.new(Width, Height)
end

local function Notify(Input)
	if Closed then return end

	NotificationIndex += 1

	local Width = IsMobile and math.min(260, math.max(1, GetAvailableSize().X - 32)) or 260
	local Duration = Input.Duration or 3

	local Canvas = Instances:Create("CanvasGroup", {
		Parent = ScreenGui.Instance,
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.fromOffset(-Width - 40, IsMobile and 8 or 120),
		Size = UDim2.fromOffset(Width + 40, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		GroupTransparency = 1,
		ZIndex = 100,
	})

	Instances:Create("UIPadding", {
		Parent = Canvas.Instance,
		PaddingTop = UDim.new(0, 20),
		PaddingBottom = UDim.new(0, 20),
		PaddingLeft = UDim.new(0, 20),
		PaddingRight = UDim.new(0, 20),
	})

	local Panel = Instances:Create("Frame", {
		Parent = Canvas.Instance,
		Size = UDim2.fromOffset(Width, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.SectionBackground,
	})
	Box(Panel, true)

	Instances:Create("UIPadding", {
		Parent = Panel.Instance,
		PaddingTop = UDim.new(0, 9),
		PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
	})

	Instances:Create("UIListLayout", {
		Parent = Panel.Instance,
		Padding = UDim.new(0, 9),
		SortOrder = Enum.SortOrder.LayoutOrder
	})

	local Body = Instances:Create("Frame", {
		Parent = Panel.Instance,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 1,
	})

	Instances:Create("UIListLayout", {
		Parent = Body.Instance,
		ItemLineAlignment = Enum.ItemLineAlignment.Stretch,
		Padding = UDim.new(0, 8),
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local Accent = Instances:Create("Frame", {
		Parent = Body.Instance,
		BackgroundColor3 = Theme.Accent,
		Size = UDim2.fromOffset(3, 0),
		LayoutOrder = 1
	})

	Instances:Create("UICorner", {Parent = Accent.Instance, CornerRadius = UDim.new(1, 0)})

	Instances:Create("UIGradient", {
		Parent = Accent.Instance,
		Rotation = 90,
		Color = Gradients.Bar
	})

	Instances:Create("UIShadow", {
		Parent = Accent.Instance,
		BlurRadius = UDim.new(0, 10),
		Color = Theme.Accent,
		Transparency = 0.85
	})

	local Info = Instances:Create("Frame", {
		Parent = Body.Instance,
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 2
	})

	Instances:Create("UIFlexItem", {Parent = Info.Instance, FlexMode = Enum.UIFlexMode.Fill})

	Instances:Create("UIListLayout", {
		Parent = Info.Instance,
		Padding = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder
	})

	Instances:Create("TextLabel", {
		Parent = Info.Instance,
		Text = Input.Title or "Solix Hub",
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		LayoutOrder = 1,
	})

	if Input.Description then
		Instances:Create("TextLabel", {
			Parent = Info.Instance,
			Text = Input.Description,
			TextSize = 13,
			TextColor3 = Theme.Unselected,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 0, 0),
			LayoutOrder = 2,
		})
	end

	local Track = Instances:Create("Frame", {
		Parent = Panel.Instance,
		BackgroundColor3 = Theme.OtherBackgrounds,
		Size = UDim2.new(1, 0, 0, 3),
		LayoutOrder = 2
	})

	Instances:Create("UICorner", {Parent = Track.Instance, CornerRadius = UDim.new(1, 0)})

	local Fill = Instances:Create("Frame", {
		Parent = Track.Instance,
		BackgroundColor3 = Theme.Accent,
		Size = UDim2.fromScale(1, 1)
	})

	Instances:Create("UICorner", {Parent = Fill.Instance, CornerRadius = UDim.new(1, 0)})

	Instances:Create("UIGradient", {Parent = Fill.Instance, Color = Gradients.Fill})

	Instances:Create("UIShadow", {
		Parent = Fill.Instance,
		BlurRadius = UDim.new(0, 10),
		Color = Theme.Accent,
		Transparency = 0.85
	})

	local Notification = {
		Canvas = Canvas,
		Index = NotificationIndex,
		Panel = Panel,
		Status = true,
		Tick = tick(),
		Duration = Duration,
	}
	table.insert(Notifications, Notification)

	Fill:Tweens(TweenInfo.new(Duration, Enum.EasingStyle.Linear), {Size = UDim2.fromScale(0, 1)})
	return Notification
end

Connect(RunService.Heartbeat, function()
	local Now = tick()
	local Offset = 0
	local Top = IsMobile and 8 or 120
	local NotificationWidth

	if IsMobile
		and #Notifications > 0
	then
		NotificationWidth = math.min(260, math.max(1, GetAvailableSize().X - 32))
	end

	for Index = #Notifications, 1, -1 do
		local Notification = Notifications[Index]

		if Now - Notification.Tick >= Notification.Duration + 1.25 then
			Notification.Canvas:Clean()
			table.remove(Notifications, Index)
		end
	end

	for Index, Notification in Notifications do
		if NotificationWidth
			and Notification.Panel.Instance.Size.X.Offset ~= NotificationWidth
		then
			Notification.Panel.Instance.Size = UDim2.fromOffset(NotificationWidth, 0)
			Notification.Canvas.Instance.Size = UDim2.fromOffset(NotificationWidth + 40, 0)
		end

		local Visible = Now - Notification.Tick < Notification.Duration
		local Width = math.max(Notification.Canvas.Instance.AbsoluteSize.X, 1)

		if Notification.Status ~= Visible
			or Notification.Offset ~= Offset
			or Notification.Positioned ~= true
		then
			Notification.Status = Visible
			Notification.Offset = Offset
			Notification.Positioned = true

			Notification.Canvas:Tweens(TweenInfo.new(1, Animation.EasingStyle, Enum.EasingDirection.Out), {
				Position = UDim2.fromOffset(Visible and -4 or -Width, Top + Offset),
				GroupTransparency = Visible and 0 or 1,
			})
		end

		if Visible then
			Offset += Notification.Panel.Instance.AbsoluteSize.Y + 8
		end
	end

	if NotificationOnly
		and NotificationIndex > 0
		and #Notifications == 0
	then
		Cleanup()
	end
end)

local GameConfig = GameList[GameId]

if not GameConfig then
	Notify({
		Title = "Solix Hub",
		Description = "This game is not supported.",
		Duration = 5
	})
	return
end

PrepareWorkspace()
PreloadFonts()

local ScriptId = GameConfig.Id
local IsKeyless = GameConfig.Keyless

local ProjectId = type(Config.ProjectId) == "string" and Config.ProjectId or ""

if type(getgenv().PolSec_ProjectId) == "string"
	and getgenv().PolSec_ProjectId ~= ""
then
	ProjectId = getgenv().PolSec_ProjectId
end

if ProjectId == "" then
	Notify({
		Title = "Solix Hub",
		Description = "Set Config.ProjectId to your PolSec project ID.",
		Duration = 5
	})
	return
end

LowUnc = not (hookfunction and hookmetamethod)

local function DeleteFile(Input)
	if delfile
		and isfile(Input)
	then
		delfile(Input)
	end
end

local PolSec

local function GetSDK()
	if PolSec then return PolSec end

	local Chunk, Error = loadstring(game:HttpGet(SdkUrl))
	assert(Chunk, Error)

	local SDK = Chunk()
	assert(type(SDK) == "table" and type(SDK.check_key) == "function", "License SDK unavailable")
	SDK.script_id = ScriptId

	PolSec = SDK
	return SDK
end

local LoaderUrl = LoaderBaseUrl .. "/" .. ProjectId .. "/" .. ScriptId

local function ReadJson(Input)
	if not isfile
		or not readfile
		or not isfile(Input)
	then
		return nil
	end

	local Success, Source = pcall(readfile, Input)

	if not Success
		or type(Source) ~= "string"
		or Source == ""
	then
		return nil
	end

	local Decoded, Data = pcall(HttpService.JSONDecode, HttpService, Source)

	if not Decoded
		or type(Data) ~= "table"
	then
		return nil
	end

	return Data
end

local function LoadSavedKey()
	local Current = ReadJson(Config.KeyFile)

	if Current
		and type(Current.key) == "string"
		and Current.key ~= ""
	then
		local ExpiresAt = tonumber(Current.expires_at)

		if not ExpiresAt
			or ExpiresAt <= 0
			or ExpiresAt >= os.time()
		then
			return Current.key
		end

		DeleteFile(Config.KeyFile)
	end

	local LegacyPaths = {
		"solixhub/savedkey.txt",
		"solixhub/license_key.json",
		"solixhub.com/polsec/license.key.json",
	}

	for Index = 1, #LegacyPaths do
		local LegacyPath = LegacyPaths[Index]

		if isfile
			and isfile(LegacyPath)
			and readfile
		then
			local Success, Source = pcall(readfile, LegacyPath)

			if Success
				and type(Source) == "string"
				and Source:gsub("%s", "") ~= ""
			then
				local Key

				if Index ~= 1 then
					local Decoded, Data = pcall(HttpService.JSONDecode, HttpService, Source)
					Key = Decoded and type(Data) == "table" and Data.key or nil
				else
					Key = Source:gsub("^%s+", ""):gsub("%s+$", "")
				end

				if type(Key) == "string"
					and Key ~= ""
				then
					local Saved = pcall(writefile, Config.KeyFile, HttpService:JSONEncode({
						key = Key,
						saved_at = os.time(),
					}))

					if Saved
						and delfile
					then
						pcall(delfile, LegacyPath)
					end

					return Key
				end
			end
		end
	end

	return nil
end

local function SaveKey(Input1, Input2)
	if type(writefile) ~= "function" then return false end

	local Success = pcall(writefile, Config.KeyFile, HttpService:JSONEncode({
		key = Input1,
		note = Input2 and Input2.Note or nil,
		discord_id = Input2 and Input2.DiscordId or nil,
		expires_at = Input2 and Input2.ExpiresAt or nil,
		saved_at = os.time(),
	}))

	return Success
end

local function ApplyKey(Input1, Input2)
	script_key = Input1
	getgenv().script_key = Input1
	getgenv().key = Input1
	getgenv().PolSec_Note = Input2 and Input2.Note or nil
	getgenv().PolSec_Key_Note = Input2 and Input2.Note or nil
	getgenv().PolSec_Expiry = Input2 and Input2.ExpiresAt or nil
	getgenv().PolSec_UserId = Input2 and Input2.DiscordId or nil
	getgenv().PolSec_Discord_Id = Input2 and Input2.DiscordId and tostring(Input2.DiscordId) or nil
	getgenv().polsec_script_id = ScriptId
	getgenv().key_expire = Input2 and Input2.ExpiresAt or 0
	getgenv().key_note = Input2 and Input2.Note or ""

	SaveKey(Input1, Input2)
end

local function PrepareGame()
	local Source = game:HttpGet(LoaderUrl)

	local Chunk, Error = loadstring(Source)
	assert(Chunk, Error)
	return Chunk
end

local function LoadGame()
	PrepareGame()()
end

local function PolSecErrorMessage(Input1, Input2, Input3)
	local Code = type(Input1) == "string" and string.lower(Input1) or "unknown_error"

	if ErrorMessages[Code] then
		return ErrorMessages[Code]
	end

	if type(Input2) == "string"
		and Input2 ~= ""
	then
		local MessageCode = string.lower(Input2)

		if ErrorMessages[MessageCode] then
			return ErrorMessages[MessageCode]
		end
	end

	if type(Input3) == "table"
		and type(Input3.blacklist_reason) == "string"
		and Input3.blacklist_reason ~= ""
	then
		return Input3.blacklist_reason
	end

	return ErrorMessages.unknown_error
end

local function CheckKey(Input)
	Input = type(Input) == "string" and Input:gsub("^%s+", ""):gsub("%s+$", "") or ""
	if Input == "" then return false, ErrorMessages.enter_a_key end

	local Success, Result = pcall(function()
		return GetSDK().check_key(Input)
	end)

	if not Success
		or type(Result) ~= "table"
	then
		return false, ErrorMessages.network_error, nil, "network_error"
	end

	if Result.status ~= "key_valid" then
		local User = type(Result.user) == "table" and Result.user or nil
		return false, PolSecErrorMessage(Result.status, Result.message, User), nil, Result.status
	end

	local User = type(Result.user) == "table" and Result.user or {}

	return true, {
		AdKey = User.ad_key == true,
		DiscordId = User.discord_id or User.discordId,
		ExpiresAt = User.key_expires,
		Note = User.note,
	}, Input
end

local AttributionUrl = "https://solixhub.com/api/free-key/first-game"

local function ReportFirstGame(Input)
	if not Request then return end

	task.spawn(function()
		pcall(Request, {
			Url = AttributionUrl,
			Method = "POST",
			Headers = {["Content-Type"] = "application/json"},
			Body = HttpService:JSONEncode({
				key = Input,
				gameId = GameId,
				placeId = tostring(game.PlaceId),
				scriptId = ScriptId,
			}),
		})
	end)
end

if IsKeyless then
	script_key = "trail"
	getgenv().script_key = "trail"
	getgenv().polsec_script_id = ScriptId

	local Loaded, Error = pcall(LoadGame)

	if Loaded then
		Cleanup()
	else
		warn("[Solix Hub] Script failed: " .. tostring(Error))
		Notify({Description = "Script failed to start. Check the executor console.", Duration = 5})
	end

	return
end

local function TrySilent(Input)
	local Success, Data, NormalizedKey, Status = CheckKey(Input)

	if not Success then
		return false, Status
	end

	ApplyKey(NormalizedKey, Data)
	ReportFirstGame(NormalizedKey)

	local Prepared, Chunk = pcall(PrepareGame)

	if not Prepared then
		return false, "network_error"
	end

	local Loaded, Error = pcall(Chunk)

	if not Loaded then
		warn("[Solix Hub] Script failed: " .. tostring(Error))
		return false, "network_error"
	end

	Cleanup()
	return true
end

local function IsPlaceholderKey(Input)
	local Value = type(Input) == "string" and Input:gsub("^%s+", ""):gsub("%s+$", ""):lower() or ""
	return Value == "" or Value == "trial" or Value == "trail"
end

local SavedKey = LoadSavedKey()

local InitialKey = getgenv().script_key

if IsPlaceholderKey(InitialKey) then
	InitialKey = script_key
end

if IsPlaceholderKey(InitialKey) then
	InitialKey = SavedKey
end

if not IsPlaceholderKey(InitialKey) then
	local Loaded, Status = TrySilent(InitialKey)

	if Loaded then
		return
	end

	if SavedKey
		and InitialKey == SavedKey
		and Status ~= "network_error"
		and Status ~= "rate_limited"
	then
		DeleteFile(Config.KeyFile)
	end

	InitialKey = nil
end

NotificationOnly = false

local PanelWidth = 360
local Padding = IsMobile and 12 or 16
local ButtonHeight = IsMobile and 44 or 36
local ContentWidth = PanelWidth - Padding * 2
local HalfWidth = (ContentWidth - 10) / 2
local PanelHeight = IsMobile and 300 or 282

local Main = Instances:Create("CanvasGroup", {
	Parent = ScreenGui.Instance,
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(PanelWidth, PanelHeight),
	BackgroundColor3 = Theme.Background,
	GroupTransparency = 1,
})
Box(Main, true)

local Scale = Instances:Create("UIScale", {Parent = Main.Instance, Scale = 1})

local Header = Instances:Create("Frame", {
	Parent = Main.Instance,
	Active = true,
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(Padding, Padding),
	Size = UDim2.new(1, -Padding * 2, 0, 40),
})

local LogoAssets = GetLogoAssets()
local Logo = Instances:Create("ImageLabel", {
	Parent = Header.Instance,
	BackgroundTransparency = 1,
	Size = UDim2.fromOffset(40, 40),
	Image = LogoAssets.Base,
})
Instances:Create("ImageLabel", {
	Parent = Logo.Instance,
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
	Image = LogoAssets.Accent,
	ImageColor3 = Theme.Accent,
})

Instances:Create("TextLabel", {
	Parent = Header.Instance,
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(180, 24),
	Text = "solixhub.com",
	TextColor3 = Theme.TextColor,
	TextSize = 16,
})

local CloseButton = Instances:Create("TextButton", {
	Parent = Header.Instance,
	AnchorPoint = Vector2.new(1, 0.5),
	BackgroundTransparency = 1,
	Position = UDim2.fromScale(1, 0.5),
	Size = UDim2.fromOffset(IsMobile and 44 or 24, IsMobile and 44 or 24),
	Text = "X",
	TextColor3 = Theme.Unselected,
	TextSize = 20,
})

local KeyBox = Instances:Create("Frame", {
	Parent = Main.Instance,
	BackgroundColor3 = Theme.OtherBackgrounds,
	Position = UDim2.fromOffset(Padding, 70),
	Size = UDim2.new(1, -Padding * 2, 0, ButtonHeight),
})
Box(KeyBox)

local KeyInput = Instances:Create("TextBox", {
	Parent = KeyBox.Instance,
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(10, 0),
	Size = UDim2.new(1, -20, 1, 0),
	Text = "",
	TextSize = IsMobile and 16 or 15,
	PlaceholderText = "Paste your key here",
	PlaceholderColor3 = Theme.Placeholder,
	TextXAlignment = Enum.TextXAlignment.Left,
	ClearTextOnFocus = false,
})

local ContinueButton = Instances:Create("TextButton", {
	Parent = Main.Instance,
	Position = UDim2.fromOffset(Padding, 116),
	Size = UDim2.new(1, -Padding * 2, 0, ButtonHeight),
	BackgroundColor3 = Theme.Accent,
	Text = "Continue",
	TextSize = 15,
})
Box(ContinueButton, false, true)

local GetKeyButton = Instances:Create("TextButton", {
	Parent = Main.Instance,
	Position = UDim2.fromOffset(Padding, 162),
	Size = UDim2.fromOffset(HalfWidth, ButtonHeight),
	BackgroundColor3 = Theme.OtherBackgrounds,
	Text = "Get Key",
	TextSize = 15,
})
Box(GetKeyButton)

local SkipKeyButton = Instances:Create("TextButton", {
	Parent = Main.Instance,
	Position = UDim2.fromOffset(Padding + HalfWidth + 10, 162),
	Size = UDim2.fromOffset(HalfWidth, ButtonHeight),
	BackgroundColor3 = Theme.OtherBackgrounds,
	Text = "Skip Key",
	TextSize = 15,
})
Box(SkipKeyButton)

local JoinDiscordButton = Instances:Create("TextButton", {
	Parent = Main.Instance,
	Position = UDim2.fromOffset(Padding, 208),
	Size = UDim2.new(1, -Padding * 2, 0, ButtonHeight),
	BackgroundColor3 = Theme.OtherBackgrounds,
	Text = "Join Discord",
	TextSize = 15,
})
Box(JoinDiscordButton)

local function CloseUI(Input)
	if Closed or Closing then return end

	Closing = true
	ContinueButton.Instance.Active = false

	local Fade = Main:Tweens(TweenInfo.new(Animation.Duration, Animation.EasingStyle, Enum.EasingDirection.In), {GroupTransparency = 1})
	Connect(Fade.Tween.Completed, function(State)
		if State ~= Enum.PlaybackState.Completed then return end

		if Input then
			Main.Instance.Visible = false
			Input()
		else
			Cleanup()
		end
	end)
end

local function CopyLink(Input1, Input2)
	local Success = setclipboard and pcall(setclipboard, Input1)
	Notify({Description = Success and Input2 or "Open this link: " .. Input1})
end

local function Submit()
	if Closed or Closing or Validating then return end

	Validating = true
	ContinueButton.Instance.Text = "Checking..."
	ContinueButton.Instance.Active = false

	local Success, Valid, Data, NormalizedKey = pcall(CheckKey, KeyInput.Instance.Text)

	if not Success or not Valid then
		Validating = false
		ContinueButton.Instance.Text = "Continue"
		ContinueButton.Instance.Active = true
		Notify({Description = Success and Data or ErrorMessages.network_error, Duration = 5})
		return
	end

	ApplyKey(NormalizedKey, Data)
	ReportFirstGame(NormalizedKey)
	ContinueButton.Instance.Text = "Loading..."

	local Prepared, Chunk = pcall(PrepareGame)

	if not Prepared then
		Validating = false
		ContinueButton.Instance.Text = "Continue"
		ContinueButton.Instance.Active = true
		Notify({Description = "Could not load the script. Your key is saved; try again.", Duration = 5})
		return
	end

	CloseUI(function()
		local Loaded, Error = pcall(Chunk)

		if not Loaded then
			warn("[Solix Hub] Script failed: " .. tostring(Error))
		end
	end)
end

ContinueButton:Connect("Activated", Submit)
KeyInput:Connect("FocusLost", function(Input)
	if Input then Submit() end
end)
GetKeyButton:Connect("Activated", function()
	CopyLink(Config.KeyUrl, "Key link copied. Paste it in your browser.")
end)
SkipKeyButton:Connect("Activated", function()
	CopyLink(Config.ShopUrl, "Buy link copied. Open it to skip ads and get a key.")
end)
JoinDiscordButton:Connect("Activated", function()
	CopyLink(Config.DiscordUrl, "Discord invite copied.")
end)
CloseButton:Connect("Activated", CloseUI)

if type(InitialKey) == "string"
	and InitialKey ~= ""
then
	KeyInput.Instance.Text = InitialKey
end

local function AnimateButton(Input)
	Input:Connect("MouseEnter", function()
		if Closed then return end

		Input:Tweens(nil, {TextColor3 = Theme.Accent})
	end)

	Input:Connect("MouseLeave", function()
		if Closed then return end

		Input:Tweens(nil, {TextColor3 = Theme.TextColor})
	end)

	Input:Connect("Activated", function()
		if Closed or Closing then return end

		local Fill = Instances:Create("Frame", {
			Parent = Input.Instance,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Theme.Accent,
			ClipsDescendants = true,
			ZIndex = 2,
		})
		Instances:Create("UICorner", {Parent = Fill.Instance, CornerRadius = UDim.new(0, 4)})
		Instances:Create("UIGradient", {Parent = Fill.Instance, Rotation = 90, Color = Gradients.Element})
		Instances:Create("TextLabel", {
			Parent = Fill.Instance,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = Input.Instance.Text,
			TextColor3 = Theme.Background,
			ZIndex = 3,
		})

		local Press = Fill:Tweens(TweenInfo.new(Animation.Duration * 1.25, Animation.EasingStyle, Enum.EasingDirection.InOut), {Size = UDim2.fromScale(0, 1)})
		Press.Tween.Completed:Connect(function(State)
			if State == Enum.PlaybackState.Completed then
				Fill:Clean()
			end
		end)
	end)
end

AnimateButton(ContinueButton)
AnimateButton(GetKeyButton)
AnimateButton(SkipKeyButton)
AnimateButton(JoinDiscordButton)

local DragOutline = Instances:Create("Frame", {
	Parent = ScreenGui.Instance,
	AnchorPoint = Main.Instance.AnchorPoint,
	Size = Main.Instance.Size,
	BackgroundTransparency = 1,
	Visible = false,
	ZIndex = 99999,
})
Instances:Create("UICorner", {Parent = DragOutline.Instance, CornerRadius = UDim.new(0, 6)})
Instances:Create("UIStroke", {Parent = DragOutline.Instance, Color = Theme.Accent, Thickness = 1})

local DragSnapLineH = Instances:Create("Frame", {
	Parent = ScreenGui.Instance,
	BackgroundColor3 = Theme.Accent,
	BackgroundTransparency = 0.35,
	BorderSizePixel = 0,
	Visible = false,
	ZIndex = 99998,
})
local DragSnapLineV = Instances:Create("Frame", {
	Parent = ScreenGui.Instance,
	BackgroundColor3 = Theme.Accent,
	BackgroundTransparency = 0.35,
	BorderSizePixel = 0,
	Visible = false,
	ZIndex = 99998,
})

local Dragging = false
local DragStart
local DragPosition
local LastDragPosition
local DragConnection

local function UpdateDragSnap(Input)
	local Viewport = Workspace.CurrentCamera.ViewportSize
	local Center = Viewport / 2
	local Position = Vector2.new(
		Input.X.Scale * Viewport.X + Input.X.Offset,
		Input.Y.Scale * Viewport.Y + Input.Y.Offset
	)
	local SnapX = math.abs(Position.X - Center.X) <= 10
	local SnapY = math.abs(Position.Y - Center.Y) <= 10

	DragSnapLineH.Instance.Visible = SnapY
	DragSnapLineV.Instance.Visible = SnapX

	if SnapY then
		DragSnapLineH.Instance.Position = UDim2.fromOffset(0, Center.Y)
		DragSnapLineH.Instance.Size = UDim2.fromOffset(Viewport.X, 1)
	end

	if SnapX then
		DragSnapLineV.Instance.Position = UDim2.fromOffset(Center.X, 0)
		DragSnapLineV.Instance.Size = UDim2.fromOffset(1, Viewport.Y)
	end

	return UDim2.fromOffset(
		SnapX and Center.X or Position.X,
		SnapY and Center.Y or Position.Y
	)
end

Header:Connect("InputBegan", function(Input)
	if Input.UserInputType ~= Enum.UserInputType.MouseButton1
		and Input.UserInputType ~= Enum.UserInputType.Touch
	then
		return
	end

	if Closing then return end

	Dragging = true
	DragStart = Input.Position
	DragPosition = Main.Instance.Position
	LastDragPosition = DragPosition
	DragOutline.Instance.Position = DragPosition
	DragOutline.Instance.Size = Main.Instance.Size
	DragOutline.Instance.Visible = true

	if DragConnection then
		DragConnection:Disconnect()
	end

	DragConnection = Connect(Input.Changed, function()
		if Input.UserInputState ~= Enum.UserInputState.End then return end

		Dragging = false
		DragOutline.Instance.Visible = false
		DragSnapLineH.Instance.Visible = false
		DragSnapLineV.Instance.Visible = false

		if DragConnection then
			DragConnection:Disconnect()
			DragConnection = nil
		end

		Main:Tweens(nil, {Position = LastDragPosition})
	end)
end)

Connect(UserInputService.InputChanged, function(Input)
	if not Dragging then return end

	if Input.UserInputType == Enum.UserInputType.MouseMovement
		or Input.UserInputType == Enum.UserInputType.Touch
	then
		local Delta = Input.Position - DragStart
		local Position = UDim2.new(
			DragPosition.X.Scale,
			DragPosition.X.Offset + Delta.X,
			DragPosition.Y.Scale,
			DragPosition.Y.Offset + Delta.Y
		)
		local Snapped = UpdateDragSnap(Position)

		LastDragPosition = UDim2.fromOffset(Snapped.X.Offset, Snapped.Y.Offset)
		DragOutline:Tweens(TweenInfo.new(Animation.Duration * 0.5, Animation.EasingStyle, Enum.EasingDirection.Out), {Position = LastDragPosition})
	end
end)

CloseButton:Connect("MouseEnter", function()
	CloseButton:Tweens(nil, {TextColor3 = Theme.TextColor})
end)
CloseButton:Connect("MouseLeave", function()
	CloseButton:Tweens(nil, {TextColor3 = Theme.Unselected})
end)

Main:Tweens(nil, {GroupTransparency = 0})
