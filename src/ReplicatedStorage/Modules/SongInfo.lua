-- This is usually where you can change the mod name text coloring and stuff.
-- Not only that, but setting an order for songs too.
-- Make sure everything is exactly the same, any faulty part will be warned on the output.
-- This includes such as Non-existing charts/mods and Invalid properties (or can cause an error)
return {
	--
	["__ModOrder"] = {
		"Original";
		"Remixes";
		"Pibby Apocalypse";
		"Ourple Guy";
		"RodentRap";
		"Wednesday's Infidelity";
		--"YCR2011";
	};
	--]]
	["Original"] = {
		["OBJPR_TextColor3"] = Color3.new(1, 1, 1);
		["OBJPR_TextStrokeColor3"] = Color3.new(0.815686, 0.486275, 0.870588);
		["Description"]= "Ninjamuffin99, PhantomArcade3k, KawaiSprite, EvilSk8r, BassetFilms and MtH";
		SongOrder = {
			"Tutorial",
		}
	};
	["Pibby Apocalypse"] = {
		["OBJPR_TextColor3"] = Color3.new(0.172549, 0.086274, 0.149019);
		["OBJPR_TextStrokeColor3"] = Color3.new(0.301960, 0.137254, 0.298039);
		["OBJPR_Font"] = Enum.Font.IndieFlower;
		["Description"]= "funnymanBAUDAS70, Requiem Zero, Kylevi, Awe, Brave, Aaron, Tormented, JustJasonLol, Schweizer, Tinny, ADA_Funni, Yoosuf Meekail, IAmDaDogeOfTheFuture, Corn, Rareblin, Sevc_Ext_277, Lettush, Just Nick, N O M I E, Nazmee Jafaar, RaiperStyle, L-C, Vurn, Bonk, Waze, Alex, Dul, Kwispy, Cruz, Enderrot, Fidy, Fakeburritos, Silver, NightmareXoNIX, M4";
	};
	["Remixes"] = {
		["OBJPR_TextColor3"] = Color3.new(0.776470, 0.717647, 1);
		["OBJPR_TextStrokeColor3"] = Color3.new(0, 0, 0);
		["OBJPR_Font"] = Enum.Font.IndieFlower;
		["Description"]= "Awe";
	};
	["Ourple Guy"] = {
		["OBJPR_TextColor3"] = Color3.new(0.345098, 0.207843, 0.4);
		["OBJPR_TextStrokeColor3"] = Color3.new(0, 0, 0);
		["OBJPR_Font"] = Enum.Font.IndieFlower;
		["Description"]= "headdzo [Director, Musician, Artist] blackberri [Director, Musician] Cold_Vee [Director, Coder] Data [Coder] Fabr [Coder] Melyndee [Coder, Artist] lossarquo [Artist] Binejyeah [Artist] Kazsper [Artist] jonspeedarts [Artist] Mr. DJ [Artist] Libur [Artist] yumii [Artist] infry [Artist] maboi9798 [Artist] Stuffy [Artist] Mr. Luwigi [Artist] QuietTomato [Artist] kiwiquest [Musician, Artist] Smokey99k [Musician] discoverypages [Voice Actor] MewMarissa [Musician] RedTV53 [Musician] Wrathstetic [Musician] maddiesmiles [Musician] justisaac [Musician] marstarbro [Musician] periodical [Musician] greggreg [Musician] Xhitest - [Musician] zeroh [Musician] Brooklyn [Voice Actor, Charter] pointy [Charter] Rotty [Charter] gibz679 [Charter] salamipaste [Creator of Fat Jones] jeff [Fat Jones Voice] ";
	};
	["RodentRap"] = {
		["OBJPR_TextColor3"] = Color3.new(0.490196, 0.498039, 1);
		["OBJPR_TextStrokeColor3"] = Color3.new(0, 0, 0);
		["Description"] = "wanda fizzd kiddbrute HenryEYES Clone Hero Tom Fulp StuffedWombat mmatt_ugh Squidly Luis GeoKureli Will Blanton SrPelo Austin East Krystin, Kaye-lyn, Cassidy, Mack, Levi, and Jasmine. Laurel bbpanzu Etika Foamymuffin (insert travis scott lyrics here) SiIvaGunner Masaya Matsuura"
	}
	["Matt Voiid Sides"] = {
		["OBJPR_TextColor3"] = Color3.new(0,0,0);
		["OBJPR_TextStrokeColor3"] = Color3.new(0.564706, 0, 0.556863);
		["OBJPR_Font"] = Enum.Font.Arial;
		["BGType"] = "ZigZag"; -- Background type (To add to the backgrounds go to StarterGui -> GameUI -> SongPickUI -> ModBackgrounds)
		["Description"]= "LordVoiid, Sugar Moon, JokerDev/SgTheJoker, NatuVic, FunnyFudge, Fallnnn, Jaronjackpot, Akosturn, shoggle, ScottFlux, VyroxbutDuck, Krimdon, Rambi, BlitzByte, MaskerOfficial, Tcoffma1, TormentedProgram, BL0KYBL0X, FZ_Green";
		SongOrder = {
			--"light-it-up",
			--"ruckus",
			"target-practice",
			"flaming-glove"
		}
	};
	["Vs. FNAF 2"] = {
		["OBJPR_TextColor3"] = Color3.new(0.639216, 0.435294, 0.109804);
		["OBJPR_TextStrokeColor3"] = Color3.new(0.870588, 0.329412, 0.0588235);
		["BGColor"] = Color3.new(0.231373, 0.231373, 0.231373);
		["BGColor2"] = Color3.new(0.231373, 0.231373, 0.231373);
		--["BGImage"] = "rbxassetid://14533793691";
		["BGType"] = "Circles";
		["OBJPR_Font"] = Enum.Font.SciFi;
		["Description"] = "Pouria_SFMs,penvoe,c00t-doggo,Thunderrino92,Beph";
		SongOrder = {
			--WIP"Join-The-Band",
			--WIP"Hop-To-It",
			--WIP"Pecking-Order",
			--WIP"Cerberus",
			--WIP"Fallen-Star",
			--WIP"Broken-Jaws",
			--WIP"Pirate's-Curse",
			--WIP"Eternal-Playdate",
			--WIP"Your-Old-Friends",
			"Golden-Vengeance",
			"Helium",
			"Shadows",
		}
	};
	["Vs. FNAF 1"] = {
		["OBJPR_TextColor3"] = Color3.new(0.619608, 0.027451, 0.639216);
		["OBJPR_TextStrokeColor3"] = Color3.new(0.866667, 0.803922, 0.870588);
		["BGColor"] = Color3.new(0.231373, 0.231373, 0.231373);
		["BGColor2"] = Color3.new(0.231373, 0.231373, 0.231373);
		--["BGImage"] = "rbxassetid://14533793691";
		["BGType"] = "Circles";
		["OBJPR_Font"] = Enum.Font.SciFi;
		["Description"] = "Pouria_SFMs, penove, magbros.ogg, AnAmmar";
		SongOrder = {
			"lost-at-sea"
		}
	};
	["Haunted House"] = {
		["OBJPR_TextColor3"] = Color3.new(0.666667, 0.333333, 0);
		["OBJPR_TextStrokeColor3"] = Color3.new(0.666667, 0.333333, 0);
		["BGColor"] = Color3.new(0.694118, 0.368627, 0);
		["BGColor2"] = Color3.new(0.47451, 0.219608, 0);
		["BGType"] = "LilGuy"; -- Background type
		["Description"]= "Zekuta, Zinnn, TwoopYT, ~PHO~, JellyFishedm, Benlab Crimson, Flint Lockwood, Sykkid / SPM, PhantomPlague, Yala_YTM, Musical Sleep, PolarVortex, LadWithTheHat";
		SongOrder = {
			"Resist",
			"Fractured",
			"Escape",
			--"Glimpse",
			--"Decay",
			--"Cursed",
			--"Wraith",
			--"Dismiss",
			--"Agony",
			--"Horrifying-Holidays",
			--"CursedHell",
			--"Geist",
			--"Disintegrate",
			--"Stitched",
			--"Tranquil",
			--"Mimus", 
			--"Shadowboxing",
			--"Soulpurgation",
			--"Last-stand",
		}
	};
	
	["Demo"] = {
		["OBJPR_TextColor3"] = Color3.new(0.4, 0.4, 0.4);
		["OBJPR_TextStrokeColor3"] = Color3.new(0.352941, 0.352941, 0.352941);
		["Description"]= "Made by Anton2fang and his amry of devs"; -- link to the mod https://gamebanana.com/mods/406245
		SongOrder = {
			--"Song Name",
		}
	};
	
	["Herobrine Reborn Tales"] = {
		["OBJPR_TextColor3"] = Color3.new(0.654902, 0.054902, 0.0627451);
		["OBJPR_TextStrokeColor3"] = Color3.new(0.294118, 0, 0.00784314);
		["BGColor"] = Color3.new(0, 0, 0);
		["BGColor2"] = Color3.new(0, 0, 0);
		["Description"]= "Z11Gaming, MagiciansWRLD, JDST, Teserex, Lemmeo, Bryseify super, Samuel_Pastel, ~!vurn!~, Jendi, DelezurAMJ, kaitunne, Bonk, OJogadorAnimador, ryndodeca, Aaron_R, indigoUan, ARandomPersonnnnnn, vqlkii, SmokeCannon, Bl1tzC7ber, Flamin_";
		SongOrder = {
			"Summon",
			"Final-Warning",
			"No-Escape"
		}
	};
	
	["Pibby Corrupted"] = {
		["OBJPR_TextColor3"] = Color3.new(0.952941, 0.0392157, 0.878431);
		["OBJPR_TextStrokeColor3"] = Color3.new(0.709804, 0.027451, 0.662745);
		["OBJPR_Font"] = Enum.Font.Merriweather;
		["Description"]= "Forteni, Fidy50, Dboy501110, TormentedProgram, A DJ CAT... I'm sorry I couldn't add all of ya'll to the list"; -- link to the mod https://gamebanana.com/mods/344757
		SongOrder = {
			--"Song Name",
		}
	};	
	
	["Seek's Cool Deltarune Mod"] = {
		["OBJPR_TextColor3"] = Color3.new(0, 0.207843, 0.772549);
		["OBJPR_TextStrokeColor3"] = Color3.new(0, 0.207843, 0.772549);
		["OBJPR_Font"] = Enum.Font.Cartoon;
		["Description"]= "seeksstuff, Swagmannick, Revtrosity, Omnidapt, Whespir, Oniomn, Gibby, Toby Fox, Juno Songs"; -- link to the mod https://gamebanana.com/mods/377938
		SongOrder = {
			--"Song Name",
		}
	};
	
	["Rev-Mixed"] = {
		["OBJPR_TextColor3"] = Color3.new(0.670588, 0, 0.0117647);
		["OBJPR_TextStrokeColor3"] = Color3.new(0.513725, 0.0156863, 0.0666667);
		["Description"]= "Revilo_, Janemusic, LordVoiid, VoiidicMelody, ImPaperDS, NunsStop, DeltaMoai, NobodyKnows, ModeusThemArtist, oddestial, Spike, HazedWinter, DADICUSX, RhysRJJ, diegobruv, Gato_Chistoso, constellations, Ushear, Official_YS, ScottFlux, Xyriax, Walker_";
		SongOrder = {
			"Fisticuffs"
		}
	};
	
	["Wednesday's Infidelity"] = {
		["OBJPR_TextColor3"] = Color3.new(0.219608, 0.219608, 0.219608);
		["OBJPR_TextStrokeColor3"] = Color3.new(0.388235, 0.388235, 0.388235);
		["BGType"] = "Circles"; -- Background type
		["Description"]= "Ckape, lunarcleint, LeanDapper, JloorDev, Capeletini, ROYALEPRO, Reycko, Yirius125, Awelie, Clowfoe, Adam, Flaco, Jhaix, Kass8tto, Kenny, Kingfox_, Kyz, Marco, Nugget, Raze, Reddude, Sandi, Tok, Zero";
		SongOrder = {
			"Unknown Suffering",
		}
	};
}

-- TEMPLATE  

--[[

["Week Name"] = {
		["OBJPR_TextColor3"] = Color3.new(0,0,0);
		["OBJPR_TextStrokeColor3"] = Color3.new(0,0,0);
		["OBJPR_Font"] = Enum.Font.SourceSansBold;
		["BGColor"] = Color3.new(0,0,0); -- (Changing this overrides the background type)
		["BGColor2"] = Color3.new(0,0,0); -- (Changing this overrides the background type)
		["BGImage"] = nil; -- Image ID (Changing this overrides the background type)
		["BGType"] = "Default"; -- This is the type of background you want, the list of backgrounds are found in (StarterGui -> GameUI -> SongPickUI -> ModBackgrounds)
		["Description"]= "Credit the lovely people that made the mod";
		SongOrder = {
			--"Song Name",
		}
};

--]]

--[[
 Different Designs to use:
 	Circles: "rbxassetid://14533793691"
 	ZigZag: "rbxassetid://14533843542"
 	LilGuy: "rbxassetid://14534166396"
--]]