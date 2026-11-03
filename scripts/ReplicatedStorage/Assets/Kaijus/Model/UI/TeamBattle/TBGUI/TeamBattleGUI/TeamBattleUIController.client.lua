-- Team Battle UI Controller
-- Displays the round timer and Red/Blue team scores from server-side NumberValues.
-- Self-contained: clone the TBGUI ScreenGui to a player's PlayerGui to activate.
-- Not wired to any activation system yet.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local gui = script.Parent
local timerFrame = gui:FindFirstChild("Timer")
local timerLabel = timerFrame and timerFrame:FindFirstChild("TimeTXT")
local redLabel = gui:FindFirstChild("RedLabel")
local redScoreLabel = redLabel and redLabel:FindFirstChild("TimeTXT")
local blueLabel = gui:FindFirstChild("BlueLabel")
local blueScoreLabel = blueLabel and blueLabel:FindFirstChild("TimeTXT")

-- Format seconds as M:SS
local function formatTime(seconds)
	seconds = math.max(0, math.floor(seconds))
	local m = math.floor(seconds / 60)
	local s = seconds % 60
	return string.format("%d:%02d", m, s)
end

local function updateTimer(value)
	if timerLabel then
		timerLabel.Text = formatTime(value)
	end
end

local function updateRedScore(value)
	if redScoreLabel then
		redScoreLabel.Text = tostring(value)
	end
end

local function updateBlueScore(value)
	if blueScoreLabel then
		blueScoreLabel.Text = tostring(value)
	end
end

-- Locate the server-side TeamBattle folder
local function findTeamBattleFolder()
	local server = workspace:FindFirstChild("Server")
	if not server then return nil end
	local gms = server:FindFirstChild("GameModeScripts")
	if not gms then return nil end
	return gms:FindFirstChild("TeamBattle")
end

local function connectValues()
	local tb = findTeamBattleFolder()
	if not tb then return false end

	local timer = tb:FindFirstChild("Timer")
	if timer then
		updateTimer(timer.Value)
		timer.Changed:Connect(updateTimer)
	end

	local redTeam = tb:FindFirstChild("RedTeam")
	if redTeam then
		local redScore = redTeam:FindFirstChild("Score")
		if redScore then
			updateRedScore(redScore.Value)
			redScore.Changed:Connect(updateRedScore)
		end
	end

	local blueTeam = tb:FindFirstChild("BlueTeam")
	if blueTeam then
		local blueScore = blueTeam:FindFirstChild("Score")
		if blueScore then
			updateBlueScore(blueScore.Value)
			blueScore.Changed:Connect(updateBlueScore)
		end
	end

	return timer ~= nil
end

-- Try connecting immediately
if not connectValues() then
	if timerLabel then timerLabel.Text = "0:00" end
	if redScoreLabel then redScoreLabel.Text = "0" end
	if blueScoreLabel then blueScoreLabel.Text = "0" end

	-- Watch for server folder creation
	workspace.DescendantAdded:Connect(function(descendant)
		if descendant.Name == "TeamBattle" and descendant:IsA("Folder") then
			task.wait(0.1)
			connectValues()
		end
	end)
end

-- Listen for round state events (for future integration)
local function connectRoundState()
	local event = ReplicatedStorage:FindFirstChild("RoundState")
	if event and event:IsA("RemoteEvent") then
		event.OnClientEvent:Connect(function(state)
			if state == "RoundEnd" and timerLabel then
				timerLabel.Text = "0:00"
			end
		end)
		return true
	end
	return false
end

if not connectRoundState() then
	ReplicatedStorage.DescendantAdded:Connect(function(descendant)
		if descendant.Name == "RoundState" and descendant:IsA("RemoteEvent") then
			connectRoundState()
		end
	end)
end