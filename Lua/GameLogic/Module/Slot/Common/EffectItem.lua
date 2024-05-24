--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:特效基类
--     创建时间:2023/09/20  
--------------------------------------------------------------------------------
local UIShareInterface = require "BaseLogic.UI.UIShareInterface"
local EffectItem = BaseClass("EffectItem", UIShareInterface)

function EffectItem:__ctor(parent, baseView)
	if parent then
		self.uiPrefab = parent
		self:RecordGameObject()
	end
	self.mBaseView = baseView
	self.odds = 0
	self.isPlaying = false
	self.callBack = false
	self:Initialize()
end

function EffectItem:Initialize()
	
end

function EffectItem:Play(odds, callBack)
	self.odds = odds or 0
	self.callBack = callBack or false
	self.isPlaying = true
	Globals.gameModel:AddWinOdds(self.odds, self.odds > 0)
	Globals.timerMgr:AddTimer(function()
		self:Stop()
	end, 0, 0.3)
end

function EffectItem:Stop()
	if not self.isPlaying then
		return
	end
	
	self.isPlaying = false
	if self.callBack then
		local callBack = self.callBack
		self.callBack = false
		callBack()
	end
end

function EffectItem:IsPlaying()
	return self.isPlaying
end


return EffectItem