
Limbs = {
	["Head"] = {
		Joint = "Neck",
		Properties = {
			BrickColor = BrickColor.new("Bright yellow"),
			Size = Vector3.new(2, 1, 1),
			BackSurface = Enum.SurfaceType.Smooth,
			BottomSurface = Enum.SurfaceType.Inlet,
			FrontSurface = Enum.SurfaceType.Smooth,
			LeftSurface = Enum.SurfaceType.Smooth,
			RightSurface = Enum.SurfaceType.Smooth,
			TopSurface = Enum.SurfaceType.Smooth,
		},
		DefaultInstances = {
			{
				ClassName = "SpecialMesh",
				Properties = {
					Name = "Mesh",
					MeshType = Enum.MeshType.Head,
					Scale = Vector3.new(1.25, 1.25, 1.25),
					Offset = Vector3.new(0, 0, 0),
					VertexColor = Vector3.new(1, 1, 1)
				},
			},
			{
				ClassName = "Decal",
				Properties = {
					Name = "face",
					Shiny = 20,
					Specular = 0,
					Face = Enum.NormalId.Front,
					Texture = "rbxasset://textures/face.png"
				},
			},
		},
	},
	["Torso"] = {
		Joint = "Neck",
		Properties = {
			BrickColor = BrickColor.new("Bright blue"),
			Size = Vector3.new(2, 2, 1),
			BackSurface = Enum.SurfaceType.Smooth,
			BottomSurface = Enum.SurfaceType.Inlet,
			FrontSurface = Enum.SurfaceType.Smooth,
			LeftSurface = Enum.SurfaceType.Weld,
			RightSurface = Enum.SurfaceType.Weld,
			TopSurface = Enum.SurfaceType.Studs,
			LeftParamA = 0,
			LeftParamB = 0,
			RightParamA = 0,
			RightParamB = 0,
		},
		DefaultInstances = {
			{
				ClassName = "Decal",
				Properties = {
					Name = "roblox",
					Shiny = 20,
					Specular = 0,
					Face = Enum.NormalId.Front,
					Texture = ""
				},
			},
		},
	},
	["HumanoidRootPart"] = {
		Joint = "RootJoint",
		Properties = {
			BrickColor = BrickColor.new("Bright blue"),
			Size = Vector3.new(2, 2, 1),
			Transparency = 1,
			BackSurface = Enum.SurfaceType.Smooth,
			BottomSurface = Enum.SurfaceType.Smooth,
			FrontSurface = Enum.SurfaceType.Smooth,
			LeftSurface = Enum.SurfaceType.Smooth,
			RightSurface = Enum.SurfaceType.Smooth,
			TopSurface = Enum.SurfaceType.Smooth,
			LeftParamA = 0,
			LeftParamB = 0,
			RightParamA = 0,
			RightParamB = 0,
		},
	},
	["Left Arm"] = {
		Joint = "Left Shoulder",
		Properties = {
			BrickColor = BrickColor.new("Bright yellow"),
			Size = Vector3.new(1, 2, 1),
			BackSurface = Enum.SurfaceType.Smooth,
			BottomSurface = Enum.SurfaceType.Inlet,
			FrontSurface = Enum.SurfaceType.Smooth,
			LeftSurface = Enum.SurfaceType.Smooth,
			RightSurface = Enum.SurfaceType.Smooth,
			TopSurface = Enum.SurfaceType.Studs,
		},
	},
	["Right Arm"] = {
		Joint = "Right Shoulder",
		Properties = {
			BrickColor = BrickColor.new("Bright yellow"),
			Size = Vector3.new(1, 2, 1),
			BackSurface = Enum.SurfaceType.Smooth,
			BottomSurface = Enum.SurfaceType.Inlet,
			FrontSurface = Enum.SurfaceType.Smooth,
			LeftSurface = Enum.SurfaceType.Smooth,
			RightSurface = Enum.SurfaceType.Smooth,
			TopSurface = Enum.SurfaceType.Studs,
		},
	},
	["Left Leg"] = {
		Joint = "Left Hip",
		Properties = {
			BrickColor = BrickColor.new("Br. yellowish green"),
			Size = Vector3.new(1, 2, 1),
			BackSurface = Enum.SurfaceType.Smooth,
			BottomSurface = Enum.SurfaceType.Smooth,
			FrontSurface = Enum.SurfaceType.Smooth,
			LeftSurface = Enum.SurfaceType.Smooth,
			RightSurface = Enum.SurfaceType.Smooth,
			TopSurface = Enum.SurfaceType.Studs,
		},
	},
	["Right Leg"] = {
		Joint = "Right Hip",
		Properties = {
			BrickColor = BrickColor.new("Br. yellowish green"),
			Size = Vector3.new(1, 2, 1),
			BackSurface = Enum.SurfaceType.Smooth,
			BottomSurface = Enum.SurfaceType.Smooth,
			FrontSurface = Enum.SurfaceType.Smooth,
			LeftSurface = Enum.SurfaceType.Smooth,
			RightSurface = Enum.SurfaceType.Smooth,
			TopSurface = Enum.SurfaceType.Studs,
		},
	},
	
	--R15 limbs
	["LeftFoot"] = {
		Joint = "LeftAnkle",
		Properties = {
			BrickColor = BrickColor.new("Br. yellowish green"),
			Size = Vector3.new(1.001, 0.335, 1),
			BackSurface = Enum.SurfaceType.Smooth,
			BottomSurface = Enum.SurfaceType.Smooth,
			FrontSurface = Enum.SurfaceType.Smooth,
			LeftSurface = Enum.SurfaceType.Smooth,
			RightSurface = Enum.SurfaceType.Smooth,
			TopSurface = Enum.SurfaceType.Studs,
			MeshId = "http://www.roblox.com/asset?id=467982673"
		},
	},
	["RightFoot"] = {
		Joint = "RightAnkle",
		Properties = {
			BrickColor = BrickColor.new("Br. yellowish green"),
			Size = Vector3.new(1.001, 0.335, 1),
			BackSurface = Enum.SurfaceType.Smooth,
			BottomSurface = Enum.SurfaceType.Smooth,
			FrontSurface = Enum.SurfaceType.Smooth,
			LeftSurface = Enum.SurfaceType.Smooth,
			RightSurface = Enum.SurfaceType.Smooth,
			TopSurface = Enum.SurfaceType.Studs,
			MeshID = "http://www.roblox.com/asset?id=467982681"
		},
	},
	["LeftLowerLeg"] = {
		Joint = "LeftKnee",
		Properties = {
			BrickColor = BrickColor.new("Br. yellowish green"),
			Size = Vector3.new(1, 1.49, 1),
			BackSurface = Enum.SurfaceType.Smooth,
			BottomSurface = Enum.SurfaceType.Smooth,
			FrontSurface = Enum.SurfaceType.Smooth,
			LeftSurface = Enum.SurfaceType.Smooth,
			RightSurface = Enum.SurfaceType.Smooth,
			TopSurface = Enum.SurfaceType.Studs,
			MeshID = "http://www.roblox.com/asset?id=467982675"
		},
	},
	["RightLowerLeg"] = {
		Joint = "RightKnee",
		Properties = {
			BrickColor = BrickColor.new("Br. yellowish green"),
			Size = Vector3.new(1, 1.49, 1),
			BackSurface = Enum.SurfaceType.Smooth,
			BottomSurface = Enum.SurfaceType.Smooth,
			FrontSurface = Enum.SurfaceType.Smooth,
			LeftSurface = Enum.SurfaceType.Smooth,
			RightSurface = Enum.SurfaceType.Smooth,
			TopSurface = Enum.SurfaceType.Studs,
			MeshID = "http://www.roblox.com/asset?id=467982684"
		},
	},
	["LeftUpperLeg"] = {
		Joint = "LeftHip",
		Properties = {
			BrickColor = BrickColor.new("Br. yellowish green"),
			Size = Vector3.new(1, 1.536, 1.001),
			BackSurface = Enum.SurfaceType.Smooth,
			BottomSurface = Enum.SurfaceType.Smooth,
			FrontSurface = Enum.SurfaceType.Smooth,
			LeftSurface = Enum.SurfaceType.Smooth,
			RightSurface = Enum.SurfaceType.Smooth,
			TopSurface = Enum.SurfaceType.Studs,
			MeshID = "http://www.roblox.com/asset?id=467982678"
		},
	},
	["RightUpperLeg"] = {
		Joint = "RightHip",
		Properties = {
			BrickColor = BrickColor.new("Br. yellowish green"),
			Size = Vector3.new(1, 1.536, 1.001),
			BackSurface = Enum.SurfaceType.Smooth,
			BottomSurface = Enum.SurfaceType.Smooth,
			FrontSurface = Enum.SurfaceType.Smooth,
			LeftSurface = Enum.SurfaceType.Smooth,
			RightSurface = Enum.SurfaceType.Smooth,
			TopSurface = Enum.SurfaceType.Studs,
			MeshID = "http://www.roblox.com/asset?id=467982686"
		},
	},
	["LeftHand"] = {
		Joint = "LeftWrist",
		Properties = {
			BrickColor = BrickColor.new("Bright yellow"),
			Size = Vector3.new(0.999, 0.335, 1),
			BackSurface = Enum.SurfaceType.Smooth,
			BottomSurface = Enum.SurfaceType.Smooth,
			FrontSurface = Enum.SurfaceType.Smooth,
			LeftSurface = Enum.SurfaceType.Smooth,
			RightSurface = Enum.SurfaceType.Smooth,
			TopSurface = Enum.SurfaceType.Studs,
			MeshID = "http://www.roblox.com/asset?id=467982655"
		},
	},
	["RightHand"] = {
		Joint = "RightWrist",
		Properties = {
			BrickColor = BrickColor.new("Bright yellow"),
			Size = Vector3.new(0.999, 0.335, 1),
			BackSurface = Enum.SurfaceType.Smooth,
			BottomSurface = Enum.SurfaceType.Smooth,
			FrontSurface = Enum.SurfaceType.Smooth,
			LeftSurface = Enum.SurfaceType.Smooth,
			RightSurface = Enum.SurfaceType.Smooth,
			TopSurface = Enum.SurfaceType.Studs,
			MeshID = "http://www.roblox.com/asset?id=467982662"
		},
	},
	["RightLowerArm"] = {
		Joint = "RightElbow",
		Properties = {
			BrickColor = BrickColor.new("Bright yellow"),
			Size = Vector3.new(1, 1.266, 1),
			BackSurface = Enum.SurfaceType.Smooth,
			BottomSurface = Enum.SurfaceType.Smooth,
			FrontSurface = Enum.SurfaceType.Smooth,
			LeftSurface = Enum.SurfaceType.Smooth,
			RightSurface = Enum.SurfaceType.Smooth,
			TopSurface = Enum.SurfaceType.Studs,
			MeshID = "http://www.roblox.com/asset?id=467982658"
		},
	},
	["RightUpperArm"] = {
		Joint = "RightShoulder",
		Properties = {
			BrickColor = BrickColor.new("Bright yellow"),
			Size = Vector3.new(1, 1.396, 1),
			BackSurface = Enum.SurfaceType.Smooth,
			BottomSurface = Enum.SurfaceType.Smooth,
			FrontSurface = Enum.SurfaceType.Smooth,
			LeftSurface = Enum.SurfaceType.Smooth,
			RightSurface = Enum.SurfaceType.Smooth,
			TopSurface = Enum.SurfaceType.Studs,
			MeshID = "http://www.roblox.com/asset?id=467982669"
		},
	},
	["LeftLowerArm"] = {
		Joint = "LeftElbow",
		Properties = {
			BrickColor = BrickColor.new("Bright yellow"),
			Size = Vector3.new(1, 1.266, 1),
			BackSurface = Enum.SurfaceType.Smooth,
			BottomSurface = Enum.SurfaceType.Smooth,
			FrontSurface = Enum.SurfaceType.Smooth,
			LeftSurface = Enum.SurfaceType.Smooth,
			RightSurface = Enum.SurfaceType.Smooth,
			TopSurface = Enum.SurfaceType.Studs,
			MeshID = "http://www.roblox.com/asset?id=467982658"
		},
	},
	["LeftUpperArm"] = {
		Joint = "LeftShoulder",
		Properties = {
			BrickColor = BrickColor.new("Bright yellow"),
			Size = Vector3.new(1, 1.396, 1),
			BackSurface = Enum.SurfaceType.Smooth,
			BottomSurface = Enum.SurfaceType.Smooth,
			FrontSurface = Enum.SurfaceType.Smooth,
			LeftSurface = Enum.SurfaceType.Smooth,
			RightSurface = Enum.SurfaceType.Smooth,
			TopSurface = Enum.SurfaceType.Studs,
			MeshID = "http://www.roblox.com/asset?id=467982661"
		},
	},																
														
}

return Limbs