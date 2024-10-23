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
local curjumpscare = nil
local cursub = nil
local set = false

return {
	EventTrigger = function(name, var1, var2)
		print(name)
		if name == "obituary" then
			print(var1)
			print(var2)
			if var1 == "scare" then
				print("hi")
				if not curjumpscare then
					curjumpscare = addSprite("Jumpscare", "rbxassetid://16178489116")
					curjumpscare.Visible = true
					curjumpscare.Transparency = 0
				end
				task.wait(5)
				curjumpscare.Visible = false
				--game.Lighting.ColorCorrection.TintColor = Color3.new(1, 0.298039, 0.298039)
				--game.Lighting.ColorCorrection.Enabled = true
				game.Lighting.SkyPrefigs.Bloody.Parent = game.Lighting
				
			end
		elseif name == "very evil scary thing two" then
			print("hi again")
			script.Jumpscare:Clone().Parent = game.Players.LocalPlayer.PlayerGui
			game.Lighting.Bloody.Parent = game.Lighting.SkyPrefigs
			game.Lighting.SkyPrefigs.BlackSky.Parent = game.Lighting
			task.delay(4, function()
				game.Players.LocalPlayer.PlayerGui:FindFirstChild("Jumpscare"):Destroy()
			end)
		elseif name == "subtitles" then
			local times = tonumber(var1)
			local text = var2
			cursub.Subtitles.Text = var2
			--task.delay(times, function()
			--	cursub.Subtitles.Text = ""
			--end)
		end
	end,
	preStart = function()
		if set then return end 
		set = true
		cursub = script.TestThingsGUI:Clone()
		cursub.Parent = game.Players.LocalPlayer.PlayerGui
	end,
	cleanUp = function()
		if game.Lighting:FindFirstChild("BlackSky") then game.Lighting.BlackSky.Parent = game.Lighting.SkyPrefigs end
		if game.Lighting:FindFirstChild("Bloody") then game.Lighting.Bloody.Parent = game.Lighting.SkyPrefigs end
		game.Lighting.ColorCorrection.Enabled = false
		cursub:Destroy()
	end,
}