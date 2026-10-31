repeat task.wait() until game:IsLoaded()

if LPH_OBFUSCATED == nil then
	LPH_NO_VIRTUALIZE = function(...) return (...) end
	LPH_ENCSTR = function(...) return (...) end
	LRM_SANITIZE = function(...) return ... end
end

local cloneref = cloneref or function(Object) return Object end

local Services = setmetatable({}, {
	__index = function(self, Name)
		local Service = cloneref(game:GetService(Name))
		rawset(self, Name, Service)
		return Service
	end,
})

local TweenService = Services.TweenService
local Players = Services.Players
local HttpService = Services.HttpService
local StarterGui = Services.StarterGui
local Camera = Services.Workspace.CurrentCamera

if identifyexecutor and identifyexecutor() == "Wave" then
	getgenv().gethui = function()
		return game:GetService("CoreGui")
	end
end

local Folder_Configs = {
	Directory = "solixhub/premium",
	Assets = "solixhub/premium/Assets",
	Configs = "solixhub/premium/Configs",
	Datas = "solixhub/premium/Datas",
	Images = "solixhub/premium/Images",
	Themes = "solixhub/premium/Themes",
}

if type(isfolder) == "function" and type(makefolder) == "function" then
	if not isfolder("solixhub") then
		makefolder("solixhub")
	end

	for _, Folder in Folder_Configs do
		if not isfolder(Folder) then
			makefolder(Folder)
		end
	end
end

local GameId = tostring(game.GameId)
local GameConfigFolder = Folder_Configs.Configs .. "/" .. GameId

if type(isfolder) == "function" and type(makefolder) == "function" and not isfolder(GameConfigFolder) then
	makefolder(GameConfigFolder)
end

local GameList = {
	["6035872082"] = { id = "7b7c5f40255d98f1", keyless = false }, -- Rivals
    ["10768172922"] = { id = "38c18cedb5717030", keyless = false }, -- RoWorld
	
}

local SdkUrl = "https://api.polsec.net/sdk"
local LoaderBase = "https://api.polsec.net/loader"

local Config = {
	Title = "SolixHub Premium",
	Subtitle = "Paste your key to continue",
	Placeholder = "Enter your key...",
	Logo = "rbxassetid://126242837118656",

	ProjectId = "67c1c4c6288eb465",
	CheckScriptId = "",
	File = "solixhub/premium/license.key.json",
	Discord = "https://discord.gg/solixhub",
	Shop = "https://solixhub.com/premium",
}

local ErrorMessages = {
	key_expired = "Your key is expired!",
	key_blacklisted = "This key is banned. Join Discord for help.",
	key_banned = "This key is banned. Join Discord for help.",
	invalid_fingerprint = "HWID not valid! Reset HWID on the panel.",
	key_hwid_locked = "HWID not valid! Reset HWID on the panel.",
	hwid_mismatch = "HWID not valid! Reset HWID on the panel.",
	invalid_key = "Wrong key. Check it and try again.",
	key_incorrect = "Wrong key. Check it and try again.",
	key_invalid = "That doesnt look like a key.",
	invalid_script_id = "Script not found.",
	script_id_incorrect = "Script not found.",
	script_id_invalid = "Script deleted.",
	invalid_executor = "Your executor isnt supported.",
	security_error = "Something went wrong. Try again.",
	time_error = "Fix your PC clock and try again.",
	key_disabled = "This key is disabled. Join Discord for help.",
	rate_limited = "Too many tries. Wait a bit and try again.",
	error = "Something broke. Join Discord for help.",
	unknown_error = "Something broke. Join Discord for help.",
	enter_a_key = "Enter a key",
	network_error = "Could not reach license server. Try again.",
}

if type(isfolder) == "function" and type(makefolder) == "function" then
	if not isfolder("solixhub/premium") then
		pcall(makefolder, "solixhub/premium")
	end
end

local function CoreNotify(Text)
	warn("[SolixHub Premium] " .. tostring(Text))
	task.spawn(function()
		for _ = 1, 5 do
			local Ok = pcall(function()
				StarterGui:SetCore("SendNotification", {
					Title = "Solix Hub",
					Text = Text,
					Icon = "rbxassetid://137698471325689",
					Duration = 5,
				})
			end)
			if Ok then
				return
			end
			task.wait(0.5)
		end
	end)
end

local function Fetch(Url)
	if typeof(request) == "function" then
		local Ok, Response = pcall(request, {
			Url = Url,
			Method = "GET",
		})

		if Ok and type(Response) == "table" and type(Response.Body) == "string" and Response.Body ~= "" then
			local Code = tonumber(Response.StatusCode) or 200
			if Code >= 200 and Code < 300 then
				return Response.Body
			end
		end
	end

	return game:HttpGet(Url)
end

local GameConfig = GameList[GameId]

if not GameConfig then
	CoreNotify("This game is not supported. GameId: " .. GameId)
	return
end

local ScriptId = GameConfig.id
local IsKeyless = GameConfig.keyless

local ProjectId = type(Config.ProjectId) == "string" and Config.ProjectId or ""
if type(getgenv().PolSec_ProjectId) == "string" and getgenv().PolSec_ProjectId ~= "" then
	ProjectId = getgenv().PolSec_ProjectId
end

if ProjectId == "" then
	CoreNotify("Set Config.ProjectId to your PolSec project ID.")
	return
end

LowUnc = not (hookfunction and hookmetamethod)

local function DeleteFile(Input)
	if isfile and isfile(Input) and delfile then
		delfile(Input)
	end
end

local PolSec
local PolSecFail
local CheckScriptId = type(Config.CheckScriptId) == "string" and Config.CheckScriptId ~= "" and Config.CheckScriptId or ScriptId
local LoaderUrl = LoaderBase .. "/" .. ProjectId .. "/" .. ScriptId

local function EnsurePolSec()
	if PolSec then
		return true
	end

	if PolSecFail then
		return false, PolSecFail
	end

	local Ok, Result = pcall(function()
		local Body = Fetch(SdkUrl)
		assert(type(Body) == "string" and Body ~= "", "empty sdk response")
		local Chunk = assert(loadstring(Body), "failed to compile sdk")
		local Sdk = Chunk()
		assert(type(Sdk) == "table" and type(Sdk.check_key) == "function", "invalid sdk")
		return Sdk
	end)

	if not Ok or type(Result) ~= "table" then
		PolSecFail = tostring(Result)
		return false, PolSecFail
	end

	PolSec = Result
	PolSec.script_id = CheckScriptId
	return true
end

local function ReadJson(Path)
	if not isfile or not readfile or not isfile(Path) then
		return nil
	end

	local Ok, Raw = pcall(readfile, Path)
	if not Ok or type(Raw) ~= "string" or Raw == "" then
		return nil
	end

	local Decoded, Data = pcall(HttpService.JSONDecode, HttpService, Raw)
	if not Decoded or type(Data) ~= "table" then
		return nil
	end

	return Data
end

local function LoadSavedKey()
	local LegacyPaths = {
		"solixhub/savedkey.txt",
		"solixhub/license_key.json",
		"solixhub.com/polsec/license.key.json",
	}

	for Index = 1, #LegacyPaths do
		local LegacyPath = LegacyPaths[Index]
		if isfile and isfile(LegacyPath) and readfile then
			local Ok, Raw = pcall(readfile, LegacyPath)
			if Ok and type(Raw) == "string" and Raw:gsub("%s", "") ~= "" then
				local Key
				if Index ~= 1 then
					local Decoded, Data = pcall(HttpService.JSONDecode, HttpService, Raw)
					Key = Decoded and type(Data) == "table" and Data.key or nil
				else
					Key = Raw:gsub("^%s+", ""):gsub("%s+$", "")
				end

				if type(Key) == "string" and Key ~= "" then
					pcall(writefile, Config.File, HttpService:JSONEncode({
						key = Key,
						saved_at = os.time(),
					}))
					pcall(delfile, LegacyPath)
					return Key
				end
			end
		end
	end

	local Data = ReadJson(Config.File)
	if not Data or type(Data.key) ~= "string" or Data.key == "" then
		return nil
	end

	local Expires = tonumber(Data.expires_at)
	if Expires and Expires > 0 and Expires < os.time() then
		DeleteFile(Config.File)
		return nil
	end

	return Data.key
end

local function SaveKey(Key, Data)
	if not writefile then
		return
	end

	if type(isfolder) == "function" and type(makefolder) == "function" and not isfolder("solixhub/premium") then
		pcall(makefolder, "solixhub/premium")
	end

	pcall(writefile, Config.File, HttpService:JSONEncode({
		key = Key,
		note = Data and Data.note or nil,
		discord_id = Data and Data.discord_id or nil,
		expires_at = Data and Data.expires_at or nil,
		saved_at = os.time(),
	}))
end

local function ApplyKey(Key, Data)
	script_key = Key
	getgenv().script_key = Key
	getgenv().key = Key
	getgenv().PolSec_Note = Data and Data.note or nil
	getgenv().PolSec_Key_Note = Data and Data.note or nil
	getgenv().PolSec_Expiry = Data and Data.expires_at or nil
	getgenv().PolSec_UserId = Data and Data.discord_id or nil
	getgenv().PolSec_Discord_Id = Data and Data.discord_id and tostring(Data.discord_id) or nil
	getgenv().polsec_script_id = ScriptId
	getgenv().key_expire = Data and Data.expires_at or 0
	getgenv().key_note = Data and Data.note or ""
	SaveKey(Key, Data)
end

local function LoadGame()
	local Body = Fetch(LoaderUrl)
	assert(type(Body) == "string" and Body ~= "", "empty loader response")
	local Chunk = assert(loadstring(Body), "failed to compile loader")
	Chunk()
end

local function PolSecErrorMessage(Status, Message, User)
	local Code = type(Status) == "string" and string.lower(Status) or "unknown_error"
	if ErrorMessages[Code] then
		return ErrorMessages[Code]
	end

	if type(Message) == "string" and Message ~= "" then
		local Lower = string.lower(Message)
		if ErrorMessages[Lower] then
			return ErrorMessages[Lower]
		end
	end

	if type(User) == "table" and type(User.blacklist_reason) == "string" and User.blacklist_reason ~= "" then
		return User.blacklist_reason
	end

	return ErrorMessages.unknown_error
end

local function CheckKey(Key)
	Key = type(Key) == "string" and Key:gsub("^%s+", ""):gsub("%s+$", "") or ""
	if Key == "" then
		return false, ErrorMessages.enter_a_key
	end

	local Ready, ReadyErr = EnsurePolSec()
	if not Ready then
		return false, "License SDK failed: " .. tostring(ReadyErr)
	end

	local Ok, Result = pcall(PolSec.check_key, Key)
	if not Ok or type(Result) ~= "table" then
		return false, ErrorMessages.network_error
	end

	if Result.status ~= "key_valid" then
		local User = type(Result.user) == "table" and Result.user or nil
		return false, PolSecErrorMessage(Result.status, Result.message, User)
	end

	local User = type(Result.user) == "table" and Result.user or {}
	return true, {
		note = User.note,
		expires_at = User.key_expires,
		discord_id = User.discord_id or User.discordId,
		ad_key = User.ad_key == true,
	}, Key
end

local function ToTime(Expires)
	if not Expires or Expires <= 0 then
		return "Lifetime"
	end

	local Left = Expires - os.time()
	if Left < 0 then
		return "Expired"
	end

	local Days = math.floor(Left / 86400)
	local Hours = math.floor((Left % 86400) / 3600)
	local Minutes = math.floor((Left % 3600) / 60)
	local Seconds = Left % 60

	if Days > 0 then
		return string.format("%dd %dh %dm", Days, Hours, Minutes)
	elseif Hours > 0 then
		return string.format("%dh %dm %ds", Hours, Minutes, Seconds)
	elseif Minutes > 0 then
		return string.format("%dm %ds", Minutes, Seconds)
	end

	return string.format("%ds", Seconds)
end

local function TrySilent(Key)
	local Ok, Data, Normalized = CheckKey(Key)
	if not Ok then
		return false
	end

	ApplyKey(Normalized, Data)
	LoadGame()
	return true
end

local SavedInitial = LoadSavedKey()
local Initial = getgenv().script_key
if type(Initial) ~= "string" or Initial == "" then
	Initial = script_key
end
if type(Initial) ~= "string" or Initial == "" then
	Initial = SavedInitial
end

if IsKeyless then
	script_key = "trail"
	getgenv().script_key = "trail"
	getgenv().polsec_script_id = ScriptId
	task.spawn(function()
		local Ok, Err = pcall(LoadGame)
		if not Ok then
			CoreNotify("Failed to load script: " .. tostring(Err))
		end
	end)
	return
end

-- UI
local Pos = UDim2.new
local Offset = UDim2.fromOffset
local White = Color3.fromRGB(255, 255, 255)

local Font = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
local CloseImage = "rbxassetid://83582143495297"

local Preset = {
	Background = Color3.fromRGB(14, 13, 14),
	SectionBackground = Color3.fromRGB(22, 20, 24),
	OtherBackgrounds = Color3.fromRGB(36, 32, 39),
	Outline = Color3.fromRGB(41, 37, 45),
	Unselected = Color3.fromRGB(165, 164, 165),
	TextColor = White,
	Accent = Color3.fromRGB(209, 37, 109),
	Danger = Color3.fromRGB(255, 72, 72),
}

local Gradient = function(Bottom)
	return ColorSequence.new{ColorSequenceKeypoint.new(0, White), ColorSequenceKeypoint.new(1, Bottom)}
end

local Gradients = {
	Element = Gradient(Color3.fromRGB(227, 223, 229)),
	Button = Gradient(Color3.fromRGB(227, 227, 227)),
	Panel = Gradient(Color3.fromRGB(215, 215, 215)),
	Fill = Gradient(Color3.fromRGB(176, 176, 176)),
	Bar = Gradient(Color3.fromRGB(135, 135, 135)),
	LineCenter = NumberSequence.new{NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.25, 0), NumberSequenceKeypoint.new(0.75, 0), NumberSequenceKeypoint.new(1, 1)},
}

local Speed = 0.4
local Easing = Enum.EasingStyle.Exponential

local Connections = {}
local Notifications = {}

local Create = function(Class, Options)
	local Object = Instance.new(Class)

	if Object:IsA("GuiObject") then
		Object.BackgroundColor3 = White
		Object.BorderSizePixel = 0
	end

	if Object:IsA("GuiButton") then
		Object.AutoButtonColor = false
	end

	if Class == "TextLabel" or Class == "TextBox" or Class == "TextButton" then
		Object.FontFace = Font
		Object.TextSize = 15
		Object.TextColor3 = Preset.TextColor
		Object.RichText = true
		Object.Text = ""
	end

	for Property, Value in Options do
		if Property ~= "Parent" then
			Object[Property] = Value
		end
	end

	Object.Name = "\0"
	Object.Parent = Options.Parent

	return Object
end

local Tween = function(Object, Properties, Info)
	local Animation = TweenService:Create(Object, Info or TweenInfo.new(Speed, Easing, Enum.EasingDirection.Out), Properties)
	Animation:Play()
	return Animation
end

local Connect = function(Signal, Callback)
	local Connection = Signal:Connect(Callback)
	table.insert(Connections, Connection)
	return Connection
end

local OnClick = function(Object, Callback)
	Connect(Object.InputBegan, function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			Callback()
		end
	end)
end

local Rich = function(Text)
	return (string.gsub(tostring(Text or ""), "<accent>(.-)</accent>", function(Inner)
		return string.format('<font color="#%s">%s</font>', Preset.Accent:ToHex(), Inner)
	end))
end

local GetParent = function()
	local Ok, CoreGui = pcall(function()
		local Gui = Services.CoreGui
		local _ = Gui:GetChildren()
		return Gui
	end)

	if Ok and CoreGui then
		return CoreGui
	end

	return Players.LocalPlayer:WaitForChild("PlayerGui")
end

local Gui = Create("ScreenGui", {Parent = GetParent(); ZIndexBehavior = Enum.ZIndexBehavior.Sibling; IgnoreGuiInset = true; ResetOnSpawn = false; DisplayOrder = 100})

if protectgui then
	pcall(protectgui, Gui)
elseif syn and syn.protect_gui then
	pcall(syn.protect_gui, Gui)
end

local SoftCreate = function(Class, Options)
	local Ok, Object = pcall(Create, Class, Options)
	return Ok and Object or nil
end

local Panel = function(Object)
	Create("UICorner", {Parent = Object; CornerRadius = UDim.new(0, 6)})
	Create("UIGradient", {Parent = Object; Rotation = 90; Color = Gradients.Panel})
	Create("UIStroke", {Parent = Object; ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual; Color = Preset.Outline; Transparency = 0.5})
	SoftCreate("UIShadow", {Parent = Object; BlurRadius = UDim.new(0, 20); Transparency = 0.82})
end

local NotifPadding = 20
local NotifMargin = 16
local NotifSpacing = 8

local Restack = function()
	local Y = 0

	for _, Notif in Notifications do
		if Notif.Visible then
			Tween(Notif.Canvas, {Position = Pos(0, NotifPadding - NotifMargin, 0, 140 - NotifPadding + Y), GroupTransparency = 0}, TweenInfo.new(1, Easing, Enum.EasingDirection.Out))
			Y += Notif.Frame.AbsoluteSize.Y + NotifSpacing
		end
	end
end

local Notify = function(Data)
	local Notif = {Visible = true}

	Notif.Canvas = Create("CanvasGroup", {Parent = Gui; GroupTransparency = 1; BackgroundTransparency = 1; AutomaticSize = Enum.AutomaticSize.XY; ZIndex = 100})
	Create("UIPadding", {Parent = Notif.Canvas; PaddingTop = UDim.new(0, NotifPadding); PaddingBottom = UDim.new(0, NotifPadding); PaddingRight = UDim.new(0, NotifPadding); PaddingLeft = UDim.new(0, NotifPadding)})

	local Frame = Create("Frame", {Parent = Notif.Canvas; BackgroundColor3 = Preset.SectionBackground; Size = Pos(0, 260, 0, 0); AutomaticSize = Enum.AutomaticSize.Y})
	Panel(Frame)
	Create("UIPadding", {Parent = Frame; PaddingTop = UDim.new(0, 9); PaddingBottom = UDim.new(0, 10); PaddingRight = UDim.new(0, 10); PaddingLeft = UDim.new(0, 10)})
	Create("UIListLayout", {Parent = Frame; Padding = UDim.new(0, 9); SortOrder = Enum.SortOrder.LayoutOrder})
	Notif.Frame = Frame

	local Body = Create("Frame", {Parent = Frame; LayoutOrder = 1; BackgroundTransparency = 1; Size = Pos(1, 0, 0, 0); AutomaticSize = Enum.AutomaticSize.Y})
	Create("UIListLayout", {Parent = Body; ItemLineAlignment = Enum.ItemLineAlignment.Stretch; Padding = UDim.new(0, 8); FillDirection = Enum.FillDirection.Horizontal; SortOrder = Enum.SortOrder.LayoutOrder})

	local Accent = Create("Frame", {Parent = Body; LayoutOrder = 1; BackgroundColor3 = Preset.Accent; Size = Pos(0, 3, 0, 0)})
	Create("UICorner", {Parent = Accent; CornerRadius = UDim.new(1, 0)})
	SoftCreate("UIShadow", {Parent = Accent; BlurRadius = UDim.new(0, 10); Color = Preset.Accent; Transparency = 0.85})
	Create("UIGradient", {Parent = Accent; Rotation = 90; Color = Gradients.Bar})

	local Info = Create("Frame", {Parent = Body; LayoutOrder = 2; BackgroundTransparency = 1; Size = Pos(1, -11, 0, 0); AutomaticSize = Enum.AutomaticSize.Y})
	SoftCreate("UIFlexItem", {Parent = Info; FlexMode = Enum.UIFlexMode.Fill})
	Create("UIListLayout", {Parent = Info; Padding = UDim.new(0, 2); SortOrder = Enum.SortOrder.LayoutOrder})
	Create("TextLabel", {Parent = Info; LayoutOrder = 1; Text = Rich(Data.Title); TextXAlignment = Enum.TextXAlignment.Left; TextWrapped = true; BackgroundTransparency = 1; Size = Pos(1, 0, 0, 0); AutomaticSize = Enum.AutomaticSize.Y})

	if Data.Description then
		Create("TextLabel", {Parent = Info; LayoutOrder = 2; Text = Rich(Data.Description); TextSize = 13; TextColor3 = Preset.Unselected; TextXAlignment = Enum.TextXAlignment.Left; TextWrapped = true; BackgroundTransparency = 1; Size = Pos(1, 0, 0, 0); AutomaticSize = Enum.AutomaticSize.Y})
	end

	local Track = Create("Frame", {Parent = Frame; LayoutOrder = 2; BackgroundColor3 = Preset.OtherBackgrounds; Size = Pos(1, 0, 0, 3)})
	Create("UICorner", {Parent = Track; CornerRadius = UDim.new(1, 0)})
	local Fill = Create("Frame", {Parent = Track; BackgroundColor3 = Preset.Accent; Size = Pos(1, 0, 1, 0)})
	Create("UICorner", {Parent = Fill; CornerRadius = UDim.new(1, 0)})
	Create("UIGradient", {Parent = Fill; Color = Gradients.Fill})
	SoftCreate("UIShadow", {Parent = Fill; BlurRadius = UDim.new(0, 10); Color = Preset.Accent; Transparency = 0.85})

	local Duration = Data.Duration or 3

	table.insert(Notifications, Notif)

	task.defer(function()
		Notif.Canvas.Position = Pos(0, -Notif.Canvas.AbsoluteSize.X, 0, 140 - NotifPadding)
		Notif.Canvas.GroupTransparency = 0
		Tween(Fill, {Size = Pos(0, 0, 1, 0)}, TweenInfo.new(Duration, Enum.EasingStyle.Linear))
		Restack()
	end)

	task.delay(Duration, function()
		Notif.Visible = false
		Tween(Notif.Canvas, {Position = Pos(0, -Notif.Canvas.AbsoluteSize.X, 0, Notif.Canvas.Position.Y.Offset), GroupTransparency = 1}, TweenInfo.new(1, Easing, Enum.EasingDirection.Out))
		Restack()

		task.wait(1.25)

		table.remove(Notifications, table.find(Notifications, Notif))
		Notif.Canvas:Destroy()
	end)
end

local Items = {}

Items.Holder = Create("CanvasGroup", {Parent = Gui; GroupTransparency = 0; BackgroundTransparency = 1; AutomaticSize = Enum.AutomaticSize.XY; ZIndex = 10})
Create("UIPadding", {Parent = Items.Holder; PaddingTop = UDim.new(0, 20); PaddingBottom = UDim.new(0, 20); PaddingRight = UDim.new(0, 20); PaddingLeft = UDim.new(0, 20)})
Items.Slide = Create("NumberValue", {Parent = Items.Holder; Value = 0})

Items.Panel = Create("Frame", {Parent = Items.Holder; Active = true; BackgroundColor3 = Preset.SectionBackground; Size = Pos(0, 340, 0, 0); AutomaticSize = Enum.AutomaticSize.Y})
Panel(Items.Panel)
Create("UIPadding", {Parent = Items.Panel; PaddingTop = UDim.new(0, 12); PaddingBottom = UDim.new(0, 12); PaddingRight = UDim.new(0, 12); PaddingLeft = UDim.new(0, 12)})
Create("UIListLayout", {Parent = Items.Panel; Padding = UDim.new(0, 10); SortOrder = Enum.SortOrder.LayoutOrder})

Items.Header = Create("Frame", {Parent = Items.Panel; LayoutOrder = 1; BackgroundTransparency = 1; Size = Pos(1, 0, 0, 0); AutomaticSize = Enum.AutomaticSize.Y})
Create("UIListLayout", {Parent = Items.Header; Padding = UDim.new(0, 6); SortOrder = Enum.SortOrder.LayoutOrder})
Items.Topbar = Create("Frame", {Parent = Items.Header; LayoutOrder = 1; BackgroundTransparency = 1; Size = Pos(1, 0, 0, 20)})
Create("UIListLayout", {Parent = Items.Topbar; Padding = UDim.new(0, 8); FillDirection = Enum.FillDirection.Horizontal; SortOrder = Enum.SortOrder.LayoutOrder; VerticalAlignment = Enum.VerticalAlignment.Center})
Items.Logo = Create("ImageLabel", {Parent = Items.Topbar; LayoutOrder = 1; Image = Config.Logo; BackgroundTransparency = 1; Size = Offset(20, 20)})
SoftCreate("UIShadow", {Parent = Items.Logo; BlurRadius = UDim.new(0, 20); Color = Preset.Accent; Transparency = 0.93})
Items.Title = Create("TextLabel", {Parent = Items.Topbar; LayoutOrder = 2; Text = Config.Title; TextXAlignment = Enum.TextXAlignment.Left; BackgroundTransparency = 1; Size = Pos(1, -37, 1, 0)})
Create("UIPadding", {Parent = Items.Title; PaddingBottom = UDim.new(0, 2)})
if not SoftCreate("UIFlexItem", {Parent = Items.Title; FlexMode = Enum.UIFlexMode.Fill}) then
	Items.Title.Size = Pos(1, -37, 1, 0)
end
Items.Close = Create("TextButton", {Parent = Items.Topbar; LayoutOrder = 3; BackgroundTransparency = 1; Size = Pos(0, 9, 1, 0)})
Items.CloseIcon = Create("ImageLabel", {Parent = Items.Close; Image = CloseImage; ImageColor3 = Preset.Unselected; BackgroundTransparency = 1; Position = Offset(0, 5); Size = Offset(9, 9)})
Items.Subtitle = Create("TextLabel", {Parent = Items.Header; LayoutOrder = 2; Text = Config.Subtitle; TextSize = 13; TextColor3 = Preset.Unselected; TextXAlignment = Enum.TextXAlignment.Left; BackgroundTransparency = 1; Size = Pos(1, 0, 0, 15)})
Create("UIPadding", {Parent = Items.Subtitle; PaddingBottom = UDim.new(0, 2)})

Items.Line = Create("Frame", {Parent = Items.Panel; LayoutOrder = 2; BackgroundColor3 = Preset.Accent; Size = Pos(1, 0, 0, 1)})
Create("UIGradient", {Parent = Items.Line; Transparency = Gradients.LineCenter})
SoftCreate("UIShadow", {Parent = Items.Line; BlurRadius = UDim.new(0, 10); Color = Preset.Accent; Transparency = 0.85})

Items.KeyInput = Create("Frame", {Parent = Items.Panel; LayoutOrder = 3; Active = true; BackgroundColor3 = Preset.Background; Size = Pos(1, 0, 0, 36)})
Create("UICorner", {Parent = Items.KeyInput; CornerRadius = UDim.new(0, 4)})
Create("UIListLayout", {Parent = Items.KeyInput; Padding = UDim.new(0, 10); FillDirection = Enum.FillDirection.Horizontal; SortOrder = Enum.SortOrder.LayoutOrder; VerticalAlignment = Enum.VerticalAlignment.Center})
Create("UIPadding", {Parent = Items.KeyInput; PaddingLeft = UDim.new(0, 12)})
Items.Input = Create("TextBox", {Parent = Items.KeyInput; LayoutOrder = 2; ClearTextOnFocus = false; PlaceholderText = Config.Placeholder; PlaceholderColor3 = Color3.fromRGB(111, 109, 114); TextXAlignment = Enum.TextXAlignment.Left; BackgroundTransparency = 1; ClipsDescendants = true; Size = Pos(1, -12, 1, 0); RichText = false})
SoftCreate("UIFlexItem", {Parent = Items.Input; FlexMode = Enum.UIFlexMode.Fill})
Create("UIPadding", {Parent = Items.Input; PaddingBottom = UDim.new(0, 2); PaddingRight = UDim.new(0, 12)})
SoftCreate("UIShadow", {Parent = Items.KeyInput; BlurRadius = UDim.new(0, 20); Transparency = 0.82})
Items.KeyStroke = Create("UIStroke", {Parent = Items.KeyInput; ApplyStrokeMode = Enum.ApplyStrokeMode.Border; BorderOffset = UDim.new(0, -1); Color = Preset.Outline; Transparency = 0.75})
Create("UIGradient", {Parent = Items.KeyInput; Rotation = 90; Color = Gradients.Button})

local Buttons = {}

for Index, Row in {{"Continue", "Join Discord"}, {"Buy Script Key"}} do
	local Holder = Create("Frame", {Parent = Items.Panel; LayoutOrder = 3 + Index; BackgroundTransparency = 1; Size = Pos(1, 0, 0, 34)})
	Create("UIListLayout", {Parent = Holder; Padding = UDim.new(0, 8); FillDirection = Enum.FillDirection.Horizontal; SortOrder = Enum.SortOrder.LayoutOrder})

	local Count = 0
	for _, Text in Row do
		if Text then
			Count += 1
		end
	end

	for Order, Text in Row do
		local Accent = Text == "Continue"
		local Button = {}
		local Half = Count > 1 and Pos(0.5, -4, 1, 0) or Pos(1, 0, 1, 0)

		Button.Instance = Create("TextButton", {Parent = Holder; LayoutOrder = Order; BackgroundColor3 = Accent and Preset.Accent or Preset.OtherBackgrounds; Size = Half})
		Create("UICorner", {Parent = Button.Instance; CornerRadius = UDim.new(0, 4)})
		SoftCreate("UIShadow", {Parent = Button.Instance; BlurRadius = UDim.new(0, 20); Transparency = 0.86})
		if SoftCreate("UIFlexItem", {Parent = Button.Instance; FlexMode = Enum.UIFlexMode.Fill}) then
			Button.Instance.Size = Pos(0, 0, 1, 0)
		end

		if Accent then
			Create("UIGradient", {Parent = Button.Instance; Rotation = 90; Color = Gradients.Fill})
			Button.Glow = SoftCreate("UIShadow", {Parent = Button.Instance; BlurRadius = UDim.new(0, 10); Color = Preset.Accent; Transparency = 0.85})
		else
			Create("UIGradient", {Parent = Button.Instance; Rotation = 90; Color = Gradients.Element})
			Create("UIStroke", {Parent = Button.Instance; ApplyStrokeMode = Enum.ApplyStrokeMode.Border; BorderOffset = UDim.new(0, -1); Color = Preset.Outline; Transparency = 0.5})
			Create("UIStroke", {Parent = Button.Instance; ApplyStrokeMode = Enum.ApplyStrokeMode.Border; BorderOffset = UDim.new(0, -2); Color = Preset.Outline; Transparency = 0.88})
		end

		Button.Title = Create("TextLabel", {Parent = Button.Instance; Text = Text; BackgroundTransparency = 1; Size = Pos(1, 0, 1, 0); RichText = false})
		Create("UIPadding", {Parent = Button.Title; PaddingBottom = UDim.new(0, 2)})

		Buttons[Text] = Button
	end
end

local State = {Open = true, Focused = false, Invalid = false, Validating = false}

local Place = function()
	local Viewport = Camera.ViewportSize
	local Size = Items.Holder.AbsoluteSize
	Items.Holder.Position = Offset(math.floor((Viewport.X - Size.X) / 2), math.floor((Viewport.Y - Size.Y) / 2) + math.round(Items.Slide.Value))
end

Connect(Items.Slide:GetPropertyChangedSignal("Value"), Place)
Connect(Items.Holder:GetPropertyChangedSignal("AbsoluteSize"), Place)
Connect(Camera:GetPropertyChangedSignal("ViewportSize"), Place)

local Press = function(Button)
	if Button.Glow then
		Tween(Button.Glow, {Transparency = 0.55}, TweenInfo.new(Speed * 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)).Completed:Connect(function()
			Tween(Button.Glow, {Transparency = 0.85})
		end)
		return
	end

	local Outline = Button.Instance
	local Fill = Create("Frame", {Parent = Outline; AnchorPoint = Vector2.new(0.5, 0.5); BackgroundColor3 = Preset.Accent; ClipsDescendants = true; Position = Pos(0.5, 0, 0.5, 0); Size = Pos(1, 0, 1, 0); ZIndex = 2})
	Create("UICorner", {Parent = Fill; CornerRadius = UDim.new(0, 4)})
	Create("UIGradient", {Parent = Fill; Rotation = 90; Color = Gradients.Element})
	local Title = Create("TextLabel", {Parent = Fill; Text = Button.Title.Text; TextColor3 = Preset.Background; AnchorPoint = Vector2.new(0.5, 0.5); BackgroundTransparency = 1; Position = Pos(0.5, 0, 0.5, 0); Size = Offset(Outline.AbsoluteSize.X, Outline.AbsoluteSize.Y); ZIndex = 3; RichText = false})
	Create("UIPadding", {Parent = Title; PaddingBottom = UDim.new(0, 2)})

	Tween(Fill, {Size = Pos(0, 0, 1, 0)}, TweenInfo.new(Speed * 1.25, Easing, Enum.EasingDirection.InOut)).Completed:Connect(function()
		Fill:Destroy()
	end)
end

local UpdateInput = function()
	local Active = State.Invalid or State.Focused
	Tween(Items.KeyStroke, {Color = State.Invalid and Preset.Danger or (State.Focused and Preset.Accent or Preset.Outline), Transparency = Active and 0.3 or 0.75})
end

local Copy = function(Link, Name)
	if Link == "" then
		Notify({Title = Name, Description = "No link was set for this", Duration = 2})
		return
	end

	local Clipboard = setclipboard or toclipboard or (Clipboard and Clipboard.set)

	if Clipboard then
		Clipboard(Link)
		Notify({Title = "Link Copied", Description = "Copied the <accent>" .. Name .. "</accent> link to your clipboard", Duration = 3})
	else
		Notify({Title = Name, Description = Link, Duration = 5})
	end
end

local Cleanup = function()
	for _, Connection in Connections do
		Connection:Disconnect()
	end

	task.spawn(function()
		repeat task.wait() until #Notifications == 0
		Gui:Destroy()
	end)
end

local Close = function(Launch, Message)
	if not State.Open then
		return
	end

	State.Open = false
	Items.Input:ReleaseFocus()
	Tween(Items.Slide, {Value = -12})
	Tween(Items.Holder, {GroupTransparency = 1}).Completed:Connect(function()
		Items.Holder:Destroy()

		if Launch then
			Notify({Title = Config.Title .. " Loaded", Description = Message or "Key accepted", Duration = 3})
			task.spawn(LoadGame)
		end

		Cleanup()
	end)
end

local SetContinue = function(Text)
	local Button = Buttons["Continue"]
	if Button then
		Button.Title.Text = Text
	end
end

local Continue = function()
	if not State.Open or State.Validating then
		return
	end

	local Key = string.match(Items.Input.Text, "^%s*(.-)%s*$") or ""
	if Key == "" then
		State.Invalid = true
		UpdateInput()
		task.delay(1, function()
			State.Invalid = false
			UpdateInput()
		end)
		Notify({Title = "Invalid Key", Description = "Paste your key first", Duration = 3})
		return
	end

	State.Validating = true
	SetContinue("Checking...")

	task.spawn(function()
		local Ok, DataOrErr, Normalized = CheckKey(Key)

		if not State.Open then
			State.Validating = false
			return
		end

		if not Ok then
			State.Validating = false
			State.Invalid = true
			UpdateInput()
			SetContinue("Continue")

			task.delay(1, function()
				State.Invalid = false
				UpdateInput()
			end)

			Notify({Title = "Invalid Key", Description = tostring(DataOrErr), Duration = 5})
			return
		end

		ApplyKey(Normalized, DataOrErr)
		SetContinue("Loading...")
		Close(true, "Key works. Time left: " .. ToTime(DataOrErr.expires_at))
		State.Validating = false
	end)
end

local OpenDiscord = function()
	task.spawn(function()
		local Opened = false

		if typeof(request) == "function" then
			local Success, Response = pcall(function()
				return request({
					Url = "http://127.0.0.1:6463/rpc?v=1",
					Method = "POST",
					Headers = {
						["Content-Type"] = "application/json",
						["Origin"] = "https://discord.com",
					},
					Body = HttpService:JSONEncode({
						cmd = "INVITE_BROWSER",
						args = { code = "solixhub" },
						nonce = HttpService:GenerateGUID(false),
					}),
				})
			end)

			Opened = Success and Response and Response.StatusCode == 200
		end

		if not Opened then
			Copy(Config.Discord, "Discord")
			return
		end

		Notify({Title = "Discord", Description = "Opening Discord invite.", Duration = 4})
	end)
end

for Text, Callback in {
	["Continue"] = Continue,
	["Join Discord"] = OpenDiscord,
	["Buy Script Key"] = function()
		Copy(Config.Shop, "shop")
	end,
} do
	local Button = Buttons[Text]

	if Button then
		OnClick(Button.Instance, function()
			if State.Open then
				Press(Button)
				Callback()
			end
		end)
	end
end

OnClick(Items.KeyInput, function()
	Items.Input:CaptureFocus()
end)

Connect(Items.Input.Focused, function()
	State.Focused = true
	UpdateInput()
end)

Connect(Items.Input.FocusLost, function(Enter)
	State.Focused = false
	UpdateInput()

	if Enter then
		Continue()
	end
end)

Connect(Items.Close.MouseEnter, function()
	Tween(Items.CloseIcon, {ImageColor3 = Preset.TextColor})
end)

Connect(Items.Close.MouseLeave, function()
	Tween(Items.CloseIcon, {ImageColor3 = Preset.Unselected})
end)

OnClick(Items.Close, function()
	Close(false)
end)

if type(Initial) == "string" and Initial ~= "" then
	Items.Input.Text = Initial
end

Place()
Items.Holder.GroupTransparency = 0
Items.Slide.Value = 0
Tween(Items.Holder, {GroupTransparency = 0})
Tween(Items.Slide, {Value = 0})

task.spawn(function()
	if type(Initial) ~= "string" or Initial == "" then
		return
	end

	local Ok, Data, Normalized = CheckKey(Initial)
	if not Ok then
		if SavedInitial and Initial == SavedInitial then
			DeleteFile(Config.File)
		end
		return
	end

	if not State.Open then
		return
	end

	ApplyKey(Normalized, Data)
	SetContinue("Loading...")
	Close(true, "Key works. Time left: " .. ToTime(Data.expires_at))
end)
