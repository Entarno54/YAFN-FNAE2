local module = {}

local buttonCons = {}
local baseCons = {}
local function clearItems(frame)
	--print("Clearing items for " .. frame.Name)
	
	for _,con in pairs(buttonCons) do
		if con ~= nil then con:Disconnect() end
	end
	table.clear(buttonCons)
	
	for _,item in pairs(frame:GetChildren()) do
		if item.Name == "UIListLayout" then continue end
		item:Destroy()
	end
end

module.Loaded = function(Settings, SongInfo, SongData, funcs)
	local options = script.Parent
	
	-- Populate the scrolling frame with the various mod options
	
	-- This will contain the mods
	local scrollingFrame = options.Chart.ScrollingFrame
	scrollingFrame.Visible = false
	
	-- This will contain the "Charts/Events/Modcharts" stuff
	local scrollingFrame2 = options.Chart.ScrollingFrame2
	scrollingFrame2.Visible = false
	
	clearItems(scrollingFrame)
	local function updateList(filter)
		for _,mod in pairs(game.ReplicatedStorage.Modules.Songs:GetChildren()) do
			if filter ~= nil and not string.match(mod.Name, filter) then continue end
			local newButton = options.Chart.Template:Clone()

			newButton.Name = mod.Name
			newButton.Text = mod.Name

			table.insert(buttonCons, newButton.Activated:Connect(function()
				--print(newButton.Text)

				-- Unload things
				scrollingFrame.Visible = false
				clearItems(scrollingFrame2)

				-- Load the charts
				local modFolder = game.ReplicatedStorage.Modules.Songs:FindFirstChild(mod.Name)
				for _,item in pairs(modFolder:GetChildren()) do
					local newItem = options.Chart.Template:Clone()

					newItem.Name = item.Name
					newItem.Text = item.Name

					-- Bascially when you click on one of the mod options it will bring up the charts and events contained inside of it
					table.insert(buttonCons, newItem.Activated:Connect(function()
						local selectedItem = modFolder:FindFirstChild(item.Name)
						local function applyChart(button)
							scrollingFrame.Visible = false
							scrollingFrame2.Visible = false

							Settings.chart = button;
							local newChart = funcs.loadChart(button);

							options.Chart.TextBox.Text = newChart.song
							funcs.loadSong(newChart.song)
						end

						if selectedItem:IsA('Folder') then
							clearItems(scrollingFrame2)
							for _,modules in pairs(selectedItem:GetChildren()) do
								local newItem = options.Chart.Template:Clone()
								newItem.Name = modules.Name
								newItem.Text = modules.Name
								table.insert(buttonCons, newItem.Activated:Connect(function()
									applyChart(selectedItem:FindFirstChild(modules.Name))
								end))

								newItem.Visible = true
								newItem.Parent = scrollingFrame2
							end
						else
							applyChart(selectedItem)
						end
					end))

					newItem.Visible = true
					newItem.Parent = scrollingFrame2
				end

				scrollingFrame2.Visible = true
			end))

			newButton.Visible = true
			newButton.Parent = scrollingFrame
		end
	end
	
	updateList(nil)
	
	table.insert(baseCons, options.Chart.TextBox.Changed:Connect(function(prop)
		if prop == "Text" then
			clearItems(scrollingFrame)
			updateList(options.Chart.TextBox.Text)
		end
	end))
	
	table.insert(baseCons, options.Chart.TextBox.Focused:Connect(function()
		scrollingFrame.Visible = true
		scrollingFrame2.Visible = false
	end))
	
	table.insert(baseCons, script.Parent.Speed.TextBox.FocusLost:Connect(function()
		if tonumber(script.Parent.Speed.TextBox.Text) ~= nil then
			local newScrollSpeed = tonumber(script.Parent.Speed.TextBox.Text)
			script.Parent.Speed.TextBox.Text = newScrollSpeed
			SongData.speed = newScrollSpeed
		else
			script.Parent.Speed.TextBox.Text = SongData.speed or 1
		end
	end))
	--[[
	funcs.addConnection(options.Chart.TextBox.FocusLost:Connect(function()
		scrollingFrame.Visible = false
		scrollingFrame2.Visible = false
		for _,item in pairs(scrollingFrame2:GetChildren()) do
			if item.Name == "UIListLayout" then return end
			item:Destroy()
		end
	end))
	--]]
end

module.chartLoaded = function(chart)
	-- Update things
	script.Parent.Speed.TextBox.Text = chart.speed
end

module.Unloaded = function()
	for _,con in pairs(baseCons) do
		if con ~= nil then con:Disconnect() end
	end
	table.clear(baseCons)
	
	clearItems(script.Parent.Chart.ScrollingFrame)
	clearItems(script.Parent.Chart.ScrollingFrame2)
end

return module