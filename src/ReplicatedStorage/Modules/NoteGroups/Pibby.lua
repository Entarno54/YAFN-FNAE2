return function(note)
	if note.RawData[4] == "GF Sing" then
		note.bro = 1
	elseif note.RawData[4] == "Sword" then
		note.Type = "Sword"
	elseif note.RawData[4] == "Glitch" then
		
	end
end