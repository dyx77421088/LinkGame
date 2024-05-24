--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:处理时间
--     创建时间:2022/05/13 
--------------------------------------------------------------------------------
local TimeUtils = {}
function TimeUtils.GetDateTime(sec)
	if(sec) then
		return os.date("*t", sec)
	else
		return os.date("*t", os.time())
	end
end
-- 秒转时分秒
function TimeUtils.GetSecHMS(sec)
	local hour = math.modf(sec/60/60)
	local minus = math.fmod(math.modf(sec/60), 60)
	local second = math.fmod(math.modf(sec), 60)
	return {
		hour = hour,
		minus = minus,
		second = second,
	}
end

	-- 转123:00:01这样的时间格式/如果没有时分则去掉前面
	-- keep:是否保留前面部分
function TimeUtils.GetSecHMSString(sec)
	local tdata = TimeUtils.GetDateTime(sec)
	local hour = tdata.hour
	local minus = tdata.minus
	local second = tdata.second
	local content = tostring(second)
	if not keep then
		if hour > 0 then
			content = string.format("%d:%02d:%02d", hour, minus, second)
		elseif minus > 0 then
			content = string.format("%d:%02d", minus, second)
		else
			content = tostring(second)
		end
	elseif hour < 100 then
		content = string.format("0%d:%02d:%02d", hour, minus, second)
	else
		content = string.format("%d:%02d:%02d", hour, minus, second)
	end
	return content
end

function TimeUtils.GetTimeHMSString(time)
	local curDataTime = TimeUtils.GetDateTime(time)
    return string.format("%02d:%02d:%02d", curDataTime.hour, curDataTime.min, curDataTime.sec)	
end

function TimeUtils.GetTimeHMString(time)
	local curDataTime = TimeUtils.GetDateTime(time)
    return string.format("%02d:%02d", curDataTime.hour, curDataTime.min)	
end 

-- 获取一个时间字符串用于显示   —— 之后有可能改成 昨天、周几  之类的
function TimeUtils.GetTimeString(time)	
	local curDataTime = TimeUtils.GetDateTime(time)
    return string.format("%d/%d/%d   %02d:%02d:%02d", curDataTime.year, curDataTime.month, curDataTime.day, curDataTime.hour, curDataTime.min, curDataTime.sec)	
end

function TimeUtils.GetCNDateString(time)
	local curDataTime = TimeUtils.GetDateTime(time)
    return string.format("%d年%d月%d日", curDataTime.year, curDataTime.month, curDataTime.day)	
end

function TimeUtils.GetNormalDateString(time)
	local curDataTime = TimeUtils.GetDateTime(time)
    return string.format("%d/%d/%d", curDataTime.year, curDataTime.month, curDataTime.day)
end

return TimeUtils