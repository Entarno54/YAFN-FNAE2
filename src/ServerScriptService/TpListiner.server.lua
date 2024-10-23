local Remote = game:GetService("ReplicatedStorage"):WaitForChild("​​")
local antiplrspam = {}
local players = game:GetService("Players")


function GetPlr(BedName)
	if not BedName then
		return nil 
	end
	BedName = string.lower(BedName)
	for i,v in pairs(players:GetPlayers()) do
		if string.find(string.lower(v.Name),BedName) then
			return v 
		end
	end	
	for i,v in pairs(players:GetPlayers()) do
		if string.find(string.lower(v.DisplayName),BedName) then
			return v 
		end
	end	
	return nil
end

Remote.OnServerEvent:Connect(function(LP,p,m)
	if p then
		if typeof(p) == "Instance" then
			if p:IsA("Player") and p:IsFriendsWith(LP.UserId) then
				if p.Character and LP.Character then
					pcall(function()
						print("Teleported")
						p.Character:SetPrimaryPartCFrame(LP.Character.HumanoidRootPart.CFrame)
					end)
				end
			end
		end
	end
end)


game:GetService("Players").PlayerAdded:Connect(function(Plr)
	if game.PlaceId == 7159173756 then
		if not game:GetService("RunService"):IsStudio() and workspace:GetAttribute("Warning") then
			delay(1,function()
				Remote:FireClient(Plr,workspace:GetAttribute("Warning"),"Message",Color3.new(1, 0.215686, 0.227451))
			end)
		end
	end
	Plr.Chatted:Connect(function(msg)
		local msg = (msg or "")
		if string.sub(msg,1,7) == "/e tpa/" or string.sub(msg,1,4) == "tpa/" then
			local Prefix,Suffix = string.find(msg,"tpa")
			Suffix+=2
			local Input = GetPlr(string.sub(msg,Suffix))
			if Input then
				if Input == Plr then
					return
				end
				if not Plr.Character:FindFirstChild("HumanoidRootPart") or Plr.Character.HumanoidRootPart.Anchored then
					return
				end
				if not antiplrspam[Plr] then
					antiplrspam[Plr] = tick() - 4
				end
				if Plr:IsFriendsWith(Input.UserId) then
					if tick() - antiplrspam[Plr] > 3 then
						antiplrspam[Plr] = tick()
						Remote:FireClient(Input,Plr)
						Remote:FireClient(Plr,"Teleport request sent to "..Input.DisplayName,"Message")
					else 
						Remote:FireClient(Plr,"Slow down, You have around ".. string.sub(tostring( 3 - (tick() - antiplrspam[Plr]) ),1,4).." seconds left","Message",Color3.new(1, 0.215686, 0.227451))
					end					
				else 
					Remote:FireClient(Plr,"You can only send a tp request to your friends ","Message",Color3.new(1, 0.215686, 0.227451))
				end
			end
		end
	end)
end)

