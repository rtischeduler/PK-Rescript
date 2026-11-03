--[[
    BeamClashClient
    Full client-side beam clash handler:
    - Clones the BeamClash UI from ReplicatedStorage
    - Shows 3-second countdown
    - 5-second spam window with click counting
    - FillFull sizes up while spamming
    - Shows FULL CAP when bar is full
    - Animation looping during clash
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local BeamClashModule = require(ReplicatedStorage:FindFirstChild("BeamClashModule"))
local BeamClashRemote = ReplicatedStorage:FindFirstChild("BeamClashRemote")

local player = Players.LocalPlayer
local isClashing = false
local isSpamPhase = false
local clickCount = 0
local clashUI = nil
local clashRenderConnection = nil
local inputConnection = nil

-- Path to the BeamClash UI template
local BEAM_CLASH_UI_PATH = "Assets.Kaijus.Effects.AttackEffects.BeamClash"

-- Find the Animator in a character
local function findAnimator(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		return humanoid:FindFirstChildOfClass("Animator")
	end
	return nil
end

-- Clone the BeamClash UI into PlayerGui
local function showClashUI()
	if clashUI then return end
	
	local template = ReplicatedStorage:FindFirstChild(BEAM_CLASH_UI_PATH, true)
	if not template then return end
	
	local playerGui = player:FindFirstChild("PlayerGui")
	if not playerGui then return end
	
	clashUI = template:Clone()
	clashUI.Name = "BeamClashUI"
	clashUI.Parent = playerGui
	
	-- Reset UI state
	local theLabel = clashUI:FindFirstChild("TheLabel")
	if theLabel then
		theLabel.Text = "Beam clashing!"
	end
	
	local yourClicks = clashUI:FindFirstChild("YourClicks")
	if yourClicks then
		yourClicks.Text = "0"
	end
	
	local option = clashUI:FindFirstChild("Option")
	if option then
		option.Text = ""
	end
	
	-- Reset FillFull inner to 0 size
	local fillFull = clashUI:FindFirstChild("FillFull")
	if fillFull then
		local innerFill = fillFull:FindFirstChild("FillFull")
		if innerFill then
			innerFill.Size = UDim2.new(0, 0, 0, 0)
		end
	end
end

-- Remove the clash UI
local function hideClashUI()
	if clashUI then
		clashUI:Destroy()
		clashUI = nil
	end
end

-- Update the FillFull bar size based on click count
local function updateFillBar(count)
	if not clashUI then return end
	
	local fillFull = clashUI:FindFirstChild("FillFull")
	if not fillFull then return end
	
	local innerFill = fillFull:FindFirstChild("FillFull")
	if not innerFill then return end
	
	local ratio = BeamClashModule.GetFillSize(count)
	-- Size up from 0 to full within the container
	innerFill.Size = UDim2.new(ratio, 0, ratio, 0)
	
	-- Check if full cap reached
	if ratio >= 1 then
		local theLabel = clashUI:FindFirstChild("TheLabel")
		if theLabel then
			theLabel.Text = "FULL CAP!"
		end
	end
end

-- Start animation looping during a clash
local function startClashEffects()
	if isClashing then return end
	isClashing = true
	clickCount = 0
	
	showClashUI()
	
	clashRenderConnection = RunService.RenderStepped:Connect(function()
		if not isClashing then return end
		
		local char = player.Character
		if not char then return end
		
		local animator = findAnimator(char)
		if animator then
			for _, track in animator:GetPlayingAnimationTracks() do
				local length = track.Length
				if length > 0 then
					local loopStart, loopEnd = BeamClashModule.GetLoopWindow(length)
					if track.TimePosition >= loopEnd then
						track.TimePosition = loopStart
					elseif track.TimePosition < loopStart then
						track.TimePosition = loopStart
					end
				end
			end
		end
	end)
end

-- Stop animation looping and clean up
local function stopClashEffects()
	isClashing = false
	isSpamPhase = false
	clickCount = 0
	
	if clashRenderConnection then
		clashRenderConnection:Disconnect()
		clashRenderConnection = nil
	end
	
	if inputConnection then
		inputConnection:Disconnect()
		inputConnection = nil
	end
	
	hideClashUI()
end

-- Start the spam phase - enable click detection
local function startSpamPhase()
	isSpamPhase = true
	
	if clashUI then
		local option = clashUI:FindFirstChild("Option")
		if option then
			option.Text = "MASH MOUSE BUTTON TO WIN!!"
		end
	end
	
	-- Listen for mouse clicks
	inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not isSpamPhase then return end
		if gameProcessed then return end
		
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			clickCount = clickCount + 1
			
			-- Update UI locally
			if clashUI then
				local yourClicks = clashUI:FindFirstChild("YourClicks")
				if yourClicks then
					yourClicks.Text = tostring(clickCount)
				end
			end
			
			updateFillBar(clickCount)
			
			-- Send click to server
			BeamClashRemote:FireServer("ClashClick")
		end
	end)
end

-- Listen for clash events from the server
BeamClashRemote.OnClientEvent:Connect(function(action, data)
	if action == "ClashStart" then
		startClashEffects()
		
	elseif action == "ClashCountdown" then
		-- data is the countdown number (3, 2, 1)
		if clashUI then
			local theLabel = clashUI:FindFirstChild("TheLabel")
			if theLabel then
				theLabel.Text = tostring(data)
			end
		end
		
	elseif action == "ClashSpamStart" then
		startSpamPhase()
		
	elseif action == "ClashClickUpdate" then
		-- Server confirmed our click count
		-- We already update locally, so this is just a confirmation
		
	elseif action == "ClashResult" then
		isSpamPhase = false
		
		if inputConnection then
			inputConnection:Disconnect()
			inputConnection = nil
		end
		
		if clashUI then
			local theLabel = clashUI:FindFirstChild("TheLabel")
			if theLabel then
				if data.winner then
					theLabel.Text = "YOU WIN!"
				else
					theLabel.Text = "YOU LOSE!"
				end
			end
			local option = clashUI:FindFirstChild("Option")
			if option then
				option.Text = data.yourClicks .. " vs " .. data.opponentClicks
			end
		end
		
	elseif action == "ClashEnd" then
		stopClashEffects()
	end
end)

-- Handle character respawn
player.CharacterAdded:Connect(function()
	if isClashing then
		stopClashEffects()
	end
end)