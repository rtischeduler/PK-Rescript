local menu = script.Parent
local soundsFolder = menu:WaitForChild("Sounds")
local scrollSound = soundsFolder:FindFirstChild("Scroll")
local clickSound = soundsFolder:FindFirstChild("Click")

local function setupImageButton(imageButton)
    -- Check if already set up
    if imageButton:GetAttribute("SoundSetup") then
        return
    end
    
    -- Check if there's a child named "Button" inside
    local childButton = imageButton:FindFirstChild("Button")
    if not childButton then
        return -- Skip if no Button child
    end
    
    imageButton:SetAttribute("SoundSetup", true)
    
    -- Store original transparency of the ImageButton
    local originalTransparency = imageButton.ImageTransparency or 0
    
    -- MouseEnter on ImageButton: play Scroll sound and set transparency to 0.3
    imageButton.MouseEnter:Connect(function()
        if scrollSound then
            scrollSound:Play()
        end
        imageButton.ImageTransparency = 0.3
    end)
    
    -- MouseLeave on ImageButton: restore original transparency
    imageButton.MouseLeave:Connect(function()
        imageButton.ImageTransparency = originalTransparency
    end)
    
    -- Click on the child Button: play Click sound
    childButton.MouseButton1Click:Connect(function()
        if clickSound then
            clickSound:Play()
        end
    end)
end

-- Find all ImageButtons that have a child named "Button"
local function findAndSetupButtons()
    for _, descendant in menu:GetDescendants() do
        if descendant:IsA("ImageButton") then
            setupImageButton(descendant)
        end
    end
end

-- Setup existing buttons
findAndSetupButtons()

-- Handle buttons added later
menu.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("ImageButton") then
        setupImageButton(descendant)
    end
end)