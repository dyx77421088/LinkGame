local AlertCheckView = BaseClass("AlertCheckView", UIViewBase)

function AlertCheckView:__ctor()
    UIViewBase.__ctor()
    self.checkBox = false
    self.cancelBtn = false
    self.cancelTxt = false
    self.contentTxt = false
    self.OkBtn = false
    self.okFunc = false
    self.okFuncTxt = nil
    self.cancelFunc = nil
    self.type = ""
    self.isDefalut = true
    self.weight = Const.GUIWeight.Alert
end

function AlertCheckView:Initialize()
    self.contentTxt = self:GetChild("Bg/contentTxt","Text")
    self.checkBox = self:GetChild("Bg/Toggle","Toggle")
    self.cancelBtn = self:GetChild("Bg/cancelBtn")
    self.okBtn = self:GetChild("Bg/certainBtn")
    self.okBtnTxt = self:GetChild("Bg/certainBtn/Text","Text")
    self.cancelBtnTxt = self:GetChild("Bg/cancelBtn/Text","Text")
    self.checkBox.isOn = true
    local OkBtnHandler =  function ( ... )
        self:OkBtnHandler(...)
    end
    local CancelBtnHandler = function ( ... )
        self:CancelBtnHandler(...)
    end
    LuaUIEventListener.SetOnClick(self.okBtn, OkBtnHandler)
    LuaUIEventListener.SetOnClick(self.cancelBtn, CancelBtnHandler)
end

function AlertCheckView:Show(type, txt, okText, okFunc,cancelText,cancelFunc ,defaultValue)
    self.type = type
    self.contentTxt.text = ""
    self.contentTxt.text = txt
    self.contentTxt.gameObject:SetActive(true)

    okText = okText or "确定"
    cancelText = cancelText or "取消"
    defaultValue = defaultValue or false
    self.cancelBtnTxt.text = cancelText
    self.okBtnTxt.text = okText
    self.cancelFunc = cancelFunc
    self.okFunc = okFunc
    if (Alert.checkDic[type]~=nil) then 
        self.checkBox.isOn = Alert.checkDic[type]
    else
        self.checkBox.isOn = defaultValue
        Alert.checkDic[type] = defaultValue
    end
end

function AlertCheckView:HideSelf()
    self.contentTxt.text = ""
    self.contentTxt.gameObject:SetActive(false)
end

function AlertCheckView:OkBtnHandler(go)
    if (self.okFunc ~= nil) then 
        self.okFunc()                        
    end
    Alert.checkDic[self.type] = self.checkBox.isOn
    self:SetIsPop(false)
end

function AlertCheckView:CancelBtnHandler(go)
    if self.cancelFunc ~= nil then 
        self.cancelFunc()                        
    end
    Alert.checkDic[self.type] = self.checkBox.isOn
    self:SetIsPop(false)
end

function AlertCheckView:__delete()
    self.checkBox = false
    self.cancelBtn = false
    self.cancelBtnTxt = false
    self.contentTxt = false
    self.okBtn = false
    self.okBtnTxt = false
    self.okFunc = false
    self.cancelFunc = false
end

return AlertCheckView