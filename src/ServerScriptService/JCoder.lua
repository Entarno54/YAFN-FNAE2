--!strict
-- Basically it tries to compress a table into a string, just to save and/or optimize the settings data.
-- Please note that the binary will be met with rounding problems alongside with Lua's floating point numbers.
-- 
--v0.0.1
local JCoder = {}

function JCoder.ToNumber(...:string)
	local t:{any} = {...}
	for ind,val:string in next,t do
		if tonumber(val) == nil then error("One of the elements is invalid") end
		t[ind] = tonumber(val)
	end
	return unpack(t)
end

function JCoder.BitToBool(str:string):{boolean}
	local t:{boolean} = {}
	local count = 1
	for bit in string.gmatch(str,".") do
		if bit == "1" then
			t[count] = true
		elseif bit == "0" then
			t[count] = false
		end
		count += 1
	end
	return t
end

function JCoder.Root(exp:number,num:number):number
	return num^(1/exp)
end

JCoder.IEEE754_MAX_SAFE_VALUE = 9007199254740991
JCoder.MuteRoundingWarning = true

function JCoder.StringBinToNumber(strBin:string):number
	local counter = 0
	local output = 0
	for BinNum in (strBin):gmatch(".") do
		if BinNum == "1" then output += 2^(#strBin-counter-1) end
		counter += 1
	end
	if output > JCoder.IEEE754_MAX_SAFE_VALUE and not JCoder.MuteRoundingWarning then warn("Value is above the safe value, expect rounding issues!") end
	return output
end

function JCoder.SplitBinary(binString:string,useLittleEndian:boolean?,returnNumbers:boolean?):string|number
	local returnTable:{any} = {}
	local remainder = math.fmod(#binString,8)
	if remainder ~= 0 then for _=1,remainder do binString = binString.."0" end end
	if type(useLittleEndian) ~= "boolean" then useLittleEndian = false end
	for bytePos = 1,#binString/8 do
		local binPart:string = useLittleEndian and binString:sub(bytePos*-8,(bytePos-1)*-8-1) or binString:sub((bytePos-1)*8+1,bytePos*8)
		returnTable[#returnTable+1] = returnNumbers and JCoder.StringBinToNumber(binPart) or binPart 
	end
	
	return table.unpack(returnTable)
end
--if val > self.IEEE754_MAX_SAFE_VALUE and not self.MuteRoundingWarning then warn("Value is above the safe value, expect rounding issues!") end
function JCoder.NumberToStringBin(val:number,byteSize:number?,failsafeVal:any?):string
	val = math.floor(val)
	if val > JCoder.IEEE754_MAX_SAFE_VALUE and not JCoder.MuteRoundingWarning then warn("Value is above the safe value, expect rounding issues!") end
	local output = ""
	local smallestByte = byteSize or 1
	if type(failsafeVal) == "boolean" and not failsafeVal then
		while (2^(8*smallestByte)) <= val  do
			smallestByte += 1
		end
	else
		local failsafeCount = 0
		local failsafeVal:number = type(failsafeVal) ~= "number" and 512 or failsafeVal
		while (2^(8*smallestByte)) <= val and failsafeCount < failsafeVal do
			smallestByte += 1
			failsafeCount += 1
		end
		if failsafeCount >= failsafeVal then error("max loop counter reached") end 
	end
	for bitPos=1,8*smallestByte do
		output = tostring((math.floor(val*(2^-(bitPos-1)))%(2^bitPos))%2) .. output
		--print(math.floor(val*(2^-(bitPos-1))),(2^bitPos),math.floor(val*(2^-(bitPos-1)))%(2^bitPos)%2)
	end
	return output
end

-- CONSOLE: for bitPos=1,8 do print((bit32.rshift(127,bitPos-1)%bit32.lshift(1,bitPos))%2) end
function JCoder.EncodeNumber(value:number):string -- Returns a number Encoded into a string.
	local outputString:string = ""
	-- Using this might lose accuracy!	
	local valString = tostring(value):gsub("e[+,-].+","")
	local sign = math.sign(value)
	if sign == -1 then
		valString = valString:sub(2)
	end
	local exponent = tostring(value):match("e[+,-].+")
	local binaryData = ""
	local dotPosition = 0 -- show no period
	if valString:sub(0,2) == "0." then
		dotPosition = 15
		valString = valString:sub(3)
	else
		local pos = string.find(valString,"%.")
		if pos then
			dotPosition = pos -1
		else
			dotPosition = 0
		end 
		valString = valString:gsub("%.","")
	end
	--print(valString)
	local funnyNumber = valString:match("0.+0") -- those 000
	local flipped = false
	if funnyNumber then
		flipped = true
		valString:reverse()
	end
	local isStrange
	if valString == "-nan(ind)" then
		isStrange = false
	elseif valString == "inf" then
		isStrange = true
	end
	
	binaryData = (sign == 1 and "1" or "0") -- sign bit
		.. (exponent ~= nil and "1" or "0") -- exponent bit
		.. JCoder.NumberToStringBin(dotPosition):sub(5) -- period position
	--print(dotPosition,JCoder.NumberToStringBin(dotPosition):sub(5))
	if exponent then
		local expSign = exponent:sub(2,2) == "+"
		local expVal = tonumber(exponent:sub(3))
		binaryData = binaryData 
			.. (expSign and "1" or "0") -- exponent sign bit
			.. JCoder.NumberToStringBin(expVal):sub(-9) -- exponent value
	elseif isStrange == nil then
		binaryData = binaryData .. "0" -- strange bit (always false in this case)
			.. (flipped and "1" or "0") -- flip bit
	elseif type(isStrage) == "boolean" then
		binaryData = binaryData .. "1" -- strange bit (always true in this case)
			.. (isStrange and "0" or "1") -- value type bit (-nan(ind)/inf)
	end
	local binNum = JCoder.NumberToStringBin(tonumber(valString),6)
	--print(binNum,JCoder.StringBinToNumber(binNum))
	binaryData = binaryData .. binNum -- number 
	local textByteCodes = {JCoder.SplitBinary(binaryData,false,true)}
	for _,v:any in next,textByteCodes do
		outputString = outputString .. string.char(v)
	end
	return outputString
end

function JCoder.DecodeNumber(str:string):number
	local byteData:{number} = {string.byte(str,1,-1)}
	local binData:{string} = {}
	for Index,Byte in next,byteData do
		binData[Index] = JCoder.NumberToStringBin(Byte)
	end
	local rawBin = table.concat(binData,"")
	-- iterate thru the data
	local lowerByte = binData[1]
	
	local sign:any,expNot:boolean = unpack(JCoder.BitToBool(lowerByte))
	sign = sign and "" or "-"
	local dotPos = JCoder.StringBinToNumber(lowerByte:sub(3,-3))
	-- if expNot
		local expSign,expVal
	-- else
		local strange:boolean
		-- if strange
			local stnType:boolean
		-- else
			local reverse:boolean
	local num
	
	if expNot then
		expSign = JCoder.BitToBool(lowerByte:sub(7,7))[1]
		expVal = JCoder.StringBinToNumber(rawBin:sub(8,16))
	else
		strange = JCoder.BitToBool(lowerByte:sub(7,7))[1]
		if strange then
			stnType = JCoder.BitToBool(lowerByte:sub(8,8))[1]
		else
			reverse = JCoder.BitToBool(lowerByte:sub(8,8))[1]
		end
	end
	num = JCoder.StringBinToNumber(rawBin:sub(-48))
	local mummy = ""
	if strange then
		mummy = stnType and "-nan(ind)" or "inf"
	else
		if reverse then
			mummy = string.reverse(tostring(num))
			--print("reversed!")
		else
			mummy = tostring(num)
		end
		if dotPos < 15 and dotPos > 0 then
			local bottomNum,topNum = mummy:sub(1,dotPos),mummy:sub(dotPos+1)
			print(dotPos,bottomNum,topNum)
			mummy = bottomNum .. "." .. topNum
		else
			mummy = (dotPos == 0 and "0." or "") .. mummy
		end
		mummy = sign .. mummy 
	end
	if expNot then
		mummy = mummy 
			.. "e"
			.. (expSign and "+" or "-")
			.. tostring(expVal)
	end
	local number = tonumber(mummy)
	print(mummy,number)
	if number == nil then error("Invalid Number!") end
	return number
end

function JCoder.Encode(data:{any})
	
end

return JCoder
