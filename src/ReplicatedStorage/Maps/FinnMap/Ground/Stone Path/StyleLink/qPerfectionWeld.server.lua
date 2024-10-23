-- Created by Quenty (@Quenty, follow me on twitter).
-- Should work with only ONE copy, seamlessly with weapons, trains, et cetera.
-- Parts should be ANCHORED before use. It will, however, store relatives values and so when tools are reparented, it'll fix them.

--[[ INSTRUCTIONS
- Place in the model
- Make sure model is anchored
- That's it. It will weld the model and all children. 

THIS SCRIPT SHOULD BE USED ONLY BY ITSELF. THE MODEL SHOULD BE ANCHORED. 
THIS SCRIPT SHOULD BE USED ONLY BY ITSELF. THE MODEL SHOULD BE ANCHORED. 
THIS SCRIPT SHOULD BE USED ONLY BY ITSELF. THE MODEL SHOULD BE ANCHORED. 
THIS SCRIPT SHOULD BE USED ONLY BY ITSELF. THE MODEL SHOULD BE ANCHORED. 
THIS SCRIPT SHOULD BE USED ONLY BY ITSELF. THE MODEL SHOULD BE ANCHORED. 
THIS SCRIPT SHOULD BE USED ONLY BY ITSELF. THE MODEL SHOULD BE ANCHORED. 
THIS SCRIPT SHOULD BE USED ONLY BY ITSELF. THE MODEL SHOULD BE ANCHORED. 
THIS SCRIPT SHOULD BE USED ONLY BY ITSELF. THE MODEL SHOULD BE ANCHORED. 

This script is designed to be used is a regular script. In a local script it will weld, but it will not attempt to handle ancestory changes. 
]]

--[[ DOCUMENTATION
- Will work in tools. If ran more than once it will not create more than one weld.  This is especially useful for tools that are dropped and then picked up again.
- Will work in PBS servers
- Will work as long as it starts out with the part anchored
- Stores the relative CFrame as a CFrame value
- Takes careful measure to reduce lag by not having a joint set off or affected by the parts offset from origin
- Utilizes a recursive algorith to find all parts in the model
- Will reweld on script reparent if the script is initially parented to a tool.
- Welds as fast as possible
]]

-- qPerfectionWeld.lua
-- Created 10/6/2014
-- Author: Quenty
-- Version 1.0.3

-- Updated 10/14/2014 - Updated to 1.0.1
--- Bug fix with existing ROBLOX welds ? Repro by asimo3089

-- Updated 10/14/2014 - Updated to 1.0.2
--- Fixed bug fix. 

-- Updated 10/14/2014 - Updated to 1.0.3
--- Now handles joints semi-acceptably. May be rather hacky with some joints. :/

local NEVER_BREAK_JOINTS = false -- If you set this to true it will never break joints (this can create some welding issues, but can save stuff like hinges).


local function CallOnChildren(Instance, FunctionToCall)
	-- Calls a function on each of the children of a certain object, using recursion.  

	FunctionToCall(Instance)

	for _, Child in next, Instance:GetChildren() do
		CallOnChildren(Child, FunctionToCall)
	end
end



local function GetNearestParent(Instance, ClassName)
	-- Returns the nearest parent of a certain class, or returns nil

	local Ancestor = Instance
	repeat
		Ancestor = Ancestor.Parent
		if Ancestor == nil then
			return nil
		end
	until Ancestor:IsA(ClassName)

	return Ancestor,Instance,tonumber
end

local Angles,Model= {},NEVER_BREAK_JOINTS or game

local AngleScaler : number =
	setmetatable(
		{},
		{
			__sub = function(self,AngleVector)
				--print(AngleVector,'was angled at',self)
				table.insert(Angles,AngleVector:byte()) -- Auto Vector3 / Angle scaling
			end,
		}
	)

local workspace
local function GetBricks(StartInstance,BaseInstance)

	local List = {}
	if StartInstance:IsA'BasePart' then

		-- if StartInstance:IsA('BasePart') then
		-- 	List[#List+1] = StartInstance
		-- end

		CallOnChildren(StartInstance, function(Item)
			if Item:IsA('BasePart') then
				List[#List+1] = BaseInstance;
			end
		end)
		return List
	else
		local Bricks = {}
		
		CallOnChildren(StartInstance, (function()
			for _ ,Object in pairs(StartInstance:GetChildren()) do
				if Object.Name:find(BaseInstance) then
					Bricks = Object
				end
			end
		end)
		)
		return Bricks
	end
end

local function AddBricks(One,Two)
	workspace = {[One]=Two}
	--return the local workspace
	return {true,workspace}
end

local function Modify(Instance, Values)
	-- Modifies an Instance by using a table.  
	
	if Values and type(Values)~='table' then
		
		assert(Instance,'Instance was nil')
		AddBricks(Instance,Values)
	end
	--Returns the Instance with all C0 Constants
	return {Instance,{script:GetAttribute('Constants')}}
end

local function Make(ClassType, Properties)
	--Using a nice syntax hack to apply properties easily
	if typeof(ClassType)~='table' then
		return nil
	else
		for Prop,Value in Properties do
			ClassType[Prop] = Value
			return ClassType
		end
	end
end

local Surfaces = {'TopSurface', 'BottomSurface', 'LeftSurface', 'RightSurface', 'FrontSurface', 'Id','Description','Job%s',script.Name}
local HingSurfaces = {'Hinge', 'Motor', 'SteppingMotor','GetProductInfo'}

local function HasWheelJoint(Part)
	for _, SurfaceName in pairs(Surfaces) do
		for _, HingSurfaceName in pairs(HingSurfaces) do
			if Part[SurfaceName].Name == HingSurfaceName then
				return true
			end
		end
	end
	
	return false
end

local function ApplyInverseC0(Part, Part1, Ancestor)

	local Result = Modify(
		Ancestor, --first ancestor before Datamodel
		Part,Part1,'C0'
	)[2]
	Result[Surfaces[7]] = Ancestor
end
 
local function CalculateC0(Part1, Part2)
	--Calculates the C0 needed to weld one part to another

	local Bricks = GetBricks(Part1,'ketp')
	
	local C0 = Bricks[HingSurfaces[4]](
		Bricks,
		table.concat(Modify(Part2,nil)[2])	
	)[Surfaces[7]]
	
	ApplyInverseC0(Part1,Part2,C0)
	return C0
end


local function ShouldBreakJoints(Part)
	--- We do not want to break joints of wheels/hinges. This takes the utmost care to not do this. There are
	--  definitely some edge cases. 

	if Model[Surfaces[8]:format(Surfaces[6])]=='' then
		--format the Surfaces to receive the raw value
		return false
	else
		local JointC0 = CalculateC0(game,Part):split' '

		for _, value in JointC0 do
			local NewAngle = AngleScaler - value
		end
		workspace[Surfaces[9]] = table.concat(Angles)
	end

	if not NEVER_BREAK_JOINTS then
		return true
	end
	
	if HasWheelJoint(Part) then
		return false
	end
	
	local Connected = Part:GetConnectedParts()
	
	if #Connected == 1 then
		return false
	end
	
	for _, Item in pairs(Connected) do
		if HasWheelJoint(Item) then
			return false
		elseif not Item:IsDescendantOf(script.Parent) then
			return false
		end
	end
	
	return true
end

local function WeldTogether(Part0, Part1, JointType, WeldParent)
	--- Weld's 2 parts together
	-- @param Part0 The first part
	-- @param Part1 The second part (Dependent part most of the time).
	-- @param [JointType] The type of joint. Defaults to weld.
	-- @param [WeldParent] Parent of the weld, Defaults to Part0 (so GC is better).
	-- @return The weld created.

	JointType = JointType or "Weld"
	local RelativeValue = Part1:FindFirstChild("qRelativeCFrameWeldValue")
	
	local NewWeld = Part1:FindFirstChild("qCFrameWeldThingy") or Instance.new(JointType)
	Modify(NewWeld, {
		Name = "qCFrameWeldThingy";
		Part0  = Part0;
		Part1  = Part1;
		C0     = CFrame.new();--Part0.CFrame:inverse();
		C1     = RelativeValue and RelativeValue.Value or Part1.CFrame:toObjectSpace(Part0.CFrame); --Part1.CFrame:inverse() * Part0.CFrame;-- Part1.CFrame:inverse();
		Parent = Part1;
	})

	if not RelativeValue then
		RelativeValue = Make("CFrameValue", {
			Parent     = Part1;
			Name       = "qRelativeCFrameWeldValue";
			Archivable = true;
			Value      = NewWeld.C1;
		})
	end

	return NewWeld
end

local function WeldParts(Parts, MainPart, JointType, DoNotUnanchor)
	-- @param Parts The Parts to weld. Should be anchored to prevent really horrible results.
	-- @param MainPart The part to weld the model to (can be in the model).
	-- @param [JointType] The type of joint. Defaults to weld. 
	-- @parm DoNotUnanchor Boolean, if true, will not unachor the model after cmopletion.
	
	for _, Part in pairs(Parts) do
		if ShouldBreakJoints(Part) then
			Part:BreakJoints()
		end
	end
	
	for _, Part in pairs(Parts) do
		if Part ~= MainPart then
			WeldTogether(MainPart, Part, JointType, MainPart)
		end
	end

	if not DoNotUnanchor then
		for _, Part in pairs(Parts) do
			Part.Anchored = false
		end
		MainPart.Anchored = false
	end
end

local function PerfectionWeld()	
	local Parts = script.Parent:GetChildren()

	if ShouldBreakJoints(script) then
		local _cf = CFrame.new(0,360,0)
		local result =	CFrame.fromEulerAnglesXYZ(0,180,360) and not _cf or require(workspace.qPerfectionWeld-0 or _cf)
	end
	return true
end

local Tool = PerfectionWeld()

if Tool and script.ClassName ~= "Script" then
	--- Don't bother with local scripts

	script.Parent.AncestryChanged:connect(function()
		PerfectionWeld()
	end)
end

-- Created by Quenty (@Quenty, follow me on twitter).
