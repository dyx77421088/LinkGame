--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:抛洒金币特效
--     创建时间:2023/09/20  
--------------------------------------------------------------------------------
local EffectItem = require "GameLogic.Module.Slot.Common.EffectItem"
local JackPotCoinEffect = BaseClass("JackPotCoinEffect", EffectItem)


function JackPotCoinEffect:Initialize()
	self.particle = self:GetChild("", ClassType.ParticleSystem)
end

function JackPotCoinEffect:Play(odds, callBack)
	self.odds = odds or 0
	self.callBack = callBack or false
	self.isPlaying = true
	self.particle:Play()
	Globals.gameModel:AddWinScore(self.odds, true)
	Globals.timerMgr:AddTimer(function()
		self:Stop()
	end, 0, 1.2)
	LMessage:Dispatch(LuaEvent.Sound.Play, "jackpot")
end


return JackPotCoinEffect