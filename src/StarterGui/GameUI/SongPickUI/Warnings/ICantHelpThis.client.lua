script.Parent.Parent:WaitForChild("SongPick"):GetPropertyChangedSignal("Visible"):Connect(function()
	script.Parent.Visible = script.Parent.Parent.SongPick.Visible
end)