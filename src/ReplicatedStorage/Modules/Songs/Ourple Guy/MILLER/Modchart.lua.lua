 --!nolint UnknownGlobal
--!nolint UninitializedLocal
local Conductor = require(game.ReplicatedStorage.Modules.Conductor)
local sprite = require(game.ReplicatedStorage.Modules.Sprite)
local filter = nil
local warning = nil
local curSection = nil
local dodge = nil
local dodgeButtons = nil
--local timer = 0;

local buttonCheck = nil
--local characters = {"bf", "GF", "BF"}
local objects = {
	camHUD = nil;
	dad = nil;
	camGame = nil;
}
local helper = require(game.ReplicatedStorage.Modules.ModchartHelper)

return {

	EventTrigger = function(name, value1, value2)
		--print(name)'
		--print(value1)'
		if name == "set note type" then
			local char = string.split(value1, " ")[1]
			print(char)
			--print(characters[char])
			script:SetAttribute("CurChar", string.split(value1, " ")[1])
			if value1 == "BF" then
				script:SetAttribute("CurChar", "BF")
			end
		elseif name == "all sing" then
			script:SetAttribute("CurChar", "All")
		elseif name == "add alpha" then
			print(value1, value2, tonumber(value2), objects[value1])
			if objects[value1] and tonumber(value2) then
				if objects[value1]:IsA("Model") then
					for _, part in objects[value1]:GetDescendants() do
						if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" or part:IsA("Decal") then
							part.Transparency -= tonumber(value2)
						end
					end
				elseif not objects[value1]:IsA("Model") then
					objects[value1].BackgroundTransparency += tonumber(value2)
				end
			end
		elseif name == "decrease alpha" then
			print(value1, value2, tonumber(value2))
			if objects[value1] and tonumber(value2) then
				print(objects[value1]:IsA("Model"))
				if objects[value1]:IsA("Model") then
					for _, part in objects[value1]:GetDescendants() do
						if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" or part:IsA("Decal") then
							part.Transparency += tonumber(value2)
						end
					end
				elseif not objects[value1]:IsA("Model") then
					objects[value1].BackgroundTransparency -= tonumber(value2)
				end
			end
		elseif name == "alter visibility" then
			print(value1)
			local character = playerObjects[value1]
			print(character)
			local visibility = value2 == "true" and 0 or 1
			if character then
				for _, p in character.Obj:GetDescendants() do
					if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" or p:IsA("Decal") then
						p.Transparency = visibility
					end
				end
			end
			if value1 == "camHUD" then
				HideNotes(visibility == 1 and true or false, "both", true)
			end
		elseif name == "object play animation" then
			print(name, value1, value2)
			if value2 == "die" then
				print(value2, playerObjects)
				if playerObjects[value1] then
					gameHandler.processEvent("Alter Visibility", value1, "false")
				end
			elseif value2 == "idle" or value2 == "dance" then
				if playerObjects[value1] then
					gameHandler.processEvent("Alter Visibility", value1, "true")
				end
			end
		end
	end,
	
	preStart = function()
		camControls.StayOnCenter = true
		local dad = playerObjects.Dad.Obj
		dad.PrimaryPart  = dad.HumanoidRootPart
		dad:PivotTo(mapProps.Dad.CFrame)
		if not gameUI:FindFirstChild("Tint") then
			objects.camHUD = addSprite("Tint", Color3.new(0,0,0))
			objects.camHUD.Position = UDim2.new(-.5, 0, -.5, 0)
			objects.camHUD.Size = UDim2.new(100, 0, 100, 0)
			objects.camHUD.Visible = true
			objects.camHUD.BackgroundTransparency = 0
			objects.camHUD.Parent = gameUI
		end
		objects.camGame = objects.camHUD
		gameHandler.processEvent("Alter Visibility", "Dad", "false")
		objects.dad = dad
		for _, object in objects.dad:GetDescendants() do
			if not object:IsA("BasePart") then continue end
			if object.Transparency == 1 then
				object:AddTag("CantChangeAlpha")
			end
		end
	end,
	
	Start = function()
	end,
	
	cleanUp = function()
		script:SetAttribute("CurChar", "BF")
	end,
}