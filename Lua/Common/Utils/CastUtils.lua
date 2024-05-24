
--[[
    拆分Uitls, 数据结构 转换 的函数都放在这里
    author:xym
    time:2021-02-04 15:44:23
]]
local Color = UnityEngine.Color
local CastUtils = {clsCache = {}}
function CastUtils.V3toV2(v3)
	return Vector2(v3.x, v3.y)
end

function CastUtils.V2toV3(v2)
	return Vector3(v2.x, v2.y, 0)
end

function CastUtils.SerialVec3(v3)
	return {x = v3.x, y = v3.y, z = v3.z}
end

function CastUtils.UnSerialVec3(t)
	return Vector3(t.x, t.y, t.z)
end

function CastUtils.Color2Str(color)
	return {r = color.r, g = color.g, b = color.b, a = color.a}
end

function CastUtils.Vector3toStr(vector)
	return {x = vector.x, y = vector.y, z = vector.z}
end

function CastUtils.Vector2toStr(vector)
	return {x = vector.x, y = vector.y}
end

function CastUtils.Rotation2Str(rotation)
	return {x = rotation.x, y = rotation.y, z = rotation.z, w = rotation.w}
end

function CastUtils.Str2Color(str)
	return Color(str.r, str.g, str.b, str.a)
end

function CastUtils.StrtoVector2(str)
	return Vector2(str.x, str.y)
end

function CastUtils.StrtoVector3(str)
	return Vector3(str.x, str.y, str.z)
end

function CastUtils.Array2Table(array)
	local t = {}
	if array then
		for i=0,array.Length-1 do
			table.insert(t, array[i])
		end
	end
	return t
end

function CastUtils.List2Table(list)
	if list ~= nil then
		local t = {}
		for i=0, list.Count-1 do
			table.insert(t, list[i])
		end
		return t
	end
end

function CastUtils.Hex2Color(num, gammaFix)
	local r = bit.rshift(bit.band(num, 0xff000000), 24)
	local g = bit.rshift(bit.band(num, 0x00ff0000), 16)
	local b = bit.rshift(bit.band(num, 0x0000ff00), 8)
	local a = bit.band(num, 0x000000ff)
	local color = CastUtils.Color255(r, g, b, a)
	
	if gammaFix then
		color.r = math.pow(color.r, 0.45)
		color.g = math.pow(color.g, 0.45)
		color.b = math.pow(color.b, 0.45)
	end
	return color
end

--16进制字符串转color，不建议频繁调用
function CastUtils.ColorHex(str, gammaFix)
	str = string.gsub(str,"#","")
	local r = string.hex2number(string.sub(str, 1, 2))
	local g = string.hex2number(string.sub(str, 3, 4))
	local b = string.hex2number(string.sub(str, 5, 6))
	local a = string.hex2number(string.sub(str, 7, 8))
	local color = CastUtils.Color255(r, g, b, a)
	if gammaFix then
		color.r = ComUtils.ChangeGammmaValue(color.r) 
		color.g = ComUtils.ChangeGammmaValue(color.g)
		color.b = ComUtils.ChangeGammmaValue(color.b)
	end
	return color
end

function CastUtils.Color255(r, g, b, a)
	a = a or 255
	return Color(r/255, g/255, b/255, a/255)
end

return CastUtils