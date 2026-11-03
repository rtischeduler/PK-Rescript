local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NeckTurnEvent = ReplicatedStorage:WaitForChild("NeckTurn")

-- Store latest angles per player (server is just a relay now)
local playerAngles = {}
local UPDATE_RATE = 0.03 -- ~30fps broadcast rate

-- Handle incoming angles from a client
NeckTurnEvent.OnServerEvent:Connect(function(player, pitch, yaw, maxPitch, maxYaw)
	if type(pitch) ~= "number" or type(yaw) ~= "number" then return end
	playerAngles[player.UserId] = {
		pitch = pitch,
		yaw = yaw,
		maxPitch = math.clamp(maxPitch or math.rad(45), 0, math.rad(90)),
		maxYaw = math.clamp(maxYaw or math.rad(50), 0, math.rad(90))
	}
end)

-- Clean up when a player leaves
Players.PlayerRemoving:Connect(function(player)
	playerAngles[player.UserId] = nil
	-- Tell other clients to reset this player's head
	for _, otherPlayer in Players:GetPlayers() do
		NeckTurnEvent:FireClient(otherPlayer, player.UserId, 0, 0, math.rad(45), math.rad(50))
	end
end)

-- Broadcast loop: relay angles to all OTHER clients at throttled rate
while task.wait(UPDATE_RATE) do
	for userId, data in pairs(playerAngles) do
		for _, player in Players:GetPlayers() do
			if player.UserId ~= userId then
				NeckTurnEvent:FireClient(player, userId, data.pitch, data.yaw, data.maxPitch, data.maxYaw)
			end
		end
	end
end