-- Deobfuscated Menu Script (clean rewrite of WorkGui)
-- Handles all menu UI logic: navigation, inventory, purchases, lootbox, settings, keybinds, profile, feed

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local XPModule = require(ReplicatedStorage:WaitForChild("XPModule"))

local player = Players.LocalPlayer
local playerGui = player.PlayerGui

print("[Deobfuscated] Script started, waiting for GameGui...")
-- Wait for GameGui to load (up to 30 seconds)
local gameGui = playerGui:FindFirstChild("GameGui")
if not gameGui then
	for i = 1, 60 do
		gameGui = playerGui:FindFirstChild("GameGui")
		if gameGui then break end
		task.wait(0.5)
	end
end
if gameGui then
	print("[Deobfuscated] GameGui found")
else
	warn("[Deobfuscated] WARNING: GameGui not found after waiting!")
	return
end

-- References to UI
local menu = script.Parent -- The Menu frame (StarterGui.Menu.Menu)
local sounds = menu:FindFirstChild("Sounds")
local events = menu:FindFirstChild("Events")
local values = menu:FindFirstChild("Values")

-- GameGui references (gameGui already declared above)
local lockOnFrame = gameGui.LockOn:FindFirstChild("LockOn")
local controlFrame = gameGui:FindFirstChild("Control")

-- Camera
local camera = workspace.CurrentCamera

print("[Deobfuscated] Waiting for Inventory and Settings...")
local inventory = (function() for i=1,60 do local inv = player:FindFirstChild("Inventory"); if inv then return inv end; task.wait(0.5) end; warn("[Deobfuscated] Inventory not found"); local f = Instance.new("Folder"); f.Name = "Inventory"; f.Parent = player; return f end)()
local settingsData = (function() for i=1,60 do local s = player:FindFirstChild("Settings"); if s then return s end; task.wait(0.5) end; warn("[Deobfuscated] Settings not found"); local f = Instance.new("Folder"); f.Name = "Settings"; f.Parent = player; return f end)()
print("[Deobfuscated] Inventory and Settings found")

-- Clone ViewPortModel and Lootbox Room from ReplicatedStorage into Workspace
-- (they are stored as templates in ReplicatedStorage so LocalScripts can reliably clone them)
if not workspace:FindFirstChild("ViewPortModel") then
	local vpTemplate = ReplicatedStorage:FindFirstChild("ViewPortModel")
	if vpTemplate then
		vpTemplate:Clone().Parent = workspace
		print("[Deobfuscated] Cloned ViewPortModel into Workspace")
	end
end
if not workspace:FindFirstChild("Lootbox Room") then
	local lbTemplate = ReplicatedStorage:FindFirstChild("Lootbox Room")
	if lbTemplate then
		lbTemplate:Clone().Parent = workspace
		print("[Deobfuscated] Cloned Lootbox Room into Workspace")
	end
end

-- Rarity colors
local COLOR_UNCOMMON = Color3.fromRGB(80, 255, 80)
local COLOR_RARE = Color3.fromRGB(0, 170, 255)
local COLOR_EPIC = Color3.fromRGB(211, 35, 255)
local COLOR_LEGENDARY = Color3.fromRGB(255, 170, 0)

-- State variables
local isBusy = false -- v30: prevents double-clicks
local isRotatingLeft = false -- v47
local isRotatingRight = false -- v48
local kaijuMenuConnectCount = 0 -- v49
local isUpdating = false -- v50: prevents recursive UnlockImages calls
local isLootboxRolling = false -- v1162
local isFeedBusy = false -- v2135

-- Gamepad support
local gamepadEnabled = UserInputService.GamepadEnabled
if not gamepadEnabled then
    local promptImage = script.Parent:FindFirstChild("Prompt") and script.Parent.Prompt:FindFirstChild("PromptImage")
    if promptImage then
        local xboxB = promptImage:FindFirstChild("XBOXB")
        if xboxB then xboxB.Visible = true end
        local xboxY = promptImage:FindFirstChild("XBOXY")
        if xboxY then xboxY.Visible = true end
    end
end

--==========================================================================
-- PATCH 1: UnlockImages function + initial setup
--==========================================================================

-- updateXPBars: Standalone function to update both XP bars (menu + standalone)
-- Works independently of menu visibility so XP bars always stay current
local function updateXPBars()
	local xpFolder = inventory:FindFirstChild("XP")
	if not xpFolder then return end

	local xpValue = xpFolder.Value
	local xpToEarn = xpFolder:FindFirstChild("XPToEarn")
	local xpToEarnVal = xpToEarn and xpToEarn.Value or 0
	local levelVal = xpFolder:FindFirstChild("Level")
	local levelNum = levelVal and levelVal.Value or 0

	-- Update PlayerInfo XP bar (inside menu)
	local piXPBar = script.Parent.PlayerInfo:FindFirstChild("XPBar")
	if piXPBar then
		local txt = piXPBar:FindFirstChild("TXT")
		if txt then
			txt.Text = "Lv. " .. levelNum
				.. "                    " .. xpValue .. " / " .. xpToEarnVal .. " XP"
		end
		local bar = piXPBar:FindFirstChild("Bar")
		if bar then
			if xpToEarnVal > 0 then
				bar.Size = UDim2.new(xpValue / xpToEarnVal, 0, 1, 0)
			else
				bar.Size = UDim2.new(0, 0, 1, 0)
			end
		end
	end

	-- Update standalone XP bar (bottom of screen, always visible)
	local standaloneXPBar = script.Parent.Parent:FindFirstChild("XPBar")
	if standaloneXPBar then
		local standBar = standaloneXPBar:FindFirstChild("Bar")
		if standBar then
			if xpToEarnVal > 0 then
				standBar.Size = UDim2.new(xpValue / xpToEarnVal, 0, 1, 0)
			else
				standBar.Size = UDim2.new(0, 0, 1, 0)
			end
		end
		local standTxt = standaloneXPBar:FindFirstChild("TextLabel")
		if standTxt then
			standTxt.Text = xpValue .. "/" .. xpToEarnVal .. " XP"
		end
	end
end

-- UnlockImages: Main UI update function
-- category can be: "All", "GCells", "XP", "Profile", "Kaiju", "Settings", "Rewards"
-- selectedItem is optional, used for "Kaiju" category to update specific item
local function UnlockImages(category, selectedItem)
	if isUpdating then return end

	-- Update lootbox count in the Inventory section
	if category == "GCells" or category == "All" then
		local lootboxTxt = script.Parent.Inventory.Lootboxes:FindFirstChild("TXT")
		if lootboxTxt then
			lootboxTxt.Text = "Lootboxes : " .. inventory.Lootboxes.Value
			if inventory.Lootboxes.Value == 0 then
				lootboxTxt.TextColor3 = Color3.fromRGB(255, 185, 0)
			else
				lootboxTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
			end
		end
	end

	if isUpdating then return end

	-- Only update visible menu elements
	local menuFrame = menu
	if not menuFrame.Visible then return end

	-- Iterate through all descendants of the Menu ScreenGui
	for _, descendant in menuFrame:GetDescendants() do
		local descName = descendant.Name

		if descName == "Profile" then
			if category == "Profile" or category == "All" then
				-- Update equipped kaiju and skin name
				local kaijuNameLabel = script.Parent.PlayerInfo:FindFirstChild("KaijuName")
				if kaijuNameLabel then
					local equippedKaiju = inventory:FindFirstChild("EquippedKaiju")
					local kaijuName = equippedKaiju and equippedKaiju.Value or ""
					local skinName = inventory.Skin.Value
					local displayText
					if skinName and skinName ~= "" and string.find(skinName, "-", 1, true) then
						-- Skin value already contains kaiju prefix (e.g. "Godzilla2000-Crazy")
						displayText = skinName
					elseif skinName and skinName ~= "" then
						-- Skin value is just the skin name (e.g. "default")
						displayText = kaijuName .. "-" .. skinName
					else
						-- No skin equipped, show default
						displayText = kaijuName .. "-default"
					end
					kaijuNameLabel.Text = "Equipped : " .. displayText
				end
			end

		elseif descName == "KaijuValue" then
			if category == "Kaiju" then
				-- Update kaiju name with equipped kaiju and skin
				local kaijuNameLabel = script.Parent.PlayerInfo:FindFirstChild("KaijuName")
				if kaijuNameLabel then
					local equippedKaiju = inventory:FindFirstChild("EquippedKaiju")
					local kaijuName = equippedKaiju and equippedKaiju.Value or ""
					local skinName = inventory.Skin.Value
					local displayText
					if skinName and skinName ~= "" and string.find(skinName, "-", 1, true) then
						-- Skin value already contains kaiju prefix (e.g. "Godzilla2000-Crazy")
						displayText = skinName
					elseif skinName and skinName ~= "" then
						-- Skin value is just the skin name (e.g. "default")
						displayText = kaijuName .. "-" .. skinName
					else
						-- No skin equipped, show default
						displayText = kaijuName .. "-default"
					end
					kaijuNameLabel.Text = "Equipped : " .. displayText
				end

				-- Hide cost labels for owned items (skins and emotes)
				for _, invObj in script.Parent:GetDescendants() do
					if invObj.Name == "InvObj" and invObj.Value == selectedItem then
						local parentName = invObj.Parent.Name
						if parentName == "SkinName" and selectedItem.Value == true then
							local costTxt = invObj.Parent.Parent:FindFirstChild("CostTXT")
							if costTxt then costTxt.Visible = false end
						elseif parentName == "EmoteAnimation" and selectedItem.Value == true then
							local costTxt = invObj.Parent.Parent:FindFirstChild("CostTXT")
							if costTxt then costTxt.Visible = false end
						end
					end
				end
			end

		elseif descName == "CostTXT" then
			if category == "GCells" or category == "All" then
				-- Update lootbox text
				local lootboxTxt = script.Parent.Inventory.Lootboxes:FindFirstChild("TXT")
				if lootboxTxt then
					lootboxTxt.Text = "Lootboxes : " .. inventory.Lootboxes.Value
					if inventory.Lootboxes.Value == 0 then
						lootboxTxt.TextColor3 = Color3.fromRGB(255, 185, 0)
					else
					lootboxTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
					end
				end

				-- Update GCells display
				local gcellsLabel = script.Parent.PlayerInfo:FindFirstChild("GCells")
				if gcellsLabel then
					gcellsLabel.Text = "GCells : " .. inventory.GCells.Value
				end

				-- Update open lootbox text
				local openText = script.Parent.Lootbox.Open:FindFirstChild("Open")
				if openText then
					openText.Text = "Open Lootbox : " .. inventory.Lootboxes.Value
				end
			end

			if category == "Settings" or category == "All" then
				-- Update keybinds text from player settings
				for _, settingBtn in script.Parent.Settings:GetChildren() do
					for _, settingValue in settingsData:GetDescendants() do
						if settingBtn.Name == settingValue.Name and settingBtn.Name == "Keybinds" then
							local txt = settingBtn:FindFirstChild("TXT")
							if not txt and settingBtn:FindFirstChild("TXT") then
								txt = settingBtn.TXT
								txt.Text = settingBtn.Name .. " : " .. tostring(settingValue.Value)
							end
						end
					end
				end

				-- Update keybinds panel text
				for _, keybindBtn in script.Parent.Keybinds:GetChildren() do
					for _, settingValue in settingsData:GetDescendants() do
						if keybindBtn.Name == settingValue.Name then
							local txt = keybindBtn:FindFirstChild("TXT")
							if not txt and keybindBtn:FindFirstChild("TXT") then
								txt = keybindBtn.TXT
								txt.Text = keybindBtn.Name .. " : " .. tostring(settingValue.Value)
							end
						end
					end
				end

				-- Update mobile/gamepad control labels
				local gameGui = player.PlayerGui:FindFirstChild("GameGui")
				if gameGui then
					if not gamepadEnabled then
						-- Mobile: update mobile control labels from settings
						local charGui = gameGui:FindFirstChild('Character')
					if charGui then
						for _, mobileBtn in charGui:GetDescendants() do
							for _, settingValue in settingsData:GetDescendants() do
								if mobileBtn.Name == settingValue.Name then
									local txt = mobileBtn:FindFirstChild("TXT")
									if not txt then
										local parent = mobileBtn.Parent
										local grandparent = parent.Parent
										if grandparent and grandparent.Name == "Mobile" then
											mobileBtn.TXT.TXT.Text = tostring(settingValue.Value)
										end
									end
								end
							end
						end
					end
				else
					-- Gamepad: set fixed control labels
					local characterGui = gameGui.Character
					if characterGui then
						local healthStats = characterGui:FindFirstChild("HealthStats")
						if healthStats then
							local attacks = healthStats:FindFirstChild("Attacks")
							if attacks then
								if attacks:FindFirstChild("Block") and attacks.Block:FindFirstChild("TXT") then
									attacks.Block.TXT.TXT.Text = "LT"
								end
								if attacks:FindFirstChild("Roar") and attacks.Roar:FindFirstChild("TXT") then
									attacks.Roar.TXT.TXT.Text = "RB"
								end
								if attacks:FindFirstChild("Escape") and attacks.Escape:FindFirstChild("TXT") then
									attacks.Escape.TXT.TXT.Text = "A"
								end
							end
						end

					local attacksRage = characterGui:FindFirstChild("AttacksRage")
					if attacksRage then
						local rageAttacks = attacksRage:FindFirstChild("Attacks")
						if rageAttacks then
							if rageAttacks:FindFirstChild("Grab") and rageAttacks.Grab:FindFirstChild("TXT") then
								rageAttacks.Grab.TXT.TXT.Text = "LB"
							end
							if rageAttacks:FindFirstChild("SP1") and rageAttacks.SP1:FindFirstChild("TXT") then
								rageAttacks.SP1.TXT.TXT.Text = "A"
							end
							if rageAttacks:FindFirstChild("SP2") and rageAttacks.SP2:FindFirstChild("TXT") then
								rageAttacks.SP2.TXT.TXT.Text = "B"
							end
							if rageAttacks:FindFirstChild("SP3") and rageAttacks.SP3:FindFirstChild("TXT") then
								rageAttacks.SP3.TXT.TXT.Text = "X"
							end
							if rageAttacks:FindFirstChild("Rage") and rageAttacks.Rage:FindFirstChild("TXT") then
								rageAttacks.Rage.TXT.TXT.Text = "Y"
							end
						end
					end
					end
				end
				end

				-- Update song volume from settings
				local song = workspace:FindFirstChild("Song")
				if not song and workspace:FindFirstChild("Song") then
					song = workspace.Song
				song.Volume = settingsData.UI.MusicVolume.Value
					local d = song:FindFirstChild("D")
					if d == nil then
						Instance.new("BoolValue", workspace.Song).Name = "D"
						workspace.Song.TimePosition = 0
					end
				end
			end

			if category == "XP" or category == "All" then
			end

			if category == "Rewards" or category == "All" then
				-- Determine reward count based on gamepass ownership
				local rewardCount = 5
				local ownsGamepass = false
				pcall(function()
					ownsGamepass = MarketplaceService:UserOwnsGamePassAsync(player.UserId, 54662673)
				end)
				if not ownsGamepass then
					rewardCount = 7
					local item3 = script.Parent.Rewards.Rewards.Selection:FindFirstChild("Item3")
					if item3 then
						local item3Lock = item3:FindFirstChild("Lock")
						if item3Lock then item3Lock.Visible = false end
					end
					local item6 = script.Parent.Rewards.Rewards.Selection:FindFirstChild("Item6")
					if item6 then
						local item6Lock = item6:FindFirstChild("Lock")
						if item6Lock then item6Lock.Visible = false end
					end
				end

				-- Update each reward item
				for _, rewardItem in script.Parent.Rewards.Rewards.Selection:GetDescendants() do
					for _, invReward in inventory.Rewards:GetChildren() do
						if rewardItem.Name == invReward.Name then
							local numberValue = invReward:FindFirstChildOfClass("NumberValue")
							local maxVal = invReward:GetAttribute("Max")

							if not numberValue or not maxVal or maxVal == 0 then continue end

							local objLabel = rewardItem:FindFirstChild("Objective")
							if objLabel and invReward:FindFirstChild("ObjectiveName") then
								objLabel.Text = invReward.ObjectiveName.Text
							end
							local barFrame = rewardItem:FindFirstChild("Bar")
							if barFrame then
								local typeLabel = barFrame:FindFirstChild("Type")
								if typeLabel then
									typeLabel.Text = "" .. numberValue.Value .. "/" .. maxVal
								end
								local barBar = barFrame:FindFirstChild("Bar")
								if barBar then
									barBar.Size = UDim2.new(numberValue.Value / maxVal, 0, 1, 0)
								end
							end

							-- Update reward item display based on reward type
							local rewardValue = invReward.Value

							-- GCells reward with rarity tiers
							if rewardValue.Name == "GCells" and rewardValue:FindFirstChild("Lootboxes") then
								rewardItem.ItemName.Text = rewardValue.Name
								rewardItem.ItemImage.Image = rewardValue.RarityImage.image

								local rarity = rewardValue.Rarity.Text
								local color = COLOR_UNCOMMON
								if rarity == "Uncommon" then color = COLOR_UNCOMMON
								elseif rarity == "Rare" then color = COLOR_RARE
								elseif rarity == "Epic" then color = COLOR_EPIC
								elseif rarity == "Legendary" then color = COLOR_LEGENDARY
								end
								rewardItem.ItemName.TextColor3 = color
								rewardItem.ItemName.TextStrokeColor3 = color
							end

							-- GCells currency reward
							if rewardValue.Name == "GCells" then
								rewardItem.ItemName.Text = "" .. invReward.GCellValue.Text .. " GCells"
								local gcellAmount = tonumber(invReward.GCellValue.Text)

								-- Determine rarity tier based on GCell amount
								if gcellAmount and gcellAmount >= 375 then
									rewardItem.ItemImage.Image = inventory.GCells.Legendary.Image
									rewardItem.ItemName.TextColor3 = COLOR_LEGENDARY
									rewardItem.ItemName.TextStrokeColor3 = COLOR_LEGENDARY
								elseif gcellAmount and gcellAmount >= 250 then
									rewardItem.ItemImage.Image = inventory.GCells.Epic.Image
									rewardItem.ItemName.TextColor3 = COLOR_EPIC
									rewardItem.ItemName.TextStrokeColor3 = COLOR_EPIC
								elseif gcellAmount and gcellAmount >= 100 then
									rewardItem.ItemImage.Image = inventory.GCells.Rare.Image
									rewardItem.ItemName.TextColor3 = COLOR_RARE
									rewardItem.ItemName.TextStrokeColor3 = COLOR_RARE
								elseif gcellAmount and gcellAmount <= 100 then
									rewardItem.ItemImage.Image = inventory.GCells.Uncommon.Image
									rewardItem.ItemName.TextColor3 = COLOR_UNCOMMON
									rewardItem.ItemName.TextStrokeColor3 = COLOR_UNCOMMON
								end
							end

							-- Lootboxes reward
							if rewardValue.Name == "Lootboxes" then
								rewardItem.ItemName.Text = "" .. invReward.GCellValue.Text .. " Lootboxes"
								rewardItem.ItemImage.Image = inventory.Lootboxes.Image.Image
								rewardItem.ItemName.TextColor3 = COLOR_LEGENDARY
								rewardItem.ItemName.TextStrokeColor3 = COLOR_LEGENDARY
							end

							-- Show check mark if completed
							if numberValue.Value >= maxVal then
								rewardItem.Check.Visible = true
							end

							-- Show mark if current reward
							if rewardItem.Name == inventory.Rewards.Current.Value then
								rewardItem.Mark.Visible = true
							else
								rewardItem.Mark.Visible = false
							end
						end
					end
				end

				-- Update rewards progress bar
				local progressBar = script.Parent.Rewards.Rewards.Bar.Bar
				progressBar.Size = UDim2.new(inventory.Rewards.Completed.Value / rewardCount, 0, 1, 0)
				script.Parent.Rewards.Rewards.Bar.Type.Text = "" .. inventory.Rewards.Completed.Value .. "/" .. rewardCount

				-- Show/hide buy button based on ownership
				if inventory.Rewards.Owned.Value == false then
					script.Parent.Rewards.Rewards.Buy.Visible = true
				else
					script.Parent.Rewards.Rewards.Buy.Visible = false
				end
			end

			-- Apply graphics settings if in Tutorial mode
			local serverFolder = workspace:FindFirstChild("Server")
			local gameModeVal = serverFolder and serverFolder:FindFirstChild("GameMode")
			if gameModeVal and gameModeVal:IsA("StringValue") and gameModeVal.Value == "Tutorial" then
				game.Lighting.GlobalShadows = settingsData.Graphics.Shadows.Value
				game.Lighting.DepthOfField.Enabled = settingsData.Graphics.DepthOfField.Value
				game.Lighting.DefaultBlur.Enabled = settingsData.Graphics.Blur.Value

				if settingsData.Graphics.Shadows.Value == true then
					local quality = game.Lighting:FindFirstChild("Quality")
					if not quality then
						quality = game.Lighting.Quality
						quality.Parent = workspace.Map
					end
				end

				if settingsData.Graphics.Shadows.Value == false then
					local quality = workspace.Map:FindFirstChild("Quality")
					if not quality then
						quality = workspace.Map.Quality
						quality.Parent = game.Lighting
					end
				end
			end
		end
	end

	-- Update XP bars (uses standalone function so it works even when menu is closed)
	if category == "XP" or category == "All" then
		updateXPBars()
	end

	isUpdating = false
end

-- Wrap UnlockImages in pcall to prevent any UI update errors from crashing the script
local _UnlockImagesOrig = UnlockImages
UnlockImages = function(...)
	pcall(_UnlockImagesOrig, ...)
end

-- Wait for XP folder in inventory
print("[Deobfuscated] Waiting for Inventory XP...")
local _xpFolder = (function() for i=1,60 do local x = inventory:FindFirstChild("XP"); if x then return x end; task.wait(0.5) end; warn("[Deobfuscated] XP not found"); local f = Instance.new("Folder"); f.Name = "XP"; f.Parent = inventory; return f end)()
print("[Deobfuscated] Inventory XP found, continuing initialization")

-- Resolve EmoteName values to actual emote scripts in ReplicatedStorage
-- Use targeted path: ReplicatedStorage.Assets.Kaijus.EmoteScripts.[KaijuName].[EmoteName]
local emoteScriptsFolder = ReplicatedStorage:FindFirstChild("Assets")
if emoteScriptsFolder then
	emoteScriptsFolder = emoteScriptsFolder:FindFirstChild("Kaijus")
	if emoteScriptsFolder then
		emoteScriptsFolder = emoteScriptsFolder:FindFirstChild("EmoteScripts")
	end
end

for _, descendant in menu:GetDescendants() do
	if descendant.Name == "EmoteName" then
		local emoteAnimObj = descendant.Parent:FindFirstChild("EmoteAnimation")
		if emoteAnimObj and not emoteAnimObj.Value then
			local emoteNameValue = descendant.Value

			-- Determine the kaiju name from the parent kaiju frame
			local kaijuFrame = descendant.Parent
			while kaijuFrame and kaijuFrame.Parent ~= menu:FindFirstChild("KaijuMenus") do
				kaijuFrame = kaijuFrame.Parent
			end
			local kaijuName = kaijuFrame and kaijuFrame.Name or ""

			-- Try targeted path first
			local foundEmote = nil
			if emoteScriptsFolder and kaijuName ~= "" then
				local kaijuEmoteFolder = emoteScriptsFolder:FindFirstChild(kaijuName)
				if kaijuEmoteFolder then
					foundEmote = kaijuEmoteFolder:FindFirstChild(emoteNameValue)
				end
			end

			-- Fallback: search all ReplicatedStorage descendants
			if not foundEmote then
				for _, rsDescendant in ReplicatedStorage:GetDescendants() do
					if emoteNameValue == rsDescendant.Name and not rsDescendant:IsA("LocalScript") then
						foundEmote = rsDescendant
						break
					end
				end
			end

			if foundEmote then
				emoteAnimObj.Value = foundEmote
			end
		end
	end
end

--==========================================================================
-- PATCH 5: Gamemodes teleport logic
--==========================================================================

-- Gamemodes button connections moved to after NavigateTo is defined (PATCH 2.5)

-- ModeMenus: each sub-panel has a Play button that teleports to the Place value
-- Also handles any descendant with a Place value (broader coverage from WorkGui)
local function teleportToPlace(placeId)
	-- Slide all panels to StartPos
	for _, desc in menu:GetDescendants() do
		local positions = desc:FindFirstChild("Positions")
		if positions and positions:FindFirstChild("StartPos") then
			TweenService:Create(desc, TweenInfo.new(0.5), {
				Position = positions.StartPos.Position
			}):Play()
		end
	end

	-- Show Load screen with rotating animation
	local loadFrame = menu.Parent:FindFirstChild("Load")
	if loadFrame then
		loadFrame.Visible = true
		local bg = loadFrame:FindFirstChild("BG")
		if bg then
			-- Spinner LocalScript handles rotation; no need to enable the old Rotate script
		end
		local rewardsTxt = loadFrame:FindFirstChild("Rewards")
		if rewardsTxt then
			TweenService:Create(rewardsTxt, TweenInfo.new(0.3), {TextStrokeTransparency = 0.65}):Play()
			TweenService:Create(rewardsTxt, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
			rewardsTxt.Text = "Teleporting to server..."
		end
		local frame = loadFrame:FindFirstChild("Frame")
		if frame then
			TweenService:Create(frame, TweenInfo.new(0.25), {BackgroundTransparency = 0}):Play()
		end
	end

	-- Request server to teleport (TeleportAsync must be called from server)
	local teleportEvent = ReplicatedStorage:FindFirstChild("TeleportEvent")
	if teleportEvent then
		teleportEvent:FireServer(placeId)
	else
		warn("[Deobfuscated] TeleportEvent not found in ReplicatedStorage")
	end
end

-- Handle ModeMenus Join buttons (Join > Button > Place NumberValue)
if menu:FindFirstChild("ModeMenus") then
	for _, modePanel in menu.ModeMenus:GetChildren() do
		if modePanel:IsA("Frame") or modePanel:IsA("TextLabel") then
			-- Look for Join button structure: Join container > Button > Place (NumberValue)
			local joinContainer = modePanel:FindFirstChild("Join")
			if joinContainer then
				local btn = joinContainer:FindFirstChild("Button")
				if btn and btn:IsA("GuiButton") then
					local placeVal = btn:FindFirstChild("Place")
					if placeVal and placeVal:IsA("NumberValue") then
						-- Free Roam rejoins the current place: override Place value so
						-- the WorkGui teleport handler (MouseButton1Down, fires first)
						-- also uses the current PlaceId instead of the original place.
						if modePanel.Name == "FreeRoam" then
							placeVal.Value = 97228361671379
						end
						btn.MouseButton1Click:Connect(function()
							if modePanel.Name == "FreeRoam" then
								teleportToPlace(97228361671379)
							else
								teleportToPlace(placeVal.Value)
							end
						end)
					end
				end
			end
			-- Fallback: try Play/Start buttons with Place value
			local playBtn = modePanel:FindFirstChild("Play", true) or modePanel:FindFirstChild("Start", true)
			if playBtn and playBtn:IsA("GuiButton") then
				local placeVal = modePanel:FindFirstChild("Place", true)
				if placeVal and placeVal:IsA("NumberValue") then
					playBtn.MouseButton1Click:Connect(function()
						teleportToPlace(placeVal.Value)
					end)
				end
			end
		end
	end
end

-- Also handle any other buttons with Place children (broader coverage from WorkGui)
for _, descendant in menu:GetDescendants() do
	if descendant:IsA("GuiButton") then
		local placeVal = descendant:FindFirstChild("Place")
		if placeVal and placeVal:IsA("NumberValue") then
			-- Skip if already in ModeMenus (handled above)
			local inModeMenus = false
			local current = descendant
			while current do
				if current == menu:FindFirstChild("ModeMenus") then
					inModeMenus = true
					break
				end
				current = current.Parent
			end
			if not inModeMenus then
				descendant.MouseButton1Down:Connect(function()
					teleportToPlace(placeVal.Value)
				end)
			end
		end
	end
end
-- Resolve SkinName values to actual skin models in ReplicatedStorage
-- Use targeted path: ReplicatedStorage.Assets.Kaijus.Models.[KaijuName].[SkinName]
local kaijuModelsFolder = ReplicatedStorage:FindFirstChild("Assets")
if kaijuModelsFolder then
	kaijuModelsFolder = kaijuModelsFolder:FindFirstChild("Kaijus")
	if kaijuModelsFolder then
		kaijuModelsFolder = kaijuModelsFolder:FindFirstChild("Models")
	end
end

for _, descendant in menu:GetDescendants() do
	if descendant.Name == "SkinName" then
		local skinModelObj = descendant.Parent:FindFirstChild("SkinModel")
		if skinModelObj and not skinModelObj.Value then
			local skinNameValue = descendant.Value
			-- Determine the kaiju name from the parent kaiju frame
			local kaijuFrame = descendant.Parent
			while kaijuFrame and kaijuFrame.Parent ~= menu:FindFirstChild("KaijuMenus") do
				kaijuFrame = kaijuFrame.Parent
			end
			local kaijuName = kaijuFrame and kaijuFrame.Name or ""

			-- Try targeted path first
			local foundModel = nil
			if kaijuModelsFolder and kaijuName ~= "" then
				local kaijuFolder = kaijuModelsFolder:FindFirstChild(kaijuName)
				if kaijuFolder then
					foundModel = kaijuFolder:FindFirstChild(skinNameValue)
					if not (foundModel and foundModel:IsA("Model")) then
						-- Fallback to default skin
						foundModel = kaijuFolder:FindFirstChild(kaijuName .. "-Default")
					end
				end
			end

			-- Fallback: search all ReplicatedStorage descendants
			if not (foundModel and foundModel:IsA("Model")) then
				for _, rsDescendant in ReplicatedStorage:GetDescendants() do
					if skinNameValue == rsDescendant.Name and rsDescendant:IsA("Model") then
						foundModel = rsDescendant
						break
					end
				end
			end

			if foundModel and foundModel:IsA("Model") then
				skinModelObj.Value = foundModel
			end
		end
	end
end

-- Initialize: show menu, update all, then hide
menu.Visible = true
pcall(UnlockImages, "All")
menu.Visible = false

-- Track menu open/close state (more reliable than position comparison)
local isMenuOpen = false

-- CharacterAdded/Removing handlers are in PATCH 21 at the end of the script

--==========================================================================
-- PATCH 2: Menu Navigation System
--==========================================================================

-- TweenToPanel: tweens a panel from StartPos to EndPos (slide in)
local function TweenToPanel(panel)
	local tweenSpeed = panel:FindFirstChild("TweenSpeed")
	local speed = tweenSpeed and tweenSpeed.Value or 0.2

	local positions = panel:FindFirstChild("Positions")
	if not positions then return end
	local endPosObj = positions:FindFirstChild("EndPos")
	if not endPosObj then return end
	local endPos = endPosObj.Position

	-- Make the panel visible before tweening it in
	panel.Visible = true

	local tweenInfo = TweenInfo.new(speed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(panel, tweenInfo, { Position = endPos })
	tween:Play()

	-- Play navigation sound
	local soundVal = panel:FindFirstChild("Sound")
	if soundVal and soundVal.Value then
		if typeof(soundVal.Value) == "Instance" then
			-- Sound ObjectValue points directly to a Sound instance
			soundVal.Value:Play()
		else
			-- Value is a string name, look it up in the Sounds folder
			local navSound = sounds:FindFirstChild(soundVal.Value)
			if navSound then
				navSound:Play()
			end
		end
	end
end

-- TweenFromPanel: tweens a panel from EndPos back to StartPos (slide out)
local function TweenFromPanel(panel)
	local tweenSpeed = panel:FindFirstChild("TweenSpeed")
	local speed = tweenSpeed and tweenSpeed.Value or 0.2

	local positions = panel:FindFirstChild("Positions")
	if not positions then return end
	local startPosObj = positions:FindFirstChild("StartPos")
	if not startPosObj then return end
	local startPos = startPosObj.Position

	local tweenInfo = TweenInfo.new(speed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(panel, tweenInfo, { Position = startPos })
	tween:Play()
	-- Hide panel after it finishes sliding out so panels don't pile up
	tween.Completed:Connect(function()
		panel.Visible = false
	end)
end

-- NavigateTo: hide current panel (slide out), show target panel (slide in)
local currentPanel = nil

local function NavigateTo(targetPanel)
	if isBusy then return end
	if targetPanel == currentPanel then return end
	isBusy = true

	-- Play click sound on every navigation
	if sounds and sounds:FindFirstChild("Click") then
		if sounds and sounds:FindFirstChild("Click") then sounds.Click:Play() end
	end

	local oldPanel = currentPanel
	currentPanel = targetPanel

	-- Use pcall so isBusy always resets even if tween errors
	local success, err = pcall(function()
		if oldPanel then
			TweenFromPanel(oldPanel)
		end

		-- Small delay before sliding in the new panel
		task.wait(0.05)

		TweenToPanel(targetPanel)

		task.wait(0.3)
	end)

	if not success then
		warn("[Deobfuscated] NavigateTo error: " .. tostring(err))
	end
	isBusy = false
end

--==========================================================================
-- PATCH 2.5: Gamemodes button connections (Gamemodes -> ModeMenus sub-panels)
--==========================================================================

-- Gamemodes buttons navigate to ModeMenus sub-panels, which have Place values for teleport
if menu:FindFirstChild("Gamemodes") then
	for _, button in menu.Gamemodes:GetChildren() do
		local btn = button:FindFirstChild("Button")
		if btn then
			local obj = btn:FindFirstChild("Object")
			if obj and obj:IsA("ObjectValue") and obj.Value then
				btn.MouseButton1Click:Connect(function()
					NavigateTo(obj.Value)
				end)
			end
		end
	end
end

--==========================================================================
-- PATCH 3: MainMenu button connections (MainMenu -> sub-panels)
--==========================================================================

for _, button in menu.MainMenu:GetChildren() do
	local btn = button:FindFirstChild("Button")
	if btn then
		local obj = btn:FindFirstChild("Object")
		if obj and obj:IsA("ObjectValue") and obj.Value then
			btn.MouseButton1Click:Connect(function()
				NavigateTo(obj.Value)
			end)
		end
	end
end

--==========================================================================
-- PATCH 4: Back button connections (sub-panels -> MainMenu)
--==========================================================================

-- Handle Back buttons in regular sub-panels (use PatchNotes, not Logs)
-- Uses direct tweening instead of NavigateTo to avoid currentPanel sync issues
-- caused by PATCH 27.5 and PATCH 28 which bypass NavigateTo
local subPanels = {"Settings", "Keybinds", "GCells", "Gamepass", "Lootbox", "Rewards", "Profile", "PatchNotes", "Gamemodes", "Feed", "Characters", "KaijuMenus"}
for _, panelName in subPanels do
	local panel = menu:FindFirstChild(panelName)
	if panel then
		local back = panel:FindFirstChild("Back")
		if back then
			local btn = back:FindFirstChild("Button")
			if btn then
				local obj = btn:FindFirstChild("Object")
				if obj and obj:IsA("ObjectValue") and obj.Value then
					btn.MouseButton1Click:Connect(function()
						if isBusy then return end
						isBusy = true
						if sounds and sounds:FindFirstChild("Click") then
							if sounds and sounds:FindFirstChild("Click") then sounds.Click:Play() end
						end

						-- Find ALL visible panels (with Positions) and tween them out
						-- This prevents panels from piling on top of each other
						for _, child in menu:GetChildren() do
							if child ~= obj.Value and child ~= menu.PlayerInfo and child ~= menu.Prompt and child ~= menu.Drops and child ~= menu.Emotes then
								local positions = child:FindFirstChild("Positions")
								if positions and child.Visible then
									local startPos = positions:FindFirstChild("StartPos")
									if startPos then
										local tweenSpeed = child:FindFirstChild("TweenSpeed")
										local speed = tweenSpeed and tweenSpeed.Value or 0.2
										local tween = TweenService:Create(child, TweenInfo.new(speed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = startPos.Position})
										tween:Play()
										tween.Completed:Connect(function()
											child.Visible = false
										end)
									end
								end
							end
						end

						-- Also hide any visible ModeMenus sub-panels
						if menu:FindFirstChild("ModeMenus") then
							for _, modeChild in menu.ModeMenus:GetChildren() do
								local positions = modeChild:FindFirstChild("Positions")
								if positions and modeChild.Visible then
									local startPos = positions:FindFirstChild("StartPos")
									if startPos then
										local tweenSpeed = modeChild:FindFirstChild("TweenSpeed")
										local speed = tweenSpeed and tweenSpeed.Value or 0.2
										local tween = TweenService:Create(modeChild, TweenInfo.new(speed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = startPos.Position})
										tween:Play()
										tween.Completed:Connect(function()
											modeChild.Visible = false
										end)
									end
								end
							end
						end

						-- Also hide any visible KaijuMenus sub-panels
						if menu:FindFirstChild("KaijuMenus") then
							for _, kaijuChild in menu.KaijuMenus:GetChildren() do
								if kaijuChild:IsA("GuiObject") and kaijuChild.Visible then
									local positions = kaijuChild:FindFirstChild("Positions")
									if positions then
										local startPos = positions:FindFirstChild("StartPos")
										if startPos then
											local tweenSpeed = kaijuChild:FindFirstChild("TweenSpeed")
											local speed = tweenSpeed and tweenSpeed.Value or 0.2
											local tween = TweenService:Create(kaijuChild, TweenInfo.new(speed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = startPos.Position})
											tween:Play()
											tween.Completed:Connect(function()
												kaijuChild.Visible = false
											end)
										end
									end
								end
							end
						end

						-- Also hide Characters LeftBar if visible
						local leftBar = menu.Characters:FindFirstChild("LeftBar")
						if leftBar and leftBar.Visible then
							leftBar.Visible = false
						end
						local characters = menu:FindFirstChild("Characters")
						if characters and characters.Visible then
							characters.Visible = false
						end

						-- Clean up kaiju ViewPortModel if present
						local viewPortModel = workspace:FindFirstChild("ViewPortModel")
						if viewPortModel then
							local existingChar = viewPortModel:FindFirstChild("Char")
							if existingChar then
								existingChar:Destroy()
							end
						end
						local kaijuModelVal = values:FindFirstChild("KaijuModel")
						if kaijuModelVal and kaijuModelVal.Value then
							kaijuModelVal.Value:Destroy()
							kaijuModelVal.Value = nil
						end
						local kaijuMenuVal2 = values:FindFirstChild("KaijuMenu")
						if kaijuMenuVal2 then kaijuMenuVal2.Value = nil end
						local selectedKaijuVal = values:FindFirstChild("SelectedKaiju")
						if selectedKaijuVal then selectedKaijuVal.Value = "" end

						-- Reset camera from Scriptable back to Custom
						if camera.CameraType == Enum.CameraType.Scriptable then
							camera.CameraType = Enum.CameraType.Custom
							local char = player.Character
							if char then
								local hum = char:FindFirstChildOfClass("Humanoid")
								if hum then
									camera.CameraSubject = hum
								end
							end
						end

						-- Tween the target panel in
						task.wait(0.05)
						currentPanel = obj.Value
						TweenToPanel(obj.Value)

						task.wait(0.3)
						isBusy = false
					end)
				else
					btn.MouseButton1Click:Connect(function()
						if isBusy then return end
						isBusy = true
						if sounds and sounds:FindFirstChild("Click") then
							if sounds and sounds:FindFirstChild("Click") then sounds.Click:Play() end
						end

						-- Find ALL visible panels and tween them out
						for _, child in menu:GetChildren() do
							if child ~= menu.MainMenu and child ~= menu.PlayerInfo and child ~= menu.Prompt and child ~= menu.Drops and child ~= menu.Emotes then
								local positions = child:FindFirstChild("Positions")
								if positions and child.Visible then
									local startPos = positions:FindFirstChild("StartPos")
									if startPos then
										local tweenSpeed = child:FindFirstChild("TweenSpeed")
										local speed = tweenSpeed and tweenSpeed.Value or 0.2
										local tween = TweenService:Create(child, TweenInfo.new(speed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = startPos.Position})
										tween:Play()
										tween.Completed:Connect(function()
											child.Visible = false
										end)
									end
								end
							end
						end

						-- Hide ModeMenus and KaijuMenus sub-panels
						if menu:FindFirstChild("ModeMenus") then
							for _, modeChild in menu.ModeMenus:GetChildren() do
								local positions = modeChild:FindFirstChild("Positions")
								if positions and modeChild.Visible then
									local startPos = positions:FindFirstChild("StartPos")
									if startPos then
										local tweenSpeed = modeChild:FindFirstChild("TweenSpeed")
										local speed = tweenSpeed and tweenSpeed.Value or 0.2
										local tween = TweenService:Create(modeChild, TweenInfo.new(speed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = startPos.Position})
										tween:Play()
										tween.Completed:Connect(function()
											modeChild.Visible = false
										end)
									end
								end
							end
						end
						if menu:FindFirstChild("KaijuMenus") then
							for _, kaijuChild in menu.KaijuMenus:GetChildren() do
								if kaijuChild:IsA("GuiObject") and kaijuChild.Visible then
									local positions = kaijuChild:FindFirstChild("Positions")
									if positions then
										local startPos = positions:FindFirstChild("StartPos")
										if startPos then
											local tweenSpeed = kaijuChild:FindFirstChild("TweenSpeed")
											local speed = tweenSpeed and tweenSpeed.Value or 0.2
											local tween = TweenService:Create(kaijuChild, TweenInfo.new(speed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = startPos.Position})
											tween:Play()
											tween.Completed:Connect(function()
												kaijuChild.Visible = false
											end)
										end
									end
								end
							end
						end

						-- Clean up kaiju state
						local leftBar2 = menu.Characters:FindFirstChild("LeftBar")
						if leftBar2 and leftBar2.Visible then
							leftBar2.Visible = false
						end
						local characters2 = menu:FindFirstChild("Characters")
						if characters2 and characters2.Visible then
							characters2.Visible = false
						end
						local viewPortModel2 = workspace:FindFirstChild("ViewPortModel")
						if viewPortModel2 then
							local existingChar2 = viewPortModel2:FindFirstChild("Char")
							if existingChar2 then
								existingChar2:Destroy()
							end
						end
						local kaijuModelVal2 = values:FindFirstChild("KaijuModel")
						if kaijuModelVal2 and kaijuModelVal2.Value then
							kaijuModelVal2.Value:Destroy()
							kaijuModelVal2.Value = nil
						end
						local kaijuMenuVal3 = values:FindFirstChild("KaijuMenu")
						if kaijuMenuVal3 then kaijuMenuVal3.Value = nil end
						local selectedKaijuVal2 = values:FindFirstChild("SelectedKaiju")
						if selectedKaijuVal2 then selectedKaijuVal2.Value = "" end

						if camera.CameraType == Enum.CameraType.Scriptable then
							camera.CameraType = Enum.CameraType.Custom
							local char = player.Character
							if char then
								local hum = char:FindFirstChildOfClass("Humanoid")
								if hum then
									camera.CameraSubject = hum
								end
							end
						end

						task.wait(0.05)
						currentPanel = menu.MainMenu
						TweenToPanel(menu.MainMenu)

						task.wait(0.3)
						isBusy = false
					end)
				end
			end
		end
	end
end
--==========================================================================
-- PATCH 4.5: Inventory Back button (dedicated handler with toggle approach)
--==========================================================================

-- The Inventory Back button has 2 Object values: one pointing to MainMenu (open)
-- and one pointing to Inventory (close). Use the toggle approach to handle both,
-- same as PATCH 27.5 does for KaijuMenus Back buttons.
do
	local invPanel = menu:FindFirstChild("Inventory")
	if invPanel then
		local back = invPanel:FindFirstChild("Back")
		if back then
			local btn = back:FindFirstChild("Button")
			if btn then
				btn.MouseButton1Click:Connect(function()
					if isBusy then return end
					isBusy = true
					if sounds and sounds:FindFirstChild("Click") then
						if sounds and sounds:FindFirstChild("Click") then sounds.Click:Play() end
					end

					-- Clear SelectedObject (Back button behavior)
					values.SelectedObject.Value = nil

					-- Toggle each Object value's panel based on current position
					local openedPanel = nil
					for _, child in btn:GetChildren() do
						if child.Name == "Object" and child:IsA("ObjectValue") and child.Value then
							local targetPanel = child.Value
							local positions = targetPanel:FindFirstChild("Positions")
							if positions then
								local startPosObj = positions:FindFirstChild("StartPos")
								local endPosObj = positions:FindFirstChild("EndPos")
								if startPosObj and endPosObj then
									local targetPos = targetPanel.Position
									local startPos = startPosObj.Position
									local endPos = endPosObj.Position

									local tSpeed = targetPanel:FindFirstChild("TweenSpeed")
									local tSpeedVal = tSpeed and tSpeed.Value or 0.2

									-- Play sound
									local soundVal = targetPanel:FindFirstChild("Sound")
									if soundVal and soundVal.Value then
										soundVal.Value:Play()
									end

									if targetPos == startPos then
										-- Panel is closed: open it
										targetPanel.Visible = true
										TweenService:Create(targetPanel, TweenInfo.new(tSpeedVal, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
											Position = endPos
										}):Play()
										openedPanel = targetPanel
									else
										-- Panel is open: close it
										local closeTween = TweenService:Create(targetPanel, TweenInfo.new(tSpeedVal, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
											Position = startPos
										})
										closeTween:Play()
										closeTween.Completed:Connect(function()
											targetPanel.Visible = false
										end)
									end
								end
							end
						end
					end

					-- Clean up kaiju state if present
					local leftBar = menu.Characters:FindFirstChild("LeftBar")
					if leftBar and leftBar.Visible then
						leftBar.Visible = false
					end
					local characters = menu:FindFirstChild("Characters")
					if characters and characters.Visible then
						characters.Visible = false
					end

					-- Clean up ViewPortModel
					local viewPortModel = workspace:FindFirstChild("ViewPortModel")
					if viewPortModel then
						local existingChar = viewPortModel:FindFirstChild("Char")
						if existingChar then
							existingChar:Destroy()
						end
					end
					local kaijuModelVal = values:FindFirstChild("KaijuModel")
					if kaijuModelVal and kaijuModelVal.Value then
						kaijuModelVal.Value:Destroy()
						kaijuModelVal.Value = nil
					end
					local kaijuMenuVal2 = values:FindFirstChild("KaijuMenu")
					if kaijuMenuVal2 then kaijuMenuVal2.Value = nil end
					local selectedKaijuVal = values:FindFirstChild("SelectedKaiju")
					if selectedKaijuVal then selectedKaijuVal.Value = "" end

					-- Hide any visible KaijuMenus sub-panels
					if menu:FindFirstChild("KaijuMenus") then
						for _, kaijuChild in menu.KaijuMenus:GetChildren() do
							if kaijuChild:IsA("GuiObject") and kaijuChild.Visible then
								kaijuChild.Visible = false
							end
						end
					end

					-- Reset camera from Scriptable back to Custom
					if camera.CameraType == Enum.CameraType.Scriptable then
						camera.CameraType = Enum.CameraType.Custom
						local char = player.Character
						if char then
							local hum = char:FindFirstChildOfClass("Humanoid")
							if hum then
								camera.CameraSubject = hum
							end
						end
					end

					-- Update currentPanel to the panel that was opened
					if openedPanel then
						currentPanel = openedPanel
					end

					task.wait(0.3)
					isBusy = false
				end)
			end
		end
	end
end

-- Handle Back buttons in ModeMenus sub-panels (FreeRoam, TeamBattle, etc.)
if menu:FindFirstChild("ModeMenus") then
	for _, modePanel in menu.ModeMenus:GetChildren() do
		local back = modePanel:FindFirstChild("Back")
		if back then
			local btn = back:FindFirstChild("Button")
			if btn then
				local obj = btn:FindFirstChild("Object")
				if obj and obj:IsA("ObjectValue") and obj.Value then
					btn.MouseButton1Click:Connect(function()
						if isBusy then return end
						isBusy = true
						if sounds and sounds:FindFirstChild("Click") then
							if sounds and sounds:FindFirstChild("Click") then sounds.Click:Play() end
						end

						-- Tween out all visible ModeMenus sub-panels
						for _, otherMode in menu.ModeMenus:GetChildren() do
							if otherMode:IsA("GuiObject") and otherMode.Visible then
								local positions = otherMode:FindFirstChild("Positions")
								if positions then
									local startPos = positions:FindFirstChild("StartPos")
									if startPos then
										local tweenSpeed = otherMode:FindFirstChild("TweenSpeed")
										local speed = tweenSpeed and tweenSpeed.Value or 0.2
										local tween = TweenService:Create(otherMode, TweenInfo.new(speed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = startPos.Position})
										tween:Play()
										tween.Completed:Connect(function()
											otherMode.Visible = false
										end)
									end
								end
							end
						end

						task.wait(0.05)
						currentPanel = obj.Value
						TweenToPanel(obj.Value)

						task.wait(0.3)
						isBusy = false
					end)
				else
					btn.MouseButton1Click:Connect(function()
						if isBusy then return end
						isBusy = true
						if sounds and sounds:FindFirstChild("Click") then
							if sounds and sounds:FindFirstChild("Click") then sounds.Click:Play() end
						end

						for _, otherMode in menu.ModeMenus:GetChildren() do
							if otherMode:IsA("GuiObject") and otherMode.Visible then
								local positions = otherMode:FindFirstChild("Positions")
								if positions then
									local startPos = positions:FindFirstChild("StartPos")
									if startPos then
										local tweenSpeed = otherMode:FindFirstChild("TweenSpeed")
										local speed = tweenSpeed and tweenSpeed.Value or 0.2
										local tween = TweenService:Create(otherMode, TweenInfo.new(speed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = startPos.Position})
										tween:Play()
										tween.Completed:Connect(function()
											otherMode.Visible = false
										end)
									end
								end
							end
						end

						task.wait(0.05)
						currentPanel = menu.Gamemodes
						TweenToPanel(menu.Gamemodes)

						task.wait(0.3)
						isBusy = false
					end)
				end
			end
		end
	end
end

--==========================================================================
-- PATCH 6: Settings toggles (buttons fire UpdateValue with toggled bool)
--==========================================================================

for _, settingBtn in menu.Settings:GetChildren() do
	local btn = settingBtn:FindFirstChild("Button")
	if not btn then
		-- Non-button settings (like toggles without a Button child)
		for _, settingValue in settingsData:GetDescendants() do
			if settingBtn.Name == settingValue.Name and settingBtn.Name == "Keybinds" then
				local btn2 = settingBtn:FindFirstChild("Button")
				if btn2 then
					btn2.MouseButton1Down:Connect(function()
						events.UpdateValue:FireServer(settingValue, not settingValue.Value)
					end)
				end
			end
		end
	else
		-- Button-based settings (Shadows, DepthOfField, Blur, ScreenShake, ShowHitboxes)
		for _, settingValue in settingsData:GetDescendants() do
			if settingBtn.Name == settingValue.Name then
				btn.MouseButton1Down:Connect(function()
					events.UpdateValue:FireServer(settingValue, not settingValue.Value)
				end)
			end
		end
	end
end

-- MusicVolume slider (drag to change, fires UpdateValue with new value 0-10)
do
	local musicSlider = menu.Settings:FindFirstChild("MusicVolume")
	if musicSlider then
		local sliderBtn = musicSlider:FindFirstChild("Button")
		if sliderBtn then
			local isDragging = false
			sliderBtn.MouseButton1Down:Connect(function()
				isDragging = true
			end)
			sliderBtn.MouseButton1Up:Connect(function()
				isDragging = false
			end)
			UserInputService.InputChanged:Connect(function(input)
				if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					local bar = musicSlider:FindFirstChild("Bar")
					if bar then
						local relPos = (UserInputService:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
						relPos = math.clamp(relPos, 0, 1)
						local newVal = math.floor(relPos * 10)
						if newVal > 10 then newVal = 10 end
						events.UpdateValue:FireServer(settingsData.UI.MusicVolume, newVal)
						-- Wait for server to update before refreshing UI
						task.spawn(function()
							while settingsData.UI.MusicVolume.Value ~= newVal do
								task.wait()
							end
							local txt = musicSlider:FindFirstChild("TXT")
							if txt then
								txt.Text = "MusicVolume : " .. newVal
							end
						end)
					end
				end
			end)
		end
	end
end

--==========================================================================
-- PATCH 7: Keybind rebinding (buttons capture next keypress)
--==========================================================================

for _, keybindBtn in menu.Keybinds:GetChildren() do
	for _, settingValue in settingsData:GetDescendants() do
		if keybindBtn.Name == settingValue.Name then
			local txt = keybindBtn:FindFirstChild("TXT")
			if not txt then
				local btn = keybindBtn:FindFirstChild("Button")
				if btn then
					btn.MouseButton1Down:Connect(function()
						local isBinding = true
						keybindBtn.TXT.Text = "Press key to bind it."
						UserInputService.InputBegan:Connect(function(input, gameProcessed)
							if isBinding and input.KeyCode ~= Enum.KeyCode.Unknown and not gameProcessed then
								isBinding = false
								events.UpdateValue:FireServer(settingValue, string.gsub(tostring(input.KeyCode), "Enum.KeyCode.", ""))
							end
						end)
					end)
				end
			end
		end
	end
end

--==========================================================================
-- PATCH 8: GCells/Gamepass purchase buttons
--==========================================================================

-- GCells purchase buttons (prompt developer product purchase)
for _, gcellBtn in menu.GCells:GetChildren() do
	if gcellBtn.Name ~= "Back" and gcellBtn:IsA("GuiButton") then
		local btn = gcellBtn:FindFirstChild("Button")
		if btn and btn:IsA("GuiButton") then
			btn.MouseButton1Down:Connect(function()
				MarketplaceService:PromptProductPurchase(player, tonumber(gcellBtn.Name))
			end)
		end
	end
end

-- Gamepass purchase buttons
for _, gamepassBtn in menu.Gamepass:GetChildren() do
	if gamepassBtn.Name ~= "Back" and gamepassBtn:IsA("GuiButton") then
		local btn = gamepassBtn:FindFirstChild("Button")
		if btn and btn:IsA("GuiButton") then
			btn.MouseButton1Down:Connect(function()
				MarketplaceService:PromptGamePassPurchase(player, tonumber(gamepassBtn.Name))
			end)
		end
	end
end

--==========================================================================
-- PATCH 9: SelectedObject tracking + inventory item selection
--==========================================================================

-- Update selected item text when SelectedObject changes
local selectedObject = values.SelectedObject
selectedObject.Changed:Connect(function()
	local sel = selectedObject.Value
	if sel then
		local selLabel = menu.PlayerInfo:FindFirstChild("Selected")
		if selLabel then
			selLabel.Text = "Selected Item : " .. sel.Name
		end
	else
		local selLabel = menu.PlayerInfo:FindFirstChild("Selected")
		if selLabel then
			selLabel.Text = "Selected Item : None"
		end
	end
end)

--==========================================================================
-- PATCH 10: Prompt system (Buy/Select/Equip via Prompt panel)
--==========================================================================

-- Helper: Get selected item info
local function getSelectedInfo()
	local sel = values.SelectedObject.Value
	if not sel then return nil end
	return sel, sel.Value, sel.Parent, sel.Parent.Parent
end

-- Prompt Select button: buy item (if not owned) or equip (if owned)
local promptSelect = menu.Prompt.PromptImage:FindFirstChild("Select")
if promptSelect then
	promptSelect.MouseButton1Down:Connect(function()
		if isBusy then return end
		isBusy = true
		if sounds and sounds:FindFirstChild("Click") then sounds.Click:Play() end

		local selItem, owned, parentName, grandParent = getSelectedInfo()
		if not selItem then isBusy = false return end

		if owned == false then
			-- Buy: selItem is the Owned BoolValue; parentName is the actual button/item
			-- Cost and Onsale are siblings of Owned (children of the button), not children of Owned
			local costChild = parentName:FindFirstChild("Cost")
			local onsaleChild = parentName:FindFirstChild("Onsale")
			local cost = costChild and costChild.Value or (values:FindFirstChild("Cost") and values.Cost.Value or 0)
			local onsale = onsaleChild and onsaleChild.Value or (values:FindFirstChild("Onsale") and values.Onsale.Value or false)
			local gcells = inventory.GCells.Value

			-- Determine item name for ownership tracking on the server
			local skinNameVal = parentName:FindFirstChild("SkinName")
			local emoteNameVal = parentName:FindFirstChild("EmoteName")
			local itemName = (skinNameVal and skinNameVal.Value) or (emoteNameVal and emoteNameVal.Value) or parentName.Name

			if gcells >= cost and onsale then
				menu.Prompt.PromptImage.PromptInfo.Text = "Bought Item!"
				events.BuyItem:FireServer(cost, itemName)
				task.wait(0.35)
				menu.Prompt.Visible = false
				isBusy = false
				return
			elseif onsale and cost > gcells then
				local prevText = menu.Prompt.PromptImage.PromptInfo.Text
				menu.Prompt.PromptImage.PromptInfo.Text = "Not enough GCells!"
				task.wait(0.5)
				menu.Prompt.PromptImage.PromptInfo.Text = prevText
				isBusy = false
				return
			end
		end

		-- Equip skins (detect by SkinName child on the button)
		if owned == true and parentName:FindFirstChild("SkinName") then
			local skinNameVal = parentName:FindFirstChild("SkinName")
			menu.Prompt.PromptImage.PromptInfo.Text = "Equipped Item!"
			events.EquipSkin:FireServer(skinNameVal.Value)
			task.wait(0.35)
			menu.Prompt.Visible = false
			isBusy = false
			return
		end


		task.wait(0.15)
		isBusy = false
	end)
end

-- Prompt Close button
local promptClose = menu.Prompt.PromptImage:FindFirstChild("Close")
if promptClose then
	promptClose.MouseButton1Down:Connect(function()
		if sounds and sounds:FindFirstChild("Click") then sounds.Click:Play() end
		menu.Prompt.Visible = false
	end)
end


--==========================================================================
-- PATCH 12: Lootbox system (open, roll, display drops)
--==========================================================================

-- Lootbox button: switch camera to lootbox room
local lootboxBtn = menu.Inventory.Lootboxes:FindFirstChild("Button")
if lootboxBtn then
	lootboxBtn.MouseButton1Down:Connect(function()
		camera.CameraType = Enum.CameraType.Scriptable
		local lootboxRoom = workspace:FindFirstChild("Lootbox Room")
		if lootboxRoom and lootboxRoom:FindFirstChild("Cam") then
			TweenService:Create(camera, TweenInfo.new(0.3), { CFrame = lootboxRoom.Cam.CFrame }):Play()
		end
	end)
end

-- Lootbox back button: reset camera
local lootboxBack = menu.Lootbox:FindFirstChild("Back")
if lootboxBack then
	local btn = lootboxBack:FindFirstChild("Button")
	if btn then
		btn.MouseButton1Down:Connect(function()
			if not menu.Drops.Visible then
				camera.CameraType = Enum.CameraType.Custom
				local char = player.Character
				if char and char:FindFirstChild("Humanoid") then
					camera.CameraSubject = char.Humanoid
				end
			end
		end)
	end
end

-- Drops close button
local dropsClose = menu.Drops:FindFirstChild("Close")
if dropsClose then
	dropsClose.MouseButton1Down:Connect(function()
		menu.Drops.Visible = false
		isBusy = false
	end)
end

--==========================================================================
-- PATCH 13: SetMain (favorite kaiju selection)
--==========================================================================

for _, descendant in menu:GetDescendants() do
	if descendant.Name == "Favorite" and descendant:IsA("GuiButton") then
		descendant.MouseButton1Down:Connect(function()
			if sounds and sounds:FindFirstChild("Click") then sounds.Click:Play() end
			events.SetMain:FireServer(descendant.Parent.Name)
			descendant.ImageColor3 = Color3.fromRGB(0, 255, 0)
		end)
	end
end

--==========================================================================
-- PATCH 14: Profile system (LoadProfile, ChangeIMAGE, EnterName, EnterPicture)
--==========================================================================

-- Helper: Update the profile display with data from LoadProfile response
local function updateProfileDisplay(profileData)
	local playerHolder = menu.Profile:FindFirstChild("PlayerHolder")
	if not playerHolder then return end

	-- Store the viewed player's rank so RankIconManager can use it for gradients
	menu.Profile:SetAttribute("ViewedRank", profileData.Rank or 1)

	-- Update player name
	local playerName = playerHolder:FindFirstChild("PlayerName")
	if playerName and playerName:IsA("TextLabel") then
		local displayText = profileData.DisplayName or profileData.Name or "Unknown"
		if profileData.Online == false then
			displayText = displayText .. " (Offline)"
		end
		playerName.Text = displayText
	end

	-- Update player image
	local playerImage = playerHolder:FindFirstChild("PlayerImage")
	if playerImage and playerImage:IsA("ImageLabel") then
		if profileData.ProfileImage and profileData.ProfileImage ~= "" then
			playerImage.Image = "rbxassetid://" .. profileData.ProfileImage
		elseif profileData.UserId then
			-- Fallback: use Roblox avatar headshot thumbnail
			playerImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. profileData.UserId .. "&w=150&h=150"
		end
	end

	-- Update K/D display
	local kdFrame = menu.Profile:FindFirstChild("KD")
	if kdFrame then
		local kdText = kdFrame:FindFirstChild("TX")
		if kdText and kdText:IsA("TextLabel") then
			local kills = profileData.Kills or 0
			local deaths = profileData.Deaths or 0
			kdText.Text = tostring(kills) .. "K / " .. tostring(deaths) .. "D"
		end
	end

	-- Update TimePlayed display (if element exists)
	local timePlayedFrame = menu.Profile:FindFirstChild("TimePlayed")
	if timePlayedFrame then
		local tpText = timePlayedFrame:FindFirstChild("TX")
		if tpText and tpText:IsA("TextLabel") then
			if profileData.Level then
				tpText.Text = "Level " .. tostring(profileData.Level)
			end
		end
	end

	-- Update MainKaiju display (if element exists)
	local mainKaijuFrame = menu.Profile:FindFirstChild("MainKaiju")
	if mainKaijuFrame then
		local mkText = mainKaijuFrame:FindFirstChild("TX")
		if mkText and mkText:IsA("TextLabel") then
			local kaijuName = profileData.MainKaiju or ""
			if kaijuName == "" or kaijuName == "default" or kaijuName == "Default" then
				kaijuName = profileData.EquippedKaiju or ""
			end
			if kaijuName ~= "" and kaijuName ~= "default" and kaijuName ~= "Default" then
				mkText.Text = "Main Kaiju: " .. kaijuName
			else
				mkText.Text = "Main Kaiju: None"
			end
		end
	end

	-- Update DMGDone display (total damage dealt)
	local dmgFrame = menu.Profile:FindFirstChild("DMGDone")
	if dmgFrame then
		local dmgText = dmgFrame:FindFirstChild("TX")
		if dmgText and dmgText:IsA("TextLabel") then
			local totalDmg = profileData.TotalDamage or 0
			local dmgStr
			if totalDmg >= 1000000 then
				dmgStr = string.format("%.1fM", totalDmg / 1000000)
			elseif totalDmg >= 1000 then
				dmgStr = string.format("%.1fK", totalDmg / 1000)
			else
				dmgStr = tostring(totalDmg)
			end
			dmgText.Text = "Damage: " .. dmgStr
		end
	end

	-- Update BestCombo display (if element exists)
	local bestComboFrame = menu.Profile:FindFirstChild("BestCombo")
	if bestComboFrame then
		local bcText = bestComboFrame:FindFirstChild("TX")
		if bcText and bcText:IsA("TextLabel") then
			local bestCombo = profileData.BestCombo or 0
			bcText.Text = "Best Combo: " .. tostring(bestCombo) .. "x"
		end
	end
end

-- Helper: Show an error message on the profile display
local function showProfileError(errorMsg)
	local playerHolder = menu.Profile:FindFirstChild("PlayerHolder")
	if playerHolder then
		local playerName = playerHolder:FindFirstChild("PlayerName")
		if playerName and playerName:IsA("TextLabel") then
			playerName.Text = errorMsg or "Error"
		end
		local playerImage = playerHolder:FindFirstChild("PlayerImage")
		if playerImage and playerImage:IsA("ImageLabel") then
			playerImage.Image = ""
		end
	end
	local kdFrame = menu.Profile:FindFirstChild("KD")
	if kdFrame then
		local kdText = kdFrame:FindFirstChild("TX")
		if kdText and kdText:IsA("TextLabel") then
			kdText.Text = "--K / --D"
		end
	end
	local mainKaijuFrame = menu.Profile:FindFirstChild("MainKaiju")
	if mainKaijuFrame then
		local mkText = mainKaijuFrame:FindFirstChild("TX")
		if mkText and mkText:IsA("TextLabel") then
			mkText.Text = "--"
		end
	end
	local dmgFrame = menu.Profile:FindFirstChild("DMGDone")
	if dmgFrame then
		local dmgText = dmgFrame:FindFirstChild("TX")
		if dmgText and dmgText:IsA("TextLabel") then
			dmgText.Text = "--"
		end
	end
	local bestComboFrame = menu.Profile:FindFirstChild("BestCombo")
	if bestComboFrame then
		local bcText = bestComboFrame:FindFirstChild("TX")
		if bcText and bcText:IsA("TextLabel") then
			bcText.Text = "--"
		end
	end
end

-- LoadProfile response handler: update profile display with received data
local loadProfileEvent = events and events:FindFirstChild("LoadProfile")
if loadProfileEvent and loadProfileEvent:IsA("RemoteEvent") then
	loadProfileEvent.OnClientEvent:Connect(function(success, dataOrError)
		if success and type(dataOrError) == "table" then
			updateProfileDisplay(dataOrError)
		elseif not success and type(dataOrError) == "string" then
			menu.Profile:SetAttribute("ViewedRank", nil)
			showProfileError(dataOrError)
		end
	end)
end

-- Profile button: load own profile and clear text fields
local profileBtn = menu.MainMenu.Profile:FindFirstChild("Button")
if profileBtn then
	profileBtn.MouseButton1Down:Connect(function()
		-- Clear text fields
		local enterNameTxt = menu.Profile.EnterName:FindFirstChild("TXT")
		local enterPictureTxt = menu.Profile.EnterPicture:FindFirstChild("TXT")
		if enterNameTxt then enterNameTxt.Text = "" end
		if enterPictureTxt then enterPictureTxt.Text = "" end

		-- Load own profile via LoadProfile
		if loadProfileEvent then
			loadProfileEvent:FireServer(player.Name)
		end

		-- Also fire CheckProfile for backward compatibility
		if events and events:FindFirstChild("CheckProfile") then
			events.CheckProfile:FireServer(player.Name, true)
		end
	end)
end

-- EnterPicture FocusLost: set profile image via ChangeIMAGE
local enterPictureTxt = menu.Profile.EnterPicture:FindFirstChild("TXT")
if enterPictureTxt then
	enterPictureTxt.FocusLost:Connect(function()
		if enterPictureTxt.Text ~= "" then
			local imageId = enterPictureTxt.Text

			-- Fire ChangeIMAGE with "ProfileImage" as the target name
			if events and events:FindFirstChild("ChangeIMAGE") then
				events.ChangeIMAGE:FireServer("ProfileImage", imageId)
			end

			-- Update display immediately
			local playerImage = menu.Profile.PlayerHolder:FindFirstChild("PlayerImage")
			if playerImage and playerImage:IsA("ImageLabel") then
				playerImage.Image = "rbxassetid://" .. imageId
			end
		end
	end)
end

-- EnterName FocusLost: load another player's profile via LoadProfile
local enterNameTxt = menu.Profile.EnterName:FindFirstChild("TXT")
if enterNameTxt then
	enterNameTxt.FocusLost:Connect(function()
		if enterNameTxt.Text ~= "" then
			local targetName = enterNameTxt.Text

			-- Fire LoadProfile to request the target player's data
			if loadProfileEvent then
				loadProfileEvent:FireServer(targetName)
			end

			-- Slide profile out, wait, then slide back in
			TweenService:Create(menu.Profile, TweenInfo.new(0.25), {
				Position = menu.Profile.Positions.StartPos.Position
			}):Play()
			task.wait(2.5)
			TweenService:Create(menu.Profile, TweenInfo.new(0.25), {
				Position = menu.Profile.Positions.EndPos.Position
			}):Play()
		end
	end)
end

--==========================================================================
-- PATCH 15: Rewards Buy button (buy season pass for 1000 GCells)
--==========================================================================

local buySeasonBtn = menu.Rewards.Rewards.Buy.BuySeason.Button:FindFirstChild("Button")
if buySeasonBtn then
	buySeasonBtn.MouseButton1Down:Connect(function()
		if inventory.GCells.Value >= 1000 and inventory.Rewards.Owned.Value == false then
			events.BuyItem:FireServer(1000, "RewardsSeasonPass")
			if sounds and sounds:FindFirstChild("Click") then sounds.Click:Play() end
		elseif inventory.GCells.Value < 1000 and inventory.Rewards.Owned.Value == false then
			buySeasonBtn.TXT.Text = "Not enough GCells"
			task.wait(0.75)
			buySeasonBtn.TXT.Text = "Buy : 1000G"
		end
	end)
end

--==========================================================================
-- PATCH 16: Menu toggle (open/close via MenuButton and M key)
--==========================================================================

-- Helper: Open the menu (slide MainMenu in)
local function openMenu()
	if isBusy then return end
	isBusy = true
	isMenuOpen = true
	menu.MainMenu.Visible = true
	menu.Visible = true
	menu.PlayerInfo:TweenPosition(UDim2.new(0, 0, 0, 0), "InOut", "Linear", 0.45)
	menu.PlayerInfo.Visible = true
	-- Hide GameGui character controls
	local gameGuiObj = player.PlayerGui:FindFirstChild("GameGui")
	if gameGuiObj and gameGuiObj:FindFirstChild("Character") then
		if gameGuiObj:FindFirstChild("Character") then if gameGuiObj:FindFirstChild("Character") then gameGuiObj.Character.Visible = false end end
	end
	if sounds and sounds:FindFirstChild("Slide") then sounds.Slide:Play() end
	-- Tween MainMenu in
	local tween = TweenService:Create(menu.MainMenu, TweenInfo.new(menu.MainMenu:FindFirstChild("TweenSpeed") and (menu.MainMenu:FindFirstChild("TweenSpeed") and menu.MainMenu.TweenSpeed.Value or 0.2)), {
		Position = menu.MainMenu.Positions.EndPos.Position
	})
	tween:Play()
	tween.Completed:Connect(function()
		isBusy = false
	end)
	currentPanel = menu.MainMenu
	-- Refresh player info when menu opens
	UnlockImages("All")
end

-- Helper: Close the menu (slide MainMenu out + hide all sub-panels)
local function closeMenu()
	if isBusy then return end
	isBusy = true
	isMenuOpen = false
	if sounds and sounds:FindFirstChild("Slide") then sounds.Slide:Play() end
	-- Re-enable GameGui
	local gameGuiObj = player.PlayerGui:FindFirstChild("GameGui")
	if gameGuiObj then
		gameGuiObj.Enabled = true
		if gameGuiObj:FindFirstChild("Character") then
			if gameGuiObj:FindFirstChild("Character") then if gameGuiObj:FindFirstChild("Character") then gameGuiObj.Character.Visible = true end end
		end
	end
	-- Tween MainMenu out
	TweenService:Create(menu.MainMenu, TweenInfo.new(menu.MainMenu:FindFirstChild("TweenSpeed") and (menu.MainMenu:FindFirstChild("TweenSpeed") and menu.MainMenu.TweenSpeed.Value or 0.2)), {
		Position = menu.MainMenu.Positions.StartPos.Position
	}):Play()
	-- Slide out and hide all sub-panels (any panel with Positions)
	for _, child in menu:GetChildren() do
		if child ~= menu.MainMenu and child ~= menu.PlayerInfo and child ~= menu.Prompt and child ~= menu.Drops and child ~= menu.Emotes then
			local positions = child:FindFirstChild("Positions")
			if positions then
				local startPos = positions:FindFirstChild("StartPos")
				if startPos then
					local tweenSpeed = child:FindFirstChild("TweenSpeed")
					local speed = tweenSpeed and tweenSpeed.Value or 0.2
					local panelTween = TweenService:Create(child, TweenInfo.new(speed), {
						Position = startPos.Position
					})
					panelTween:Play()
					panelTween.Completed:Connect(function()
						child.Visible = false
					end)
				end
			end
		end
	end
	-- Also hide ModeMenus sub-panels
	if menu:FindFirstChild("ModeMenus") then
		for _, modePanel in menu.ModeMenus:GetChildren() do
			local positions = modePanel:FindFirstChild("Positions")
			if positions then
				local startPos = positions:FindFirstChild("StartPos")
				if startPos then
					local tweenSpeed = modePanel:FindFirstChild("TweenSpeed")
					local speed = tweenSpeed and tweenSpeed.Value or 0.2
					local panelTween = TweenService:Create(modePanel, TweenInfo.new(speed), {
						Position = startPos.Position
					})
					panelTween:Play()
					panelTween.Completed:Connect(function()
						modePanel.Visible = false
					end)
				end
			end
		end
	end
	-- Clean up kaiju viewport: hide Characters/LeftBar/KaijuMenus, reset camera
	local leftBar = menu.Characters:FindFirstChild("LeftBar")
	if leftBar then
		leftBar.Visible = false
	end
	local characters = menu:FindFirstChild("Characters")
	if characters then
		characters.Visible = false
	end
	local kaijuMenus = menu:FindFirstChild("KaijuMenus")
	if kaijuMenus then
		for _, kaijuPanel in kaijuMenus:GetChildren() do
			if kaijuPanel:IsA("GuiObject") then
				kaijuPanel.Visible = false
			end
		end
	end
	-- Reset camera from Scriptable back to Custom
	if camera.CameraType == Enum.CameraType.Scriptable then
		camera.CameraType = Enum.CameraType.Custom
		local char = player.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then
				camera.CameraSubject = hum
			end
		end
	end
	-- Clean up ViewPortModel (remove cloned kaiju)
	local viewPortModel = workspace:FindFirstChild("ViewPortModel")
	if viewPortModel then
		local existingChar = viewPortModel:FindFirstChild("Char")
		if existingChar then
			existingChar:Destroy()
		end
	end
	-- Reset kaiju selection values
	local kaijuMenuVal = values:FindFirstChild("KaijuMenu")
	if kaijuMenuVal then kaijuMenuVal.Value = nil end
	local kaijuModelVal = values:FindFirstChild("KaijuModel")
	if kaijuModelVal then
		if kaijuModelVal.Value then
			kaijuModelVal.Value:Destroy()
		end
		kaijuModelVal.Value = nil
	end
	local selectedKaijuVal = values:FindFirstChild("SelectedKaiju")
	if selectedKaijuVal then selectedKaijuVal.Value = "" end

	-- Slide out PlayerInfo
	menu.PlayerInfo:TweenPosition(UDim2.new(-0.75, 0, 0, 0), "InOut", "Linear", 0.35)
	task.wait(0.35)
	menu.Visible = false
	menu.MainMenu.Visible = false
	menu.PlayerInfo.Visible = false
	currentPanel = nil
	isBusy = false
end

-- MenuButton click: toggle menu
local menuButton = menu.Parent:FindFirstChild("MenuButton")
if menuButton then
	print("[Deobfuscated] MenuButton found, setting up toggle handler")
	local menuBtn = menuButton:FindFirstChild("Button")
	
	-- Disable Selectable on the child Button to prevent mobile touch-selection issues
	-- (Selectable=true can cause the first tap to "focus" the button instead of activating it)
	if menuBtn then
		menuBtn.Selectable = false
	end
	
	local function toggleMenu()
		if isBusy then return end
		if not isMenuOpen then
			openMenu()
		else
			closeMenu()
		end
	end
	
	-- Connect to child Button only (single connection, no debounce needed)
	if menuBtn then
		menuBtn.Activated:Connect(toggleMenu)
		print("[Deobfuscated] MenuButton.Button Activated handler connected")
	else
		-- Fallback: connect to parent if child Button doesn't exist
		menuButton.Activated:Connect(toggleMenu)
		print("[Deobfuscated] MenuButton parent Activated handler connected (no child Button)")
	end
else
	warn("[Deobfuscated] WARNING: MenuButton not found!")
end

-- M key: toggle menu
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.M and not gameProcessed then
		if isBusy then return end
		if not isMenuOpen then
			openMenu()
		else
			closeMenu()
		end
	end
end)


--==========================================================================
-- PATCH 17: Kaiju selection (KaijuMenu Select button)
--==========================================================================
-- NOTE: Select button handling is now done by KaijuSelectHandler script which
-- properly checks ownership and handles free kaijus. PATCH 17 only handles
-- the Left/Right rotation buttons for the kaiju carousel.

-- When KaijuMenu value changes, connect the rotation buttons
-- Track connections so we can disconnect old ones before creating new ones
-- (prevents stacked handlers that make rotation faster each time)
local kaijuMenuVal = values:FindFirstChild("KaijuMenu")
local prevRotationConnections = {}

if kaijuMenuVal then
	kaijuMenuVal.Changed:Connect(function()
		local kaijuMenuPanel = kaijuMenuVal.Value
		if not kaijuMenuPanel then return end

		-- Disconnect any previous rotation button connections to prevent stacking
		for _, conn in ipairs(prevRotationConnections) do
			conn:Disconnect()
		end
		prevRotationConnections = {}

		-- Reset rotation state flags
		isRotatingLeft = false
		isRotatingRight = false

		kaijuMenuConnectCount += 1

		-- Left/Right rotation buttons for kaiju carousel
		local leftBtn = kaijuMenuPanel:FindFirstChild("Left")
		if leftBtn then
			table.insert(prevRotationConnections, leftBtn.MouseButton1Down:Connect(function()
				isRotatingLeft = true
				while isRotatingLeft do
					local kaijuModelVal = values:FindFirstChild("KaijuModel")
					if kaijuModelVal and kaijuModelVal.Value and kaijuModelVal.Value:FindFirstChild("HumanoidRootPart") then
						kaijuModelVal.Value.HumanoidRootPart.CFrame = kaijuModelVal.Value.HumanoidRootPart.CFrame * CFrame.Angles(0, -0.085, 0)
					end
					task.wait(0.025)
				end
			end))
			table.insert(prevRotationConnections, leftBtn.MouseButton1Up:Connect(function()
				isRotatingLeft = false
			end))
			table.insert(prevRotationConnections, leftBtn.MouseLeave:Connect(function()
				isRotatingLeft = false
			end))
		end

		local rightBtn = kaijuMenuPanel:FindFirstChild("Right")
		if rightBtn then
			table.insert(prevRotationConnections, rightBtn.MouseButton1Down:Connect(function()
				isRotatingRight = true
				while isRotatingRight do
					local kaijuModelVal = values:FindFirstChild("KaijuModel")
					if kaijuModelVal and kaijuModelVal.Value and kaijuModelVal.Value:FindFirstChild("HumanoidRootPart") then
						kaijuModelVal.Value.HumanoidRootPart.CFrame = kaijuModelVal.Value.HumanoidRootPart.CFrame * CFrame.Angles(0, 0.085, 0)
					end
					task.wait(0.025)
				end
			end))
			table.insert(prevRotationConnections, rightBtn.MouseButton1Up:Connect(function()
				isRotatingRight = false
			end))
			table.insert(prevRotationConnections, rightBtn.MouseLeave:Connect(function()
				isRotatingRight = false
			end))
		end
	end)
end

--==========================================================================
-- PATCH 18: Feed notification system
--==========================================================================

local feedContainer = menu.Parent:FindFirstChild("Feed")
if feedContainer then
	local innerFeed = feedContainer:FindFirstChild("Feed")
	if innerFeed then
	innerFeed.ChildAdded:Connect(function(feedItem)
		feedItem:WaitForChild("Chime")
		-- Wait for any existing feed animation to finish
		while isFeedBusy do
			task.wait(0.08)
		end

		if feedItem then
			isFeedBusy = true
			feedItem.Position = menu.Parent.Feed.Feed.Spots.Feed1.Position
			feedItem.Chime:Play()

			-- Slide feed item in
			TweenService:Create(feedItem, TweenInfo.new(0.075), {
				Position = UDim2.new(0.75, 0, feedItem.Position.Y.Scale, 0)
			}):Play()
			task.wait(0.08)

			-- Shift other feed items down
			for _, otherItem in innerFeed:GetChildren() do
				if otherItem ~= feedItem and otherItem:IsA("Frame") and feedItem then
					if otherItem.Position.Y.Scale == feedItem.Position.Y.Scale then
						feedItem.Position = UDim2.new(0.75, 0, feedItem.Position.Y.Scale + 0.062, 0)
					end
				end
			end

			isFeedBusy = false

			-- Wait then slide out and destroy
			task.wait(5)
			if feedItem then
				TweenService:Create(feedItem, TweenInfo.new(0.075), {
					Position = UDim2.new(1.15, 0, feedItem.Position.Y.Scale, 0)
				}):Play()
				task.wait(0.08)
				feedItem:Destroy()
			end
		end
	end)
	end
end

--==========================================================================
-- PATCH 19: Gamepad support (ButtonB close, ButtonY select)
--==========================================================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	-- ButtonB: close prompt
	if input.KeyCode == Enum.KeyCode.ButtonB then
		if menu.Prompt.PromptImage.Visible then
			if sounds and sounds:FindFirstChild("Click") then sounds.Click:Play() end
			menu.Prompt.Visible = false
		end
	end

	-- ButtonY: select/buy/equip (same as Prompt Select button)
	if input.KeyCode == Enum.KeyCode.ButtonY then
		if menu.Prompt.PromptImage.Visible and not isBusy then
			isBusy = true
			if sounds and sounds:FindFirstChild("Click") then sounds.Click:Play() end

			local selItem, owned, parentName, grandParent = getSelectedInfo()
			if not selItem then isBusy = false return end

			if owned == false then
				local costAttr = selItem:GetAttribute("Onsale")
				local gcells = inventory.GCells.Value
				local costVal = selItem:FindFirstChild("Cost")
				local cost = costVal and costVal.Value or 0

				if gcells >= cost and costAttr == true then
					menu.Prompt.PromptImage.PromptInfo.Text = "Bought Item!"
					events.BuyItem:FireServer(cost, costVal)
					task.wait(0.35)
					menu.Prompt.Visible = false
					isBusy = false
					return
				elseif costAttr == true and cost > gcells then
					local prevText = menu.Prompt.PromptImage.PromptInfo.Text
					menu.Prompt.PromptImage.PromptInfo.Text = "Not enough GCells!"
					task.wait(0.5)
					menu.Prompt.PromptImage.PromptInfo.Text = prevText
					isBusy = false
					return
				end
			end

			-- Equip skins
			if owned == true and parentName.Name == "Skins" then
				menu.Prompt.PromptImage.PromptInfo.Text = "Equipped Item!"
				events.EquipSkin:FireServer(selItem)
				task.wait(0.35)
				menu.Prompt.Visible = false
				isBusy = false
				return
			end

			task.wait(0.15)
			isBusy = false
		end
	end
end)

--==========================================================================
-- PATCH 20: Initial profile load (CheckProfile + LoadProfile for own profile)
--==========================================================================

if events and events:FindFirstChild("CheckProfile") then
	events.CheckProfile:FireServer(player.Name, true)
end
-- Also load own profile data to populate the display
if events and events:FindFirstChild("LoadProfile") then
	events.LoadProfile:FireServer(player.Name)
end

--==========================================================================
-- PATCH 21: Lootbox Open button + RollItem function
--==========================================================================

-- Rarity thresholds (random 0-950)
-- 0-90: Legendary, 91-225: Epic, 226-465: Rare, 467-950: Uncommon
local RARITY_THRESHOLDS = {
	{max = 90, name = "Legendary"},
	{max = 225, name = "Epic"},
	{max = 465, name = "Rare"},
	{max = 950, name = "Uncommon"},
}

-- XP amounts by rarity
local XP_BY_RARITY = {Uncommon = 150, Rare = 275, Epic = 425, Legendary = 585}
-- GCell amounts by rarity
local GCELLS_BY_RARITY = {Uncommon = 10, Rare = 25, Epic = 55, Legendary = 125}

-- Color mapping
local RARITY_COLORS = {
	Uncommon = COLOR_UNCOMMON,
	Rare = COLOR_RARE,
	Epic = COLOR_EPIC,
	Legendary = COLOR_LEGENDARY,
}

-- Item type pools by lootbox slot
local ITEM_POOLS = {
	Item1 = {"GCells", "XP", "Skins", "Emotes"}, -- random 1-11 mapped
	Item2 = {"Skins", "Emotes", "GCells", "XP"}, -- random 1-10 mapped
	Item3 = {"GCells", "XP", "Emotes", "Skins"}, -- random 1-11 mapped
}

-- RollItem: determines the item type, rarity, and populates the drop display
-- Returns: rewardType (string), rewardName (string), amount (number), rarity (string)
--   rewardType: "XP", "GCells", "Skin", "Emote"
--   rewardName: item name for skins/emotes, or same as rewardType for currency
--   amount: numeric amount for XP/GCells
--   rarity: rarity string
local function RollItem(dropFrame)
	local roll = math.random(0, 950)
	local itemType = nil
	local rarity = nil
	local amount = 0

	-- Determine rarity from roll
	for _, threshold in RARITY_THRESHOLDS do
		if roll <= threshold.max then
			rarity = threshold.name
			break
		end
	end
	if not rarity then rarity = "Uncommon" end

	-- Determine item type from the drop frame name
	local slotName = dropFrame.Name
	if slotName == "Item1" then
		local types = {"GCells", "GCells", "GCells", "XP", "XP", "XP", "Skins", "Skins", "Skins", "Emotes", "Emotes"}
		itemType = types[math.random(1, 11)]
	elseif slotName == "Item2" then
		local types = {"Skins", "Skins", "Skins", "Emotes", "Emotes", "Emotes", "GCells", "GCells", "XP", "XP"}
		itemType = types[math.random(1, 10)]
	elseif slotName == "Item3" then
		local types = {"GCells", "GCells", "GCells", "XP", "XP", "XP", "Emotes", "Emotes", "Emotes", "Skins", "Skins"}
		itemType = types[math.random(1, 11)]
	end

	-- Kaiju drop override: if Legendary rarity, 30% chance to get a kaiju instead
	if rarity == "Legendary" and math.random(1, 10) <= 3 then
		itemType = "Kaiju"
	end

	-- Emotes are always Rare rarity
	if itemType == "Emotes" then
		rarity = "Rare"
	end

	local color = RARITY_COLORS[rarity] or COLOR_UNCOMMON

	-- Process XP reward
	if itemType == "XP" then
		amount = XP_BY_RARITY[rarity] or 150
		dropFrame.ItemImage.Image = "http://www.roblox.com/asset/?id=293541673"
		dropFrame.ItemName.TextColor3 = color
		dropFrame.ItemName.TextStrokeColor3 = color
		dropFrame.ItemName.Text = amount .. " XP"
		return "XP", "XP", amount, rarity
	end

	-- Process GCells reward
	if itemType == "GCells" then
		amount = GCELLS_BY_RARITY[rarity] or 10
		-- Find matching rarity image in inventory GCells folder
		for _, gcellChild in inventory.GCells:GetChildren() do
			if gcellChild.Name == rarity then
				dropFrame.ItemImage.Image = gcellChild.Image
				break
			end
		end
		dropFrame.ItemName.TextColor3 = color
		dropFrame.ItemName.TextStrokeColor3 = color
		dropFrame.ItemName.Text = amount .. " GCells"
		return "GCells", "GCells", amount, rarity
	end

	-- Process Kaiju reward (rare Legendary drop)
	if itemType == "Kaiju" then
		local KAIJU_DROPS = {"Zilla", "ShowaGigan", "Godzilla2000", "TitanusGodzilla", "Orga", "Destoroyah", "MechaGodzilla2021"}
		-- Filter to only unowned kaijus
		local unownedKaijus = {}
		for _, kaijuName in KAIJU_DROPS do
			local owned = inventory:FindFirstChild(kaijuName)
			if not (owned and owned:IsA("BoolValue") and owned.Value) then
				table.insert(unownedKaijus, kaijuName)
			end
		end
		if #unownedKaijus > 0 then
			local chosenKaiju = unownedKaijus[math.random(1, #unownedKaijus)]
			dropFrame.ItemName.TextColor3 = COLOR_LEGENDARY
			dropFrame.ItemName.TextStrokeColor3 = COLOR_LEGENDARY
			dropFrame.ItemName.Text = chosenKaiju
			-- Try to find kaiju image from KaijuMenus
			local kaijuImage = nil
			local kaijuMenusFolder = menu:FindFirstChild("KaijuMenus")
			if kaijuMenusFolder then
				local kaijuPanel = kaijuMenusFolder:FindFirstChild(chosenKaiju)
				if kaijuPanel then
					local img = kaijuPanel:FindFirstChild("Image")
					if img then
						local imgLabel = img:IsA("ImageLabel") and img or img:FindFirstChildOfClass("ImageLabel")
						if imgLabel then kaijuImage = imgLabel.Image end
					end
				end
			end
			if kaijuImage then
				dropFrame.ItemImage.Image = kaijuImage
			else
				dropFrame.ItemImage.Image = "http://www.roblox.com/asset/?id=293541673"
			end
			return "Kaiju", chosenKaiju, 0, "Legendary"
		else
			-- All kaijus owned: fall back to Legendary GCells
			amount = GCELLS_BY_RARITY["Legendary"] or 125
			for _, gcellChild in inventory.GCells:GetChildren() do
				if gcellChild.Name == "Legendary" then
					dropFrame.ItemImage.Image = gcellChild.Image
					break
				end
			end
			dropFrame.ItemName.TextColor3 = COLOR_LEGENDARY
			dropFrame.ItemName.TextStrokeColor3 = COLOR_LEGENDARY
			dropFrame.ItemName.Text = amount .. " GCells"
			return "GCells", "GCells", amount, "Legendary"
		end
	end

	-- Process Skins or Emotes: find unowned items matching rarity
	if itemType == "Skins" or itemType == "Emotes" then
		local rewardType = (itemType == "Skins") and "Skin" or "Emote"
		local candidates = {}
		for _, invDesc in inventory:GetDescendants() do
			if invDesc:IsA("BoolValue") and invDesc.Value == false then
				-- For skins, only allow Godzilla2000, TitanusGodzilla, and MechaGodzilla2021 skins
				if itemType == "Skins" then
					local skinName = invDesc.Name
					local isAllowed = (string.find(skinName, "Godzilla2000") == 1) or (string.find(skinName, "TitanusGodzilla") == 1) or (string.find(skinName, "MechaGodzilla2021") == 1)
					if not isAllowed then continue end
				end
				-- Check if this item matches the rolled rarity
				local rarityLabel = invDesc:FindFirstChild("Rarity")
				if rarityLabel and rarityLabel:IsA("TextLabel") and rarityLabel.Text == rarity then
					local locked = invDesc:FindFirstChild("Locked")
					if not locked or (locked:IsA("BoolValue") and not locked.Value) then
						table.insert(candidates, invDesc)
					end
				end
			end
		end

		if #candidates > 0 then
			local chosen = candidates[math.random(1, #candidates)]
			local rarityImg = chosen:FindFirstChild("RarityImage")
			if rarityImg and rarityImg:IsA("ImageLabel") then
					dropFrame.ItemImage.Image = rarityImg.Image
				end
				dropFrame.ItemName.Text = chosen.Name
				dropFrame.ItemName.TextColor3 = color
				dropFrame.ItemName.TextStrokeColor3 = color
			return rewardType, chosen.Name, 0, rarity
		end

		-- No matching unowned items: fall back to GCells reward
		amount = GCELLS_BY_RARITY[rarity] or 10
		for _, gcellChild in inventory.GCells:GetChildren() do
			if gcellChild.Name == rarity then
				dropFrame.ItemImage.Image = gcellChild.Image
				break
			end
		end
		dropFrame.ItemName.TextColor3 = color
		dropFrame.ItemName.TextStrokeColor3 = color
		dropFrame.ItemName.Text = amount .. " GCells"
		return "GCells", "GCells", amount, rarity
	end

	-- Fallback: no matching item found, return nil to trigger re-roll
	return nil, nil, 0, nil
end

-- UnlockItems: process a single drop slot (roll, display, fire server event)
local function UnlockItems(dropFrame)
	-- Wait for any previous roll to finish
	while isLootboxRolling do
		task.wait()
	end
	isLootboxRolling = true

	local rewardType, rewardName, amount, rarity = RollItem(dropFrame)

	-- If no item found, re-roll until we get one
	while not rewardType do
		task.wait()
		rewardType, rewardName, amount, rarity = RollItem(dropFrame)
	end

	-- Show the Drops panel and fire the unlock event with proper parameters
	menu.Drops.Visible = true
	events.LootboxUnlock:FireServer(rewardType, rewardName, amount, rarity)

	-- Brief wait for server to process the unlock
	task.wait(0.15)

	isLootboxRolling = false
end

-- Lootbox Open button: full open flow with animation
local openBtn = menu.Lootbox:FindFirstChild("Open")
if openBtn then
	local openButton = openBtn:FindFirstChild("Button")
	if openButton then
		openButton.MouseButton1Down:Connect(function()
			-- If busy and Drops is visible, reset and close
			if isBusy and menu.Drops.Visible then
				local whiteFlash = menu.Lootbox.ECT:FindFirstChild("WhiteFlash")
				if whiteFlash and whiteFlash.Visible == false then
					local _lbRoom = workspace:FindFirstChild("Lootbox Room")
				local _lbCam = _lbRoom and _lbRoom:FindFirstChild("Cam")
				if _lbCam and (camera.CFrame.Position - _lbCam.CFrame.Position).Magnitude < 1 then
						menu.Drops.Visible = false
						isBusy = false
					end
				end
				return
			end

			-- Check lootbox count
			if inventory.Lootboxes.Value > 0 and not isBusy then
				local whiteFlash = menu.Lootbox.ECT:FindFirstChild("WhiteFlash")
				if whiteFlash and not whiteFlash.Visible and not menu.Drops.Visible then
					isBusy = true

					-- Play chest shake sound
					if sounds and sounds:FindFirstChild("ChestShake") then sounds.ChestShake:Play() end
					task.wait(0.45)

					-- Play chest open animation
local animTrack = nil
					local anim = Instance.new("Animation")
					anim.AnimationId = "http://www.roblox.com/asset/?id=137345436387190"
					local lootboxModel = workspace:FindFirstChild("Lootbox Room")
					if lootboxModel and lootboxModel:FindFirstChild("LootBox") then
						local humanoid = lootboxModel.LootBox:FindFirstChildOfClass("Humanoid")
						if humanoid then
							local track = humanoid:LoadAnimation(anim)
							track:Play()
animTrack = track
						end
					end

					task.wait(0.3)
					if sounds and sounds:FindFirstChild("Chestopen") then sounds.Chestopen:Play() end
					task.wait(0.2)
					if sounds and sounds:FindFirstChild("ChestShine") then sounds.ChestShine:Play() end

					-- White flash effect
					whiteFlash.Visible = true
					TweenService:Create(whiteFlash, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
					task.wait(0.2)

					-- Reveal 3 items sequentially
					UnlockItems(menu.Drops.Item1)
					while isLootboxRolling do task.wait(0.01) end
					UnlockItems(menu.Drops.Item2)
					while isLootboxRolling do task.wait(0.01) end
					UnlockItems(menu.Drops.Item3)

					task.wait(0.3)

					-- Deduct lootbox and reset
					local deductEvent = events:FindFirstChild("LootboxDeduct")
					if deductEvent then
						deductEvent:FireServer()
					end

					-- Stop the specific animation track (matching WorkGui)
					if lootboxModel and lootboxModel:FindFirstChild("LootBox") then
						local humanoid = lootboxModel.LootBox:FindFirstChildOfClass("Humanoid")
						if humanoid then
							if lootboxModel and lootboxModel:FindFirstChild("LootBox") then
								animTrack:Stop(0.1)
							end
						end
					end

					-- Reset camera to lootbox room
					TweenService:Create(camera, TweenInfo.new(0.2), {
						CFrame = workspace:FindFirstChild("Lootbox Room") and workspace["Lootbox Room"]:FindFirstChild("Cam") and workspace["Lootbox Room"].Cam.CFrame or camera.CFrame
					}):Play()
					task.wait(0.2)

					-- Fade out white flash
					TweenService:Create(whiteFlash, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
					task.wait(0.3)
					whiteFlash.Visible = false

					isBusy = false
				end
			end
		end)
	end
end

--==========================================================================
-- PATCH 22: Skin/Emote store item selection (DISABLED - handled by KaijuSelectHandler)
--==========================================================================
-- This patch was removed to avoid conflicts with KaijuSelectHandler, which
-- properly handles skin/emote selection with model preview and free skin auto-equip.

--==========================================================================
-- PATCH 23: Button hover effects (scroll sound + transparency)
--==========================================================================

for _, descendant in menu:GetDescendants() do
	if descendant:IsA("TextButton") and descendant.Name == "Button" then
		local parent = descendant.Parent
		if parent and parent:IsA("GuiObject") then
			local originalTransparency = parent.ImageTransparency

			descendant.MouseEnter:Connect(function()
				local scrollSound = sounds:FindFirstChild("Scroll")
				if scrollSound then
					local clone = scrollSound:Clone()
					clone.PlayOnRemove = true
					clone.Parent = script
					clone:Destroy()
				end
				parent.ImageTransparency = 0
			end)

			descendant.MouseLeave:Connect(function()
				parent.ImageTransparency = originalTransparency
			end)
		end
	end
end

--==========================================================================
-- PATCH 24: Inventory sub-navigation (Kaijus, GCells, Gamepasses, Lootboxes buttons)
--==========================================================================

-- Helper: find the navigation target from a button's Object values
-- For buttons with 2 Object values, picks the one that's not the current panel
local function getNavTargetFromButton(btn, currentPanel)
	for _, child in btn:GetChildren() do
		if child:IsA("ObjectValue") and child.Name == "Object" and child.Value then
			if child.Value ~= currentPanel then
				return child.Value
			end
		end
	end
	-- Fallback: return first Object value found
	for _, child in btn:GetChildren() do
		if child:IsA("ObjectValue") and child.Name == "Object" and child.Value then
			return child.Value
		end
	end
	return nil
end

-- Inventory.Kaijus button: navigate to Characters LeftBar, or clean up if already visible
local kaijusBtn = menu.Inventory:FindFirstChild("Kaijus")
if kaijusBtn then
	local btn = kaijusBtn:FindFirstChild("Button")
	if btn then
		local targetPanel = getNavTargetFromButton(btn, menu.Inventory)
		btn.MouseButton1Down:Connect(function()
			local leftBar = menu.Characters:FindFirstChild("LeftBar")
			local leftBarStartPos = leftBar and leftBar:FindFirstChild("Positions") and leftBar.Positions:FindFirstChild("StartPos")
			local isLeftBarShown = leftBarStartPos and (leftBar.Position.X.Scale > leftBarStartPos.Position.X.Scale + 0.01)
			if isLeftBarShown then
				-- LeftBar already shown: tween it back and clean up ViewPortModel
				leftBar:TweenPosition(leftBarStartPos.Position)
				task.wait(0.1)
				local viewPortModel = workspace:FindFirstChild("ViewPortModel")
				if viewPortModel then
					for _, child in viewPortModel:GetChildren() do
						if child.Name == "Char" then
							child:Destroy()
						end
					end
				end

				-- Check if a kaiju model is selected
				local kaijuModelVal = values:FindFirstChild("KaijuModel")
				if kaijuModelVal and kaijuModelVal.Value then
					-- Reset camera
					camera.CameraType = Enum.CameraType.Custom
					local char = player.Character
					if char and char:FindFirstChildOfClass("Humanoid") then
						camera.CameraSubject = char:FindFirstChildOfClass("Humanoid")
					end
					kaijuModelVal.Value:Destroy()
					kaijuModelVal.Value = nil
					values.SelectedKaiju.Value = ""
					local kaijuMenuVal = values:FindFirstChild("KaijuMenu")
					if kaijuMenuVal then kaijuMenuVal.Value = nil end
				end
				currentPanel = nil
			elseif targetPanel then
				-- LeftBar not shown: slide it in while keeping Inventory open
				if targetPanel.Parent then
					targetPanel.Parent.Visible = true
				end
				TweenToPanel(targetPanel)
				currentPanel = targetPanel
			end
		end)
	end
end

-- Inventory.GCells, Gamepasses, Lootboxes buttons: close LeftBar if visible, then navigate
for _, btnName in {"GCells", "Gamepasses", "Lootboxes"} do
	local invBtn = menu.Inventory:FindFirstChild(btnName)
	if invBtn then
		local btn = invBtn:FindFirstChild("Button")
		if btn then
			local targetPanel = getNavTargetFromButton(btn, menu.Inventory)
			btn.MouseButton1Down:Connect(function()
				-- Close LeftBar if shown (check position, not Visible since Visible is always true)
				local leftBar = menu.Characters:FindFirstChild("LeftBar")
				local leftBarStartPos = leftBar and leftBar:FindFirstChild("Positions") and leftBar.Positions:FindFirstChild("StartPos")
				if leftBar and leftBarStartPos and (leftBar.Position.X.Scale > leftBarStartPos.Position.X.Scale + 0.01) then
					leftBar:TweenPosition(leftBarStartPos.Position)
					task.wait(0.25)
					currentPanel = nil
				end
				-- Navigate to target panel
				if targetPanel then
					NavigateTo(targetPanel)
				end
			end)
		end
	end
end

--==========================================================================
-- PATCH 24.5: Settings sub-navigation (Keybinds button -> Keybinds panel)
--==========================================================================

-- Settings.Keybinds button: navigate from Settings to Keybinds panel
local keybindsNavBtn = menu.Settings:FindFirstChild("Keybinds")
if keybindsNavBtn then
	local btn = keybindsNavBtn:FindFirstChild("Button")
	if btn then
		local targetPanel = getNavTargetFromButton(btn, menu.Settings)
		if targetPanel then
			btn.MouseButton1Down:Connect(function()
				NavigateTo(targetPanel)
			end)
		end
	end
end

--==========================================================================
-- PATCH 25: Kaiju selection from Selection list
--==========================================================================

-- When clicking a kaiju in a Selection list, set KaijuMenu value
for _, descendant in menu:GetDescendants() do
	if descendant:IsA("TextButton") and descendant.Name == "Button" then
		local parent = descendant.Parent
		local grandparent = parent and parent.Parent
		if grandparent and grandparent.Name == "Selection" then
			local obj = descendant:FindFirstChild("Object")
			if obj and obj:IsA("ObjectValue") and obj.Value then
			descendant.MouseButton1Down:Connect(function()
					if isBusy then return end
					-- Don't re-select if already viewing this kaiju
					local kaijuMenuVal = values:FindFirstChild("KaijuMenu")
					if kaijuMenuVal and kaijuMenuVal.Value == obj.Value then return end

					isBusy = true
					menu.Prompt.Visible = false
					if sounds and sounds:FindFirstChild("Click") then sounds.Click:Play() end

					-- Set the KaijuMenu value (triggers PATCH 17 handler)
					if kaijuMenuVal then
						kaijuMenuVal.Value = obj.Value
					end
					values.SelectedKaiju.Value = obj.Value.Name

					-- Clone kaiju model into ViewPortModel for display
					local viewPortModel = workspace:FindFirstChild("ViewPortModel")
					if viewPortModel then
						-- Remove existing Char
						local existingChar = viewPortModel:FindFirstChild("Char")
						if existingChar then existingChar:Destroy() end

						-- Resolve the kaiju model to display: equipped skin if owned, else default
						local kaijuName = values.SelectedKaiju.Value
						local kaijuModelObj = parent:FindFirstChild("KaijuModel")
						local kaijuModel = nil

						-- Check player's equipped skin for this kaiju
						local inventory = player:FindFirstChild("Inventory")
						print("[SKIN-DEBUG] Kaiju: " .. tostring(kaijuName) .. ", Inventory found: " .. tostring(inventory ~= nil))
						if inventory then
							-- Try per-kaiju skin first, then global skin
							local skinsFolder = inventory:FindFirstChild("Skins")
							local skinVal = skinsFolder and skinsFolder:FindFirstChild(kaijuName)
							print("[SKIN-DEBUG] SkinsFolder: " .. tostring(skinsFolder ~= nil) .. ", skinVal: " .. tostring(skinVal ~= nil))
							local equippedSkin = skinVal and skinVal.Value or ""
							print("[SKIN-DEBUG] Per-kaiju skin value: " .. tostring(equippedSkin))
							if equippedSkin == "" then
								local globalSkin = inventory:FindFirstChild("Skin")
								equippedSkin = globalSkin and globalSkin.Value or ""
								print("[SKIN-DEBUG] Global skin value: " .. tostring(equippedSkin))
							end

							-- The full skin name (e.g. "Godzilla2000-Charcoal") is what the ownership BoolValue is named.
							-- The stripped name (e.g. "Charcoal") is used for model lookup.
							local fullSkinName = equippedSkin

							-- Check ownership using the FULL skin name (matches BoolValue name from BuyItem)
							local ownsSkin = fullSkinName == "Default" or fullSkinName == ""
							if not ownsSkin and fullSkinName ~= "" then
								local ownVal = inventory:FindFirstChild(fullSkinName)
								print("[SKIN-DEBUG] Ownership check (full): ownVal=" .. tostring(ownVal ~= nil) .. " name=" .. fullSkinName)
								ownsSkin = ownVal and ownVal:IsA("BoolValue") and ownVal.Value or false
							end
							print("[SKIN-DEBUG] ownsSkin: " .. tostring(ownsSkin))

							-- Strip kaiju name prefix if present (e.g. "Godzilla2000-Charcoal" -> "Charcoal") for model lookup
							local dashPos = string.find(equippedSkin, "-", 1, true)
							if dashPos then
								equippedSkin = string.sub(equippedSkin, dashPos + 1)
							end
							print("[SKIN-DEBUG] Stripped skin name for model lookup: " .. tostring(equippedSkin))

							-- Resolve the skin model from ReplicatedStorage if owned
							if ownsSkin and equippedSkin ~= "" and equippedSkin ~= "Default" then
								local modelsRoot = ReplicatedStorage:FindFirstChild("Assets")
								modelsRoot = modelsRoot and modelsRoot:FindFirstChild("Kaijus")
								modelsRoot = modelsRoot and modelsRoot:FindFirstChild("Models")
								if modelsRoot then
									local kaijuFolder = modelsRoot:FindFirstChild(kaijuName)
									print("[SKIN-DEBUG] KaijuFolder: " .. tostring(kaijuFolder ~= nil) .. " for " .. tostring(kaijuName))
									if kaijuFolder then
										-- Try full name first (e.g. "Godzilla2000-Charcoal"), then stripped name
										local skinModel = kaijuFolder:FindFirstChild(fullSkinName)
										print("[SKIN-DEBUG] Full-name skin model: " .. tostring(skinModel ~= nil))
										if not skinModel or not skinModel:IsA("Model") then
											skinModel = kaijuFolder:FindFirstChild(equippedSkin)
											print("[SKIN-DEBUG] Stripped-name skin model: " .. tostring(skinModel ~= nil))
										end
										if not skinModel or not skinModel:IsA("Model") then
											skinModel = kaijuFolder:FindFirstChild(kaijuName .. "-" .. equippedSkin)
											print("[SKIN-DEBUG] Constructed full-name skin model: " .. tostring(skinModel ~= nil))
										end
										if skinModel and skinModel:IsA("Model") then
											kaijuModel = skinModel:Clone()
											print("[SKIN-DEBUG] Successfully cloned skin model: " .. skinModel.Name)
										end
									end
								else
									print("[SKIN-DEBUG] Models root not found!")
								end
							else
								print("[SKIN-DEBUG] Skipping skin resolve: ownsSkin=" .. tostring(ownsSkin) .. " skin=" .. tostring(equippedSkin))
							end
						end

						-- Fall back to default model if no skin model was resolved
						if not kaijuModel then
							print("[SKIN-DEBUG] Falling back to default model")
							kaijuModel = kaijuModelObj and kaijuModelObj.Value and kaijuModelObj.Value:Clone()
						end
						if not kaijuModel then
							task.wait(0.15)
							isBusy = false
							return
						end
						kaijuModel.Name = "Char"
						-- Store clone in values.KaijuModel for cleanup later
						local kmVal = values:FindFirstChild("KaijuModel")
						if kmVal then kmVal.Value = kaijuModel end

						-- Anchor for setup
					local hrp = kaijuModel:FindFirstChild("HumanoidRootPart")
					if hrp then hrp.Anchored = true end

						kaijuModel.Parent = viewPortModel

						-- Position at CharSpot (stand on top, accounting for HRP half-height)
					local charSpot = viewPortModel:FindFirstChild("CharSpot")
					if charSpot and hrp then
						local humanoid = kaijuModel:FindFirstChildOfClass("Humanoid")
						local hipY = humanoid and humanoid.HipHeight or 0
						local groundY = charSpot.CFrame.Y + charSpot.Size.Y/2
						hrp.CFrame = CFrame.new(charSpot.CFrame.X, groundY + hipY + hrp.Size.Y/2, charSpot.CFrame.Z)
					end

					-- Keep HRP anchored so character stands on non-collidable CharSpot without falling
					if hrp then hrp.Anchored = true end

					-- Play idle animation from Animations folder in ReplicatedStorage
					local humanoid = kaijuModel:FindFirstChildOfClass("Humanoid")
					if humanoid then
						local kaijuName = values.SelectedKaiju.Value
						local animationsRoot = ReplicatedStorage:FindFirstChild("Animations")
						if animationsRoot and kaijuName then
							local kaijuAnimFolder = animationsRoot:FindFirstChild(kaijuName)
							if not kaijuAnimFolder then
								-- Fallback: try mapped animation folder name (e.g. "ShowaGigan" -> "Gigan")
								local animNameMap = {["ShowaGigan"] = "Gigan", ["DummyG2K"] = "Zilla", ["DummyG2k"] = "Zilla"}
								local mappedName = animNameMap[kaijuName]
								if mappedName then
									kaijuAnimFolder = animationsRoot:FindFirstChild(mappedName)
								end
							end
							if kaijuAnimFolder then
								local animFolder = kaijuAnimFolder:FindFirstChild("Animations")
								if animFolder then
									local idleAnim = animFolder:FindFirstChild("Idle")
									if idleAnim and idleAnim:IsA("Animation") then
										humanoid:LoadAnimation(idleAnim):Play()
									end
								end
							end
						end

						-- Play Orga animation if exists
						local orga = kaijuModel:FindFirstChild("Orga")
						if not orga then
							local orgaAnim = Instance.new("Animation")
							orgaAnim.AnimationId = "http://www.roblox.com/asset/?id=9127268479"
							humanoid:LoadAnimation(orgaAnim):Play()
						end
					end

					-- Set camera to ViewPortModel
					local cam = viewPortModel:FindFirstChild("Cam")
					if cam and hrp then
						cam.CFrame = CFrame.new(cam.CFrame.X, hrp.CFrame.Y, cam.CFrame.Z)
						cam.Orientation = Vector3.new(-0.76, 178.03, 0)
					end
					camera.CameraType = Enum.CameraType.Scriptable
					camera.CFrame = cam and cam.CFrame or camera.CFrame
				end

					task.wait(0.15)
					isBusy = false
				end)
			end
		end
	end
end

--==========================================================================
-- PATCH 26: Mobile menu support (ensure MenuButton works on touch devices)
--==========================================================================

-- On mobile/touch devices, MouseButton1Down fires on tap, so the MenuButton
-- click handler in PATCH 16 already works. Ensure the MenuButton is visible.
if UserInputService.TouchEnabled then
	local menuButtonParent = menu.Parent:FindFirstChild("MenuButton")
	if menuButtonParent then
		menuButtonParent.Visible = true
	end
end

-- Also support the Enum.KeyCode.ButtonStart (Menu button on gamepad) to toggle menu
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.ButtonStart and not gameProcessed then
		if isBusy then return end
		if not isMenuOpen then
			openMenu()
		else
			closeMenu()
		end
	end
end)

--==========================================================================
-- PATCH 27: CharacterAdded/Removing - refresh UI
--==========================================================================

player.CharacterAdded:Connect(function()
	UnlockImages("All")
end)
player.CharacterRemoving:Connect(function()
	UnlockImages("All")
end)

--==========================================================================
-- PATCH 27.5: Live update listeners for player info (GCells, EquippedKaiju, Skin)
--==========================================================================

-- Update GCells display when the value changes on the server
local gcellsValue = inventory:FindFirstChild("GCells")
if gcellsValue then
	gcellsValue.Changed:Connect(function()
		UnlockImages("GCells")
	end)
end

-- Update Lootboxes display when the value changes on the server
local lootboxesValue = inventory:FindFirstChild("Lootboxes")
if lootboxesValue then
	lootboxesValue.Changed:Connect(function()
		UnlockImages("GCells")
	end)
end

-- Update equipped kaiju/skin display when Skin value changes
local skinValue = inventory:FindFirstChild("Skin")
if skinValue then
	skinValue.Changed:Connect(function()
		UnlockImages("All")
	end)
end

-- Update equipped kaiju/skin display when EquippedKaiju value changes
local equippedKaijuValue = inventory:FindFirstChild("EquippedKaiju")
if equippedKaijuValue then
	equippedKaijuValue.Changed:Connect(function()
		UnlockImages("All")
	end)
else
	-- EquippedKaiju may not exist yet; listen for it being added to inventory
	inventory.ChildAdded:Connect(function(child)
		if child.Name == "EquippedKaiju" and child:IsA("ValueBase") then
			child.Changed:Connect(function()
				UnlockImages("All")
			end)
			-- Trigger an immediate update for the newly created value
			UnlockImages("All")
		end
	end)
end

--==========================================================================
-- PATCH 28: KaijuMenu panel management (show SelectStores, hide stores)
--==========================================================================

-- When KaijuMenu value changes, manage the sub-panels (from WorkGui lines 3726-3843)
if kaijuMenuVal then
	kaijuMenuVal.Changed:Connect(function(newMenu)
		-- Hide/show MenuButton, PlayerList, and XPBar based on KaijuMenu state
		local menuParent = menu.Parent
		if menuParent then
			local menuBtn = menuParent:FindFirstChild("MenuButton")
			local playerListBtn = menuParent:FindFirstChild("PlayerList")
			local xpBar = menuParent:FindFirstChild("XPBar")
			local shouldHide = newMenu ~= nil
			if menuBtn then menuBtn.Visible = not shouldHide end
			if playerListBtn then playerListBtn.Visible = not shouldHide end
			if xpBar then xpBar.Visible = not shouldHide end
		end

		if not newMenu then return end

		-- Close Inventory panel if visible
		if menu.Inventory.Visible then
			local invTween = TweenService:Create(menu.Inventory,
				TweenInfo.new(menu.Inventory:FindFirstChild("TweenSpeed") and (menu.Inventory:FindFirstChild("TweenSpeed") and menu.Inventory.TweenSpeed.Value or 0.2)),
				{Position = menu.Inventory.Positions.StartPos.Position})
			invTween:Play()
			invTween.Completed:Connect(function()
				menu.Inventory.Visible = false
			end)
		end

		-- Show KaijuMenu panel
		newMenu.Visible = true

		-- Show SelectStores, position at EndPos
		local selectStores = newMenu:FindFirstChild("SelectStores")
		if selectStores then
			selectStores.Visible = true
			if selectStores:FindFirstChild("Positions") then
				selectStores.Position = selectStores.Positions.EndPos.Position
			end
		end

		-- Hide SkinStore, reset to StartPos
		local skinStore = newMenu:FindFirstChild("SkinStore")
		if skinStore then
			skinStore.Visible = false
			if skinStore:FindFirstChild("Positions") then
				skinStore.Position = skinStore.Positions.StartPos.Position
			end
		end

		-- Hide EmoteStore, reset to StartPos
		local emoteStore = newMenu:FindFirstChild("EmoteStore")
		if emoteStore then
			emoteStore.Visible = false
			if emoteStore:FindFirstChild("Positions") then
				emoteStore.Position = emoteStore.Positions.StartPos.Position
			end
		end


		-- Tween KaijuMenu to EndPos
		local tweenSpeed = newMenu:FindFirstChild("TweenSpeed")
		local speed = tweenSpeed and tweenSpeed.Value or 0.2
		if newMenu:FindFirstChild("Positions") then
			TweenService:Create(newMenu, TweenInfo.new(speed), {
				Position = newMenu.Positions.EndPos.Position
			}):Play()
		end

		-- Hide other KaijuMenu panels
		if menu:FindFirstChild("KaijuMenus") then
			for _, otherMenu in menu.KaijuMenus:GetChildren() do
				if otherMenu ~= newMenu then
					local otherSpeed = otherMenu:FindFirstChild("TweenSpeed")
					local otherSpeedVal = otherSpeed and otherSpeed.Value or 0.2
					if otherMenu:FindFirstChild("Positions") then
						local otherTween = TweenService:Create(otherMenu, TweenInfo.new(otherSpeedVal), {
							Position = otherMenu.Positions.StartPos.Position
						})
					otherTween:Play()
					otherTween.Completed:Connect(function()
						otherMenu.Visible = false
					end)
				end
				end
			end
		end
	end)
end

--==========================================================================
-- PATCH 29: Universal Object button handler (MenuToggle navigation)
--==========================================================================

-- Catch-all handler for buttons with Object children that aren't already handled
-- by specific patches. Handles MenuToggle buttons in Selection->Open hierarchy
-- and general panel toggling (from WorkGui lines 3982-4143)
for _, descendant in menu:GetDescendants() do
	if descendant:IsA("GuiButton") and descendant.Name == "Button" then
		-- Check if this button has an Object child
		local obj = descendant:FindFirstChild("Object")
		if obj and obj:IsA("ObjectValue") and obj.Value then
			-- Check if this is a MenuToggle in Selection -> Open hierarchy
			local parent = descendant.Parent
			local grandparent = parent and parent.Parent
			local greatGrandparent = grandparent and grandparent.Parent

			local isMenuToggle = false
			if greatGrandparent and greatGrandparent.Name == "MenuToggle" then
				if grandparent and grandparent.Name == "Selection" then
					if parent and parent.Name == "Open" then
						isMenuToggle = true
					end
				end
			end

			if isMenuToggle then
				descendant.MouseButton1Down:Connect(function()
					if isBusy then return end
					isBusy = true

					menu.Prompt.Visible = false
					if sounds and sounds:FindFirstChild("Click") then sounds.Click:Play() end

					-- Find the Object child and toggle the target panel
					for _, child in descendant:GetChildren() do
						if child.Name == "Object" and child:IsA("ObjectValue") and child.Value then
							local targetPanel = child.Value
							local targetPos = targetPanel.Position
							local startPos = targetPanel.Positions.StartPos.Position
							local endPos = targetPanel.Positions.EndPos.Position

							if targetPos == startPos then
								-- Panel is closed: open it
								targetPanel.Visible = true

								-- Check if this is a Back button
								local parentName = descendant.Parent.Parent.Name
								if parentName == "Back" then
									values.SelectedObject.Value = nil
								end

								-- Special handling: Back button inside Inventory
								local grandParentName = descendant.Parent.Parent.Parent and descendant.Parent.Parent.Parent.Name
								if parentName == "Back" and grandParentName == "Inventory" then
									local leftBar = menu.Characters:FindFirstChild("LeftBar")
									if leftBar and leftBar.Visible then
										-- Clean up kaiju model
										local kaijuModelVal = values:FindFirstChild("KaijuModel")
										if kaijuModelVal and kaijuModelVal.Value then
											kaijuModelVal.Value:Destroy()
											kaijuModelVal.Value = nil
											values.SelectedKaiju.Value = ""
											local kmVal = values:FindFirstChild("KaijuMenu")
											if kmVal then kmVal.Value = nil end
										end
										-- Close LeftBar
										local lbTween = TweenService:Create(leftBar,
											TweenInfo.new(leftBar:FindFirstChild("TweenSpeed") and (leftBar:FindFirstChild("TweenSpeed") and leftBar.TweenSpeed.Value or 0.2)),
											{Position = leftBar.Positions.StartPos.Position})
										lbTween:Play()
										lbTween.Completed:Connect(function()
											leftBar.Visible = false
										end)
									end
								end

								-- Play sound from Object value
								local soundVal = child.Value:FindFirstChild("Sound")
								if soundVal and soundVal.Value then
									soundVal.Value:Play()
								end

								-- Tween to EndPos
								local tSpeed = child.Value:FindFirstChild("TweenSpeed")
								local tSpeedVal = tSpeed and tSpeed.Value or 0.2
								TweenService:Create(child.Value, TweenInfo.new(tSpeedVal), {
									Position = endPos
								}):Play()
								task.wait(0.3)
								isBusy = false
							else
								-- Panel is open: close it
								local soundVal = child.Value:FindFirstChild("Sound")
								if soundVal and soundVal.Value then
									soundVal.Value:Play()
								end

								local tSpeed = child.Value:FindFirstChild("TweenSpeed")
								local tSpeedVal = tSpeed and tSpeed.Value or 0.2
								local closeTween = TweenService:Create(child.Value, TweenInfo.new(tSpeedVal), {
									Position = startPos
								})
								closeTween:Play()
								closeTween.Completed:Connect(function()
									child.Value.Visible = false
									task.wait(0.15)
									isBusy = false
								end)
							end
							end
						end

					task.wait(0.3)
					isBusy = false
				end)
			end
		end
	end
end

--==========================================================================
-- PATCH 27.5: Back buttons inside KaijuMenus (SelectStores/SkinStore/EmoteStore)
--==========================================================================

-- Back buttons in KaijuMenus have the hierarchy:
-- KaijuMenus > [KaijuName] > [StoreName] > Back > Button > Object(s)
-- The Button has multiple Object ObjectValues: one pointing to the kaiju menu (to close)
-- and one pointing to Inventory (to open). Toggle each panel based on current position.
-- When backing out of SelectStores (exiting kaiju menu entirely), also reset camera
-- and clean up the kaiju model from the ViewPortModel.
for _, kaijuMenu in (menu:FindFirstChild("KaijuMenus") and menu.KaijuMenus:GetChildren() or {}) do
	if kaijuMenu:IsA("Frame") then
		for _, storeName in {"SelectStores", "SkinStore", "EmoteStore"} do
			local store = kaijuMenu:FindFirstChild(storeName)
			if store then
				local back = store:FindFirstChild("Back")
				if back then
					local btn = back:FindFirstChild("Button")
					if btn then
						btn.MouseButton1Down:Connect(function()
							if isBusy then return end
							isBusy = true
							if sounds and sounds:FindFirstChild("Click") then sounds.Click:Play() end

							-- Clear SelectedObject (Back button behavior from WorkGui)
							values.SelectedObject.Value = nil

							-- Toggle each Object value's panel
							for _, child in ipairs(btn:GetChildren()) do
								if child.Name == "Object" and child:IsA("ObjectValue") and child.Value then
									local targetPanel = child.Value
									local targetPos = targetPanel.Position
									local startPos = targetPanel.Positions.StartPos.Position
									local endPos = targetPanel.Positions.EndPos.Position

									-- Play sound
									local soundVal = targetPanel:FindFirstChild("Sound")
									if soundVal and soundVal.Value then
										soundVal.Value:Play()
									end

									local tSpeed = targetPanel:FindFirstChild("TweenSpeed")
									local tSpeedVal = tSpeed and tSpeed.Value or 0.2

									if targetPos == startPos then
										-- Panel is closed: open it
										targetPanel.Visible = true
										TweenService:Create(targetPanel, TweenInfo.new(tSpeedVal), {
											Position = endPos
										}):Play()
									else
										-- Panel is open: close it
										local closeTween = TweenService:Create(targetPanel, TweenInfo.new(tSpeedVal), {
											Position = startPos
										})
										closeTween:Play()
										closeTween.Completed:Connect(function()
											targetPanel.Visible = false
										end)
									end
								end
							end

							-- If this is the SelectStores Back button, we are exiting the kaiju menu entirely.
							-- Reset camera from Scriptable to Custom and clean up kaiju model.
							if storeName == "SelectStores" then
								-- Reset camera
								if camera.CameraType == Enum.CameraType.Scriptable then
									camera.CameraType = Enum.CameraType.Custom
									local char = player.Character
									if char then
										local hum = char:FindFirstChildOfClass("Humanoid")
										if hum then
											camera.CameraSubject = hum
										end
									end
								end

								-- Clean up ViewPortModel kaiju character
								local viewPortModel = workspace:FindFirstChild("ViewPortModel")
								if viewPortModel then
									local existingChar = viewPortModel:FindFirstChild("Char")
									if existingChar then
										existingChar:Destroy()
									end
								end

								-- Clean up kaiju state values
								local kaijuModelVal = values:FindFirstChild("KaijuModel")
								if kaijuModelVal and kaijuModelVal.Value then
									kaijuModelVal.Value:Destroy()
									kaijuModelVal.Value = nil
								end
								local kaijuMenuValBack = values:FindFirstChild("KaijuMenu")
								if kaijuMenuValBack then kaijuMenuValBack.Value = nil end
								local selectedKaijuValBack = values:FindFirstChild("SelectedKaiju")
								if selectedKaijuValBack then selectedKaijuValBack.Value = "" end
							end

							task.wait(0.3)
							isBusy = false
						end)
					end
				end
			end
		end
	end
end

--==========================================================================
-- PATCH 30: SkinStore/EmoteStore sub-navigation (tab switching)
--==========================================================================

-- Within a KaijuMenu, the SelectStores panel has Skins/Emotes tab buttons.
-- Each tab (Skins/Emotes) is an ImageButton with a Button TextButton child on top
-- (ZIndex 5, full size) that intercepts clicks. The Button has Object ObjectValues:
-- Skins.Button -> SelectStores (to close) and SkinStore (to open)
-- Emotes.Button -> SelectStores (to close) and EmoteStore (to open)
-- We connect to the Button child and toggle panels via Object values.
for _, kaijuMenu in (menu:FindFirstChild("KaijuMenus") and menu.KaijuMenus:GetChildren() or {}) do
	local selectStores = kaijuMenu:FindFirstChild("SelectStores")
	if selectStores then
		for _, tabName in {"Skins", "Emotes"} do
			local tab = selectStores:FindFirstChild(tabName)
			if tab then
				local tabBtn = tab:FindFirstChild("Button")
				if tabBtn and tabBtn:IsA("GuiButton") then
					tabBtn.MouseButton1Down:Connect(function()
						if isBusy then return end
						isBusy = true
						if sounds and sounds:FindFirstChild("Click") then sounds.Click:Play() end

						-- Toggle each Object value's panel
						for _, child in ipairs(tabBtn:GetChildren()) do
							if child.Name == "Object" and child:IsA("ObjectValue") and child.Value then
								local targetPanel = child.Value
								local targetPos = targetPanel.Position
								local startPos = targetPanel.Positions.StartPos.Position
								local endPos = targetPanel.Positions.EndPos.Position

								local tSpeed = targetPanel:FindFirstChild("TweenSpeed")
								local tSpeedVal = tSpeed and tSpeed.Value or 0.2

								if targetPos == startPos then
									-- Panel is closed: open it
									targetPanel.Visible = true
									TweenService:Create(targetPanel, TweenInfo.new(tSpeedVal), {
										Position = endPos
									}):Play()
								else
									-- Panel is open: close it
									local closeTween = TweenService:Create(targetPanel, TweenInfo.new(tSpeedVal), {
										Position = startPos
									})
									closeTween:Play()
									closeTween.Completed:Connect(function()
										targetPanel.Visible = false
									end)
								end
							end
						end

						task.wait(0.3)
						isBusy = false
					end)
				end
			end
		end
	end
end

--==========================================================================
-- PATCH 26: Auto-update XP/Level/Rank UI when values change
--==========================================================================

-- Connect to XP, Level, XPToEarn, and Rank value changes to refresh the menu UI
local _xpFolder = inventory:FindFirstChild("XP")
if _xpFolder then
	local function _onXPChanged()
		updateXPBars()
	end

	local _levelVal = _xpFolder:FindFirstChild("Level")
	if _levelVal then _levelVal.Changed:Connect(_onXPChanged) end

	_xpFolder.Changed:Connect(_onXPChanged)

	local _xpToEarnVal = _xpFolder:FindFirstChild("XPToEarn")
	if _xpToEarnVal then _xpToEarnVal.Changed:Connect(_onXPChanged) end

	local _rankVal = _xpFolder:FindFirstChild("Rank")
	if _rankVal then _rankVal.Changed:Connect(_onXPChanged) end
end

-- Also update display when GCells or Lootboxes change
local _gcellsVal = inventory:FindFirstChild("GCells")
if _gcellsVal then _gcellsVal.Changed:Connect(function() UnlockImages("GCells") end) end

local _lootboxesVal = inventory:FindFirstChild("Lootboxes")
if _lootboxesVal then _lootboxesVal.Changed:Connect(function() UnlockImages("GCells") end) end

-- Initial UI refresh
UnlockImages("All")

--==========================================================================
-- PATCH 31: Continuous XP bar updates (always running, not just on menu open)
--==========================================================================

-- Run a continuous loop to update XP bars every 0.5 seconds
-- This ensures XP bars are always current even when the menu is closed
task.spawn(function()
	while true do
		updateXPBars()
		task.wait(0.5)
	end
end)

-- Also call once immediately
updateXPBars()
