--do local deathMode:nil = nil do local scoreMul = nil if deathMode then if scoreMul then if deathMode then if scoreMul then end end if deathMode then if scoreMul then end end if deathMode then if scoreMul then end end if deathMode then if scoreMul then end end if deathMode then if scoreMul then end end if deathMode then if scoreMul then end end if deathMode then if scoreMul then end end if deathMode then if scoreMul then end end if deathMode then if scoreMul then end end if deathMode then if scoreMul then end end end end end end do end do end
local module = {}

local repS = game:GetService("ReplicatedStorage")
local mods = repS.Modules
local songs = mods:WaitForChild'Songs'
local TS = game:GetService("TweenService")
local UIS = game:service'UserInputService'
local KSP = game:GetService("KeyframeSequenceProvider")
local RS = game:GetService("RunService")
local SS = game:GetService("SoundService")
local HS = game:GetService("HttpService")
local plr = game:service'Players'.localPlayer
local repS = game.ReplicatedStorage
local cam = workspace.CurrentCamera
local gameUI = script.Parent
-- libraries i guess
local Character = require(game.ReplicatedStorage.Modules.Character)
local NoteClass = require(game.ReplicatedStorage.Modules.Note)
local Sprite = require(game.ReplicatedStorage.Modules.Sprite)
local Switch = require(game.ReplicatedStorage.Modules.Switch)
local FlxVel = require(game.ReplicatedStorage.Modules.FlxVel)
--local Player = require(game.ReplicatedStorage.Modules.Player)
local Receptor = require(game.ReplicatedStorage.Modules.Receptor)
local UserInputBind = require(game.ReplicatedStorage.Modules.UserInputBindables)
local ScoreUtils = require(game.ReplicatedStorage.Modules.ScoreUtils)
local Icons = require(game.ReplicatedStorage.Modules.Icons)
local GameSettings = require(repS.Modules.GameSettings) 
local RPC = require(repS.Modules.BloxstrapRPC)
local ids = require(repS.SongIDs)
local playerNoteOffsets= {}
local opponentNoteOffsets = {}
local DadNotesUI = script.Parent.realGameUI.Notes.DadNotes
local BFNotesUI = script.Parent.realGameUI.Notes.BFNotes
local DadBG,BFBG = script.Parent.realGameUI.Notes.DadBG,script.Parent.realGameUI.Notes.BFBG
local TimeBar = gameUI.TimeBar
--local customScoreFormat = ""
local GFSection = false

local noteScaleRatio = Vector2.new(448,684) -- TODO: do this programatically
-- (Create a Frame with a size of 0,1280,0,720 w/ the aspectratioconstraint in it and get the absolutesize from it for this variable)
-- or basically print(1280*0.35,720*0.95)


local visSus = game.ReplicatedStorage.VisualSustain
local songEndEvent = Instance.new("BindableEvent")
module.endSongEvent = songEndEvent.Event

local sliderVelocities = {}
local velocityMarkers = {}
local initialSpeed = 1;

local ScoreLabel = script.Parent.realGameUI:WaitForChild'ScoreLabel'
local ScoreLabelss = script.Parent.realGameUI:WaitForChild'Ratings'
local HPBarBG = script.Parent.realGameUI.Notes:WaitForChild'HPBarBG'
local HPContainer = HPBarBG.BarContainer
local HPBarG = HPContainer:WaitForChild'GreenBar'
local HPBarR = HPContainer:WaitForChild'RedBar'
local RNG= Random.new()
local totalPlayed=0;
local totalNotesHit=0;
local accuracy=0;
local mapProps=nil;

-- Generics

local instrSound: Sound=script.Parent.Song.Instrumental
local voiceSound: Sound=script.Parent.Song.Voices
local HB = game:service'RunService'.Heartbeat
local ratingLabels={}
local noteLanes = {};
local susNoteLanes = {};
local allReceptors = {};
local averageAccuracy = {}
local playerStrums = {}
local leftStrums = {}
local rightStrums  = {};
local dadStrums={}
local boomSpeed = 4
local camSpeed = 1
local currentSection={}
local updateMotions={}
PlayerObjects = {}
local combo = 0;
local opponentCombo = 0;
local speedModifier = 1;
local flipMode=false;
local validScore = true;
local Botplay = false;
local attributeFunctions = {}
local camZooming = false
local defaultCamZoom = .05
local songLength = 0
local falseSongLength = -1
local defaultClockTime = 6.5 -- Change this to change the time of day!!!
local modcharts = {}
local targetCam = cam.CFrame
function numLerp(a,b,c)
	return a+(b-a)*c
end
local defaultScreenSize = Vector2.new(1280,720)
local ScreenRatio = cam.ViewportSize.Y/cam.ViewportSize.X
local defaultScreenRatio = defaultScreenSize.Y/defaultScreenSize.X
local ratioDiffX = cam.ViewportSize.X / defaultScreenSize.X
local ratioDiffY = cam.ViewportSize.Y / defaultScreenSize.Y
local visualiser = nil
leaveButton = require(game.ReplicatedStorage.Modules.Topbar).getIcon("LeaveButton")
leaveButton:setEnabled(false)
local GameStartTime = os.time()
-- Experimental

-- modchart functions --
--[[
local modchartFunctions = {}; 

local function bindModchart(name, func)
	local boundFunc = function(...)
		if type(func) == "function" then
			return func(...)
		end
	end
	
	modchartFunctions[name] = boundFunc -- store bound functions inside of modchartFunctions
	
	print(modchartFunctions)
	
	return boundFunc
end

local function unbindModchart()
	for name, boundFunc in pairs(modchartFunctions) do
		modchartFunctions[name] = nil -- Clear reference of bound function
	end
	
	modchartFunctions = {} -- Reset table
end
]]
--  -- 

-- listing math things
local round2 = function(x) 
	return string.format("%.1f", x)
end

-- Tweens
local CameraTween
local StoredTweens = {};

local function addTween(tween:Tween, name:string) -- name is optional
	if tween then
		if name then
			StoredTweens[name] = tween
		else
			table.insert(StoredTweens, tween)
		end
		
		tween.Completed:Connect(function()
			if not name then
				local targetSighted = table.find(StoredTweens, tween)
				if targetSighted then
					table.remove(StoredTweens, targetSighted)
				end
			end
			
			tween = nil
		end)
	end
end

-- (ratioDiff * (internalSettings.autoSize * module.settings.customSize))

local LoadingStatus = {
	LoadedNotes = 0;
	DataNotes = 0;
	SectionCount = 0;
	PreloadedImages = 0;
	DoneLoading = false;
}
local IntroSounds = {
	script.Parent.Countdown['3'];
	script.Parent.Countdown['2'];
	script.Parent.Countdown['1'];
	script.Parent.Countdown.Go;
}
local rates = {
	miss=0;
	bad=0;
	good=0;
	sick=0;	
}
local songData;
local lastBPMChange

-- Controllable Stuff
camFollow = nil

local camControls = {
	zoom=0;
	BehaviourType = "All"; -- All,HUD,Camera,Separate
	-- If BehaviourType is Separate, use these 2 values below.
	hudZoom = 0.05;
	camZoom = 0;
	camOffset = CFrame.new();
	StayOnCenter = false;
	ForcedPos = false;
	DisableLerp = false;
	noBump = false;
}
local internalSettings = {
	autoSize = 1; -- Basically a variable to handle the UI size, although it's only used once, so it's not recommended to change this value.
	notesRotateWithReceptors = false; -- Receptors will share their rotation with the notes.
	notesShareTransparencyWithReceptors = false; -- Notes will share the same transparency as the receptors transparency.
	OpponentNoteDrain = false; -- What it says, it can be a number to enable it.
	useDuoSkins = false;
	useBPMSyncing = false; -- Due to compatibility issues with certain modcharts, this will be used, i don't understand why neither.
	currentNoteSkinChange = nil;
	showOnlyStrums = false;
	NoteSpawnTransparency = 0;
	minHealth=0.1
}

local NoteXmls = {
	[0] = repS.Modules.Assets["Note4K.xml"];
	[1] = repS.Modules.Assets["Note6K.xml"];
	[2] = repS.Modules.Assets["Note9K.xml"];
	[3] = repS.Modules.Assets["Note9K.xml"];
	[4] = repS.Modules.Assets["Note9K.xml"];
	[5] = repS.Modules.Assets["Note9K.xml"];
}

local XMLToUse

local DirAmmo = {
	[0] = 4;
	[1] = 6;
	[2] = 9;
	[3] = 5; -- FB&WG
	[4] = 7; -- FB&WG
	[5] = 8; -- Tinky Winky
	--[n + 1] = 21
}

local zoomManiaStuff = {
	[0] = 1,
	[1] = 0.8,
	[2] = 0.55,
	[3] = 0.95,
	[4] = 0.7,
	[5] = 0.6;
}

-- Defining stuff into the module

module.settings = GameSettings.settings
module.settingsRules = GameSettings.settingsRules
module.LoadingStatus = LoadingStatus
module.PlayerObjects = PlayerObjects

-- shared stuff

shared.internalSettings = internalSettings -- Important
shared.noteScaleRatio=noteScaleRatio; -- Important
shared.DirAmmo = DirAmmo -- Important
shared.sections = true
shared.cancelAnim = false

-- uhh, stuff that can change?

local BFIcon, DadIcon = Sprite.new(HPBarBG.Parent.BF,true,1,true,defaultScreenSize),Sprite.new(HPBarBG.Parent.Dad,true,1,true,defaultScreenSize)
local plrIcon,oppIcon
module.PositioningParts = {
	Left = nil; -- Dad
	Right = nil; -- Boyfriend
	Left2 = nil; -- Second BF
	Right2 = nil;
	Camera = nil;
	isPlayer = {nil,nil,nil,nil}; -- bf, dad, bf2, dad2
	AccuracyRate = nil; -- the funny messages
	PlayAs = nil; -- none, left or right
	isOpponentAvailable = nil; -- fighting against a ghost?????
	Spot = nil;
	BFIcon = BFIcon;
	DadIcon = DadIcon;
	CameraPlayer = false;
}
module.PlayerStats = {
	Health = 1;
	DrainRate = 0; -- health drained in seconds.
	MaxHealth = 2;
	Score = 0;
}

-- Might be used in the future
--module.OpponentSettings = {}

PlayerObjects.BF,PlayerObjects.Dad=nil,nil;
PlayerObjects.BF2,PlayerObjects.Dad2=nil,nil;

type Note = NoteClass.Note

local generatedSong=false;
local startedCountdown=false;
local startingSong=false;
local songEnded=false;
local opponentNotes = {};
local notes = {};
local bpmChangePoints = {}
local events = {}
local eventNotes = {}

--[[ DEPRECATED
local playerNotesList = {
	[0] = {0,1,2,3,8,9,10,11};
	[1] = {0,1,2,3,4,5,12,13,14,15,16,17};
	[2] = {0,1,2,3,4,5,6,7,8,18,19,20,21,22,23,24,25,26};
	[3] = {0,1,2,3,4,10,11,12,13,14};
}--]] 

local keyAmmo = {4,6,9,5,7,8}

songData = {
	mania = 0
}

local bindNameDir = {}

local function KillclientAnims()
	if game:GetService("Players").LocalPlayer.Character then
		local CLEAR_HUM = game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid") 
		if CLEAR_HUM then
			for i,v in pairs(CLEAR_HUM:GetPlayingAnimationTracks()) do 
				if v.Animation and not v.Animation:IsDescendantOf(CLEAR_HUM.Parent) then
					--		print(v.Animation:GetFullName())
					v:Stop()
					v:Destroy()
				end
			end
		end
	end
end

function module.setProperty(va, value)
	local split = ''
	if string.find(va, '.') then
		split = string.split(va, '.')

		if split[1] == 'camControls' then
			camControls[split[2]] = value
		end
	end

	if va == 'defaultCamZoom' then -- not efficient but loadstring is disabled by default because of exploits
		defaultCamZoom = 1 - value
	elseif va == 'camGame.zoom' then
		camControls.hudZoom = value
	elseif va == 'camZooming' then
		camZooming = value
	elseif va == 'songLength' then
		falseSongLength = value
	end
end

local function offsetUI(inten)
	return CFrame.new(math.rad(math.random(-inten,inten)),math.rad(math.random(-inten,inten)),math.rad(math.random(-inten,inten)))
end

function AddPointToUDim2(udim2,point)
	return udim2+UDim2.new(0,point.X,0,point.Y);
end

local function GetColorFromHEX(hex:number)
	local numbString = string.format("%X",hex)
	if #numbString < 6 then
		repeat
			numbString = "0" .. numbString
		until #numbString >= 6
	end
	local red = tonumber("0x" .. numbString:sub(1,2))
	local green = tonumber("0x" .. numbString:sub(3,4))
	local blue = tonumber("0x" .. numbString:sub(5,6))
	return Color3.fromRGB(red,green,blue)
end

function GetDirectionForKey(KeyCode)
	--[[
	for direction,keys in next, module.settings.Keybinds[songData.mania+1] do
		if(table.find(keys,KeyCode))then
			return direction
		end
	end
	--]]
	for direction,bindName in next, bindNameDir do
		if(bindName == KeyCode)then
			return direction
		end
	end
end
--[[
if module.settings.preloadDeathNotes then
	local deathNotes = gameUI.Parent.PreLoad.DeathNotes:GetChildren()
	for i = 1, #deathNotes do
		deathNotes[i].Visible = true
	end
else
	local deathNotes = gameUI.Parent.PreLoad.DeathNotes:GetChildren()
	for i = 1, #deathNotes do
		deathNotes[i].Visible = false
	end
end]]

function HeldDirections()
	local d={[0]=false,[1]=false,[2]=false,[3]=false,[4]=false,[5]=false,[6]=false,[7]=false,[8]=false}

	for direction,_ in next, module.settings.Keybinds[songData.mania+1] do
		d[direction-1] = UserInputBind.IsBindPressed("Direction" .. direction)
	end
	return d
end

local curSong=""

local lastStep,lastBeat,curStep,totalSteps,totalBeats,curBeat=0,0,0,0,0,0;

local loadedModchartData = {};
local loadedCutscene = nil;

local unspawnedNotes = {}
local NoteObject
local Conductor = require(game.ReplicatedStorage.Modules.Conductor)
Conductor.screenSize = defaultScreenSize

local GameplayEvent = Instance.new("BindableEvent")
GameplayEvent.Name = "GameplayEvent"
module.GameplayEvent = GameplayEvent.Event

--	-	-	-	-	-	-	-	-	-	-	-	-	-	-
-- Functions
--	-	-	-	-	-	-	-	-	-	-	-	-	-	-

function module.getSongName(Module)
	local data = require(Module) --songCache[Module.Name] or require(Module or songs.Philly)
	if(typeof(data)=='string')then
		data=game:service'HttpService':JSONDecode(data)
	end
	return data.song.song
end

local SongIdInfo

function mapVelocityChanges()
	if(sliderVelocities==nil or #sliderVelocities==0)then
		return
	end

	local pos = sliderVelocities[1].startTime*(initialSpeed*sliderVelocities[1].multiplier)
	table.insert(velocityMarkers,pos);

	for i =2, #sliderVelocities do
		pos+=(sliderVelocities[i].startTime-sliderVelocities[i-1].startTime)*(initialSpeed*sliderVelocities[i-1].multiplier)
		table.insert(velocityMarkers,pos);
	end
end

function shakeUI(intensity, duration)
	local elapsed = 0
	while elapsed < duration and generatedSong do
		if elapsed < duration then
			gameUI.realGameUI.Position = UDim2.new(0.5,(math.random(-intensity,intensity)),0.5,(math.random(-intensity,intensity)))
		end
		elapsed += RS.RenderStepped:Wait()
	end

	gameUI.realGameUI.Position = UDim2.new(0.5, 0, 0.5, 0)
end

function shakeScreen(intensity, duration)
	local elapsed = 0
	while elapsed < duration and generatedSong do
		if elapsed < duration then
			snapCamera(offsetUI(intensity))
		end
		elapsed += HB:Wait()
	end

	snapCamera(CFrame.new())
end

local soundCache = {}
function playSound(snd,vol)
	local sound 
	if typeof(snd) ~= "Instance" then
		assert(type(snd) == "string" or type(snd) == "number","Invalid value.")
		local id = type(snd) == "string" and snd or ("rbxassetid://" .. snd)
		sound = soundCache[id]
		if not sound then
			local soundCast = Instance.new("Sound")
			soundCast.SoundId = id
			soundCast.Volume = 1
			soundCast.PlaybackSpeed = speedModifier
			soundCache[id] = soundCast
			sound = soundCast
		end
	else
		sound = snd
	end
	sound.Volume = vol or 1
	if sound.Parent == nil then
		sound.Parent = SS
	end
	SS:PlayLocalSound(sound)
end

-- Old function, removed cause too complicated to use
--[[
function addSprite(tag:Name, imageId:ImageId, pos:Position, size:Size)
	local image = gameUI.realGameUI.Overlay:Clone()
	local x = pos.X.Offset / ratioDiffX
	local y = pos.Y.Offset * ratioDiffY
	image.Position = UDim2.new(pos.X.Scale, x, pos.Y.Scale, y)
	image.Size = size--UDim2.new(size.X.Scale / ratioDiff, size.X.Offset, size.Y.Scale / ratioDiff, size.Y.Offset)
	image.Name = tag
	image.Image = imageId
	image.Visible = true
	return image
end
--]]

function module.genSong(songName, songSettings, plr2) -- plr2: 1=dad2 2=bf2
	generatedSong=false
	startedCountdown=false
	PlayerObjects = { -- Redefine
		BF = nil;
		Dad = nil;
		BF2 = nil;
		Dad2 = nil;
	}
	if not module.PositioningParts.isPlayer[1] and PlayerObjects.BF then PlayerObjects.BF:Destroy() end
	if not module.PositioningParts.isPlayer[2] and PlayerObjects.Dad then PlayerObjects.Dad:Destroy() end
	if not module.PositioningParts.isPlayer[3] and PlayerObjects.BF2 then PlayerObjects.BF2:Destroy() end
	if not module.PositioningParts.isPlayer[4] and PlayerObjects.Dad2 then PlayerObjects.Dad2:Destroy() end
	--print("Engine:genSong | playing as " .. (module.PositioningParts.PlayAs and "Boyfriend" or "Dad"))

	-- reset everything
	shared.sections=true
	shared.cancelAnim=false
	voiceSound:Stop()
	instrSound:Stop()
	totalNotesHit,totalPlayed =0,0
	accuracy=0
	camZooming = false
	defaultCamZoom = 0.05
	falseSongLength = -1
	camControls.zoom = 0
	camControls.BehaviourType = "Separate"
	camControls.StayOnCenter = false
	camControls.DisableLerp = false

	resetGroup("Conductor")

	Conductor.elapsed=0
	Conductor.curSong=songName
	internalSettings.currentNoteSkinChange = nil
	internalSettings.OpponentNoteDrain = false
	internalSettings.notesShareTransparencyWithReceptors = false
	internalSettings.NoteSpawnTransparency = 0
	internalSettings.showOnlyStrums = false
	internalSettings.notesRotateWithReceptors = false
	workspace.Camera.FieldOfView = 70
	game.Lighting.ClockTime = defaultClockTime
	game.Lighting.ColorCorrection.Saturation = 0
	allReceptors = {}
	dadStrums = {}
	playerStrums = {}
	leftStrums = {}
	rightStrums = {}
	averageAccuracy = {}
	bpmChangePoints = {}
	modcharts = {}
	events = {}
	loadedModchartData = {}
	eventNotes = {}
	NoteClass.specialNoteAnimQueue = {}
	LoadingStatus.LoadedNotes = 0;
	LoadingStatus.DataNotes = 0;
	LoadingStatus.SectionCount = 0;
	LoadingStatus.PreloadedImages = 0;
	LoadingStatus.DoneLoading = false;
	for i,v in next,notes do
		pcall(function()v:Destroy()end)
	end
	for i,v in next,unspawnedNotes do
		pcall(function()v:Destroy()end)
	end
	notes={}
	unspawnedNotes={}
	combo=0
	opponentCombo=0
	module.PlayerStats.Score=0
	module.PlayerStats.Health=1
	module.PlayerStats.DrainRate = 0
	module.PlayerStats.MaxHealth = 2
	gameUI.realGameUI.Rotation = 0
	gameUI.realGameUI.Position = UDim2.new(0.5,0,0.5,0)
	if module.settings.HideProps then
		local Props = workspace.Props:GetChildren()
		for i = 1, #Props do
			Props[i].Parent = game.ReplicatedStorage.HiddenProps
		end
	else
		local Props = game.ReplicatedStorage.HiddenProps:GetChildren()
		for i = 1, #Props do
			Props[i].Parent = workspace.Props
		end
	end
	for i,v in next, rates do rates[i]=0 end
	lastStep,lastBeat,curStep,totalSteps,totalBeats,curBeat=0,0,0,0,0,0;
	Conductor.Downscroll = module.settings.Downscroll
	speedModifier = songSettings.SpeedModifier
	camSpeed = speedModifier
	instrSound.PlaybackSpeed=speedModifier
	voiceSound.PlaybackSpeed=speedModifier

	local camSizeX = cam.ViewportSize.X 
	local data = require(songName)--songCache[songName] or require(songs:FindFirstChild(songName) or songs.Philly)
	if(typeof(data)=='string')then
		data=game:service'HttpService':JSONDecode(data)
	end
	songData=data.song;
	--[[if plr2 then
		if plr2 == 1 then
			flipMode = false
		else
			flipMode = true
		end
	else
		flipMode = not module.PositioningParts.PlayAs
	end]]
	flipMode = not module.PositioningParts.PlayAs
	if songData.mania == nil then
		songData.mania = 0
	end
	songData.mania = songName:GetAttribute("maniaForce") or songData.mania
	local NSFolder =  repS.Modules.Assets["noteSkins" .. DirAmmo[songData.mania] .. "K"]
	SongIdInfo = ids[songData.song]
	if not SongIdInfo then error('This Chart References A Undefined Song (Please Change Or Add It In SongIds)'); return end

	curSong=songName
	shared.song=curSong
	shared.songData=songData
	shared.songSpeed=((module.settings.ForceSpeed and 1 or songData.speed) * module.settings.CustomSpeed) -- * 1/instrSound.PlaybackSpeed -- NO!!!!!!
	shared.Receptors = allReceptors
	initialSpeed = shared.songSpeed*.45;
	velocityMarkers={}
	sliderVelocities = data.sliderVelocities;
	if(sliderVelocities)then
		table.sort(sliderVelocities,function(a,b)
			return a.startTime<b.startTime
		end)
	else
		sliderVelocities = {
			{
				startTime= 0;
				multiplier=1;
			}
		}
	end
	mapVelocityChanges();
	Conductor.SVIndex=0;
	internalSettings.useBPMSyncing = SongIdInfo.UseBPMSyncing or true
	internalSettings.useDuoSkins = false -- vs Eteled, Bob & Bosip and stuff that uses one noteskin from each side
	if SongIdInfo.BFNoteSkin and SongIdInfo.DadNoteSkin then
		internalSettings.useDuoSkins = {
			BF = NSFolder:FindFirstChild(SongIdInfo.BFNoteSkin or "");
			Dad = NSFolder:FindFirstChild(SongIdInfo.DadNoteSkin or "")
		}
	end
	if SongIdInfo.defaultCamZoom then
		defaultCamZoom = 1 - SongIdInfo.defaultCamZoom
	end
	if SongIdInfo.ClockTime and SongIdInfo.ClockTime~=nil then
		game.Lighting.ClockTime = SongIdInfo.ClockTime
	end
	if(module.settings["NoteSkin_" .. DirAmmo[songData.mania] .."K"] == "Default" and typeof(SongIdInfo.NoteSkin)=='string')then
		NoteObject = NSFolder:FindFirstChild(SongIdInfo.NoteSkin or "")
	else

		NoteObject = NSFolder:FindFirstChild(module.settings["NoteSkin_" .. DirAmmo[songData.mania] .."K"])
	end
	if internalSettings.useDuoSkins and module.settings["NoteSkin_" .. DirAmmo[songData.mania] .."K"] ~= "Default" then
		internalSettings.useDuoSkins[flipMode and "Dad" or "BF"] = NSFolder:FindFirstChild(module.settings["NoteSkin_" .. DirAmmo[songData.mania] .."K"])
	end
	if(not NoteObject)then -- if somehow it's NIL, use the Original.
		NoteObject=NSFolder.Original;
	end
	if internalSettings.useDuoSkins then
		NoteXml = {} 
		NoteXml.BF = (internalSettings.useDuoSkins.BF:FindFirstChild("XML") or internalSettings.useDuoSkins.BF:FindFirstChild("XMLRef")) or NoteXmls[songData.mania]
		if NoteXml.BF:IsA("ObjectValue") and NoteXml.BF.Name == "XMLRef" then
			NoteXml.BF = NoteXml.BF.Value
		end
		NoteXml.Dad = (internalSettings.useDuoSkins.Dad:FindFirstChild("XML") or internalSettings.useDuoSkins.Dad:FindFirstChild("XMLRef")) or NoteXmls[songData.mania]
		if NoteXml.Dad:IsA("ObjectValue") and NoteXml.Dad.Name == "XMLRef" then
			NoteXml.Dad = NoteXml.Dad.Value
		end
		if module.settings["NoteSkin_" .. DirAmmo[songData.mania] .."K"] ~= "Default" then
			local fMName =flipMode and "Dad" or "BF"
			NoteXml[fMName] = (NoteObject:FindFirstChild("XML") or NoteObject:FindFirstChild("XMLRef")) or NoteXmls[songData.mania]
			if NoteXml[fMName]:IsA("ObjectValue") and NoteXml[fMName].Name == "XMLRef" then
				NoteXml[fMName] = NoteXml[fMName].Value
			end
		end
	else
		NoteXml = (NoteObject:FindFirstChild("XML") or NoteObject:FindFirstChild("XMLRef")) or NoteXmls[songData.mania]
		if NoteXml:IsA("ObjectValue") and NoteXml.Name == "XMLRef" then
			NoteXml = NoteXml.Value
		end
	end

	
	game:GetService('ContentProvider'):PreloadAsync({'rbxassetid://11638311146'})
	

	opponentNotes={}
	for i = 1,DirAmmo[songData.mania] do
		noteLanes[i]={};
		susNoteLanes[i]={};
		playerNoteOffsets[i] = {X=0,Y=0} -- Create a point LuaU type maybe?
		opponentNoteOffsets[i] = {X=0,Y=0}
	end

	local modchart = nil
	local cutscene = nil
	if module.settings.Modcharts then
		local childs = songName.Parent:GetChildren()
		for i = 1, #childs do 
			if string.match(childs[i].Name, ".lua", string.len(childs[i].Name)-4) then
				table.insert(modcharts, childs[i])
			elseif childs[i].Name == "events" then
				local thing = require(childs[i])
				table.insert(events, HS:JSONDecode(thing))
			end
			if childs[i].Name == "Cutscene" then
				cutscene = childs[i]
			end
		end
		local childs = songName.Parent.Parent:GetChildren()
		for i = 1, #childs do 
			if string.match(childs[i].Name, ".lua", string.len(childs[i].Name)-4) then
				table.insert(modcharts, childs[i])
			end
		end
		modchart = SongIdInfo.Script and mods.Modcharts:FindFirstChild(SongIdInfo.Script) or mods.Modcharts:FindFirstChild(songData.song)
		table.insert(modcharts, modchart)
	end

	startingSong=true

	internalSettings.autoSize = module.settings.maniaAutoSize and zoomManiaStuff[songData.mania] or 1 -- set a size depending on mania mode
	shared.autoSize=internalSettings.autoSize
	local hasOneExtraButton = songData.song == "Termination"
		or songData.song == "Left Unchecked" 
		or songData.song == "Safety Lullaby"
		or songData.song == "the-end"
		or (songData.song == "Monochrome" and songName.Name ~= "Hard")
		or (songData.song == "MissingNo." and songName.Name == "get real")
	for Direction,Keycodes in next,module.settings.Keybinds[songData.mania+1] do
		for _,KeyCode in next,Keycodes do
			UserInputBind.AddBind("Direction" .. Direction,KeyCode)
		end
		if UIS.TouchEnabled then 
			local button = UserInputBind.CreateBindButton("Direction" .. Direction,gameUI.Resources.KeyButton:Clone())
			if module.settings.diamondNoteSpacebarTouch and DirAmmo[songData.mania]%2 == 1 and not hasOneExtraButton then
				if Direction == math.ceil(DirAmmo[songData.mania]/2) then
					button.Size = UDim2.new(1,0,1/3,0)
					button.Position = UDim2.new(0,0,2/3,0)
				elseif Direction < math.ceil(DirAmmo[songData.mania]/2) then
					button.Position = UDim2.new(1/(DirAmmo[songData.mania]-1) * (tonumber(Direction)-1),0,0,0)
					button.Size = UDim2.new(1/(DirAmmo[songData.mania]-1),0,2/3,0)
				else
					button.Position = UDim2.new(0.5 + (1/(DirAmmo[songData.mania]-1) * (tonumber(Direction) - math.ceil(DirAmmo[songData.mania]/2)-1)),0,0,0)
					button.Size = UDim2.new(1/(DirAmmo[songData.mania]-1),0,2/3,0)
				end
			else
				if hasOneExtraButton then
					button.Size = UDim2.new(1/DirAmmo[songData.mania],0,2/3,0)
					--make all the buttons to have a gap below the screen
				else
					button.Size = UDim2.new(1/DirAmmo[songData.mania],0,1,0)
				end
				button.Position = UDim2.new(1/DirAmmo[songData.mania] * (tonumber(Direction)-1),0,0,0)
			end
			button.BackgroundTransparency = 0.975
			local color = GetColorFromHEX(module.settings.TileColors[songData.mania+1][Direction]) or Color3.fromRGB(RNG:NextInteger(0,255),RNG:NextInteger(0,255),RNG:NextInteger(0,255))
			button.ImageColor3 = color
			button.ImageTransparency = 0.5
			button.BG.BackgroundColor3 = color
			button.Visible = true
			--button.Text = Direction

			button.Parent = gameUI.TouchScreen
		end
		bindNameDir[Direction] = "Direction" .. Direction
	end
	if UIS.TouchEnabled then 
		if songData.song == "Termination" then
			local button = UserInputBind.CreateBindButton("Dodge",gameUI.Resources.KeyButton:Clone())
			button.Size = UDim2.new(1,0,1/2,0)
			button.Position = UDim2.new(0,0,2/3,0)
			button.ImageColor3 = Color3.new(1, 0.72549, 0.72549)
			button.BG.BackgroundColor3 = Color3.new(1, 0.72549, 0.72549)
			button.Visible = true
			button.Parent = gameUI.TouchScreen
		elseif songData.song == "Left Unchecked" 
			or songData.song == "Safety Lullaby" 
			or songData.song == "the-end"
			or (songData.song == "Monochrome" and songName.Name ~= "Hard")
			or (songData.song == "MissingNo." and songName.Name == "get real")
		then
			local button = UserInputBind.CreateBindButton("win",gameUI.Resources.KeyButton:Clone())
			button.Size = UDim2.new(1,0,1/2,0)
			button.Position = UDim2.new(0,0,2/3,0)
			button.ImageColor3 = Color3.new(1, 0, 0)
			button.BG.BackgroundColor3 = Color3.new(0.541176, 0, 0)
			button.Visible = true
			button.Parent = gameUI.TouchScreen
		end
	end

	module.PositioningParts.songName = songData.song
	if SongIdInfo.PlaybackSpeed then
		instrSound.PlaybackSpeed *= SongIdInfo.PlaybackSpeed
		voiceSound.PlaybackSpeed *= SongIdInfo.PlaybackSpeed
	end

	-- Cover the scree in black so that the player doesn't have to look at the game while it is loading
	local flash = gameUI.realGameUI.Flash
	flash.BackgroundTransparency = 0
	flash.BackgroundColor3 = Color3.new(0, 0, 0)
	flash.Visible = true

	if SongIdInfo.mapProps and repS.Maps:FindFirstChild(SongIdInfo.mapProps) then
		local map = repS.Maps[SongIdInfo.mapProps]
		local Floor = module.PositioningParts.Spot:FindFirstChild('Floor')
		mapProps = map:Clone()
		local povit = Floor:GetPivot()
		mapProps:PivotTo(povit)
		if mapProps:FindFirstChild("MapScript") then
			task.spawn(require(mapProps.MapScript).main)
		end
		local Props = game.workspace.BaseMap:GetChildren()
		for i = 1, #Props do
			Props[i].Parent = game.ReplicatedStorage.HiddenMaps
		end
		if SongIdInfo.hideProps then
			local Props2 = game.Workspace.Props:GetChildren()
			for i = 1, #Props2 do
				Props2[i].Parent = game.ReplicatedStorage.HiddenProps
			end
		end
	end

	local notesData = songData.notes
	--BFNotesUI.Position = UDim2.new((-498 + (-112 * (DirAmmo[songData.mania] - 4)))  * (internalSettings.autoSize * module.settings.customSize)/workspace.CurrentCamera.ViewportSize.X,0,1,0)
	Conductor:ChangeBPM(songData.bpm)
	--print(Conductor.BPM,60/Conductor.BPM)
	lastBPMChange = {
		songTime = 0;
		stepTime = 0;
		bpm = songData.bpm;
	}
	local setanimationtableevent = nil
	local setupcharacter = nil
	-- set up the player stuff
	do
		local BFChar = songData.player1
		local DadChar = songData.player2
		-- icons
		
		-- Trust me this needed
		local BFsIcon = SongIdInfo.BFAnimations or "BF"
		local DadsIcon = SongIdInfo.DadAnimations or "Dad"
		
		plrIcon = flipMode and DadIcon or BFIcon
		oppIcon = flipMode and BFIcon or DadIcon
		if module.settings.CustomIcon and module.settings.CustomIcon ~= "Default" then
			if flipMode then
				DadsIcon = module.settings.CustomIcon
			else
				BFsIcon = module.settings.CustomIcon
			end
		end
		
		-- Try to reset the animations
		BFIcon.Animations = {}
		DadIcon.Animations = {}
		BFIcon.CurrAnimation = nil;
		DadIcon.CurrAnimation = nil;
		BFIcon.AnimData.Looped = false
		DadIcon.AnimData.Looped = false

		module.changeIcon(BFsIcon, true) -- true is right side
		module.changeIcon(DadsIcon, false) -- false is left side
		-- models
		local CharacterAnimations = {};
		local plrChar = flipMode and DadChar or BFChar
		local Animations = {};
		local BFAnim,DadAnim
		local selectedPlayerAnims = module.settings.ForcePlayerAnim ~= "Default" and 
			repS.Animations.CharacterAnims:FindFirstChild(module.settings.ForcePlayerAnim) or repS.Animations.CharacterAnims:FindFirstChild(plrChar)
		if flipMode then
			Animations["BF"] = (repS.Animations.CharacterAnims:FindFirstChild(SongIdInfo.BFAnimations or BFChar) or repS.Animations.CharacterAnims.BF)
			Animations["Dad"] = selectedPlayerAnims or (repS.Animations.CharacterAnims:FindFirstChild(SongIdInfo.DadAnimations or DadChar) or repS.Animations.CharacterAnims.Dad)
		else
			Animations["BF"] = selectedPlayerAnims or (repS.Animations.CharacterAnims:FindFirstChild(SongIdInfo.BFAnimations or BFChar) or repS.Animations.CharacterAnims.BF)
			Animations["Dad"] = (repS.Animations.CharacterAnims:FindFirstChild(SongIdInfo.DadAnimations or DadChar) or repS.Animations.CharacterAnims.Dad)
		end
		
		local function makeAnimTable(name, anim) -- Make the animation table for character's name
			Animations[name] = anim
			if not CharacterAnimations[name] then
				CharacterAnimations[name] = {};
				CharacterAnimations[name].MicPositioning = nil
				CharacterAnimations[name].Offset = CFrame.new()
				CharacterAnimations[name].Name = anim.Name
			end
			for _,AnimObj in next,anim:GetChildren() do
				if AnimObj:IsA("CFrameValue") and AnimObj.Name == "BFOffset" then
					CharacterAnimations[name].Offset = AnimObj.Value
				end
				if AnimObj:IsA("Folder") and AnimObj.Name == "MicPositioning" then
					for _,Obj in next,AnimObj:GetChildren() do
						CharacterAnimations[name].MicPositioning[Obj.Name] = Obj.Value
					end
				elseif AnimObj:IsA("ObjectValue") or AnimObj:IsA("BoolValue") and AnimObj.Name == "MicPositioning" then
					CharacterAnimations[name].MicPositioning = AnimObj.Value
				elseif AnimObj:IsA('StringValue') and AnimObj.Name == "Microphone" then
					CharacterAnimations[name].Microphone = AnimObj.Value
				elseif AnimObj:IsA("Animation") then
					--CharacterAnimations[name][AnimObj.Name] = string.sub(AnimObj.AnimationId,14)
				end
			end
		end
		
		setanimationtableevent = function(side, folder)
			makeAnimTable(side, folder)
		end
		
		makeAnimTable("BF", Animations["BF"])
		makeAnimTable("Dad", Animations["Dad"])
		if SongIdInfo.BF2Animations then
			makeAnimTable("BF2", repS.Animations.CharacterAnims:FindFirstChild(SongIdInfo.BF2Animations and SongIdInfo.BF2Animations or repS.Animations.CharacterAnims.BF) or repS.Animations.CharacterAnims.BF)
		end
		if SongIdInfo.Dad2Animations then
			makeAnimTable("Dad2", repS.Animations.CharacterAnims:FindFirstChild(SongIdInfo.Dad2Animations and SongIdInfo.Dad2Animations or repS.Animations.CharacterAnims.Dad) or repS.Animations.CharacterAnims.Dad)
		end
		
		local opponent = module.PositioningParts.isOpponentAvailable -- this is the player on the other side of the stage
		local char = plr.Character

		local Animator = char.Humanoid:FindFirstChildOfClass("Animator")
		if Animator then
			local PlayingTracks = Animator:GetPlayingAnimationTracks()
			for _,Track in next,PlayingTracks do
				Track:Stop(0)
			end
		end

		local offsets = {CFrame.new(), CFrame.new(), CFrame.new(), CFrame.new()}
		
		-- Order of the characters that will be spawned
		local objectOrder = {"BF", "Dad", SongIdInfo.BF2Animations and "BF2" or nil, SongIdInfo.Dad2Animations and "Dad2" or nil};
		local charOrder = {BFChar, DadChar, SongIdInfo.BF2Animations, SongIdInfo.Dad2Animations};
		local sides = {"Left", "Right", "Left2", "Right2"};
		
		if SongIdInfo.ExtraAnimations then
			local i = 2
			local indexx = 5
			for name,animation in pairs(SongIdInfo.ExtraAnimations) do
				--print(name, animation)
				objectOrder[indexx] = name
				charOrder[indexx] = animation.Animation
				local newSide = animation.Side ..tostring(i)
				
				if not sides[animation.newSide] then
					table.insert(sides, newSide)
					if not module.PositioningParts[newSide] then
						module.PositioningParts[newSide] = Instance.new("Part")
						local newCFrame = module.PositioningParts[animation.Side].CFrame
						for a = 1, i-1 do
							if animation.Side == "Left" then
								newCFrame *= CFrame.new(3,0,-2)
							else
								newCFrame *= CFrame.new(-2,0,-2)
							end
						end
						--module.PositioningParts[newSide].Anchored = true
						--module.PositioningParts[newSide].Parent = workspace
						module.PositioningParts[newSide].CFrame = newCFrame
					end
				else
					module.PositioningParts.Left2.CFrame = module.PositioningParts.Left.CFrame * CFrame.new(3, 0, -2)
					module.PositioningParts.Right2.CFrame = module.PositioningParts.Right.CFrame * CFrame.new(-2, 0, -2)
				end
				makeAnimTable(name, repS.Animations.CharacterAnims:FindFirstChild(animation.Animation) or repS.Animations.CharacterAnims.Dad)
				indexx +=1;
				i+=1;
			end
		end
		
		module.PositioningParts.Left2.CFrame = module.PositioningParts.Left.CFrame * CFrame.new(3,0,-2)
		module.PositioningParts.Right2.CFrame = module.PositioningParts.Right.CFrame * CFrame.new(3,0,3)

		if SongIdInfo.AnimOffsets then
			offsets = SongIdInfo.AnimOffsets

			for i = 1, #offsets do
				module.PositioningParts[sides[i]].CFrame *= offsets[i]
			end
		end
		
		
		if SongIdInfo.BF2Animations then -- Moves the position a bit because the characters overlap a bit
			module.PositioningParts.Left.CFrame *= CFrame.new(-1.75, 0, 0.25)
		end
		
		-- What this does is make the characters for "BF" and "Dad", it's is designed to be scaleable so like if you had "Dad2" and "BF2" then it could work easier to add more than just 4
		if PlayerObjects then
			for _,char in pairs(PlayerObjects) do
				if char then
					char:Destroy()
				end
			end
		end
		setupcharacter = function(index, obj)
			if index == "objectorderfind" then
				print(obj)
				index = table.find(objectOrder, obj)
				print(index)
			end
			--print(index)
			--if (not Animations[obj]) then continue end
			if PlayerObjects then
				if PlayerObjects[obj] then
					PlayerObjects[obj]:Destroy()
				end
			end
			local player = module.PositioningParts.isPlayer[index]
			
			local description = nil
			local opponent = nil
			if player then
				description = player.Character.Humanoid:WaitForChild("HumanoidDescription") -- Retrieves the accessories of a character

				if not description then
					task.wait() -- Make it yield in case the description didn't load
				end

				if player == game.Players.LocalPlayer and module.PositioningParts.isOpponentAvailable then
					opponent = module.PositioningParts.isOpponentAvailable
				end
			end
			--print(module.PositioningParts[sides[index]])
			local Char = Character.new(charOrder[index], module.PositioningParts[sides[index]].CFrame, player == game.Players.LocalPlayer and player or nil, CharacterAnimations[obj], Animations[obj].Name, speedModifier, description, opponent)

			if not Char then
				warn("Character failed to spawn")
				return;
			end

			PlayerObjects[obj] = Char


			if not player then
				PlayerObjects[obj].Obj.Parent = workspace
			else
					--[[
					task.spawn(function()
						--print(string.format('%s is here', tostring(player.Name)))
						local serverRig = workspace:WaitForChild("ServerRig-" .. player.Name, 5)
						if serverRig then
							serverRig:Destroy()
						else
							warn(string.format('%s Server Rig not removed', tostring(player.Name)))
						end
					end)
					--]]
			end

			if index%2 == 0 then -- for every characters flip the direction, (so it would go like BF, Dad, BF, Dad, BF, Dad)
				Char:flipDir() -- this function swaps the left and right animations (used for characters on the left side)
			end

			if char then
				Char:ToggleAnimatorScript(false) -- Disables a roblox default script that handles animating player movement
			end

			
		end
		print(sides)
		for index,obj in pairs(objectOrder) do
			print(charOrder[index])
			if (not charOrder[index]) then continue end
			print(obj, index, sides[index], module.PositioningParts[sides[index]], charOrder[index])
			setupcharacter(index, obj)
		end
	end

	-- set the UI up
	if module.settings.MiddleScroll then
		DadNotesUI.Visible = false
		BFNotesUI.Visible = false
		BFBG.Visible = false
		DadBG.Visible = false
		local theUI = flipMode and DadNotesUI or BFNotesUI
		local theBG = flipMode and DadBG or BFBG
		theUI.Visible = true
		theUI.Position = UDim2.new(0.5,0,1,0)
		theUI.AnchorPoint = Vector2.new(0.5,1)
		theBG.Size = UDim2.fromScale((0.35 * ((shared.autoSize * shared.handler.settings.customSize)))*(DirAmmo[songData.mania]/4),0.95)
		theBG.BackgroundTransparency = module.settings.BackgroundTrans/100
		theBG.Visible = true
		theBG.Position = UDim2.new(0.5,0,1,0)
		theBG.AnchorPoint = Vector2.new(0.5,1)
	elseif module.settings.hideOppArrows then
		DadNotesUI.Visible = false
		BFNotesUI.Visible = false
		BFBG.Visible = false
		DadBG.Visible = false
		local theUI = flipMode and DadNotesUI or BFNotesUI
		local theBG = flipMode and DadBG or BFBG
		theUI.Visible = true
		theBG.BackgroundTransparency = module.settings.BackgroundTrans/100
		theBG.Visible = true
	else
		DadNotesUI.Visible = true
		BFNotesUI.Visible = true
		BFBG.Visible = true
		DadBG.Visible = true

		BFNotesUI.Position = UDim2.new(0.95,0,1,0)
		BFNotesUI.AnchorPoint = Vector2.new(1,1)
		DadNotesUI.Position = UDim2.new(0.05,0,1,0)
		DadNotesUI.AnchorPoint = Vector2.new(0,1)

		BFBG.Position = UDim2.new(0.95,0,1,0)
		BFBG.AnchorPoint = Vector2.new(1,1)
		BFBG.Size = UDim2.fromScale((0.35 * ((shared.autoSize * shared.handler.settings.customSize)))*(DirAmmo[songData.mania]/4),0.95)
		BFBG.BackgroundTransparency = module.settings.BackgroundTrans/100
		DadBG.Position = UDim2.new(0.05,0,1,0)
		DadBG.AnchorPoint = Vector2.new(0,1)
		DadBG.Size = UDim2.fromScale((0.35 * ((shared.autoSize * shared.handler.settings.customSize)))*(DirAmmo[songData.mania]/4),0.95)
		DadBG.BackgroundTransparency = module.settings.BackgroundTrans/100
	end

	DadNotesUI:ClearAllChildren()
	BFNotesUI:ClearAllChildren()
	
	-- Attributes stuff
	for Name,Value in next,songName:GetAttributes() do
		if attributeFunctions[Name] then
			attributeFunctions[Name](Value)
		end
	end

	local noteGroup = SongIdInfo.NoteGroup or songName:GetAttribute('noteGroup') or 'Default'
	
	if(#modcharts > 0 or cutscene)then  -- Modchart Variables
		local vars = {
			flipMode=flipMode;
			defaultcamzoom=1 + defaultCamZoom;
			--[[
			p1 = (flipMode and PlayerObjects.BF or PlayerObjects.Dad);
			p2 = (flipMode and PlayerObjects.Dad or PlayerObjects.BF);
			dad=PlayerObjects.Dad;
			dad2=PlayerObjects.Dad2;
			bf=PlayerObjects.BF;         Those are old ones that dont work with new character system properly
			bf2=PlayerObjects.BF2;
			]]--
			playerObjects=PlayerObjects;
			playerNoteOffsets=playerNoteOffsets;
			opponentNoteOffsets=opponentNoteOffsets;
			playSound=playSound;
			leftStrums=leftStrums;
			rightStrums=rightStrums;
			dadStrums=dadStrums;
			playerStrums=playerStrums;
			allReceptors=allReceptors;
			camControls=camControls;
			internalSettings=internalSettings;
			gameUI=gameUI;
			gameHandler=module;
			unspawnedNotes=unspawnedNotes;
			notes=notes;
			noteLanes=noteLanes;
			susNoteLanes=susNoteLanes;
			noteGroup=noteGroup;
			initialSpeed=initialSpeed;
			mapProps=mapProps;
			playbackRate=speedModifier;
			plrStats = module.PlayerStats,
			HideNotes = function(hide:boolean, side:string, hideReceptors:boolean, speed)
				local oldThing = internalSettings.notesShareTransparencyWithReceptors
				local noteStuff
				local receps
				if side == "left" then
					noteStuff = flipMode
					receps = leftStrums
				elseif side == "right" then
					noteStuff = not flipMode
					receps = rightStrums
				elseif side == "both" then
					noteStuff = nil
					receps = allReceptors
				end

				speed = speed or 1

				task.spawn(function()
					local trans = 0
					local elapsed = 0
					local To = hide and 1 or 0
					local From = hide and 0 or 1
					if hideReceptors then
						internalSettings.notesShareTransparencyWithReceptors = true
					end
					--if side == "both" then
					--	internalSettings.NoteSpawnTransparency = trans -- This makes any spawning notes transparency
					--end
					repeat
						elapsed += HB:Wait()
						trans = numLerp(From, To, elapsed/speed) -- Lerp I guess
						if elapsed > speed then
							trans = To
						end
						if hideReceptors == true then -- Having it hide the receptors make everything so much easier
							for _,receptor in pairs(receps) do
								receptor.Alpha = math.abs(1-trans)
							end
						end
						for _,note in pairs(notes) do
							if not noteStuff or (note.MustPress == noteStuff) then
								note.Transparency = trans
							end
						end
						for _,note in pairs(unspawnedNotes) do
							if not noteStuff or (note.MustPress == noteStuff) then
								note.Transparency = trans
							end
						end
					until elapsed>speed or songEnded
					--internalSettings.notesShareTransparencyWithReceptors = oldThing or false
				end)
			end,
			MoveCamera = function(position:CFrame) -- Moves the camera to the desired position (CFrame value)
				-- Define The Previous Values
				local stayedOnCenter = camControls.StayOnCenter
				local disabledLerp = camControls.DisableLerp
				-- Set this stuff to this so that the camera moves instantly
				camControls.DisableLerp = true
				camControls.StayOnCenter = true
				module.PositioningParts.Camera.CFrame = position
				targetCam = position
				delay(0.2, function()
					-- Return stuff to the previous value
					camControls.DisableLerp = disabledLerp
					camControls.StayOnCenter = stayedOnCenter
				end)
			end,
			addSprite = function(tag:string, image:string, parent) -- Makes a sprite that will cover the screen with defined image
				local newSprite = repS.Assets.Images.Overlay:Clone()
				if typeof(image) ~= "Color3" then -- if it is a Color3 value then make change the background color
					newSprite.Image = image
				else
					newSprite.BackgroundColor3 = image
				end

				newSprite.Name = tag
				newSprite.Parent = parent or gameUI.realGameUI.waste

				return newSprite
			end;
			-- This is helpful for people who don't want to be calculating everything
			addAnimatedSprite = function(image:ImageLabel, visible:boolean, parent:Instance)
				-- Adding animated sprites is no simple matter so I am making all these checks to ensure people are following the right steps to make it work
				if not image or not image:IsA("ImageLabel") then warn('Where the Image Label at?') return end
				local img = image:Clone()
				local sizeData = img:GetAttribute("SpriteSize") -- This is required
				if not sizeData then
					warn('ImageLabel Lacks The "SpriteSize" Vector2 Attribute') -- Adding this for people who don't read documentation
					return
				end
				local bigSizeData = img:GetAttribute("SpriteSheetSize") -- This is also required
				if not bigSizeData then
					warn('ImageLabel Lacks The "SpriteSheetSize" Vector2 Attribute')
					return
				end
				-- The factor is equal to roblox's image size limit which is 1024x1024
				local largerSize = bigSizeData.X >= bigSizeData.Y and bigSizeData.X or bigSizeData.Y
				-- The Vector2 is equal to the size of the frame multiplied by the size of the ImageLabel
				local factor = largerSize/1024
				if factor < 1 then
					factor = 1
				end
				local animSprite = Sprite.new(img, true, factor, true, {X=sizeData.X/img.Size.X.Scale, Y=sizeData.Y/img.Size.Y.Scale})
				animSprite.GUI.Visible = visible or true
				img.Parent = parent or gameUI.realGameUI
				return animSprite
			end,
		}
		for i = 1, #modcharts do
			table.insert(loadedModchartData, require(modcharts[i]));
			table.insert(loadedModchartData[i], modcharts[i].Name)
			for _,v in next, loadedModchartData[i] do
				if(typeof(v)=='function')then
					local orig = getfenv(v);
					local env = setmetatable({},{
						__index=function(s,i)
							return vars[i] or orig[i];
						end,
					})
					setfenv(v,env)
				end
			end
			if(loadedModchartData[i]) and loadedModchartData[i].preInit then
				loadedModchartData[i].preInit(gameUI,module)
			end
		end
		for i = 1, #modcharts do
			table.insert(loadedModchartData, require(modcharts[i]));
			table.insert(loadedModchartData[i], modcharts[i].Name)
			for _,v in next, loadedModchartData[i] do
				if(typeof(v)=='function')then
					local orig = getfenv(v);
					local env = setmetatable({},{
						__index=function(s,i)
							return vars[i] or orig[i];
						end,
					})
					setfenv(v,env)
				end
			end
			if(loadedModchartData[i]) and loadedModchartData[i].preInit then
				loadedModchartData[i].preInit(gameUI,module)
			end
		end
		if cutscene then
			loadedCutscene = require(cutscene)
			for _,v in next, loadedCutscene do
				if(typeof(v)=='function')then
					local orig = getfenv(v);
					local env = setmetatable({},{
						__index=function(s,i)
							return vars[i] or orig[i];
						end,
					})
					setfenv(v,env)
				end
			end
			if loadedCutscene and loadedCutscene.Preload then
				loadedCutscene.Preload();
			end
		end
	else
		loadedModchartData = {}
	end
	do
		local curBPM = songData.bpm;
		local steps = 0;
		local pos = 0;

		for i = 1, #songData.notes do
			local section = songData.notes[i];
			if(section.changeBPM and section.bpm ~= curBPM)then
				curBPM = section.bpm;
				table.insert(bpmChangePoints,{
					stepTime = steps;
					songTime=pos;
					bpm=curBPM;
				})
				table.insert(Conductor.bpmChangeMap,{
					stepTime = steps;
					songTime=pos;
					bpm=curBPM;
				})
			end
			local deltaSteps = section.lengthInSteps or 16;
			steps+=deltaSteps;
			pos+= ((60/curBPM)*1000/4)*deltaSteps;
		end
	end
	
	local maniac = keyAmmo[songData.mania+1]
	
	-- preload the notes
	local ScriptProcessor = repS.Modules.ChartProcessors:FindFirstChild(SongIdInfo.ChartProcessorName or "")
	if ScriptProcessor and ScriptProcessor:IsA("ModuleScript") then
		require(ScriptProcessor)(unspawnedNotes,notesData,songData,internalSettings,flipMode,{
			bCP = bpmChangePoints;
			HB = HB;
			LS = LoadingStatus;
			mania = maniac;
			nG = noteGroup;
			NXML = NoteXml;
			NO = NoteObject;
			BFUI = BFNotesUI;
			DadUI = DadNotesUI;
			gPFT = getPosFromTime;
			cS = module.settings.customSize;
			module = songName;
			rngSeed = module.PositioningParts.Spot:GetAttribute("randomSeed")
		})
	else -- use the default one
		local idx=0;
		local currentBPM = songData.bpm
		local totalSteps,totalPos = 0,0
		for _,section in next, notesData do
			idx+=1
			if(idx%8==0)then
				HB:wait()
			end
			LoadingStatus.SectionCount += 1
			if section.lengthInSteps == nil then section.lengthInSteps = 16 end
			LoadingStatus.DataNotes = #section.sectionNotes
			local length = section.lengthInSteps/4
			local idx2 = 0
			local lastNoteData
			local dType = section.dType or 0
			local deltaSteps = section.lengthInSteps
			for _,songNotes in next, section.sectionNotes do
				idx2+=1
				if(idx2%8==0)then
					HB:wait()
				end
				LoadingStatus.DataNotes -= 1
				local strumTime=songNotes[1]
				local noteData=songNotes[2]
				if type(songNotes[3]) == "number" then -- HANDLE EVENT SHIT
					local gottaHit = section.mustHitSection 

					if songNotes[2]%(maniac*2)>=maniac then
						gottaHit= not section.mustHitSection
					end

					if(flipMode) then gottaHit = not gottaHit end
					local oldNote:Note=nil;
					if(#unspawnedNotes>0)then
						oldNote = unspawnedNotes[#unspawnedNotes]
					end
					-- init arrow obj

					local swagNote:Note
					if internalSettings.useDuoSkins then
						swagNote = NoteClass.new((gottaHit ~= flipMode) and NoteXml.BF or NoteXml.Dad,(gottaHit ~= flipMode) and internalSettings.useDuoSkins.BF or internalSettings.useDuoSkins.Dad,strumTime,songNotes, songData.mania,noteGroup,noteData,oldNote)
					else
						swagNote = NoteClass.new(NoteXml,NoteObject,strumTime,songNotes, songData.mania,noteGroup,noteData,oldNote)
					end
					swagNote.MustPress=gottaHit
					swagNote.InitialPos = getPosFromTime(swagNote.StrumTime);
					local Side = 'Right';
					if(flipMode and swagNote.MustPress or not flipMode and not swagNote.MustPress)then
						Side='Left';
					elseif(flipMode and not swagNote.MustPress or not flipMode and swagNote.MustPress ) then
						Side='Right'
					end

					swagNote.Side= Side;
					swagNote.Parent=swagNote.Side=='Left' and DadNotesUI or BFNotesUI
					swagNote.SustainLength = songNotes[3]
					swagNote.dType = dType


					--swagNote.NoteMode = songData.mania
					local WHENTHEIMPOSTORISLENGTH = swagNote.SustainLength/Conductor.stepCrochet

					table.insert(unspawnedNotes,swagNote)

					--local visualSustain = visSus:Clone()
					--visualSustain.Size=swagNote.NoteObject.Size
					local SusSize=0;
					if(swagNote.CanSustain==false)then WHENTHEIMPOSTORISLENGTH=0 swagNote.SustainLength=0 end
					if(math.floor(WHENTHEIMPOSTORISLENGTH)>0)then
						for WHENTHEIMPOSTORISNOTE = 0,math.floor(WHENTHEIMPOSTORISLENGTH)-1 do
							oldNote = unspawnedNotes[#unspawnedNotes]

							local impostorNote:Note -- = NoteClass.new(NoteXml,NoteObject,strumTime+(Conductor.stepCrochet*WHENTHEIMPOSTORISNOTE)+Conductor.stepCrochet,songNotes,songData.mania,noteGroup,noteData,oldNote,true)
							if internalSettings.useDuoSkins then
								impostorNote = NoteClass.new((gottaHit ~= flipMode) and NoteXml.BF or NoteXml.Dad,(gottaHit ~= flipMode) and internalSettings.useDuoSkins.BF or internalSettings.useDuoSkins.Dad,strumTime+(Conductor.stepCrochet*WHENTHEIMPOSTORISNOTE)+Conductor.stepCrochet,songNotes, songData.mania,noteGroup,noteData,oldNote,true)
							else
								impostorNote = NoteClass.new(NoteXml,NoteObject,strumTime+(Conductor.stepCrochet*WHENTHEIMPOSTORISNOTE)+Conductor.stepCrochet,songNotes,songData.mania,noteGroup,noteData,oldNote,true)
							end
							--impostorNote.NoteObject.Visible=false
							table.insert(unspawnedNotes,impostorNote)
							impostorNote.MustPress=gottaHit
							impostorNote.Side= swagNote.Side
							impostorNote.InitialPos = getPosFromTime(impostorNote.StrumTime);
							impostorNote.Scale.Y /= (internalSettings.autoSize * module.settings.customSize)
							impostorNote.Parent= (impostorNote.MustPress ~= flipMode) and BFNotesUI or DadNotesUI
							impostorNote.dType = dType
						--[[
						if(impostorNote.MustPress) then
							impostorNote.Parent=BFNotesUI
						end--]]

							--SusSize+=impostorNote.NoteObject.AbsoluteSize.Y
							--B=impostorNote;
						end
					end
					LoadingStatus.LoadedNotes +=1
					lastNoteData = songNotes
				elseif type(songNotes[3]) == "string" and songNotes[2] == -1 then -- Treat it as an Psych event
					local eventData = {
						songNotes[1];
						{{songNotes[3], unpack(songNotes,4)}};
					}

					if #events > 0 then -- hopefully this fixes that issue FOREVER
						if events[1]["song"]["events"] then
							table.move({eventData}, 1, #eventData, #events[1]["song"]["events"]+1, events[1]["song"]["events"])
							--table.insert(events[1]["song"]["events"][#events+1], eventData)
						end
						--if table.find(events[1]["song"], "events") then
						--	events[1]["song"]["events"][#events[1]] = eventData
						--else
						--	print(eventData)

						--	--events[1]["song"]["events"][#events[1]+1]["song"]["events"] = eventData
						--end

					else

						table.insert(events, {song = {events = {eventData}}})
						--print(events)
					end
				end
			end
		end
	end

	if repS.Modules.Modcharts:FindFirstChild(songData.song) then
		if repS.Modules.Modcharts[songData.song]:FindFirstChild("event") then
			local thing = require(repS.Modules.Modcharts[songData.song].event)
			table.insert(events, HS:JSONDecode(thing))
		end
	end

	if songName:FindFirstChild("event") then
		local thing = require(songName.event)
		table.insert(events, HS:JSONDecode(thing))
	end

	local processEvent = function (event, value1, value2,...)
		local curEvent = typeof(event) == "table" and string.lower(event[1]) or string.lower(event)	

		if curEvent == "set camera zoom" then
			--camControls.BehaviourType = "Camera"
			--camControls.BehaviourType = "Separate"
			camControls.zoom = tonumber(value1) or 0
			camControls.hudZoom = value2~=nil and tonumber(value2) or 0
			--camControls.BehaviourType = "All"
		elseif curEvent == "tween camera zoom" then
			local camZoom = 1 - tonumber(value1) or 0
			local length = tonumber(value2) or 0.1
			--defaultCamZoom = 1 - camZoom
			if ... == nil then
				CameraTween = TS:Create(game.Workspace.Camera,TweenInfo.new(length,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{FieldOfView=70-(camZoom*25)})
			else
				CameraTween = TS:Create(game.Workspace.Camera,TweenInfo.new(length, ...),{FieldOfView=70-(camZoom*25)})
			end

			--defaultCamZoom = 1 - camZoom
			CameraTween:Play()
			CameraTween.Completed:Connect(function()
				defaultCamZoom = camZoom
				camControls.hudZoom = camZoom
				CameraTween = nil
			end)
			return CameraTween
		elseif curEvent == "hey!" then
			local value = 2
			Switch()
				:case('bf' or 'boyfriend' or '0', function()
					value = 0
				end)
				:case('gf' or 'girlfriend' or '1', function()
					value = 1
				end)(string.lower(value1))
			if value == 0 then
				local char = PlayerObjects.BF
				char:PlayAnimation("hey", true)
			else
				-- do somethin 
			end
		elseif curEvent == "add camera zoom" then
			if module.settings.CameraZooms and camControls.hudZoom < 1.4 then
				camControls.hudZoom += tonumber(value1) or 0.03
				camControls.camZoom += tonumber(value2) or 0.015
			end
		elseif curEvent == "play animation" then
			local char = PlayerObjects.Dad; -- Marker
			Switch()
			:case('bf' or 'boyfriend', function()
				char = PlayerObjects.BF;
			end)
			:case('gf' or 'grilfriend', function()
				char = PlayerObjects.GF or nil;
				-- Girlfriend is not a character
				-- return
			end)
			:default(function()
				local var2 = value2
				if var2 == nil then var2 = "BF" end
					
				char = PlayerObjects[var2]
			end)(string.lower(value2))
			
			if char ~= nil then
				char:PlayAnimation(string.lower(value1), true);
				-- char.specialAnim = true; -- This also doesn't exist
			end
		elseif curEvent == "camera follow pos" then
			if camFollow ~= nil then
				local val1 = tonumber(value1) or 0
				local val2 = tonumber(value2) or 0

				--camControls.ForcedPos = false
				if val1 ~= 0 and val2 ~= 0 then
					camControls.camOffset = CFrame.new(math.rad(val1/10),math.rad(val2/10), 0)
					--camControls.ForcedPos = true
					--print(camControls.camOffset.X .. ', ' .. camControls.camOffset.Y)
				end
			end
		elseif curEvent == "screen shake" then -- supposed to shake UI as well
			-- how screen shake works if value 1 and 2 is double
			-- value1 [1] -> duration (shakeScreen)
			-- value1 [2] -> intensity (shakeScreen)
			
			-- value2 [1] -> duration (shakeUI)
			-- value2 [2] -> intensity (shakeUI)
			
			--print("screen shaked at "..value1.." intensity for "..value2.." seconds") value1 can either be one number or two numbers separated by a comma
			local split
			local split2 = {0, 0}
			if value2 == nil then
				value2 = '0, 0'
			end
			if string.find(value2, ',') then
				split2 = string.split(value2, ',')
				-- [1] duration (shakeUI)
				-- [2] intensity (shakeUI)
			end
			if string.find(value1, ',') then
				split = string.split(value1, ',')
				value1 = split[1] -- duration (shakeScreen)
				value2 = split[2] -- intensity (shakeScreen)
			else
				value1 = tonumber(value1) -- duration (shakeScreen)
				value2 = tonumber(value2) -- intensity (shakeScreen)
			end
			
			-- ShakeScreen
			local duration = tonumber(value1) / speedModifier or 0
			local intensity = tonumber(value2) * 1000 or 0
			
			-- ShakeUI
			local dur2 = tonumber(split2[1]) / speedModifier or 0
			local inten2 = camSizeX*tonumber(split2[2]) or 0

			if duration > 0 and intensity ~= 0 then
				spawn(function()
					-- Screen shake was too intense so I am adjusting values
					shakeScreen(intensity/0.9, duration)
				end)
			end

			if dur2 > 0 and inten2 ~= 0 then
				spawn(function()
					shakeUI(inten2, dur2)
				end)
			end
		elseif curEvent == "change scroll speed" then --['Change Scroll Speed', "Value 1: Scroll Speed Multiplier (1 is default)\nValue 2: Time it takes to change fully in seconds."],
			if not module.settings.ForceSpeed then
				local duration = (tonumber(value2) or 0)/speedModifier
				local newSpeed = (module.settings.CustomSpeed * tonumber(value1) or 1)
				local songSpeedTween = ((initialSpeed/.45)/songData.speed) * module.settings.CustomSpeed
				local elapsed = 0
				if duration <= 0 then -- Change speed instantly
					initialSpeed = songData.speed * .45 * newSpeed--newSpeed
					for i = 1, #unspawnedNotes do
						unspawnedNotes[i].InitialPos = getPosFromTime(unspawnedNotes[i].StrumTime)
					end
					for i = 1, #notes do
						notes[i].InitialPos = getPosFromTime(notes[i].StrumTime)
					end
				else
					spawn(function()
						while elapsed < duration and not songEnded do
							songSpeedTween = numLerp(songSpeedTween, newSpeed, elapsed / duration)
							initialSpeed = (songData.speed * .45 * songSpeedTween)
							for i = 1, #unspawnedNotes do
								unspawnedNotes[i].InitialPos = getPosFromTime(unspawnedNotes[i].StrumTime)
							end
							for i = 1, #notes do
								notes[i].InitialPos = getPosFromTime(notes[i].StrumTime)
							end
							elapsed += RS.RenderStepped:Wait()
						end
					end)
				end
			end
		elseif curEvent == "set cam speed" then
			camSpeed = tonumber(value1) or 1
		--[[elseif curEvent == "cam boom speed" then -- this was only used by one thing and is not needed
			boomSpeed = tonumber(value1) or 4
			local bam = tonumber(value2) or 1]]
		elseif curEvent == "camera flash" then
			if module.settings.distractions then
				if value2 == '' or value2 == nil then
					value2 = '#FFFFFF'
				end
				module.flash(tostring(value2), tonumber(value1) or 1, 0)
			end
		elseif curEvent == "lane modifier" then
			local lane = tonumber(value1)
			local speed = tonumber(value2)/speedModifier
			--print("Lane "..lane.." was modified to "..speed)
			local indx = 0
			for i =1, #notes do
				if notes[i].NoteData == lane then
					notes[i].ScrollMultiplier = speed
				end
				notes[i].InitialPos = getPosFromTime(notes[i].StrumTime)
			end
			for i =1, #unspawnedNotes do
				if unspawnedNotes[i].NoteData == lane then
					unspawnedNotes[i].ScrollMultiplier = speed
				end
				unspawnedNotes[i].InitialPos = getPosFromTime(unspawnedNotes[i].StrumTime)
			end
		
		elseif curEvent == "change character" then
			if game.ReplicatedStorage.Animations.CharacterAnims:FindFirstChild(value2) then
				setanimationtableevent(value1, game.ReplicatedStorage.Animations.CharacterAnims:FindFirstChild(value2))
				setupcharacter("objectorderfind", value1)
				local g = value1
				if g == "BF" then g = true else g = false end
				module.changeIcon(value2, g)
			end
		elseif curEvent == "change map" then
			if value1 and repS.Maps:FindFirstChild(value1) then
				mapProps:Destroy()
				local map = repS.Maps[value1]
				local Floor = module.PositioningParts.Spot:FindFirstChild('Floor')
				mapProps = map:Clone()
				mapProps.Parent = workspace
				local povit = Floor:GetPivot()
				mapProps:PivotTo(povit)
				local Props = game.workspace.BaseMap:GetChildren()
				for i = 1, #Props do
					Props[i].Parent = game.ReplicatedStorage.HiddenMaps
				end
				if SongIdInfo.hideProps then
					local Props2 = game.Workspace.Props:GetChildren()
					for i = 1, #Props2 do
						Props2[i].Parent = game.ReplicatedStorage.HiddenProps
					end
				end
			end
		end

		for i,v in pairs(loadedModchartData) do -- marker
			coroutine.resume(coroutine.create(function(...)
				if v.EventTrigger then
					v.EventTrigger(curEvent, value1, value2, ...)
				end
			end))
		end
	end
	module.processEvent = processEvent
	for i = 1, #loadedModchartData do
		if loadedModchartData[i].init then
			loadedModchartData[i].init()
		end
	end
	table.sort(unspawnedNotes,function(a,b)
		return a.StrumTime<b.StrumTime
	end)
	
	-- I should instead preload images by making decals behind the loading screen
	if SongIdInfo.PreloadImages then
		local function makePreloadingImage(name, imageId, location)
			local newImage = Instance.new("ImageLabel")
			newImage.ZIndex = 4
			newImage.Image = tostring(imageId)
			newImage.Parent = location
			newImage.Size = UDim2.new(.1, 0, .1, 0) -- Small
			newImage.Visible = true

			local waitTime = 0
			
			--[[
			while waitTime > .8 do -- Waits at least .8 seconds (not sure what the optimal time is though)
				waitTime += HB:Wait()
			end
			--]]
			
			game:GetService("ContentProvider"):PreloadAsync({newImage})
			
			repeat 
				waitTime += HB:Wait()
			until waitTime > 2 or newImage.IsLoaded == true

			LoadingStatus.PreloadedImages+=1; -- Track that an image loaded
			newImage:Destroy()
		end

		for i,v in pairs(SongIdInfo.PreloadImages) do
			makePreloadingImage(tostring(i), v, gameUI.realGameUI.Flash)
		end
		-- Old system that doesn't do much good...
		--[[
		game:GetService('ContentProvider'):PreloadAsync(SongIdInfo.PreloadImages, function()
			LoadingStatus.PreloadedImages+=1
		end)
		]]
	end
	
	-- This preload system works well
	if SongIdInfo.PreloadSounds then
		for i = 1, #SongIdInfo.PreloadSounds do
			playSound(SongIdInfo.PreloadSounds[i], 0.0001)
		end
	end

	if SongIdInfo.CameraPlayerFocus then
		module.PositioningParts.CameraPlayer = true
	end

	instrSound.SoundId='rbxassetid://' .. SongIdInfo.Instrumental
	instrSound.PlaybackSpeed = SongIdInfo.InstrumentalSpeed or 1
	if(songData.needsVoices and SongIdInfo.Voices~=0 and SongIdInfo.Voices)then
		voiceSound.SoundId='rbxassetid://' .. SongIdInfo.Voices
	else
		voiceSound.SoundId=''
		songData.needsVoices=false
	end
	instrSound.Volume = (SongIdInfo.InstrumentalVolume or 2)*(module.settings.SongVolume/100)
	voiceSound.Volume = (SongIdInfo.VoiceVolume or 2)*(module.settings.SongVolume/100)
	voiceSound:Stop()
	voiceSound:Stop()
	voiceSound.TimePosition=0
	instrSound.TimePosition=0
	LoadingStatus.DoneLoading = true;
	generatedSong=true

	-- preupdate the UI
	local DSPos 
	if Conductor.Downscroll then
		DSPos = UDim.new(0.1,0)
	else
		DSPos = UDim.new(0.95,0)
	end
	BFIcon.GUI.AnchorPoint = Vector2.new(0.2,2/3)
	DadIcon.GUI.AnchorPoint = Vector2.new(0.8,2/3)
	HPBarBG.Position = UDim2.new(UDim.new(0.5,0),DSPos)
	HPBarBG.Visible = true
	BFIcon.GUI.Visible = true
	DadIcon.GUI.Visible = true
	updateUI()
end

function module.playCutscene(name)
	if loadedCutscene then
		if loadedCutscene[name] then
			loadedCutscene[name](); -- Play whatever the cutscene is
		end
	else
		warn('There Aint No Cutscene')
	end
end

function updateUI()
	local scale = HPBarBG.Size.X.Scale*HPContainer.Size.X.Scale
	local normalHP = module.PlayerStats.Health/module.PlayerStats.MaxHealth
	local center = ((1-HPBarBG.Size.X.Scale) + (HPBarBG.Size.X.Scale * (HPContainer.Size.X.Scale/0.98)))/2
	local bfoffset = gameUI.realGameUI.Notes.BF:GetAttribute("Offset") or CFrame.new() -- you can define this offset inside of a modchart using :SetAttribute("Offset", Vector3)
	local dadoffset = gameUI.realGameUI.Notes.Dad:GetAttribute("Offset") or CFrame.new()
	if flipMode then
		HPBarG.Size = UDim2.fromScale((1-normalHP),1)
		HPBarR.Size = UDim2.fromScale(normalHP,1)
		BFIcon.GUI.Position = UDim2.new(center-(0.5-normalHP)*scale, bfoffset.X,HPBarBG.Position.Y.Scale, bfoffset.Y)
		DadIcon.GUI.Position = UDim2.new(center-(0.5-normalHP)*scale, dadoffset.X, HPBarBG.Position.Y.Scale, dadoffset.Y)
		BFIcon:UpdateSize()
		DadIcon:UpdateSize()
	else
		HPBarR.Size = UDim2.fromScale((1-normalHP),1)
		HPBarG.Size = UDim2.fromScale(normalHP,1)
		BFIcon.GUI.Position = UDim2.new(center+(0.5-normalHP)*scale, bfoffset.X, HPBarBG.Position.Y.Scale, bfoffset.Y)
		DadIcon.GUI.Position = UDim2.new(center+(0.5-normalHP)*scale, dadoffset.X, HPBarBG.Position.Y.Scale, dadoffset.Y)
		BFIcon:UpdateSize()
		DadIcon:UpdateSize()
	end
end

function module.changeIcon(name,side) -- false:dad  true:bf
	local DadAssetInfo = Icons[name] or Icons.Face
	local BFAssetInfo = Icons[name] or Icons.BF
	if side == false then
		DadIcon.Animations = {}
		DadIcon.CurrAnimation = nil;
		DadIcon.AnimData.Looped = false
		if DadAssetInfo.NormalXMLArgs then
			DadIcon:AddSparrowXML(DadAssetInfo.NormalXMLArgs[1],"Alive",unpack(DadAssetInfo.NormalXMLArgs,2)).ImageId = DadAssetInfo.NormalId
			for i = 1, #DadIcon.Animations.Alive.Frames do
				DadIcon.Animations.Alive.Frames[i].FrameSize = DadAssetInfo.NormalDimensions
			end
		else
			DadIcon:AddAnimation("Alive",{{
				Size = DadAssetInfo.NormalDimensions;
				FrameSize = DadAssetInfo.NormalDimensions;
				Offset = DadAssetInfo.OffsetAlive or Vector2.new();
			}},1,true,DadAssetInfo.NormalId)
		end
		-- Dead
		if DadAssetInfo.DeadXMLArgs then
			DadIcon:AddSparrowXML(DadAssetInfo.DeadXMLArgs[1],"Dead",unpack(DadAssetInfo.DeadXMLArgs,2)).ImageId = DadAssetInfo.DeadId
			for i = 1, #DadIcon.Animations.Dead.Frames do
				DadIcon.Animations.Dead.Frames[i].FrameSize = DadAssetInfo.DeadDimensions
			end
		elseif DadAssetInfo.NormalXMLArgs then
			DadIcon:AddSparrowXML(DadAssetInfo.NormalXMLArgs[1],"Dead",unpack(DadAssetInfo.NormalXMLArgs,2)).ImageId = DadAssetInfo.NormalId
			for i = 1, #DadIcon.Animations.Dead.Frames do
				DadIcon.Animations.Dead.Frames[i].FrameSize = DadAssetInfo.NormalDimensions
			end
		else
			DadIcon:AddAnimation("Dead",{{
				Size = (DadAssetInfo.DeadDimensions or DadAssetInfo.NormalDimensions);
				FrameSize = (DadAssetInfo.DeadDimensions or DadAssetInfo.NormalDimensions);
				Offset = DadAssetInfo.OffsetDead or Vector2.new();
			}},1,true,DadAssetInfo.DeadId or DadAssetInfo.NormalId)
		end
		-- Winning
		if DadAssetInfo.WinningXMLArgs then
			DadIcon:AddSparrowXML(DadAssetInfo.WinningXMLArgs[1],"Winning",unpack(DadAssetInfo.WinningXMLArgs,2)).ImageId = DadAssetInfo.WinningId
			for i = 1, #DadIcon.Animations.Winning.Frames do
				DadIcon.Animations.Winning.Frames[i].FrameSize = DadAssetInfo.WinningDimensions
			end
		elseif DadAssetInfo.NormalXMLArgs then
			DadIcon:AddSparrowXML(DadAssetInfo.NormalXMLArgs[1],"Winning",unpack(DadAssetInfo.NormalXMLArgs,2)).ImageId = DadAssetInfo.NormalDimensions
			for i = 1, #DadIcon.Animations.Winning.Frames do
				DadIcon.Animations.Winning.Frames[i].FrameSize = DadAssetInfo.NormalDimensions
			end
		else
			DadIcon:AddAnimation("Winning",{{
				Size = (DadAssetInfo.WinningDimensions or DadAssetInfo.NormalDimensions);
				FrameSize = (DadAssetInfo.WinningDimensions or DadAssetInfo.NormalDimensions);
				Offset = DadAssetInfo.OffsetWinning or Vector2.new();
			}},1,true,DadAssetInfo.WinningId or DadAssetInfo.NormalId)
		end
		DadIcon:PlayAnimation("Alive")
		DadIcon:ResetAnimation()
		DadIcon.Scale = Vector2.new(0.75, 0.75)
		DadIcon.GUI.ResampleMode = DadAssetInfo.IsPixelated and Enum.ResamplerMode.Pixelated or Enum.ResamplerMode.Default
		HPBarR.BackgroundColor3 = module.settings.IconColors and DadAssetInfo.IconColor or Color3.fromRGB(255,0,0)
	else
		BFIcon.Animations = {}
		BFIcon.CurrAnimation = nil;
		BFIcon.AnimData.Looped = false
		if BFAssetInfo.NormalXMLArgs then
			BFIcon:AddSparrowXML(BFAssetInfo.NormalXMLArgs[1],"Alive",unpack(BFAssetInfo.NormalXMLArgs,2)).ImageId = BFAssetInfo.NormalId
			for i = 1, #BFIcon.Animations.Alive.Frames do
				BFIcon.Animations.Alive.Frames[i].FrameSize = BFAssetInfo.NormalDimensions
			end
		else
			BFIcon:AddAnimation("Alive",{{
				Size = BFAssetInfo.NormalDimensions;
				FrameSize = BFAssetInfo.NormalDimensions;
				Offset = BFAssetInfo.OffsetNormal or Vector2.new();
			}},1,true,BFAssetInfo.NormalId)
		end
		-- Dead
		if BFAssetInfo.DeadXMLArgs then
			BFIcon:AddSparrowXML(BFAssetInfo.DeadXMLArgs[1],"Dead",unpack(BFAssetInfo.DeadXMLArgs,2)).ImageId = BFAssetInfo.DeadId
			for i = 1, #BFIcon.Animations.Dead.Frames do
				BFIcon.Animations.Dead.Frames[i].FrameSize = BFAssetInfo.NormalDimensions
			end
		elseif BFAssetInfo.NormalXMLArgs then
			BFIcon:AddSparrowXML(BFAssetInfo.NormalXMLArgs[1],"Dead",unpack(BFAssetInfo.NormalXMLArgs,2)).ImageId = BFAssetInfo.NormalId
			for i = 1, #BFIcon.Animations.Dead.Frames do
				BFIcon.Animations.Dead.Frames[i].FrameSize = BFAssetInfo.NormalDimensions
			end
		else
			BFIcon:AddAnimation("Dead",{{
				Size = (BFAssetInfo.DeadDimensions or BFAssetInfo.NormalDimensions);
				FrameSize = (BFAssetInfo.DeadDimensions or BFAssetInfo.NormalDimensions);
				Offset = BFAssetInfo.OffsetDead or Vector2.new();
			}},1,true,BFAssetInfo.DeadId or BFAssetInfo.NormalId)
		end
		-- Winning
		if BFAssetInfo.WinningXMLArgs then
			BFIcon:AddSparrowXML(BFAssetInfo.WinningXMLArgs[1],"Winning",unpack(BFAssetInfo.WinningXMLArgs,2)).ImageId = BFAssetInfo.WinningId
			for i = 1, #BFIcon.Animations.Winning.Frames do
				BFIcon.Animations.Winning.Frames[i].FrameSize = BFAssetInfo.WinningDimensions
			end
		elseif BFAssetInfo.NormalXMLArgs then
			BFIcon:AddSparrowXML(BFAssetInfo.NormalXMLArgs[1],"Winning",unpack(BFAssetInfo.NormalXMLArgs,2)).ImageId = BFAssetInfo.WinningId
			for i = 1, #BFIcon.Animations.Winning.Frames do
				BFIcon.Animations.Winning.Frames[i].FrameSize = BFAssetInfo.NormalDimensions
			end
		else
			BFIcon:AddAnimation("Winning",{{
				Size = (BFAssetInfo.WinningDimensions or BFAssetInfo.NormalDimensions);
				FrameSize = (BFAssetInfo.WinningDimensions or BFAssetInfo.NormalDimensions);
				Offset = BFAssetInfo.OffsetWinning or Vector2.new();
			}},1,true,BFAssetInfo.WinningId or BFAssetInfo.NormalId)
		end
		BFIcon:PlayAnimation("Alive")
		BFIcon:ResetAnimation()
		BFIcon.Scale = Vector2.new(0.75, 0.75)
		BFIcon.FlipHorizontally = true
		BFIcon.GUI.ResampleMode = BFAssetInfo.IsPixelated and Enum.ResamplerMode.Pixelated or Enum.ResamplerMode.Default
		HPBarG.BackgroundColor3 = (module.settings.IconColors and BFAssetInfo.IconColor or Color3.fromRGB(102, 255, 51))
	end
end

function module.changeAnimation(name,player,speed,looped,force)
	player:ChangeAnim(name, speedModifier)
	
	--[[
	if not module.settings.ForcePlayerAnim or force and repS.Animations.CharacterAnims:FindFirstChild(name) then
		local Animation = repS.Animations.CharacterAnims:FindFirstChild(name)
		local needsProps = Animation:GetAttribute("CharacterName")
		local props
		local micName

		if needsProps and repS.Characters[needsProps] then
			props = needsProps
		end

		player.AnimName = Animation.Name

		local animTable = {
			Offset = CFrame.new();
			MicPositioning = {};-- Can be an object as well.
		}

		for _,AnimObj in next,Animation:GetChildren() do
			if AnimObj:IsA("CFrameValue") and AnimObj.Name == "BFOffset" then
				animTable.Offset = AnimObj.Value
			elseif AnimObj:IsA("Folder") and AnimObj.Name == "MicPositioning" then
				for _,Obj in next,AnimObj:GetChildren() do
					animTable.MicPositioning[Obj.Name] = Obj.Value
				end
			elseif AnimObj:IsA("ObjectValue") or AnimObj:IsA('BoolValue') and AnimObj.Name == "MicPositioning" then
				animTable.MicPositioning = AnimObj.Value
			elseif AnimObj:IsA('StringValue') and AnimObj.Name == "Microphone" then
				micName = AnimObj.Value
			elseif AnimObj:IsA("Animation") then
				animTable[AnimObj.Name] = string.sub(AnimObj.AnimationId,14)
			end
		end

		if player.IsPlayer then
			player.MicPositions = animTable.MicPositioning
		end

		for _,Track in next,player.Animator:GetPlayingAnimationTracks() do
			Track:Stop(0)
		end

		if(animTable.DanceLeft and animTable.DanceRight)then
			player.BeatDancer=true;
			player:AddAnimation("danceLeft",animTable["DanceLeft"],speedModifier,true,Enum.AnimationPriority.Idle)
			player:AddAnimation("danceRight",animTable["DanceRight"],speedModifier,true,Enum.AnimationPriority.Idle)
		else
			player:AddAnimation("idle",animTable["Idle"],speedModifier,true,Enum.AnimationPriority.Idle)
		end

		player:AddAnimation("singDOWN",animTable["SingDown"],speedModifier,false,Enum.AnimationPriority.Movement)
		player:AddAnimation("singLEFT",animTable["SingLeft"],speedModifier,false,Enum.AnimationPriority.Movement)
		player:AddAnimation("singRIGHT",animTable["SingRight"],speedModifier,false,Enum.AnimationPriority.Movement)
		player:AddAnimation("singUP",animTable["SingUp"],speedModifier,false,Enum.AnimationPriority.Movement)

		for name,id in next, animTable do
			if((typeof(id)=='string' or typeof(id)=='number') and not player:AnimLoaded(id))then
				print("animation: " .. name)
				player:AddAnimation(name:lower(),id,speedModifier,false,Enum.AnimationPriority.Movement)
			end
		end

		if animTable.MicPositioning ~= nil then
			player.Obj:FindFirstChild("Default"):Destroy()
			local Mic = game:GetService("ReplicatedStorage").Assets.Microphones:FindFirstChild(micName or "Default") or game:GetService("ReplicatedStorage").Assets.Microphones.Default
			Mic = Mic:Clone()
			local micWeld = Instance.new("Weld")
			if typeof(animTable.MicPositioning) == "Instance" then
				micWeld.Part0 = animTable.MicPositioning
			elseif typeof(animTable.MicPositioning) == "boolean" then
				micWeld.C0 = CFrame.new(0, -1, -0.4) * CFrame.fromEulerAnglesXYZ(0,math.rad(0),0)
				micWeld.Part0 = animTable.MicPositioning and player.Obj["Right Arm"] or player.Obj["Left Arm"]
			else
				micWeld.C0 = CFrame.new(0, -1, -0.4) * CFrame.fromEulerAnglesXYZ(0,math.rad(0),0)
				if player.Obj:FindFirstChild('Right Arm') then micWeld.Part0 = player.Obj["Right Arm"] end
			end
			micWeld.Part1 = Mic.Handle
			micWeld.Name = "HandleWeld"
			micWeld.Parent = Mic
			Mic.Parent = player.Obj
			player.Microphone = Mic
		end
	end
	--]]
end

local function eventNoteEarlyTrigger(eventNote)
	local returnedValue = 0
	for i = 1, #loadedModchartData do	
		if loadedModchartData[i].EarlyTrigger then
			returnedValue = loadedModchartData[i].EarlyTrigger(eventNote)
		end
		if(returnedValue ~= 0) then
			return returnedValue;
		end
	end
	return 0
end

function module.closeScript(name : string) -- When called it removes the specified modchart from the list of modcharts
	for i = 1, #loadedModchartData do
		if loadedModchartData[i] then
			if table.find(loadedModchartData[i], name) ~= nil then
				table.remove(loadedModchartData, i)
			end
		end
	end
end

function checkEventNote(SongTime, offset)
	local eventsLength = #eventNotes
	if eventsLength > 0 then
		offset += (SongIdInfo.EventOffset or 0)
		for i = 1, eventsLength do
			local eventNote = eventNotes[i]
			local Time = eventNote[1]	
			if(SongTime < Time + offset)then
				return
			end

			for j = 1, #eventNote[2] do
				local name = eventNote[2][j][1]
				local value1 = eventNote[2][j][2]
				local value2 = eventNote[2][j][3]

				module.processEvent((name), value1, value2, unpack(eventNote[2][j], 4));
			end

			table.remove(eventNotes, i)
			break;
		end
	end
end

function resync()
	local songPos = ((Conductor.SongPos*instrSound.PlaybackSpeed)/1000)
	if songPos < songLength then
		warn'resync'
		instrSound:Stop()
		voiceSound:Stop()
		instrSound.TimePosition=songPos
		voiceSound.TimePosition=songPos
		--instrSound.Playing=true
		--voiceSound.Playing=true
		instrSound:Resume()
		voiceSound:Resume()
	end
end

function module.startCountdown(customIcon)
	if loadedCutscene and loadedCutscene.Start then
		--module.flash('#000000', 0, 0)
		gameUI.realGameUI.Flash.Visible = false
		loadedCutscene.Start(gameUI,module)
	else
		module.flash("#000000", 5/speedModifier, 0) -- Hide the game while it loads so that it doesn't look as bad
	end

	if SongIdInfo.mapProps and repS.Maps:FindFirstChild(SongIdInfo.mapProps) then
		mapProps.Parent = workspace.Maps
	end
	if SongIdInfo.hideBox then
		local PerformingSpots = workspace.PerformingSpots:GetChildren()
		for i = 1, #PerformingSpots do
			if PerformingSpots[i].Name == "BoomBox" then
				PerformingSpots[i].Parent = game.ReplicatedStorage.HiddenBoomBoxes
			end
		end
	end
	if module.settings.HideUI then
		--gameUI.realGameUI.Notes.BF.Visible = false
		--gameUI.realGameUI.Notes.Dad.Visible = false
		--gameUI.realGameUI.Notes.HPBarBG.Visible = false -- This should be a setting of it's own
		ScoreLabel.Visible = false
	else
		--gameUI.realGameUI.Notes.HPBarBG.BarContainer.Visible = true
		ScoreLabel.Visible = true
	end

	if module.settings.Modcharts then
		if #events > 0 or songData.events and #songData.events > 0 then -- Event system 0.8.2 -- Remember to change that when changing the system
			print("Loading Events...")

			local success, issue = pcall(function()
				if(songData.events)then
					if(#songData.events > 0) then
						for num, Time in pairs(songData.events) do
							if type(Time[1]) ~= "number" then return end
							Time[1] -= eventNoteEarlyTrigger(Time)
						end
						table.move(songData.events, 1, #songData.events, #eventNotes + 1, eventNotes)
					end
				end
				for n = 1, #events do
					if(#events > 0)then
						local song = events[n].song
						local loop = song.events ~= nil and song.events or song.notes or songData.notes
						for i,event in pairs(loop) do
							if type(event[1]) ~= "number" then
								--warn("How did this get here?", event)
								--table.remove(loop, event)
							else
								local eary = eventNoteEarlyTrigger(event)
								if eary~=nil then event[1] -= eary end

								table.move({event}, 1, #event, #eventNotes + 1, eventNotes)
							end
						end

						--table.move(loop, 1, #loop, #eventNotes + 1, eventNotes) -- This caused the system to add stuff that were not events
					end
				end

				table.sort(eventNotes, function(a,b)
					return a[1] < b[1]
				end)
			end)

			if not success then
				warn("Events failed to load!", issue)
			else
				print('Events Loaded')
			end
		end
	end
	
	Botplay = false
	if module.settings.ChillMode and module.PositioningParts.isOpponentAvailable == nil then
		Botplay = true
		for _,button in next,gameUI.TouchScreen:GetChildren() do
			UserInputBind.RemoveBind(button)
			button:Destroy()
		end
		for i=1,DirAmmo[songData.mania] do
			UserInputBind.ClearBinds("Direction" .. i)
		end
	end
	
	-- Check player settings so that the player doesn't have "Advantages" to get a better score
	validScore = true
	if module.settings.PlaybackSpeed ~= 1 then
		validScore = false
	elseif Botplay then
		validScore = false
	end
	
	startedCountdown=true

	local function generateReceptors(player)
		for i = 1,DirAmmo[songData.mania] do
			local selNoteXml
			local obj
			if internalSettings.useDuoSkins then
				selNoteXml = player == 1 and NoteXml.BF or NoteXml.Dad
				obj = (player == 1 and internalSettings.useDuoSkins.BF or internalSettings.useDuoSkins.Dad):Clone()
			else
				selNoteXml = NoteXml
				obj = NoteObject:Clone()
			end

			local babyArrow = Receptor.new(obj,true,2,true,noteScaleRatio)

			babyArrow.Index = i
			babyArrow.Direction = ""
			babyArrow.Scale=Vector2.new(.7,.7) * (internalSettings.autoSize * module.settings.customSize)
			if songData.mania ~= 0 then -- shaggy system
				local nSuf = {"LEFT","DOWN","UP","RIGHT"}
				local pPre = {"left","down","up","right"}
				if songData.mania == 1 then
					nSuf = {"LEFT","UP","RIGHT","LEFT","DOWN","RIGHT"}
					pPre = {"left","up","right","yel","down","dark"}
				elseif songData.mania == 2 then
					nSuf = {"LEFT","DOWN","UP","RIGHT","SPACE","LEFT","DOWN","UP","RIGHT"}
					pPre = {"left","down","up","right","white","yel","violet","black","dark"}
				elseif songData.mania == 3 then
					nSuf = {"LEFT","DOWN","SPACE","UP","RIGHT"}
					pPre = {"left","down","white","up","right"}
				elseif songData.mania == 4 then
					nSuf = {"LEFT","UP","RIGHT","SPACE","LEFT","DOWN","RIGHT"}
					pPre = {"left","up","right","white","yel","down","dark"}
				elseif songData.mania == 5 then
					nSuf = {"LEFT","DOWN","UP","RIGHT","LEFT","DOWN","UP","RIGHT"}
					pPre = {"left","down","up","right","yel","violet","black","dark"}
				end
				babyArrow:AddSparrowXML(selNoteXml,'static', 'arrow' .. nSuf[i]);
				babyArrow:AddSparrowXML(selNoteXml,'pressed', pPre[i] .. ' press', 24, false);
				babyArrow:AddSparrowXML(selNoteXml,'confirm', pPre[i] .. ' confirm', 24, false);
				babyArrow.Direction = nSuf[i] ~= "SPACE" and string.lower(nSuf[i]) or "up"
			else -- vanilla system
				if(i==1)then
					babyArrow:AddSparrowXML(selNoteXml,'static', 'arrowLEFT');
					babyArrow:AddSparrowXML(selNoteXml,'pressed', 'left press', 24, false);
					babyArrow:AddSparrowXML(selNoteXml,'confirm', 'left confirm', 24, false);
					babyArrow.Direction = "left"
				elseif(i==2)then
					babyArrow:AddSparrowXML(selNoteXml,'static', 'arrowDOWN');
					babyArrow:AddSparrowXML(selNoteXml,'pressed', 'down press', 24, false);
					babyArrow:AddSparrowXML(selNoteXml,'confirm', 'down confirm', 24, false);
					babyArrow.Direction = "down"
				elseif(i==3)then
					babyArrow:AddSparrowXML(selNoteXml,'static', 'arrowUP');
					babyArrow:AddSparrowXML(selNoteXml,'pressed', 'up press', 24, false);
					babyArrow:AddSparrowXML(selNoteXml,'confirm', 'up confirm', 24, false);
					babyArrow.Direction = "up"
				elseif(i==4)then
					babyArrow:AddSparrowXML(selNoteXml,'static', 'arrowRIGHT');
					babyArrow:AddSparrowXML(selNoteXml,'pressed', 'right press', 24, false);
					babyArrow:AddSparrowXML(selNoteXml,'confirm', 'right confirm', 24, false);
					babyArrow.Direction = "right"
				end
			end
			babyArrow:PlayAnimation("static")
			--obj.ImageTransparency=1
			--obj.Parent=DadNotesUI
			obj.ZIndex=1
			--babyArrow.DefaultX = (112 * (i-1)) - (player == 1 and (112 * (DirAmmo[songData.mania] - 4)) or 0) + 54
			local arrowSpacing = 112
			if module.settings.MiddleScroll then
				babyArrow.DefaultX = (((noteScaleRatio.X/2)) - (((112 * DirAmmo[songData.mania])/2)*(internalSettings.autoSize * module.settings.customSize))) + ((112) * (i-1))-- - (112 * (DirAmmo[songData.mania] - 4))
			else
				if player == 1 then
					babyArrow.DefaultX = (noteScaleRatio.X - ((112 * DirAmmo[songData.mania])*(internalSettings.autoSize * module.settings.customSize))) + (112 * (i-1))-- - (112 * (DirAmmo[songData.mania] - 4))
				else
					babyArrow.DefaultX = (112 * (i-1))
				end
			end
			babyArrow.DefaultX += 54
			babyArrow.DefaultY = Conductor.Downscroll and defaultScreenSize.Y - 80 or 50

			babyArrow:SetPosition(babyArrow.DefaultX,babyArrow.DefaultY);

			if(player==1)then
				table.insert(flipMode and dadStrums or playerStrums,babyArrow)
				table.insert(rightStrums,babyArrow)
				if(flipMode)then
					babyArrow.AnimationFinished:Connect(function(anim)
						if(anim:sub(-7) == "confirm")then
							babyArrow:PlayAnimation("static")
						end
					end)
				elseif(not flipMode) and Botplay then
					babyArrow.AnimationFinished:Connect(function(anim)
						if(anim:sub(-7) == "confirm")then
							babyArrow:PlayAnimation("static")
						end
					end)
				end
			else
				table.insert(flipMode and playerStrums or dadStrums,babyArrow)
				table.insert(leftStrums,babyArrow)
				if(not flipMode)then
					babyArrow.AnimationFinished:Connect(function(anim)
						if(anim:sub(-7) == "confirm")then
							babyArrow:PlayAnimation("static")
						end
					end)
				elseif (flipMode) and Botplay then
					babyArrow.AnimationFinished:Connect(function(anim)
						if(anim:sub(-7) == "confirm")then
							babyArrow:PlayAnimation("static")
						end
					end)
				end
			end
			table.insert(allReceptors,babyArrow)

		--[[
		local tw = game:service'TweenService':Create(
			obj,
			TweenInfo.new(
				1,
				Enum.EasingStyle.Circular,
				Enum.EasingDirection.Out,
				0,
				false,
				.5+(.2*i)
			),
			{
				ImageTransparency= 1 - ((songData.mania ~= 0 and (player == 1 == flipMode)) and 0.2 or 1),
			}
		)
		tw:Play()--]]

			obj.Name=i
		end
	end

	generateReceptors(1)
	generateReceptors(2)
	for i,v in next,rightStrums do
		for Type,Args in next,NoteClass.specialNoteAnimQueue do
			local ImageId,xmlFile,name,prefix,framerate,looped,factor = unpack(Args)
			v:AddSparrowXML(xmlFile,name,v.Direction .. prefix,framerate,looped,factor).ImageId = ImageId
		end
		v.GUI.Parent = BFNotesUI 
	end
	for i,v in next,leftStrums do
		for Type,Args in next,NoteClass.specialNoteAnimQueue do
			local ImageId,xmlFile,name,prefix,framerate,looped,factor = unpack(Args)
			v:AddSparrowXML(xmlFile,name,v.Direction .. prefix,framerate,looped,factor).ImageId = ImageId
		end
		v.GUI.Parent = DadNotesUI
	end
	Conductor.timePosition=(-Conductor.crochet*5)/1000
	Conductor.songPosition=-Conductor.crochet*5
	--[[
	if flipMode then
		HPBarG.Size = UDim2.fromScale((1-normalHP),1)
		HPBarR.Size = UDim2.fromScale(normalHP,1)
		BFIcon.GUI.Position = UDim2.fromScale(center-(0.5-normalHP)*scale,HPBarBG.Position.Y.Scale)
		DadIcon.GUI.Position = UDim2.fromScale(center-(0.5-normalHP)*scale,HPBarBG.Position.Y.Scale)
		BFIcon:UpdateSize()
		DadIcon:UpdateSize()
	else
		HPBarR.Size = UDim2.fromScale((1-normalHP),1)
		HPBarG.Size = UDim2.fromScale(normalHP,1)
		BFIcon.GUI.Position = UDim2.fromScale(center+(0.5-normalHP)*scale,HPBarBG.Position.Y.Scale)
		DadIcon.GUI.Position = UDim2.fromScale(center+(0.5-normalHP)*scale,HPBarBG.Position.Y.Scale)
		BFIcon:UpdateSize()
		DadIcon:UpdateSize()
	end
	
	if Conductor.Downscroll then
		DSPos = UDim.new(0.1,0)
	else
		DSPos = UDim.new(0.95,0)
	end]]
	if module.settings.Downscroll and not songEnded then
		ScoreLabel.Position = UDim2.new(0.5,0,0.15,0)
	else
		ScoreLabel.Position = UDim2.new(0.5,0,0.99,0)
	end
	TimeBar.Visible = true
	TimeBar.BarContainer.Visible = true
	TimeBar.BarContainer.Progress.Visible = true
	gameUI.realGameUI.Ratings.Visible = true
	local countdownImages = {}
	if SongIdInfo.countdownImages then
		countdownImages = {
			SongIdInfo.countdownImages[1];
			SongIdInfo.countdownImages[2];
			SongIdInfo.countdownImages[3]; 
			SongIdInfo.countdownImages[4];
		}
	elseif SongIdInfo.countdownImages == false then
		countdownImages = {
			0;
			0;
			0;
			0;
		}
	else
		countdownImages = {
			0;
			6443228613;
			6443225217;
			11695589915;  --6443224742
		}
	end
	local DadIdleTrack = PlayerObjects.Dad:GetAnimationTrack("idle")
	local BFIdleTrack = PlayerObjects.BF:GetAnimationTrack("idle")
	if SongIdInfo.BF2Animations and PlayerObjects.BF2 then
		local BF2IdleTrack = PlayerObjects.BF2:GetAnimationTrack("idle")
	end
	if SongIdInfo.Dad2Animations and PlayerObjects.Dad2 then
		local Dad2IdleTrack = PlayerObjects.Dad2:GetAnimationTrack("idle")
	end
	local Dad2IdleTrack,BF2IdleTrack
	--customScoreFormat = module.settings.CustomScoreFormat
	--[[local DadBPMSpeed = DadIdleTrack.Length/(60/Conductor.BPM) /2
	DadIdleTrack:AdjustSpeed(DadBPMSpeed ~= huge and DadBPMSpeed or 1)
	local BFBPMSpeed = BFIdleTrack.Length/(60/Conductor.BPM) /2
	BFIdleTrack:AdjustSpeed(BFBPMSpeed ~= huge and BFBPMSpeed or 1)
	
	if PlayerObjects.Dad2 then
		Dad2IdleTrack = PlayerObjects.Dad2:GetAnimationTrack("idle")
		local Dad2BPMSpeed = Dad2IdleTrack.Length/(60/Conductor.BPM) /2
		Dad2IdleTrack:AdjustSpeed(Dad2BPMSpeed ~= huge and Dad2BPMSpeed or 1)
		PlayerObjects.Dad2:Dance()
	end]]
	-- ^ THIS IS DUMB!
	-- WHY WOULD YOU DO THIS!?
	-- JUST RUINS THEM

	if PlayerObjects.Dad then PlayerObjects.Dad:Dance() end
	if PlayerObjects.BF then PlayerObjects.BF:Dance() end
	if SongIdInfo.BF2Animations then
		--module.PositioningParts.Left2.CFrame = module.PositioningParts.Left.CFrame * CFrame.new(3,0,-0.5)
		if PlayerObjects.BF2 then PlayerObjects.BF2:Dance() end
	end
	if SongIdInfo.Dad2Animations then
		if PlayerObjects.Dad2 then PlayerObjects.Dad2:Dance() end
	end
	for i = 1, #loadedModchartData do
		if loadedModchartData[i] and loadedModchartData[i].preStart then
			loadedModchartData[i].preStart()
		end
	end

	IntroSounds[1].SoundId = "rbxassetid://6532958901";
	IntroSounds[2].SoundId = "rbxassetid://6532959822";
	IntroSounds[3].SoundId = "rbxassetid://6532960894";
	IntroSounds[4].SoundId = "rbxassetid://6532961544";
	if SongIdInfo.IntroSounds then
		IntroSounds[1].SoundId = SongIdInfo.IntroSounds[1]
		IntroSounds[2].SoundId = SongIdInfo.IntroSounds[2]
		IntroSounds[3].SoundId = SongIdInfo.IntroSounds[3]
		IntroSounds[4].SoundId = SongIdInfo.IntroSounds[4]
	end
	for i = 1,4 do
		delay(((Conductor.crochet/1000)*i)/speedModifier,function()
			if SongIdInfo.IntroSounds ~= false then
				IntroSounds[i]:Play()
			end
			if(countdownImages[i]~=0)then
				local img =Instance.new("ImageLabel")
				img.Image='rbxassetid://' .. countdownImages[i]
				img.BackgroundTransparency=1
				img.AnchorPoint=Vector2.new(.5,.5)
				img.Position=UDim2.new(.5,0,.5,0)
				if(i==1)then
					img.Size=UDim2.new(0,780,0,400)
				elseif(i==2)then
					img.Size=UDim2.new(0,757,0,364)
				elseif(i==3)then
					img.Size=UDim2.new(0,702,0,322)
				elseif(i==4)then
					img.Size=UDim2.new(0,558,0,430)
				end
				img.Parent=script.Parent
				local tw = game:service'TweenService':Create(
					img,
					TweenInfo.new(
						(Conductor.crochet/1000)/speedModifier,
						Enum.EasingStyle.Cubic,
						Enum.EasingDirection.InOut,
						0,
						false,
						0
					),
					{
						ImageTransparency=1
					}
				)
				tw.Completed:connect(function()
					img:Destroy()

					--[[if generatedSong == false and instrSound.Playing == true then
						instrSound:Stop()
						voiceSound:Stop()
					end]]--
					pcall(game.Destroy,tw)

					delay(1, function()
						if i == 4 then -- This plays when the countdown actually finishes
							if not (module.PositioningParts.isOpponentAvailable)then
								--gameUI.LeaveSpotButton.Visible = true
								leaveButton:setEnabled(true)
							end
						end -- Prevents the player from ending the song before it starts
					end)
				end)
				tw:Play()
			end
		end)
	end
end

local currIconTweens = {}
function tweenIconSize(Icon,time)
	if currIconTweens[Icon] == nil or currIconTweens[Icon] then
		currIconTweens[Icon] = false
	end
	local function tweenFunc()
		currIconTweens[Icon] = true
		local callTime = tick()
		local scaleStart = 0.875
		local scaleEnd = 0.7
		local scaleDiff = scaleEnd - scaleStart
		repeat
			local val = scaleStart + (scaleDiff * TS:GetValue((tick() - callTime) / time,Enum.EasingStyle.Sine,Enum.EasingDirection.Out))
			Icon.Scale = Vector2.new(val,val)
			RS.RenderStepped:Wait()
		until tick() > callTime+time or not currIconTweens[Icon]
		Icon.Scale = Vector2.new(scaleEnd,scaleEnd)
		currIconTweens[Icon] = false
	end
	local wrapped = coroutine.wrap(tweenFunc)
	wrapped()
end
--[[
function module.PlaySong(n) -- keeping this, may get deprecated in the future.
	generatedSong=false
	startingSong=true
	startedCountdown=false
	print("loading chart")
	module.genSong(n)
	repeat wait() until instrSound.IsLoaded and generatedSong
	warn'loaded'
	DadNotesUI.Visible = true
	BFNotesUI.Visible = true
	script.Parent.HPBarBG.Visible = true
	module.startCountdown()
end
--]]
--if generatedSong == false and instrSound.Playing == true or voiceSound.Playing == true then
--instrSound:Stop()
--voiceSound:Stop()
--end
function module.endSong()
	-- Save Song Data
	
	if evil then coroutine.close(evil) evil = nil end
	SetRPC()
	if shared.song and validScore then
		-- Only save the score on right side
		if not flipMode then
			local songPlayed = tostring(songData.song)
			local saveGame = false
			-- Check if there is previous save data
			if module.settings.SongData[songPlayed] then
				-- Check for the difficulty save
				if module.settings.SongData[songPlayed][shared.song.Name] then
					if module.PlayerStats.Score > tonumber(module.settings.SongData[songPlayed][shared.song.Name][1]) then
						saveGame = true
						-- Replace previous song data
						module.settings.SongData[songPlayed][shared.song.Name] = {
							tostring(module.PlayerStats.Score),
							tostring(accuracy)
						}
					end
				end
			else
				-- Make new save data
				saveGame = true
				local saveThis = {
					[shared.song.Name] = {
						tostring(module.PlayerStats.Score), 
						tostring(accuracy)
					};
				};
				module.settings.SongData[songPlayed] = saveThis
			end

			if saveGame then
				-- Save the data
				repS.InfoRetriever:InvokeServer(0x2,module.settings)
			end
		end
	end
	
	if game.Players.LocalPlayer then -- Make the player visible
		for i,v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
			if (v:IsA("BasePart") or v:IsA("Decal")or v:IsA("MeshPart")) and v.Name~="HumanoidRootPart" then
				v.Transparency = 0
			end
			if (v:IsA("SurfaceGui") or v:IsA("BillboardGui") or v:IsA("Beam")) then
				v.Enabled = true
			end
		end
	end

	shared.songData=nil;
	shared.song=nil;
	shared.songSpeed=nil;
	shared.Receptors={};
	shared.sections=nil;

	if CameraTween then
		CameraTween:Cancel()
	end
	
	-- Remove the tweens
	for _,tween in pairs(StoredTweens) do
		if tween then
			tween:Cancel()
			tween = nil
		end
	end

	for i = 1, #loadedModchartData do
		if loadedModchartData[i].cleanUp then
			loadedModchartData[i].cleanUp()
		end
	end

	generatedSong=false
	events = {};
	eventNotes = {};
	loadedModchartData = {};
	loadedCutscene = nil;
	allReceptors = {};
	modcharts = {};
	velocityMarkers = {};
	sliderVelocities = {};
	currIconTweens = {};
	Botplay = nil
	startingSong = nil
	startedCountdown = nil
	GFSection = nil
	boomSpeed = nil
	camSpeed = 1
	songLength = nil
	falseSongLength = nil
	defaultCamZoom = .05
	initialSpeed = nil
	speedModifier = 1;
	
	-- Undefine Stats
	accuracy = nil
	combo = nil
	opponentCombo = nil
	totalPlayed = nil
	totalSteps = nil
	totalBeats = nil
	totalNotesHit = nil

	resetGroup("Map")

	instrSound.TimePosition = 0
	voiceSound.TimePosition = 0
	camZooming = true

	instrSound:Stop()
	voiceSound:Stop()
	game.Lighting.ClockTime = defaultClockTime

	resetGroup("UI")

	resetGroup("Conductor")

	pcall(KillclientAnims)
	--customScoreFormat = ""
	for _,button in next,gameUI.TouchScreen:GetChildren() do
		UserInputBind.RemoveBind(button)
		button:Destroy()
	end
	for i=1,DirAmmo[songData.mania] do
		UserInputBind.ClearBinds("Direction" .. i)
	end
	if(shared.effects)then
		for _,v in next, shared.effects do
			v:destroy()
		end
	end
	for _,Note in next,unspawnedNotes do
		if Note and Note.Destroy then Note:Destroy() end
	end
	for _,Note in next,notes do
		if Note and Note.Destroy then Note:Destroy() end
	end
	ratingLabels = {}
	noteLanes = {}
	susNoteLanes = {}
	averageAccuracy = {}
	playerStrums = {}
	leftStrums = {}
	rightStrums = {}
	dadStrums = {}
	notes = {}
	opponentNotes = {}
	currentSection = {}
	updateMotions = {}
	
	resetGroup("PositioningParts")

	bindNameDir = {}

	cam.CameraType = Enum.CameraType.Custom
	cam.FieldOfView = 70
	flipMode = nil
	validScore = nil
	
	-- Make it nil otherwise it will keep playing the character destroy function (also this clears memory)
	if PlayerObjects then
		for _,char in pairs(PlayerObjects) do
			if char then
				char:Destroy()
			end
		end
	end
	PlayerObjects = nil -- Clear the table so that it isn't called after the song ends (DO NOT CHANGE THIS. WILL BREAK A BUNCH)
	songEndEvent:Fire()
end

local evil = nil

function module.startSong()
	local SongStartTime = os.time()
	startingSong=false

	instrSound:Resume()

	resetGroup("Conductor")
	if module.settings.Visualize then
		visualiser = require(game.ReplicatedStorage.Modules.AudioVis).new(gameUI.realGameUI.SoundVisualiser, module.settings.VisualizerBars)
		visualiser:LinkToSound(instrSound)
	end

	leaveButton:setEnabled(true)
	if(songData.needsVoices)then
		voiceSound:Resume()
	end
	if instrSound.TimeLength > voiceSound.TimeLength then
		songLength = instrSound.TimeLength
	else
		songLength = voiceSound.TimeLength
	end
	for i = 1, #loadedModchartData do
		if loadedModchartData[i] and loadedModchartData[i].Start then
			loadedModchartData[i].Start()
		end	
	end
	local SongEndTime = SongStartTime + songLength
	evil = coroutine.create(function()
		while true do
			if not instrSound.Playing then break end
			task.spawn(SetRPC, curSong, SongStartTime, SongEndTime)
			task.wait(20)
		end
	end)
	coroutine.resume(evil)
end

function module.flash(hex,speed,int)
	if type(hex) == "number" then
		warn("Cannot perform Camera Flash if hex value is not valid!")
		return
	end
	local frame = gameUI.realGameUI.Flash
	frame.BackgroundTransparency = int or 0
	frame.BackgroundColor3 = Color3.fromHex(hex)
	frame.Visible = true
	local tweenInfo = TweenInfo.new(
		speed/speedModifier,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	)
	local Goal = {}
	Goal.BackgroundTransparency = 1
	local tween = TS:Create(frame,tweenInfo,Goal)
	addTween(tween, '_CameraFlashTween') -- Adds the tween to a list that will automatically cancel and remove tweens when the song ends
	tween:Play()
end

local function setGameUITransparency(n)
	for _,pogNote in next, notes do
		pogNote.Transparency = n
	end
	for _,bruhNote in next, allReceptors do
		bruhNote.Alpha = 1-n
	end
	BFIcon.Alpha = 1-n
	DadIcon.Alpha = 1-n
	HPBarBG.ImageTransparency = n
	HPBarBG.BarContainer.BackgroundTransparency = n
	HPBarG.BackgroundTransparency = n
	HPBarR.BackgroundTransparency = n
	internalSettings.NoteSpawnTransparency = n
end

module.setGameUITransparency = setGameUITransparency

----dusttale
--local phantomActive = false
--local bonedCount = 0
---- sonic from the executable
--local fogCount = 0
--local fogDrain = 0
function GoodHit(daNote)
	if(flipMode and daNote.MustPress or not flipMode and not daNote.MustPress)then
		camZooming=true
	end
	if not daNote or daNote.Update == nil then return end
	local noteType = daNote.Type
	if(not daNote.IsSustain)then
		if noteType ~= "None" then
			--[[
			if daNote.Type == "Bone" then
				bonedCount += 1
				gameUI.realGameUI.Dust.ImageTransparency = 1 - (bonedCount / 10)
				playSound("rbxassetid://4735718618",4)
				if bonedCount >= 10 then
					module.Kill()
				end
				local thread = function()
					local effectRunout = tick() + 35
					repeat
						RS.RenderStepped:Wait()
					until tick() > effectRunout or not generatedSong
					bonedCount -= 1
					gameUI.real=.Dust.ImageTransparency = 1 - (bonedCount / 10)
				end
				thread = coroutine.create(thread) 
				coroutine.resume(thread)
				if daNote.Destroy then daNote:Destroy() end	
				return
			elseif noteType == "Knife" then
				module.flash("ff3030",0.4)
				playSound(5810686185,2)
				module.PlayerStats.Health-=1
			elseif noteType == "Bullet" then
				PlayerObjects.BF:PlayAnimation("dodge")
			elseif noteType == "BloodyKnife" then
				module.flash("ff3030",0.4)
				playSound(5810686185,2)
			elseif noteType == "Gem" then
				module.PlayerStats.Health += 0.02
			elseif noteType == "Trap" then
				local thread = function()
					local healthDrained = 0
					repeat
						local delta = RS.RenderStepped:Wait()
						local drainAmount = (6/1250) * (delta / (1/60))
						module.PlayerStats.Health -= drainAmount
						healthDrained += drainAmount
					until healthDrained > 1 or not generatedSong
				end
				thread = coroutine.create(thread) 
				coroutine.resume(thread)
				if daNote.Destroy then daNote:Destroy() end	
				return
			elseif daNote.Type == "phantom" then
				local function doTrans()
					if phantomActive == false then
						phantomActive = true
						local opacity = 0
						wait()
						repeat
							local delta = RS.RenderStepped:Wait()
							opacity += 0.01 * (delta/(1/60))
							setGameUITransparency(opacity)
						until opacity >= 0.95
						opacity = 0.95 -- in case it goes above the mark
						setGameUITransparency(opacity)

						phantomActive = tick() + 10
						repeat
							RS.RenderStepped:Wait()
						until tick() > phantomActive
						repeat
							local delta = RS.RenderStepped:Wait()
							opacity -= 0.01 * (delta/(1/60))
							setGameUITransparency(opacity)
						until opacity <= 0
						opacity = 0
						setGameUITransparency(opacity)
						phantomActive = false
					end
				end
				local wrappedThread = coroutine.wrap(doTrans)
				wrappedThread()
				playSound("rbxassetid://7757747076",2)
				if daNote.Destroy then daNote:Destroy() end	
				return
			elseif daNote.Type == "Karma" then
				local thread = function()
					local healthDrained = 0
					repeat
						HPBarG.BackgroundColor3 = Color3.new(1, 0, 0.701961)
						local delta = RS.RenderStepped:Wait()
						local drainAmount = (2/1250) * (delta / (1/60))
						module.PlayerStats.Health -= drainAmount
						healthDrained += drainAmount
					until healthDrained > 0.5 or not generatedSong
					HPBarG.BackgroundColor3 = Color3.fromRGB(102, 255, 51)
				end
				thread = coroutine.create(thread) 
				coroutine.resume(thread)
				if daNote.Destroy then daNote:Destroy() end	
				return
			end
			
			]]
			if noteType == "kill" then
				if module.settings.DeathEnabled then
					module.Kill()
					playSound(11003930474,2)
				else
					module.PlayerStats.Health-=1
					module.PlayerStats.Score-=13500;
				end
			end
		end
		if(module.settings.HitSound)then
			local h = script.Parent.Hit:Clone();
			h.Parent=script.Parent
			h:Play()
			game:service'Debris':AddItem(h,1);
		end
	end
	voiceSound.Volume=(SongIdInfo.VoiceVolume or 2)*(module.settings.SongVolume/100)
	daNote.GoodHit=true
	daNote:Destroy()
	local theStrum = playerStrums[daNote.NoteData+1]
	theStrum:PlayAnimation(theStrum.Animations[daNote.Type.."_confirm"] and daNote.Type.."_confirm" or "confirm",true)

	if daNote.HealthLoss > 0 then
		--[[
		if(noteType=='Spam' and songData.song=='Last-stand' )then
			daNote.HealthLoss=numLerp(0,1.35,module.PlayerStats.Health/2);
			if(daNote.HealthLoss<.5)then
				daNote.HealthLoss=.5
			end
		end
		]]
		module.PlayerStats.Health -= daNote.HealthLoss;
		module.PlayerStats.Score-=math.round(daNote.HealthLoss*1000)
		GameplayEvent:Fire("GhostTap")
		rates.miss+=1
		combo=0;
		if daNote.Destroy then daNote:Destroy() end			
	else
		local missed=false;
		GameplayEvent:Fire("NoteHit",daNote.StrumTime,Conductor.SongPos,daNote.IsSustain,noteType,daNote.NoteData)
		for i,v in pairs(loadedModchartData) do
			coroutine.resume(coroutine.create(function()
				if v.P1NoteHit then
					v.P1NoteHit(noteType, daNote.NoteData, daNote)
				end
			end))
		end
		if(daNote.GainOnSustains or not daNote.IsSustain)then
			module.PlayerStats.Health += daNote.HPGain
		end

		if(not daNote.IsSustain)then
			if(not missed)then
				combo+=1
				ScorePopup(daNote.StrumTime-Conductor.SongPos, daNote)
			else
				rates.miss+=1
				combo=0;
				if daNote.Destroy then daNote:Destroy() end		
			end
		else
			totalNotesHit+=1
		end
	end
	local sDir
	Switch()
	:default(function() 
		sDir = {"LEFT","DOWN","UP","RIGHT"}
	end)
	:case(1,function()
		if(module.settings.NoteSkin_6K=='2v200' or module.settings.NoteSkin_6K=='Default' and SongIdInfo.NoteSkin=='2v200')then
			sDir = {"LEFT","DOWN","RIGHT","LEFT","UP","RIGHT"}
		else
			sDir = {"LEFT","UP","RIGHT","LEFT","DOWN","RIGHT"}
		end
	end)
	:case(2,function()
		sDir = {"LEFT","DOWN","UP","RIGHT","UP","LEFT","DOWN","UP","RIGHT"}
	end)
	:case(3,function()
		sDir = {"LEFT","DOWN","UP","UP","RIGHT"}
	end)
	:case(4,function()
		sDir = {"LEFT","UP","RIGHT","UP","LEFT","DOWN","RIGHT"}
	end)
	:case(5,function()
		sDir = {"LEFT","DOWN","UP","RIGHT","LEFT","DOWN","UP","RIGHT"}
	end)(math.abs(songData.mania))

	local char
	--if GFSection then
	--	daNote.bro = "BF2"
	--end
	if daNote.dType ~= 0 then
		if daNote.dType == 1 then
			char = (flipMode and PlayerObjects.Dad2 or PlayerObjects.BF2)
		elseif daNote.dType == 2 then
			char = daNote.NoteData <= 3 and (flipMode and PlayerObjects.Dad2 or PlayerObjects.BF2) or (flipMode and PlayerObjects.Dad or PlayerObjects.BF)
		end
	elseif daNote.bro ~= 0 then
		if type(daNote.bro) == "string" then
			if not PlayerObjects[daNote.bro] then
				warn("Invalid Character")
				return;
			else
				char = PlayerObjects[daNote.bro]
			end
		elseif type(daNote.bro) == 'table' then
			daNote.noAnimation = true; -- this is here for a reason
			for _,ch in pairs(daNote.bro) do
				if not PlayerObjects[ch] then
					warn("Invalid Character")
					return;
				else
					PlayerObjects[ch]:PlayAnimation("sing" .. sDir[daNote.NoteData+1],true)
				end
			end
		elseif daNote.bro == 1 then
			char = (flipMode and PlayerObjects.Dad2 or PlayerObjects.BF2)
		elseif daNote.bro == 2 then
			char = daNote.NoteData <= 3 and (flipMode and PlayerObjects.Dad2 or PlayerObjects.BF2) or (flipMode and PlayerObjects.Dad or PlayerObjects.BF)
		elseif daNote.bro == 3 then
			char = (flipMode and PlayerObjects.Dad or PlayerObjects.BF)
			char:PlayAnimation("sing" .. sDir[daNote.NoteData+1],true)
			char = (flipMode and PlayerObjects.Dad2 or PlayerObjects.BF2)
		elseif daNote.bro == 4 then
			char = (flipMode and PlayerObjects.Dad or PlayerObjects[modcharts[1]:GetAttribute("CurChar")])
			if modcharts[1]:GetAttribute("CurChar") == "All" then
				daNote.noAnimation = true; -- this is here for a reason
				for _,ch in pairs(PlayerObjects) do
					ch:PlayAnimation("sing" .. sDir[daNote.NoteData+1],true)
				end
			end
		end
	else
		char = (flipMode and PlayerObjects.Dad or PlayerObjects.BF)
	end -- shaggy thing
	
	if char then
		char.Holding=daNote.HoldParent;
		if shared.cancelAnim == false and not daNote.noAnimation and not daNote.CustomAnimation then
			char:PlayAnimation("sing" .. sDir[daNote.NoteData+1],true)
		elseif shared.cancelAnim == false and not daNote.noAnimation and daNote.CustomAnimation then
			print(daNote.CustomAnimation)
			char:PlayAnimation(daNote.CustomAnimation,true)
		end
	end
	
	UpdateAccuracy()
end

function resetGroup(group)
	Switch()
	:case("UI", function()
		if module.settings.Visualize and visualiser then
			visualiser:UnlinkFromSound()
			visualiser:Destroy()
			visualiser = nil
		end
		DadNotesUI.Visible = false
		BFNotesUI.Visible = false
		HPBarBG.Visible = false
		BFIcon.GUI.Visible = false
		BFIcon.GUI:SetAttribute("Offset", Vector3.new())
		DadIcon.GUI:SetAttribute("Offset", Vector3.new())
		DadIcon.GUI.Visible = false
		BFBG.Visible = false
		DadBG.Visible = false
		TimeBar.Visible = false
		for _, g in rates do
			if gameUI.realGameUI.Ratings:FindFirstChild(_) then
				gameUI.realGameUI.Ratings[_].Text = "0"
			end
		end
		leaveButton:setEnabled(false)
		gameUI.realGameUI.Ratings.Visible = false
		ScoreLabel.Size = UDim2.fromScale(1,0.05)
		gameUI.realGameUI.Rotation = 0
		gameUI.realGameUI.Notes.Rotation = 0
		--gameUI.realGameUI.Overlay.Visible = false
		gameUI.realGameUI.Flash.Visible = false
		gameUI.realGameUI.Notes.Rotation = 0
		gameUI.waste:ClearAllChildren()
		gameUI.realGameUI.waste:ClearAllChildren()
		gameUI.realGameUI.Notes.waste:ClearAllChildren()
		gameUI.HudUI.waste:ClearAllChildren()
	end)
	:case("Conductor", function()
		Conductor.SongPos = 0
		Conductor.CurrentTrackPos = 0
		Conductor.AdjustedSongPos = 0
		Conductor.timePosition = 0
		Conductor.songPosition = 0
	end)
	:case("PositioningParts", function()
		module.PositioningParts.PlayAs = nil
		module.PositioningParts.AccuracyRate = nil
		module.PositioningParts.Left = nil
		module.PositioningParts.Left2 = nil
		module.PositioningParts.Right = nil
		module.PositioningParts.Right2 = nil
		module.PositioningParts.Camera = nil
		module.PositioningParts.CameraPlayer = false
	end)
	:case("camControls", function()
		camControls.BehaviourType = "Separate"
		camControls.zoom = 0
		camControls.hudZoom = .05
		camControls.camZoom = 0
		camControls.ForcedPos = false
		camControls.StayOnCenter = false
	end)
	:case("Map", function()
		if mapProps then
			mapProps:Destroy()
			local Props = game.ReplicatedStorage.HiddenProps:GetChildren()
			for i = 1, #Props do
				Props[i].Parent = workspace.Props
			end
			local Props2 = game.ReplicatedStorage.HiddenMaps:GetChildren()
			for i = 1, #Props2 do
				Props2[i].Parent = game.workspace.BaseMap
			end
		end
		local PerformingSpots = game.ReplicatedStorage.HiddenBoomBoxes:GetChildren()
		for i = 1, #PerformingSpots do
			if PerformingSpots[i].Name == "BoomBox" then
				PerformingSpots[i].Parent = workspace.PerformingSpots
			end
		end

		mapProps=nil
	end)(group)
end

-- This is too much reassurance checks, I should make this happen some other time and not during the song
-- Made this function to relieve clutter from the ScorePopup function and allow for people to make noteSplashes for both sides
local function spawnNoteSplash(note)
	local id = note.NoteData+1
	local texture = "noteSplashes"
	local songMania = DirAmmo[songData.mania]
	if note.NoteSplashSkin ~= nil and note.NoteSplashSkin ~= "None" then
		texture = note.NoteSplashSkin
	elseif SongIdInfo.NoteSplashSkin ~= nil then
		texture = SongIdInfo.NoteSplashSkin
	end

	local obj2
	if typeof(texture) == "string" and repS.Modules.Assets["noteSkins"..songMania.."K"]:FindFirstChild(texture) then
		obj2 = repS.Modules.Assets["noteSkins"..songMania.."K"][texture]:Clone()
	elseif typeof(texture) ~= "string" and texture:IsA("ImageLabel") then
		obj2 = texture:Clone()
	else
		warn("Not a valid note splash, must be a ImageLabel or a NoteSplash name")
		return -- Prevent the game from reading beyond this line when the notesplash isn't valid
	end

	local xml = obj2.XML

	local animNum = math.random(1, 2)
	local delayT = math.random(-2, 2)
	local setScale = (internalSettings.autoSize * module.settings.customSize)
	local thePlayerStrum = playerStrums[id]
	local splash = Receptor.new(obj2, true, obj2:GetAttribute('scale') or 1, true, noteScaleRatio)
	splash.GUI.ImageRectSize = splash.GUI.ImageRectSize * 2
	splash.Index = id
	splash.Direction = ""
	splash.Scale=Vector2.new(.7,.7) * setScale
	
	if songData.mania ~= 0 then -- shaggy system
		local pDe = {"left", "down", "up", "right"}
		local pPre = {"purple","blue","green","red"}
		if songData.mania == 1 then
			pPre = {"purple","green","red","yellow","blue","dark"}
		elseif songData.mania == 2 then
			pPre = {"purple","blue","green","red","white","yellow","violet","darkred","dark"}
		elseif songData.mania == 3 then
			pPre = {"purple","blue","white","green","red"}
		elseif songData.mania == 4 then
			pPre = {"purple","green","red","white","yellow","violet","dark"}
		elseif songData.mania == 5 then
			pPre = {"purple","blue","green","red","yellow","violet","darkred","dark"}
		end
		splash:AddSparrowXML(xml,'splash ' .. id, "note splash " .. pPre[id] .. " " .. animNum, 24 + delayT * speedModifier, false);
		splash.Direction = pDe[id]
	else
		if(id==1)then
			splash:AddSparrowXML(xml, 'splash 1', "note splash purple " .. animNum, 24 + delayT * speedModifier,false)
			splash.Direction = "left"
		elseif(id==2)then
			splash:AddSparrowXML(xml, 'splash 2', "note splash blue " .. animNum, 24 + delayT * speedModifier,false)
			splash.Direction = "down"
		elseif(id==3)then
			splash:AddSparrowXML(xml, 'splash 3', "note splash green " .. animNum, 24 + delayT * speedModifier,false)
			splash.Direction = "up"
		elseif(id==4)then
			splash:AddSparrowXML(xml, 'splash 4', "note splash red " .. animNum, 24 + delayT * speedModifier,false)
			splash.Direction = "right"
		end

		local arrowSpacing = 112
		if module.settings.MiddleScroll then
			splash.DefaultX = (((noteScaleRatio.X/2)) - (((112 * songMania)/2)*setScale)) + ((112) * (id-1))-- - (112 * (DirAmmo[songData.mania] - 4))
		else
			if flipMode == false then
				splash.DefaultX = (noteScaleRatio.X - ((112 * songMania)*setScale)) + (112 * (id-1))-- - (112 * (DirAmmo[songData.mania] - 4))
			else
				splash.DefaultX = (112 * (id-1))
			end
		end
	end
	splash.DefaultX = id*54
	splash.DefaultY = Conductor.Downscroll and defaultScreenSize.Y - 80 or 50

	obj2.Parent=(flipMode and DadNotesUI or BFNotesUI)

	splash.Alpha = thePlayerStrum.Alpha

	splash:SetPosition(thePlayerStrum.X,thePlayerStrum.Y)
	splash:PlayAnimation('splash ' .. id, false)
	obj2.Name = "Splash " .. id
	delay(((6.6 + delayT)/60)/speedModifier,function()
		obj2:Destroy()
		splash:Destroy()
	end)
end

local ratingNamesSize = {
	sick = Vector2.new(599,202);
	good = Vector2.new(549,183);
	bad = Vector2.new(317,185);
	trash = Vector2.new(413,180);
}
function ScorePopup(noteDiff, note)
	local rating = ScoreUtils:GetRating(noteDiff) or "sick"
	local intScore = ScoreUtils:GetScore(rating) or 0
	totalNotesHit += ScoreUtils:GetAccuracy(rating) or 1

	if(rates[rating])then
		rates[rating]+=1
		gameUI.realGameUI.Ratings[rating].Text = tostring(rates[rating])
	end
	
	if rating == "sick" then
		spawnNoteSplash(note)
	end
	module.PlayerStats.Score+=intScore
	local ratingText = Instance.new("ImageLabel")
	ratingText.BackgroundTransparency=1
	--ratingText.Font=Enum.Font.Cartoon
	--ratingText.TextColor3=rating=='sick' and Color3.fromRGB(19, 224, 255) or rating=='good' and Color3.fromRGB(55, 236, 14) or Color3.new(1, 0, 0) or 'bad' and Color3.fromRGB(208, 1, 0) or rating=='trash' and Color3.fromRGB(81, 59, 44) or Color3.new(1,1,1)
	--ratingText.TextStrokeColor3=Color3.new(0,0,0)
	--ratingText.TextStrokeTransparency=.2
	--ratingText.TextSize=94
	local screenMul = (cam.ViewportSize.X/defaultScreenSize.X) * module.settings.ratingSize
	local scaleSize = ((ratingNamesSize[rating]) * (0.45))*screenMul
	ratingText.Size = UDim2.fromOffset(scaleSize.X,scaleSize.Y)
	if SongIdInfo.RatingSet then
		ratingText.Image=SongIdInfo.RatingSet[rating]
	else
		ratingText.Image=ScoreUtils.ratingNames[rating]
	end
	ratingText.AnchorPoint=Vector2.new(.5,.5)
	ratingText.Position=UDim2.new(.5,-40,.5,140)
	ratingText:SetAttribute("Acceleration",Vector2.new(0,550))
	local Side = not module.PositioningParts.PlayAs and "Right" or "Left"
	ratingText:SetAttribute("Side", Side)
	ratingText:SetAttribute("Velocity",Vector2.new(RNG:NextInteger(0,10),-RNG:NextInteger(140,175)))
	ratingText:SetAttribute("Offset",Vector2.new(0,0))
	table.insert(ratingLabels,ratingText)
	ratingText.Parent = script.Parent
	local tw = game:service'TweenService':Create(ratingText,TweenInfo.new(.2/speedModifier,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,Conductor.crochet*0.0005),{ImageTransparency = 1})--{TextTransparency=1,TextStrokeTransparency=1})
	tw.Completed:connect(function()
		ratingText:destroy()
		pcall(game.Destroy,tw)
	end)
	tw:Play()

	local displayedCombo = '';
	if(combo<100) then -- 0
		displayedCombo=displayedCombo..'0'
	end
	if(combo<10) then -- 00
		displayedCombo=displayedCombo..'0'
	end

	displayedCombo = displayedCombo .. combo

	for i,v in next, string.split(displayedCombo,'') do
		local comboText = game.ReplicatedStorage.Assets.Numbers:FindFirstChild(v):Clone()
		comboText.AnchorPoint=Vector2.new(.5,.5)
		comboText.Size = UDim2.new(comboText.Size.X.Scale*screenMul,comboText.Size.X.Offset*screenMul,
			comboText.Size.Y.Scale*screenMul,comboText.Size.Y.Offset*screenMul
		)
		comboText.Size = UDim2.new(comboText.Size.X.Scale*.55,comboText.Size.X.Offset*.55,comboText.Size.Y.Scale*.55,comboText.Size.Y.Offset*.55)
		comboText.Position=UDim2.new(.5,(-40 + ((43)*i))*screenMul,.5,80*screenMul)
		comboText:SetAttribute("Acceleration",Vector2.new(0,RNG:NextInteger(200,300)))
		comboText:SetAttribute("Side", Side)
		comboText:SetAttribute("Velocity",Vector2.new(RNG:NextInteger(-5,5),-RNG:NextInteger(140,160)))
		comboText:SetAttribute("Offset",Vector2.new((26*i)-90,-60)*screenMul)
		table.insert(ratingLabels,comboText)
		comboText.Parent = script.Parent
		local tw = game:service'TweenService':Create(comboText,TweenInfo.new(.2/speedModifier,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,Conductor.crochet*0.002),{ImageTransparency=1})
		tw.Completed:connect(function()
			comboText:destroy()
			pcall(game.Destroy,tw)
		end)
		tw:Play()
	end
	-- MS Hit Offset counter
	if not module.settings.ShowHitOffset then return end
	if #averageAccuracy >= 50 then
		table.remove(averageAccuracy,50)
	end
	averageAccuracy[#averageAccuracy+1] = noteDiff
	local median = 0
	for _,v in pairs(averageAccuracy) do
		median += v
	end
	--table.foreach(averageAccuracy,function(i,v) median += v end)
	median /= #averageAccuracy
	local processedNoteDiff = tostring(math.floor(noteDiff))
	local isNegative = noteDiff < 0
	for i,v in next, string.split(processedNoteDiff,"") do -- noteDiff thingy
		if not game.ReplicatedStorage.Assets.Numbers:FindFirstChild(v) then continue end
		local comboText = game.ReplicatedStorage.Assets.Numbers:FindFirstChild(v):Clone()
		comboText.AnchorPoint=Vector2.new(.5,.5)
		comboText.Size = UDim2.new(comboText.Size.X.Scale*screenMul,comboText.Size.X.Offset*screenMul,
			comboText.Size.Y.Scale *screenMul,comboText.Size.Y.Offset*screenMul
		)
		comboText.Size = UDim2.new(comboText.Size.X.Scale*.55,comboText.Size.X.Offset*.55,comboText.Size.Y.Scale*.55,comboText.Size.Y.Offset*.55)
		comboText.Position=UDim2.new(.5,(-40 + (43*i))*screenMul,.5,80*screenMul)
		comboText.ImageColor3 = isNegative and Color3.new(1, 0.576471, 0.576471) or Color3.new(0.572549, 1, 0.564706)
		comboText:SetAttribute("Acceleration",Vector2.new(0,RNG:NextInteger(200,300)))
		comboText:SetAttribute("Side", Side)
		comboText:SetAttribute("Velocity",Vector2.new(RNG:NextInteger(-5,5),-RNG:NextInteger(140,160)))
		comboText:SetAttribute("Offset",Vector2.new((26*i)-90,-100)*screenMul)
		table.insert(ratingLabels,comboText)
		comboText.Parent = script.Parent
		local tw = game:service'TweenService':Create(comboText,TweenInfo.new(.2/speedModifier,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,Conductor.crochet*0.002),{ImageTransparency=1})
		tw.Completed:connect(function()
			comboText:destroy()
			pcall(game.Destroy,tw)
		end)
		tw:Play()
	end
end

function module.handleHit(strum,noteDiff,noteType,noteDir,sussy) -- this is what the other player hits
	local sDir
	Switch()
	:default(function() 
		sDir = {"LEFT","DOWN","UP","RIGHT"}
	end)
	:case(1,function()
		if(module.settings.NoteSkin_6K=='2v200' or module.settings.NoteSkin_6K=='Default' and SongIdInfo.NoteSkin=='2v200')then
			sDir = {"LEFT","DOWN","RIGHT","LEFT","UP","RIGHT"}
		else
			sDir = {"LEFT","UP","RIGHT","LEFT","DOWN","RIGHT"}
		end
	end)
	:case(2,function()
		sDir = {"LEFT","DOWN","UP","RIGHT","UP","LEFT","DOWN","UP","RIGHT"}
	end)
	:case(3,function()
		sDir = {"LEFT","DOWN","UP","UP","RIGHT"}
	end)
	:case(4,function()
		sDir = {"LEFT","UP","RIGHT","UP","LEFT","DOWN","RIGHT"}
	end)
	:case(5,function()
		sDir = {"LEFT","DOWN","UP","RIGHT","LEFT","DOWN","UP","RIGHT"}
	end)(math.abs(songData.mania))
	if(songData.needsVoices)then
		voiceSound.Volume = (SongIdInfo.VoiceVolume or 2)*(module.settings.SongVolume/100)
	end
	camZooming = true
	for i,v in pairs(loadedModchartData) do
		coroutine.resume(coroutine.create(function()
			if v.P2NoteHit then
				v.P2NoteHit(noteType, noteDir)
			end
		end))
	end
	if type(internalSettings.OpponentNoteDrain) == "number" then
		if module.PlayerStats.Health < internalSettings.minHealth then
			module.PlayerStats.Health -= 0
		else
			module.PlayerStats.Health -= internalSettings.OpponentNoteDrain
		end

	end
	--[[
	if(noteType=='Gem')then
		if(SongIdInfo.NoteGroup=='Gems') and module.PlayerStats.Health > .0425 then
			module.PlayerStats.Health -= .0425;
		end
	elseif(noteType=='BlackGem')then
		module.PlayerStats.Health = .001;
	end
	]]
	local theStrum = dadStrums[noteDir+1]
	theStrum:PlayAnimation(theStrum.Animations[noteType.."_confirm"] and noteType.."_confirm" or "confirm",true)
	if(not sussy)then
		opponentCombo+=1
		if (not module.settings.hideOppRatings) then
			module.fakeScorePopup(noteDiff)	
		end
	end
	local char
	for i = 1,#opponentNotes do
		local note= opponentNotes[i]
		if note.Update==nil then
			continue
		end
		if(note.StrumTime==strum and note.NoteData==noteDir)then
			if note.dType ~= 0 then
				if note.dType == 1 then
					char = (not flipMode and PlayerObjects.Dad2 or PlayerObjects.BF2)
				elseif note.dType == 2 then
					char = note.NoteData <= 3 and (not flipMode and PlayerObjects.Dad2 or PlayerObjects.BF2)
				end
			elseif note.bro ~= 0 then
				if type(note.bro) == "string" then
					if not PlayerObjects[note.bro] then
						warn("Invalid Character")
						break;
					else
						char = PlayerObjects[note.bro]
					end
				elseif note.bro == 1 then
					char = (not flipMode and PlayerObjects.Dad2 or PlayerObjects.BF2)
				elseif note.bro == 2 then
					char = note.NoteData <= 3 and (not flipMode and PlayerObjects.Dad2 or PlayerObjects.BF2)
				elseif note.bro == 3 then
					char = (not flipMode and PlayerObjects.Dad2 or PlayerObjects.BF2)
					char:PlayAnimation("sing" .. sDir[note.NoteData+1],true)
					char = (not flipMode and PlayerObjects.Dad or PlayerObjects.BF)
				elseif note.bro == 4 then
					char = (not flipMode and PlayerObjects.Dad or PlayerObjects[modcharts[1]:GetAttribute("CurChar")])
					if modcharts[1]:GetAttribute("CurChar") == "All" then
						note.noAnimation = true; -- this is here for a reason
						for _,ch in pairs(PlayerObjects) do
							ch:PlayAnimation("sing" .. sDir[note.NoteData+1],true)
						end
					end
				end
			else
				char = (not flipMode and PlayerObjects.Dad or PlayerObjects.BF)
			end
			if not note.noAnimation then
				char:PlayAnimation("sing" .. sDir[note.NoteData+1],true)
				note:Destroy()
			elseif note.CustomAnimation then
				print(note.CustomAnimation)
				char:PlayAnimation(note.CustomAnimation)
			end
			break;
		end
	end
end

function module.GhostTap()
	opponentCombo = 0
end

function module.fakeScorePopup(noteDiff)
	local rating = ScoreUtils:GetRating(noteDiff)
	local screenMul = (cam.ViewportSize.X/defaultScreenSize.X) * module.settings.ratingSize
	local ratingText = Instance.new("ImageLabel")
	ratingText.BackgroundTransparency=1
	--ratingText.Font=Enum.Font.Cartoon
	--ratingText.TextColor3=rating=='sick' and Color3.fromRGB(19, 224, 255) or rating=='good' and Color3.fromRGB(55, 236, 14) or Color3.new(1, 0, 0) or 'bad' and Color3.fromRGB(208, 1, 0) or rating=='trash' and Color3.fromRGB(81, 59, 44) or Color3.new(1,1,1)
	--ratingText.TextStrokeColor3=Color3.new(0,0,0)
	--ratingText.TextStrokeTransparency=.8
	--ratingText.TextSize=94
	local scaleSize = ((ratingNamesSize[rating]) * 0.45) * screenMul -- this should fix the size difference of the opponent's ratings
	--ratingText.Size = UDim2.fromOffset(scaleSize.X / (ScreenRatio/defaultScreenRatio),scaleSize.Y / (ScreenRatio/defaultScreenRatio))
	ratingText.Size = UDim2.fromOffset(scaleSize.X,scaleSize.Y)
	if SongIdInfo.RatingSet then
		ratingText.Image=SongIdInfo.RatingSet[rating]
	else
		ratingText.Image=ScoreUtils.ratingNames[rating]
	end
	--ratingText.Image=ScoreUtils.ratingNames[rating]
	ratingText.AnchorPoint=Vector2.new(.5,.5)
	ratingText.Position=UDim2.new(.5,-40,.5,140)
	local Side = module.PositioningParts.PlayAs and "Right" or "Left"
	ratingText:SetAttribute("Side", Side)
	ratingText:SetAttribute("Acceleration",Vector2.new(0,550))
	ratingText:SetAttribute("Origin",Vector2.new(0,0))
	ratingText:SetAttribute("Offset",Vector2.new(0,0))
	ratingText:SetAttribute("Velocity",Vector2.new(RNG:NextInteger(0,10),-RNG:NextInteger(140,175)))

	table.insert(ratingLabels,ratingText)
	ratingText.Parent = script.Parent
	local tw = game:service'TweenService':Create(ratingText,TweenInfo.new(.2/speedModifier,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,Conductor.crochet*0.001),{ImageTransparency = 1})--{TextTransparency=1,TextStrokeTransparency=1})
	tw.Completed:connect(function()
		ratingText:destroy()
		pcall(game.Destroy,tw)
	end)
	tw:Play()
	if (not module.settings.hideOppCombo) then
		local displayedCombo = '';
		if(opponentCombo<100) then -- 0
			displayedCombo=displayedCombo..'0'
		end
		if(opponentCombo<10) then -- 00
			displayedCombo=displayedCombo..'0'
		end

		displayedCombo = displayedCombo .. opponentCombo

		for i,v in next, string.split(displayedCombo,'') do
			local comboText = game.ReplicatedStorage.Assets.Numbers:FindFirstChild(v):Clone()
			comboText.AnchorPoint=Vector2.new(.5,.5)
			comboText.Size = UDim2.new(comboText.Size.X.Scale*screenMul,comboText.Size.X.Offset*screenMul,
				comboText.Size.Y.Scale*screenMul,comboText.Size.Y.Offset*screenMul
			)
			comboText.Size = UDim2.new(comboText.Size.X.Scale*.55,comboText.Size.X.Offset*.55,comboText.Size.Y.Scale*.55,comboText.Size.Y.Offset*.55)
			comboText.Position=UDim2.new(.5,(-40 + ((43)*i))*screenMul,.5,80*screenMul)
			comboText:SetAttribute("Acceleration",Vector2.new(0,RNG:NextInteger(200,300)))
			comboText:SetAttribute("Side", Side)
			comboText:SetAttribute("Velocity",Vector2.new(RNG:NextInteger(-5,5),-RNG:NextInteger(140,160)))
			comboText:SetAttribute("Offset",Vector2.new((26*i)-90,-60)*screenMul)
			table.insert(ratingLabels,comboText)
			comboText.Parent = script.Parent
			local tw = game:service'TweenService':Create(comboText,TweenInfo.new(.2/speedModifier,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,Conductor.crochet*0.002),{ImageTransparency=1})
			tw.Completed:connect(function()
				comboText:destroy()
				pcall(game.Destroy,tw)
			end)
			tw:Play()
		end
	end
end

function module.OpponentMissNote(strum,noteDiff,noteType,noteDir,sussy)
	opponentCombo=0
	for i,v in pairs(loadedModchartData) do
		coroutine.resume(coroutine.create(function()
			if v.P2NoteMiss then
				v.P2NoteMiss(noteType, noteDir)
			end
		end))
	end
end

function MissNote(note)
	if note then
		for i,v in pairs(loadedModchartData) do
			coroutine.resume(coroutine.create(function()
				if v.P1NoteMiss then
					v.P1NoteMiss(note.Type, note.NoteData, note)
				end
			end))
		end
		if note.Type ~= "None" then
			--[[if note.Type == "Knife" then
				PlayerObjects.BF:PlayAnimation("dodge")
				rates.miss-=1
				module.PlayerStats.Health+=0.075
			elseif note.Type == "BloodyKnife" then
				PlayerObjects.BF:PlayAnimation("dodge")
			elseif note.Type == 'MattCaution' or note.Type == "Spam" then
				if module.settings.DeathEnabled then
					module.Kill()
					playSound(11003995387,2)
				else
					module.PlayerStats.Health-=1
					module.PlayerStats.Score-=13500;
				end
			elseif note.Type == "Bullet" and note.NoteGroup == "BlackBetrayal" then
				module.PlayerStats.Health-=1
			elseif note.Type == "Static" then
				module.PlayerStats.Health-=(2/5)
				local object = gameUI.realGameUI.OverlaySprite
				local static = Sprite.new(object,true,1,true)
				object.Image = "rbxassetid://11089800126"
				object.Visible = true
				local xml = game.ReplicatedStorage.Modules.Assets.MiscXML["hitStatic.xml"]
				static:AddSparrowXML(xml,"shabam","staticANIMATION",24,false,8).ImageId = "rbxassetid://11089800126"
				static.GUI.Visible = true
				static:PlayAnimation("shabam")
				local MATH = random(1,2)
				if MATH == 1 then
					playSound(11090112135,2)
				else
					playSound(11090114488,2)
				end
			
			else
			
			end
			]]
			module.PlayerStats.Health-=.075;
			module.PlayerStats.Score-=50;
		end
		
		if(songData.needsVoices)then
			voiceSound.Volume = 0
		end
		
		module.PlayerStats.Health-=.075;
		module.PlayerStats.Score-=50;

		combo=0; -- To disable ghost tapping move these lines out of this statement \/
		rates.miss+=1
		--playSound(6374202044,0.5) -- record scratch sound removed cause annoying
		
		UpdateAccuracy()
		module.PlayerStats.Health=math.clamp(module.PlayerStats.Health,0,module.PlayerStats.MaxHealth)
		GameplayEvent:Fire("NoteMiss",module.PlayerStats.Score,not not note)
	end
	
end

function GetNextHittable(lane)
	for i = 1,#lane do
		if(lane[i].CanBeHit and not lane[i].GoodHit and not lane[i].TooLate)then
			return lane[i],i
		end
	end
end

function CheckInput(bind,io)
	local dir = GetDirectionForKey(bind)
	local hitSomething=false;

	if(dir)then
		local nextHit = GetNextHittable(noteLanes[dir])
		if(nextHit and nextHit.CanBeHit and not nextHit.IsSustain and not nextHit.TooLate and not nextHit.GoodHit) and playerStrums[nextHit.NoteData+1].CanBePressed then
			hitSomething=true;
			GoodHit(nextHit);
		end

		if(not hitSomething and GetNextHittable(susNoteLanes[dir])==nil) then
			MissNote();
		end
	end
end

UserInputBind.InputEvents.Began:Connect(function(BindName,io)
	if not generatedSong then return end
	CheckInput(BindName,io);
end)

function UpdateAccuracy()
	totalPlayed+=1
	accuracy = totalNotesHit/totalPlayed*100
end

local dDeb={[0]=false,[1]=false,[2]=false,[3]=false,[4]=false,[5]=false,[6]=false,[7]=false,[8]=false}
function checkHeldKeys()
	local heldDirections = HeldDirections()
	for i = 1,#notes do
		local n = notes[i]
		if Botplay then
			if(n.CanBeHit and n.MustPress) and playerStrums[n.NoteData+1].CanBePressed then
				if n.IsSustain then
					GoodHit(n)
				else -- Make it delayed so it is a "good" hit
					delay(0.14 / speedModifier, function()
						GoodHit(n);
					end)
				end
			end
		else
			if(n.CanBeHit and n.MustPress and heldDirections[n.NoteData] and n.IsSustain) and playerStrums[n.NoteData+1].CanBePressed then
				GoodHit(n);
			end
		end
	end
	for i,v in next, playerStrums do
		if(heldDirections[i-1] and (v.CurrAnimation:sub(-7) ~= "confirm"))then
			v:PlayAnimation("pressed")
			if dDeb[i-1] then
				continue
			end
			dDeb[i-1] = true
		elseif(not heldDirections[i-1])then
			if not Botplay then
				v:PlayAnimation("static")
			end
			if not dDeb[i-1] then
				continue
			end
			dDeb[i-1] = false
		end
	end
end

instrSound.DidLoop:connect(module.endSong)

function beatHit()
	lastBeat+=Conductor.crochet;
	totalBeats+=1;
	table.sort(notes,function(a,b)
		return a.Y>b.Y
	end)

	tweenIconSize(DadIcon,0.9 * (60/Conductor.BPM)/speedModifier)
	tweenIconSize(BFIcon,0.9 * (60/Conductor.BPM)/speedModifier)

	local currentNoteIndex = math.floor(curStep/16)
	if(songData.notes[currentNoteIndex])then
		local noteData = songData.notes[currentNoteIndex]
		if(noteData.changeBPM)then
			local oldBPM = Conductor.BPM
			Conductor:ChangeBPM(noteData.bpm)
			print(("(new: %s, old: %s) BPM"):format(tostring(Conductor.BPM),tostring(oldBPM)))
		end
	end

	if(camZooming and camControls.hudZoom < 0.85 and curBeat%4==0 and module.settings.CameraZooms) and not camControls.noBump then
		-- Makes the camera zoom in on the beat
		camControls.hudZoom+=0.015
		camControls.camZoom+=0.03
	end

	for i,v in pairs(loadedModchartData) do
		coroutine.resume(coroutine.create(function()
			if v.BeatHit then
				v.BeatHit(totalBeats)
			end
		end))
	end

	if PlayerObjects.BF and (not PlayerObjects.BF:IsSinging()) and totalBeats%2 == 1 then
		PlayerObjects.BF:Dance()
	end
	if PlayerObjects.Dad and (not PlayerObjects.Dad:IsSinging()) and totalBeats%2 == 1 then
		PlayerObjects.Dad:Dance()
	end

	-- TimeBar UI
	if TimeBar.Visible and generatedSong then
		local DSPos = 0
		if Conductor.Downscroll then
			DSPos = UDim.new(1,-6)
		else
			DSPos = UDim.new(0,6)
		end

		local goalTime = songLength
		local songPos = (Conductor.SongPos/1000)

		if falseSongLength > -1 then
			goalTime = falseSongLength
		end

		TimeBar.BarContainer.Progress.Size = UDim2.fromScale(0,1)
		TimeBar.Position = UDim2.new(UDim.new(.5,0),DSPos)
		if songPos > 0 then
			TimeBar.BarContainer.Progress.Size = UDim2.fromScale(songPos/goalTime,1)
			local timeleft = goalTime-songPos
			TimeBar.BarContainer.Time.Text = convertToHMS(timeleft)
			TimeBar.BarContainer.Time.Position = UDim2.new(0,0,0,(DSPos.Offset))
		end
	end
end

function stepHit()
	totalSteps+=1
	lastStep+=Conductor.stepCrochet

	if(Conductor.SongPos>lastStep+(Conductor.stepCrochet*3))then
		lastStep=Conductor.SongPos
		totalSteps=math.ceil(lastStep/Conductor.stepCrochet);
	end
	
	if totalSteps > curStep then
		totalSteps = curStep
	end
	if totalSteps < curStep then
		for i,v in pairs(loadedModchartData) do
			coroutine.resume(coroutine.create(function()
				if(v and v.StepHit)then -- checks if there is a modchart function for StepHit
					v.StepHit(totalSteps)
				end	
			end))
		end
		
		totalSteps +=1
	end

	if(totalSteps%4==0)then
		beatHit()
	end

	for i,v in pairs(loadedModchartData) do
		coroutine.resume(coroutine.create(function()
			if(v and v.StepHit)then -- checks if there is a modchart function for StepHit
				v.StepHit(totalSteps)
			end	
		end))
	end

	local songPos = (Conductor.SongPos/1000)
	local instrPos,voicePos = instrSound.TimePosition/instrSound.PlaybackSpeed,voiceSound.TimePosition/voiceSound.PlaybackSpeed
	local offset = (SongIdInfo.Offset or 0) + (module.settings.ChartOffset/1000)

	if(songData.needsVoices)then -- When the song has a voices song it checks to see if the TimePosition of the song is off by a bit.
		if(instrPos-(songPos - offset)>(3 * speedModifier) or voicePos-(songPos - offset) > (3 * speedModifier))then
			resync() -- This will readjust the songs to be at the correct time
		end
	else
		if(instrPos - (songPos - offset)>(3 * speedModifier))then
			resync()
		end
	end
end

local function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

function getPosFromTime(strumTime,speed)
	local idx = 0;
	while idx<#sliderVelocities do
		if(strumTime<sliderVelocities[idx+1].startTime)then
			break
		end
		idx+=1;
	end
	return getPosFromTimeSV(strumTime,idx,speed)
end


function getSVFromTime(strumTime)
	local idx = 0;
	while idx<#sliderVelocities do
		if(strumTime<sliderVelocities[idx+1].startTime)then
			break
		end
		idx+=1;
	end
	idx-=1;
	if(idx<=0)then
		return initialSpeed
	end
	return initialSpeed*(sliderVelocities[idx+1].multiplier)
end

function getSpeed(strumTime)
	return getSVFromTime(strumTime)*(initialSpeed*(1/.45))
end

shared.getSpeed=getSpeed;

function getPosFromTimeSV(strumTime,svIdx,speed)
	if not speed then
		speed = 1
	end
	if(svIdx==0 or svIdx==nil)then
		return strumTime*(initialSpeed*speed)
	end

	svIdx-=1;

	local curPos = velocityMarkers[svIdx+1]
	curPos+=((strumTime-sliderVelocities[svIdx+1].startTime)*(initialSpeed*sliderVelocities[svIdx+1].multiplier*speed));
	return curPos
end

function updatePosVars()
	local offset = (SongIdInfo.Offset or 0) + (module.settings.ChartOffset/1000)
	Conductor.SongPos = Conductor.songPosition+(offset*1000) 
	Conductor.TimePos = Conductor.timePosition+offset

	Conductor.AdjustedSongPos = Conductor.SongPos*instrSound.PlaybackSpeed;
	Conductor.CurrentTrackPos = getPosFromTime(Conductor.SongPos)

	checkEventNote(Conductor.SongPos, offset)
end

function module.receptChangeSkin(Receptor,NSLabel,XML)
	local i = Receptor.Index
	Receptor.Animations = {}
	Receptor.GUI.Image = NSLabel.Image
	Receptor:AddSparrowXML(XML,'green', 'arrowUP');
	Receptor:AddSparrowXML(XML,'blue', 'arrowDOWN');
	Receptor:AddSparrowXML(XML,'purple', 'arrowLEFT');
	Receptor:AddSparrowXML(XML,'red', 'arrowRIGHT');
	if songData.mania ~= 0 then -- shaggy system
		local nSuf = {"LEFT","DOWN","UP","RIGHT"}
		local pPre = {"left","down","up","right"}
		if songData.mania == 1 then
			nSuf = {"LEFT","UP","RIGHT","LEFT","DOWN","RIGHT"}
			pPre = {"left","up","right","yel","down","dark"}
		elseif songData.mania == 2 then
			nSuf = {"LEFT","DOWN","UP","RIGHT","SPACE","LEFT","DOWN","UP","RIGHT"}
			pPre = {"left","down","up","right","white","yel","violet","black","dark"}
		elseif songData.mania == 3 then
			nSuf = {"LEFT","DOWN","SPACE","UP","RIGHT"}
			pPre = {"left","down","white","up","right"}
		elseif songData.mania == 4 then
			nSuf = {"LEFT","UP","RIGHT","SPACE","LEFT","DOWN","RIGHT"}
			pPre = {"left","up","right","white","left","up","right"}
		elseif songData.mania == 5 then
			nSuf = {"LEFT","DOWN","UP","RIGHT","LEFT","DOWN","UP","RIGHT"}
			pPre = {"left","down","up","right","yel","violet","black","dark"}
		end
		Receptor:AddSparrowXML(XML,'static', 'arrow' .. nSuf[i]);
		Receptor:AddSparrowXML(XML,'pressed', pPre[i] .. ' press', 24, false);
		Receptor:AddSparrowXML(XML,'confirm', pPre[i] .. ' confirm', 24, false);
	else -- vanilla system
		if(i==1)then
			Receptor:AddSparrowXML(XML,'static', 'arrowLEFT');
			Receptor:AddSparrowXML(XML,'pressed', 'left press', 24, false);
			Receptor:AddSparrowXML(XML,'confirm', 'left confirm', 24, false);
		elseif(i==2)then
			Receptor:AddSparrowXML(XML,'static', 'arrowDOWN');
			Receptor:AddSparrowXML(XML,'pressed', 'down press', 24, false);
			Receptor:AddSparrowXML(XML,'confirm', 'down confirm', 24, false);
		elseif(i==3)then
			Receptor:AddSparrowXML(XML,'static', 'arrowUP');
			Receptor:AddSparrowXML(XML,'pressed', 'up press', 24, false);
			Receptor:AddSparrowXML(XML,'confirm', 'up confirm', 24, false);
		elseif(i==4)then
			Receptor:AddSparrowXML(XML,'static', 'arrowRIGHT');
			Receptor:AddSparrowXML(XML,'pressed', 'right press', 24, false);
			Receptor:AddSparrowXML(XML,'confirm', 'right confirm', 24, false);
		end
	end
	Receptor:PlayAnimation("static",true)
end

local function receptChangeSkin(Receptor,NSLabel,XML)
	local i = Receptor.Index
	Receptor.Animations = {}
	Receptor.GUI.Image = NSLabel.Image
	Receptor:AddSparrowXML(XML,'green', 'arrowUP');
	Receptor:AddSparrowXML(XML,'blue', 'arrowDOWN');
	Receptor:AddSparrowXML(XML,'purple', 'arrowLEFT');
	Receptor:AddSparrowXML(XML,'red', 'arrowRIGHT');
	if songData.mania ~= 0 then -- shaggy system
		local nSuf = {"LEFT","DOWN","UP","RIGHT"}
		local pPre = {"left","down","up","right"}
		if songData.mania == 1 then
			nSuf = {"LEFT","UP","RIGHT","LEFT","DOWN","RIGHT"}
			pPre = {"left","up","right","yel","down","dark"}
		elseif songData.mania == 2 then
			nSuf = {"LEFT","DOWN","UP","RIGHT","SPACE","LEFT","DOWN","UP","RIGHT"}
			pPre = {"left","down","up","right","white","yel","violet","black","dark"}
		elseif songData.mania == 3 then
			nSuf = {"LEFT","DOWN","SPACE","UP","RIGHT"}
			pPre = {"left","down","white","up","right"}
		elseif songData.mania == 4 then
			nSuf = {"LEFT","UP","RIGHT","SPACE","LEFT","DOWN","RIGHT"}
			pPre = {"left","up","right","white","left","up","right"}
		elseif songData.mania == 5 then
			nSuf = {"LEFT","DOWN","UP","RIGHT","LEFT","DOWN","UP","RIGHT"}
			pPre = {"left","down","up","right","yel","violet","black","dark"}
		end
		Receptor:AddSparrowXML(XML,'static', 'arrow' .. nSuf[i]);
		Receptor:AddSparrowXML(XML,'pressed', pPre[i] .. ' press', 24, false);
		Receptor:AddSparrowXML(XML,'confirm', pPre[i] .. ' confirm', 24, false);
	else -- vanilla system
		if(i==1)then
			Receptor:AddSparrowXML(XML,'static', 'arrowLEFT');
			Receptor:AddSparrowXML(XML,'pressed', 'left press', 24, false);
			Receptor:AddSparrowXML(XML,'confirm', 'left confirm', 24, false);
		elseif(i==2)then
			Receptor:AddSparrowXML(XML,'static', 'arrowDOWN');
			Receptor:AddSparrowXML(XML,'pressed', 'down press', 24, false);
			Receptor:AddSparrowXML(XML,'confirm', 'down confirm', 24, false);
		elseif(i==3)then
			Receptor:AddSparrowXML(XML,'static', 'arrowUP');
			Receptor:AddSparrowXML(XML,'pressed', 'up press', 24, false);
			Receptor:AddSparrowXML(XML,'confirm', 'up confirm', 24, false);
		elseif(i==4)then
			Receptor:AddSparrowXML(XML,'static', 'arrowRIGHT');
			Receptor:AddSparrowXML(XML,'pressed', 'right press', 24, false);
			Receptor:AddSparrowXML(XML,'confirm', 'right confirm', 24, false);
		end
	end
	Receptor:PlayAnimation("static",true)
end

function module.ChangeNoteSkin(name,boolSide,force,mania)
	local NSFolder
	NSFolder =  repS.Modules.Assets["noteSkins" .. DirAmmo[songData.mania] .. "K"]
	local skin2Change = NSFolder:FindFirstChild(name or "Original")
	local selNoteXml = (skin2Change:FindFirstChild("XML") or skin2Change:FindFirstChild("XMLRef")) or skin2Change[songData.mania]
	if force then
		selNoteXml = (skin2Change:FindFirstChild("XML") or skin2Change:FindFirstChild("XMLRef")) or skin2Change[mania]
	end
	if selNoteXml:IsA("ObjectValue") and selNoteXml.Name == "XMLRef" then
		selNoteXml = selNoteXml.Value
	end
	if boolSide ~= nil and internalSettings.useDuoSkins then -- false=dad, true=bf
		local strums = boolSide and rightStrums or leftStrums
		if force==true then
			if module.settings["NoteSkin_" .. DirAmmo[mania] .. "K"] ~= "Default" then
				local strums = flipMode and playerStrums or dadStrums
				for i,Receptor in next,strums do
					receptChangeSkin(Receptor,skin2Change,selNoteXml)
				end
			else
				for index,Receptor in next,strums do
					receptChangeSkin(Receptor,skin2Change,selNoteXml)
				end
			end
		else
			if module.settings["NoteSkin_" .. DirAmmo[mania] .. "K"] ~= "Default" then
				local strums = flipMode and playerStrums or dadStrums
				for i,Receptor in next,strums do
					receptChangeSkin(Receptor,skin2Change,selNoteXml)
				end
			else
				for index,Receptor in next,allReceptors do
					receptChangeSkin(Receptor,skin2Change,selNoteXml)
				end
			end
		end
		if module.settings["NoteSkin_" .. DirAmmo[mania] .. "K"] ~= "Default" then
			local strums = flipMode and playerStrums or dadStrums
			for i,Receptor in next,strums do
				receptChangeSkin(Receptor,skin2Change,selNoteXml)
			end
		else
			for index,Receptor in next,strums do
				receptChangeSkin(Receptor,skin2Change,selNoteXml)
			end
		end
	else
		if module.settings["NoteSkin_" .. DirAmmo[songData.mania] .. "K"] ~= "Default" then
			local strums = flipMode and playerStrums or dadStrums
			for i,Receptor in next,strums do
				receptChangeSkin(Receptor,skin2Change,selNoteXml)
			end
		else
			for index,Receptor in next,allReceptors do
				receptChangeSkin(Receptor,skin2Change,selNoteXml)
			end
		end
	end

	internalSettings.currentNoteSkinChange = {
		SkinId = skin2Change.Image;
		XML = selNoteXml;
		Side = boolSide
	}

	for _,Note in next,notes do
		if internalSettings.currentNoteSkinChange.Side == nil then
			if Note.Side ~= (module.PositioningParts.PlayAs and "Right" or "Left") then
				Note:ChangeSkin(internalSettings.currentNoteSkinChange.XML ,internalSettings.currentNoteSkinChange.SkinId) 
			elseif module.settings["NoteSkin_" .. DirAmmo[songData.mania] .. "K"] == "Default" then
				if Note then
					Note:ChangeSkin(internalSettings.currentNoteSkinChange.XML ,internalSettings.currentNoteSkinChange.SkinId) 
				end
			end
		elseif Note.Side == (internalSettings.currentNoteSkinChange.Side and "Right" or "Left") then
			Note:ChangeSkin(internalSettings.currentNoteSkinChange.XML ,internalSettings.currentNoteSkinChange.SkinId) 
		end
	end
end

if _G.HBGameHandlerConnection then
	_G.HBGameHandlerConnection:Disconnect()
end

shared.getNotes = function()
	return unspawnedNotes
end

function CheckSpawns()
	for i=1,4 do -- try to iterate thru 4 notes, then break off the loop if it a note doesn't reach the spawn point yet.
		if(unspawnedNotes[1])then
			if(Conductor.CurrentTrackPos-getPosFromTime(unspawnedNotes[1].StrumTime) > -3000)then
				local dunceNote:Note = unspawnedNotes[1]
				dunceNote.NoteObject.Parent=dunceNote.Parent
				dunceNote.Animation.Scale = Vector2.new(dunceNote.Animation.Scale.X,dunceNote.Animation.Scale.Y) * (internalSettings.autoSize * module.settings.customSize)  
				table.insert(notes,dunceNote)
				if(dunceNote.MustPress)then
					if(dunceNote.IsSustain)then
						table.insert(susNoteLanes[dunceNote.NoteData+1],dunceNote);
					else
						table.insert(noteLanes[dunceNote.NoteData+1],dunceNote);
					end
					table.sort(susNoteLanes[dunceNote.NoteData+1],function(a,b)
						return b.StrumTime>a.StrumTime
					end)
					table.sort(noteLanes[dunceNote.NoteData+1],function(a,b)
						return b.StrumTime>a.StrumTime
					end)
				else
					table.insert(opponentNotes,dunceNote);
					table.sort(opponentNotes,function(a,b)
						return b.StrumTime>a.StrumTime
					end)
				end
				local receptorTarget
				if dunceNote.MustPress then
					receptorTarget = playerStrums[dunceNote.NoteData+1]
				else
					receptorTarget = dadStrums[dunceNote.NoteData+1]
				end
				dunceNote.ReceptorTarget = receptorTarget
				dunceNote.Transparency = internalSettings.NoteSpawnTransparency
				if internalSettings.currentNoteSkinChange and internalSettings.currentNoteSkinChange.SkinId ~= dunceNote.NoteObject.Image then
					if internalSettings.currentNoteSkinChange.Side == nil then
						if dunceNote.Side ~= (module.PositioningParts.PlayAs and "Right" or "Left") then
							dunceNote:ChangeSkin(internalSettings.currentNoteSkinChange.XML ,internalSettings.currentNoteSkinChange.SkinId) 
						elseif module.settings["NoteSkin_" .. DirAmmo[songData.mania] .. "K"] == "Default" then
							dunceNote:ChangeSkin(internalSettings.currentNoteSkinChange.XML ,internalSettings.currentNoteSkinChange.SkinId) 
						end
					elseif dunceNote.Side == (internalSettings.currentNoteSkinChange.Side and "Right" or "Left") then
						dunceNote:ChangeSkin(internalSettings.currentNoteSkinChange.XML ,internalSettings.currentNoteSkinChange.SkinId) 
					end
				end
				--print("Spawn note!")
				table.remove(unspawnedNotes,1)
			else
				break
			end
		end
	end
end

function Format(Int)
	return string.format("%02i", Int)
end

function convertToHMS(Seconds)
	local Minutes = (Seconds - Seconds%60)/60
	Seconds = Seconds - Minutes*60
	local Hours = (Minutes - Minutes%60)/60
	Minutes = Minutes - Hours*60
	return Minutes ..":"..Format(Seconds)
end

-- May be unused for now.
--[[local function lowPriorityUpdate() -- An update function for less needed info like Scores.
	while true do
		if generatedSong then
			if module.PlayerStats.Health < 0.4 then
				plrIcon:PlayAnimation("Dead")
				oppIcon:PlayAnimation("Winning")
			elseif module.PlayerStats.Health > 1.6 then
				plrIcon:PlayAnimation("Winning")
				oppIcon:PlayAnimation("Dead")
			else
				plrIcon:PlayAnimation("Alive")
				oppIcon:PlayAnimation("Alive")
			end

			local likeRating = "";
			local rating2 = ""
			local rating3 = ""

			if accuracy == 100 then
				rating2 = "Perfect!"
				rating3 = "SS"
			elseif accuracy >= 90 then
				rating2 = "Sick!"
				rating3 = "S"
			elseif accuracy >= 80 then
				rating2 = "Great"
				rating3 = "A"
			elseif accuracy >= 70 then
				rating2 = "Good"
				rating3 = "B"
			elseif accuracy == 69 then
				rating2 = "Nice"
				rating3 = "C"
			elseif accuracy >= 60 then
				rating2 = "Meh"
				rating3 = "C"
			elseif accuracy >= 50 then
				rating2 = "Bruh"
				rating3 = "D"
			elseif accuracy >= 40 then
				rating2 = "Bad"
				rating3 = "F"
			elseif accuracy >= 0 then
				rating2 = ""
			end

			if rates.miss < 1 then
				if totalPlayed < 1 then likeRating = "?" end
				if (rates.sick > 0) then likeRating = "SFC" end
				if (rates.good > 0) then likeRating = "GFC" end
				if (rates.bad > 0) then likeRating = "FC" end
			elseif (rates.miss > 0 and rates.miss < 10) then
				likeRating = "SDCB"
			elseif (rates.miss >= 10) then
				likeRating = "Clear"
			end

			ScoreLabel.Text = string.format("Score: %d | Misses: %d | Rating: %s (%s%%) - %s",
				module.PlayerStats.Score,
				rates.miss,
				tostring(rating2),
				tostring(round(math.floor(accuracy), 5)),
				tostring(likeRating)
			)
		if songData.song == "Unlimited Power" then
			ScoringAlt.Misses.Text = "Misses: " .. tostring(rates.miss)
			ScoringAlt.Combo.Text = tostring(combo)
			ScoringAlt.Score.Text = tostring(module.PlayerStats.Score)
			ScoringAlt.Accuracy.Text = tostring(round2(accuracy)) .. "% [" ..tostring(likeRating) .. "]"
			ScoringAlt.Rank.Text = tostring(rating2)
		end
		if customScoreFormat == "YAFN Engine" then
			--gameUI.ScoreLabel.BackgroundTransparency = 0.5
			ScoreLabel.Size = UDim2.fromScale(1,0.036)
			ScoreLabel.Text = "Score: " .. tostring(module.PlayerStats.Score) .. " | Combo: " .. tostring(combo) .. " | Misses: " .. tostring(rates.miss) .. " | Accuracy: " .. tostring(round(floor(accuracy),4)) .. "%"
		elseif customScoreFormat == "Psych Engine" then
			--gameUI.ScoreLabel.BackgroundTransparency = 1
			ScoreLabel.Size = UDim2.fromScale(1,0.05)
			ScoreLabel.Text = "Score: " .. tostring(module.PlayerStats.Score) .. " | Misses: " .. tostring(rates.miss) .. " | Rating: ".. tostring(rating2) .. " (" .. tostring(round(floor(accuracy),5)) .. "%)".. " - " .. tostring(likeRating)
		elseif customScoreFormat == "Kade Engine" then
			--gameUI.ScoreLabel.BackgroundTransparency = 1
			ScoreLabel.Size = UDim2.fromScale(1,0.05)
			ScoreLabel.Text = "Score: " .. tostring(module.PlayerStats.Score) .. " | Combo Breaks: " .. tostring(rates.miss) .. " | Accuracy: " .. tostring(round(floor(accuracy),4)) .. "%".. " | (" .. tostring(likeRating) .. ")"
		end
		
		if(plr.Character)then
			plr.Character:destroy()
			plr.Character=nil
		end
		end
		wait(0.038)
	end
end

coroutine.wrap(lowPriorityUpdate)() -- Has a 0.05 wait time (which runs at a slower interval)
]]

_G.HBGameHandlerConnection = RS.RenderStepped:Connect(function(deltaTime)

	if(not generatedSong)then return end
	if module.PositioningParts.PlayAs == nil then module.endSong();return end

	if(startingSong)then
		if(startedCountdown)then
			Conductor.timePosition+=deltaTime * speedModifier
			Conductor.songPosition+=(deltaTime*1000) * speedModifier
			updatePosVars();
			if(Conductor.songPosition>=0)then
				module.startSong()
			end
			CheckSpawns()
		end
	else
		Conductor.timePosition+=(deltaTime) * speedModifier
		Conductor.songPosition+=(deltaTime*1000) * speedModifier
		updatePosVars();
		CheckSpawns()
	end

	local lastNote:Note

	curStep= lastBPMChange.stepTime + math.floor((Conductor.SongPos-lastBPMChange.songTime)/Conductor.stepCrochet);

	if (Conductor.SongPos>lastStep+Conductor.stepCrochet-Conductor.safeZoneOffset or Conductor.SongPos<lastStep+Conductor.safeZoneOffset)then
		if(Conductor.SongPos>lastStep+Conductor.stepCrochet)then
			stepHit()
		end
	end
	curBeat=math.round(curStep/4);

	if(generatedSong)then
		for i = 1,#playerStrums do
			local sprite = playerStrums[i];
			if(playerNoteOffsets[i].X~=0 and playerNoteOffsets[i].Y~=0)then
				sprite.GUI.Position = AddPointToUDim2(UDim2.new(
					UDim.new(0,(112*(i-1)+56) * (internalSettings.autoSize * module.settings.customSize)),
					Conductor.Downscroll 
						and UDim.new(1,-106 ) 
						or UDim.new(0,106 )
					) , playerNoteOffsets[i] )--]]           
			end
		end
		for i = 1,#dadStrums do
			local sprite = dadStrums[i];
			if(opponentNoteOffsets[i].X~=0 and opponentNoteOffsets[i].Y~=0)then
				sprite.GUI.Position = AddPointToUDim2(UDim2.new(
					UDim.new(0,(112*(i-1)+56) * (internalSettings.autoSize * module.settings.customSize)),
					Conductor.Downscroll 
						and UDim.new(1,-106 ) 
						or UDim.new(0,106 )
					) , opponentNoteOffsets[i] )--]]
			end
			-- TODO: Alpha, etc
		end

		if startedCountdown then
			for i,v in pairs(loadedModchartData) do
				coroutine.resume(coroutine.create(function()
					if(v and v.Update) and generatedSong then
						v.Update(deltaTime * speedModifier)
					end
				end))
			end	
		end

		--[[for i = #lane,1,-1 do
			local c = lane[i];
			local n = lane[i-1]
			if(i==1)then
				break;
			end
			if(c~=n and abs(c.StrumTime-n.StrumTime)<10 )then
				warn("DELETED STACKED NOTE",lane[i].StrumTime)
				lane[i]:Destroy();
				table.remove(lane,i);
			end
		end]]


		for i = 1,#notes do
			local daNote=notes[i]
			if(daNote.Update==nil)then
				continue
			end
			if (not daNote.Destroyed)then
				local offsets = playerNoteOffsets[daNote.NoteData+1]
				local receptor = playerStrums[daNote.NoteData+1]
				if(not daNote.MustPress)then
					receptor = dadStrums[daNote.NoteData+1];
					offsets = opponentNoteOffsets[daNote.NoteData+1]
				end --(not daNote.MustPress and daNote.GoodHit) and module.PositioningParts.isOpponentAvailable == nil and daNote.MissPunish and startedCountdown
				if(not daNote.MustPress and daNote.GoodHit) and module.PositioningParts.isOpponentAvailable == nil and daNote.MissPunish and startedCountdown and daNote.shouldPress then
					-- the opponent code
					local sDir
					local theStrum = dadStrums[daNote.NoteData+1]
					theStrum:PlayAnimation(theStrum.Animations[daNote.Type.."_confirm"] and daNote.Type.."_confirm" or "confirm",true)
					if (flipMode and PlayerObjects.BF or PlayerObjects.Dad) then
						Switch()
						:default(function() 
							sDir = {"LEFT","DOWN","UP","RIGHT"}
						end)
						:case(1,function()
							if(module.settings.NoteSkin_6K=='2v200' or module.settings.NoteSkin_6K=='Default' and SongIdInfo.NoteSkin=='2v200')then
								sDir = {"LEFT","DOWN","RIGHT","LEFT","UP","RIGHT"}
							else
								sDir = {"LEFT","UP","RIGHT","LEFT","DOWN","RIGHT"}
							end
						end)
						:case(2,function()
							sDir = {"LEFT","DOWN","UP","RIGHT","UP","LEFT","DOWN","UP","RIGHT"}
						end)
						:case(3,function()
							sDir = {"LEFT","DOWN","UP","UP","RIGHT"}
						end)
						:case(4,function()
							sDir = {"LEFT","UP","RIGHT","UP","LEFT","DOWN","RIGHT"}
						end)
						:case(5,function()
							sDir = {"LEFT","DOWN","UP","RIGHT","LEFT","DOWN","UP","RIGHT"}
						end)(math.abs(songData.mania))
						local char
						if daNote.dType ~= 0 then
							if daNote.dType == 1 then
								char = (flipMode and PlayerObjects.BF2 or PlayerObjects.Dad2)
							elseif daNote.dType == 2 then
								char = daNote.NoteData <= 3 and (flipMode and PlayerObjects.BF2 or PlayerObjects.Dad2) or (flipMode and PlayerObjects.BF or PlayerObjects.Dad)
							end
						elseif daNote.bro ~= 0 then
							if type(daNote.bro) == "string" then
								if not PlayerObjects[daNote.bro] then
									warn("Invalid Character")
									break;
								else
									char = PlayerObjects[daNote.bro]
								end
							elseif daNote.bro == 1 then
								char = (flipMode and PlayerObjects.BF2 or PlayerObjects.Dad2)
							elseif daNote.bro == 2 then
								char = daNote.NoteData <= 3 and (flipMode and PlayerObjects.BF2 or PlayerObjects.Dad2) or (flipMode and PlayerObjects.BF or PlayerObjects.Dad)
							elseif daNote.bro == 3 then
								char = (flipMode and PlayerObjects.BF or PlayerObjects.Dad)
								char:PlayAnimation("sing" .. sDir[daNote.NoteData+1],true)
								char = (flipMode and PlayerObjects.BF2 or PlayerObjects.Dad2)
							end
						else
							char = (flipMode and PlayerObjects.BF or PlayerObjects.Dad)
						end -- shaggy thing
						if char == nil then
							char = (flipMode and PlayerObjects.BF or PlayerObjects.Dad)
						end
						char.Holding=daNote.HoldParent;
						if shared.cancelAnim == false and not daNote.noAnimation then
							char:PlayAnimation("sing" .. sDir[daNote.NoteData+1],true)
						end	
					end
					--[[
					if(daNote.Type=='Gem')then
						if(daNote.NoteGroup=='Gems') and module.PlayerStats.Health > .0425 then
							module.PlayerStats.Health -= .0425;
						end
					elseif(daNote.Type=='BlackGem')then
						module.PlayerStats.Health = .001;
					end
					]]

					if type(internalSettings.OpponentNoteDrain) == "number" then
						if module.PlayerStats.Health < internalSettings.minHealth then
							module.PlayerStats.Health -= 0
						else
							module.PlayerStats.Health -= internalSettings.OpponentNoteDrain
						end
					end
					if(songData.needsVoices)then
						voiceSound.Volume = (SongIdInfo.VoiceVolume or 2)*(module.settings.SongVolume/100)
					end
					camZooming = true
					for i,v in pairs(loadedModchartData) do
						coroutine.resume(coroutine.create(function()
							if v.P2NoteHit then
								v.P2NoteHit(daNote.Type, daNote.NoteData)
							end
						end))
					end
					daNote:Destroy()
					continue
				elseif module.PositioningParts.isOpponentAvailable and (not daNote.MustPress and daNote.TooLate) then
					for i,v in pairs(loadedModchartData) do
						coroutine.resume(coroutine.create(function()
							if v.P2NoteHit then
								v.P2NoteHit(daNote.Type, daNote.NoteData)
							end
						end))
					end
					daNote:Destroy()
				end
				daNote.ReceptorX = receptor.GUI.Position.X.Scale
				local yVel = daNote.YVel or (Conductor.Downscroll and -1 or 1)
				local xVel = daNote.XVel or 0
				
				if daNote.scrollDirection == "Down" then yVel = -1
				elseif daNote.scrollDirection == "Up" then yVel = 1
				elseif daNote.scrollDirection == "Left" then xVel = -1
				elseif daNote.scrollDirection == "Right" then xVel = 1 end
				
				local baseYVal = 0
				if daNote.MustPress then
					baseYVal = (playerStrums[daNote.NoteData+1]:GetPosition().Y)
				else
					baseYVal = (dadStrums[daNote.NoteData+1]:GetPosition().Y)
				end
				
				local pos = daNote.InitialPos-Conductor.CurrentTrackPos
				if daNote.IsSustain and (yVel ~= -1 and yVel ~= 1) and xVel ~= 0 then -- The extra conditionals are there because the game gets a tad laggier running the equation
					daNote.NoteObject.Rotation = (math.atan2(xVel, -yVel) * (180/math.pi)+360)
				end
				
				daNote:SetPosition(
					xVel ~= 0 and daNote.manualXOffset+((pos)*(xVel))*(daNote.ScrollMultiplier) or daNote.manualXOffset,
					(baseYVal+((pos)*(yVel)))*daNote.ScrollMultiplier
				)
				daNote:Update()
				if(daNote.TooLate)then
					if not Botplay and (daNote.TooLate or not daNote.GoodHit) and (daNote.HealthLoss==0) and daNote.MustPress and not daNote.Destroyed and daNote.MissPunish then
						--voiceSound.Volume=0
						MissNote(daNote);
					end
					daNote:Destroy()
					continue
				end
			end
			lastNote = daNote
		end

		local currentNoteIndex = math.ceil(curStep/16)
		if(songData.notes[currentNoteIndex])then
			if(currentSection ~= songData.notes[currentNoteIndex])then
				currentSection = songData.notes[currentNoteIndex]
				for i = 1, #loadedModchartData do
					if(loadedModchartData[i] and loadedModchartData[i].sectionChange) and generatedSong then
						loadedModchartData[i].sectionChange(currentSection)
					end
				end
				if shared.sections and not camControls.ForcedPos then
					if(not songData.notes[currentNoteIndex].mustHitSection)then
						if songData.notes[currentNoteIndex].dType==1 then -- The commented out stuff makes the camera focus the characters
							camFollow = module.PositioningParts.Right2 -- module.PlayerObjects.Dad2.Obj.PrimaryPart
						else
							camFollow = module.PositioningParts.Right -- module.PlayerObjects.Dad.Obj.PrimaryPart
						end
					elseif songData.notes[currentNoteIndex].gfSection == true  then
						GFSection = true
						camFollow = module.PositioningParts.Left2 -- module.PlayerObjects.BF2.Obj.PrimaryPart
					elseif(songData.notes[currentNoteIndex].mustHitSection) then
						GFSection = false
						camFollow = module.PositioningParts.Left -- module.PlayerObjects.BF.Obj.PrimaryPart
					end
				end
			end
		end
	end

	if startingSong then return end

	checkHeldKeys()
	local held = HeldDirections()
	--
	if PlayerObjects.BF and (PlayerObjects.BF.HoldTimer>Conductor.stepCrochet*4*.001 and not held[0] and not held[1] and not held[2] and not held[3])then -- LAZY OK
		PlayerObjects.BF:Dance()
	end
	if PlayerObjects.BF2 and (PlayerObjects.BF2.HoldTimer>Conductor.stepCrochet*4*.001 and not held[0] and not held[1] and not held[2] and not held[3])then -- LAZY OK
		PlayerObjects.BF2:Dance()
	end
	--]]

	-- TODO: maybe a custom class to extend on table?
	-- maybe name it group or somethin
	for i = #notes,1,-1 do
		if(notes[i].Update==nil)then
			table.remove(notes,i)
		end
	end

	for i = 1,#noteLanes do
		if(noteLanes[i][1] and noteLanes[i][1].Update==nil) then
			table.remove(noteLanes[i],1)
		end
	end

	for i = 1,#susNoteLanes do
		if(susNoteLanes[i][1] and susNoteLanes[i][1].Update==nil) then
			table.remove(susNoteLanes[i],1)
		end
	end

	for i = 1,#opponentNotes do
		if(opponentNotes[i][1] and opponentNotes[i][1].Update==nil) then
			table.remove(opponentNotes[i],1)
		end
	end

	for d = 1,#noteLanes do
		local dir = d-1;

		local hittable={};
		local unhittable={};
		for i = 1,#notes do
			if(notes[i].NoteData==dir and not notes[i].IsSustain)then
				if(notes[i].MustPress)then
					table.insert(hittable,notes[i])
				else
					table.insert(unhittable,notes[i])
				end
			end
		end
		table.sort(hittable,function(a,b)
			return a.StrumTime<b.StrumTime
		end)
		table.sort(unhittable,function(a,b)
			return a.StrumTime<b.StrumTime
		end)
		for _,s in next, {hittable,unhittable}do
			for i = #s,1,-1 do
				local c = s[i];
				local n = s[i-1]
				if(i==1)then
					break;
				end
				if(c~=n and math.abs(c.StrumTime-n.StrumTime)<10 and c.MustPress==n.MustPress)then
					c:Destroy();
				end
			end
		end
	end

	-- update curStep

	for _,bpmChangeEvent in next,bpmChangePoints do
		if Conductor.SongPos >= bpmChangeEvent.songTime then
			lastBPMChange = bpmChangeEvent
		else
			break
		end 
	end
	-- events (which sucked)
	--[[
	local nextEvent = events[1] 
	
	if nextEvent and Conductor.SongPos >= nextEvent.strumTime then
		--module.processEvent(nextEvent,nextEvent.Arguments[1],nextEvent.Arguments[2])
		if loadedModchartData.EventTrigger then
			loadedModchartData.EventTrigger(nextEvent.Name,nextEvent.strumTime,unpack(nextEvent.Arguments))
		end
		table.remove(events,1)
	end]]

	-- HealthUI
	if module.PlayerStats.Health < 0.4 then
		plrIcon:PlayAnimation("Dead")
		oppIcon:PlayAnimation("Winning")
	elseif module.PlayerStats.Health > 1.6 then
		plrIcon:PlayAnimation("Winning")
		oppIcon:PlayAnimation("Dead")
	else
		plrIcon:PlayAnimation("Alive")
		oppIcon:PlayAnimation("Alive")
	end

	local likeRating = "";
	local rating2 = ""

	if accuracy == 100 then
		rating2 = "Perfect!"
	elseif accuracy >= 90 then
		rating2 = "Sick!"
	elseif accuracy >= 80 then
		rating2 = "Great"
	elseif accuracy >= 70 then
		rating2 = "Good"
	elseif accuracy == 69 then
		rating2 = "Nice"
	elseif accuracy >= 60 then
		rating2 = "Meh"
	elseif accuracy >= 50 then
		rating2 = "Bruh"
	elseif accuracy >= 40 then
		rating2 = "Bad"
	elseif accuracy >= 0 then
		rating2 = ""
	end

	if rates.miss < 1 then
		if totalPlayed < 1 then likeRating = "?" end
		if (rates.sick > 0) then likeRating = "SFC" end
		if (rates.good > 0) then likeRating = "GFC" end
		if (rates.bad > 0) then likeRating = "FC" end
	elseif (rates.miss > 0 and rates.miss < 10) then likeRating = "SDCB"
	elseif (rates.miss >= 10) then likeRating = "Clear" end
	
	ScoreLabel.Text = string.format("Score: %d | Rating: %s - %s",
		module.PlayerStats.Score,
		tostring(rating2),
		tostring(likeRating)
	)
	if accuracy then
		ScoreLabelss.accuracy.Text = string.sub(tostring(accuracy), 1, 5).."%"
	end
	ScoreLabelss.miss.Text = tostring(rates.miss)
	for i = #updateMotions,1,-1 do
		local obj = updateMotions[i]
		if(obj.Parent)then
			FlxVel:UpdateMotion(obj,deltaTime) 
		else
			table.remove(updateMotions,i)
		end
	end
	-- Make sure the health updates before the UI so that the health healthbar doesn't go past 1 or below 0
	module.PlayerStats.Health=math.clamp(module.PlayerStats.Health,0,module.PlayerStats.MaxHealth)
	
	updateUI()
	if module.PlayerStats.Health <= 0 and module.settings.DeathEnabled then
		module.Kill()
	end
end)
pcall(RS.UnbindFromRenderStep,RS,"CameraUpdate")

local lastViewport = cam.ViewportSize
local justStarted = true
local smoothy = CFrame.new()

local realGameUI = gameUI.realGameUI
local hudUI = gameUI.HudUI

function snapCamera(v)
	smoothy = v
end

-- Some constants for the camera movement/zoom speed
local SPEED_MODIFIER = 3.125
local CAMERA_SPEED_FACTOR = 0.07

RS:BindToRenderStep("CameraUpdate", Enum.RenderPriority.Camera.Value - 1, function(dt)
	if module.PositioningParts.Camera then
		if justStarted then
			justStarted = false
		elseif not generatedSong then
			targetCam = cam.CFrame
		end
		camFollow = (not camControls.StayOnCenter) and camFollow or module.PositioningParts.Camera 
		cam.CameraType = Enum.CameraType.Scriptable

		local base = module.PositioningParts.Camera.CFrame 
		local relativeCF = base:PointToObjectSpace(camFollow.CFrame.p)
		
		-- Mathy math math
		local interpolate = 1 - (dt * (SPEED_MODIFIER * speedModifier))
		local int1 = math.clamp((CAMERA_SPEED_FACTOR * interpolate) * camSpeed, 0, 1)
		-- okay so there are 3 main calculations, the interpolate which is basically the amount of change calculation
		-- the int1 which is the camera move speed (I have to use clamp to because if a player has a 2 second long lag spike then the camera will go past it's target)
		-- int2 which is the zoom speed, which also needs to be clamped
		targetCam = targetCam:lerp(base * CFrame.new(relativeCF * Vector3.new(1,0,0)), int1)

		if not camControls.DisableLerp then
			if smoothy ~= camControls.camOffset then
				smoothy = smoothy:Lerp(camControls.camOffset, int1)
			end

			cam.CFrame = targetCam * smoothy
		else
			cam.CFrame = targetCam * camControls.camOffset
		end

		if camZooming then
			local int2 = math.clamp(interpolate, 0, 1)
			camControls.camZoom = numLerp(0, camControls.camZoom, int2)
			camControls.hudZoom = numLerp(defaultCamZoom, camControls.hudZoom, int2)
		end
	else
		cam.CameraType = Enum.CameraType.Custom
		camFollow = nil
		camControls.zoom = 0
		camControls.camOffset = CFrame.new()
		justStarted = false
		camControls.hudZoom = 0 -- this resets the FieldOfView
		
		-- Make the camera go back to normal
		camControls.DisableLerp = true
		snapCamera(CFrame.new())
		--targetCam = cam.CFrame
	end

	if(cam.ViewportSize~=lastViewport)then
		for i = 1, #playerStrums do
			local v = playerStrums[i]
			v:UpdateSize()
			v:SetPosition(v.X, v.Y)
		end
		for i = 1, #dadStrums do
			local v = dadStrums[i]
			v:UpdateSize()
			v:SetPosition(v.X, v.Y)
		end
		lastViewport = cam.ViewportSize
	end

	realGameUI.Size = UDim2.new(1+(camControls.camZoom),0,1+(camControls.camZoom),0)
	hudUI.Size = UDim2.new(((70/cam.FieldOfView)),0,((70/cam.FieldOfView)),0)
	cam.FieldOfView = 70-(camControls.hudZoom*25) --70/camControls.hudZoom -- --70-(camControls.hudZoom*100)	--(defaultCamZoom*70)-(camControls.hudZoom*100)

	if module.PositioningParts.AccuracyRate then
		for i = #ratingLabels,1,-1 do
			local obj = ratingLabels[i]
			obj.ZIndex=-2-(#ratingLabels-i)
			local side = obj:GetAttribute("Side")
			local pos = module.PositioningParts[side].CFrame;
			pos*=CFrame.new(0,0,-2)

			local vector,visible = cam:WorldToScreenPoint(pos.p)
			obj:SetAttribute("Origin",UDim2.new(0,vector.x+obj:GetAttribute("Offset").x,0,vector.y+ 75+obj:GetAttribute("Offset").y))
			obj.Visible=visible
			if(obj.Parent)then
				FlxVel:UpdateMotion(obj,dt) 
			else
				table.remove(ratingLabels,i)
			end
		end
	end
end)


-- Previous format
--[[RS:BindToRenderStep("CameraUpdate", Enum.RenderPriority.Camera.Value - 1, function(dt)
	if module.PositioningParts.Camera then
		if justStarted then
			justStarted = false
		elseif not generatedSong then
			targetCam = cam.CFrame
		end
		camFollow = (not camControls.StayOnCenter) and camFollow or module.PositioningParts.Camera 
		cam.CameraType = Enum.CameraType.Scriptable

		local base = module.PositioningParts.Camera.CFrame 
		local relativeCF = base:PointToObjectSpace(camFollow.CFrame.p)
		targetCam = targetCam:lerp(base * CFrame.new(relativeCF * Vector3.new(1,0,0)), 0.06 * camSpeed)
		
		if not camControls.DisableLerp then
			if smoothy ~= camControls.camOffset then
				smoothy = smoothy:Lerp(camControls.camOffset, 0.35 * camSpeed)
			end
			cam.CFrame = targetCam * smoothy
		else
			cam.CFrame = targetCam * camControls.camOffset
		end
		
		if camZooming then
			camControls.camZoom = numLerp(0, camControls.camZoom, clamp(1 - (dt * 3.125 * speedModifier), 0, 1))
			camControls.hudZoom = numLerp(defaultCamZoom, camControls.hudZoom, clamp(1 - (dt * 3.125 * speedModifier), 0, 1))
		end
	else
		cam.CameraType = Enum.CameraType.Custom
		camFollow = nil
		camControls.zoom = 0
		camControls.camOffset = CFrame.new()
		justStarted = false
	end
	if(cam.ViewportSize~=lastViewport)then
		pcall(function()
			for i,v in next, playerStrums do
				v:UpdateSize();
				v:SetPosition(v.X,v.Y)
			end
		end)
		pcall(function()
			for i,v in next, dadStrums do
				v:UpdateSize();
				v:SetPosition(v.X,v.Y)
			end
		end)
		lastViewport = cam.ViewportSize
	end

	gameUI.realGameUI.Size = UDim2.new(1+(camControls.camZoom),0,1+(camControls.camZoom),0)
	gameUI.HudUI.Size = UDim2.new(((70/cam.FieldOfView)+camControls.camZoom),0,((70/cam.FieldOfView)+camControls.camZoom),0)
	cam.FieldOfView = 70-(camControls.hudZoom*25) --70/camControls.hudZoom -- --70-(camControls.hudZoom*100)	--(defaultCamZoom*70)-(camControls.hudZoom*100)

	if module.PositioningParts.AccuracyRate then
		for i = #ratingLabels,1,-1 do
			local obj = ratingLabels[i]
			obj.ZIndex=-2-(#ratingLabels-i)
			local side = obj:GetAttribute("Side")
			local pos = module.PositioningParts[side].CFrame;
			pos*=CFrame.new(0,0,-2)

			local vector,visible = cam:WorldToScreenPoint(pos.p)
			obj:SetAttribute("Origin",UDim2.new(0,vector.x+obj:GetAttribute("Offset").x,0,vector.y+ 75+obj:GetAttribute("Offset").y))
			obj.Visible=visible
			if(obj.Parent)then
				FlxVel:UpdateMotion(obj,dt) 
			else
				table.remove(ratingLabels,i)
			end
		end
	end
end)]]

--attributeFunctions = {}
function attributeFunctions.ForceMiddleScroll(value)

	-- Hide Opponent Arrows
	DadNotesUI.Visible = false
	BFNotesUI.Visible = false
	BFBG.Visible = false
	DadBG.Visible = false
	local theUI = flipMode and DadNotesUI or BFNotesUI
	local theBG = flipMode and DadBG or BFBG
	theUI.Visible = true
	theBG.BackgroundTransparency = module.settings.BackgroundTrans/100
	theBG.Visible = true

	if value ~= 0 then
		if value < 0 then
			local n = 350
			theUI:TweenPosition(UDim2.new(0.5,0,1,0),Enum.EasingDirection.InOut,Enum.EasingStyle.Quad,math.abs(value))
			theUI.AnchorPoint = Vector2.new(0.5,1)
			theBG:TweenPosition(UDim2.new(0.5,0,1,0),Enum.EasingDirection.InOut,Enum.EasingStyle.Quad,math.abs(value))
			theBG.AnchorPoint = Vector2.new(0.5,1)
		else
			--while startingSong ~= true do
			--	wait()
			--end
		end
	else
		theUI.Position = UDim2.new(0.5,0,1,0)
		theUI.AnchorPoint = Vector2.new(0.5,1)
		theBG.Position = UDim2.new(0.5,0,1,0)
		theBG.AnchorPoint = Vector2.new(0.5,1)
	end
	--[[ 
	TODO: yes.
	if value less than 0, play the animation in seconds by the absolute value as soon the receptors spawns
	if 0, snap them in the center instantly
	if value above 0, play the animation in seconds when the song starts
	--]]
end 
function attributeFunctions.OpponentNoteDrain(value)
	internalSettings.OpponentNoteDrain = value
end
function attributeFunctions.MaxHealth(value)
	module.PlayerStats.MaxHealth  = value
end
function attributeFunctions.CameraStaysInCenter(value)
	camControls.StayOnCenter = value
end

function attributeFunctions.RandomizeNotes(value)
	if value then
		local arrowCount = keyAmmo[songData.mania]
		for i = 1, #unspawnedNotes do
			if unspawnedNotes[i].MustPress == 0 then
				unspawnedNotes[i].NoteData = math.random(0,arrowCount-1)
			elseif unspawnedNotes[i].MustPress == 1 then
				unspawnedNotes[i].NoteData = math.random(arrowCount,(arrowCount-1 + arrowCount))
			end
			if unspawnedNotes[i].IsSustain == true then
				local PrevNote = unspawnedNotes[i].PrevNote
				unspawnedNotes[i].NoteData = PrevNote.NoteData
			end
		end
		--for i = 1, #notes do
		--	if(flipMode and notes[i].MustPress or not flipMode and not notes[i].MustPress)then -- LEFT SIDE
		--		notes[i].RawData[2] = random(0,arrowCount-1)
		--	elseif(flipMode and not notes[i].MustPress or not flipMode and notes[i].MustPress ) then -- RIGHT SIDE
		--		notes[i].RawData[2] = random(0,arrowCount-1) + arrowCount 
		--	end
		--end
		--for i = 1, #unspawnedNotes do
		--	if(flipMode and unspawnedNotes[i].MustPress or not flipMode and not unspawnedNotes[i].MustPress)then -- LEFT SIDE
		--		unspawnedNotes[i].RawData[2] = random(0,arrowCount-1)
		--	elseif(flipMode and not unspawnedNotes[i].MustPress or not flipMode and unspawnedNotes[i].MustPress ) then -- RIGHT SIDE
		--		unspawnedNotes[i].RawData[2] = random(0,arrowCount-1) + arrowCount 
		--	end
		--end
	end
end

function module.Kill() -- Function is called when the player dies. If that wan't clear enough
	--print("death")
	pcall(KillclientAnims)
	if evil then coroutine.close(evil) evil = nil end
	SetRPC()
	GameplayEvent:Fire("Death")
	--module.endSong() -- Commented out because this already runs whenever the player dies
end

function module.GetSongs()
	return songs:GetChildren()
end

function SetRPC(songname: string?, songtime: number?, songendtime: number?)
	print(songname, songtime, songendtime)
	if not songname then
		RPC.SetRichPresence({
			details = "Playing Entar's Friday Night",
			state = "Not in a song",
			timeStart = GameStartTime,
			largeImage = {
				assetId = 112418475060183,
				hoverText = "Entar's Friday Night"
			},
			smallImage = {
				assetId = 13409122839,
				hoverText = "Roblox"
			}
		})
	else
		RPC.SetRichPresence({
			details = "Playing "..songname.Parent.Name,
			state = tostring(module.PlayerStats.Score).. " Score",
			timeStart = songtime,
			timeEnd = math.floor(songtime + songendtime),
			largeImage = {
				assetId = 112418475060183,
				hoverText = "Entar's Friday Night"
			},
			smallImage = {
				assetId = 13409122839,
				hoverText = "Roblox"
			}
		})
	end
end

SetRPC()

return module