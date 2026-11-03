local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local SettingsSave = game.ReplicatedStorage:WaitForChild("SettingsSave")
local SettingsLoad = game.ReplicatedStorage:WaitForChild("SettingsLoad")

local settingsFrame = script.Parent

-- ===============================
-- DEFAULT SETTINGS
-- ===============================
local settings = {
	MusicVolume = 0.75,
	ShowHitboxes = false,
	ScreenShake = true,
	Blur = true,
	DepthOfField = true,
	Shadows = true,
}

-- ===============================
-- LOAD SETTINGS FROM DATASTORE
-- ===============================
local function loadSettings()
	local success, data = pcall(function()
		return SettingsLoad:InvokeServer()
	end)
	if success and data then
		for key, value in pairs(data) do
			if settings[key] ~= nil then
				settings[key] = value
			end
		end
	end
end

local function saveSettings()
	SettingsSave:FireServer(settings)
end

-- ===============================
-- APPLY SETTINGS TO GAME
-- ===============================
local function applyMusicVolume()
	local music = game.Workspace:FindFirstChild("Music")
	if music and music:IsA("Sound") then
		music.Volume = settings.MusicVolume
	end
	-- Also search for any Sound named "Song" in workspace
	for _, desc in pairs(game.Workspace:GetDescendants()) do
		if desc:IsA("Sound") and (desc.Name == "Song" or desc.Name == "Music") then
			desc.Volume = settings.MusicVolume
		end
	end
end

local function applyBlur()
	local blur = Lighting:FindFirstChild("DefaultBlur")
	if blur and blur:IsA("BlurEffect") then
		blur.Enabled = settings.Blur
	end
end

local function applyDepthOfField()
	local dof = Lighting:FindFirstChild("DepthOfField")
	if dof and dof:IsA("DepthOfFieldEffect") then
		dof.Enabled = settings.DepthOfField
	end
end

local function applyShadows()
	Lighting.GlobalShadows = settings.Shadows
end

local function applyHitboxVisibility()
	local targetTransparency = settings.ShowHitboxes and 0.5 or 1
	-- Check current character
	local char = player.Character
	if char then
		for _, desc in pairs(char:GetDescendants()) do
			if desc:IsA("BasePart") and desc.Name == "Hitbox" then
				desc.Transparency = targetTransparency
			end
		end
	end
	-- Also check workspace for any stray hitboxes
	for _, desc in pairs(game.Workspace:GetDescendants()) do
		if desc:IsA("BasePart") and desc.Name == "Hitbox" then
			desc.Transparency = targetTransparency
		end
	end
end

local function applyAllSettings()
	applyMusicVolume()
	applyBlur()
	applyDepthOfField()
	applyShadows()
	applyHitboxVisibility()
end

-- ===============================
-- UPDATE UI DISPLAYS
-- ===============================
local function updateDisplays()
	local musicVolBtn = settingsFrame:FindFirstChild("MusicVolume")
	if musicVolBtn and musicVolBtn:FindFirstChild("TXT") then
		musicVolBtn.TXT.Text = "MusicVolume : " .. tostring(settings.MusicVolume)
	end

	local hitboxBtn = settingsFrame:FindFirstChild("ShowHitboxes")
	if hitboxBtn and hitboxBtn:FindFirstChild("TXT") then
		hitboxBtn.TXT.Text = "ShowHitboxes : " .. tostring(settings.ShowHitboxes)
	end

	local shakeBtn = settingsFrame:FindFirstChild("ScreenShake")
	if shakeBtn and shakeBtn:FindFirstChild("TXT") then
		shakeBtn.TXT.Text = "ScreenShake : " .. tostring(settings.ScreenShake)
	end

	local blurBtn = settingsFrame:FindFirstChild("Blur")
	if blurBtn and blurBtn:FindFirstChild("TXT") then
		blurBtn.TXT.Text = "Blur : " .. tostring(settings.Blur)
	end

	local dofBtn = settingsFrame:FindFirstChild("DepthOfField")
	if dofBtn and dofBtn:FindFirstChild("TXT") then
		dofBtn.TXT.Text = "DepthOfField : " .. tostring(settings.DepthOfField)
	end

	local shadowBtn = settingsFrame:FindFirstChild("Shadows")
	if shadowBtn and shadowBtn:FindFirstChild("TXT") then
		shadowBtn.TXT.Text = "Shadows : " .. tostring(settings.Shadows)
	end
end

-- ===============================
-- WIRE UP SETTINGS UI
-- ===============================

-- MusicVolume: TextBox input (type a number like 0.5 or .75)
local musicVolBtn = settingsFrame:FindFirstChild("MusicVolume")
if musicVolBtn then
	local txtBox = musicVolBtn:FindFirstChild("TXT")
	if txtBox and txtBox:IsA("TextBox") then
		txtBox.FocusLost:Connect(function(enterPressed)
			local text = txtBox.Text
			-- Extract number from text like "MusicVolume : .75"
			local numStr = text:match("[%d%.]+$") or text:match("[%d%.]+")
			if numStr then
				local num = tonumber(numStr)
				if num and num >= 0 and num <= 10 then
					settings.MusicVolume = num
					applyMusicVolume()
					saveSettings()
				end
			end
			updateDisplays()
		end)
	end
end

-- Toggle settings: ShowHitboxes, ScreenShake, Blur, DepthOfField, Shadows
local toggleSettings = {
	ShowHitboxes = "ShowHitboxes",
	ScreenShake = "ScreenShake",
	Blur = "Blur",
	DepthOfField = "DepthOfField",
	Shadows = "Shadows",
}

for btnName, settingKey in pairs(toggleSettings) do
	local btn = settingsFrame:FindFirstChild(btnName)
	if btn then
		local buttonChild = btn:FindFirstChild("Button")
		if buttonChild then
			buttonChild.MouseButton1Down:Connect(function()
				settings[settingKey] = not settings[settingKey]
				-- Apply the specific setting
				if settingKey == "ShowHitboxes" then
					applyHitboxVisibility()
				elseif settingKey == "Blur" then
					applyBlur()
				elseif settingKey == "DepthOfField" then
					applyDepthOfField()
				elseif settingKey == "Shadows" then
					applyShadows()
				end
				saveSettings()
				updateDisplays()
			end)
		end
		-- Hover effects
		btn.MouseEnter:Connect(function()
			btn.ImageTransparency = 0.3
		end)
		btn.MouseLeave:Connect(function()
			btn.ImageTransparency = 0.75
		end)
	end
end

-- ===============================
-- CONTINUOUSLY SYNC MUSIC VOLUME
-- ===============================
task.spawn(function()
	while true do
		applyMusicVolume()
		task.wait(2)
	end
end)

-- ===============================
-- WATCH FOR NEW HITBOXES
-- ===============================
-- Watch for new hitboxes in character and workspace
player.CharacterAdded:Connect(function(char)
	char.DescendantAdded:Connect(function(desc)
		if desc:IsA("BasePart") and desc.Name == "Hitbox" then
			task.defer(function()
				desc.Transparency = settings.ShowHitboxes and 0.5 or 1
			end)
		end
	end)
end)

game.Workspace.DescendantAdded:Connect(function(desc)
	if desc:IsA("BasePart") and desc.Name == "Hitbox" then
		task.defer(function()
			desc.Transparency = settings.ShowHitboxes and 0.5 or 1
		end)
	end
end)

-- Also handle character if already loaded
if player.Character then
	player.Character.DescendantAdded:Connect(function(desc)
		if desc:IsA("BasePart") and desc.Name == "Hitbox" then
			task.defer(function()
				desc.Transparency = settings.ShowHitboxes and 0.5 or 1
			end)
		end
	end)
end

-- ===============================
-- INIT
-- ===============================
loadSettings()
applyAllSettings()
updateDisplays()