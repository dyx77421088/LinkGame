local seed = nil
local oldFunc = math.randomseed
function math.randomseed(v, ...)
	print("设置随机数种子:", seed)
	seed = v
	return oldFunc(v, ...)
end

function math.getseed()
	return seed
end
--[[--

根据系统时间初始化随机数种子，让后续的 math.random() 返回更随机的值

]]
function math.newrandomseed()
	local ok, socket = pcall(function()
		return require("socket")
	end)

	if ok then
		-- 如果集成了 socket 模块，则使用 socket.gettime() 获取随机数种子
		math.randomseed(socket.gettime() * 1000)
	else
		math.randomseed(os.time())
	end
	math.random()
	math.random()
	math.random()
	math.random()
end

function math.randomFloat(lower, greater)
	return lower + math.random() * (greater - lower)
end


--[[--

对数值进行四舍五入，如果不是数值则返回 0

@param number value 输入值

@return number

]]
function math.round(value)
	return math.floor(value + 0.5)
end

--[[--

正数:向上取整
负数:向下取证

@param number value 输入值

@return number

]]
function math.roundUp( value )
	if (value <= 0) then 
		return math.floor(value)
	end

	local v = math.round(value)
	if value > v then 
		return v + 1
	end
	return v
end

--[[--

角度转弧度

]]
function math.angle2radian(angle)
	return angle*math.pi/180
end

--[[--

弧度转角度

]]
function math.radian2angle(radian)
	return radian/math.pi*180
end

function math.clamp(v, a, b)
    a = a or 0
    b = b or 1
    return math.min(math.max(v, a), b)
end

function math.lerp(a, b, t)
    return a * (1 - t) + b * t
end

function math.move(a, b, c)
	if(a > b) then
		return math.max(a - c, b)
	else
		return math.min(a + c, b)
	end
end

function math.sign(v)
    return v ~= 0 and (v / math.abs(v)) or 1
end

function math.CeilVec(f, precision)
	return math.ceil(f*precision)/precision
end

--向下取精度
function math.floorVec(f, precision)
	return math.floor(f*precision)/precision
end

function math.toboolean(v)
    return not not v
end

function math.reduce(v, precision)
	return math.floor(v / precision)
end

function math.expand(v, precision)
	return math.floor(v * precision)
end