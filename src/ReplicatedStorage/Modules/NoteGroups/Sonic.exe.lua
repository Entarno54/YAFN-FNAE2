return function(note) -- leaving this here just so that you people have a sense on what NoteGroups are for
	if note.RawData[4] == 2 then --glitch note
		note.Type = "Static"
	end
	if note.RawData[4] == 3 then --phantom note
		note.Type = "PhantomSonic"
	end
	if note.Mania == 3 then
		if note.RawData[2] == 2 or note.RawData[2] == 7 then
			note.Type = "Ring"
			note.noAnimation = true
		end
	end
end