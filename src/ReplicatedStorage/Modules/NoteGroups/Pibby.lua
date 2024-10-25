return function(note)
	if note.RawData[4] == "GF Sing" then
		note.bro = "GF"
	elseif note.RawData[4] == "Sword" then
		note.Type = "Sword"
	elseif note.RawData[4] == "Glitch" then
		
	elseif note.RawData[4] == "Second Char Sing" and note.RawData[2] <= 3  then
		note.bro = "Jake"
	elseif note.RawData[4] == "Both Chat Sing" and note.RawData[2] <= 3 then
		note.bro = {"Dad", "Jake"}
	end
	if note.RawData[4] then
		print(note.RawData[4])
	end
end