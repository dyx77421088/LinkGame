--------------------------------------------------------------------------------
--     作者:lb
--     文件描述:倒计时用
--------------------------------------------------------------------------------

local CustomCountdown = BaseClass(UIItem)

function CustomCountdown:__ctor(parent, viewbase)
    self.isRunning = false
    self.tickFuncall = false
    self.callback = false
    --结算时间戳
    self.endTime = false
    self.timerId = false
end

function CustomCountdown:Initialize()

end


--==============================--
--desc:
--time:2019-01-16 11:16:13
--@cd:
--@update:
--@complete:
--@duration:默认1s间隔
--@return 
--==============================--
function CustomCountdown:Start(cd, update, complete, duration)
    if self.isRunning then
        return
    end
    duration = duration or 1
    self.duration = duration
    self.tickFuncall = update
    self.callback = complete

    self.isRunning = true

    self.endTime = ServerTimeManager.Now() + cd
    self:TimerFun()
    self.timerId = TimerManager.Add(self.TimerFun, duration, -1, true, self)
end


--==============================--
--desc:是否强制回调完成
--time:2018-08-08 11:13:11
--@isCompeleteCall:
--@return 
--==============================--
function CustomCountdown:Stop(isCompeleteCall)
    self.isRunning = false
    if isCompeleteCall then
        if self.callback then
            self.callback()
        end  
    end
    if self.timerId then        
        self.timerId = TimerManager.Remove(self.timerId)
    end
end

function CustomCountdown:TimerFun()
    if ServerTimeManager.Now() > self.endTime then -- 结束
        self:Stop()
        if self.callback then
            self.callback()
        end
    else
        local cd = self.endTime - ServerTimeManager.Now()
        if self.tickFuncall then
            self.tickFuncall(cd)
        end
    end
end

function CustomCountdown:__delete()
    self:Stop()
    self.tickFuncall = false
    self.callback = false
    self.timerId = false
end

return CustomCountdown