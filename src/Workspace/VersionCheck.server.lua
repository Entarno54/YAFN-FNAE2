do
	local VERSION = "Prerelease V5"

	local success, err = pcall(function()
		local request = game:GetService("HttpService"):GetAsync("https://raw.githubusercontent.com/Piper0007/YAFN-Banana-Edition/main/Version.json")
		
		--print("Data From GitHub: " .. request)
		request = game:GetService("HttpService"):JSONDecode(tostring(request))

		if (tostring(request.VERSION) ~= VERSION) then
			warn('This version of the engine is not up to date, if you want go check out the new version at: "https://github.com/Piper0007/YAFN-Banana-Edition"')
		end
	end)
	
	if not success then warn("Problem While Checking Version -> " .. err) end
end
