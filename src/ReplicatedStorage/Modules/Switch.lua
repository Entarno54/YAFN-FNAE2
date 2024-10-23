
local switchObjectMethods = {}
switchObjectMethods.__index = switchObjectMethods

switchObjectMethods.__call = function(self, variable)
	local c = self._callbacks[variable] or self._default
	if not c then
		error("No case statement defined for variable, and :default is not defined")
	end

	c()
end

function switchObjectMethods:case(v, f)
	self._callbacks[v] = f
	return self
end

function switchObjectMethods:default(f)
	self._default = f
	return self
end

-------------------------------------------------------------0
return function()
	local o = setmetatable({}, switchObjectMethods)	
	o._callbacks = {}	
	return o
end