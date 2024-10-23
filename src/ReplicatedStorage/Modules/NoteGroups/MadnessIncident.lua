return function(note)
	if note.RawData[4] == "Expurgation Note" then
		note.Type = "kill"
		--note.IsSustain = true
		note.NoteObject.Image = game.ReplicatedStorage.Modules.Assets.DeathNotes.attackNote.Image
		note.MissPunish = false
		note.CanSustain = true
		note.shouldPress = false
	--elseif table.find({80,81,82,83}, note.RawData[2]) then
	--	note.Type = "kill"
	--	--note.IsSustain = true
	--	note.NoteObject.Image = game.ReplicatedStorage.Modules.Assets.DeathNotes.attackNote.Image
	--	note.MissPunish = false
	--	note.CanSustain = true
	--	note.shouldPress = false
	end
end