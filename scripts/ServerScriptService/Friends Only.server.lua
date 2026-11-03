local Players = game:GetService("Players")

-- YOUR USER ID
local OWNER_ID = 3882403525

local function onPlayerAdded(player)
	-- 1. Check if the player is the owner themselves
	if player.UserId == OWNER_ID then
		print("Owner joined: " .. player.Name)
		return
	end

	-- 2. Brief wait to ensure Roblox social data is loaded
	task.wait(1)

	-- 3. Check friendship status
	local success, isFriend = pcall(function()
		return player:IsFriendsWith(OWNER_ID)
	end)

	-- 4. Result logic
	if success and isFriend then
		print(player.Name .. " is a friend. Access granted.")
	else
		-- If check failed or they aren't a friend, kick them
		player:Kick("Testing will be public today! Check back soon!")
	end
end

-- Connect the function to new players
Players.PlayerAdded:Connect(onPlayerAdded)

-- Robustness: Check any players who might have joined before the script finished loading
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end
