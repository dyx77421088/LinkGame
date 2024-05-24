--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:GM界面
--     创建时间:2022/05/06 
--------------------------------------------------------------------------------
local GMView = BaseClass("GMView", UIViewBase)
local ClassData = Globals.configMgr:GetConfig("ClassData")
local GMPanel = require (ClassData.GMPanel)
local GMShortcutPanel = require (ClassData.GMShortcutPanel)
function GMView:__ctor(cb)
    self.weight = Const.GUIWeight.GM
end

function GMView:__delete()

end

function GMView:Initialize()
    self.gmBtn = self:GetChild("GMBtn")
    self:AddUIEvent(self.gmBtn, callback(self, "OnDragGmBtn"))
    self.gmPanel = GMPanel.New(self:GetChild("GMPanel"), nil, self)
	self.gmShortcutPanel = GMShortcutPanel.New(self:GetChild("GMShortcutPanel"), nil, self)
    self.gmPanel:SetIsPop(false)
	self.gmShortcutPanel:SetIsPop(false)
end

function GMView:OnDragGmBtn(luaTrigger, param)
    if(param == "Drag") then
        local screenPoint = Globals.touchMgr:GetTouchPosition()
        local isIn, localPoint = false, Vector2.zero
        isIn, localPoint = TransformUtils.ScreenPointToLocalPointInRectangle(self.transform, screenPoint, Globals.cameraMgr:GetUICamera(), localPoint)
        if(not isIn) then
            return
        end
        self.gmBtn.anchoredPosition = localPoint
		if _ShortcutGM then
			self.gmShortcutPanel.transform.anchoredPosition = localPoint
		end
        self.gmBtnDrag = true
    elseif(param == "EndDrag") then
        self.gmBtnDrag = false
    elseif(param == "PointerClick" and not self.gmBtnDrag) then
		if _ShortcutGM then
			if self.gmShortcutPanel:GetIsPop() then
				self.gmShortcutPanel:SetIsPop(false)
			else
				self.gmShortcutPanel:SetIsPop(true)
			end
		else
			self.gmPanel:SetIsPop(true)
		end
    end
end

function GMView:ShowSelf()
    self:BindEvent(LuaEvent.GM.HideGMPanel, "OnHideGMPanel")
end

function GMView:HideSelf()
    self:UnBindAllEvent()
end

function GMView:OnHideGMPanel()
	self.gmPanel:SetIsPop(false)
	Globals.timerMgr:AddTimer(function()
		self.gmShortcutPanel:SetIsPop(false)
	end, 0, 0.5)
end

return GMView