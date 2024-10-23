local Parts = {}
local Con
for i,v in pairs(script.Parent:GetDescendants()) do 
	if v:IsA("BasePart") then

		v.CollisionGroup = "Player Collide"
		
		Parts[#Parts+1] = v
	end
end

script.Disabled = true

Con = game:GetService("RunService").RenderStepped:Connect(function()
	if script.Parent.Parent then
		for i,v in pairs(Parts) do 
			v.LocalTransparencyModifier = 0
		end
	else 
		Con:Disconnect()
	end
end)