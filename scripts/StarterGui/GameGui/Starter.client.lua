script.Parent.Enabled = false
-- Wait for Menu to appear in PlayerGui (with timeout)
local menuGui = nil
for i = 1, 60 do
	menuGui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("Menu")
	if menuGui then break end
	task.wait(0.5)
end
if menuGui then
	local menuFrame = menuGui:FindFirstChild("Menu")
	if menuFrame and menuFrame.Visible == false then
		script.Parent.Enabled = true
	end
else
	warn("[Starter] Menu ScreenGui not found after 30 seconds")
	script.Parent.Enabled = true
end
