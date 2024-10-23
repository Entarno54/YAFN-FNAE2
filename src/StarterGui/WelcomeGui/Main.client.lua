script.Parent.Frame.Visible = true

local texts = {
	"Hello chat",
	"Its friday night real",
	"Based on YAFN engine",
	"Made by Entar57212",
	"Welcome to"
}

for _, text in texts do
	script.Parent.Frame.TextLabel.Text = text
	task.wait(3)
end
script.Parent.Frame.Transparency = 0.7
script.Parent.Frame.BackgroundColor = BrickColor.White()
script.Parent.Frame.TextLabel.Visible = false
script.Parent.Frame.TextLabelS.Visible = true
script.Parent.Frame.TextLabelSI.Visible = true
game.TweenService:Create(script.Parent.Frame.TextLabelS, TweenInfo.new(.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, true), {Size = UDim2.new(0.394, 200, 0.331, 0), Position = UDim2.new(0.227, 0,0.334, 0)}):Play()

game.UserInputService.InputBegan:Connect(function(i)
	if i.KeyCode == Enum.KeyCode.Return or i.UserInputType == Enum.UserInputType.Touch then
		script.Parent.Frame.Transparency = 0.3
		game.TweenService:Create(script.Parent.Frame, TweenInfo.new(0.3), {Transparency = 1}):Play()
		script.Parent.Frame.TextLabelS.Visible = false
		script.Parent.Frame.TextLabelSI.Visible = false
		task.wait(.4)
		script.Parent.Enabled = false
	end
end)