local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local teleportEvent = ReplicatedStorage:FindFirstChild("TeleportEvent")
if not teleportEvent then
	warn("[TeleportHandler] TeleportEvent not found in ReplicatedStorage")
	return
end

teleportEvent.OnServerEvent:Connect(function(player, placeId)
	if typeof(placeId) ~= "number" then
		warn("[TeleportHandler] Invalid placeId from " .. tostring(player))
		return
	end

	local ok, err = pcall(function()
		TeleportService:TeleportAsync(placeId, {player})
	end)

	if not ok then
		warn("[TeleportHandler] TeleportAsync failed for " .. player.Name .. ": " .. tostring(err))
	end
end)