print("VOID HUB KEY SYSTEM")

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local SAVED_KEY_FILE = "voidhub/voidhub_key.txt"
local MAX_KEY_LENGTH = 50

local GAME_SCRIPTS = {
	[108533757090220] = "7d4d44567b1899503a60c87a69f0448f", -- Garden Tower Defense	
	[12351694619883] = "7d4d44567b1899503a60c87a69f0448f", -- Garden Tower Defense	
	[123516946198836] = "7d4d44567b1899503a60c87a69f0448f", -- Garden Tower Defense	
	[135729108619936] = "a3695c9f29b0e32af87a0ba3f2147cba", -- Build A Pet Factory
	[113236157544232] = "a3695c9f29b0e32af87a0ba3f2147cba", -- Anime Astral Simulator
	[132016691802922] = "bb7b83fa7ea677e833498389b9a1d17f", -- Build a Base and Steal
	[77458130464788] = "bb7b83fa7ea677e833498389b9a1d17f", -- Build a Base and Steal
	[70790155462881] = "a3695c9f29b0e32af87a0ba3f2147cba", -- Zombie Turret Farm
	[99702578544768] = "f7c39b17dc72c6d6dd2fe5bf9936979a", -- Be a Fish Bait
	[84515722934860] = "06ddc54d0d04db6d047cf7fb2121330e", -- Anime Expeditions
	[107706720875645] = "a3695c9f29b0e32af87a0ba3f2147cba", -- Roll for Anime
	[83660368690441] = "a3695c9f29b0e32af87a0ba3f2147cba", -- Roll Your Army
}

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local scale = 1
if isMobile then
	local minDimension = math.min(workspace.CurrentCamera.ViewportSize.X, workspace.CurrentCamera.ViewportSize.Y)
	scale = minDimension < 400 and 0.7 or minDimension < 600 and 0.85 or 0.95
end

local function px(n)
	return math.floor(n * scale)
end

local Colors = {
	Background = Color3.fromRGB(6, 6, 10),
	Panel = Color3.fromRGB(11, 10, 17),
	Stroke = Color3.fromRGB(28, 22, 45),
	Accent = Color3.fromRGB(120, 70, 220),
	AccentDim = Color3.fromRGB(90, 55, 160),
	TextPrimary = Color3.fromRGB(225, 220, 235),
	TextSecondary = Color3.fromRGB(150, 140, 175),
	TextTertiary = Color3.fromRGB(100, 90, 120),
	Success = Color3.fromRGB(100, 220, 150),
	Error = Color3.fromRGB(255, 100, 120),
	Warning = Color3.fromRGB(255, 180, 80),
}

local CONTAINER_WIDTH, CONTAINER_HEIGHT = px(400), px(300)

local UI = {}
local isLoading, isDestroyed = false, false

local function new(class, props, parent)
	local inst = Instance.new(class)
	for key, value in pairs(props) do
		inst[key] = value
	end
	inst.Parent = parent
	return inst
end

local function corner(radius, parent)
	return new("UICorner", { CornerRadius = UDim.new(0, radius) }, parent)
end

local function stroke(color, thickness, parent)
	return new("UIStroke", { Color = color, Thickness = thickness, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, parent)
end

local function hoverTint(button, normalColor, hoverColor)
	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.15), { BackgroundColor3 = hoverColor }):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.15), { BackgroundColor3 = normalColor }):Play()
	end)
end

local function BuildUI()
	local screenGui = new("ScreenGui", {
		Name = "VoidHubKeySystem",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 100,
	}, PlayerGui)

	new("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0,
	}, screenGui)

	local container = new("Frame", {
		Size = UDim2.fromOffset(CONTAINER_WIDTH, CONTAINER_HEIGHT),
		Position = UDim2.new(0.5, -CONTAINER_WIDTH / 2, 0.5, -CONTAINER_HEIGHT / 2),
		BackgroundColor3 = Colors.Panel,
		BorderSizePixel = 0,
	}, screenGui)
	corner(px(16), container)
	stroke(Colors.Stroke, 1.5, container)

	new("UIPadding", {
		PaddingTop = UDim.new(0, px(24)),
		PaddingBottom = UDim.new(0, px(20)),
		PaddingLeft = UDim.new(0, px(24)),
		PaddingRight = UDim.new(0, px(24)),
	}, container)

	local layout = new("UIListLayout", {
		Padding = UDim.new(0, px(12)),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
	}, container)
	layout.SortOrder = Enum.SortOrder.LayoutOrder

	new("TextLabel", {
		LayoutOrder = 1,
		Size = UDim2.new(1, 0, 0, px(26)),
		BackgroundTransparency = 1,
		Text = "Access Key Required",
		TextColor3 = Colors.TextPrimary,
		TextSize = px(20),
		Font = Enum.Font.GothamBold,
	}, container)

	new("TextLabel", {
		LayoutOrder = 2,
		Size = UDim2.new(1, 0, 0, px(18)),
		BackgroundTransparency = 1,
		Text = "Enter your key to unlock full access",
		TextColor3 = Colors.TextSecondary,
		TextSize = px(13),
		Font = Enum.Font.Gotham,
	}, container)

	local inputBox = new("TextBox", {
		LayoutOrder = 3,
		Size = UDim2.new(1, 0, 0, px(44)),
		BackgroundColor3 = Colors.Background,
		BorderSizePixel = 0,
		Text = "",
		PlaceholderText = "Enter your access key...",
		TextColor3 = Colors.TextPrimary,
		PlaceholderColor3 = Colors.TextTertiary,
		TextSize = px(14),
		Font = Enum.Font.GothamMedium,
		ClearTextOnFocus = false,
	}, container)
	corner(px(10), inputBox)
	local inputStroke = stroke(Colors.Stroke, 1.5, inputBox)
	new("UIPadding", { PaddingLeft = UDim.new(0, px(12)), PaddingRight = UDim.new(0, px(12)) }, inputBox)

	local counter = new("TextLabel", {
		LayoutOrder = 4,
		Size = UDim2.new(1, 0, 0, px(14)),
		BackgroundTransparency = 1,
		Text = "0/" .. MAX_KEY_LENGTH,
		TextColor3 = Colors.TextTertiary,
		TextSize = px(11),
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Right,
	}, container)

	local submitButton = new("TextButton", {
		LayoutOrder = 5,
		Size = UDim2.new(1, 0, 0, px(40)),
		BackgroundColor3 = Colors.Accent,
		BorderSizePixel = 0,
		Text = "Verify Key",
		TextColor3 = Colors.TextPrimary,
		TextSize = px(14),
		Font = Enum.Font.GothamBold,
		AutoButtonColor = false,
	}, container)
	corner(px(10), submitButton)
	hoverTint(submitButton, Colors.Accent, Colors.AccentDim)

	local buttonRow = new("Frame", {
		LayoutOrder = 6,
		Size = UDim2.new(1, 0, 0, px(36)),
		BackgroundTransparency = 1,
	}, container)
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, px(10)),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
	}, buttonRow)

	local getKeyButton = new("TextButton", {
		Size = UDim2.new(0.5, -px(5), 1, 0),
		BackgroundColor3 = Colors.Background,
		BorderSizePixel = 0,
		Text = "🔑 Get Key",
		TextColor3 = Colors.TextPrimary,
		TextSize = px(13),
		Font = Enum.Font.GothamMedium,
		AutoButtonColor = false,
	}, buttonRow)
	corner(px(10), getKeyButton)
	stroke(Colors.Stroke, 1.5, getKeyButton)
	hoverTint(getKeyButton, Colors.Background, Colors.Panel)

	local discordButton = new("TextButton", {
		Size = UDim2.new(0.5, -px(5), 1, 0),
		BackgroundColor3 = Colors.Background,
		BorderSizePixel = 0,
		Text = "💬 Discord",
		TextColor3 = Colors.TextPrimary,
		TextSize = px(13),
		Font = Enum.Font.GothamMedium,
		AutoButtonColor = false,
	}, buttonRow)
	corner(px(10), discordButton)
	stroke(Colors.Stroke, 1.5, discordButton)
	hoverTint(discordButton, Colors.Background, Colors.Panel)

	local status = new("TextLabel", {
		LayoutOrder = 7,
		Size = UDim2.new(1, 0, 0, px(16)),
		BackgroundTransparency = 1,
		Text = "",
		TextColor3 = Colors.Error,
		TextSize = px(12),
		Font = Enum.Font.GothamMedium,
		TextWrapped = true,
	}, container)

	UI.ScreenGui = screenGui
	UI.Input = inputBox
	UI.InputStroke = inputStroke
	UI.Counter = counter
	UI.Submit = submitButton
	UI.GetKey = getKeyButton
	UI.Discord = discordButton
	UI.Status = status
end

local function ShowStatus(message, color)
	UI.Status.Text = message
	UI.Status.TextColor3 = color or Colors.Warning
end

local function SetLoading(loading)
	isLoading = loading
	UI.Submit.Text = loading and "Verifying..." or "Verify Key"
end

local function DestroyKeySystem()
	if isDestroyed then
		return
	end
	isDestroyed = true
	UI.ScreenGui:Destroy()
	table.clear(UI)
end

local function LoadMainScript()
	print("LOADING MAIN SCRIPT for place " .. tostring(game.PlaceId))
	local scriptId = GAME_SCRIPTS[game.PlaceId]
	if not scriptId then
		Player:Kick("🚫 This game is not supported by voidhub. Join a supported game to use the script.")
		return
	end
	local ok, err = pcall(function()
		loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/" .. scriptId .. ".lua"))()
	end)
	if not ok then
		warn("[voidhub] Main script failed to load: " .. tostring(err))
	end
end

local function ValidateKey(keyInput)
	if isLoading or isDestroyed then
		return
	end
	if not keyInput or keyInput == "" then
		ShowStatus("Please enter an access key", Colors.Error)
		return
	end
	local scriptId = GAME_SCRIPTS[game.PlaceId]
	if not scriptId then
		ShowStatus("This game is not supported by voidhub", Colors.Error)
		return
	end

	SetLoading(true)
	ShowStatus("Validating key...", Colors.Warning)

	task.spawn(function()
		local ok, result = pcall(function()
			local LuarmorAPI = loadstring(game:HttpGet("https://sdkapi-public.luarmor.net/library.lua"))()
			LuarmorAPI.script_id = scriptId
			return LuarmorAPI.check_key(keyInput)
		end)

		SetLoading(false)

		if not ok or not result then
			ShowStatus("Connection error. Please try again.", Colors.Error)
			return
		end

		if result.code == "KEY_VALID" then
			writefile(SAVED_KEY_FILE, tostring(keyInput))
			ShowStatus("✅ Access granted! Loading...", Colors.Success)
			script_key = keyInput
			task.wait(0.3)
			DestroyKeySystem()
			LoadMainScript()
			return
		end

		if result.code == "KEY_HWID_LOCKED" then
			ShowStatus("⚠️ HWID Mismatch - Use /resethwid in Discord", Colors.Error)
		elseif result.code == "KEY_EXPIRED" then
			ShowStatus("❌ Key Expired - Get a new key", Colors.Error)
		else
			ShowStatus("❌ Invalid Key: " .. tostring(result.message or "Unknown error"), Colors.Error)
		end
	end)
end

local function CheckSavedKey()
	if isfile and readfile and isfile(SAVED_KEY_FILE) then
		local savedKey = readfile(SAVED_KEY_FILE)
		if savedKey and savedKey ~= "" then
			ShowStatus("Checking saved key...", Colors.Warning)
			ValidateKey(savedKey)
		end
	end
end

local function CopyToClipboard(text, successMessage)
	if setclipboard then
		setclipboard(text)
		ShowStatus(successMessage, Colors.Success)
	else
		ShowStatus("Link: " .. text, Colors.Warning)
	end
end

local function ConnectEvents()
	UI.Input:GetPropertyChangedSignal("Text"):Connect(function()
		if #UI.Input.Text > MAX_KEY_LENGTH then
			UI.Input.Text = string.sub(UI.Input.Text, 1, MAX_KEY_LENGTH)
		end
		UI.Counter.Text = #UI.Input.Text .. "/" .. MAX_KEY_LENGTH
		ShowStatus("")
	end)

	UI.Input.Focused:Connect(function()
		UI.InputStroke.Color = Colors.Accent
	end)
	UI.Input.FocusLost:Connect(function(enterPressed)
		UI.InputStroke.Color = Colors.Stroke
		if enterPressed then
			ValidateKey(UI.Input.Text)
		end
	end)

	UI.Submit.MouseButton1Click:Connect(function()
		ValidateKey(UI.Input.Text)
	end)
	UI.GetKey.MouseButton1Click:Connect(function()
		CopyToClipboard("https://ads.luarmor.net/get_key?for=voidhub_Keysystem-UYYNpTHupRUK", "🔑 Key link copied!")
	end)
	UI.Discord.MouseButton1Click:Connect(function()
		CopyToClipboard("https://discord.gg/Bv4CFc2ZTx", "💬 Discord invite copied!")
	end)
end

local function Initialize()
	BuildUI()
	ConnectEvents()
	CheckSavedKey()
end

Initialize()
