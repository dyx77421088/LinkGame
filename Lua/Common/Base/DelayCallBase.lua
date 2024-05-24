--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:延迟回调，重复调用的话以最后一次调用为准
--     创建时间:2021/10/28 
--------------------------------------------------------------------------------
local DelayCallBase = BaseClass("DelayCallBase")

function DelayCallBase:__ctor()
	self.m_DelayCallTimerDict = nil
end

--延迟回调
--time 延迟时间
--funcname 函数名
--。。。 调用时的参数
function DelayCallBase:DelayCall(time, funcname, ...)
	if not self.m_DelayCallTimerDict then
		self.m_DelayCallTimerDict = {}
	end
	local timer = self.m_DelayCallTimerDict[funcname]
	if timer then
		Globals.timerMgr:DelTimer(timer)
	end
	self.m_DelayCallTimerDict[funcname] = Globals.timerMgr:AddTimer(callback(self, funcname, ...), time, time)
end


function DelayCallBase:PauseDelayCall(pasueFunc, time, funcname, ...)
	if not self.m_DelayCallTimerDict then
		self.m_DelayCallTimerDict = {}
	end
	local timer = self.m_DelayCallTimerDict[funcname]
	if timer then
		Globals.timerMgr:DelTimer(timer)
	end
	self.m_DelayCallTimerDict[funcname] = Globals.timerMgr:AddTimerCommon(callback(self, funcname, ...), time, time, false, pasueFunc)
end

--停止延迟回调
--funcname 函数名
function DelayCallBase:StopDelayCall(funcname)
	if not self.m_DelayCallTimerDict then
		return
	end
	local timer = self.m_DelayCallTimerDict[funcname]
	if timer then
		Globals.timerMgr:DelTimer(timer)
		self.m_DelayCallTimerDict[funcname] = nil
	end
end

--停止所有延迟回调
function DelayCallBase:StopAllDelayCall()
	if not self.m_DelayCallTimerDict then
		return
	end
	for funcName, _ in pairs(self.m_DelayCallTimerDict) do
		self:StopDelayCall(funcName)
	end
end

return DelayCallBase