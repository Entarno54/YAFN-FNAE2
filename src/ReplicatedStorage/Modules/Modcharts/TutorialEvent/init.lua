--!nolint UnknownGlobal
--!nolint UninitializedLocal
local Conductor = require(game.ReplicatedStorage.Modules.Conductor)
local timer = 0;
local xx = 0; -- dad x offset
local yy = 0; -- dad y offset
local xx2 = 0; -- bf x offset
local yy2 = -300; -- bf y offset
local ofs = 150; -- offset on anim play
local followchars = true;
local start = false
local mustHitSection

return {
	preStart = function()
		--local whiteSky = game.Lighting.SkyPrefigs:FindFirstChild('WhiteSky')
		--whiteSky.Parent = game.Lighting;
	end,
	Start = function()
		start = true
		followchars = true
	end,
	cleanUp = function()
		start = false
		--local whiteSky = game.Lighting:FindFirstChild('WhiteSky')
		--whiteSky.Parent = game.Lighting.SkyPrefigs
	end,
	sectionChange = function(section)
		mustHitSection = section.mustHitSection
	end,
	BeatHit = function()
		gameHandler.processEvent("add camera zoom", 0.015, 0) -- camZoom, hudZoom
	end,
	Update = function()
		if start then
			if followchars == true then
				local dadAnim = tostring(dad:GetCurrentSingAnim())
				local bfAnim = tostring(bf:GetCurrentSingAnim())
				if mustHitSection == false then
					if dadAnim == 'singLEFT' then
						gameHandler.processEvent('camera follow pos',xx-ofs,yy)
					end
					if dadAnim == 'singRIGHT' then
						gameHandler.processEvent('camera follow pos',xx+ofs,yy)
					end
					if dadAnim == 'singUP' then
						gameHandler.processEvent('camera follow pos',xx,yy-ofs)
					end
					if dadAnim == 'singDOWN' then
						gameHandler.processEvent('camera follow pos',xx,yy+ofs)
					end
					if bf:IsSinging() == false then
						gameHandler.processEvent('camera follow pos',xx,yy)
					end
				else
					if bfAnim == 'singLEFT' then
						gameHandler.processEvent('camera follow pos',xx2-ofs,yy2)
					end
					if bfAnim == 'singRIGHT' then
						gameHandler.processEvent('camera follow pos',xx2+ofs,yy2)
					end
					if bfAnim == 'singUP' then
						gameHandler.processEvent('camera follow pos',xx2,yy2-ofs)
					end
					if bfAnim == 'singDOWN' then
						gameHandler.processEvent('camera follow pos',xx2,yy2+ofs)
					end
					if bf:IsSinging() == false then
						gameHandler.processEvent('camera follow pos',xx2,yy2)
					end
				end
			else
				gameHandler.processEvent('camera follow pos','','')
			end
		end
	end,
}