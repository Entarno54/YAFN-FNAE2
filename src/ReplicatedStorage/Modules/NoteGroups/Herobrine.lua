return function(note)
	--[[
	if tonumber(note.RawData[2]) > 3 then
		note.bro = {"BF","BF2","Dad3","BF3"} -- oh my g
	end
	--]]
	if note.RawData[4] == "Attack" then
		note.Type = "Attack"
		--note.bro = {"Dad2","BF2"} -- Testing the extra characters thing
	elseif tonumber(note.RawData[2]) < 4 then
		--note.bro = {"BF","BF2","Dad3","BF3"}
	end
end