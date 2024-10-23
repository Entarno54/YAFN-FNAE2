return function(note)
	if table.find({24,25,26,27}, note.RawData[2]) then
		note.Type = "nightmare"
		--note.IsSustain = true
		note.NoteObject.Image = game.ReplicatedStorage.Modules.Assets.DeathNotes.nightmareNote.Image
		note.MissPunish = false
		note.CanSustain = true
		note.shouldPress = true
	--elseif table.find({80,81,82,83}, note.RawData[2]) then
	--	note.Type = "kill"
	--	--note.IsSustain = true
	--	note.NoteObject.Image = game.ReplicatedStorage.Modules.Assets.DeathNotes.attackNote.Image
	--	note.MissPunish = false
	--	note.CanSustain = true
	--	note.shouldPress = false
	end
end