--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Joints = {
	["Neck"] = {
		Part0 = "Torso",
		Part1 = "Head",
		C0 = CFrame.new(0, 1, 0, -1, -0, -0, 0, 0, 1, 0, 1, 0),
		C1 = CFrame.new(0, -0.5, 0, -1, -0, -0, 0, 0, 1, 0, 1, 0),
		MaxVelocity = 0.1,
		Parent = "Torso",
	},
	["RootJoint"] = {
		Part0 = "HumanoidRootPart",
		Part1 = "Torso",
		C0 = CFrame.new(0, 0, 0, -1, -0, -0, 0, 0, 1, 0, 1, 0),
		C1 = CFrame.new(0, 0, 0, -1, -0, -0, 0, 0, 1, 0, 1, 0),
		MaxVelocity = 0.1,
		Parent = "HumanoidRootPart",
	},
	["Left Shoulder"] = {
		Part0 = "Torso",
		Part1 = "Left Arm",
		C0 = CFrame.new(-1, 0.5, 0, -0, -0, -1, 0, 1, 0, 1, 0, 0),
		C1 = CFrame.new(0.5, 0.5, 0, -0, -0, -1, 0, 1, 0, 1, 0, 0),
		MaxVelocity = 0.1,
		Parent = "Torso",
	},
	["Right Shoulder"] = {
		Part0 = "Torso",
		Part1 = "Right Arm",
		C0 = CFrame.new(1, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, -0, -0),
		C1 = CFrame.new(-0.5, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, -0, -0),
		MaxVelocity = 0.1,
		Parent = "Torso",
	},
	["Left Hip"] = {
		Part0 = "Torso",
		Part1 = "Left Leg",
		C0 = CFrame.new(-1, -1, 0, -0, -0, -1, 0, 1, 0, 1, 0, 0),
		C1 = CFrame.new(-0.5, 1, 0, -0, -0, -1, 0, 1, 0, 1, 0, 0),
		MaxVelocity = 0.1,
		Parent = "Torso",
	},
	["Right Hip"] = {
		Part0 = "Torso",
		Part1 = "Right Leg",
		C0 = CFrame.new(1, -1, 0, 0, 0, 1, 0, 1, 0, -1, -0, -0),
		C1 = CFrame.new(0.5, 1, 0, 0, 0, 1, 0, 1, 0, -1, -0, -0),
		MaxVelocity = 0.1,
		Parent = "Torso",
	},
	
	--R15 Joints
	["LeftAnkle"] = {
		Part0 = "LeftLowerLeg",
		Part1 = "LeftFoot",
		C0 = CFrame.new(-0.00382620096, -0.710131407, 0.00030554086, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		C1 = CFrame.new(-0.00901681185, 0.032443285, 0.000177569687, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		MaxVelocity = 0,
		Parent = "LeftFoot",
	},
	["LeftWrist"] = {
		Part0 = "LeftLowerLeg",
		Part1 = "LeftFoot",
		C0 = CFrame.new(-0.0016657114, -0.682255626, -0.00989592075, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		C1 = CFrame.new(-0.000386238098, 0.0579008311, -0.0154390335, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		MaxVelocity = 0,
		Parent = "LeftFoot",
	},
	["LeftElbow"] = {
		Part0 = "LeftUpperArm",
		Part1 = "LeftLowerArm",
		C0 = CFrame.new(-0.00166511536, -0.263139546, -0.00943991542, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		C1 = CFrame.new(-0.0016657114, 0.122950554, -0.00989592075, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		MaxVelocity = 0,
		Parent = "LeftLowerArm",
	},
	["LeftKnee"] = {
		Part0 = "LeftUpperLeg",
		Part1 = "LeftLowerLeg",
		C0 = CFrame.new(-0.00382620096, -0.264486194, 0.000586740673, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		C1 = CFrame.new(-0.00382620096, 0.289868593, 0.00030554086, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		MaxVelocity = 0,
		Parent = "LeftLowerLeg",
	},
	["LeftShoulder"] = {
		Part0 = "UpperTorso",
		Part1 = "LeftUpperArm",
		C0 = CFrame.new(-1.24955308, 0.556408584, -0.015560925, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		C1 = CFrame.new(0.247964978, 0.456732988, -0.00943991542, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		MaxVelocity = 0,
		Parent = "LeftUpperArm",
	},
	["Root"] = {
		Part0 = "HumanoidRootPart",
		Part1 = "LowerTorso",
		C0 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		C1 = CFrame.new(0.000280171633, 0.133037761, -0.0142721087, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		MaxVelocity = 0,
		Parent = "LowerTorso",
	},
	["LeftHip"] = {
		Part0 = "LowerTorso",
		Part1 = "LeftUpperLeg",
		C0 = CFrame.new(-0.50451982, -0.243062243, 0.00122789107, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		C1 = CFrame.new(-0.00382620096, 0.4851138, 0.000686740503, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		MaxVelocity = 0,
		Parent = "LeftUpperLeg",
	},
	["RightAnkle"] = {
		Part0 = "RightLowerLeg",
		Part1 = "RightFoot",
		C0 = CFrame.new(0.00382620096, -0.710731506, 0.000283418223, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		C1 = CFrame.new(0.00901681185, 0.0318431854, 0.000155551359, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		MaxVelocity = 0,
		Parent = "RightFoot",
	},
	["RightWrist"] = {
		Part0 = "RightLowerArm",
		Part1 = "RightHand",
		C0 = CFrame.new(0.00214457512, -0.682049513, -0.00989595056, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		C1 = CFrame.new(0.000865101814, 0.058106944, -0.0154390335, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		MaxVelocity = 0,
		Parent = "RightHand",
	},
	["RightElbow"] = {
		Part0 = "RightUpperArm",
		Part1 = "RightLowerArm",
		C0 = CFrame.new(0.00214397907, -0.263139546, -0.00944012403, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		C1 = CFrame.new(0.00214457512, 0.122950554, -0.00989595056, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		MaxVelocity = 0,
		Parent = "RightLowerArm",
	},
	["RightKnee"] = {
		Part0 = "RightUpperLeg",
		Part1 = "RightLowerLeg",
		C0 = CFrame.new(0.00382620096, -0.265086174, 0.000426991843, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		C1 = CFrame.new(0.00382620096, 0.289268613, 0.000145851634, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		MaxVelocity = 0,
		Parent = "RightLowerLeg",
	},
	["RightShoulder"] = {
		Part0 = "UpperTorso",
		Part1 = "RightUpperArm",
		C0 = CFrame.new(1.25031853, 0.5565539, -0.015560925, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		C1 = CFrame.new(-0.24787569, 0.456878304, -0.00944012403, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		MaxVelocity = 0,
		Parent = "RightUpperArm",
	},
	["RightHip"] = {
		Part0 = "LowerTorso",
		Part1 = "RightUpperLeg",
		C0 = CFrame.new(0.505080223, -0.243262246, 0.00102789141, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		C1 = CFrame.new(0.00382620096, 0.484913796, 0.000486815348, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		MaxVelocity = 0,
		Parent = "RightUpperLeg",
	},
	["Waist"] = {
		Part0 = "LowerTorso",
		Part1 = "UpperTorso",
		C0 = CFrame.new(0.000280171633, 0.537143946, -0.0142721087, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		C1 = CFrame.new(0.000338107347, -0.463463932, -0.015560925, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		MaxVelocity = 0,
		Parent = "UpperTorso",
	},
	["R15Neck"] = {
		Name = "Neck",
		Part0 = "UpperTorso",
		Part1 = "Head",
		C0 = CFrame.new(0.000338107347, 0.806032121, -0.015560925, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		C1 = CFrame.new(-2.72095203e-005, -0.565615535, 0.00386685133, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		MaxVelocity = 0,
		Parent = "Head",
	},														
		
}

return Joints