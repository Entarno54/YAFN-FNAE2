--made for use in RhythmEx

--you better know some math before using this

--TODO:
 --Account for character limb size < 0.2

--Updated:
 --Works with R15 avatars

Players = game:GetService("Players")

local function Create(classes, properties)
    assert(type(classes) == "string", "screwed up argument 1")
    assert(type(properties) == "table" or properties == nil, "screwed up argument 2")
    local Created = Instance.new(classes)
    if properties then
        for property, value in pairs(properties) do
            if property ~= "Parent" then
                Created[property] = value
            end
        end
    end
    if properties.Parent ~= nil then
        Created.Parent = properties.Parent
    end
    return Created
end

ContentsFolder = script:FindFirstChild("Contents")

Contents = {}
for i, v in pairs(ContentsFolder:GetChildren()) do
	local Object = v:Clone()
	if v:IsA("ModuleScript") then
		Contents[v.Name] = require(Object)
	else
		Contents[v.Name] = Object
	end
end

Limbs = Contents.Limbs
Joints = Contents.Joints

BasePart = Create("Part",{
	Shape = Enum.PartType.Block,
	Material = Enum.Material.Plastic,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	FormFactor = Enum.FormFactor.Custom,
	Anchored = false,
	Locked = true,
	CanCollide = true,
})

MeshPart = Create("MeshPart",{
	Material = Enum.Material.Plastic,
	Anchored = false,
	Locked = true,
	CanCollide = true
})

function SetProperties(Table)
	local Object = Table.Object
	local Properties = Table.Properties
	if not Object or not Properties then
		return
	end
	for i, v in pairs(Properties) do
		pcall(function()
			Object[i] = v
		end)
	end
	return Object
end

function RegenerateLimb(Character, Limb)
	
	local OriginalTorsoCFrame = nil
	local Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if Torso then
		OriginalTorsoCFrame = Torso.CFrame
	end
	
	local LimbName = Limb
	local Limb = Limbs[Limb]	
	
	if not Limb then
		return
	end
	
	local Joint = Joints[Limb.Joint]
	if not Joint then
		return
	end
		
		
	local Part = BasePart:Clone()		
	local Humanoid = Character:FindFirstChild("Humanoid")
	if Humanoid then
		if Humanoid.RigType == Enum.HumanoidRigType.R15 then
			if LimbName == "Head" then
				Limb.Joint = "R15Neck"
				Joint = Joints[Limb.Joint]
			end
			
			Part = MeshPart:Clone()
		elseif Humanoid.RigType == Enum.HumanoidRigType.R6 then
			if LimbName == "Head" then
				Limb.Joint = "Neck"
				Joint = Joints[Limb.Joint]
			end
		end
	end		

	
	Part.Name = LimbName
	
	--Copy default properties over to new limb
	for i, v in pairs(Limb.Properties) do
		pcall(function()
			Part[i] = v
		end)
	end
	
	local Part0 = ((LimbName == Joint.Part0 and Part) or Character:FindFirstChild(Joint.Part0))
	local Part1 = ((LimbName == Joint.Part1 and Part) or Character:FindFirstChild(Joint.Part1))
	local JointParent = ((Joint.Parent == Part.Name and Part) or Character:FindFirstChild(Joint.Parent))
	if not Part0 or not Part1 or not JointParent then
		return
	end
	
	local JointsSaved = {}
	local ObjectsSaved = {}
	local ConnectedLimbs = {}
	local LimbObject = Character:FindFirstChild(LimbName)
	if LimbObject then
		for i, v in pairs(LimbObject:GetConnectedParts()) do
			local PartLimb = Limbs[v.Name]
			if PartLimb then
				local PartJoint = Joints[PartLimb.Joint]
				if PartJoint and PartJoint ~= Joint then
					local JointInstance = {
						ClassName = "Motor6D",
						Properties = {
							Name = PartLimb.Joint,
							Part0 = ((PartJoint.Part0 == LimbObject.Name and Part) or v),
							Part1 = ((PartJoint.Part1 == LimbObject.Name and Part) or v),
							C0 = PartJoint.C0,
							C1 = PartJoint.C1,
							Parent = ((PartJoint.Parent == Part.Name and Part) or (Character:FindFirstChild(PartJoint.Parent) and Character:FindFirstChild(PartJoint.Parent))),
							MaxVelocity = PartJoint.MaxVelocity,
							CurrentAngle = PartJoint.CurrentAngle,
							DesiredAngle = PartJoint.DesiredAngle,
						}
					}
					if JointInstance.Properties.Part0 ~= JointInstance.Properties.Part1 then
						table.insert(JointsSaved, JointInstance)
					end
					table.insert(ConnectedLimbs, v)
				end
			end
		end
		for i, v in pairs(LimbObject:GetChildren()) do
			if not v:IsA("BasePart") and not v:IsA("JointInstance") then
				table.insert(ObjectsSaved, v:Clone())
			end
		end
	end
	
	for i, v in pairs(Character:GetChildren()) do
		if v:IsA("BasePart") and v.Name == LimbName then
			v:Destroy()
		end
	end
	
	for i, v in pairs(JointsSaved) do
		local JointInstance = SetProperties({Object = Instance.new(v.ClassName), Properties = v.Properties})
	end
	
	if #ObjectsSaved > 0 then
		for i, v in pairs(ObjectsSaved) do
			v.Parent = Part
		end
	elseif Limb.DefaultInstances then --Copy original appearance back to new limbs
		for i, v in pairs(Limb.DefaultInstances) do
			pcall(function()
				local Object = SetProperties({Object = Instance.new(v.ClassName), Properties = v.Properties})
				Object.Parent = Part
			end)
		end
	end
	
	local NewJoint = Create("Motor6D",{
		Name = Limb.Joint,
		Part0 = Part0,
		Part1 = Part1,
		C0 = Joint.C0,
		C1 = Joint.C1,
		Parent = JointParent,
	})

	Part.Parent = Character
	
	local Humanoid = Character:FindFirstChild("Humanoid")
	if Humanoid then
		if LimbName == "Head" then
			Character.PrimaryPart = Part
		end
		if LimbName == "Head" or LimbName == "Torso" or LimbName == "UpperTorso" or LimbName == "HumanoidRootPart" then
			local Animate = Character:FindFirstChild("Animate") --Fix animation
			local NewHumanoid = Humanoid:Clone()
			Humanoid:Destroy()
			NewHumanoid.Parent = Character
			if Animate then
				spawn(function()
					Animate.Disabled = true
					wait()
					Animate.Disabled = false
				end)
			end
		end
		
		for i, v in pairs(Character:GetChildren()) do --Keep hats and tools on character
			if v:IsA("Accoutrement") then
				v.Parent = nil
				v.Parent = Character
			elseif v:IsA("Tool") then
				Humanoid:EquipTool(v)
			end
		end
	end
	
	local BodyColors = Character:FindFirstChild("Body Colors") --Fix coloring
	if BodyColors then
		local PartColor = (string.gsub(LimbName, " ", "") .. "Color")
		pcall(function()
			Part.BrickColor = BodyColors[PartColor]
		end)
	end
	
	local Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if Torso and OriginalTorsoCFrame then
		Torso.CFrame = OriginalTorsoCFrame
	end
		
end

function ScaleCharacter(Character, Scale, Permissions)
	local Permissions = (Permissions or {})
	if not Character --[[or not Character.Parent]] then
		return
	end	
	local Humanoid = Character:FindFirstChild("Humanoid")
	--[[if not Humanoid then
		return
	end]]
	if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Humanoid.HipHeight = Humanoid.HipHeight * Scale
	end	
	
	local Player = Players:GetPlayerFromCharacter(Character)
	if not Player and not Permissions.ResizeModels then
		return
	end
	
	local Parts = {}
	local Joints = {}
	local Meshes = {}
	
	local Hats = {}
	local Tools = {}
	
	local ToolsResized = {}
	local HatsResized = {}
	
	local Connections = {}
	
	local function ScaleObjects(BaseParent, BaseScale)
		local Parts = {}
		local Joints = {}
		local Meshes = {}
		local Hats = {}
		local Tools = {}
		
		local function GetScaleObjects(Parent)
			local Objects = Parent:GetChildren()
			if Parent == BaseParent then
				table.insert(Objects, BaseParent)
			end
			for i, v in pairs(Objects) do
				if v:IsA("JointInstance") then
					table.insert(Joints, {
						Joint = v:Clone(),
						Part0 = v.Part0,
						Part1 = v.Part1,
						Parent = v.Parent
					})
				elseif v:IsA("BasePart") then
					table.insert(Parts, v)
				elseif v:IsA("Accoutrement") then
					table.insert(Hats, v)
	--				v.Parent = nil
				elseif v:IsA("Tool") then
					table.insert(Tools, v)
--					v.Parent = nil --Causes execution scripts again, which is bad.
				elseif v:IsA("DataModelMesh") then
					table.insert(Meshes, v)
				end
				if v ~= BaseParent then
					GetScaleObjects(v)
				end
			end
		end
		
		GetScaleObjects(BaseParent)
		
		for i, v in pairs(Meshes) do
			if v:IsA("FileMesh") then
				if v:IsA("SpecialMesh") and v.MeshType == Enum.MeshType.Head then
					v.Scale = (Vector3.new(1, 1, 1) * 1.25)
				else
					v.Scale = (v.Scale * BaseScale)
				end
			end
		end
		
		for i, v in pairs(Parts) do
			pcall(function()
				v.FormFactor = Enum.FormFactor.Custom
			end)
			v.Size = (v.Size * BaseScale)
		end
		
		for i, v in pairs(Hats) do
			local PX, PY, PZ, R00, R01, R02, R10, R11, R12, R20, R21, R22 = v.AttachmentPoint:components()
			v.AttachmentPoint = CFrame.new((PX * BaseScale), (PY * BaseScale), (PZ * BaseScale), R00, R01, R02, R10, R11, R12, R20, R21, R22)
			v.AttachmentPoint = (v.AttachmentPoint + Vector3.new(0, 1, 0) * -(0.5 * (BaseScale - 1)))
			--v.Parent = Character
		end
		
		for i, v in pairs(Tools) do
			local PX, PY, PZ, R00, R01, R02, R10, R11, R12, R20, R21, R22 = v.Grip:components()
			v.Grip = CFrame.new((PX * BaseScale), (PY * BaseScale), (PZ * BaseScale), R00, R01, R02, R10, R11, R12, R20, R21, R22)
			v.Grip = (v.Grip + v.Grip.lookVector * -(BaseScale - 1))
			if Humanoid then
				--Humanoid:EquipTool(v)
			end
		end
		
		for i, v in pairs(Joints) do
			local C0PX, C0PY, C0PZ, C0R00, C0R01, C0R02, C0R10, C0R11, C0R12, C0R20, C0R21, C0R22 = v.Joint.C0:components()
			local C1PX, C1PY, C1PZ, C1R00, C1R01, C1R02, C1R10, C1R11, C1R12, C1R20, C1R21, C1R22 = v.Joint.C1:components()
			local NewJoint = SetProperties({Object = v.Joint:Clone(), Properties = {
				Part0 = v.Part0,
				Part1 = v.Part1,
				C0 = CFrame.new((C0PX * BaseScale), (C0PY * BaseScale), (C0PZ * BaseScale), C0R00, C0R01, C0R02, C0R10, C0R11, C0R12, C0R20, C0R21, C0R22),
				C1 = CFrame.new((C1PX * BaseScale), (C1PY * BaseScale), (C1PZ * BaseScale), C1R00, C1R01, C1R02, C1R10, C1R11, C1R12, C1R20, C1R21, C1R22),
				Parent = v.Parent,
			}})
			for ii, vv in pairs(v.Parent:GetChildren()) do
				if vv:IsA("JointInstance") and vv.Part0 == v.Part0 and vv.Part1 == v.Part1 and vv ~= NewJoint then
					vv:Destroy()
				end
			end
		end
		
		return {
			Tools = Tools,
			Hats = Hats
		}
	end
	
	local Objects = ScaleObjects(Character, Scale)
	
	for i, v in pairs(Objects.Tools) do
		table.insert(ToolsResized, {Object = v, Connections = {}})
	end
	for i, v in pairs(Objects.Hats) do
		table.insert(HatsResized, {Object = v, Connections = {}})
	end
	
	if Permissions.ScaleTools then
		Connections.ToolAdded = Character.ChildAdded:connect(function(Child)
			if Child:IsA("Tool") then
				local TableInstance = nil
				for i, v in pairs(ToolsResized) do
					if v and v.Object and v.Object == Child then
						TableInstance = v
					end
				end
				if not TableInstance then
					table.insert(ToolsResized, {Object = Child, Connections = {}})
					ScaleObjects(Child, Scale)
				end
			end
		end)
		Connections.ToolRemoved = Character.ChildRemoved:connect(function(Child)
			if Child:IsA("Tool") then
				local TableInstance = nil
				for i, v in pairs(ToolsResized) do
					if v and v.Object and v.Object == Child then
						TableInstance = v
					end
				end
				if not TableInstance then
					return
				end
				for i, v in pairs(ToolsResized) do
					if v.Object == Child then
						for ii, vv in pairs(v.Connections) do
							if vv then
								vv:disconnect()
							end
						end
						table.remove(ToolsResized, i)
					end
				end
				ScaleObjects(Child, (1 / Scale))
			end
		end)
	end
	
	if Permissions.ScaleHats then
		Connections.HatAdded = Character.ChildAdded:connect(function(Child)
			if Child:IsA("Accoutrement") then
				local TableInstance = nil
				for i, v in pairs(HatsResized) do
					if v and v.Object and v.Object == Child then
						TableInstance = v
					end
				end
				if not TableInstance then
					table.insert(HatsResized, {Object = Child, Connections = {}})
					ScaleObjects(Child, Scale)
				end
			end
		end)
		Connections.HatRemoved = Character.ChildRemoved:connect(function(Child)
			if Child:IsA("Accoutrement") then
				local TableInstance = nil
				for i, v in pairs(HatsResized) do
					if v and v.Object and v.Object == Child then
						TableInstance = v
					end
				end
				if not TableInstance then
					return
				end
				for i, v in pairs(HatsResized) do
					if v.Object == Child then
						for ii, vv in pairs(v.Connections) do
							if vv then
								vv:disconnect()
							end
						end
						table.remove(HatsResized, i)
					end
				end
				ScaleObjects(Child, (1 / Scale))
			end
		end)
	end
	
	local Head = Character:FindFirstChild("Head")
	local Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	
	local StateChanged = Create("BoolValue",{
		Value = true,
	})
	delay(0.1, function()
		StateChanged.Value = false
	end)
	
	if Head and Torso then
		if Humanoid then
			Humanoid.CameraOffset = Vector3.new(0, (Head.Position.Y - Torso.Position.Y - 0.75), 0)
		end
		if not Permissions.MaintainCFrame then
			Torso.CFrame = Torso.CFrame + Vector3.new(0, Torso.Size.Y, 0)
		end
	end
	
	local ScaleBack = Permissions.ScaleBack
	if ScaleBack and type(ScaleBack) == "table" and tonumber(ScaleBack.Delay) then
		delay(ScaleBack.Delay, function()
			for i, v in pairs(Connections) do
				if v then
					v:disconnect()
				end
			end
			for i, v in pairs({ToolsResized, HatsResized}) do
				for ii, vv in pairs(v) do
					for iii, vvv in pairs(vv.Connections) do
						if vvv then
							vvv:disconnect()
						end
					end
				end
			end
			local PresetPermissions = {
				ScaleBack = false,
				ScaleHats = false,
				ScaleTools = false
			}
			if Character --[[and Character.Parent]] then
				for i, v in pairs(PresetPermissions) do
					Permissions[i] = v
				end
				ScaleCharacter(Character, (1 / Scale), Permissions)
			end
			StateChanged.Value = true
		end)
	end
	
	return {
		Connections = Connections,
		StateChanged = StateChanged
	}
	
end

return {
	RegenerateLimb = RegenerateLimb,
	ScaleCharacter = ScaleCharacter,
}