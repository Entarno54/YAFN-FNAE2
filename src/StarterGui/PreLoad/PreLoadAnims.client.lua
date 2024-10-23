if not game:GetService("RunService"):IsStudio() then
	local BgLabel = script.Parent:WaitForChild("Background")
	BgLabel.BackgroundTransparency = 0.5
	local Text,Scale = BgLabel.TextLabel,BgLabel.Load
	local PreLoaded = 0
	local Preloaded2 = 0
	local Anims = {}
	local Notes = {}
	
	BgLabel.Visible = true
	
	function CheckIfExists(Prop,AssetId)
		for i,v in pairs(Anims) do 
			if v[Prop] == AssetId then
				return true
			end
		end
		for i,v in pairs(Notes) do 
			if v[Prop] == AssetId then
				return true
			end
		end
		return false
	end

	for i,v in pairs(game:GetService("ReplicatedStorage"):WaitForChild("Animations"):GetDescendants()) do 
		if v:IsA("Animation") then
			if v.AnimationId and string.find(v.AnimationId,"rbxassetid://") and not (CheckIfExists("AnimationId",v.AnimationId) ) then
				table.insert(Anims,v)
			end
		end
	end

	for i,v in pairs(game:GetService("StarterGui"):WaitForChild("PreLoad").DeathNotes:GetDescendants()) do 
		if v:IsA("ImageLabel") then
			if v.Image and string.find(v.Image,"rbxassetid://") then --and not (CheckIfExists("Image",v.Image) ) then
				table.insert(Notes,v)
			end
		end
	end

	for i,v in pairs(game:GetService("ReplicatedStorage"):WaitForChild("Modules").Modcharts:GetDescendants()) do 
		if v:IsA("Animation") then
			if v.AnimationId and string.find(v.AnimationId,"rbxassetid://") and not (CheckIfExists("AnimationId",v.AnimationId) ) then
				table.insert(Anims,v)
			end
		end
	end


	Text.Text = "PreLoading Anims : (1/"..#Anims..")"
	Text.Text = "PreLoading Anims : (1/"..#Notes..")"

	game:GetService("ContentProvider"):PreloadAsync(Notes,function()
		Preloaded2+=1
		Scale.Size = UDim2.fromScale(Preloaded2/#Notes,1)
		Text.Text = "PreLoading Notes : ("..Preloaded2.."/"..#Notes..")"
	end)

	game:GetService("ContentProvider"):PreloadAsync(Anims,function()
		PreLoaded+=1
		Scale.Size = UDim2.fromScale(PreLoaded/#Anims,1)
		Text.Text = "PreLoading Anims : ("..PreLoaded.."/"..#Anims..")"
		if PreLoaded == #Anims and Preloaded2 == #Notes then
			BgLabel:Destroy()
			script.Parent:Destroy() -- Destroy the parent so that it is gone, forever
		end
	end)
else
	wait(10)
	script.Parent:Destroy()
end