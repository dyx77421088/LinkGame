--作者:yjp
--文件描述:计时器 常用方法 AddTimer DelTimer,调用了AddTimer之后，一定要记得调用DelTimer，否则切场景这些逻辑很可能引起报错
--创建时间:2020.10.9
local TimerMgr = Singleton("TimerMgr")
local Time = UnityEngine.Time

function TimerMgr.__ctor(self)
	self:Reset()
end

local _scene_remove_dic = {}
--计时器数据重置
function TimerMgr.Reset(self)
	self.isPause = false
	self.timerDict = {}
	self.timerIDList = {}
    self.lateTimerIDList = {}
	self.lDel = {}
end

--延迟执行函数
--cb 回调函数
--delayTime 延迟时间
function TimerMgr.DelayCall(self, cb, delayTime, removeChangeScene) 
	if delayTime == nil then
		delayTime = 0
	end
	return self:AddTimer(cb, 0, delayTime, removeChangeScene)
end

--不满足某个条件则报错
--sType 错误类型，如果报错会打印出来
function TimerMgr.TimerAssert(self, sType, cbfunc, delta, delay)
	assert(cbfunc and delta and delay, sType.." args error!!!")
	assert(delta >= 0, sType.." delta must >= 0")
	assert(delay >= 0, sType.." delay must >= 0")
end

--在Update中执行  时间单位 s
--cbfunc 回调函数
--delta 调用间隔时间，0的话是每帧调用
--delay 延迟时间，0的话是下一帧调用
function TimerMgr.AddTimer(self, cbfunc, delta, delay, removeChangeScene)
	delta = delta or 0
	delay = delay or 0
	self:TimerAssert("AddTimer", cbfunc, delta, delay)
	return self:AddTimerCommon(cbfunc, delta, delay, false, nil, removeChangeScene)
end

-- 在lateUpdate中执行 时间单位 s
--cbfunc 回调函数
--delta 调用间隔时间，0的话是每帧调用
--delay 延迟时间，0的话是下一帧调用
function TimerMgr.AddLateTimer(self, cbfunc, delta, delay, removeChangeScene)
	delta = delta or 0
	delay = delay or 0
	self:TimerAssert("AddLateTimer", cbfunc, delta, delay)
	return self:AddTimerCommon(cbfunc, delta, delay, true, nil, removeChangeScene)
end

--计时器
--cbfunc 回调函数，返回true计时器才会重复执行，否则执行一次
--delta 间隔时间,若时间为0则每帧帧调用
--delay 延迟几秒第一次调用, 若时间为0则在下一帧调用
--lateupdate 是否在lateUpdate里调用，如果要控制相机的操作可以用这个
--pauseCond 暂停判断函数
function TimerMgr.AddTimerCommon(self, cbfunc, delta, delay, lateupdate, pauseCond, removeChangeScene)
	local iTimerID = ComUtils.GetUniqueID()
	local iElapsed = self:GetTime()
	self.timerDict[iTimerID] = {
		cbfunc = cbfunc,
		delta = delta,
		delay = delay,
		next_call_time = iElapsed + delay,
		last_call_time = iElapsed,
		add_frame = Time.frameCount,
		pauseCond = pauseCond,
	}
    if removeChangeScene then
        _scene_remove_dic[iTimerID] = true
    end
	if lateupdate then
		table.insert(self.lateTimerIDList, iTimerID)
	else
		table.insert(self.timerIDList, iTimerID)
	end
	return iTimerID
end

--删除计时器
--iTimerID addTimer会返回的id
function TimerMgr.DelTimer(self, iTimerID)
	if iTimerID ~= nil then
		self.timerDict[iTimerID] = nil
		_scene_remove_dic[iTimerID] = nil
	end
	return false
end

function TimerMgr.CallAndDelTimer(self, iTimerID)
    local iTime = self:GetTime()
    local iElapsed = iTime
    local callDelta = iElapsed - self.timerDict[iTimerID].last_call_time
    xpcallex(self.timerDict[iTimerID].cbfunc, callDelta)
    if iTimerID ~= nil then
        self.timerDict[iTimerID] = nil
    end
end

--使用自定义计时器
--timeGetter 获取时间的函数
function TimerMgr.SetCustomTime(self, timeGetter)
	self.timeGetter = timeGetter
end

--如果使用自定义计时器，获取这个计时器的当前时间
function TimerMgr.GetTime(self)
	if self.timeGetter then
		return self.timeGetter()
	end
	return Time.time
end

function TimerMgr.UpdateList(self, list)
	if not next(list) then
		return
	end
    local delLen = 0
	local iFrameCount = Time.frameCount
	local iTime = self:GetTime()
	for i, id in ipairs(list) do
		local v = self.timerDict[id]
		if v then 
			local iElapsed = iTime
			local callDelta = iElapsed - v.last_call_time
			if v.pauseCond then
				if v.pauseCond() == true then
					--fdd 修复定时器暂停计时错误
					if not v.firstPose then
						v.firstPose = callDelta
					end
					v.next_call_time = v.last_call_time + v.delay + callDelta - v.firstPose
				elseif v.firstPose then
					v.last_call_time = v.last_call_time + callDelta - v.firstPose
					v.firstPose = nil
				end
			end
			if v.add_frame ~= iFrameCount and (iElapsed - v.next_call_time) >= -0.005 then
				local success, ret = xpcallex(v.cbfunc, callDelta)
				if success and ret == true then
					v.last_call_time = iElapsed
					v.next_call_time = iElapsed + v.delta
                else
                    delLen = delLen + 1
                    self.lDel[delLen] = i
					self.timerDict[id] = nil
				end
			end

		else
            delLen = delLen + 1
            self.lDel[delLen] = i
		end
	end
	for j = delLen, 1, -1 do
        table.remove(list, self.lDel[j])
        self.lDel[j] = nil
	end
end

function TimerMgr.Update(self)
	if self.isPause then
		return
	end
	self:UpdateList(self.timerIDList)
end

function TimerMgr.LateUpdate(self)
	if self.isPause then
		return
	end
	self:UpdateList(self.lateTimerIDList)
end

--暂停计时器
function TimerMgr.SetPause(self, isPause)
	self.isPause = isPause
end

function TimerMgr.RemoveSceneTimer(self)
    local temp_scene = _scene_remove_dic
    _scene_remove_dic = {}
    for id, _ in pairs(_scene_remove_dic) do
        self:DelTimer(id)
    end
end

return TimerMgr