-- time.lua
-- 时间相关接口, 用于替换Helpers中时间相关的处理, 时间相关的逻辑逐渐移动到此文件
-- 减少了临时内存分配, 减少os.date调用, 减少time.realtimeSinceStartup的调用
-- 同一天内的时间推进本地计算, 使用Time.unscaledDeltaTime进行推进
-- @author zhangliang
-- 2021.1.18
time = {}

local datetime = nil
local datetimeMT =
{
    __newindex = function()
        error("write to datetime table is not allowed")
    end,
}

local daystarttime_t = {}
local realtimeSinceStartupInFrame = nil
local lastRTSync = nil
local rtSyncInterval = 10
local clientStartTime = os.time()

local function update_datetime()
    local svrtime = time.servertime()
    if datetime then
        local dt = svrtime - datetime.last_svrtime
        datetime.last_svrtime = svrtime

        local fsec = datetime.fsec + dt
        datetime.fsec = fsec % 60
        local sec = math.floor(fsec)
        datetime.sec = sec % 60
        local min = datetime.min + math.floor(sec / 60)
        datetime.min = min % 60
        datetime.hour = datetime.hour + math.floor(min / 60)
    end

    if (not datetime) or datetime.hour >= 24 then
        local i, f = math.modf(svrtime)
        datetime = os.date("*t", i)
        datetime.fsec = datetime.sec + f
        datetime.last_svrtime = svrtime
        setmetatable(datetime, datetimeMT)
    end
end

local function update_realtimesincestartup(dt)
    if (not realtimeSinceStartupInFrame) or realtimeSinceStartupInFrame - lastRTSync > rtSyncInterval then
        realtimeSinceStartupInFrame = Time.realtimeSinceStartup
        lastRTSync = realtimeSinceStartupInFrame
    else
        realtimeSinceStartupInFrame = realtimeSinceStartupInFrame + dt
    end
end

local function sec_to_hms(timestamp)
	-- 秒转时分秒
	local hour = math.modf(timestamp / 60 / 60)
	local min = math.fmod(math.modf(timestamp / 60), 60)
	local sec = math.fmod(math.modf(timestamp), 60)
	return hour, min, sec
end

time.realtimeSinceStartupInFrame = function()
    return realtimeSinceStartupInFrame or Time.realtimeSinceStartup
end

time.servertime = function()
	if Globals.clientAvatar then
		return Globals.clientAvatar.ServerStamp + time.realtimeSinceStartupInFrame() - Globals.clientAvatar.ClientStamp
    else

        return clientStartTime + time.realtimeSinceStartupInFrame()
	end
end

time.serverdatetime = function(timestamp)
    if timestamp and timestamp ~= time.servertime() then
        return setmetatable(os.date("*t", math.floor(timestamp)), datetimeMT)
    else
        if (not datetime) then
            update_datetime()
        end
        return datetime
    end
end

time.daystarttime = function(t, hour, min, sec)
    t = t or time.serverdatetime()
    daystarttime_t.year  = t.year
    daystarttime_t.month = t.month
    daystarttime_t.day   = t.day
    daystarttime_t.hour  = hour or 0
    daystarttime_t.min   = min or 0
    daystarttime_t.sec   = sec or 0
	return os.time(daystarttime_t)
end

time.daystarttimeFromstr = function(str)
    daystarttime_t.year  = tonumber(string.sub(str, 1, 4))
    daystarttime_t.month = tonumber(string.sub(str, 5, 6))
    daystarttime_t.day   = tonumber(string.sub(str, 7, 8))
    daystarttime_t.hour  = 0
    daystarttime_t.min   = 0
    daystarttime_t.sec   = 0
	return os.time(daystarttime_t)
end

time.GetSecHMSString = function(timestamp, keep)
	-- 转123:00:01这样的时间格式/如果没有时分则去掉前面
    -- keep:是否保留前面部分
    local hour, min, sec = sec_to_hms(timestamp)
	local content
	if (not keep) then
		if hour > 0 then
			content = string.format("%d:%02d:%02d", hour, min, sec)
		elseif min > 0 then
			content = string.format("%d:%02d", min, sec)
		else
			content = tostring(sec)
		end
	elseif hour < 100 then
		content = string.format("0%d:%02d:%02d", hour, min, sec)
	else
		content = string.format("%d:%02d:%02d", hour, min, sec)
	end
	return content
end

time.GetTimeString = function(timestamp)
	-- 获取一个时间字符串用于显示   —— 之后有可能改成 昨天、周几  之类的
    local callDataTime = time.serverdatetime(timestamp)
    if math.abs(timestamp - time.servertime()) <= 86400 then
		return string.format("%02d:%02d", callDataTime.hour, callDataTime.min)
	else
		return string.format("%d/%d/%d   %02d:%02d", callDataTime.year, callDataTime.month, callDataTime.day, callDataTime.hour, callDataTime.min)
	end
end

time.GetYMDTimeString = function(timestamp)
    local callDataTime = time.serverdatetime(timestamp)
	return string.format("%d年%d月%d日", callDataTime.year, callDataTime.month, callDataTime.day)
end

time.update = function()
    local dt = Time.unscaledDeltaTime
    update_realtimesincestartup(dt)
    update_datetime()
    -- print(string.format("time.update, %04d:%02d:%02d %02d:%02d:%02d, realtime: %f,%f",
    --     datetime.year, datetime.month, datetime.day,
    --     datetime.hour, datetime.min, datetime.sec,
    --     realtimeSinceStartupInFrame,
    --     Time.realtimeSinceStartup))



end

time.now = function ()
    return CS.System.DateTime.Now:ToString("MM/dd HH:mm:ss.ffff  ")
end

time.TimeZone = function ()
    return os.time() - os.time(os.date("!*t"))
end

-- 格式化时间字符串，按照函数规定的格式格式化字符串
local _time_data = {  d = 0, h = 0, m = 0, s= 0  }
time.TimeFormatStr =
{
    HHMMSS = function ()
        return string.format("%02d:%02d:%02d", _time_data.h, _time_data.m, _time_data.s)
    end,
    --溢出的天数转换成小时
    OVER_HHMMSS = function()
        if _time_data.d ~= 0 then 
            _time_data.h = _time_data.h + _time_data.d * 24
        end
        return string.format("%02d:%02d:%02d", _time_data.h, _time_data.m, _time_data.s)
    end,
    HMMSS = function ()
        return string.format("%d:%02d:%02d", _time_data.h, _time_data.m, _time_data.s)
    end,
    HHMM = function ()
        return string.format("%02d:%02d", _time_data.h, _time_data.m)
    end,
    MMSS = function ()
        return string.format("%02d:%02d", _time_data.m, _time_data.s)
    end,
    HH = function ()
        return string.format("%02d", _time_data.h)
    end,
    MM = function ()
        return string.format("%02d", _time_data.m)
    end,
    SS = function ()
        return string.format("%02d", _time_data.s)
    end,
    CHS_DDHHMMSS = function ()
        return string.format(StrUtilText("%d天%02d时%02d分%02d秒"), _time_data.d, _time_data.h, _time_data.m, _time_data.s)
    end,
    CHS_DDHHMM = function ()
        return string.format("%d天%02d时%02d分", _time_data.d, _time_data.h, _time_data.m)
    end,
    CHS_DDHH = function ()
        if _time_data.d == 0 then 
            return string.format(StrUtilText("%02d时"), _time_data.h)
        else
            return string.format(StrUtilText("%d天%02d时"), _time_data.d, _time_data.h)
        end
    end,
    CHS_HHMMSS = function ()
        return string.format(StrUtilText("%02d时%02d分%02d秒"), _time_data.h, _time_data.m, _time_data.s)
    end,
    CHS_THHMMSS = function ()
        if _time_data.d > 0 or _time_data.h > 0 then
            return string.format("%d小时%d分钟", _time_data.d * 24 + _time_data.h, _time_data.m)
        else
            return string.format("%d分钟%d秒", _time_data.m, _time_data.s)
        end
    end,
    CHS_HHMM = function ()
        return string.format(StrUtilText("%02d时%02d分"), _time_data.h, _time_data.m)
    end,
    CHS_MMSS = function ()
        return string.format(StrUtilText("%02d分%02d秒"), _time_data.m, _time_data.s)
    end,
    CHS_HH = function ()
        return string.format(StrUtilText("%02d时"), _time_data.h)
    end,
    CHS_MM = function ()
        return string.format(StrUtilText("%02d分"), _time_data.m)
    end,
    CHS_SS = function ()
        return string.format(StrUtilText("%02d秒"), _time_data.s)
    end,
}
time.GetTimeStr = function (seconds, timeFormatFunc)
    _time_data.d, _time_data.h, _time_data.m, _time_data.s =
    math.floor(seconds / (3600 * 24)),
    math.floor((seconds / 3600) % 24),
    math.floor((seconds % 3600) / 60),
    math.floor(seconds % 60)
    return timeFormatFunc()
end

time.SecondsToClock = function (seconds, unitCount, isCh)
	local seconds = tonumber(seconds)
	if unitCount == nil then
		unitCount = 3
	else
		unitCount = math.clamp(unitCount, 1, 3)
	end
	local strList = {"00", "00", "00"}
	local chList = {"秒", "分", "时", "天"}
	if seconds > 0 then
		strList[3] = string.format("%02.f", math.floor(seconds/3600))
		strList[2] = string.format("%02.f", math.floor(seconds/60 - (strList[3]*60)))
		strList[1] = string.format("%02.f", math.floor(seconds - strList[3]*3600 - strList[2] *60))
	end
	local ret = strList[1]
	if isCh then
		ret = ret .. chList[1]
	end
	for i = 2, unitCount do
		if isCh then
			ret = strList[i]..chList[i]..ret
		else
			ret = strList[i]..":"..ret
		end
	end
	return ret
end

--时间字符串转换成时间戳 格式yyyy-mm-dd hh:mm:ss
time.DateStrToTimestamp = function(timeString)
    if type(timeString) ~= 'string' then error('string2time: timeString is not a string') return 0 end
    local fun = string.gmatch( timeString, "%d+")
    local y = fun() or 0
    if y == 0 then error('timeString is a invalid time string') return 0 end
    local m = fun() or 0
    if m == 0 then error('timeString is a invalid time string') return 0 end
    local d = fun() or 0
    if d == 0 then error('timeString is a invalid time string') return 0 end
    local H = fun() or 0
    if H == 0 then error('timeString is a invalid time string') return 0 end
    local M = fun() or 0
    if M == 0 then error('timeString is a invalid time string') return 0 end
    local S = fun() or 0
    if S == 0 then error('timeString is a invalid time string') return 0 end
    return os.time({year=y, month=m, day=d, hour=H,min=M,sec=S})
end
