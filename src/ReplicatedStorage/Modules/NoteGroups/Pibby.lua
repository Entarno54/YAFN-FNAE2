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
	elseif note.RawData[4] == "Dodge Note" then
		note.CustomAnimation = "dodge"
	elseif note.RawData[4] == "Attack Note" then
		note.CustomAnimation = "shoot"..tostring(math.random(1, 3))
	end
	if note.RawData[4] then
		print(note.RawData[4])
	end
end