-- THIS IS A FEATURE THAT IS NOT YET IMPLEMENTED

--!nolint
return {
	preInit = function()
		-- This function handles the icon beat
		gameFunctions.IconBeat = function(BeatLength)
			local DadRotation = gameHandler.tween(gameUI.realGameUI.Notes.Dad,{Rotation = 360},BeatLength,Enum.EasingStyle.Quint,Enum.EasingDirection.Out,0,false,0)
			local BFRotation = gameHandler.tween(gameUI.realGameUI.Notes.BF,{Rotation = 360},BeatLength,Enum.EasingStyle.Quint,Enum.EasingDirection.Out,0,false,0)
			if plrStats.Health < 0.4 then
				--Dying
				if flipMode then
					DadRotation:Pause()
					BFRotation:Play()
					gameUI.realGameUI.Notes.Dad.Rotation = 0
				else
					BFRotation:Pause()
					DadRotation:Play()
					gameUI.realGameUI.Notes.BF.Rotation = 0
				end
			elseif plrStats.Health > 1.6 then
				--Winning
				if flipMode then
					BFRotation:Pause()
					DadRotation:Play()
					gameUI.realGameUI.Notes.BF.Rotation = 0
				else
					DadRotation:Pause()
					BFRotation:Play()
					gameUI.realGameUI.Notes.Dad.Rotation = 0
				end
			else
				DadRotation:Play()
				BFRotation:Play()
			end
		end
		
		-- This function handles the icon beat on every other beat
		gameFunctions.IconBeatAlt = function(BeatLength)
			local DadRotation = gameHandler.tween(gameUI.realGameUI.Notes.Dad,{Rotation = 0},BeatLength,Enum.EasingStyle.Quint,Enum.EasingDirection.Out,0,false,0)
			local BFRotation = gameHandler.tween(gameUI.realGameUI.Notes.BF,{Rotation = 0},BeatLength,Enum.EasingStyle.Quint,Enum.EasingDirection.Out,0,false,0)
			if plrStats.Health < 0.4 then
				--Dying
				if flipMode then
					DadRotation:Pause()
					BFRotation:Play()
					gameUI.realGameUI.Notes.Dad.Rotation = 0
				else
					BFRotation:Pause()
					DadRotation:Play()
					gameUI.realGameUI.Notes.BF.Rotation = 0
				end
			elseif plrStats.Health > 1.6 then
				--Winning
				if flipMode then
					BFRotation:Pause()
					DadRotation:Play()
					gameUI.realGameUI.Notes.BF.Rotation = 0
				else
					DadRotation:Pause()
					BFRotation:Play()
					gameUI.realGameUI.Notes.Dad.Rotation = 0
				end
			else
				DadRotation:Play()
				BFRotation:Play()
			end
		end
		
		-- This function handles updating the health bar positioning
		gameFunctions.HealthBar = function(gui, BOY, DAD, scale, normal, center)
			if flipMode then -- Just swapping it lel
				gui.BarContainer.GreenBar.Size = UDim2.fromScale((1-normal),1)
				gui.BarContainer.RedBar.Size = UDim2.fromScale(normal,1)
				BOY.GUI.Position = UDim2.fromScale(center-(0.5-normal)*scale,gui.Position.Y.Scale)
				DAD.GUI.Position = UDim2.fromScale(center-(0.5-normal)*scale,gui.Position.Y.Scale)
			else
				gui.BarContainer.RedBar.Size = UDim2.fromScale((1-normal),1)
				gui.BarContainer.GreenBar.Size = UDim2.fromScale(normal,1)
				BOY.GUI.Position = UDim2.fromScale(center+(0.5)*scale,gui.Position.Y.Scale)
				DAD.GUI.Position = UDim2.fromScale(center*scale,gui.Position.Y.Scale)
			end

			BOY:UpdateSize()
			DAD:UpdateSize()
		end
	end,
}