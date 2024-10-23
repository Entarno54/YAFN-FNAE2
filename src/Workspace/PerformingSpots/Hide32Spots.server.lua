wait(3)
if game.PrivateServerId == "" then
	for i,v in pairs(script.Parent:GetChildren()) do 
		if v.Name == "32v32" then
			v:Destroy()
		end
	end
end