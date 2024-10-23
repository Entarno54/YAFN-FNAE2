local Song = script.Parent
local TweenService = game:GetService("TweenService")
local ThingTick = nil
local IsDancing = false
local DanceTrack

function Tween(object,properties,time,style,dir,repeats,reverse,delay)
	local info = TweenInfo.new(time or 1,style or Enum.EasingStyle.Linear,dir or Enum.EasingDirection.Out,repeats or 0,reverse or false,delay or 0)
	local tween = TweenService:Create(object,info,properties)
	return tween;
end


local Play = Tween(Song,{Volume = .7},3,Enum.EasingStyle.Back,Enum.EasingDirection.InOut)
local Stop = Tween(Song,{Volume = 0},1,Enum.EasingStyle.Back,Enum.EasingDirection.InOut)


workspace.CurrentCamera:GetPropertyChangedSignal("CameraType"):Connect(function() -- checks if booted aswell
	if workspace.CurrentCamera.CameraType == Enum.CameraType.Scriptable then
		ThingTick = tick()
		Song:Play()
		Play:Play()
	else 
		if DanceTrack then
			DanceTrack:Stop()
			DanceTrack:Destroy()
			DanceTrack = nil
		end
		Stop:Play()
		IsDancing = false
		ThingTick = nil
	end
end)


Song.Parent.Parent.OwnerWait:GetPropertyChangedSignal("Visible"):Connect(function()
	if not Song.Parent.Parent.OwnerWait.Visible then
		Stop:Play()
		if DanceTrack then
			DanceTrack:Stop()
			DanceTrack:Destroy()
			DanceTrack = nil
		end
		IsDancing = false
		ThingTick = nil
	end
end)

game:GetService("RunService").RenderStepped:Connect(function()
	if ThingTick and Song.Volume > .5 then
		if tick() - ThingTick > 60*5 then
			IsDancing = true
			DanceTrack = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):LoadAnimation(game.ReplicatedStorage.Animations.LobbyDance)
			DanceTrack.Priority = Enum.AnimationPriority.Idle
			DanceTrack:Play()
			ThingTick = nil
		end
	end
end)