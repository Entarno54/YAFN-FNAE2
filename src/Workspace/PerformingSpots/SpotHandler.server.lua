---!strict
local plrs = game:GetService("Players")
local HS = game:GetService("HttpService")
local RS = game:GetService("ReplicatedStorage")
local Event = script.Parent.Event
local BindFunc = script.Parent.Function
local scoreutils = require(RS.Modules.ScoreUtils)
local SongIds = require(RS.SongIDs)
local SongInfo = require(RS.Modules.SongInfo)
local SpotSpecifier = require(game:GetService("ServerScriptService").SpotSpecifier)
--do local hi,exploiters = "!","lol" end
local POIs = {}
local SpotSounds = {}

for _,POIModel in next,script.Parent:GetChildren() do
	if not POIModel:IsA("Model") then
		continue
	end
	-- CopyPasta from old script!
	local BF:any,CO,Dad:any,ARO = POIModel:FindFirstChild("Boyfriend"), POIModel:FindFirstChild("CameraOrigin"),
		POIModel:FindFirstChild("Dad"),POIModel:FindFirstChild("AccuracyRateOrigin")
		
	local GF:any = POIModel:FindFirstChild("Girlfriend")
	local statsModel = POIModel:FindFirstChildOfClass("Model")
	local SpotUIStats:any, SpotUIDad:any, SpotUIBF:any, StatsGUI:any, PlayerIconGUI:any
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
		warn(("Spot doesn't met the requirements! (%s)"):format(POIModel:GetFullName()))
		continue
	end
	

	local SpotSound = Instance.new("Sound")
	local SpotVocals = Instance.new("Sound")
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
	
	-- end
	
	local SpotEvent = Instance.new("BindableEvent")
	SpotEvent.Name = "Event"
	SpotEvent.Parent = POIModel
	
	local SpotFunction = Instance.new("BindableFunction")
	SpotFunction.Name = "Function"
	SpotFunction.Parent = POIModel
	
	local POI:PointOfInterest = {
		BFSpot = SpotSpecifier.AddSpot(BF);
		DadSpot = SpotSpecifier.AddSpot(Dad);
		GFSpot = GF and SpotSpecifier.AddSpot(GF) or nil;
		OptionalStuff = {StatsGUI = StatsGUI,PlayerIconGUI = PlayerIconGUI};
		IsPlaying = false;
		IsSolo = false;
		Model = POIModel;
		Event = SpotEvent.Event;
	}
	POIs[#POIs + 1] = POI
	
	-- Spot stuff
	local BFtakenFunction = function(plr:any)
		local char = plr.Character
		local HRP = char:FindFirstChild("HumanoidRootPart")

		HRP.Anchored = true
		HRP.CFrame = POI.BFSpot.Part.CFrame
		
		if POI.Ownership == nil then
			POI.Ownership = plr
		elseif POI.Ownership and (POI.Ownership ~= POI.BFSpot.Owner and POI.Ownership ~= POI.DadSpot.Owner) then -- give ownership if neither spots doesn't have the actual owner.
			POI.Ownership = plr
		end
		

		Event:Fire("SpotJoin",POI.Model,POI.BFSpot.Part,plr,POI.Ownership == plr)
	end
	
	local DadtakenFunction = function(plr:any)
		local char = plr.Character
		local HRP = char:FindFirstChild("HumanoidRootPart")
		
		if POI.Ownership == nil then
			POI.Ownership = plr
		elseif POI.Ownership and (POI.Ownership ~= POI.BFSpot.Owner and POI.Ownership ~= POI.DadSpot.Owner) then -- give ownership if neither spots doesn't have the actual owner.
			POI.Ownership = plr
		end
		
		HRP.Anchored = true
		HRP.CFrame = POI.DadSpot.Part.CFrame
		Event:Fire("SpotJoin",POI.Model,POI.DadSpot.Part,plr,POI.Ownership == plr)
	end
	POI.BFSpot.Taken:Connect(BFtakenFunction)
	POI.DadSpot.Taken:Connect(DadtakenFunction)
	
	
	local leaveFunction = function(plr:Player)
		print("work!")
		local char = plr.Character
		local HRP = char:FindFirstChild("HumanoidRootPart")
		HRP.Anchored = false
		if POI.Ownership == plr or (POI.IsPlaying and not POI.IsSolo) then
			POI.Ownership = nil
			if POI.DadSpot.Owner and POI.DadSpot.Owner ~= plr then POI.DadSpot.Kick() end
			if POI.BFSpot.Owner and POI.BFSpot.Owner ~= plr then POI.BFSpot.Kick() end
			SpotSound:Stop()
			SpotVocals:Stop()
			POI.IsPlaying = false
			POI.BFSpot.PP.Enabled = true
			POI.DadSpot.PP.Enabled = true
		end
		if plr == POI.BFSpot.Owner then
			Event:Fire("SpotLeave",POI.Model,POI.BFSpot.Part,POI.BFSpot.Owner)
		elseif plr == POI.DadSpot.Owner then
			Event:Fire("SpotLeave",POI.Model,POI.DadSpot.Part,POI.DadSpot.Owner)
		end
	end
	
	POI.BFSpot.Leave:Connect(leaveFunction)
	POI.DadSpot.Leave:Connect(leaveFunction)
	
	SpotEvent.Event:Connect(function(msgType,...)
		if msgType == "BFTrigger" then
			POI.BFSpot.Kick()
		elseif msgType == "DadTrigger" then
			POI.DadSpot.Kick()
		elseif msgType == "AbruptEnd" then
			POI.DadSpot.Kick()
			POI.BFSpot.Kick()
			SpotSound:Stop()
			SpotVocals:Stop()
			Event:Fire("GameEnd")
			print("Spot gone wrong, reseting everything.")
		end
	end)
	
	-- GF Spot
	
	if POI.GFSpot then
		POI.GFSpot.PP.MaxActivationDistance = 7
		local GFAnimTrack
		local speed = 0
		local currentChar,charScript
		SpotSound:GetAttributeChangedSignal("BPM"):connect(function()
			if(GFAnimTrack)then
				speed = SpotSound:GetAttribute("BPM")==0 and 1 or GFAnimTrack.Length/(60/SpotSound:GetAttribute("BPM"))/2
				GFAnimTrack:AdjustSpeed(speed~=math.huge and speed or 1);
			end
		end)
		POI.GFSpot.Taken:Connect(function(plr)
			if plr.Character == nil then return end
			local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
			if not humanoid then return end
			if humanoid.Health <= 0 then return end
			if not plr.Character.PrimaryPart then return end
			local Animator,AnimScript = humanoid:FindFirstChildOfClass("Animator"),currentChar:FindFirstChild("Animate")
			if not Animator then return end
			currentChar = plr.Character
			if AnimScript then AnimScript.Disabled = true;charScript = AnimScript end
			currentChar:SetPrimaryPartCFrame(GF.CFrame * CFrame.new(0,0.1501,0))
			currentChar.PrimaryPart.Anchored = true
			GFAnimTrack = Animator:LoadAnimation(RS.Animations.GF)
			GFAnimTrack.Priority = Enum.AnimationPriority.Action
			GFAnimTrack.Looped = true
			GFAnimTrack:AdjustSpeed(speed~=math.huge and speed or 1);
			GFAnimTrack:Play()
		end)
		POI.GFSpot.Leave:Connect(function(plr)
			if plr.Character ~= currentChar then return end
			currentChar.PrimaryPart.Anchored = false
			if GFAnimTrack then
				GFAnimTrack:Stop()
				GFAnimTrack = nil
			end
			--POI.GFSpot.PP.ActionText = "Vibe"
			if charScript then charScript.Disabled = false;charScript = nil end
			currentChar = nil
		end)
		POI.GFSpot.TextInfo = {
			Available = "Vibe";
			Taken = "Stop";
		}
		POI.GFSpot.PP.ActionText = "Vibe"
	end
	
	-- Gameplay stuff
	
	local compRemote
	local compFunction
	local NameCache = {}
	-- COPYPASTE from old script BLOCK!!!
	SpotFunction.OnInvoke = function(msgType,...)
		print("SpotFunction | ", msgType, ...)

		if msgType == "GetPlayersFromSpot" then
			local theSpot = ...
			if theSpot == POI.Model then
				return POI.BFSpot.Owner, POI.DadSpot.Owner
			end
			wait(2)
		elseif msgType == "QueueInstancesRemoval" then
			local boolSide,instancesTable = ...
			if type(instancesTable) ~= "table" or type(boolSide) ~= "boolean" then return end
			local eventCon
			if boolSide then
				eventCon = POI.BFSpot.Leave:Connect(function()
					for _,Inst in next,instancesTable do
						Inst:Destroy()
					end
					eventCon:Disconnect()
				end)
			else
				eventCon = POI.DadSpot.Leave:Connect(function()
					for _,Inst in next,instancesTable do
						Inst:Destroy()
					end
					eventCon:Disconnect()
				end)
			end
		elseif msgType == "GetSpotOwnership" then
			return POI.Ownership
		elseif msgType == "InitializeCompRemote" then -- Starts the current spot gameplay.
			local msgSpot,whoStart,songModule,songDisplay,mode = ...
			--print(...)
			POI.Model:SetAttribute("randomSeed",math.random(-0xFFFFFFFF,0xFFFFFFFF))
			local ModuleData = HS:JSONDecode(require(songModule))
			if SongInfo[ModuleData.song.song] and SongInfo[ModuleData.song.song].Whitelist and not table.find(SongInfo[ModuleData.song.song].Whitelist,whoStart.UserId) then
				-- do nothing, or something
				return
			end 
			if NameCache[songModule:GetFullName()] then
				songDisplay = NameCache[songModule:GetFullName()]
			else
				if not ModuleData.song.song then
					songDisplay = songModule.Name
					NameCache[songModule:GetFullName()] = songModule.Name
				else
					songDisplay = ModuleData.song.song
					NameCache[songModule:GetFullName()] = ModuleData.song.song
				end
			end
			if msgSpot ~= POI.Model or whoStart ~= POI.Ownership then -- verify if it's the player who sent the signal
				print("fail")
				return
			end
			POI.IsPlaying = true

			POI.BFSpot.PP.Enabled = false
			POI.DadSpot.PP.Enabled = false
			if --[[isStatsAvailable]] POI.OptionalStuff.PlayerIconGUI and POI.OptionalStuff.StatsGUI then
				POI.OptionalStuff.StatsGUI.SongName.Text = songDisplay or (songModule.Name .. "_FAILSAFE")
				POI.OptionalStuff.StatsGUI.PlayerVS.Text = ("%s VS %s"):format(POI.DadSpot.Owner and POI.DadSpot.Owner.DisplayName or "None",POI.BFSpot.Owner and POI.BFSpot.Owner.DisplayName or "None")
				POI.OptionalStuff.StatsGUI.Score.Text = "000000000 | 000000000"
				PlayerIconGUI.BF.Image = POI.BFSpot.Owner and plrs:GetUserThumbnailAsync(POI.BFSpot.Owner.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150) or "rbxassetid://53252054"
				PlayerIconGUI.Dad.Image = POI.DadSpot.Owner and plrs:GetUserThumbnailAsync(POI.DadSpot.Owner.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150) or "rbxassetid://53252054" 
				SpotRoundStats.BFScore = 0
				SpotRoundStats.DadScore = 0
			end


			
			if (POI.DadSpot.Owner and POI.BFSpot.Owner) then
				POI.IsSolo = false
			else
				POI.IsSolo = true
			end
			SpotSound:Stop()
			SpotVocals:Stop()
			if compRemote then compRemote:Destroy() end
			if compFunction then compFunction:Destroy() end
			compRemote = Instance.new("RemoteEvent")
			compRemote.Name = "GameRoundRemote"
			compRemote.Parent = POI.Model
			compFunction = Instance.new("RemoteFunction")
			compFunction.Name = "InfoRetriever"
			compFunction.Parent = POI.Model

			compFunction.OnServerInvoke = function(plr,infoType)
				if infoType == 0x0 then -- Get Opponent player
					if POI.BFSpot.Owner == plr then
						return POI.DadSpot.Owner
					elseif POI.DadSpot.Owner == plr then
						return POI.BFSpot.Owner
					end
					return plr
				elseif infoType == 0x1 then -- return SpotSounds
					return SpotSounds
				end
			end

			local thread_Round = function()
				local BFOwnerReady, DadOwnerReady = POI.BFSpot.Owner == nil,POI.DadSpot.Owner == nil
				local BFOSongReady, DadOSongReady = POI.BFSpot.Owner == nil,POI.DadSpot.Owner == nil
				local BFSongOver, DadSongOver = POI.BFSpot.Owner == nil,POI.DadSpot.Owner == nil

				compRemote.OnServerEvent:Connect(function(plr,msg,...) -- COMPERTITION REMOTE
					--print("compRemote | ", plr, msg, ...)
					if msg == 0x0 then
						if POI.BFSpot.Owner == plr then
							BFOwnerReady = true
						end
						if POI.DadSpot.Owner == plr then
							DadOwnerReady = true
						end
					elseif msg == 0x1 then
						if POI.BFSpot.Owner == plr then
							BFOSongReady = true
						end
						if POI.DadSpot.Owner == plr then
							DadOSongReady = true
						end
					elseif msg == 0x2 then
						if POI.BFSpot.Owner == plr then
							BFSongOver = true
						end
						if POI.DadSpot.Owner == plr then
							DadSongOver = true
						end
					elseif msg == 0x3 then
						local strum,songPos,isSus,nType,dir = ...
						local diff=nil
						local score = 0
						local baseScore = 0;
						if plr == POI.DadSpot.Owner then
							baseScore = SpotRoundStats.DadScore
						elseif plr == POI.BFSpot.Owner then
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


						if plr == POI.DadSpot.Owner and POI.BFSpot.Owner then
							compRemote:FireClient(POI.BFSpot.Owner,0x1,strum,diff,nType,dir,isSus)
						end
						if plr == POI.DadSpot.Owner then
							SpotRoundStats.DadScore = score
						end
						if plr == POI.BFSpot.Owner and POI.DadSpot.Owner then
							compRemote:FireClient(POI.DadSpot.Owner,0x1,strum,diff,nType,dir,isSus)
						end	
						if plr == POI.BFSpot.Owner then
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
						if POI.DadSpot.Owner then
							local HRP = POI.DadSpot.Owner.Character:FindFirstChild("HumanoidRootPart")
							if HRP then HRP.Anchored = false end
							Event:Fire("SpotLeave",POI.Model,POI.DadSpot.Part,POI.DadSpot.Owner)
						end
						if POI.BFSpot.Owner then
							local HRP = POI.BFSpot.Owner.Character:FindFirstChild("HumanoidRootPart")
							if HRP then HRP.Anchored = false end
							Event:Fire("SpotLeave",POI.Model,POI.BFSpot.Part,POI.BFSpot.Owner)
						end
						POI.BFSpot.Kick()
						POI.DadSpot.Kick()

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
						Event:Fire("GameEnd")
						compRemote:Destroy()
						compFunction:Destroy()
						return
					elseif msg == 0x5 then
						mode = ...
						print(mode)
						if mode == "Coop" then
							SpotSpecifier.AddSpot(POIModel:FindFirstChild("Boyfriend2"))
							SpotSpecifier.AddSpot(POIModel:FindFirstChild("Dad2"))
						elseif mode == "Single" then

						else
							warn("Mode cannot be identified!")
						end
						return
					end

					if BFSongOver and DadSongOver then -- Song Over
						print("compRemote Deleted!")
						if POI.DadSpot.Owner then
							local HRP = POI.DadSpot.Owner.Character:FindFirstChild("HumanoidRootPart")
							if HRP then HRP.Anchored = false end
						end
						if POI.BFSpot.Owner then
							local HRP = POI.BFSpot.Owner.Character:FindFirstChild("HumanoidRootPart")
							if HRP then HRP.Anchored = false end
						end
						POI.IsPlaying = false
						POI.BFSpot.Kick()
						POI.DadSpot.Kick()
						compRemote:Destroy()
						compFunction:Destroy()
						Event:Fire("GameEnd")
						SpotSound:Stop()
						SpotVocals:Stop()
					end
				end)
				local count = 0
				repeat
					count += 1
					print("wait..")

					wait(1)
				until (count >= 90) or (BFOwnerReady and DadOwnerReady) or (POI.BFSpot.Owner == nil and POI.DadSpot.Owner == nil)
				if not (BFOwnerReady and DadOwnerReady) then
					SpotEvent:Fire("AbruptEnd")
					print("Someone took too long to load, kicking!")
					return
				end
				print("SpotHandler | song start!")
				--[[
				if IsSolo then
					print("SpotHandler | Enabled quit button")
					--if BFOwner then BFProxProm.ActionText = "Quit";BFProxProm.Enabled = true else BFProxProm.Enabled = false end
					--if DadOwner then DadProxProm.ActionText = "Quit";DadProxProm.Enabled = true else DadProxProm.Enabled = false end
					DadProxProm.Enabled = false
					BFProxProm.Enabled = false
				end--]]
				if POI.BFSpot.Owner then compRemote:FireClient(POI.BFSpot.Owner,0x0) end
				if POI.DadSpot.Owner then compRemote:FireClient(POI.DadSpot.Owner,0x0) end
				wait(2)
				SpotSound:Play()
				SpotVocals:Play()
			end
			thread_Round = coroutine.create(thread_Round)
			coroutine.resume(thread_Round)

			return compRemote
		end
	end
	-- end
end

-- COPY PASTA!
BindFunc.OnInvoke = function(msgType,...)
	print("SpotHandler | ",msgType,...)
	if msgType == "GetSpotRemotes" then
		local indicatedSpot = ...
		if indicatedSpot:IsDescendantOf(script.Parent) then
			print("Gave remotes for spot " .. indicatedSpot:GetFullName())
			return indicatedSpot:FindFirstChild("Function"),indicatedSpot:FindFirstChild("Event")
		end
		return
	end
end