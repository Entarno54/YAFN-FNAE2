--!strict
local Creator = {}
local functions = {}
type RBXScriptSignal = typeof(Instance.new("BindableEvent").Event); -- Thanks devforum.
local CurrentPlayersUsingSpots = {}
local Settings = {
	PreventMultiTake = true -- Prevents people from taking multiple spots at the same time.
}

export type Spot = {
	Part:BasePart;
	PP:ProximityPrompt;
	
	Owner:Player|Instance|nil;
	
	KickOnDeath:boolean;
	PromptVisibleWhenTaken:boolean;
	
	TextInfo:{
		Available:string;
		Taken:string;
	};
	-- Events
	Taken:RBXScriptSignal;
	TakeAttempt:RBXScriptSignal;
	Leave:RBXScriptSignal;
	InternalEvents:{[string]:BindableEvent};
	-- Functions
	Kick:(Spot) -> (); -- function
	DisconnectAllConnections:()->();
}
export type PointOfInterest = {
	Model:any;
	DadSpot:Spot;
	BFSpot:Spot;
	GFSpot:Spot?;
	Ownership:Player?;
	IsPlaying:boolean;
	OptionalStuff:any;
	Event:RBXScriptSignal;
	IsSolo:boolean;
}

local Plrs = game:GetService("Players")

-- Object Functions
function functions:Kick()
	local self:Spot = self
	if not self.Owner then return end
	--print("Kicking!")
	local plr:any = self.Owner
	if plr.Character then
		plr.Character.Parent = workspace
	end
	self.InternalEvents.LeaveEvent:Fire(plr,true)
	self.PP.Enabled = true
	self.Owner = nil
	self.PP.ActionText = self.TextInfo.Available
	self.DisconnectAllConnections()
	local index = table.find(CurrentPlayersUsingSpots,plr)
	if index then table.remove(CurrentPlayersUsingSpots,index) end
end

function Creator.AddSpot(part:BasePart)
	local ProxPrompt = Instance.new("ProximityPrompt")
	ProxPrompt.RequiresLineOfSight = false
	local TakenEvent = Instance.new("BindableEvent")
	local TakeAttempt = Instance.new("BindableEvent")
	local LeaveEvent = Instance.new"BindableEvent"
	local CRCon:RBXScriptConnection
	local PLCon:RBXScriptConnection
	local HDCon:RBXScriptConnection
	local Spot:Spot = {
		Part = part;
		PP = ProxPrompt;
		Taken = TakenEvent.Event; -- fires when Owner is set.
		TakeAttempt = TakeAttempt.Event; -- fires when someone else tries to take the spot.
		Leave = LeaveEvent.Event; -- fires when the same owner leaves the spot.
		KickOnDeath = true; -- Kick the player when their humanoid health reaches to 0.
		PromptVisibleWhenTaken=false;
		DisconnectAllConnections = function()
			if CRCon then CRCon:Disconnect()end
			if PLCon then PLCon:Disconnect()end
			if HDCon then HDCon:Disconnect()end
		end;
		Kick = functions.Kick;
		TextInfo = {
			Available = "Join";
			Taken = "Leave";
		};
		InternalEvents = {
			TakeAttempt = TakeAttempt;
			LeaveEvent = LeaveEvent;
			TakenEvent = TakenEvent;
		}
	}
	
	Spot.PP.ActionText = Spot.TextInfo.Available

	ProxPrompt.Triggered:Connect(function(plr:Player)
		print('Triggered')
		local char:any = plr.Character
		if Spot.Owner then
			if Spot.Owner ~= plr then -- if player is NOT the owner
				print("Attempt to take the spot.")
				TakeAttempt:Fire(plr,Spot.Owner)
				return
			else -- if the owner is the same player
				print("Player leaving spot!")
				LeaveEvent:Fire(plr,false) -- Player,byForce:boolean
				Spot.PP.Enabled = true
				Spot.Owner = nil
				Spot.PP.ActionText = Spot.TextInfo.Available
				local index = table.find(CurrentPlayersUsingSpots,plr)
				if index then table.remove(CurrentPlayersUsingSpots,index) end
				return
			end
		else -- if no owner available, proceed to set the Spot owner.
			local humanoid:Humanoid? = char:FindFirstChildOfClass("Humanoid")
			-- failsafes
			if plr.Character == nil or (char and not char:IsA("Model")) then return end
			if humanoid == nil or (humanoid and humanoid.Health <= 0) then return end
			if Settings.PreventMultiTake then
				local index = table.find(CurrentPlayersUsingSpots,plr)
				if index then return end
			end
			--
			
			if not Spot.PromptVisibleWhenTaken then
				Spot.PP.Enabled = false
			end
			Spot.Owner = plr
			TakenEvent:Fire(plr, Spot)
			Spot.PP.ActionText = Spot.TextInfo.Taken
			table.insert(CurrentPlayersUsingSpots,1,plr)
			-- Set up events
			-- Character Removing
			CRCon = plr.CharacterRemoving:Connect(function(char)
				--print("Player's character removing, Kicking...")
				LeaveEvent:Fire(plr,true)
				Spot.PP.Enabled = true
				Spot.Owner = nil
				Spot.PP.ActionText = Spot.TextInfo.Available
				local index = table.find(CurrentPlayersUsingSpots,plr)
				if index then table.remove(CurrentPlayersUsingSpots,index) end
				Spot.DisconnectAllConnections()
			end)
			-- Player Leaving
			PLCon = Plrs.PlayerRemoving:Connect(function(plrLeave)
				if plrLeave == plr then
					--print("Player left, Kicking...")
					LeaveEvent:Fire(plr,true)
					Spot.PP.Enabled = true
					Spot.Owner = nil
					Spot.PP.ActionText = Spot.TextInfo.Available
					local index = table.find(CurrentPlayersUsingSpots,plr)
					if index then table.remove(CurrentPlayersUsingSpots,index) end
					Spot.DisconnectAllConnections()
				end
			end)
			-- Character dying (optional)
			if Spot.KickOnDeath then
				local char:any = plr.Character
				local humanoid:Humanoid = char:FindFirstChildOfClass("Humanoid")
				HDCon = humanoid.Died:Connect(function()
					print("Player's Character died, Kicking...")
					LeaveEvent:Fire(plr,true)
					Spot.PP.Enabled = true
					Spot.Owner = nil
					Spot.PP.ActionText = Spot.TextInfo.Available
					local index = table.find(CurrentPlayersUsingSpots,plr)
					if index then table.remove(CurrentPlayersUsingSpots,index) end
					Spot.DisconnectAllConnections()
				end)
			end

		end
	end)
	
	ProxPrompt.Parent = part
	return Spot
end
--[[
function Creator.CreateMultiFailsafe(Spots) -- Prevent from players using specified Spots at the same time.
	if type(Spots) ~= "table" then
		error("CreateSingularSpotFailsafe expected table, got " .. typeof(Spots))
	end
	local filteredTable = {}
	for index,item in next,Spots do
		print(typeof(item))
		if type(item) == "table" then
			filteredTable[#filteredTable+1] = item
		else
			warn(("Item [%s] expected Spot type, got %s"):format(tostring(index),typeof(item)))
		end
	end
	
end
--]]
function Creator.ChangeSetting(SettingName:string,value)
	if type(Settings[SettingName]) ~= type(value) and Settings[SettingName] ~= nil then
		error(("Setting %s expected %s, got %s"):format(SettingName,type(Settings[SettingName]),type(value)))
	elseif Settings[SettingName] == nil then
		error(("Setting %s doesn't exist"):format(SettingName))
	end
	Settings[SettingName] = value
end
return Creator
