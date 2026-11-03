local EmoteHandler = {}
EmoteHandler._currentCleanup = nil

function EmoteHandler.play(emoteScript, animationId)
	-- Stop any currently playing emote first
	if EmoteHandler._currentCleanup then
		EmoteHandler._currentCleanup()
	end

	local charVal = emoteScript:FindFirstChild("Char")
	local character = charVal and charVal.Value
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end

	local player = game.Players.LocalPlayer
	local gameGui = player:FindFirstChild("PlayerGui")
		and player.PlayerGui:FindFirstChild("GameGui")
	local control = gameGui and gameGui:FindFirstChild("Control", true)
	local values = control and control:FindFirstChild("Values")
	local actions = values and values:FindFirstChild("Actions")
	local doingSomething = actions and actions:FindFirstChild("DoingSomething")


	-- Create and play the animation with fade-in
	local anim = Instance.new("Animation")
	anim.AnimationId = "rbxassetid://" .. animationId
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end
	local track = animator:LoadAnimation(anim)
	track:Play(0.35)

	-- Mark emote as active
	if doingSomething then
		doingSomething.Value = true
	end

	-- Cleanup: tween-fade the animation out and restore state
	local cleaned = false
	local function cleanup()
		if cleaned then return end
		cleaned = true
		EmoteHandler._currentCleanup = nil
		if moveConn then moveConn:Disconnect() end

		if track.IsPlaying then
			track:Stop(0.35) -- tween fade out
		end

		if doingSomething then
			doingSomething.Value = false
		end

		-- Destroy the emote script after fade completes (non-blocking)
		task.delay(0.35, function()
			if emoteScript and emoteScript.Parent then
				emoteScript:Destroy()
			end
		end)
	end

	-- Store cleanup so next emote can cancel this one
	EmoteHandler._currentCleanup = cleanup

	-- Cancel on movement / ability keys
	local cancelKeys = {
		[Enum.KeyCode.W] = true, [Enum.KeyCode.A] = true,
		[Enum.KeyCode.S] = true, [Enum.KeyCode.D] = true,
		[Enum.KeyCode.Z] = true, [Enum.KeyCode.X] = true,
		[Enum.KeyCode.C] = true, [Enum.KeyCode.G] = true,
		[Enum.KeyCode.R] = true,
	}

	local uis = game:GetService("UserInputService")

	-- Cancel immediately if already moving when emote starts
	local moveKeys = {Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D}
	for _, key in moveKeys do
		if uis:IsKeyDown(key) then
			cleanup()
			return
		end
	end

	uis.InputBegan:Connect(function(input, processed)
		if processed then return end
		if cancelKeys[input.KeyCode] then
			cleanup()
		end
	end)

	-- Cancel on any actual movement (covers joystick, auto-walk, etc.)
	local runService = game:GetService("RunService")
	local moveConn
	moveConn = runService.RenderStepped:Connect(function()
		if humanoid.MoveDirection.Magnitude > 0 then
			cleanup()
		end
	end)

	-- Cancel if stunned
	local aspects = character:FindFirstChild("Aspects")
	if aspects then
		local stunFolder = aspects:FindFirstChild("Stun")
		if stunFolder then
			local stunned = stunFolder:FindFirstChild("Stunned")
			if stunned then
				stunned.Changed:Connect(function()
					if stunned.Value then
						cleanup()
					end
				end)
			end
		end
	end

	-- For NPCs: cancel if kaiju model changes or another emote starts
	if character.Name ~= player.Name then
		local menuValues = player.PlayerGui:FindFirstChild("Menu")
			and player.PlayerGui.Menu.Menu:FindFirstChild("Values")
		if menuValues then
			local kaijuModel = menuValues:FindFirstChild("KaijuModel")
			if kaijuModel then
				kaijuModel.Changed:Connect(function()
					cleanup()
				end)
			end
		end

		local emoteScriptsFolder = player.PlayerGui:FindFirstChild("Menu")
			and player.PlayerGui.Menu.Menu:FindFirstChild("EmoteScripts")
		if emoteScriptsFolder then
			emoteScriptsFolder.ChildAdded:Connect(function()
				cleanup()
			end)
		end
	end
end

return EmoteHandler