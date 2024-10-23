--!nolint UnknownGlobal
--!nolint UninitializedLocal
local Conductor = require(game.ReplicatedStorage.Modules.Conductor)
local TS = game:GetService("TweenService")

-- Make blank variables
local colors = {};

local angleshit = nil;
local anglevar = nil;

local mustHitSection = nil;
local triggerEvent = nil;
local setProperty = nil;
local GameUI = nil;

local tweens = {};

local xx = nil; -- dad x offset
local yy = nil; -- dad y offset
local xx2 = nil; -- bf x offset
local yy2 = nil; -- bf y offset
local ofs = nil;
local followchars = nil;
local dad = nil;
local bf = nil;

-- Define blank function
local addTween = nil;

return {
	preStart = function()
		-- Define Variables
		dad = playerObjects.Dad
		bf = playerObjects.BF
		colors = {'#31a2fd', '#31fd8c', '#f794f7', '#f96d63', '#fba633'};
		angleshit = 1;
		anglevar = 1;
		mustHitSection = true
		triggerEvent = gameHandler.processEvent
		setProperty = gameHandler.setProperty
		GameUI = gameUI.realGameUI.Notes

		tweens = {};

		xx = 40;
		yy = 5;
		xx2 = -40;
		yy2 = -5;
		ofs = 90;
		followchars = false;

		-- Define Function
		addTween = function(tween)
			tween:Play()
			table.insert(tweens, tween)

			tween.Completed:Connect(function()
				table.remove(tweens, table.find(tweens, tween))
			end)
		end
	end,
	
	Start = function()
		followchars = true
	end,
	
	sectionChange = function(section)
		mustHitSection = section.mustHitSection
		
		if mustHitSection == false then
			setProperty('defaultCamZoom', 0.85)
		else
			setProperty('defaultCamZoom', 1.05)
		end
	end,
	
	StepHit = function()
		triggerEvent('screen shake', '0, 0', '0.2, 0.003')
	end,
	
	P1NoteHit = function(noteType)
		if noteType == "Sword" then
			playSound("rbxassetid://13522063537")
		end
	end,
	
	BeatHit = function(curBeat)
		if curBeat > 63 then
			if curBeat % 2 == 0 then
				angleshit = anglevar;
			else
				angleshit = -anglevar;
			end

			GameUI.Rotation = (angleshit*3)
			local UITween = TS:Create(GameUI, TweenInfo.new(Conductor.stepCrochet*0.002, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {Rotation = (angleshit)})
			local UIShake = TS:Create(GameUI, TweenInfo.new(Conductor.crochet*0.001), {Position = UDim2.new(0.5, -angleshit*8, 0.5, 0)})

			addTween(UITween)
			addTween(UIShake)
			--setProperty('camHUD.angle',angleshit*3)
			--setProperty('camGame.angle',angleshit*3)
			--doTweenAngle('turn', 'camHUD', angleshit, stepCrochet*0.002, 'circOut')
			--doTweenX('tuin', 'camHUD', -angleshit*8, crochet*0.001, 'linear')
			--doTweenAngle('tt', 'camGame', angleshit, stepCrochet*0.002, 'circOut')
			--doTweenX('ttrn', 'camGame', -angleshit*8, crochet*0.001, 'linear')
		end
	end,
	
	P2NoteHit = function()
		local luckyRoll = math.random(1, 50)
		local luckyRoll2 = math.random(1, 50)
		
		if mustHitSection == false then
			if gameHandler.PlayerStats.Health > 0.5 then
				gameHandler.PlayerStats.Health -= 0.03
			end
			
			if (luckyRoll2 >= 48) then
				triggerEvent('Screen Shake', 0.05, 0.08)
			end
			
			if (luckyRoll >= 48) then
				triggerEvent('Screen Shake', '0, 0', '0.05, 0.08')
			end
		end
	end,
	
	Update = function()
			-- this might be a huge cause of lag
			if followchars == true then
			local dadAnim = tostring(dad:GetCurrentSingAnim())
			local bfAnim = tostring(bf:GetCurrentSingAnim())
			if mustHitSection == false then
				if dad:IsSinging() == false then
					triggerEvent('camera follow pos',xx,yy)
					return
				end
				if dadAnim == 'singLEFT' then
					triggerEvent('camera follow pos',xx-ofs,yy)
				end
				if dadAnim == 'singRIGHT' then
					triggerEvent('camera follow pos',xx+ofs,yy)
				end
				if dadAnim == 'singUP' then
					triggerEvent('camera follow pos',xx,yy-ofs)
				end
				if dadAnim == 'singDOWN' then
					triggerEvent('camera follow pos',xx,yy+ofs)
				end
			else
				if bf:IsSinging() == false then
					triggerEvent('camera follow pos',xx2,yy2)
					return
				end
				if bfAnim == 'singLEFT' then
					triggerEvent('camera follow pos',xx2-ofs,yy2)
				end
				if bfAnim == 'singRIGHT' then
					triggerEvent('camera follow pos',xx2+ofs,yy2)
				end
				if bfAnim == 'singUP' then
					triggerEvent('camera follow pos',xx2,yy2-ofs)
				end
				if bfAnim == 'singDOWN' then
					triggerEvent('camera follow pos',xx2,yy2+ofs)
				end
			end
		end
	end,
	
	cleanUp = function()
		-- Set Note Rotation to 0 (default)
		GameUI.Rotation = 0

		-- Cancel Tweens
		for i = 1, #tweens do
			if tweens[i] ~= nil then
				tweens[i]:Cancel()
			end
		end

		-- Undefine Variables
		colors = {};
		tweens = {};
		angleshit = nil;
		anglevar = nil;
		mustHitSection = nil;
		triggerEvent = nil;
		setProperty = nil;
		GameUI = nil;
		xx = nil; -- dad x offset
		yy = nil; -- dad y offset
		xx2 = nil; -- bf x offset
		yy2 = nil; -- bf y offset
		ofs = nil;
		followchars = nil;
		dad = nil;
		bf = nil;

		-- Undefine Function
		addTween = nil
	end,
	
	--[[EventTrigger = function(name, v1, v2)
		if name == "blammed lights" then
			print("blammed", v1)
			local thing = workspace.Blammed.SurfaceGui.Frame
			local lightId = tonumber(v1)
			if lightId > 0 then
				TS:Create(thing, TweenInfo.new(1), {BackgroundTransparency = 0.45}):Play()
				TS:Create(thing, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromHex(colors[lightId])}):Play()
			else
				TS:Create(thing, TweenInfo.new(0.0001), {BackgroundTransparency = 1}):Play()
			end
		end
	end,]]
}