-- Solo Battle UI Controller
-- Displays the round timer from the server-side Timer NumberValue.
-- Self-contained: clone the SoloGUI ScreenGui to a player's PlayerGui to activate.
-- Not wired to any activation system yet.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local gui = script.Parent
local timerFrame = gui:FindFirstChild("Timer")
local timerLabel = timerFrame and timerFrame:FindFirstChild("TimeTXT")

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

-- Connect to the server-side SoloBattle Timer NumberValue
local function findServerTimer()
	local server = workspace:FindFirstChild("Server")
	if not server then return nil end
	local gms = server:FindFirstChild("GameModeScripts")
	if not gms then return nil end
	local solo = gms:FindFirstChild("SoloBattle")
	if not solo then return nil end
	return solo:FindFirstChild("Timer")
end

local serverTimer = findServerTimer()
if serverTimer then
	updateTimer(serverTimer.Value)
	serverTimer.Changed:Connect(updateTimer)
else
	if timerLabel then
		timerLabel.Text = "0:00"
	end
	-- Watch for the server timer being created later
	workspace.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("NumberValue") and descendant.Name == "Timer" then
			local parent = descendant.Parent
			if parent and parent.Name == "SoloBattle" then
				updateTimer(descendant.Value)
				descendant.Changed:Connect(updateTimer)
			end
		end
	end)
end

-- Listen for round state events (for future integration)
local function connectRoundState()
	local event = ReplicatedStorage:FindFirstChild("RoundState")
	if event and event:IsA("RemoteEvent") then
		event.OnClientEvent:Connect(function(state)
			-- "RoundStart" or "RoundEnd" -- can be used when integrated
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