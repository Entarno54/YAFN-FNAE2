--!strict
-- please ignore this
-- ok do your thing now
local UIWindow = {}
UIWindow.__index = UIWindow
local rng:Random = Random.new(tick())
local RS:RunService = game:GetService("RunService")
local UIS:UserInputService = game:GetService("UserInputService")
type userdata = typeof(newproxy())
type RBXScriptSignal = typeof(Instance.new("BindableEvent").Event)
export type WindowElement = {
	Position:Vector2int16;
	CornerRadius:number;
	TopbarHeight:number;
	CloseButtonWidth:number?;
	Size:Vector2int16;
	HideWhenClose:boolean; -- If false, automatically destroy the object.
	Draggable:boolean;
	Objects:{
		Topbar:ImageLabel;
		Frame:Frame;
		Contents:Frame;
		CloseButton:ImageButton;
		Text:TextLabel;
	};
	Name:string;
	Parent:Instance|nil;
	-- Unwritable Values
	Locked:boolean;
	CurrentZIndex:number;
	-- Unaccessible Values
	EventObjs:{
		Closing:BindableEvent;
		Opening:BindableEvent;
		ZIndexUpdate:BindableEvent;
	};
	-- Events
	Closing:RBXScriptSignal; -- (isBeingDestroyed:bool)
	Opening:RBXScriptSignal;
	ZIndexUpdate:RBXScriptSignal; -- (newVal:number)
}
local WriteLockProps = {"Locked","CurrentZIndex"}
local UnaccessibleProps = {"EventObjs"} -- Basically deters any attempt to read/write the values thru the proxy.
local UISettings = {
	ZIndexSpacing = 10; -- Distance between UIs.
	ZIndexOffset = 50;
}

local PropertyChangeFunctions = {}
function PropertyChangeFunctions.Position(self:WindowElement,value:any):Vector2int16
	local valueType:string = typeof(value)
	if valueType == "Vector2" then
		return Vector2int16.new(value.X,value.Y)
	elseif valueType == "Vector2int16" then
		return value
	elseif valueType == "UDim2" then
		if self.Parent ~= nil and self.Parent:IsA("GuiBase2d") then
			local theParent:GuiBase2d = self.Parent
			local scalePosition = Vector2int16.new(theParent.AbsoluteSize.X*value.X.Scale,theParent.AbsoluteSize.Y*value.Y.Scale)
			return scalePosition + Vector2int16.new(value.X.Offset,value.Y.Offset)
		else
			error("Cannot transform UDim2, parent is missing or invalid")
		end
	else
		error("Unable to cast value")
	end
end
PropertyChangeFunctions.Size = PropertyChangeFunctions.Position -- it's the same anyways

local currentOpenWindows:any = {}

function UIWindow.new()
	local Window = script.UIElements.Window:Clone()
	local Topbar = Window.TopBar
	local closeButton = Topbar.CloseButton
	local closingBindable,openingBindable,ZIUpdate = Instance.new("BindableEvent"),Instance.new("BindableEvent"),Instance.new("BindableEvent")
	local WindowElement:WindowElement = {
		Name = "Window";
		CornerRadius = 8;
		TopbarHeight = 15;
		CloseButtonWidth = 20;
		Position = Vector2int16.new(0,0); -- -32,768 , 32767
		Size = Vector2int16.new(50,50);
		HideWhenClose = false;
		Draggable = true;
		Objects = {
			Topbar = Topbar;
			Frame = Window;
			Contents = Window.Contents;
			CloseButton = closeButton;
			Text = Topbar.Text;
		};
		EventObjs={
			Closing = closingBindable;
			Opening = openingBindable;
			ZIndexUpdate = ZIUpdate;
		};
		CurrentZIndex = 0;
		Locked = false;
		Closing = closingBindable.Event;
		Opening = openingBindable.Event;
		ZIndexUpdate = ZIUpdate.Event;
	}
	Topbar.Parent = nil -- separate the topbar from the original copy
	local proxy:any = newproxy(true)
	local meta = getmetatable(proxy)
	function meta:__index(index)
		return WindowElement[index]
	end
	function meta:__newindex(index,value)
		if table.find(WriteLockProps,index) then warn(("Attempting to write %s with %s"):format(index,tostring(value)));return end
		local changeValFunc = PropertyChangeFunctions[index]
		if changeValFunc then
			WindowElement[index] = changeValFunc(WindowElement,value)
			-- probably add more options
		else
			WindowElement[index] = value
		end
		UIWindow.Update(WindowElement)
	end
	function meta:__tostring()
		return WindowElement.Name
	end
	meta.__metatable = newproxy()
	--setmetatable(proxy,meta)
	setmetatable(WindowElement,UIWindow)
	local closeButtonCon 
	local isMouseHovering
	closeButton.MouseButton1Click:Connect(function()
		if WindowElement.HideWhenClose then
			--closingBindable:Fire(false)
			WindowElement.Objects.Frame.Parent = nil
			WindowElement.Objects.Topbar.Parent = nil
			WindowElement.Parent = nil
			WindowElement:Update()
		else
			closingBindable:Fire(true)
			WindowElement:Destroy()
			closingBindable:Destroy()
			openingBindable:Destroy()
			ZIUpdate:Destroy()
		end
	end)
	closeButton.MouseEnter:Connect(function()
		isMouseHovering = true
	end)
	closeButton.MouseLeave:Connect(function()
		isMouseHovering = false
	end)
	Topbar.Text.InputBegan:Connect(function(IO:InputObject)
		if IO.UserInputType == Enum.UserInputType.MouseButton1 and not isMouseHovering then
			-- update the ZIndex
			table.remove(currentOpenWindows,table.find(currentOpenWindows,WindowElement))
			table.insert(currentOpenWindows,1,WindowElement)
			-- pretty lazy ngl
			UIWindow.UpdateZIndex()
			local pressPosition:Vector2 = UIS:GetMouseLocation()
			local offset:Vector2int16 = Vector2int16.new(WindowElement.Position.X-pressPosition.X,WindowElement.Position.Y-pressPosition.Y)
			local con:RBXScriptConnection
			local daName = "MouseMoveWindow_" .. WindowElement.Name
			con = Topbar.InputEnded:Connect(function(outIO:InputObject)
				if outIO.UserInputType == Enum.UserInputType.MouseButton1 then
					RS:UnbindFromRenderStep(daName)
					con:Disconnect()
				end
			end)
			RS:BindToRenderStep(daName,Enum.RenderPriority.Last.Value,function(delta)
				if WindowElement.Locked then RS:UnbindFromRenderStep(daName);con:Disconnect()return end -- stop it
				local pos:Vector2 = UIS:GetMouseLocation()
				WindowElement.Position = Vector2int16.new(pos.X,pos.Y) + offset
				WindowElement:Update(0)
			end)
		end
	end)
	WindowElement:Update()
	--UIWindow.UpdateZIndex(WindowElement)
	return proxy
end

function UIWindow:MoveWindow()
	
end

function UIWindow:Update(updateLevel:number|nil)
	if self.Locked then return end
	-- positioning stuff
	self.Objects.Topbar.Position = UDim2.fromOffset(self.Position.X,self.Position.Y)
	self.Objects.Frame.Position = UDim2.fromOffset(self.Position.X,self.Position.Y)
	if updateLevel == 0 then return end -- only update the positions
	-- resizing stuff
	self.Objects.Topbar.Size = UDim2.fromOffset(self.Size.X,self.TopbarHeight)
	self.Objects.Frame.Size = UDim2.fromOffset(self.Size.X,self.Size.Y)
	self.Objects.CloseButton.Size = UDim2.new(0,self.CloseButtonWidth,1,0)
	-- Details stuff
	local radius:number = self.CornerRadius
	self.Objects.Topbar.SliceScale = (radius)/40
	self.Objects.Text.Text = self.Name
	
	-- internal stuff
	self.Objects.Topbar.Parent = self.Parent
	self.Objects.Frame.Parent = self.Parent
	local selfIndex = table.find(currentOpenWindows,self)
	if not selfIndex and self.Parent ~= nil and typeof(self.Parent) == "Instance" and self.Parent:IsA("GuiBase2d") then
		table.insert(currentOpenWindows,1,self)
		UIWindow.UpdateZIndex(self)
		self.EventObjs.Opening:Fire()
	elseif selfIndex and (self.Parent == nil or typeof(self.Parent) == "Instance" and not self.Parent:IsA("GuiBase2d")) then
		table.remove(currentOpenWindows,selfIndex)
		self.EventObjs.Closing:Fire(false)
	end
	
end

function UIWindow.UpdateZIndex(self:any?)
	if self then
		local Index = table.find(currentOpenWindows,self)
		if Index then
			local anchorIndex = #currentOpenWindows-Index--(#currentOpenWindows-Index*UISettings.ZIndexSpacing)+UISettings.ZIndexOffset
			
			self.Objects.Frame.ZIndex = anchorIndex
			self.Objects.Topbar.ZIndex = 1
			--[[
			self.Objects.CloseButton.ZIndex =2
			self.Objects.Text.ZIndex = 2
			self.Objects.Contents.ZIndex = 2--]]
			self.CurrentZIndex = anchorIndex
			self.EventObjs.ZIndexUpdate:Fire(anchorIndex)
		end
	else
		for Index:number,Window:WindowElement in next,currentOpenWindows do
			local anchorIndex = #currentOpenWindows-Index --(#currentOpenWindows-Index*UISettings.ZIndexSpacing)+UISettings.ZIndexOffset
			Window.Objects.Frame.ZIndex = anchorIndex
			Window.Objects.Topbar.ZIndex = anchorIndex+1
			--[[
			Window.Objects.CloseButton.ZIndex = anchorIndex+2
			Window.Objects.Text.ZIndex = anchorIndex+2
			Window.Objects.Contents.ZIndex = anchorIndex+2
			--]]
			Window.CurrentZIndex = anchorIndex
			Window.EventObjs.ZIndexUpdate:Fire(anchorIndex)
		end
	end
end

function UIWindow:Destroy()
	print("Destroying ".. self.Name)
	local index = table.find(currentOpenWindows,self)
	if index then
		table.remove(currentOpenWindows,index)
	end
	self.Locked = true
	self.Objects.Topbar:Destroy()
	self.Objects.Frame:Destroy()
end

return UIWindow
