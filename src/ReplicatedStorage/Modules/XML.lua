-- from https://github.com/jonathanpoelen/xmlparser

local string, pairs = string, pairs

-- http://lua-users.org/wiki/StringTrim
local trim = function(s)
	local from = s:match"^%s*()"
	return from > #s and "" or s:match(".*%S", from)
end

local gtchar = string.byte('>', 1)
local slashchar = string.byte('/', 1)
local D = string.byte('D', 1)
local E = string.byte('E', 1)

function parse(s, evalEntities)
	-- remove comments
	s = s:gsub('<!%-%-(.-)%-%->', '')

	local entities, tentities = {}, {}

	if evalEntities then
		local pos = s:find('<[_%w]')
		if pos then
			s:sub(1, pos):gsub('<!ENTITY%s+([_%w]+)%s+(.)(.-)%2', function(name, q, entity)
				entities[#entities+1] = {name=name, value=entity}
			end)
			tentities = createEntityTable(entities)
			s = replaceEntities(s:sub(pos), tentities)
		end
	end

	local t, l = {}, {}

	local addtext = function(txt)
		txt = txt:match'^%s*(.*%S)' or ''
		if #txt ~= 0 then
			t[#t+1] = {text=txt}
		end    
	end
	s:gsub('<([?!/]?)([-:_%w]+)%s*(/?>?)([^<]*)', function(type, name, closed, txt)
		
		--print(type, "|", name, "|", closed, "|", txt)
		-- open
		if #type == 0 then
			local a = {}
			if #closed == 0 then
				local len = 0
				for all,aname,_,value,starttxt in string.gmatch(txt, "(.-([-_%w]+)%s*=%s*(.)(.-)%3%s*(/?>?))") do
					len = len + #all
					a[aname] = value
					if #starttxt ~= 0 then
						txt = txt:sub(len+1)
						closed = starttxt
						break
					end
				end
			end
			t[#t+1] = {tag=name, attrs=a, children={}}

			if closed:byte(1) ~= slashchar then
				l[#l+1] = t
				t = t[#t].children
			end

			addtext(txt)
			-- close
		elseif '/' == type then
			t = l[#l]
			l[#l] = nil

			addtext(txt)
			-- ENTITY
		elseif '!' == type then
			if E == name:byte(1) then
				txt:gsub('([_%w]+)%s+(.)(.-)%2', function(name, q, entity)
					entities[#entities+1] = {name=name, value=entity}
				end, 1)
			end
			-- elseif '?' == type then
			--   print('?  ' .. name .. ' // ' .. attrs .. '$$')
			-- elseif '-' == type then
			--   print('comment  ' .. name .. ' // ' .. attrs .. '$$')
			-- else
			--   print('o  ' .. #p .. ' // ' .. name .. ' // ' .. attrs .. '$$')
		end
	end)

	return {children=t, entities=entities, tentities=tentities}
end


function defaultEntityTable()
	return { quot='"', apos='\'', lt='<', gt='>', amp='&', tab='\t', nbsp=' ', }
end

function replaceEntities(s, entities)
	return s:gsub('&([^;]+);', entities)
end

function createEntityTable(docEntities, resultEntities)
	local entities = resultEntities or defaultEntityTable()
	for _,e in pairs(docEntities) do
		e.value = replaceEntities(e.value, entities)
		entities[e.name] = e.value
	end
	return entities
end

return getfenv()