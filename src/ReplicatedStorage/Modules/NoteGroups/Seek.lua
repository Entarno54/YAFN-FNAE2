return function(note)
	if note.RawData[4] == "No Animation" then
		note.noAnimation = true
	elseif note.RawData[4] == "shield" then
		note.Type = "shield"
	end
end