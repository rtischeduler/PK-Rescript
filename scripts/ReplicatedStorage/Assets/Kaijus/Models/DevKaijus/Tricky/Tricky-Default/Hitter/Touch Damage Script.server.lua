function onTouched(part)
	local h = part.Parent:findFirstChild("Humanoid")
	if h~=nil then
		h.Health = h.Health -60 ---Change This to whatever damage you want it to cause.It can also add health by using the + sign.
	end
end

script.Parent.Touched:connect(onTouched)
--Script by JonnyNinja234