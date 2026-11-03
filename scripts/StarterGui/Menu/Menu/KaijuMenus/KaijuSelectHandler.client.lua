local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- RemoteEvent for saving Kaiju/Skin selection
local KaijuSelectionEvent = ReplicatedStorage:WaitForChild("KaijuSelection")

-- Reference to the KaijuMenus folder
local KaijuMenus = script.Parent

-- Reference to the menu and values
local menu = KaijuMenus.Parent
local values = menu:FindFirstChild("Values")
local events = menu:FindFirstChild("Events")
local sounds = menu:FindFirstChild("Sounds")
local inventory = player:FindFirstChild("Inventory")

-- Current selection state (for preview purposes)
local currentKaiju = nil
local currentSkin = "Default"

-- Track currently selected skin for each kaiju (local preview)
local selectedSkins = {}

-- Track currently previewed skin button for each kaiju
local previewedSkin = {}  -- [kaijuName] = {button, skinName, owned, cost, onsale}

-- Emote preview state per kaiju
local previewedEmote = {}  -- [kaijuName] = {button, emoteName, owned, cost, onsale}

-- Currently selected emote slot for equipping
local selectedEmoteSlot = nil

-- Map menu kaiju frame names to their animation folder names in ReplicatedStorage.Animations
-- (mirrors the server's KAIJU_TO_ANIMATION_MAP in Spawn.Script)
local KAIJU_TO_ANIMATION_MAP = {
	["ShowaGigan"] = "Gigan",
}


--==========================================================================
-- Helper: Replace the Char model in ViewPortModel with a new model (skin preview)
--==========================================================================
local function previewSkinModel(skinModel, kaijuName)
	if not skinModel then return end

	local viewPortModel = workspace:FindFirstChild("ViewPortModel")
	if not viewPortModel then return end

	-- Remove existing Char
	local existingChar = viewPortModel:FindFirstChild("Char")
	if existingChar then
		existingChar:Destroy()
	end

	-- Clone the skin model
	local clonedModel = skinModel:Clone()
	clonedModel.Name = "Char"

	-- Store in values.KaijuModel for cleanup later
	if values then
		local kmVal = values:FindFirstChild("KaijuModel")
		if kmVal then kmVal.Value = clonedModel end
	end

	-- Anchor for setup
	local hrp = clonedModel:FindFirstChild("HumanoidRootPart")
	if hrp then hrp.Anchored = true end

	clonedModel.Parent = viewPortModel

	-- Position at CharSpot (stand on top, accounting for HRP half-height)
	local charSpot = viewPortModel:FindFirstChild("CharSpot")
	if charSpot and hrp then
		local humanoid = clonedModel:FindFirstChildOfClass("Humanoid")
		local hipY = humanoid and humanoid.HipHeight or 0
		local groundY = charSpot.CFrame.Y + charSpot.Size.Y/2
		hrp.CFrame = CFrame.new(charSpot.CFrame.X, groundY + hipY + hrp.Size.Y/2, charSpot.CFrame.Z)
	end

	-- Keep HRP anchored so character stands on non-collidable CharSpot without falling
	if hrp then hrp.Anchored = true end

	-- Play idle animation from ReplicatedStorage.Animations
	local humanoid = clonedModel:FindFirstChildOfClass("Humanoid")
	if humanoid then
		local animationsFolder = ReplicatedStorage:FindFirstChild("Animations")
		if animationsFolder and kaijuName then
			local animFolderName = KAIJU_TO_ANIMATION_MAP[kaijuName] or kaijuName
			local kaijuAnimFolder = animationsFolder:FindFirstChild(animFolderName)
			if kaijuAnimFolder then
				local animFolder = kaijuAnimFolder:FindFirstChild("Animations")
				if animFolder then
					local idleAnimObj = animFolder:FindFirstChild("Idle")
					if idleAnimObj and idleAnimObj:IsA("Animation") then
						local idleTrack = humanoid:LoadAnimation(idleAnimObj)
						idleTrack.Looped = true
						idleTrack:Play()
					end
				end
			end
		end

		-- Play Orga animation if no Orga child
		local orga = clonedModel:FindFirstChild("Orga")
		if not orga then
			local orgaAnim = Instance.new("Animation")
			orgaAnim.AnimationId = "http://www.roblox.com/asset/?id=9127268479"
			local orgaTrack = humanoid:LoadAnimation(orgaAnim)
			orgaTrack.Looped = true
			orgaTrack:Play()
		end
	end

	-- Set camera to ViewPortModel
	local cam = viewPortModel:FindFirstChild("Cam")
	if cam and hrp then
		cam.CFrame = CFrame.new(cam.CFrame.X, hrp.CFrame.Y, cam.CFrame.Z)
		cam.Orientation = Vector3.new(-0.76, 178.03, 0)
	end
	local camera = workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = cam and cam.CFrame or camera.CFrame
end

--==========================================================================
-- Helper: Resolve a skin model from ReplicatedStorage by kaiju name and skin name
--==========================================================================
local modelsFolder = ReplicatedStorage:FindFirstChild("Assets") and ReplicatedStorage.Assets:FindFirstChild("Kaijus") and ReplicatedStorage.Assets.Kaijus:FindFirstChild("Models")

local function resolveSkinModel(kaijuName, skinName)
	if not modelsFolder then return nil end

	local kaijuFolder = modelsFolder:FindFirstChild(kaijuName)
	if not kaijuFolder then return nil end

	-- Try exact match: a model named skinName inside the kaiju folder
	local model = kaijuFolder:FindFirstChild(skinName)
	if model and model:IsA("Model") then return model end

	-- Fallback: try the default skin for this kaiju
	local defaultName = kaijuName .. "-Default"
	local defaultModel = kaijuFolder:FindFirstChild(defaultName)
	if defaultModel and defaultModel:IsA("Model") then return defaultModel end

	return nil
end

--==========================================================================
-- Helper: Show purchase prompt
--==========================================================================
local function showPurchasePrompt(itemName, cost, itemType)
	local prompt = menu:FindFirstChild("Prompt")
	if not prompt then return end

	prompt:SetAttribute("ItemName", itemName)
	prompt:SetAttribute("ItemCost", cost)
	prompt:SetAttribute("ItemType", itemType)

	prompt.Visible = true
	local promptImg = prompt:FindFirstChild("PromptImage")
	if promptImg then
		local promptInfo = promptImg:FindFirstChild("PromptInfo")
		if promptInfo then
			promptInfo.Text = "Purchase " .. itemName .. " for " .. cost .. " GCells?"
		end
	end
end

--==========================================================================
-- Helper: Mark a skin button as owned (set Owned, hide CostTXT)
--==========================================================================
local function markSkinButtonOwned(skinButton)
	local ownedVal = skinButton:FindFirstChild("Owned")
	if ownedVal then ownedVal.Value = true end
	local costTXT = skinButton:FindFirstChild("CostTXT")
	if costTXT then costTXT.Visible = false end
end

--==========================================================================
-- Helper: Strip kaiju prefix from emote display names
-- E.g. "Godzilla2000-Rest" -> "Rest", "Zilla-Wave" -> "Wave"
--==========================================================================
local function stripKaijuPrefix(emoteName)
	local dashPos = string.find(emoteName, "-")
	if dashPos then
		return string.sub(emoteName, dashPos + 1)
	end
	return emoteName
end

--==========================================================================
-- Setup SkinStore: skin buttons preview model on click (NO purchase prompt)
--==========================================================================
local function setupSkinStore(kaijuFrame)
	local kaijuName = kaijuFrame.Name
	local skinStore = kaijuFrame:FindFirstChild("SkinStore")
	if not skinStore then return end

	local selectionFrame = skinStore:FindFirstChild("SelectionFrame")
	if not selectionFrame or not selectionFrame:IsA("ScrollingFrame") then return end

	local function setupSkinButton(skinButton)
		if skinButton:GetAttribute("SkinSetup") then return end
		skinButton:SetAttribute("SkinSetup", true)

		local button = skinButton:FindFirstChild("Button")
		if not button then return end

		button.MouseButton1Down:Connect(function()
			local skinNameVal = skinButton:FindFirstChild("SkinName")
			local skinName = skinNameVal and skinNameVal.Value or skinButton.Name
			local ownedVal = skinButton:FindFirstChild("Owned")
			local isOwned = ownedVal and ownedVal.Value or false
			local costVal = skinButton:FindFirstChild("Cost")
			local cost = costVal and costVal.Value or 0
			local onsaleVal = skinButton:FindFirstChild("Onsale")
			local onsale = onsaleVal and onsaleVal.Value or false
			local skinModelObj = skinButton:FindFirstChild("SkinModel")
			local skinModel = skinModelObj and skinModelObj.Value

			-- If SkinModel ObjectValue is nil, resolve it on-demand
			if not skinModel and skinModelObj then
				skinModel = resolveSkinModel(kaijuName, skinName)
				if skinModel then
					skinModelObj.Value = skinModel
					print("[CLIENT] Resolved skin model on-demand: " .. skinName .. " -> " .. skinModel.Name)
				end
			end

			-- ONLY preview the skin model (no purchase prompt)
			if skinModel then
				previewSkinModel(skinModel, kaijuName)
			end

			-- Set Values for later purchase/equip via Select button
			if values then
				local selSkin = values:FindFirstChild("SelectedSkin")
				if selSkin then selSkin.Value = skinName end

				local costVal2 = values:FindFirstChild("Cost")
				if costVal2 then costVal2.Value = cost end

				local onsaleVal2 = values:FindFirstChild("Onsale")
				if onsaleVal2 then onsaleVal2.Value = onsale end

				local selObj = values:FindFirstChild("SelectedObject")
				if selObj and ownedVal then
					selObj.Value = ownedVal
				end
			end

			-- Track current preview
			previewedSkin[kaijuName] = {
				button = skinButton,
				skinName = skinName,
				owned = isOwned,
				cost = cost,
				onsale = onsale,
			}

			if sounds then
				local click = sounds:FindFirstChild("Click")
				if click then click:Play() end
			end

			print("[CLIENT] Previewed skin: " .. skinName .. " for Kaiju: " .. kaijuName)
		end)
	end

	-- Connect to existing skin buttons
	for _, child in ipairs(selectionFrame:GetChildren()) do
		if child:IsA("ImageButton") then
			setupSkinButton(child)
		end
	end

	-- Handle skin buttons added later
	selectionFrame.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("ImageButton") then
			setupSkinButton(descendant)
		end
	end)
end

--==========================================================================
-- Setup SkinStore.Select button: buy (if not owned) or equip (if owned)
--==========================================================================
local function setupSkinSelectButton(kaijuFrame)
	local kaijuName = kaijuFrame.Name
	local skinStore = kaijuFrame:FindFirstChild("SkinStore")
	if not skinStore then return end

	local selectBtn = skinStore:FindFirstChild("Select")
	if not selectBtn then return end

	local button = selectBtn:FindFirstChild("Button")
	if not button then return end

	button.MouseButton1Down:Connect(function()
		local preview = previewedSkin[kaijuName]
		if not preview then
			print("[CLIENT] No skin previewed for " .. kaijuName)
			return
		end

		if sounds then
			local click = sounds:FindFirstChild("Click")
			if click then click:Play() end
		end

		if preview.owned then
			-- Equip the skin
			currentSkin = preview.skinName
			currentKaiju = kaijuName
			selectedSkins[kaijuName] = preview.skinName

			-- Fire EquipSkin event
			if events then
				local equipSkin = events:FindFirstChild("EquipSkin")
				if equipSkin then
					equipSkin:FireServer(preview.skinName)
				end
			end

			-- Also fire KaijuSelection to save skin for this kaiju
			KaijuSelectionEvent:FireServer("SetSkinForKaiju", kaijuName, preview.skinName)

			print("[CLIENT] Equipped skin: " .. preview.skinName .. " for Kaiju: " .. kaijuName)
		else
			-- Not owned: check if free or needs purchase
			if preview.cost == 0 then
				-- Free skin: auto-own and equip without prompt
				currentSkin = preview.skinName
				currentKaiju = kaijuName
				selectedSkins[kaijuName] = preview.skinName

				-- Update the Owned value on the skin button and hide cost text
				markSkinButtonOwned(preview.button)
				preview.owned = true

				-- Fire BuyItem to server so ownership is saved to datastore (cost=0 for free)
				if events then
					local buyItem = events:FindFirstChild("BuyItem")
					if buyItem then
						buyItem:FireServer(0, preview.skinName)
					end
					local equipSkin = events:FindFirstChild("EquipSkin")
					if equipSkin then
						equipSkin:FireServer(preview.skinName)
					end
				end
				KaijuSelectionEvent:FireServer("SetSkinForKaiju", kaijuName, preview.skinName)

				print("[CLIENT] Auto-equipped free skin: " .. preview.skinName)
			elseif preview.onsale then
				showPurchasePrompt(preview.skinName, preview.cost, "Skin")
			else
				print("[CLIENT] Skin is not on sale: " .. preview.skinName)
			end
		end
	end)
end




--==========================================================================
-- Setup SelectStores.Select button: buy (if not owned) or select kaiju
--==========================================================================
local function setupKaijuSelectButton(kaijuFrame)
	local kaijuName = kaijuFrame.Name
	local selectStores = kaijuFrame:FindFirstChild("SelectStores")
	if not selectStores then return end

	local selectButton = selectStores:FindFirstChild("Select")
	if not selectButton or not selectButton:IsA("ImageButton") then return end

	local button = selectButton:FindFirstChild("Button")
	if not button then return end

	button.MouseButton1Down:Connect(function()
		if sounds then
			local click = sounds:FindFirstChild("Click")
			if click then click:Play() end
		end

		-- Check if this kaiju is owned
		local selectionList = menu.Characters.LeftBar:FindFirstChild("Selection")
		local kaijuItem = selectionList and selectionList:FindFirstChild(kaijuName)
		local ownedVal = kaijuItem and kaijuItem:FindFirstChild("Owned")
		local isOwned = ownedVal and ownedVal.Value or false

		if not isOwned then
			-- Not owned: show purchase prompt
			local costVal = kaijuItem and kaijuItem:FindFirstChild("Cost")
			local cost = costVal and costVal.Value or 0

			if cost == 0 then
				-- Free kaiju: auto-own and select
				if ownedVal then ownedVal.Value = true end
				currentKaiju = kaijuName
				currentSkin = selectedSkins[kaijuName] or "Default"

				-- Fire BuyItem to server so ownership is saved to datastore (cost=0 for free)
				if events then
					local buyItem = events:FindFirstChild("BuyItem")
					if buyItem then
						buyItem:FireServer(0, kaijuName)
					end
				end

				KaijuSelectionEvent:FireServer("SetKaiju", kaijuName)
				print("[CLIENT] Selected free Kaiju: " .. kaijuName)
				return
			end

			-- Set values for purchase
			if values then
				local selKaiju = values:FindFirstChild("SelectedKaiju")
				if selKaiju then selKaiju.Value = kaijuName end
				local costVal2 = values:FindFirstChild("Cost")
				if costVal2 and costVal then costVal2.Value = costVal.Value end
				local selObj = values:FindFirstChild("SelectedObject")
				if selObj and ownedVal then selObj.Value = ownedVal end
			end

			showPurchasePrompt(kaijuName, cost, "Kaiju")
			return
		end

		-- Set the current Kaiju selection
		currentKaiju = kaijuName
		currentSkin = selectedSkins[kaijuName] or "Default"

		-- Fire event to server to save Kaiju selection (DO NOT RESPAWN)
		KaijuSelectionEvent:FireServer("SetKaiju", kaijuName)

		print("Selected Kaiju: " .. kaijuName)
	end)
end

--==========================================================================
-- Handle BuyItem response from server: update Owned values after purchase
--==========================================================================
if events then
	local buyItem = events:FindFirstChild("BuyItem")
	if buyItem then
		buyItem.OnClientEvent:Connect(function(success, itemName)
			if success and itemName and itemName ~= "" then
				print("[CLIENT] Purchase successful: " .. itemName)

				-- Update Owned BoolValue on skin buttons
				for _, kaijuFrame in ipairs(KaijuMenus:GetChildren()) do
					if kaijuFrame:IsA("Frame") then
						-- Check skin buttons
						local skinStore = kaijuFrame:FindFirstChild("SkinStore")
						if skinStore then
							local selFrame = skinStore:FindFirstChild("SelectionFrame")
							if selFrame then
								for _, skinBtn in ipairs(selFrame:GetChildren()) do
									if skinBtn:IsA("ImageButton") then
										local skinNameVal = skinBtn:FindFirstChild("SkinName")
										local skinName = skinNameVal and skinNameVal.Value or ""
										local ownedVal = skinBtn:FindFirstChild("Owned")
										if ownedVal and skinName == itemName then
											ownedVal.Value = true
											-- Hide cost text on owned skin button
											local costTXT = skinBtn:FindFirstChild("CostTXT")
											if costTXT then costTXT.Visible = false end
											-- Update preview state
											local preview = previewedSkin[kaijuFrame.Name]
											if preview and preview.skinName == itemName then
												preview.owned = true
											end
										end
									end
								end
							end
						end
				end  -- close if kaijuFrame:IsA('Frame')
			end  -- close for kaijuFrame loop
				-- Update emote Owned values in EmoteStore
				for _, kaijuFrame in ipairs(KaijuMenus:GetChildren()) do
					if kaijuFrame:IsA("Frame") then
						local emoteStore = kaijuFrame:FindFirstChild("EmoteStore")
						if emoteStore then
							local selFrame = emoteStore:FindFirstChild("SelectionFrame")
							if selFrame then
								for _, emoteBtn in ipairs(selFrame:GetChildren()) do
									if emoteBtn:IsA("ImageButton") then
										local emoteNameVal = emoteBtn:FindFirstChild("EmoteName")
										local emoteName = emoteNameVal and emoteNameVal.Value or ""
										if emoteName == itemName then
											local ownedVal = emoteBtn:FindFirstChild("Owned")
											if ownedVal then ownedVal.Value = true end
											local costTXT = emoteBtn:FindFirstChild("CostTXT")
											if costTXT then costTXT.Visible = false end
											-- Update preview state
											local preview = previewedEmote[kaijuFrame.Name]
											if preview and preview.emoteName == itemName then
												preview.owned = true
											end
										end
									end
								end
							end
						end
					end
				end

				-- Update kaiju Owned values
				local selectionList = menu.Characters.LeftBar:FindFirstChild("Selection")
				if selectionList then
					local kaijuItem = selectionList:FindFirstChild(itemName)
					if kaijuItem then
						local ownedVal = kaijuItem:FindFirstChild("Owned")
						if ownedVal then ownedVal.Value = true end
					end
				end
			else
				print("[CLIENT] Purchase failed or not enough GCells: " .. tostring(itemName))
			end
		end)
	end
end

--==========================================================================
-- Setup EmoteStore: emote buttons preview and select on click
--==========================================================================
local function setupEmoteStore(kaijuFrame)
	local kaijuName = kaijuFrame.Name
	local emoteStore = kaijuFrame:FindFirstChild("EmoteStore")
	if not emoteStore then return end

	local selectionFrame = emoteStore:FindFirstChild("SelectionFrame")
	if not selectionFrame or not selectionFrame:IsA("ScrollingFrame") then return end

	local function setupEmoteButton(emoteButton)
		if emoteButton:GetAttribute("EmoteSetup") then return end
		emoteButton:SetAttribute("EmoteSetup", true)

		local button = emoteButton:FindFirstChild("Button")
		if not button then return end

		button.MouseButton1Down:Connect(function()
			local emoteNameVal = emoteButton:FindFirstChild("EmoteName")
			local emoteName = emoteNameVal and emoteNameVal.Value or emoteButton.Name
			local ownedVal = emoteButton:FindFirstChild("Owned")
			local isOwned = ownedVal and ownedVal.Value or false
			local costVal = emoteButton:FindFirstChild("Cost")
			local cost = costVal and costVal.Value or 0
			local onsaleVal = emoteButton:FindFirstChild("Onsale")
			local onsale = onsaleVal and onsaleVal.Value or false

			-- Set Values for later purchase/equip
			if values then
				local selEmote = values:FindFirstChild("SelectedEmote")
				if selEmote then selEmote.Value = emoteName end

				local costVal2 = values:FindFirstChild("Cost")
				if costVal2 then costVal2.Value = cost end

				local onsaleVal2 = values:FindFirstChild("Onsale")
				if onsaleVal2 then onsaleVal2.Value = onsale end

				local selObj = values:FindFirstChild("SelectedObject")
				if selObj and ownedVal then
					selObj.Value = ownedVal
			end
			end

			-- Track current preview
			previewedEmote[kaijuName] = {
				button = emoteButton,
				emoteName = emoteName,
				owned = isOwned,
				cost = cost,
				onsale = onsale,
			}

			-- NOTE: Slot selection is now handled by the 'Select Emote' button,
			-- not by clicking the emote item directly. Clicking an emote only previews it.

			if sounds then
				local click = sounds:FindFirstChild("Click")
				if click then click:Play() end
			end

			print("[CLIENT] Selected emote: " .. emoteName .. " for Kaiju: " .. kaijuName)
		end)
	end

	-- Connect to existing emote buttons
	for _, child in ipairs(selectionFrame:GetChildren()) do
		if child:IsA("ImageButton") then
			setupEmoteButton(child)
		end
	end

	-- Handle emote buttons added later
	selectionFrame.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("ImageButton") then
			setupEmoteButton(descendant)
		end
	end)
end

--==========================================================================
-- Setup EmoteStore.Select button: buy (if not owned) or equip to slot
--==========================================================================
local function setupEmoteSelectButton(kaijuFrame)
	local kaijuName = kaijuFrame.Name
	local emoteStore = kaijuFrame:FindFirstChild("EmoteStore")
	if not emoteStore then return end

	local selectBtn = emoteStore:FindFirstChild("Select")
	if not selectBtn then return end

	local button = selectBtn:FindFirstChild("Button")
	if not button then return end

	button.MouseButton1Down:Connect(function()
		local preview = previewedEmote[kaijuName]
		if not preview then
			print("[CLIENT] No emote previewed for " .. kaijuName)
			return
		end

		if sounds then
			local click = sounds:FindFirstChild("Click")
			if click then click:Play() end
		end

		if preview.owned then
			-- Show the emote slot selection frame with current slot labels
			local menuFrame = KaijuMenus.Parent
			local emotesFrame = menuFrame:FindFirstChild("Emotes")
			if emotesFrame then
				emotesFrame.Visible = true
				-- Update slot labels with currently equipped emotes for this kaiju
				local inv = player:FindFirstChild("Inventory")
				local emotesInv = inv and inv:FindFirstChild("Emotes")
				local kaijuEmotesInv = emotesInv and emotesInv:FindFirstChild(kaijuName)

				for slotNum = 1, 4 do
					local slotName = "Emote" .. slotNum
					local slotUI = emotesFrame:FindFirstChild(slotName)
					if slotUI then
						local txt = slotUI:FindFirstChild("TXT")
						if txt then
							local equippedName = ""
							if kaijuEmotesInv then
								local slotVal = kaijuEmotesInv:FindFirstChild(slotName)
								if slotVal then
									equippedName = slotVal.Value
								end
							end
							if equippedName ~= "" then
								txt.Text = stripKaijuPrefix(equippedName)
							else
								txt.Text = "Empty"
							end
						end
					end
				end
			end
			print("[CLIENT] Showing emote slot selection for: " .. preview.emoteName)
		else
			-- Not owned: check if free or needs purchase
			if preview.cost == 0 then
				-- Free emote: auto-own
				local ownedVal = preview.button:FindFirstChild("Owned")
				if ownedVal then ownedVal.Value = true end
				preview.owned = true

				-- Hide cost text
				local costTXT = preview.button:FindFirstChild("CostTXT")
				if costTXT then costTXT.Visible = false end

				-- Fire BuyItem to server so ownership is saved
				if events then
					local buyItem = events:FindFirstChild("BuyItem")
					if buyItem then
						buyItem:FireServer(0, preview.emoteName)
					end
				end

				-- Show emote slot selection with current slot labels
				local menuFrame = KaijuMenus.Parent
				local emotesFrame = menuFrame:FindFirstChild("Emotes")
				if emotesFrame then
					emotesFrame.Visible = true
					-- Update slot labels with currently equipped emotes for this kaiju
					local inv = player:FindFirstChild("Inventory")
					local emotesInv = inv and inv:FindFirstChild("Emotes")
					local kaijuEmotesInv = emotesInv and emotesInv:FindFirstChild(kaijuName)

					for slotNum = 1, 4 do
						local slotName = "Emote" .. slotNum
						local slotUI = emotesFrame:FindFirstChild(slotName)
						if slotUI then
							local txt = slotUI:FindFirstChild("TXT")
							if txt then
								local equippedName = ""
								if kaijuEmotesInv then
									local slotVal = kaijuEmotesInv:FindFirstChild(slotName)
									if slotVal then
										equippedName = slotVal.Value
									end
								end
								if equippedName ~= "" then
									txt.Text = stripKaijuPrefix(equippedName)
								else
									txt.Text = "Empty"
								end
							end
						end
					end
				end

				print("[CLIENT] Auto-owned free emote: " .. preview.emoteName)
			elseif preview.onsale then
				showPurchasePrompt(preview.emoteName, preview.cost, "Emote")
			else
				print("[CLIENT] Emote is not on sale: " .. preview.emoteName)
			end
		end
	end)
end

--==========================================================================
-- Setup Menu.Emotes slot buttons: equip selected emote to a slot
--==========================================================================
local function setupEmoteSlotButtons()
	local menuFrame = KaijuMenus.Parent
	local emotesFrame = menuFrame:FindFirstChild("Emotes")
	if not emotesFrame then return end

	for slotNum = 1, 4 do
		local slotName = "Emote" .. slotNum
		local slotUI = emotesFrame:FindFirstChild(slotName)
		if slotUI then
			local button = slotUI:FindFirstChild("Button")
			if button then
				button.MouseButton1Down:Connect(function()
					-- Get the currently selected kaiju
					local currentKaijuName = ""
					if values then
						local selKaiju = values:FindFirstChild("SelectedKaiju")
						if selKaiju then currentKaijuName = selKaiju.Value end
					end

					-- Get the currently selected emote
					local selectedEmoteName = ""
					if values then
						local selEmote = values:FindFirstChild("SelectedEmote")
						if selEmote then selectedEmoteName = selEmote.Value end
					end

					if selectedEmoteName == "" then
						print("[CLIENT] No emote selected to equip")
						return
					end

					if sounds then
						local click = sounds:FindFirstChild("Click")
						if click then click:Play() end
					end

					-- Fire EquipEmote to server with per-kaiju data
					if events then
						local equipEmote = events:FindFirstChild("EquipEmote")
						if equipEmote then
							equipEmote:FireServer(selectedEmoteName, slotNum, currentKaijuName)
							print("[CLIENT] Equipping emote: " .. selectedEmoteName .. " to slot " .. slotNum .. " for kaiju " .. currentKaijuName)
						end
					end

					-- Update slot label
					local txt = slotUI:FindFirstChild("TXT")
					if txt then
						txt.Text = stripKaijuPrefix(selectedEmoteName)
					end

					-- Hide the emotes frame after equipping
					task.wait(0.15)
					emotesFrame.Visible = false
				end)
			end
		end
	end
end

-- Setup emote slot buttons
setupEmoteSlotButtons()

--==========================================================================
-- Setup all Kaiju Frames
--==========================================================================
for _, kaijuFrame in ipairs(KaijuMenus:GetChildren()) do
	if kaijuFrame:IsA("Frame") then
		setupKaijuSelectButton(kaijuFrame)
		setupSkinStore(kaijuFrame)
		setupSkinSelectButton(kaijuFrame)
		setupEmoteStore(kaijuFrame)
		setupEmoteSelectButton(kaijuFrame)
	end
end

--==========================================================================
-- Sync inventory ownership to UI on load/rejoin
--==========================================================================
task.spawn(function()
	-- Wait for inventory to be available
	local inv = player:FindFirstChild("Inventory")
	if not inv then
		inv = player:WaitForChild("Inventory", 10)
	end
	if not inv then return end

	-- Wait a brief moment for UI to be fully set up
	task.wait(0.5)

	-- Sync owned items to UI
	for _, child in ipairs(inv:GetChildren()) do
		if child:IsA("BoolValue") and child.Value then
			local itemName = child.Name

			-- Check skin buttons in all kaiju frames
			for _, kaijuFrame in ipairs(KaijuMenus:GetChildren()) do
				if kaijuFrame:IsA("Frame") then
					local skinStore = kaijuFrame:FindFirstChild("SkinStore")
					if skinStore then
						local selFrame = skinStore:FindFirstChild("SelectionFrame")
						if selFrame then
							for _, skinBtn in ipairs(selFrame:GetChildren()) do
								if skinBtn:IsA("ImageButton") then
									local skinNameVal = skinBtn:FindFirstChild("SkinName")
									local skinName = skinNameVal and skinNameVal.Value or ""
									if skinName == itemName then
										markSkinButtonOwned(skinBtn)
									end
								end
							end
						end
					end

				end
			end

				-- Check kaiju items in the Selection list
			local selectionList = menu.Characters.LeftBar:FindFirstChild("Selection")
			if selectionList then
				local kaijuItem = selectionList:FindFirstChild(itemName)
				if kaijuItem then
					local ownedVal = kaijuItem:FindFirstChild("Owned")
					if ownedVal then ownedVal.Value = true end
				end
			end
		end
	end

	-- Sync per-kaiju skins from the Skins folder in the inventory
	local skinsFolder = inv:FindFirstChild("Skins")
	if skinsFolder then
		for _, skinVal in ipairs(skinsFolder:GetChildren()) do
			if skinVal:IsA("StringValue") and skinVal.Value ~= "" then
				selectedSkins[skinVal.Name] = skinVal.Value
				print("[CLIENT] Loaded per-kaiju skin: " .. skinVal.Name .. " -> " .. skinVal.Value)
			end
		end
	end

	-- Also sync the currently equipped kaiju
	local equippedKaiju = inv:FindFirstChild("EquippedKaiju")
	if equippedKaiju and equippedKaiju.Value ~= "" then
		currentKaiju = equippedKaiju.Value
		currentSkin = selectedSkins[currentKaiju] or "Default"
	end

	-- Sync emote ownership to EmoteStore UI
	for _, kaijuFrame in ipairs(KaijuMenus:GetChildren()) do
		if kaijuFrame:IsA("Frame") then
			local emoteStore = kaijuFrame:FindFirstChild("EmoteStore")
			if emoteStore then
				local selFrame = emoteStore:FindFirstChild("SelectionFrame")
				if selFrame then
					for _, emoteBtn in ipairs(selFrame:GetChildren()) do
						if emoteBtn:IsA("ImageButton") then
							local emoteNameVal = emoteBtn:FindFirstChild("EmoteName")
							local emoteName = emoteNameVal and emoteNameVal.Value or ""
							-- Check if player owns this emote
							local ownedInInv = inv:FindFirstChild(emoteName)
							if ownedInInv and ownedInInv:IsA("BoolValue") and ownedInInv.Value then
								local ownedVal = emoteBtn:FindFirstChild("Owned")
								if ownedVal then ownedVal.Value = true end
								local costTXT = emoteBtn:FindFirstChild("CostTXT")
								if costTXT then costTXT.Visible = false end
							end
						end
					end
				end
			end
		end
	end
end)

print("Kaiju Selection Handler loaded successfully!")