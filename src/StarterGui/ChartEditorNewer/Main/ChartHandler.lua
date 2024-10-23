-- Things I gotta do (it is a LOT)
--[[
> Add ability to add/edit notes and events
> Add more checkboxes and whatnot which correspond to standard things you can do with Psych Engine's chart editor
> Improve visibility of sections
> Add support for sustain notes
> Add ability to rewind and fast forward
> Add the ability to change the playback speed of the chart (heavy lifting already done)
> Add icons that can change
> Add the ability to a separate events script and code a whole custom system that loads either the chart events or global events
--]]

local module = {}

-- Libraries
local UIS = require(game.ReplicatedStorage.Modules.UserInputBindables)
local Conductor = require(game.ReplicatedStorage.Modules.Conductor)

local connections = {};
local scrollCon = nil

local chartStuff = {};
local sliderVelocities = {};
local velocityMarkers = {};

local scriptFuncs = {};
local extraScriptsFuncs = {};
local songData = {};
local currentSection = {};

local currentSong;
local selectedTab
local songPlaying = false;
local startPlaying = false;
local initialSpeed = 2;

local updateConnected = nil

local cSettings = {
	songName = "My Amazing World",
	chart = game.ReplicatedStorage.Modules.Songs["Pibby Apocalypse"]["My Amazing World"].Hard,
	speedModifier = 1,
	ChartOffset = 0,
}

local zoomList = {
	0.25,
	0.5,
	1,
	2,
	3,
	4,
	6,
	8,
	12,
	16,
	24
}
local curZoom = 1

local function addConnection(con: RBXScriptConnection | {RBXScriptConnection})
	if typeof(con) == "table" then
		for _,c in pairs(con) do
			table.insert(connections, con)
		end
	else
		table.insert(connections, con)
	end
end

local function scriptExecute(funcName:string, ...)
	if extraScriptsFuncs[funcName] ~= nil then
		for _,data in pairs(extraScriptsFuncs[funcName]) do
			if data ~= nil then
				data(...)
			end
		end
	end
end

module.Enable = function(state: boolean)
	local function getTabScript(tab)
		if tab.Elements:FindFirstChild("Script") then
			return require(tab.Elements.Script)
		end
	end
	
	
	if state == true then
		-- Enable the thing
		script.Parent.Visible = true
		
		-- Defining functions that can be used within the module script
		scriptFuncs = {
			convertToNumber = function(value, default, min, max)
				if tostring(value) == "nan" or tonumber(value) == nil then
					return default
				else
					value = tonumber(value)
					
					if min and value <= min then
						return min
					elseif max and value >= max then
						return max
					end
					
					return value
				end
			end,
			
			convertToString = function()
				
			end,
		};
		
		local Tabs = script.Parent.Menu
		
		local SongIds = require(game.ReplicatedStorage.SongIDs)
		currentSong = SongIds[cSettings.songName]
		
		chartStuff = {}
		
		scriptFuncs["addConnection"] = addConnection
		
		local function loadChart(chart)
			local data = require(chart)
			if(typeof(data)=='string')then
				data=game:service'HttpService':JSONDecode(data)
			end
			
			songData = data.song
			
			chartStuff = {
				curStep = 0,
				curBeat = 0,
				bpmChangePoints = {},
				lastStep = 0,
				totalBeats = 0,
				totalSteps = 0,
				lastBeat = 0,
				section = -1,
				sectionStep = 0,
				sectionLength = songData.notes[1].lengthInSteps or 16,
			}
			
			chartStuff.lastBPMChange = {
				songTime = 0;
				stepTime = 0;
				bpm = songData.bpm;
			}
			
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
			
			do
				if(sliderVelocities==nil or #sliderVelocities==0)then
					return
				end

				local pos = sliderVelocities[1].startTime*(initialSpeed*sliderVelocities[1].multiplier)
				table.insert(velocityMarkers,pos);

				for i = 2, #sliderVelocities do
					pos+=(sliderVelocities[i].startTime-sliderVelocities[i-1].startTime)*(initialSpeed*sliderVelocities[i-1].multiplier)
					table.insert(velocityMarkers,pos);
				end
			end
			
			
			Conductor.SongPos = 0
			Conductor.CurrentTrackPos = 0
			Conductor.AdjustedSongPos = 0
			Conductor.timePosition = 0
			Conductor.songPosition = 0
			Conductor.bpmChangeMap = {};
			
			Conductor.ChangeBPM(Conductor, songData.bpm)
			
			Conductor.timePosition=(-Conductor.crochet*5)/1000
			Conductor.songPosition=-Conductor.crochet*5
			
			if not songData.mania then 
				songData.mania = 0
			end
			
			currentSection = {};
			
			do
				local curBPM = songData.bpm;
				local steps = 0;
				local pos = 0;

				for i = 1, #songData.notes do
					local section = songData.notes[i];
					if(section.changeBPM and section.bpm ~= curBPM)then
						curBPM = section.bpm;
						table.insert(chartStuff.bpmChangePoints,{
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
					steps += deltaSteps;
					pos += ((60/curBPM)*1000/4)*deltaSteps;
				end
			end
			
			if songData.notes[1] ~= nil then
				loadSection(1)
			end
			
			startPlaying = true
			
			scriptExecute("chartLoaded", songData)
			
			cSettings.songName = songData.song
			cSettings.chart = chart
			
			if scrollCon ~= nil then scrollCon:Disconnect(); scrollCon = nil end
			scrollCon = game:GetService("UserInputService").PointerAction:Connect(function(wheel)
				songPlaying = false
				local wasPlaying = (songPlaying==true)
				if script.Inst.Playing then
					script.Inst:Pause()
				end

				Conductor.timePosition-=wheel * cSettings.speedModifier
				Conductor.songPosition-=(wheel*1000) * cSettings.speedModifier

				reloadSection()
				
				if wasPlaying then
					--songPlaying = true
				end
			end)
			
			return songData
		end
		scriptFuncs['loadChart'] = loadChart
		
		scriptFuncs['getSectionBeats'] = function(section)
			if not section then
				section = chartStuff.section
			end
			
			local val;
			print(songData)
			print(songData.notes)
			print(songData.notes[section])
			if songData.notes[section] then 
				val = songData.notes[section].sectionBeats
			else
				val = 4
			end
			
			return val
		end
		
		scriptFuncs['beatHit'] = function()
			--print('Beat was hit')
			
			chartStuff.lastBeat+=Conductor.crochet;
			chartStuff.totalBeats+=1;
		end
		
		scriptFuncs['stepHit'] = function()
			local function resync()
				warn'resync'
				
				local songPos = (Conductor.TimePos*script.Inst.PlaybackSpeed)
				
				script.Inst:Pause()
				
				if currentSong.Voices ~= nil then
					script.Voices:Pause()
				end
				
				script.Inst.TimePosition=songPos
				
				if currentSong.Voices ~= nil then
					script.Voices.TimePosition=songPos
				end
				
				script.Inst:Resume()
				
				if currentSong.Voices ~= nil then
					script.Voices:Resume()
				end
			end
			
			chartStuff.totalSteps+=1
			chartStuff.lastStep+=Conductor.stepCrochet

			if(Conductor.SongPos>chartStuff.lastStep+(Conductor.stepCrochet*3))then
				chartStuff.lastStep=Conductor.SongPos
				chartStuff.totalSteps=math.ceil(chartStuff.lastStep/Conductor.stepCrochet);
			end

			if chartStuff.totalSteps > chartStuff.curStep then
				chartStuff.totalSteps = chartStuff.curStep
			end
			if chartStuff.totalSteps < chartStuff.curStep then
				chartStuff.totalSteps += 1
			end

			if(chartStuff.totalSteps%4==0)then
				scriptFuncs.beatHit()
			end

			local songPos = (Conductor.SongPos/1000)
			local instrPos,voicePos = script.Inst.TimePosition/script.Inst.PlaybackSpeed,script.Voices.TimePosition/script.Voices.PlaybackSpeed
			local offset = (currentSong.Offset or 0) + (cSettings.ChartOffset/1000)

			if(songData.needsVoices)then -- When the song has a voices song it checks to see if the TimePosition of the song is off by a bit.
				if(instrPos-(songPos - offset)>(3 * cSettings.speedModifier) or voicePos-(songPos - offset) > (3 * cSettings.speedModifier))then
					resync() -- This will readjust the songs to be at the correct time
				end
			else
				if(instrPos - (songPos - offset)>(3 * cSettings.speedModifier))then
					resync()
				end
			end
		end
		
		loadChart(cSettings.chart)
		
		selectedTab = nil
		local selectedTabScript;
		
		scriptFuncs.reloadAudio = function()
			script.Inst.SoundId = 'rbxassetid://' .. currentSong.Instrumental
			script.Inst.Volume = currentSong.InstrumentalVolume or 2
			
			if currentSong.Voices then
				script.Voices.SoundId = 'rbxassetid://' .. currentSong.Voices
				script.Voices.Volume = currentSong.VoicesVolume or 2
			end
			
			if not script.Inst.IsLoaded then
				script.Inst:Play()
				script.Inst.Loaded:Wait()
				script.Inst:Stop()
			end
			if currentSong.Voices and not script.Voices.IsLoaded then
				script.Voices:Play()
				script.Voices.Loaded:Wait()
				script.Voices:Stop()
			end
			
			script.Inst.TimePosition = Conductor.TimePos
			script.Voices.TimePosition = Conductor.TimePos
		end
		
		-- Set up the conductor
		--Conductor.elapsed=0
		--Conductor.curSong=cSettings.chart -- it is called cur song but it has to be linked to the chart data and not the name of the song
		--Conductor.SVIndex=0;
		
		local function loadSong(name)
			currentSong = SongIds[name]
			if not currentSong then warn('Song does not exist'); return end
			
			-- Load the inst/voices
			if currentSong then
				script.Inst.SoundId = 'rbxassetid://' .. currentSong.Instrumental
				script.Inst.Volume = currentSong.InstrumentalVolume or 2

				script.Inst:Play()
				script.Inst:Stop()

				if currentSong.Voices then
					script.Voices.SoundId = 'rbxassetid://' .. currentSong.Voices
					script.Voices.Volume = currentSong.VoicesVolume or 2

					script.Voices:Play()
					script.Voices:Stop()
				end
				
				if currentSong.PlaybackRate ~= nil then
					script.Inst.PlaybackSpeed = currentSong.PlaybackRate
					script.Voices.PlaybackSpeed = currentSong.PlaybackRate
				else
					script.Inst.PlaybackSpeed = 1
					script.Voices.PlaybackSpeed = 1
				end

				-- Wait for it to load
				if not script.Inst.IsLoaded then
					script.Inst.Loaded:Wait()
				end
				if currentSong.Voices and not script.Voices.IsLoaded then
					script.Voices.Loaded:Wait()
				end
				
				script.Inst.TimePosition = 0
				script.Voices.TimePosition = 0
			end

			print('Song Loaded')
			
			-- Load the chart <- very difficult
			
			-- After loading everything else, require the elements modulescript so that the script can handle loading the songdata
			if updateConnected then
				game:GetService("RunService"):UnbindFromRenderStep("_ChartEditorUpdate")
				updateConnected = nil
			end
			
			updateConnected = game:GetService("RunService"):BindToRenderStep("_ChartEditorUpdate", Enum.RenderPriority.Last.Value, RenderUpdate)
			updateConnected = true
		end
		scriptFuncs['loadSong'] = loadSong
		
		scriptFuncs['sectionStartTime'] = function(add)
			if not add then add = 0 end
			local daBPM = songData.bpm
			local daPos = 0
			for i = 0, chartStuff.section + add, 1 do
				if songData.notes[i] and songData.notes[i].changeBPM == true then
					daBPM = songData.notes[i].bpm
				end
				
				daPos += scriptFuncs.getSectionBeats(i) * (60000 / daBPM)
			end
			
			return daPos
		end
		
		-- Load the current song
		loadSong(cSettings.songName)
		
		-- A function that handles selecting/deselecting tabs (function is bound to all the tabs)
		local selectTab = function(gui)
			if gui == selectedTab then return end

			-- Deselect the currently selected
			if(selectedTab)then
				selectedTab.AnchorPoint = Vector2.new(0, .9)
				selectedTab.ZIndex = -10
				selectedTab.ImageColor3 = Color3.fromRGB(220, 220, 220)
				local lastScript = getTabScript(Tabs)
				if lastScript and lastScript.Unloaded ~= nil then
					lastScript.Unloaded()
				end
				local previousElements = Tabs:FindFirstChild("Elements")
				if previousElements then
					previousElements.Visible = false
					previousElements.Parent = selectedTab
				end
			end

			-- Select the new tab
			gui.AnchorPoint = Vector2.new(0, 1)
			gui.ZIndex = 1
			gui.ImageColor3 = Color3.new(1, 1, 1)
			selectedTab = gui
			selectedTab.Elements.Visible = true
			selectedTab.Elements.Parent = Tabs
			if Tabs.Elements:FindFirstChild("Script") then
				-- Get the custom script or whatever (script handles the changing of the elements)
				selectedTabScript = getTabScript(Tabs)
				if selectedTabScript.Loaded then
					-- Play a function intended for loading the UI elements' text and sizes
					selectedTabScript.Loaded(cSettings, currentSong, songData, scriptFuncs)
				end
				
				local function addExtraFunc(source:any, funcName:string)
					if source[funcName] then
						if not extraScriptsFuncs[funcName] then
							extraScriptsFuncs[funcName] = {}
						end
						
						table.insert(extraScriptsFuncs[funcName], source[funcName])
					end
				end
				
				addExtraFunc(selectedTabScript, "sectionChange")
				addExtraFunc(selectedTabScript, "chartLoaded")
			end
		end
		
		selectTab(Tabs.Charting)

		addConnection({
			Tabs.Charting.Button.Activated:Connect(function() selectTab(Tabs.Charting) end),
			Tabs.Events.Button.Activated:Connect(function() selectTab(Tabs.Events) end),
			Tabs.Note.Button.Activated:Connect(function() selectTab(Tabs.Note) end),
			Tabs.Section.Button.Activated:Connect(function() selectTab(Tabs.Section) end),
			Tabs.Song.Button.Activated:Connect(function() selectTab(Tabs.Song) end)
		})
		
		UIS.AddBind("PlaySong", Enum.KeyCode.Space)
		
		addConnection(UIS.InputEvents.Began:Connect(function(bindName)
			if bindName == "PlaySong" or bindName == "Dodge" then
				if script.Inst.Playing == true or script.Voices.Playing == true then
					songPlaying = false
					script.Inst.Playing = false
					script.Voices.Playing = false
				else
					script.Inst.TimePosition = Conductor.TimePos
					script.Inst.Playing = true
					if currentSong.Voices then
						script.Voices.TimePosition = Conductor.TimePos
						script.Voices.Playing = true
					end
					
					songPlaying = true
				end
			end
		end))
		
		addConnection(script.Inst.Ended:Connect(function()
			songPlaying = false
		end))
	else
		if updateConnected then
			game:GetService("RunService"):UnbindFromRenderStep("_ChartEditorUpdate")
			updateConnected = nil
		end
		
		-- Stop audio
		if script.Inst then
			script.Inst:Stop()
			script.Inst.TimePosition = 0
		end
		if script.Voices then
			script.Voices:Stop()
			script.Voices.TimePosition = 0
		end
		
		-- Disable the thing
		script.Parent.Visible = false
		
		if selectedTab then
			local elements = script.Parent.Menu:FindFirstChild("Elements")
			if elements then
				local lastScript = getTabScript(script.Parent.Menu)
				if lastScript and lastScript.Unloaded ~= nil then
					lastScript.Unloaded()
				end
				elements.Parent = selectedTab
			end
		end
		
		table.clear(extraScriptsFuncs)
		
		UIS.ClearBinds("PlaySong")
		
		-- Disconnect the connections
		if scrollCon ~= nil then scrollCon:Disconnect(); scrollCon = nil end
		for _,con in pairs(connections) do
			if con and con.Disconnect then
				con:Disconnect()
			end
		end
		table.clear(connections)
		
		-- idk lol
		if songData ~= nil and cSettings.chart then
			local changedChart = {song = songData}
			changedChart = game:GetService("HttpService"):JSONEncode(changedChart)
			
			local oldChart = require(cSettings.chart)
			oldChart = changedChart
		end
	end
end

local bg = script.Parent.Grid.BG

local bgPosY = bg.Position.Y.Offset

local sectionNotes = {};

function loadSection(section)
	for index,note in pairs(sectionNotes) do
		if note then
			note.Image:Destroy()
		end
	end
	table.clear(sectionNotes)
	
	local sec = songData.notes[section]
	
	local mania = songData.mania
	local color = {"P","B","G","R"}
	
	for _,note in pairs(sec.sectionNotes) do
		-- TODO: make events work :>
		local noteData = note[2]%4--shared.DirAmmo[songData.mania or 0]
		local image = nil
		if note[2] == -1 then
			-- This is an old Psych Engine event
			image = bg.Templates["Event"]:Clone()
			image.Event.Text = "Event: " .. note[3]
			image.Value1.Text = "Value1: " .. note[4]
			image.Value2.Text = "Value2: " .. note[5]
		else
			image = bg.Templates[color[noteData+1] .. "Note"]:Clone()
			if note[4] ~= nil then
				-- Indication that it is a special note
				local specialNote = bg.Templates.Special:Clone()
				local specialTypes = {"Alt Animation","Hey!","Hurt Note","GF Sing","No Animation"}
				specialNote.Text = (table.find(specialTypes, note[4])~=nil and tostring(table.find(specialTypes, note[4]))) or "?"
				specialNote.Visible = true
				specialNote.Parent = image
			end
			if note[3] ~= nil and note[3] ~= 0 then
				local sustainNote = bg.Templates.Sustain:Clone()
				sustainNote.Size = UDim2.fromScale(0.2, (note[3]/100) + 0.5)
				sustainNote.Visible = true
				sustainNote.Parent = image
			end
		end
		table.insert(sectionNotes, {
			Pos = (note[2]+1)/9,
			Y = note[1],
			Image = image,
			SustainLength = note[3]
		})
	end
end

function updatePosVars()
	local offset = (currentSong.Offset or 0) + (cSettings.ChartOffset/1000)
	Conductor.SongPos = Conductor.songPosition+(offset*1000)
	Conductor.TimePos = Conductor.timePosition+offset

	Conductor.AdjustedSongPos = Conductor.SongPos*script.Inst.PlaybackSpeed;
	Conductor.CurrentTrackPos = getPosFromTime(Conductor.SongPos)
	--checkEventNote(Conductor.SongPos, offset)
end

function reloadSection()
	local wasPlaying = (songPlaying == true)
	songPlaying = false
	task.wait() -- wait for update to stop running
	
	updatePosVars()
	
	if startPlaying == true and Conductor.songPosition >= 0 then
		startPlaying = false
		script.Inst.TimePosition = 0
	end
	
	local exactStep = chartStuff.lastBPMChange.stepTime + (Conductor.SongPos-chartStuff.lastBPMChange.songTime)/Conductor.stepCrochet
	chartStuff.curStep = math.floor(exactStep)
	chartStuff.curBeat = math.round(chartStuff.curStep / 4)
	
	script.Parent.Step.Text = "Step: " .. chartStuff.curStep
	
	local currentNoteIndex = math.ceil(chartStuff.curStep/16)
	if songData.notes[currentNoteIndex] then
		currentSection = songData.notes[currentNoteIndex]
		
		if(currentSection.changeBPM)then
			local oldBPM = Conductor.BPM
			Conductor.ChangeBPM(currentSection.bpm, cSettings.speedModifier)
		end
		
		local tileSize = (scriptFuncs.getSectionBeats()-2)/16
		script.Parent.Grid.BG.TileSize = UDim2.fromScale(2/9, tileSize)
		script.Parent.Grid.BG.NextBG.TileSize = UDim2.fromScale(2/9, tileSize)

		chartStuff.sectionStep = Conductor.SongPos
		chartStuff.sectionLength = currentSection.lengthInSteps or 16
		chartStuff.section = currentNoteIndex
		
		loadSection(currentNoteIndex)
	end
	
	for i,note in pairs(sectionNotes) do
		-- NOTE: must be a static position as the bg grid is moving the notes with it
		note.Image.Position = UDim2.fromScale(note.Pos, 0.0625 + ((note.Y-chartStuff.sectionStep) / Conductor.stepCrochet / chartStuff.sectionLength))

		if note.Y-Conductor.SongPos > 0 then
			note.Image.ImageTransparency = 0
		else
			note.Image.ImageTransparency = 0.5
		end
		
		note.Image.Visible = true
		note.Image.Parent = bg
	end
	
	bg.Position = UDim2.fromScale(0, 0.5 - ((Conductor.SongPos - chartStuff.sectionStep) / Conductor.stepCrochet / chartStuff.sectionLength * bg.Size.Y.Scale))
	
	script.Inst.PlaybackSpeed = (currentSong.PlaybackRate or 1) * cSettings.speedModifier
	script.Inst.TimePosition = Conductor.TimePos*script.Inst.PlaybackSpeed
	if currentSong.Voices then
		script.Voices.PlaybackSpeed = script.Inst.PlaybackSpeed
		script.Voices.TimePosition = Conductor.TimePos * script.Voices.PlaybackSpeed
	end
	
	if wasPlaying then
		songPlaying = true
	end
end

function RenderUpdate(deltaTime)
	if not songPlaying then return end
	
	if(startPlaying)then
		script.Inst:Pause()
		
		Conductor.timePosition+=deltaTime * cSettings.speedModifier
		Conductor.songPosition+=(deltaTime*1000) * cSettings.speedModifier
		
		updatePosVars();
		
		if(Conductor.songPosition>=0)then
			startPlaying = false
			script.Inst:Pause()
			script.Inst.TimePosition = 0
			script.Inst:Resume()
		end
		--CheckSpawns()
	else
		Conductor.timePosition+=(deltaTime) * cSettings.speedModifier
		Conductor.songPosition+=(deltaTime*1000) * cSettings.speedModifier
		updatePosVars();
		--CheckSpawns();
	end
	
	--strumLine.y = getYfromStrum((Conductor.songPosition - ) / zoomList[curZoom] % (Conductor.stepCrochet * 16)) / (scriptFuncs.getSectionBeats() / 4);
	-- current step without the rounding
	local exactStep = chartStuff.lastBPMChange.stepTime + (Conductor.SongPos-chartStuff.lastBPMChange.songTime)/Conductor.stepCrochet
	
	--bgPosY = Conductor.SongPos
	bg.Position = UDim2.fromScale(0, 0.5 - ((Conductor.SongPos - chartStuff.sectionStep) / Conductor.stepCrochet / chartStuff.sectionLength * bg.Size.Y.Scale))
	--bg.Position = UDim2.fromScale(0, 0.5 - ((exactStep - chartStuff.sectionStep) / chartStuff.sectionLength / 1000) * 1.6)
	--script.Parent.Grid.BG.Position = UDim2.new(0, 0, 0, Conductor.SongPos - getYfromStrum((Conductor.SongPos-scriptFuncs.sectionStartTime()) / zoomList[curZoom] % (Conductor.stepCrochet * 16)) / (scriptFuncs.getSectionBeats() / 4))
	
	chartStuff.curStep = math.floor(exactStep)
	
	script.Parent.Step.Text = "Step: " .. chartStuff.curStep
	
	if startPlaying then return end
	
	if (Conductor.SongPos>chartStuff.lastStep+Conductor.stepCrochet-Conductor.safeZoneOffset or Conductor.SongPos<chartStuff.lastStep+Conductor.safeZoneOffset)then
		if(Conductor.SongPos>chartStuff.lastStep+Conductor.stepCrochet)then
			scriptFuncs.stepHit()
		end
	end
	
	for i,note in pairs(sectionNotes) do
		-- NOTE: must be a static position as the bg grid is moving the notes with it
		note.Image.Position = UDim2.fromScale(note.Pos, 0.0625 + ((note.Y-chartStuff.sectionStep) / Conductor.stepCrochet / chartStuff.sectionLength))
		
		if note.Y-Conductor.SongPos > 0 then
			note.Image.ImageTransparency = 0
		else
			note.Image.ImageTransparency = 0.5
		end
		
		note.Image.Visible = true
		note.Image.Parent = bg
	end
	
	chartStuff.curBeat=math.round(chartStuff.curStep/4);
	
	local currentNoteIndex = math.ceil(chartStuff.curStep/16)
	if(songData.notes[currentNoteIndex])then
		if(currentSection ~= songData.notes[currentNoteIndex])then
			currentSection = songData.notes[currentNoteIndex]
			
			if(currentSection.changeBPM)then
				local oldBPM = Conductor.BPM
				Conductor.ChangeBPM(currentSection.bpm, cSettings.speedModifier)
			end
			
			local tileSize = (scriptFuncs.getSectionBeats()-2)/16
			script.Parent.Grid.BG.TileSize = UDim2.fromScale(2/9, tileSize)
			script.Parent.Grid.BG.NextBG.TileSize = UDim2.fromScale(2/9, tileSize)
			
			chartStuff.sectionStep = Conductor.SongPos
			chartStuff.sectionLength = currentSection.lengthInSteps or 16
			chartStuff.section = currentNoteIndex
			loadSection(currentNoteIndex)
			
			--[[
			if(not songData.notes[currentNoteIndex].mustHitSection)then
				if songData.notes[currentNoteIndex].dType==1 then

				else

				end
			elseif songData.notes[currentNoteIndex].gfSection == true  then

			elseif(songData.notes[currentNoteIndex].mustHitSection) then

			end
			--]]
			
			if currentSection.mustHitSection == true then
				local bg = script.Parent.Grid.BG
				bg.LeftIcon.Position = UDim2.fromScale(0.193, -0.152)
				bg.RightIcon.Position = UDim2.fromScale(0.635, -0.152)
			else
				local bg = script.Parent.Grid.BG
				bg.LeftIcon.Position = UDim2.fromScale(0.635, -0.152)
				bg.RightIcon.Position = UDim2.fromScale(0.193, -0.152)
			end

			if extraScriptsFuncs.sectionChange then
				for _,v in pairs(extraScriptsFuncs.sectionChange) do
					v(currentSection)
				end
			end
		end
	end
	
	for _,bpmChangeEvent in next,chartStuff.bpmChangePoints do
		if Conductor.SongPos >= bpmChangeEvent.songTime then
			chartStuff.lastBPMChange = bpmChangeEvent
		else
			break
		end
	end
end

function map(x, in_min, in_max, out_min, out_max)
	return out_min + (x - in_min)*(out_max - out_min)/(in_max - in_min)
end

function getYfromStrum(strumTime, doZoomCalc)
	local leZoom = zoomList[curZoom]
	if not doZoomCalc then leZoom = 1 end
	
	return map(strumTime, 0, 16 * Conductor.stepCrochet, 0, bgPosY, bgPosY + bg.AbsoluteSize.Y * leZoom)
	--return map(strumTime, 0, 16 * Conductor.stepCrochet, bg.Position.Height.Offset, bg.Position.Height.Offset + bg.AbsoluteSize.Y * leZoom);
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

return module