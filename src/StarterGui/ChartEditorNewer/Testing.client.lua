local ChartHandler = require(script.Parent.Main.ChartHandler)

local enabled = false

game:GetService("UserInputService").InputBegan:Connect(function(input, gPE)
	if input.KeyCode == Enum.KeyCode.Seven and game:GetService("RunService"):IsStudio() and not gPE then
		if enabled then
			ChartHandler.Enable(false)
			enabled = false
			script.Parent.Enabled = false
		else
			ChartHandler.Enable(true)
			script.Parent.Enabled = true
			enabled = true
		end		
	end
end)