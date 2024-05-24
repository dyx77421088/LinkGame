--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:彩金中奖滚分特效
--     创建时间:2023/11/20  
--------------------------------------------------------------------------------
local EffectItem = require "GameLogic.Module.Slot.Common.EffectItem"
local JackpotScrollNumEffect = BaseClass("JackpotScrollNumEffect", EffectItem)
local NumberItem = require "GameLogic.UI.Number.NumberItem"
local ButtonItem = require "GameLogic.Module.Slot.Common.ButtonItem"
local ConfigData = Globals.configMgr:GetConfig("SlotData")
local rankAnimation = ConfigData.caijin2
-- 这个是他们的状态
local rankAnimationState = {start = " Win", idle = " Idle", leave = " Leave"}


function JackpotScrollNumEffect:Initialize()
	local process = function(transform)
		return transform:GetComponent(ClassType.ParticleSystem)
	end
	self.fade = self:GetChild("mask", ClassType.Image)
	self.scrollGo = self:GetChild("spine").gameObject
	self.skeleton = self:GetChild("spine", ClassType.SkeletonGraphic)
	self.animation = self.skeleton.AnimationState
	self.jackpotNumPos = self:GetChild("jackpotNumPos")

	self.effects = TransformUtils.GetAllChilds(self:GetChild("effect"), process)

	self.button = ButtonItem.New(self:GetChild(""), self.mBaseView)
	self.button:AddOnClick(self.button, callback(self, "Stop"))
	self.gameObject:SetActive(false)
end

function JackpotScrollNumEffect:Play(odds, callBack, jackpotId)
	self.odds = odds -- 目标的分数
	self.callBack = callBack
	self.jackpotId = jackpotId -- 目标的jackpot （1， 2， 3...）
	self.currentJackpotId = 1 -- 当前的jackpotid
	self.isPlaying = true
	
	self.scrollGo:SetActive(false)
	self.gameObject:SetActive(true)

	self.fade:DOFade(0.5, 0.5):SetDelay(0.5):OnComplete(function()
		self.scrollGo:SetActive(true)
		self:StartScrollNum()
	end)
	LMessage:Dispatch(LuaEvent.Sound.Play, "bigwin", 1)

	--允许跳过滚分
	Globals.timerMgr:AddTimer(function()
		--绑定take按键事件
		LMessage:Dispatch(LuaEvent.SmallGame.KeyEvent, Const.KeyEvent.Bind, Const.KeyType.Take, callback(self, "Stop"))
		self.button:SetEnable(true)
	end, 0, 3)
end
local isChangeJackpot = ConfigData.isChangeJackpot -- 是否切换scene中的jackpot
local isMoveJackpot = ConfigData.isMoveJackpot -- 都别移动了！！
function JackpotScrollNumEffect:StartScrollNum()
	local odds = self.odds / self.jackpotId
	local jackpotId = self.currentJackpotId -- 当前使用的jackpotid
	-- 播放spine动画,第三个参数表示是否循环播放
	self.animation:SetAnimation(0, rankAnimation[jackpotId]..rankAnimationState.start, false)
	self.animation:AddAnimation(0, rankAnimation[jackpotId]..rankAnimationState.idle, true, 0)
	-- 播放金币特效
	self.effects[math.clamp(jackpotId, 1, #self.effects)]:Play()

	-- 呼叫scene中的jackpot进行数字滚动
	local arguments = {
		jackpotId = jackpotId, 
		startScore = (self.currentJackpotId - 1) * odds, endScore = self.currentJackpotId * odds,
		jackpotNumPos = self.jackpotNumPos.position,
		callBk = callback(self, "OnCompleteEvent")
	}
	local b = nil
	if jackpotId > 1 and not isChangeJackpot or not isMoveJackpot then -- 如果滚动的jackpoid>1 而且 不需要替换场景上的jackpot图标
		b = Const.SceneViewEMO.RevealScene.JackpotPlay -- 只需要改变number
	else
		b = Const.SceneViewEMO.RevealScene.JackpotShow -- 场景上的jackpot也移动过去
	end
	if not isChangeJackpot then arguments.jackpotId = self.jackpotId end -- 使用最终的jackpot

	G_printerror("看看数据是啥玩意", b, arguments.jackpotId)
	LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Scene, b, arguments)
	-- self:OnCompleteEvent()



	-- local endScore = math.floor(self.odds * Globals.gameModel.slot * Globals.gameModel.platformArg.multiplier)
	-- self.num:ScrollNum(0, endScore, 0, 4):OnComplete(callback(self, "OnCompleteEvent")):OnStart(function()
	-- 	self.skeleton.transform:DOScale(1, 0.1)
	-- 	-- 播放spine动画,第三个参数表示是否循环播放
	-- 	self.animation:SetAnimation(0, rankAnimation[self.jackpotId]..rankAnimationState.start, false)
	-- 	self.animation:AddAnimation(0, rankAnimation[self.jackpotId]..rankAnimationState.idle, true, 0)
	-- 	self.num.transform:DOScale(1, 0.5)
	-- 	self.effects[self.jackpotId]:Play()
	-- 	self.effect_border:Play() -- 框住num的框框
	-- 	LMessage:Dispatch(LuaEvent.Sound.Play, "bigwin", 2)
	-- end)
end

function JackpotScrollNumEffect:OnCompleteEvent()
	if self.currentJackpotId == self.jackpotId then
	
	else
		if isChangeJackpot then
			LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Scene, Const.SceneViewEMO.RevealScene.JackpotHide, self.currentJackpotId, function ()
			end)
		end
		self.currentJackpotId = self.currentJackpotId + 1
		self:StartScrollNum()
		
	end
	-- Globals.timerMgr:AddTimer(function()
	-- 	self:Stop()
	-- end, 0, 5)
end

function JackpotScrollNumEffect:Stop()
	if not self.isPlaying then
		return
	end
	
	self.isPlaying = false
	self.effects[math.clamp(self.jackpotId, 1, #self.effects)]:Stop(true, UnityEngine.ParticleSystemStopBehavior.StopEmittingAndClear)
	-- self.effect_border:Stop(true, UnityEngine.ParticleSystemStopBehavior.StopEmittingAndClear)
	-- self.num.transform:DOScale(0, 0.2)
	self.animation:SetAnimation(0, rankAnimation[self.jackpotId]..rankAnimationState.leave, false)
	self.fade:DOFade(0, 0.4):SetDelay(0.3):OnComplete(function()
		self.gameObject:SetActive(false)
		Globals.gameModel:AddWinScore(self.odds, true)
		if self.callBack then
			local callBack = self.callBack
			self.callBack = false
			callBack()
		end
		LMessage:Dispatch(LuaEvent.Sound.Play, "bigwin", 4)
	end)
	LMessage:Dispatch(LuaEvent.Sound.Play, "bigwin", 3)
end


return JackpotScrollNumEffect