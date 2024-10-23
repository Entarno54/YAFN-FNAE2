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
local helper = require(game.ReplicatedStorage.Modules.ModchartHelper)

local buttonCheck = nil
local connection = nil
return {
	EventTrigger = function(name, var1, var2)
		if name == "camerapostest1" then
			camControls.ForcedPos = true
			connection = game["Run Service"].RenderStepped:Connect(function()
				MoveCamera(mapProps.CameraTest.CFrame)
			end)
			camControls.targetCam = cf
		elseif name == "camerapostest2" then
			camControls.ForcedPos = false
		end
	end,
}