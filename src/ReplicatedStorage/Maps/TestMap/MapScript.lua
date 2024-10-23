return {
	main = function()
		local up = true
		while true do
			local x,y,z = script.Parent.CameraTest.CFrame:ToOrientation()
			local tw = game:GetService("TweenService"):Create(script.Parent.CameraTest, TweenInfo.new(1), {CFrame = CFrame.new(script.Parent.CameraTest.Position + Vector3.new(0, -2, 0)) * CFrame.fromOrientation(x,y,z)})
			tw:Play()
			tw.Completed:Wait()	
			local tw = game:GetService("TweenService"):Create(script.Parent.CameraTest, TweenInfo.new(1), {CFrame = CFrame.new(script.Parent.CameraTest.Position + Vector3.new(0, 2, 0)) * CFrame.fromOrientation(x,y,z)})
			tw:Play()
			tw.Completed:Wait()	
		end
	end,
}