local Updater = {}

function Updater:Add(obj)
	if(not obj.Update)then return error("Updater:Add expects an argument that is alive and has an Update function.",2)end
	if(self:IsAlive(obj))then
		table.insert(self,{
			Object=obj;
			IsAlive=function(s)
				return self:IsAlive(s.Object)
			end,
		})
	end
end

function Updater:Destroy(obj)
	for i = #self,1,-1 do
		if(self[i].Object==obj)then
			table.remove(self,i)
		end
	end
end

function Updater:IsAlive(obj)
	if(not obj.Update)then print('no update') return false end
	return obj.Destroyed==false or obj.Alive==true or obj.Destroyed==nil and obj.Alive==nil	
end

function Updater:ClearDead()
	for i = #self,1,-1 do
		if(not self[i]:IsAlive())then
			table.remove(self,i)
		end
	end
end

game:service'RunService'.Heartbeat:connect(function(deltaTime)
	Updater:ClearDead()
	for i = #Updater,1,-1 do
		Updater[i].Object:Update(deltaTime)
	end
end)

return Updater

-- Prev stuff
--[==[ 
function Updater:Add(obj)
	if(not obj.Update)then return error("Updater:Add expects an argument that is alive and has an Update function.",2)end
	if(self:IsAlive(obj))then
		table.insert(self,{
			Object=obj;
			IsAlive=function(s)
				return self:IsAlive(s.Object)
			end,
		})
	end
end

function Updater:Destroy(obj)
	for i = #self,1,-1 do
		if(self[i].Object==obj)then
			table.remove(self,i)
		end
	end
end

function Updater:IsAlive(obj)
	if(not obj.Update)then print('no update') return false end
	return obj.Destroyed==false or obj.Alive==true or obj.Destroyed==nil and obj.Alive==nil	
end

function Updater:ClearDead()
	for i = #self,1,-1 do
		if(not self[i]:IsAlive())then
			table.remove(self,i)
		end
	end
end

game:service'RunService'.Heartbeat:connect(function(deltaTime)
	Updater:ClearDead()
	for i = #Updater,1,-1 do
		Updater[i].Object:Update(deltaTime)
	end
end)
]==]