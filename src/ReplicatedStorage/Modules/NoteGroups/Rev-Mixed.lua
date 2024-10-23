return function(note)
	if note.RawData[4] == "Punch" then
		note.Type = "Punch"
		note.noAnimation = true
	end
end