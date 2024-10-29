local Lighting = game:GetService("Lighting")
--!nolint UnknownGlobal
--!nolint UninitializedLocal
local Conductor = require(game.ReplicatedStorage.Modules.Conductor)
local minecraftSky = nil
local properties = {
	["Ambient"] = Color3.fromRGB(44, 44, 44),
	["EnvironmentDiffuseScale"] = 0,
	["EnvironmentSpecularScale"] = 0,
}
local originalproperties = {
	["Ambient"] = game.Lighting.Ambient,
	["EnvironmentSpecularScale"] = game.Lighting.EnvironmentSpecularScale,
	["EnvironmentDiffuseScale"] = game.Lighting.EnvironmentDiffuseScale
}
return {
	preStart = function()
		local bf = playerObjects.BF
		local dad = playerObjects.Dad
		local pibby = playerObjects.GF
		local jake = playerObjects.Jake
		-- Make characters have their humanoid root part their primary part
		bf.Obj.PrimaryPart = bf.Obj.HumanoidRootPart
		dad.Obj.PrimaryPart = dad.Obj.HumanoidRootPart
		pibby.Obj.PrimaryPart = pibby.Obj.HumanoidRootPart
		jake.Obj.PrimaryPart = jake.Obj.HumanoidRootPart
		
		-- Also move BF and Dad into their proper positions
		local newDadPos = mapProps:FindFirstChild("FinnPos").CFrame
		local newBFPos = mapProps:FindFirstChild("BFPos").CFrame
		local newPpos = mapProps:FindFirstChild("GFPos").CFrame
		local newJPos = mapProps:FindFirstChild("JakePos").CFrame
		
		gameHandler.PositioningParts.Right.CFrame = newDadPos
		gameHandler.PositioningParts.Left.CFrame = newBFPos
		
		-- Destroy these parts to fix potential anim clipping
		--mapProps.dadPos:Destroy()
		--mapProps.bfPos:Destroy()
		
		bf.Obj:PivotTo(newBFPos)
		dad.Obj:PivotTo(newDadPos)
		pibby.Obj:PivotTo(newPpos)
		jake.Obj:PivotTo(newJPos)
		for _, property in properties do
			game.Lighting[_] = property
		end
	end,
	
	sectionChange = function()
		
	end,
	
	cleanUp = function()
		for _, property in originalproperties do
			game.Lighting[_] = property
		end
	end,
}