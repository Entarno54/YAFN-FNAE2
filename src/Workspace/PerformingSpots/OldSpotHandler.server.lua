local PS
if script:IsAncestorOf(workspace) then
	PS = script.Parent
else
	PS = workspace:WaitForChild("PerformingSpots")
end
local NameCache = {}
local Event = PS.Event
local BindFunc = PS.Function
local RS = game:GetService("RunService")
local RepS = game:GetService("ReplicatedStorage")
local HS = game:GetService("HttpService")
local songIds = require(RepS.SongIDs)
local PP = Instance.new("ProximityPrompt")
local plrs = game:GetService("Players")
PP.ActionText = "Join"
PP.ObjectText = "%s (%s)"
PP.RequiresLineOfSight = false
PP.HoldDuration = 0.5
PP.KeyboardKeyCode = Enum.KeyCode.E
PP.Name = "Prompt"
PP.MaxActivationDistance = 10
local SpotSounds = {}
local Spots = {}
local SpotStuff = {}
local scoreutils = require(game.ReplicatedStorage.Modules.ScoreUtils)

for _,Spot in pairs(PS:GetChildren()) do
	if not Spot:IsA("Model") then continue end
	local BF,CO,Dad,ARO = Spot:FindFirstChild("Boyfriend"), Spot:FindFirstChild("CameraOrigin"),
		Spot:FindFirstChild("Dad"),Spot:FindFirstChild("AccuracyRateOrigin")
	-- optional stuff
	local GF = Spot:FindFirstChild("Girlfriend")
	local statsModel = Spot:FindFirstChildOfClass("Model")
	local SpotUIStats, SpotUIDad, SpotUIBF, StatsGUI, PlayerIconGUI
	local SpotRoundStats = {
		DadScore = 0;
		BFScore = 0;
	}
	if statsModel then
		SpotUIStats = statsModel:FindFirstChild("Stats")
		SpotUIDad = statsModel:FindFirstChild("DadScreen")
		SpotUIBF = statsModel:FindFirstChild("BFScreen")
		-- i'm not bothering to add a failsafe rn
		StatsGUI = {
			PlayerVS = SpotUIStats.GUI:FindFirstChild("PlayerVs");
			Score = SpotUIStats.GUI:FindFirstChild("Score");
			SongName = SpotUIStats.GUI:FindFirstChild("SongName");
		}
		PlayerIconGUI = {
			Dad = SpotUIDad.GUI:FindFirstChild("ImageLabel");
			BF = SpotUIBF.GUI:FindFirstChild("ImageLabel")
		}
	end
	
	
	if not (BF and CO and Dad and ARO) then
		warn(("Spot doesn't met the requirements! (%s)"):format(Spot:GetFullName()))
		continue
	end
	
	local isStatsAvailable = statsModel ~= nil
	local DadProxProm = PP:Clone()
	DadProxProm.ObjectText = DadProxProm.ObjectText:format("Player 2","Left") -- me
	DadProxProm.Style = Enum.ProximityPromptStyle.Default
	DadProxProm.RequiresLineOfSight = false
	DadProxProm.Parent = Dad
	local BFProxProm = PP:Clone()
	BFProxProm.ObjectText = BFProxProm.ObjectText:format("Player 1","Right")
	BFProxProm.Style = Enum.ProximityPromptStyle.Default
	BFProxProm.RequiresLineOfSight = false
	BFProxProm.Parent = BF
	local GFProxProm
	if GF then
		GFProxProm = PP:Clone()
		GFProxProm.ActionText = "Sit"
		GFProxProm.ObjectText = "Boombox Seat"
		GFProxProm.Style = Enum.ProximityPromptStyle.Default
		GFProxProm.RequiresLineOfSight = false
		GFProxProm.MaxActivationDistance = 7
		GFProxProm.Parent = GF
	end
	
	
	
	if not game:GetService("RunService"):IsStudio() then
		BF.Transparency = 1
		Dad.Transparency = 1
		CO.Transparency = 1
		ARO.Transparency = 1
		
		if GF then
			GF.Transparency = 1
		end
	end
	local SpotEvent = Instance.new("BindableEvent")
	local SpotBindFunc = Instance.new("BindableFunction")
	local SpotSound = Instance.new("Sound")
	local SpotVocals = Instance.new("Sound")
	SpotEvent.Name = "Event"
	SpotBindFunc.Name = "Function"
	SpotEvent.Parent = Spot
	SpotBindFunc.Parent = Spot
	SpotSound.Name = "RoundSong"
	SpotSound.Volume = 1
	SpotSound.RollOffMaxDistance = 30
	SpotSound.RollOffMinDistance = 12
	SpotSound.RollOffMode = Enum.RollOffMode.Inverse
	SpotSound.Parent = ARO
	SpotSound:SetAttribute("BPM",0);
	
	SpotVocals.Name = "RoundVocals"
	SpotVocals.Volume = 1
	SpotVocals.RollOffMaxDistance = 30
	SpotVocals.RollOffMinDistance = 12
	SpotVocals.RollOffMode = Enum.RollOffMode.Inverse
	SpotVocals.Parent = ARO
	SpotSounds[#SpotSounds+1] = SpotSound
	SpotSounds[#SpotSounds+1] = SpotVocals
	-- set up the events
	
	local Ownership
	local DadOwner
	local BFOwner
	local DadCon
	local BFCon
	local compRemote
	local compFunction
	local isPlaying
	
	local SpotDat = {
		KickOff=function()
			pcall(function()DadCon:KickOff()end)
			pcall(function()BFCon:KickOff()end)
			pcall(function()DadCon:Failsafe()end)
			pcall(function()BFCon:Failsafe()end)
			DadOwner=nil;
			BFOwner=nil;
			Ownership=nil;
		end;
		Update=function(self)
			self.Ownership=Ownership;
			self.BFOwner=BFOwner
			self.DadOwner=DadOwner
		end;
	}
	
	SpotSound.Stopped:connect(function()
		SpotSound:SetAttribute("BPM",0)
	end)

	local GFOwner
	if GF then
		local GFAnimTrack
		local GFCon
		SpotSound:GetAttributeChangedSignal("BPM"):connect(function()
			if(GFAnimTrack)then
				local speed = SpotSound:GetAttribute("BPM")==0 and 1 or GFAnimTrack.Length/(60/SpotSound:GetAttribute("BPM"))/2
				GFAnimTrack:AdjustSpeed(speed~=math.huge and speed or 1);
			end
		end)
		GFProxProm.Triggered:Connect(function(plr)
			local HRP = plr.Character:FindFirstChild("HumanoidRootPart")
			local hum = plr.Character:FindFirstChildOfClass("Humanoid")
			local AnimController = hum:FindFirstChildOfClass("Animator")
			local AnimScript = plr.Character:FindFirstChild("Animate")
			if (not HRP) or (GFOwner ~= plr and GFOwner ~= nil) then return end
			if plr == DadOwner or plr == BFOwner then return end

			if GFOwner == plr then
				GFOwner = nil
				HRP.Anchored = false
				hum.Sit = false
				GFAnimTrack:Stop()
				GFAnimTrack = nil
				GFProxProm.ActionText = "Vibe"

				if AnimScript then AnimScript.Disabled = false end
				if GFCon then GFCon:Disconnect() end
				return
			end
			HRP.CFrame = GF.CFrame * CFrame.new(0,1.5,0)
			HRP.Anchored = true
			GFProxProm.ActionText = "Stop"
			if AnimScript then AnimScript.Disabled = true end
			GFAnimTrack = AnimController:LoadAnimation(RepS.Animations.GF)
			GFAnimTrack.Priority = Enum.AnimationPriority.Action
			GFAnimTrack.Looped = true
			local speed = SpotSound:GetAttribute("BPM")==0 and 1 or GFAnimTrack.Length/(60/SpotSound:GetAttribute("BPM"))/2
			GFAnimTrack:AdjustSpeed(speed~=math.huge and speed or 1);
			GFOwner = plr
			GFCon = plr.CharacterRemoving:Connect(function()
				GFCon:Disconnect()
				GFOwner = nil
				DadProxProm.MaxActivationDistance = 10
				DadProxProm.ActionText = "Vibe"
				print("GF character removed")
			end)
			GFAnimTrack:Play()
		end)
	end
	
	-- Dad Spot
	
	DadPPEventFunc = function(plr)
		SpotEvent:Fire("DadTrigger",plr)
	end
	
	-- BF Spot
	
	BFPPEventFunc = function(plr)
		SpotEvent:Fire("BFTrigger",plr)
	end
	
	table.insert(SpotStuff,SpotDat)
	
	DadProxProm.Triggered:Connect(DadPPEventFunc)
	BFProxProm.Triggered:Connect(BFPPEventFunc)
	
	SpotEvent.Event:Connect(function(actionType,...)
		print(actionType,...)
		
		if actionType == "AbruptEnd" then
			if DadOwner then
				Event:Fire("SpotLeave",Spot,Dad,DadOwner)
				if DadOwner.Character then
					local HRP = DadOwner.Character:FindFirstChild("HumanoidRootPart")
					if HRP then HRP.Anchored = false end
				end
			end
			if BFOwner then
				Event:Fire("SpotLeave",Spot,BF,BFOwner)
				if BFOwner.Character then
					local HRP = BFOwner.Character:FindFirstChild("HumanoidRootPart")
					if HRP then HRP.Anchored = false end
				end
			end
			BFProxProm.ActionText = "Join"
			DadProxProm.ActionText = "Join"
			BFProxProm.Enabled = true
			DadProxProm.Enabled = true
			DadOwner = nil
			BFOwner = nil
			Ownership = nil
			isPlaying = false
			if DadCon then DadCon:Disconnect() end
			if BFCon then BFCon:Disconnect() end
			if compRemote then compRemote:Destroy() end
			if compFunction then compFunction:Destroy() end
			SpotSound:Stop()
			SpotVocals:Stop()
			warn("Something went wrong!")
		elseif actionType == "BFTrigger" then -- BF SPOT TRIGGER
			local plr = ...
			local HRP = plr.Character:FindFirstChild("HumanoidRootPart")
			local Humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
			if (BFOwner ~= nil and BFOwner ~= plr) then
				return
			end
			if (not Humanoid) or not HRP then
				return
			end
			if Humanoid.Sit then return end
			if GF and GFOwner == plr then return end
			if DadOwner == plr then return end

			if BFOwner == plr then -- Leave functionality

				Event:Fire("SpotLeave",Spot,BF,plr)
				SpotSound:Stop()
				SpotVocals:Stop()
				HRP.Anchored = false
				BFOwner = nil
				BFProxProm.MaxActivationDistance = 10
				BFProxProm.ActionText = "Join"
				BFProxProm.Enabled = true
				if BFCon then BFCon:Disconnect() end

				if Ownership == BFOwner then
					Ownership = nil
					if DadOwner then
						DadOwner = nil	
						DadProxProm.MaxActivationDistance = 10
						DadProxProm.ActionText = "Join"
						DadProxProm.Enabled = true
						Event:Fire("SpotLeave",Spot,Dad,DadOwner)
						if DadOwner.Character then
							local dadHRP = DadOwner.Character:FindFirstChild("HumanoidRootPart")
							dadHRP.Anchored = false
						end
					end
				end

				if isPlaying then
					isPlaying = false
					DadProxProm.MaxActivationDistance = 10
					DadProxProm.ActionText = "Join"
					DadProxProm.Enabled = true
				end

				return
			end

			-- Join Functionality

			HRP.Anchored = true
			HRP.CFrame = BF.CFrame
			BFOwner = plr
			BFProxProm.ActionText = "Leave" 
			BFProxProm.MaxActivationDistance = 10
			BFProxProm.Enabled = false--Comment this if something goes wrong.

			if Ownership == nil then
				Ownership = plr
			end
			Event:Fire("SpotJoin",Spot,BF,plr,Ownership == plr)

			-- set up the failsafe events

			local failsafeFunc = function()
				BFCon:Disconnect()
				if Ownership == BFOwner then
					Ownership = nil
					SpotEvent:Fire("AbruptEnd")
					return
				end
				Event:Fire("SpotLeave",Spot,BF,BFOwner)
				if DadOwner and DadOwner.Character then 
					Event:Fire("SpotLeave",Spot,Dad,DadOwner)
					DadOwner = nil
					DadOwner.Character.HumanoidRootPart.Anchored = false
				end
				if compRemote then compRemote:Destroy() end
				if compFunction then compFunction:Destroy() end
				SpotSound:Stop()
				SpotVocals:Stop()
				BFOwner = nil

				BFProxProm.MaxActivationDistance = 10
				BFProxProm.ActionText = "Join"
				BFProxProm.Enabled = true
				print("BF character removed")
			end
			BFCon = {plr.CharacterRemoving:Connect(failsafeFunc);plrs.PlayerRemoving:Connect(function(plrLeave)
				if BFOwner ~= plrLeave then return end
				failsafeFunc()
			end);
			}
			function BFCon:KickOff()
				if(BFOwner)then
					BFPPEventFunc(BFOwner)
				end
			end
			function BFCon:Failsafe()
				failsafeFunc()
			end
			function BFCon:Disconnect()
				self[1]:Disconnect()
				self[2]:Disconnect()
			end
		elseif actionType == "DadTrigger" then -- DAD SPOT TRIGGER
			local plr = ...
			local HRP = plr.Character:FindFirstChild("HumanoidRootPart")
			local Humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
			if (DadOwner ~= nil and DadOwner ~= plr) then
				return
			end
			if (not Humanoid) or not HRP then
				return
			end
			if Humanoid.Sit then return end
			if GF and GFOwner == plr then return end
			if BFOwner == plr then return end

			if DadOwner == plr then -- Leave functionality

				Event:Fire("SpotLeave",Spot,Dad,plr)
				SpotSound:Stop()
				SpotVocals:Stop()
				HRP.Anchored = false
				DadOwner = nil
				DadProxProm.MaxActivationDistance = 10
				DadProxProm.ActionText = "Join"
				DadProxProm.Enabled = true
				if DadCon then DadCon:Disconnect() end

				if Ownership == DadOwner then
					Ownership = nil
					if BFOwner then -- kick the other player if the Owner leaves.
						BFOwner = nil
						BFProxProm.MaxActivationDistance = 10
						BFProxProm.ActionText = "Join"
						BFProxProm.Enabled = true
						Event:Fire("SpotLeave",Spot,BF,BFOwner)
						if BFOwner.Character then
							local bfHRP = BFOwner.Character:FindFirstChild("HumanoidRootPart")
							bfHRP.Anchored = false
						end
					end
				end

				if isPlaying then
					isPlaying = false
					BFProxProm.MaxActivationDistance = 10
					BFProxProm.ActionText = "Join"
					BFProxProm.Enabled = true
				end

				return
			end

			-- Join Functionality

			HRP.Anchored = true
			HRP.CFrame = Dad.CFrame
			DadOwner = plr
			DadProxProm.ActionText = "Leave" 
			DadProxProm.MaxActivationDistance = 10
			DadProxProm.Enabled = false -- Comment this if something goes wrong.

			if Ownership == nil then
				Ownership = plr
			end
			Event:Fire("SpotJoin",Spot,Dad,plr,Ownership == plr)

			-- set up the failsafe events

			local failsafeFunc = function()
				DadCon:Disconnect()
				if Ownership == DadOwner then
					Ownership = nil
					SpotEvent:Fire("AbruptEnd")
					return
				end
				Event:Fire("SpotLeave",Spot,Dad,DadOwner)
				if BFOwner and BFOwner.Character then 
					Event:Fire("SpotLeave",Spot,BF,BFOwner)
					BFOwner = nil
					BFOwner.Character.HumanoidRootPart.Anchored = false
				end
				if compRemote then compRemote:Destroy() end
				if compFunction then compFunction:Destroy() end
				if Ownership == DadOwner then
					Ownership = nil
				end
				SpotSound:Stop()
				SpotVocals:Stop()
				DadOwner = nil
				DadProxProm.MaxActivationDistance = 10
				DadProxProm.ActionText = "Join"
				DadProxProm.Enabled = true

				BFProxProm.MaxActivationDistance = 10
				BFProxProm.ActionText = "Join"
				BFProxProm.Enabled = true
				print("Dad character removed")
			end
			DadCon = {plr.CharacterRemoving:Connect(failsafeFunc);plrs.PlayerRemoving:Connect(function(plrLeave)
				if DadOwner ~= plrLeave then return end
				failsafeFunc()
			end);
			}
			function DadCon:KickOff()
				if(DadOwner)then
					DadPPEventFunc(DadOwner)
				end
			end
			function DadCon:Failsafe()
				failsafeFunc()
			end
			function DadCon:Disconnect()
				self[1]:Disconnect()
				self[2]:Disconnect()
			end
		end
	end)
	
	SpotBindFunc.OnInvoke = function(msgType,...)
		print("SpotBindFunc | ", msgType, ...)
		
		if msgType == "GetPlayersFromSpot" then
			local theSpot = ...
			if theSpot == Spot then
				return BFOwner, DadOwner
			end
			wait(2)
		elseif msgType == "GetSpotOwnership" then
			return Ownership
		elseif msgType == "InitializeCompRemote" then -- Starts the current spot gameplay.
			local msgSpot,whoStart,songModule,songDisplay = ...
			--print(...)
			if NameCache[songModule:GetFullName()] then
				songDisplay = NameCache[songModule:GetFullName()]
			else
				local ModuleData = HS:JSONDecode(require(songModule))
				if not ModuleData.song.song then
					songDisplay = songModule.Name
					NameCache[songModule:GetFullName()] = songModule.Name
				else
					songDisplay = ModuleData.song.song
					NameCache[songModule:GetFullName()] = ModuleData.song.song
				end
			end
			if msgSpot ~= Spot or whoStart ~= Ownership then -- verify if it's the player who sent the signal
				print("fail")
				return
			end
			isPlaying = true
			
			if isStatsAvailable then
				StatsGUI.SongName.Text = songDisplay or (songModule.Name .. "_FAILSAFE")
				StatsGUI.PlayerVS.Text = ("%s VS %s"):format(DadOwner and DadOwner.Name or "None",BFOwner and BFOwner.Name or "None")
				StatsGUI.Score.Text = "000000000 | 000000000"
				PlayerIconGUI.BF.Image = BFOwner and plrs:GetUserThumbnailAsync(BFOwner.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150) or "rbxassetid://53252054"
				PlayerIconGUI.Dad.Image = DadOwner and plrs:GetUserThumbnailAsync(DadOwner.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150) or "rbxassetid://53252054" 
				SpotRoundStats.BFScore = 0
				SpotRoundStats.DadScore = 0
			end
			
			
			local IsSolo 
			if (DadOwner or BFOwner) and not (DadOwner and BFOwner) then
				IsSolo = true
			end
			SpotSound:Stop()
			SpotVocals:Stop()
			BFProxProm.Enabled = false
			DadProxProm.Enabled = false
			if compRemote then compRemote:Destroy() end
			if compFunction then compFunction:Destroy() end
			compRemote = Instance.new("RemoteEvent")
			compRemote.Name = "GameRoundRemote"
			compRemote.Parent = Spot
			compFunction = Instance.new("RemoteFunction")
			compFunction.Name = "InfoRetriever"
			compFunction.Parent = Spot
			
			compFunction.OnServerInvoke = function(plr,infoType)
				if infoType == 0x0 then -- Get Opponent player
					if BFOwner == plr then
						return DadOwner
					elseif DadOwner == plr then
						return BFOwner
					end
					return plr
				elseif infoType == 0x1 then -- return SpotSounds
					return SpotSounds
				end
			end
			
			local thread_Round = function()
				local BFOwnerReady, DadOwnerReady = BFOwner == nil,DadOwner == nil
				local BFOSongReady, DadOSongReady = BFOwner == nil,DadOwner == nil
				local BFSongOver, DadSongOver = BFOwner == nil,DadOwner == nil
				
				compRemote.OnServerEvent:Connect(function(plr,msg,...) -- COMPERTITION REMOTE
					--print("compRemote | ", plr, msg, ...)
					if msg == 0x0 then
						if BFOwner == plr then
							BFOwnerReady = true
						end
						if DadOwner == plr then
							DadOwnerReady = true
						end
					elseif msg == 0x1 then
						if BFOwner == plr then
							BFOSongReady = true
						end
						if DadOwner == plr then
							DadOSongReady = true
						end
					elseif msg == 0x2 then
						if BFOwner == plr then
							BFSongOver = true
						end
						if DadOwner == plr then
							DadSongOver = true
						end
					elseif msg == 0x3 then
						local strum,songPos,isSus,nType,dir = ...
						local diff=nil
						local score = 0
						local baseScore = 0;
						if plr == DadOwner then
							baseScore = SpotRoundStats.DadScore
						elseif plr == BFOwner then
							baseScore = SpotRoundStats.BFScore
						end
						if(songPos==false)then
							score = strum
							strum = 0;
							songPos = 0;
						else
							diff = strum-songPos
							if(not isSus)then
								score = baseScore + scoreutils:GetScore(scoreutils:GetRating(diff)); 
							else
								score=baseScore
							end
						end
						
						-- TODO: VERIFY THE HIT!!

						
						if plr == DadOwner and BFOwner then
							compRemote:FireClient(BFOwner,0x1,strum,diff,nType,dir,isSus)
						end
						if plr == DadOwner then
							SpotRoundStats.DadScore = score
						end
						if plr == BFOwner and DadOwner then
							compRemote:FireClient(DadOwner,0x1,strum,diff,nType,dir,isSus)
						end	
						if plr == BFOwner then
							SpotRoundStats.BFScore = score
						end
						local scLenD = tostring(math.abs(SpotRoundStats.DadScore))
						local scLenB = tostring(math.abs(SpotRoundStats.BFScore))
						local scD 
						local scB
						if SpotRoundStats.DadScore < 0 then
							scD = '<font color="#FF0000">-' .. string.sub("00000000",#scLenD +1) .. scLenD .. "</font>"
						else
							scD = string.sub("000000000",#scLenD +1) .. scLenD
						end
						if SpotRoundStats.BFScore < 0 then
							scB = '<font color="#FF0000">-' .. string.sub("00000000",#scLenB +1) .. scLenB .. "</font>"
						else
							scB = string.sub("000000000",#scLenB +1) .. scLenB
						end
						StatsGUI.Score.Text = ("%s | %s"):format(scD,scB)
						return
							
						
					elseif msg == 0x4 then -- someone has been murdered!
						if DadOwner then
							local HRP = DadOwner.Character:FindFirstChild("HumanoidRootPart")
							if HRP then HRP.Anchored = false end
							Event:Fire("SpotLeave",Spot,Dad,DadOwner)
						end
						if BFOwner then
							local HRP = BFOwner.Character:FindFirstChild("HumanoidRootPart")
							if HRP then HRP.Anchored = false end
							Event:Fire("SpotLeave",Spot,BF,BFOwner)
						end
						BFProxProm.ActionText = "Join"
						DadProxProm.ActionText = "Join"
						BFProxProm.Enabled = true
						DadProxProm.Enabled = true
						DadOwner = nil
						BFOwner = nil
						Ownership = nil
						if DadCon then DadCon:Disconnect() end
						if BFCon then BFCon:Disconnect() end
						
						local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
						local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
						local boom = Instance.new("Explosion")
						boom.DestroyJointRadiusPercent = 0
						boom.Position = hrp.Position
						local death = Instance.new("Sound")
						death.SoundId = "rbxassetid://6878469634"
						death.Volume = 1
						death.Parent = hrp
						death:Play()
						humanoid.Health = -1
						boom.Parent = workspace

						SpotSound:Stop()
						SpotVocals:Stop()
						
						wait(1)
						compRemote:Destroy()
						compFunction:Destroy()
						return
					end
					
					if BFSongOver and DadSongOver then
						print("compRemote Deleted!")
						if DadOwner then
							local HRP = DadOwner.Character:FindFirstChild("HumanoidRootPart")
							if HRP then HRP.Anchored = false end
						end
						if BFOwner then
							local HRP = BFOwner.Character:FindFirstChild("HumanoidRootPart")
							if HRP then HRP.Anchored = false end
						end
						BFProxProm.ActionText = "Join"
						DadProxProm.ActionText = "Join"
						BFProxProm.Enabled = true
						DadProxProm.Enabled = true
						isPlaying = false
						DadOwner = nil
						BFOwner = nil
						Ownership = nil
						if DadCon then DadCon:Disconnect() end
						if BFCon then BFCon:Disconnect() end
						compRemote:Destroy()
						compFunction:Destroy()

						SpotSound:Stop()
						SpotVocals:Stop()
					end
				end)
				local count = 0
				repeat
					count += 1
					print("wait..")
					
					wait(1)
				until (count >= 30) or (BFOwnerReady and DadOwnerReady) or (BFOwner == nil and DadOwner == nil)
				if not (BFOwnerReady and DadOwnerReady) then
					SpotEvent:Fire("AbruptEnd")
					print("Spot reset, failsafe activated.")
					return
				end
				print("SpotHandler | song start!")
				if IsSolo then
					print("SpotHandler | Enabled quit button")
					--if BFOwner then BFProxProm.ActionText = "Quit";BFProxProm.Enabled = true else BFProxProm.Enabled = false end
					--if DadOwner then DadProxProm.ActionText = "Quit";DadProxProm.Enabled = true else DadProxProm.Enabled = false end
					DadProxProm.Enabled = false
					BFProxProm.Enabled = false
				end
				if BFOwner then compRemote:FireClient(BFOwner,0x0) end
				if DadOwner then compRemote:FireClient(DadOwner,0x0) end
				wait(2)
				SpotSound:Play()
				SpotVocals:Play()
			end
			thread_Round = coroutine.create(thread_Round)
			coroutine.resume(thread_Round)

			return compRemote
		end
	end
	Spots[#Spots+1] = Spot
end

BindFunc.OnInvoke = function(msgType,...)
	print("SpotHandler | ",msgType,...)
	if msgType == "GetSpotRemotes" then
		local indicatedSpot = ...
		if indicatedSpot:IsDescendantOf(PS) then
			print("Gave remotes for spot " .. indicatedSpot:GetFullName())
			return indicatedSpot:FindFirstChild("Function"),indicatedSpot:FindFirstChildOfClass("Event")
		end
		return
	end
end

game:service'RunService'.Stepped:connect(function()
	for _,v in next, SpotStuff do
		v:Update()
		if(v.Ownership)then
			if(v.BFOwner~=v.Ownership and v.DadOwner~=v.Ownership or not v.Ownership.Parent)then
				v:KickOff()
			end
		end
	end
end)