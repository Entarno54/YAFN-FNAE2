local module = {}
local CurrentBinds = {}
local BindPressed = {}
local currentPressedKeys = {}
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local IdGen = Random.new()
local InputEvents = {
	Began = Instance.new("BindableEvent");
	Changed = Instance.new("BindableEvent");
	Ended = Instance.new("BindableEvent");
	Pressed = Instance.new("BindableEvent"); -- Basically an equivalent of "MouseButton1Clicked", but with keys instead.
}
module.FocusedTextBox = false
UIS.TextBoxFocused:Connect(function(TextBox)
	module.FocusedTextBox = TextBox
end)
UIS.TextBoxFocusReleased:Connect(function()
	wait() -- damn you roblox
	module.FocusedTextBox = false
end)
UIS.InputBegan:Connect(function(IO,gPE)
	if(UIS:GetFocusedTextBox()~=nil)then return end
	local KeyCodeIndex = module.FindBindName(IO.KeyCode)
	currentPressedKeys[IO.KeyCode] = not module.FocusedTextBox
	if KeyCodeIndex and not module.FocusedTextBox then
		BindPressed[KeyCodeIndex] = true
		InputEvents.Began:Fire(KeyCodeIndex,IO,gPE)
	end
end)
UIS.InputChanged:Connect(function(IO,gPE)
	if(UIS:GetFocusedTextBox()~=nil)then return end
	local KeyCodeIndex = module.FindBindName(IO.KeyCode)
	if KeyCodeIndex and not module.FocusedTextBox then
		InputEvents.Changed:Fire(KeyCodeIndex,IO,gPE)
	end
end)
UIS.InputEnded:Connect(function(IO,gPE)
	if(UIS:GetFocusedTextBox()~=nil)then return end
	local KeyCodeIndex = module.FindBindName(IO.KeyCode)
	if currentPressedKeys[IO.KeyCode] ~= nil then
		if currentPressedKeys[IO.KeyCode] and KeyCodeIndex and not module.FocusedTextBox then
			InputEvents.Pressed:Fire(KeyCodeIndex,IO,gPE)
		end
		currentPressedKeys[IO.KeyCode] = nil
	end
	if KeyCodeIndex and not module.FocusedTextBox then
		BindPressed[KeyCodeIndex] = false
		InputEvents.Ended:Fire(KeyCodeIndex,IO,gPE)
	end
end)


function module.AddBind(bindName,keyCode)
	if keyCode.EnumType ~= Enum.KeyCode then
		error("Enum is not a Keycode!")
	end
	for searchBindName,KeyCodes in next,CurrentBinds do
		local KeyCodeIndex = table.find(KeyCodes,keyCode)
		if KeyCodeIndex then
			table.remove(KeyCodes,KeyCodeIndex)
			--warn(("%s has already been binded to %s, moving bind instead!"):format(keyCode.Name,searchBindName))
			break
		end
	end
	local oldKeyCode = CurrentBinds[bindName]
	if oldKeyCode then
		if table.find(oldKeyCode,keyCode) ~= keyCode then
			oldKeyCode[#oldKeyCode+1] = keyCode
		end
	else
		CurrentBinds[bindName] = {keyCode}
		BindPressed[bindName] = false
	end
	--print("added", keyCode,"at",bindName)
end
function module.CreateBindButton(bindName,buttonObj)
	if not buttonObj then
		buttonObj = Instance.new("ImageButton")
	end
	for searchBindName,KeyCodes in next,CurrentBinds do
		local KeyCodeIndex = table.find(KeyCodes,buttonObj)
		if KeyCodeIndex then
			table.remove(KeyCodes,KeyCodeIndex)
			--warn(("%s has already been binded to %s, moving bind instead!"):format(tostring(buttonObj),searchBindName))
			break
		end
	end
	local oldKeyCode = CurrentBinds[bindName]
	if oldKeyCode then
		if table.find(oldKeyCode,buttonObj) ~= buttonObj then
			oldKeyCode[#oldKeyCode+1] = buttonObj
		end
	else
		CurrentBinds[bindName] = {buttonObj}
		BindPressed[bindName] = false
	end
	
	-- touch support
	--[[
	buttonObj.InputBegan:Connect(function(IO,gPE)
		if IO.UserInputType == Enum.UserInputType.Touch and IO.UserInputState == Enum.UserInputState.Begin then
			print(IO.UserInputType,IO.UserInputState,IO.Position)
			BindPressed[bindName] = true
			InputEvents.Began:Fire(bindName,IO,gPE)
		end
	end)
	buttonObj.InputChanged:Connect(function(IO,gPE)
		print(IO.UserInputType,IO.UserInputState,IO.Position)
		if IO.UserInputType == Enum.UserInputType.Touch and IO.UserInputState == Enum.UserInputState.Change then
			local touchPosition = IO.Position
			local UIPos = buttonObj.AbsolutePosition
			local UISize = buttonObj.AbsoluteSize
			local relativePos = (Vector2.new(touchPosition.X,touchPosition.Y) - UIPos)
			if not ((relativePos.X > 0 and relativePos.X < UISize.X) and (relativePos.Y > 0 and relativePos.Y < UISize.Y)) then
				BindPressed[bindName] = false
				InputEvents.Ended:Fire(bindName,IO,gPE)
			end
		end
	end)
	buttonObj.InputEnded:Connect(function(IO,gPE)
		if IO.UserInputType == Enum.UserInputType.Touch and IO.UserInputState == Enum.UserInputState.End then
			BindPressed[bindName] = false
			InputEvents.Ended:Fire(bindName,IO,gPE)
		end
	end)
	--]]
	local touchIOList = {}
	UIS.TouchStarted:Connect(function(IO,gPE)
		local touchPosition = IO.Position
		local UIPos = buttonObj.AbsolutePosition
		local UISize = buttonObj.AbsoluteSize
		local relativePos = (Vector2.new(touchPosition.X,touchPosition.Y) - UIPos)
		if ((relativePos.X > 0 and relativePos.X < UISize.X) and (relativePos.Y > 0 and relativePos.Y < UISize.Y)) then
			touchIOList[#touchIOList + 1] = IO
			BindPressed[bindName] = true
			InputEvents.Began:Fire(bindName,IO,gPE)
		end
	end)
	UIS.TouchMoved:Connect(function(IO,gPE)
		local lastIO = table.find(touchIOList,IO)
		if lastIO then
			touchIOList[lastIO] = IO
			local touchPosition = IO.Position
			local UIPos = buttonObj.AbsolutePosition
			local UISize = buttonObj.AbsoluteSize
			local relativePos = (Vector2.new(touchPosition.X,touchPosition.Y) - UIPos)
			if not ((relativePos.X > 0 and relativePos.X < UISize.X) and (relativePos.Y > 0 and relativePos.Y < UISize.Y)) then
				BindPressed[bindName] = false
				InputEvents.Ended:Fire(bindName,IO,gPE)
				table.remove(touchIOList,lastIO)
				--print("dragged away from button!")
			end
		end
	end)
	UIS.TouchEnded:Connect(function(IO,gPE)
		local lastIO = table.find(touchIOList,IO)
		if lastIO then
			--touchIOList[lastIO] = IO
			table.remove(touchIOList,lastIO)
			BindPressed[bindName] = false
			InputEvents.Ended:Fire(bindName,IO,gPE)
		end
	end)
	--print("added button object at",bindName)
	return buttonObj
end

function module.ChangeBind(bindName,keyCode)
	local KeyCodeIndex
	for searchBindName,KeyCodes in next,CurrentBinds do
		KeyCodeIndex = table.find(KeyCodes,keyCode)
		if KeyCodeIndex then
			table.remove(KeyCodes,KeyCodeIndex)
			break
		end
	end
	local oldKeyCode = CurrentBinds[bindName]
	if oldKeyCode then
		if table.find(oldKeyCode,keyCode) ~= keyCode then
			oldKeyCode[#oldKeyCode+1] = keyCode
		end
	else
		CurrentBinds[bindName] = {keyCode}
		BindPressed[bindName] = false
	end
	--print("moved",keyCode,"to",bindName)
end
function module.RemoveBind(keyCode)
	local KeyCodeIndex
	for searchBindName,KeyCodes in next,CurrentBinds do
		KeyCodeIndex = table.find(KeyCodes,keyCode)
		if KeyCodeIndex then
			table.remove(KeyCodes,KeyCodeIndex)
			print("removed",keyCode)
			break
		end
	end
end
function module.IsBindPressed(bindName)
	if type(BindPressed[bindName]) == "boolean" then
		return BindPressed[bindName]
	end
end
function module.ClearBinds(bindName)
	if CurrentBinds[bindName] then -- this is more of a bind removal, but still cleans them.
		CurrentBinds[bindName] = nil
		BindPressed[bindName] = nil
	end
end
function module.ClearAllBinds()
	CurrentBinds = {}
	BindPressed = {}
end
function module.FindBindName(keyCode)
	local KeyCodeIndex
	for searchBindName,KeyCodes in next,CurrentBinds do
		KeyCodeIndex = table.find(KeyCodes,keyCode)
		if KeyCodeIndex then
			KeyCodeIndex = searchBindName
			break
		end
	end
	return KeyCodeIndex
end
function module.GetCurrentBindsList()
	return CurrentBinds
end

module.InputEvents = {
	Began = InputEvents.Began.Event;
	Changed = InputEvents.Changed.Event;
	Ended = InputEvents.Ended.Event;
	Pressed = InputEvents.Pressed.Event;
}
return module