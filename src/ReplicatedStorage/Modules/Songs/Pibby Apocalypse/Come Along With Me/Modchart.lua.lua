--!nolint UnknownGlobal
--!nolint UninitializedLocal
local Conductor = require(game.ReplicatedStorage.Modules.Conductor)
local sprite = require(game.ReplicatedStorage.Modules.Sprite)
local filter = nil
local warning = nil
local curSection = nil
local sky
local dodge = nil
local dodgeButtons = nil
local followchars = nil
local shake = false
local xx = 0; -- dad x offset
local yy = 0; -- dad y offset
local xx2 = 0; -- bf x offset
local yy2 = -300; -- bf y offset
local ofs = 150; -- offset on anim play
local start = false
local TS = game:GetService("TweenService")

-- Make blank variables
local colors = {};

local angleshit = nil;
local anglevar = nil;
--local timer = 0;

local buttonCheck = nil
local addTween = nil
local tweens = nil

return {
	Start = function()
		start = true
		
	end,
	EventTrigger = function(name, value1, value2)
		if name == "changemapone" then
			shake = true
			local bf = playerObjects.BF
			local dad = playerObjects.Dad
			bf.Obj.PrimaryPart = bf.Obj.HumanoidRootPart
			dad.Obj.PrimaryPart = dad.Obj.HumanoidRootPart
			print(playerObjects)
			-- Also move BF and Dad into their proper positions
			local newDadPos = mapProps:FindFirstChild("dadPos").CFrame
			local newBFPos = mapProps:FindFirstChild("bfPos").CFrame

			gameHandler.PositioningParts.Right.CFrame = newDadPos
			gameHandler.PositioningParts.Left.CFrame = newBFPos
			mapProps.Floor.Transparency = 1

			-- Destroy these parts to fix potential anim clipping
			--mapProps.dadPos:Destroy()
			--mapProps.bfPos:Destroy()
			print(playerObjects.BF.Obj)
			playerObjects.BF.Obj:PivotTo(newBFPos)
			playerObjects.Dad.Obj:PivotTo(newDadPos)
			--if value1 == "txt" then
			--	print("changed text to".. value2)
			--	game.Players.LocalPlayer.PlayerGui.SillyBillyUI.TxtFrame.TextLabel.Text = value2
			--elseif value1 == "break mirror" then
			--	print(mapProps)
			--	mapProps.Glass.Decal.Transparency = 0
			--end
			for _, g in mapProps.Mountain:GetDescendants() do
				if g:IsA("BasePart") or g:IsA("Decal") and not g:FindFirstChildWhichIsA("Decal") then
					g.Transparency = 0
				elseif g:IsA("ParticleEmitter") then
					g.Enabled = true
				end
			end
			for _, g in mapProps.Ground:GetDescendants() do
				if g:IsA("BasePart") then
					g.Transparency = 1
				elseif g:IsA("ParticleEmitter") then
					g.Enabled = false
				end
			end
			for _, g in mapProps.Phaseonethings:GetDescendants() do 
				if g:IsA("BasePart") or g:IsA("Decal") then 
					g.Transparency = 1 
				elseif g:IsA("RopeConstraint") then 
					g.Visible = false 
				end 
			end
			sky:Destroy()
			sky = game.Lighting.SkyPrefigs.GraySky:Clone()
			sky.Parent = game.Lighting

			-- Destroy these parts to fix potential anim clipping
			--mapProps.dadPos:Destroy()
			--mapProps.bfPos:Destroy()

			bf.Obj:PivotTo(newBFPos)
			dad.Obj:PivotTo(newDadPos)
		elseif name == "changemaptwo" then
			shake = false
			local bf = playerObjects.BF
			local dad = playerObjects.Dad
			bf.Obj.PrimaryPart = bf.Obj.HumanoidRootPart
			dad.Obj.PrimaryPart = dad.Obj.HumanoidRootPart

			-- Also move BF and Dad into their proper positions
			local newDadPos = mapProps:FindFirstChild("dadPos").CFrame
			local newBFPos = mapProps:FindFirstChild("bfPos").CFrame

			gameHandler.PositioningParts.Right.CFrame = newDadPos
			gameHandler.PositioningParts.Left.CFrame = newBFPos
			mapProps.Floor.Transparency = 1

			-- Destroy these parts to fix potential anim clipping
			--mapProps.dadPos:Destroy()
			--mapProps.bfPos:Destroy()

			bf.Obj:PivotTo(newBFPos)
			dad.Obj:PivotTo(newDadPos)
			--if value1 == "txt" then
			--	print("changed text to".. value2)
			--	game.Players.LocalPlayer.PlayerGui.SillyBillyUI.TxtFrame.TextLabel.Text = value2
			--elseif value1 == "break mirror" then
			--	print(mapProps)
			--	mapProps.Glass.Decal.Transparency = 0
			--end
			for _, g in mapProps.Mountain:GetDescendants() do
				if g:IsA("BasePart") or g:IsA("Decal") then
					g.Transparency = 1
				elseif g:IsA("ParticleEmitter") then
					g.Enabled = false
				end
			end
			for _, g in mapProps.Ground:GetDescendants() do
				if g:IsA("BasePart") then
					g.Transparency = 1
				elseif g:IsA("ParticleEmitter") then
					g.Enabled = false
				end
			end
			for _, g in mapProps.Phaseonethings:GetDescendants() do 
				if g:IsA("BasePart") or g:IsA("Decal") then 
					g.Transparency = 0 
				elseif g:IsA("RopeConstraint") then 
					g.Visible = true 
				end 
			end
			sky:Destroy()
			sky = game.Lighting.SkyPrefigs.WhiteSky:Clone()
			sky.Parent = game.Lighting
			
		elseif name == "changemapthree" then
			for _, g in mapProps.Phaseonethings:GetDescendants() do 
				if g:IsA("BasePart") or g:IsA("Decal") then 
					g.Transparency = 1 
				elseif g:IsA("RopeConstraint") then 
					g.Visible = false 
				end 
			end
			shake = true
			local bf = playerObjects.BF
			local dad = playerObjects.Dad
			
			local newDadPos = mapProps:FindFirstChild("dadPos3").CFrame
			local newBFPos = mapProps:FindFirstChild("bfPos3").CFrame

			bf.Obj:PivotTo(newBFPos)
			dad.Obj:PivotTo(newDadPos)
			print(playerObjects.BF)
			print("GG")

			gameHandler.PositioningParts.Right.CFrame = newDadPos
			gameHandler.PositioningParts.Left.CFrame = newBFPos

			bf.Obj:PivotTo(newBFPos)
			dad.Obj:PivotTo(newDadPos)
			print("GG")

			-- Destroy these parts to fix potential anim clipping
			--mapProps.dadPos3:Destroy()
			--mapProps.bfPos3:Destroy()
			for _, g in mapProps.Mountain:GetDescendants() do
				if g:IsA("BasePart") or g:IsA("Decal") then
					g.Transparency = 1
				elseif g:IsA("ParticleEmitter") then
					g.Enabled = false
				end
			end
			for _, g: Instance in mapProps.Ground:GetDescendants() do
				if g:IsA("BasePart") or g:IsA("UnionOperation") or g:IsA("MeshPart") then
					g.Transparency = 0
				elseif g:IsA("ParticleEmitter") then
					g.Enabled = true
				end
			end
			for _, g in mapProps.Phaseonethings:GetDescendants() do 
				if g:IsA("BasePart") or g:IsA("Decal") then 
					g.Transparency = 1 
				elseif g:IsA("RopeConstraint") then 
					g.Visible = false 
				end 
			end
		elseif name == "evilthingtwo" then
			local bf = playerObjects.BF
			local dad = playerObjects.Dad
			--mapProps.BG.Decal.Transparency = 1

			-- Also move BF and Dad into their proper positions
			local newDadPos = mapProps:FindFirstChild("dadPos2").CFrame
			local newBFPos = mapProps:FindFirstChild("bfPos2").CFrame
			
			bf.Obj:PivotTo(newBFPos)
			dad.Obj:PivotTo(newDadPos)

			gameHandler.PositioningParts.Right.CFrame = newDadPos
			gameHandler.PositioningParts.Left.CFrame = newBFPos

			bf.Obj:PivotTo(newBFPos)
			dad.Obj:PivotTo(newDadPos)

			-- Destroy these parts to fix potential anim clipping
			--mapProps.dadPos2:Destroy()
			--mapProps.bfPos2:Destroy()
			
			for _, g in mapProps.Mountain:GetDescendants() do
				if g:IsA("BasePart") or g:IsA("Decal") then
					g.Transparency = 1
				elseif g:IsA("ParticleEmitter") then
					g.Enabled = false
				end
			end
			for _, g in mapProps.Ground:GetDescendants() do
				if g:IsA("BasePart") then
					g.Transparency = 1
				elseif g:IsA("ParticleEmitter") then
					g.Enabled = false
				end
			end
			for _, g in mapProps.Phaseonethings:GetDescendants() do 
				if g:IsA("BasePart") or g:IsA("Decal") then 
					g.Transparency = 1 
				elseif g:IsA("RopeConstraint") then 
					g.Visible = false 
				end 
			end
			sky:Destroy()
			sky = game.Lighting.SkyPrefigs.BlackSky:Clone()
			sky.Parent = game.Lighting
		end
	end,
	cleanUp = function()
		if sky then
			sky:Destroy()
		end
		--game.Players.LocalPlayer.PlayerGui:FindFirstChild("SillyBillyUI"):Destroy()
	end,
	preStart = function()
		-- Define Variables
		sky = game.Lighting.SkyPrefigs.WhiteSky:Clone()
		sky.Parent = game.Lighting
		--colors = {'#31a2fd', '#31fd8c', '#f794f7', '#f96d63', '#fba633'};
		--angleshit = 0;
		--anglevar = 0;
		--mustHitSection = true
		--triggerEvent = gameHandler.processEvent
		--setProperty = gameHandler.setProperty
		--GameUI = gameUI.realGameUI.Notes

		--tweens = {};

		--xx = 40;
		--yy = 5;
		--xx2 = -40;
		--yy2 = -5;
		--ofs = 90;
		--followchars = false;

		---- Define Function
		--addTween = function(tween)
		--	tween:Play()
		--	table.insert(tweens, tween)

		--	tween.Completed:Connect(function()
		--		table.remove(tweens, table.find(tweens, tween))
		--	end)
		--end
	end,
	--BeatHit = function(curBeat)
	--		if shake then
	--			if curBeat % 2 == 0 then
	--				angleshit = anglevar;
	--			else
	--				angleshit = -anglevar;
	--			end

	--			GameUI.Rotation = (angleshit*3)
	--			local UITween = TS:Create(GameUI, TweenInfo.new(Conductor.stepCrochet*0.002, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {Rotation = (angleshit)})
	--			local UIShake = TS:Create(GameUI, TweenInfo.new(Conductor.crochet*0.001), {Position = UDim2.new(0.5, -angleshit*8, 0.5, 0)})

	--			addTween(UITween)
	--			addTween(UIShake)
	--		end
	--end,
	--P1NoteHit = function(g, y, zz)
	--	print(y)
	--	if start then
	--		if followchars and not mustHitSection then
	--			if y == 0 then
	--				gameHandler.processEvent('camera follow pos',xx-ofs,yy)
	--			elseif y == 3 then
	--				gameHandler.processEvent('camera follow pos',xx+ofs,yy)
	--			elseif y == 2 then
	--				gameHandler.processEvent('camera follow pos',xx,yy-ofs)
	--			elseif y == 1 then
	--				gameHandler.processEvent('camera follow pos',xx,yy+ofs)
	--			end
	--		else
	--			gameHandler.processEvent('camera follow pos','','')
	--		end
	--	end
	--end,
	--P2NoteHit = function(g, y, zz)
	--	print(y)
	--	if start then
	--		if followchars and mustHitSection then
	--			if y == 0 then
	--				gameHandler.processEvent('camera follow pos',xx2-ofs,yy2)
	--			elseif y == 3 then
	--				gameHandler.processEvent('camera follow pos',xx2+ofs,yy2)
	--			elseif y == 2 then
	--				gameHandler.processEvent('camera follow pos',xx2,yy2-ofs)
	--			elseif y == 1 then
	--				gameHandler.processEvent('camera follow pos',xx2,yy2+ofs)
	--			end
	--		else
	--			gameHandler.processEvent('camera follow pos','','')
	--		end
	--	end
	--end
}