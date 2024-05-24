--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:游戏运行速度
--     创建时间:2024/05/13 
--------------------------------------------------------------------------------
local GMRunSpeedView = BaseClass("GMRunSpeedView", UIViewBase)
local ButtonItem = require "GameLogic.Module.Slot.Common.ButtonItem"


function GMRunSpeedView:__ctor(cb)
    self.weight = Const.GUIWeight.GM
	self.numerator = 1 --分子
	self.denominator = 1 --分母
	self.speed = 1 --速度
	self.pause = false
end

function GMRunSpeedView:Initialize()
    self.panel = self:GetChild("Panel")
    self:AddUIEvent(self.panel, callback(self, "OnDragPanel"))
    self.playBtn = ButtonItem.New(self:GetChild("Panel/Play"), self)
	self:AddOnClick(self.playBtn, callback(self, "OnClickBtn", "play"))
	self.pauseBtn = ButtonItem.New(self:GetChild("Panel/Pause"), self)
	self:AddOnClick(self.pauseBtn, callback(self, "OnClickBtn", "pause"))
	self.increaseBtn = ButtonItem.New(self:GetChild("Panel/Increase"), self)
	self:AddOnClick(self.increaseBtn, callback(self, "OnClickBtn", "inrease"))
	self.reduceBtn = ButtonItem.New(self:GetChild("Panel/Reduce"), self)
	self:AddOnClick(self.reduceBtn, callback(self, "OnClickBtn", "reduce"))
	self.closeBtn = ButtonItem.New(self:GetChild("Panel/Close"), self)
	self:AddOnClick(self.closeBtn, callback(self, "OnClickBtn", "close"))
	self.text = self:GetChild("Panel/Text", ClassType.Text)
end

function GMRunSpeedView:OnDragPanel(trigger, param)
    if(param == "Drag") then
        local screenPoint = Globals.touchMgr:GetTouchPosition()
        local isIn, localPoint = false, Vector2.zero
        isIn, localPoint = TransformUtils.ScreenPointToLocalPointInRectangle(self.transform, screenPoint, Globals.cameraMgr:GetUICamera(), localPoint)
        if(not isIn) then
            return
        end
        self.panel.anchoredPosition = localPoint
    end
end

function GMRunSpeedView:OnClickBtn(param)
	if param == "play" then
		self.speed = self.numerator / self.denominator
		self.pause = false
		self.playBtn:SetIsPop(false)
		self.pauseBtn:SetIsPop(true)
	elseif param == "pause" then
		self.pause = true
		self.playBtn:SetIsPop(true)
		self.pauseBtn:SetIsPop(false)
	elseif param == "inrease" then
		if self.denominator > 1 then
			self.denominator = self.denominator - 1
		else
			self.numerator = self.numerator + 1
		end
		self.speed = self.numerator / self.denominator
	elseif param == "reduce" then
		if self.numerator > 1 then
			self.numerator = self.numerator - 1
		else
			self.denominator = self.denominator + 1
		end
		self.speed = self.numerator / self.denominator
	elseif param == "close" then
		Globals.uiMgr:HideView("GMRunSpeedView")
	end
	
	if self.speed >= 1 then
		self.text.text = string.format("速度: %d", self.speed)
	else
		self.text.text = string.format("速度: %d / %d", self.numerator, self.denominator)
	end
	
	if self.pause then
		Time.timeScale = 0
		self.text.color = Color.red
	else
		Time.timeScale = self.speed
		self.text.color = Color.green
	end
end

function GMRunSpeedView:ShowSelf()
	self.speed = Time.timeScale
	if self.speed == 0 then
		self.pause = true
	elseif self.speed < 1 then
		self.numerator = 1
		self.denominator = math.floor(1 / self.speed)
		self.text.text = string.format("速度: %d / %d", self.numerator, self.denominator)
	else
		self.numerator = self.speed
		self.denominator = 1
		self.text.text = string.format("速度: %d", self.speed)
	end
	
	if self.pause then
		self.text.color = Color.red
		self.playBtn:SetIsPop(true)
		self.pauseBtn:SetIsPop(false)
	else
		self.text.color = Color.green
		self.playBtn:SetIsPop(false)
		self.pauseBtn:SetIsPop(true)
	end
end


return GMRunSpeedView