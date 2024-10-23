local module = {}

module.Loaded = function(Settings, SongInfo, SongData, funcs)
	print('Loading sh in the custom script')
	
	-- Load the instrumental volume button
	script.Parent.InstVolume.TextBox.Text = SongInfo.InstrumentalVolume or 2
	funcs.addConnection(script.Parent.InstVolume.TextBox.FocusLost:Connect(function()
		local newValue = funcs.convertToNumber(script.Parent.InstVolume.TextBox.Text, 2, 0.1, 5)
		script.Parent.InstVolume.TextBox.Text = tostring(newValue)
		
		SongInfo.InstrumentalVolume = newValue
		funcs.reloadAudio()
	end))
	
	-- Load the voices volume button
	script.Parent.VoicesVolume.TextBox.Text = SongInfo.VoicesVolume or 2
	funcs.addConnection(script.Parent.VoicesVolume.TextBox.FocusLost:Connect(function()
		local newValue = funcs.convertToNumber(script.Parent.VoicesVolume.TextBox.Text, 2, 0.1, 5)
		script.Parent.VoicesVolume.TextBox.Text = tostring(newValue)

		SongInfo.VoicesVolume = newValue
		funcs.reloadAudio()
	end))
	
	script.Parent.BPM.TextBox.Text = SongData.bpm
	funcs.addConnection(script.Parent.BPM.TextBox.FocusLost:Connect(function()
		local newValue = funcs.convertToNumber(script.Parent.BPM.TextBox.Text, SongData.bpm or 150, 0, nil)
		script.Parent.BPM.TextBox.Text = tostring(newValue)

		SongData.bpm = newValue
		-- Reload the chart size or whatever
	end))
	
	script.Parent.Offset.TextBox.Text = SongInfo.Offset or 0
	funcs.addConnection(script.Parent.Offset.TextBox.FocusLost:Connect(function()
		local newValue = funcs.convertToNumber(script.Parent.Offset.TextBox.Text, 0, -10000, nil)
		script.Parent.Offset.TextBox.Text = tostring(newValue)

		SongInfo.Offset = newValue
	end))
end

return module