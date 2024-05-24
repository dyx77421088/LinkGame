local AlertView = BaseClass("AlertView", UIViewBase)
local CustomButton = require "Base.UI.Custom.CustomButton"
function AlertView:__ctor()
    self.view = false
    self.contentTxt = false
    self.okBtn = false
    self.cancelBtn = false
    -- self.modalUI  = false,
    self.m_okCallback = false
    self.m_cancelCallback = false
    self.prefs = false
    self.cbx = false
    self.tips = false
    self.weigth = GE.GUIWeight.Alert
end

function AlertView:Initialize()
    self.view = self.UIprefab
    -- self.modalUI = self:GetChild("modal", "UISprite")
    self.titleText = self:GetChild("Bg/titleTxt", "Text")
    self.contentTxt = self:GetChild("Bg/contentTxt", "Text")
    self.tips = self:GetChild("Bg/Toggle/Label", "Text")
    self.tips.text = "今日之内不再提示"

    self.okBtn = CustomButton.New(self:GetChild("Bg/certainBtn"),self)
    self.cancelBtn = CustomButton.New(self:GetChild("Bg/cancelBtn"),self)
    local function OnOkHandler(isAuto)
        self:OkHandler(isAuto)
    end
    local function OnCancelHandler(...)
        self:CancelHandler(...)
    end
    self.okBtn:SetOnClick(OnOkHandler)
    self.cancelBtn:SetOnClick(OnCancelHandler)

    self.cbx = self:GetChild("Bg/Toggle","Toggle")
    local function OnCbxChange(...)
        self:OnCbxChange(...)
    end
    self:AddCloseBtn("Bg/closeBtn")
    LuaUIEventListener.SetToggleOnValueChanged(self.cbx.gameObject, OnCbxChange)
end
--[[

]]
--==============================--
--addby:yjp
--desc:显示提示
--@content: 图文混排content格式：<size=35><sprite=%d></size> name,exType
--[[@config:{
    certainText = "确定", --确定按钮的文字
    cancelText = "取消", --取消按钮的文字
    onCertain = nil, --确定回调
    onCancel = nil, --取消回调
    delayTime = nil,--+值表示在按钮1倒计时， -值表示在按钮2倒计时
    prefs = nil,--传入prefs会提示今日不再提示
    title = nil,
}]]
--@return:
--time:2021-11-02 11:25:52
--==============================--
function AlertView:Show(content, config)
    local certainText = config.certainText or "确定"
    local cancelText = config.cancelText or ""

    self.m_okCallback = config.onCertain
    self.m_cancelCallback = config.onCancel

    local delayTime = config.delayTime or 0

    if config.prefs ~= nil then
        self.prefs = config.prefs
        self.cbx.gameObject:SetActive(true)
        if (Globals.ioMgr:GetRoleData(self.prefs) == os.date("%x", os.time)) then
            self:SetIsPop(false)
            if (self.m_okCallback ~= nil) then
                self.m_okCallback()
            end
            return
        end
        self.cbx.isOn = false
    else
        self.cbx.gameObject:SetActive(false)
    end

    self:ShowContent(content)
    self.okBtn:SetText(certainText)
    self.cancelBtn:SetText(cancelText)
    --MyLog(7,"self.cancelBtn:SetText(cancelText)")
    if cancelText == "" then
        self.okBtn:SetPos(0, -128)
        --MyLog(7,"okBtnPos",self.okBtn.transform.localPosition.y)
        self.cancelBtn:SetActive(false)
    else
        self.okBtn:SetPos(139.5, -128)
        self.cancelBtn:SetActive(true)
    end
    --MyLog(7,"self:SetIsPop(true)")
    --self:SetBgSize()
    self:SetIsPop(true)
    if (delayTime > 0) then
        self.okBtn:StartTimerClick(delayTime, certainText .. "(%s)")
    elseif (delayTime < 0) then
        self.cancelBtn:StartTimerClick(-1 * delayTime, cancelText .. "(%s)")
    end
    -- self.modalUI.gameObject:SetActive(modal)
    self.titleText.text = config.title or "提示"
end

function AlertView:ShowContent(content)
    self.contentTxt.text = ""
    self.contentTxt.text = content
    self.contentTxt.gameObject:SetActive(true)
    self.tips.gameObject:SetActive(false)
end

function AlertView:ShowTips(content)
    self.tips.gameObject:SetActive(true)
    self.tips.text = content
end

-- isAuto ： 是否倒计时结束自动调用 true ：倒计时自动调用的， false：主动点击调用
function AlertView:OkHandler(isAuto)
    self.okBtn:StopAndClearTimer()
    self.cancelBtn:StopAndClearTimer()
    local okCb = self.m_okCallback
    self:SetIsPop(false)
    if (okCb ~= nil) then
        okCb(isAuto)
    end
end

function AlertView:CancelHandler(go)
    self.okBtn:StopAndClearTimer()
    self.cancelBtn:StopAndClearTimer()
    local cancelCb = self.m_cancelCallback
    self:SetIsPop(false)
    if (cancelCb ~= nil) then
        cancelCb()
    end
end

function AlertView:HideSelf()
    self.okBtn:StopAndClearTimer()
    self.cancelBtn:StopAndClearTimer()
    self.contentTxt.text = ""
    self.contentTxt.gameObject:SetActive(false)
    self.m_okCallback = false
    self.m_cancelCallback = false
    if (self.cbx.gameObject.activeSelf) then
        self.cbx.gameObject:SetActive(false)
    end
end

function AlertView:OnCbxChange(value)
    if (self.prefs ~= nil and self.prefs ~= false) then
        if (value == true) then
            Globals.ioMgr:SetRoleData(self.prefs, os.date("%x", os.time()))
            --PlayerPrefs.SetString(self.prefs, tostring(Utility.Date(os.time())))
        else
            Globals.ioMgr:SetRoleData(self.prefs, 0)
        end
    end
end

function AlertView:__delete()
    self.view = false
    self.contentTxt = false
    self.okBtn = false
    self.cancelBtn = false
    self.m_okCallback = false
    self.m_cancelCallback = false
    self.prefs = false
    self.cbx = false
    self.tips = false
end

return AlertView