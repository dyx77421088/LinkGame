--------------------------------------------------------------------------------
--     作者:lb
--     文件描述:优化
--------------------------------------------------------------------------------

local CustomButton = BaseClass(UIItem)

function CustomButton:__ctor(parent, baseView)
    self.contentTxt = false
    self.timer = false
    self.lastTime = false --剩余时间
    self.content = false  --按钮显示内容
    self.contentFormat = false --按钮倒计时显示内容
    self.callBack = false --倒计时结束回调函数
    self:InitItem(parent, nil, baseView)
end

function CustomButton:Initialize()
    self.contentTxt = self:GetChild("Text","Text")
end

function CustomButton:SetPos(x, y)
    self.transform.anchoredPostion = Vector2(x, y)
end

function CustomButton:SetText(value)
    if(value == nil) then        
        return
    else
        self.content = value              
        self.contentTxt.text = value         
    end
end

function CustomButton:SetActive(value)
    return self.UIprefab:SetActive(value)
end

--==============================--
--desc:设置点击事件
--time:2018-09-19 03:16:19
--@func:
--@args:
--@return 
--==============================-- 
function CustomButton:SetOnClick(func, args)
    local nativeFunc = false
    if args then
        nativeFunc = function(go, isAuto)
            self:StopAndClearTimer()
            func(args, isAuto)
        end
    else
        nativeFunc = function(go, isAuto)        
            self:StopAndClearTimer()
            func(isAuto)
        end
    end
    self.callBack = nativeFunc
    self:AddOnClick(self.parent, nativeFunc)
end

function CustomButton:SetEnableColor(value, includeClick)
    UIUtils.SetEnableColor(self.gameObject, value, includeClick)
end


-- /********************************倒计时按钮***************************************/
    -- /// <summary>
    -- /// 倒计时按钮
    -- /// </summary>
    -- /// <param name="seconds">延迟时间</param>
    -- /// <param name="labelFormat">label显示：StrUtilText("确定{0}")</param>
function CustomButton:StartTimerClick(seconds, labelFormat)
    self.lastTime = seconds
    self.contentFormat = labelFormat
    self:TimerFun()
    self.timerId = Globals.timerMgr:AddTimer(lamda(self.TimerFun, self), 1,seconds,true)
end

function CustomButton:TimerFun()
    if(self.lastTime == 0) then
        if self.callBack then
             self.callBack(nil, true) 
        end
        self:StopAndClearTimer(self.content)
        return
    end
    self.contentTxt.text = string.format(self.contentFormat, self.lastTime)
    self.lastTime = self.lastTime - 1
end

    -- /// <summary>
    -- /// 停止按钮延时
    -- /// </summary>
function CustomButton:StopAndClearTimer(label)
    if not self.contentTxt and label then
        self.contentTxt.text = label
    end
    self:RemoveTimer()
end

function CustomButton:ShowSelf()
end

function CustomButton:HideSelf()
end

function CustomButton:RemoveTimer()
    if not self.timerId then
        self.timerId = Globals.timerMgr:DelTimer(self.timerId)
    end
end

function CustomButton:__delete()
   self:RemoveTimer()
    self.contentTxt = false
    self.timer = false
end

return CustomButton