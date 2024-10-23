--!nolint UnknownGlobal
--!nolint UninitializedLocal
local Conductor = require(game.ReplicatedStorage.Modules.Conductor)
local minecraftSky = nil

return {
	preStart = function()
		local bf = playerObjects.BF
		local dad = playerObjects.Dad
		-- Make characters have their humanoid root part their primary part
		bf.Obj.PrimaryPart = bf.Obj.HumanoidRootPart
		dad.Obj.PrimaryPart = dad.Obj.HumanoidRootPart
		
		-- Also move BF and Dad into their proper positions
		local newDadPos = mapProps:FindFirstChild("dadPos").CFrame
		local newBFPos = mapProps:FindFirstChild("bfPos").CFrame
		
		gameHandler.PositioningParts.Right.CFrame = newDadPos
		gameHandler.PositioningParts.Left.CFrame = newBFPos
		
		-- Destroy these parts to fix potential anim clipping
		mapProps.dadPos:Destroy()
		mapProps.bfPos:Destroy()
		
		bf.Obj:PivotTo(newBFPos)
		dad.Obj:PivotTo(newDadPos)
	end,
	
	sectionChange = function()
		
	end,
	
	cleanUp = function()
	end,
}