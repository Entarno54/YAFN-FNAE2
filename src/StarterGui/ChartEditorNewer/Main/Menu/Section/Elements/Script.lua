local module = {}

local function toggleButton(button:ImageButton, state:boolean)
	if state == true then
		button.Image = "rbxassetid://103326983765336"
		button:SetAttribute("Activated", false)
	else
		button.Image = "rbxassetid://75319357442213"
		button:SetAttribute("Activated", true)
	end
end

module.Loaded = function(Settings, SongInfo, SongData, funcs)
	print('Loading sh in the custom script')
	
	-- Load the musthit section button
	funcs.addConnection(script.Parent.MustHit.ImageButton.Activated:Connect(function()
		-- Handle check box (currently cannot change it)
		if script.Parent.MustHit.ImageButton:GetAttribute("Activated") == true then
			toggleButton(script.Parent.MustHit.ImageButton, false)
		else
			toggleButton(script.Parent.MustHit.ImageButton, true)
		end
	end))
end

module.sectionChange = function(sectionData)
	toggleButton(script.Parent.MustHit.ImageButton, sectionData.mustHitSection)
	
	toggleButton(script.Parent.GFSection.ImageButton, sectionData.gfSection)
	
	toggleButton(script.Parent.ChangeBPM.ImageButton, sectionData.changeBPM)
	if tonumber(sectionData.bpm) ~= nil then
		script.Parent.BPM.TextBox.Text = sectionData.bpm
	end
end

return module