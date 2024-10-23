--!strict
-- I'm just gonna split the data saving functionality into this module.
-- It's getting beyond annoying to deal with the shit bugs.
local this = {}

type settingsData = {
	RawBasic:string;
	RawKey:string;
	BasicTable:{[string]:any};
	KeyTable:{[number]:{[number]:{[number]:EnumItem}}};
	IsLoaded:boolean;
}

local keyCodeValues:{[number]:EnumItem} = {}
for _,KeyCode in next,Enum.KeyCode:GetEnumItems() do
	keyCodeValues[KeyCode.Value] = KeyCode
end

local DSS = game:GetService("DataStoreService")
local HS = game:GetService("HttpService")
local DataStoreName = "PersonalInfo"
local userPrefix = "PLR_"
local countTimeout = 15
local cacheData = {}


function this.LoadData(player:Instance|number):boolean -- this will return a boolean whenever it was possible to load the player data or not.
	--assert(self == this,"Expected ':' not '.'")
	if typeof(player) == "Instance" and player:IsA("Player") then
		player = player.UserId
	elseif type(player) ~= "number" then
		error(("Expected Player/Id, got %s"):format(typeof(player) == "Instance" and player.ClassName or type(player)))
	end
	local DataStorage = DSS:GetDataStore(DataStoreName,userPrefix .. tostring(player))
	local basicData,keybindData
	local counter = 0
	repeat
		counter +=1
		local BDran,KDran
		-- Get the basic settings
		if not basicData then
			BDran,basicData = pcall(DataStorage.GetAsync,DataStorage,"BasicSettings")
			if not BDran then
				basicData = warn("MAIN SETTINGS FAIL: " .. basicData)
			elseif basicData == nil then
				basicData = "{}"
			end
		end
		-- Get the keybind settings
		if not keybindData then
			KDran,keybindData = pcall(DataStorage.GetAsync,DataStorage,"KeySettings")
			if not KDran then
				keybindData = warn("KEY SETTINGS FAIL: " .. keybindData)
			elseif keybindData == nil then
				keybindData = "{}"
			end
		end
	until (basicData and keybindData) or counter >= countTimeout
	local confirmLoad = false
	if counter < countTimeout then
		-- Settings has been successfully loaded.
		confirmLoad = true
		local playerData:settingsData = {
			RawBasic = basicData;
			RawKey = keybindData;
			IsLoaded = false;
			BasicTable = {};
			KeyTable = {};
		}
		cacheData[player] = playerData
	end
	return confirmLoad
end

function this.GetData(player:Instance|number,getRaw:boolean?):({[any]:any}|string,{[any]:any}|string)
	--assert(self == this,"Expected ':' not '.'")
	if typeof(player) == "Instance" and player:IsA("Player") then
		player = player.UserId
	elseif type(player) ~= "number" then
		error(("Expected Player/Id, got %s"):format(typeof(player) == "Instance" and player.ClassName or type(player)))
	end
	local playerData = cacheData[player]
	if playerData == nil then
		error("Data for given player is non-existent.")
	end
	if getRaw then
		return playerData.RawBasic,playerData.RawKey
	else
		-- Try to process thru the data
		local KeyData,BasicData = HS:JSONDecode(playerData.RawBasic),HS:JSONDecode(playerData.RawKey)
		local validKeybinds:{[number]:{[number]:{[number]:EnumItem}}} = {}
		for indexCode:string,EnumVal:number in next,KeyData do
			local stupidHex = string.split(indexCode,"_")
			local mania,dir,index = tonumber("0x" .. stupidHex[1]),tonumber("0x" .. stupidHex[2]),tonumber("0x" .. stupidHex[3])
			--mania,dir,index = tonumber("0x" .. stupidHex[1]),tonumber("0x" .. stupidHex[2]),tonumber("0x" .. stupidHex[3])
			
			if validKeybinds[mania] == nil then
				validKeybinds[mania] = {}
			end
			if validKeybinds[mania][dir] == nil then
				validKeybinds[mania][dir] = {}
			end
			validKeybinds[mania][dir][index] = keyCodeValues[EnumVal]
		end
		playerData.IsLoaded = true
		playerData.BasicTable,playerData.KeyTable = BasicData,validKeybinds
		return BasicData,validKeybinds
	end
end

function this.UpdateData(player:Instance|number,settingName:string,...) -- Updates the player data.
	if typeof(player) == "Instance" and player:IsA("Player") then
		player = player.UserId
	elseif type(player) ~= "number" then
		error(("Expected Player/Id, got %s"):format(typeof(player) == "Instance" and player.ClassName or type(player)))
	end
	local playerData = cacheData[player]
	if playerData == nil then
		error("Data for given player is non-existent.")
	elseif not playerData.IsLoaded then 
		error("Settings aren't loaded!")
	end
	
	if settingName == "Keybinds" then
		local mania:number,dir:number,index:number,KeyCode:EnumItem = ...
		playerData.KeyTable[mania][dir][index] = KeyCode
	else
		local newValue = ...
		playerData.BasicTable[settingName] = newValue
	end
end

function this.SaveData(player:Instance|number) -- NOTE: This will delete the cached table! Please use this when the player is leaving!
	if typeof(player) == "Instance" and player:IsA("Player") then
		player = player.UserId
	elseif type(player) ~= "number" then
		error(("Expected Player/Id, got %s"):format(typeof(player) == "Instance" and player.ClassName or type(player)))
	end
	local playerData = cacheData[player]
	if playerData == nil then
		error("Data for given player is non-existent.")
	elseif not playerData.IsLoaded then 
		error("Settings aren't loaded!")
	end
	
	local formattedKeys = {}
	for ManiaVal,DirTable in next,playerData.KeyTable do
		for Direction,Keycodes in next, DirTable do
			for Index,KeyCode in next,Keycodes do
				local tableIndex = string.format("%X",ManiaVal) .. "_" .. string.format("%X",Direction) .. "_" .. string.format("%X",Index)
				formattedKeys[tableIndex] = KeyCode.Value
			end
		end
	end
	local saveBasic,saveKeys = HS:JSONEncode(playerData.BasicTable),HS:JSONEncode(formattedKeys)
	local DataStorage = DSS:GetDataStore(DataStoreName,userPrefix .. tostring(player))
	local basicSaved,keybindSaved = false,false
	local counter = 0
	repeat
		counter +=1
		local info
		if not basicSaved then
			basicSaved,info = pcall(DataStorage.SetAsync,DataStorage,"BasicSettings",saveBasic)
			if not basicSaved then
				warn("MAIN SETTINGS SAVE FAIL: " .. info)
			end
		end
		if not keybindSaved then
			keybindSaved,info = pcall(DataStorage.SetAsync,DataStorage,"KeySettings",saveKeys)
			if not keybindSaved then
				warn("KEY SETTINGS SAVE FAIL: " .. info)
			end
		end
	until (basicSaved and keybindSaved) or counter >= countTimeout
	cacheData[player] = nil
end

return this