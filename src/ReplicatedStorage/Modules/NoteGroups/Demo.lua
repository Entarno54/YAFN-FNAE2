return function(note) -- Use this to just check and set some of the properties for the custom noteType.
	if note.RawData[4] == "buble" then -- To add the XML data you have to use the Note script inside of Modules
		note.Type = "buble"
		note.NoteObject.Image = game.ReplicatedStorage.Modules.Assets.DeathNotes.bubleNote.Image
		note.MissPunish = true
		note.CanSustain = true
		note.shouldPress = true
		note.NoteSplashSkin = note.NoteObject.bubleNotenoteSplash
	elseif note.RawData[4] == "notesX" then
		note.Type = "xNote"
		note.NoteObject.Image = game.ReplicatedStorage.Modules.Assets.DeathNotes.xNote.Image
		note.noAnimation = true
		note.MissPunish = true
		note.CanSustain = true
		note.shouldPress = true
		note.NoteSplashSkin = "None"
	end
end