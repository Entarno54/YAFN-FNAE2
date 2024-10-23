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

return {
	preStart = function()
		camControls.ForcedPos = true
		MoveCamera(mapProps.Cam.CFrame)
	end,
	Start = function()
		for _, g in script:GetChildren() do
			if not g:IsA("NumberValue") then continue end
				print(dad)
				task.wait(.3)
				dad.Obj.Humanoid:FindFirstChild(g.Name).Value = g.Value
		end
		script.SillyBillyUI:Clone().Parent = game.Players.LocalPlayer.PlayerGui

	end,
	EventTrigger = function(name, value1, value2)
		if name == "ill make" then
			if value1 == "txt" then
				print("changed text to ".. value2)
				game.Players.LocalPlayer.PlayerGui.SillyBillyUI.TxtFrame.TextLabel.Text = value2
			elseif value1 == "break mirror" then
				print(mapProps)
				mapProps.Glass.Decal.Transparency = 0
			end
			
		end
	end,
	cleanUp = function()
		game.Players.LocalPlayer.PlayerGui:FindFirstChild("SillyBillyUI"):Destroy()
	end,
}