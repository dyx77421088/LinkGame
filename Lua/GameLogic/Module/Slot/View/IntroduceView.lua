--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:Introduce视图主逻辑
--     创建时间:2023/09/20  
--------------------------------------------------------------------------------
local IntroduceTipItem = BaseClass("IntroduceTipItem", UIItem)
local ButtonItem = require "GameLogic.Module.Slot.Common.ButtonItem"
local ConfigData = Globals.configMgr:GetConfig("SlotData")


function IntroduceTipItem:__ctor(parent, baseView, id)
	self:InitItem(parent, nil, baseView)
	self.id = id
end

function IntroduceTipItem:Initialize()
	self.highlight = self:GetChild("on").gameObject
	self.clickBtn = ButtonItem.New(self:GetChild(""), self.mBaseView)
	if self.clickBtn then
		self.clickBtn:AddOnClick(self.clickBtn, callback(self, "OnClickBtn"), Const.SoundType.Button_SwitchPage)
	end
end

function IntroduceTipItem:OnClickBtn()
	self.mBaseView:OnSwitchPage(self.id)
end

function IntroduceTipItem:OnSwitch(active)
	self.highlight:SetActive(active)
end


local IntroduceView = BaseClass("IntroduceView", UIViewBase)

function IntroduceView:Initialize()
	self.page = self:GetChild("pages")
	self.tipPrefab = self:GetChild("tips/0")
	self.tipPrefab.gameObject:SetActive(false)
	self.backBtn = ButtonItem.New(self:GetChild("back"), self)
	self.backBtn:AddOnClick(self.backBtn, callback(self, "OnClickBackBtn"), Const.SoundType.Button_Back)
	self.lastBtn = ButtonItem.New(self:GetChild("last"), self)
	if self.lastBtn then
		self:AddOnClick(self.lastBtn, callback(self, "OnClickLastBtn"), Const.SoundType.Button_SwitchPage)
	end
	self.nextBtn = ButtonItem.New(self:GetChild("next"), self)
	if self.nextBtn then
		self:AddOnClick(self.nextBtn, callback(self, "OnClickNextBtn"), Const.SoundType.Button_SwitchPage)
	end
	self:AddUIEvent(self, callback(self, "OnUIEvent"))
	
	Globals.resMgr:LoadObject(ConfigData.prefabName, "introduce", callback(self, "OnLoadObject"))
end

function IntroduceView:OnLoadObject(object)
	local process = function(tran, i, list)
		return tran.gameObject
	end
	local page = GameObject.Instantiate(object, self.page)
	self.pages = TransformUtils.GetAllChilds(page, process)
	self.pageCnt = #self.pages
	
	local onInstantiate = function(index, go)
		return IntroduceTipItem.New(go, self, index)
	end
	local onSetData = function(index, item)
		item:OnSwitch(false)
	end
	self.tips = {}
	ComUtils.SimpleReuse(self.tips, self.tipPrefab, self.pageCnt, onInstantiate, onSetData)
	
	self:OnSwitchPage(1)
end

function IntroduceView:OnUIEvent(trigger, param)
	if param == "down" then
		local screenPoint = Globals.touchMgr:GetTouchPosition()
        local isIn, localPoint = false, Vector2.zero
        isIn, localPoint = TransformUtils.ScreenPointToLocalPointInRectangle(self.transform, screenPoint, Globals.cameraMgr:GetUICamera(), localPoint)
        if(not isIn) then
            return
        end
		self.startPoint = localPoint
	elseif param == "up" then
		local screenPoint = Globals.touchMgr:GetTouchPosition()
        local isIn, localPoint = false, Vector2.zero
        isIn, localPoint = TransformUtils.ScreenPointToLocalPointInRectangle(self.transform, screenPoint, Globals.cameraMgr:GetUICamera(), localPoint)
        if(not isIn) then
            return
        end
		if localPoint.x - self.startPoint.x > 100 then
			Globals.soundMgr:PlayEffect(Const.SoundType.Button_SwitchPage)
			self:OnClickLastBtn()
		elseif localPoint.x - self.startPoint.x < -100 then
			Globals.soundMgr:PlayEffect(Const.SoundType.Button_SwitchPage)
			self:OnClickNextBtn()
		end
	end
end

function IntroduceView:OnKeyEvent(...)
	local keyEvent = select(1, ...)
	if keyEvent == Const.KeyEvent.Click then
		local msg = select(2, ...)
		if msg and msg.id == "Introduce" then
			self:OnClickNextBtn()
		end
	end
end

function IntroduceView:OnSwitchPage(index)
	if self.pageIdx == index then
		return
	end
	if self.pageIdx then
		self.pages[self.pageIdx]:SetActive(false)
		self.tips[self.pageIdx]:OnSwitch(false)
	end
	self.pageIdx = index
	if self.pageIdx < 1 then
		self.pageIdx = self.pageCnt
	elseif self.pageIdx > self.pageCnt then
		self.pageIdx = 1
	end
	self.pages[self.pageIdx]:SetActive(true)
	self.tips[self.pageIdx]:OnSwitch(true)
end

function IntroduceView:OnClickBackBtn()
	Globals.uiMgr:HideView("IntroduceView")
end

function IntroduceView:OnClickNextBtn()
	if self.pageCnt < 2 then
		return
	end
	self:OnSwitchPage(self.pageIdx + 1)
end

function IntroduceView:OnClickLastBtn()
	if self.pageCnt < 2 then
		return
	end
	self:OnSwitchPage(self.pageIdx - 1)
end

function IntroduceView:ShowSelf()
	self:BindEvent(LuaEvent.SmallGame.KeyEvent, "OnKeyEvent")
	Globals.gameModel:AddLock()
	LMessage:Dispatch(LuaEvent.SmallGame.IncreaseCover, self.uiName)
	Globals.pipeMgr:Send(EEvent.PipeMsg.GameInfo, {state = true, introduce = true})
	ComUtils.SetTimeScale(0.5)
end

function IntroduceView:HideSelf()
	self:UnBindAllEvent()
	Globals.gameModel:RemoveLock()
	LMessage:Dispatch(LuaEvent.SmallGame.DecreaseCover, self.uiName)
	Globals.pipeMgr:Send(EEvent.PipeMsg.GameInfo, {state = true, introduce = false})
	ComUtils.SetTimeScale(1)
end

return IntroduceView