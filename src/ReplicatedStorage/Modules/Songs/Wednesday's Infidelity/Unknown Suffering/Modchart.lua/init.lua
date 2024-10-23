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
		game.Lighting.ColorCorrection.Enabled = true
		game.Lighting.ColorCorrection.Saturation = -1
		
		-- Variables
		curSection = 0
		dodge = false
		dodgeButtons = gameHandler.settings.MenuControls.Dodge
		
		buttonCheck = game:GetService("UserInputService").InputBegan:Connect(function(input)
			if input.KeyCode == dodgeButtons[1] or input.KeyCode == dodgeButtons[2] then
				dodge = true
			end
		end)
		
		-- Make a animated sprite
		local function makeAnimatedSprite(name, image)
			local object = gameUI.realGameUI.OverlaySprite:Clone()
			object.Image = image
			object.Name = name
			object.Parent = gameUI.waste
			
			return object
		end
		
		-- Apply images to sprite
		filter = addAnimatedSprite(script.grain, false, gameUI.waste)
		filter:AddSparrowXML(script.grainXML,"grain","idle",45*playbackRate,true)
		filter:PlayAnimation("grain",true)
		filter.GUI.Visible = true
		
		warning = addAnimatedSprite(script.warning, false, gameUI.waste)
		warning.GUI.Visible = false
		warning:AddSparrowXML(script.warningXML,"warning","Advertencia",12*playbackRate,false)
	end,
	
	Start = function()
		gameHandler.setProperty("songLength", 121 * 1000)
	end,
	
	EventTrigger = function(name)
		if name == "do syringe" then
			dodge = false
			
			warning.GUI.Visible = true
			warning:PlayAnimation("warning",true)
			
			playSound(3713805456, 1.5)
			delay(1.25, function()
				if not dodge then
					gameHandler.PlayerStats.Health = 0
				end
				
				dodge = false
			end)
		end
	end,
	
	P2NoteHit = function()
		if gameHandler.PlayerStats.Health > 0.2 then
			gameHandler.PlayerStats.Health -= 0.0215
		end
	end,
	
	StepHit = function(curStep)
		if curStep % 16 == 0 then
			curSection = math.floor(curStep / 16)
		end
		
		if curSection >= 16 and curSection <= 23 then
			if curStep % 16 == 0 then
				gameHandler.processEvent("add camera zoom", .25, .082)
			end
		end
		
		if curSection >= 24 and curSection <= 47 or curSection >= 69 and curSection <= 99 then
			if curStep % 4 == 0 then
				gameHandler.processEvent("add camera zoom", .2, .07)
			end
		end
		
		if curStep == 1096 or curStep == 1100 then
			gameHandler.processEvent("add camera zoom", .2, .07)
		end
		
		if curStep == 776 or curStep == 1096 then
			gameHandler.processEvent("add camera zoom", .15, .06)
		end
		
		if curSection >= 49 and curSection <= 67 or curSection >= 109 and curSection <= 138 then
			if curStep % 8 == 0 then
				gameHandler.processEvent("add camera zoom", .15, .06)
			end
		end
		
		if curStep == 224 then
			-- follow dad pos
			gameHandler.processEvent("camera follow pos", -300, -20)
		end
	end,
	
	cleanUp = function()
		game.Lighting.ColorCorrection.Enabled = false
		
		filter = nil
		warning = nil
		curSection = nil
		dodge = nil
		dodgeButtons = nil
		buttonCheck:Disconnect()
		buttonCheck = nil
	end,
}