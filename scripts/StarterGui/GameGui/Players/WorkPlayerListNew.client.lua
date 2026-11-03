local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local playerListFrame = script.Parent
local colors = playerListFrame:FindFirstChild("Colors")
local ttLabel = playerListFrame:FindFirstChild("TT")
local fullSize = colors and colors:FindFirstChild("FullSize") and colors.FullSize.Size or UDim2.new(0.25, 0, 0.55, 0)

local localPlayer = Players.LocalPlayer
local isListVisible = false
local isTabHeld = false

-- Disable default Roblox player list
game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

-- Rank and RankIcon visibility is managed by RankIconManager in StarterPlayerScripts

local function showPlayerList()
	if isListVisible then return end
	isListVisible = true
	local serverFolder = workspace:FindFirstChild("Server")
	if serverFolder then
		local gameMode = serverFolder:FindFirstChild("GameMode")
		if gameMode and gameMode:IsA("StringValue") and ttLabel then
			ttLabel.Text = gameMode.Value
		end
	end
	playerListFrame.Visible = true
	playerListFrame:TweenSize(fullSize, "InOut", "Linear", 0.05)
end

local function hidePlayerList()
	if not isListVisible then return end
	isListVisible = false
	playerListFrame:TweenSize(UDim2.new(0, 0, 0, 0), "InOut", "Linear", 0.05)
	task.wait(0.05)
	playerListFrame.Visible = false
end

-- Tab key: hold to show, release to hide (PC)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.Tab then
		isTabHeld = true
		showPlayerList()
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.Tab then
		isTabHeld = false
		hidePlayerList()
	end
end)

-- Menu PlayerList button click (mobile + PC)
local menuButtonConnected = false
local function connectMenuButton()
	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
	if not playerGui then return end
	local menuGui = playerGui:FindFirstChild("Menu")
	if not menuGui then return end
	local playerListBtn = menuGui:FindFirstChild("PlayerList")
	if not playerListBtn then return end
	local btn = playerListBtn:FindFirstChild("Button")
	local target = btn and btn:IsA("GuiButton") and btn or playerListBtn
	if target and target:IsA("GuiButton") then
		target.Activated:Connect(function()
			if isListVisible then
				hidePlayerList()
			else
				showPlayerList()
			end
		end)
		menuButtonConnected = true
	end
end

connectMenuButton()

-- Retry connecting the MenuButton if it wasn't ready yet
if not menuButtonConnected then
	task.spawn(function()
		for i = 1, 30 do
			task.wait(1)
			if menuButtonConnected then break end
			connectMenuButton()
		end
	end)
end

-- Update player list when visible
RunService.Stepped:Connect(function()
	local ok, err = pcall(function()
	if not playerListFrame.Visible then return end

	-- Assign numbers to players
	local playerCount = 0
	for _, player in Players:GetPlayers() do
		local numberValue = player:FindFirstChild("Number")
		if not numberValue then
			numberValue = Instance.new("NumberValue")
			numberValue.Name = "Number"
			numberValue.Parent = player
		end
		playerCount = playerCount + 1
		numberValue.Value = playerCount
	end

	-- Update player frames
	for _, frame in playerListFrame:GetChildren() do
		if not frame:IsA("Frame") then continue end
		if frame.Name == "Colors" then continue end

		frame.Visible = false
		local frameNumber = frame:FindFirstChild("Number")
		if not frameNumber then continue end

		for _, player in Players:GetPlayers() do
			local playerNumber = player:FindFirstChild("Number")
			if not playerNumber then continue end
			if playerNumber.Value ~= frameNumber.Value then continue end

			local character = player.Character
			if not character then break end

			-- Set background color
			if player == localPlayer then
				if colors then
					local yc = colors:FindFirstChild("YourColor")
					if yc then frame.BackgroundColor3 = yc.BackgroundColor3 end
				end
			else
				if colors then
					local oc = colors:FindFirstChild("OtherColor")
					if oc then frame.BackgroundColor3 = oc.BackgroundColor3 end
				end
			end

			-- Team color override
			if player:FindFirstChild("PlayerTeam") then
				local teamBrick = character:FindFirstChild("TeamBrick")
				if teamBrick and teamBrick:IsA("BasePart") then
					frame.BackgroundColor3 = teamBrick.Color
				end
			end

			frame.Visible = true

			-- Player name
			local playerNameLabel = frame:FindFirstChild("PlayerName")
			if playerNameLabel then
				playerNameLabel.Text = player.Name
			end

			-- Kaiju image
			local kaijuImageFrame = frame:FindFirstChild("KaijuImage")
			if kaijuImageFrame then
				local innerImg = kaijuImageFrame:FindFirstChild("KaijuImage")
				if innerImg then
					local imageSet = false

					-- Try Settings ModuleScript first (has KaijuImage property)
					local settingsModule = character:FindFirstChild("Settings")
					if settingsModule and settingsModule:IsA("ModuleScript") then
						local success, settingsData = pcall(function()
							return require(settingsModule)
						end)
						if success and settingsData and settingsData.KaijuImage then
							innerImg.Image = tostring(settingsData.KaijuImage)
							imageSet = true
						end
					end

					-- Fallback: use the Image NumberValue cloned from the kaiju folder by the Spawn script
					if not imageSet then
						local imageValue = character:FindFirstChild("Image")
						if imageValue and imageValue:IsA("NumberValue") then
							innerImg.Image = "rbxassetid://" .. tostring(math.floor(imageValue.Value))
						end
					end
				end
			end

			-- K/D Stats
			local statsLabel = frame:FindFirstChild("Stats")
			if statsLabel then
				local playerStats = player:FindFirstChild("Stats")
				if playerStats then
					local k = playerStats:FindFirstChild("K")
					local d = playerStats:FindFirstChild("D")
					if k and d then
						statsLabel.Text = tostring(k.Value) .. "K / " .. tostring(d.Value) .. "D"
					end
				end
			end

			-- Rank and RankIcon are managed by RankIconManager

			break
		end
	end
	end) -- end pcall
	if not ok then
		warn("[WorkPlayerListNew] Update error: " .. tostring(err))
	end
end)