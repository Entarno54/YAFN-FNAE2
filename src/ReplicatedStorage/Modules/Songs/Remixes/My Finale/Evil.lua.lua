local helper = require(game.ReplicatedStorage.Modules.ModchartHelper)
local evil = nil
local evil2 = nil
return {
	P2NoteHit = function()
		print(flipMode)
		if plrStats.Health >= 0.05 then
			plrStats.Health -= 0.03
		end
	end,
	Start = function()
		if not evil and not evil2 then
			evil = addSprite('Overlay', Color3.fromRGB(0,0,0), gameUI)
			evil.ZIndex = 0
			evil2 = script.ImageLabel:Clone()
			evil2.Parent = evil
		end
		game.TweenService:Create(evil2, TweenInfo.new(10, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 302, 0, 270)}):Play()
		game.TweenService:Create(evil2.UIGradient, TweenInfo.new(10, Enum.EasingStyle.Linear), {Offset = Vector2.new(0, -1)}):Play()
		task.wait(9)
		game.TweenService:Create(evil, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
		game.TweenService:Create(evil2, TweenInfo.new(1), {ImageTransparency = 1}):Play()
	end,
	cleanUp = function()
		if evil then evil:Destroy() evil2:Destroy() end
		evil = nil
		evil2 = nil
	end,
}