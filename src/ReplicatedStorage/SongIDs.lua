local Fnaf2Set = {
	sick="rbxassetid://11565346734",
	good="rbxassetid://11565347520",
	bad="rbxassetid://11565348156",
	trash="rbxassetid://11565348156"
}

return {
	-- Original
	['Tutorial']={
		Instrumental = 100495435674995;
	};
	["Bopeebo"]={
		Instrumental = 72918072094267;
	};
	["BopeeboPico"]={
		Instrumental = 101810123204448;
		BFAnimations = "PicoPlayer"
	};
	["Unknown Suffering"] = {
		Instrumental = 83979815274423;
		InstrumentalVolume = 4.5;
		Voices = 84769289412123;
		VoiceVolume = 4.5;
		
		NoteSkin = "BaW";
		
		countdownImages = {
			0,
			14523261722,
			14523264654,
			14523280625
		};
		
		PreloadImages = {
			"rbxassetid://14523550833"
		};
		
		PreloadSounds = {
			"rbxassetid://14523773603"
		};
		
		RatingSet = {
			sick="rbxassetid://14523252211",
			good="rbxassetid://14523277996",
			bad="rbxassetid://14523266520",
			trash="rbxassetid://14523266520"
		};
		DadAnimations = "WI";
	};
	["FreeForMe"] = {
		Instrumental = 18868922639;
		DadAnimations="SonicFFM";
		BFAnimations="BF";
		mapProps = "free4me";
		hideBox = true
	};
	["Silly Billy"] = {
		Instrumental = 97471753055482;
		InstrumentalSpeed = 0.86933333333;
		DadAnimations="Yourself";
		BFAnimations="BF";
		mapProps = "SillBill";
		hideBox = true;
		AnimOffsets = { -- (Optional) Defines the CFrame offset for (BF, DAD, BF2, DAD2) all the CFrames do not have to be defined.
			CFrame.new(),
			CFrame.new(0, -1.5, 0),
			CFrame.new(),
			CFrame.new()
		};
	};
	["TestSong"] = {
		Instrumental = 97471753055482;
		InstrumentalSpeed = 0.86933333333;
		DadAnimations="Yourself";
		BFAnimations="BF";
		mapProps = "TestMap";
		hideBox = true;
	};
	["Nightmare-Run"] = {
		Instrumental = 129404711824639;
		Voices=90876029512998;
		NoteGroup = 'HurtNotesYe';
	};
	["Child's Play"] = {
		Instrumental = 77210890046684;
		DadAnimations = "GumballPretend";
		BFAnimations = "BFPA";
		mapProps = "PASchool";
		hideBox = true;
	};
	["My Amazing World"] = {
		Instrumental = 101677518227342;
		DadAnimations = "GumballNormal";
		BFAnimations = "BFPA";
		ExtraAnimations = {
			["Darwin"] = {
				Side = "Left";
				Animation = "DarwinRemote"
			}
		};
		NoteGroup = "MILLER";
		mapProps = "PASchool";
		hideBox = true
	};
	["Forgotten World"] = {
		Instrumental = 101465822982600;
		DadAnimations = "GumballNormal";
		BFAnimations = "BFPA";
		mapProps = "ForgottenWorld";
	};
	["Come Along With Me"] = {
		Instrumental = 124411322992324;
		DadAnimations = "FinnPAOne";
		BFAnimations = "BFPA";
		mapProps = "FinnMap";
		hideBox = true
	};
	["Incident-Expurgation"] = {
		Instrumental = 108110616117398;
		NoteGroup = 'MadnessIncident';
	};
	["My Finale"] = {
		Instrumental = 79401314444454;
		DadAnimations = "GumballNormal";
		BFAnimations = "DarwinRemote";
		mapProps = "ForgottenWorld";
		hideBox = true
	};
	["MILLER"] = {
		Instrumental = 107959217490853;
		ExtraAnimations = {
			['GF'] = {
				Side = "Left",
				Animation = "WilliamAfton"
			};
			["Special"] = {
				Side = "Left",
				Animation = "Special"
			};
			["Peter"] = {
				Side = "Left",
				Animation = "PhoneGuyTwo"
			};
			["Steven"] = {
				Side = "Left",
				Animation = "PhoneGuyOne"
			}
		};
		NoteGroup = "MILLER";
		BFAnimations = "JackNotMiller";
		DadAnimations = "HenryMiller";
		hideBox = true;
		mapProps = "MILLER"
	}
}
--[[
	["example"] = {
	Instrumental = _;
	Voices = _; (Optional) if you don't have this make sure to set "needsVoices" to false
	InstrumentalVolume = 2; (Optional) Sets the volume for the instrumental (default: 2)
	VoiceVolume = 2; (Optional) Sets the volume for the voices (default: 2)
	Offset = 0; -- (Optional) Applies an offset to the chart
	EventOffset = 0; -- (Optional) Applies an offset to the events
	BFAnimations = _; -- (Optional) Set Boyfriends animation
	BF2Animations = _; -- (Optional) Adds a secondary Boyfriend with said animation
	DadAnimations = _; -- (Optional) Set Dads animation
	Dad2Animations = _; -- (Optional) Adds a secondary Dad with said animation
	ExtraAnimations = { -- (Optional) Adds extra characters ordered as (BF, Dad, BF, Dad)
		"Character Animation Name",
	};
	AnimOffsets = { -- (Optional) Defines the CFrame offset for (BF, DAD, BF2, DAD2) all the CFrames do not have to be defined.
		CFrame.new(),
		CFrame.new(),
		CFrame.new(),
		CFrame.new()
	};
	NoteGroup = ''; -- (Optional) Defines which notegroup to use inside of the NoteGroups folder
	NoteSkin = ''; -- (Optional) Sets the noteskin for the song
	NoteSplashSkin = ''; -- (Optional) Sets the notesplash skin for the song
	Script = ''; -- (Optional) Option to change the script that the song will use [Uses scripts from modcharts folder]
	defaultCamZoom = 0; -- (Optional) changes the default zoom/FOV of the camera when the song starts
	mapProps = ''; -- (Optional) Adds the map to the game using the name of the map in the ReplicatedStorage.Maps Folder
	ClockTime = 0; -- (Optional) Sets the time of day
	hideProps = boolean; -- (Optional) Tells whether or not to hide props in the map
	hideBox = boolean; -- (Optional) Hides all boomboxes
	PreloadSounds = { -- (Optional) Plays the sound at a very low volume so that the game forces it to load
		"rbxassetid://" -- sound id
	};
	PreloadImages = { -- (Optional) Prechaches images for the song
		"rbxassetid://" -- image id
	};
	countdownImages = { -- (Optional) you could just make it equal false for it to be nothing
		0; -- image of 3
		0; -- image of the 2
		0; -- image of the 1
		0; -- image of the go!
	};
	IntroSounds = { -- 
		"rbxassetid://"; -- Voice for 3 -- If you want there to be silence just make it blank like "";
		"rbxassetid://"; -- Voice for 2
		"rbxassetid://"; -- Voice for 1
		"rbxassetid://"; -- Voice for Go
	};
	RatingSet = { -- (Optional) Changes the images for the ratings
		sick="rbxassetid://10849280164",
		good="rbxassetid://10849281330",
		bad="rbxassetid://10849282992",
		trash="rbxassetid://10849284734"
		};
	};
]]--