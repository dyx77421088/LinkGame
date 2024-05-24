--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:按赢分等级滚分特效
--     创建时间:2023/11/20  
--------------------------------------------------------------------------------
Const.RankScrollNumEffect = {
	Character = "character",
	Spine = "spine", -- bigwin的spine动画
	Effect = { -- 一些特效
		BigWinFire = "effect/mg_eff_BigWinfire",
		Coins = "effect/ng_eff_coins",
		CoinsLeve1 = "effect/ng_eff_coins_leve1",
		CoinsLeve2 = "effect/ng_eff_coins_leve2",
	}
}
local EffectItem = require "GameLogic.Module.Slot.Common.EffectItem"
local RankScrollNumEffect = BaseClass("RankScrollNumEffect", EffectItem)
local NumberItem = require "GameLogic.UI.Number.NumberItem"
local ButtonItem = require "GameLogic.Module.Slot.Common.ButtonItem"
local ConfigData = Globals.configMgr:GetConfig("SlotData")
local rankRange = {10, 20}
local rankAnimation = {"BIGWIN", "MEGAWIN", "SUPERWIN"}
local rankAnimationHz = {idle = " Idle", leave = " Leave", win = " Win"}

function RankScrollNumEffect:Initialize()
	local process = function(tran, i, list)
		return {transform = tran, gameObject = tran.gameObject, image = tran:GetComponent(ClassType.Image)}
	end
	self.effectCoins = {}
	self.fade = self:GetChild("", ClassType.Image)
	self.character = self:GetChild(Const.RankScrollNumEffect.Character, ClassType.RawImage)
	self.num = NumberItem.New(self:GetChild("num"), self:GetChild("num/0").gameObject, self.mBaseView)
	self.num:SetAtlasParam(ConfigData.atlasName, "bigwinnumber/")
	-- bigwin的时候的特效
	self.effectBigWinFire = self:GetChild(Const.RankScrollNumEffect.Effect.BigWinFire, ClassType.ParticleSystem)
	self.effectCoins[1] = self:GetChild(Const.RankScrollNumEffect.Effect.Coins, ClassType.ParticleSystem)
	self.effectCoins[2] = self:GetChild(Const.RankScrollNumEffect.Effect.CoinsLeve1, ClassType.ParticleSystem)
	self.effectCoins[3] = self:GetChild(Const.RankScrollNumEffect.Effect.CoinsLeve2, ClassType.ParticleSystem)
	-- spine动画
	self.spineGO = self:GetChild(Const.RankScrollNumEffect.Spine).gameObject
	self.spine = self:GetChild(Const.RankScrollNumEffect.Spine, ClassType.SkeletonGraphic)
	-- 这个的Prefab一开始要显示出来，不然获得的值就是空
	self.animation = self.spine.AnimationState

	self.button = ButtonItem.New(self:GetChild(""), self.mBaseView)
	self.button:AddOnClick(self.button, callback(self, "Stop"))
	self.gameObject:SetActive(false)
	
end

function RankScrollNumEffect:Play(odds, callBack, noAddScore)
	self.odds = odds
	self.callBack = callBack
	self.noAddScore = noAddScore or false
	self.isPlaying = true
	self.rankIndex = 0
	self.rankCount = 1
	self.startScore = 0
	self.endScore = 0
	local oddsScale = self.odds / 100
	for i = #rankRange, 1, -1 do
		if oddsScale > rankRange[i] then
			self.rankCount = i + 1
			break
		end
	end
	-- 设置bigwin中角色的显示
	local renderTexture = Globals.cameraMgr:GetRenderTexture()
	self.character.texture = renderTexture

	self.num.transform.localScale = Vector3.zero

	self.button:SetEnable(false)
	self.spineGO:SetActive(false)
	self.gameObject:SetActive(true)
	-- bigwin中的character显示出来
	self.character:DOFade(1, 0.2):SetDelay(0.8)
	self.fade:DOFade(0.7, 0.5):SetDelay(1):OnComplete(function() -- 背景变暗
		self.spineGO:SetActive(true)
		self.num.transform:DOScale(1.5, 0.5):OnComplete(function()
			self.num.transform:DOScale(1, 0.2)
		end)
		self:StartScrollNum()
	end)
	
	--允许跳过滚分
	Globals.timerMgr:AddTimer(function()
		--绑定take按键事件
		LMessage:Dispatch(LuaEvent.SmallGame.KeyEvent, Const.KeyEvent.Bind, Const.KeyType.Take, callback(self, "Stop"))
		self.button:SetEnable(true)
	end, 0, 3)
	
	LMessage:Dispatch(LuaEvent.Sound.Play, "bigwin", 1)
end

function RankScrollNumEffect:StartScrollNum()
	self.rankIndex = self.rankIndex + 1
	self.startScore = self.endScore
	if self.rankIndex == self.rankCount then
		self.endScore = math.reduce(Globals.gameModel.playBet * self.odds, 100)
	else
		self.endScore = Globals.gameModel.playBet * rankRange[self.rankIndex]
	end
	local showStart = math.floor(self.startScore * Globals.gameModel.slot * Globals.gameModel.platformArg.multiplier)
	local showEnd = math.floor(self.endScore * Globals.gameModel.slot * Globals.gameModel.platformArg.multiplier)
	self.num:ScrollNum(showStart, showEnd, 0, 3):OnStart(callback(self, "OnStartEvent")):OnComplete(callback(self, "OnCompleteEvent")):OnKill(callback(self, "OnKillEvent"))
end

local anim = {Const.SceneViewEMO.NameStr.Animation.Win1, Const.SceneViewEMO.NameStr.Animation.Win2, Const.SceneViewEMO.NameStr.Animation.Win3}
--滚分开始事件
function RankScrollNumEffect:OnStartEvent()
	self.animation:SetAnimation(0, rankAnimation[self.rankIndex]..rankAnimationHz.win, false)
	self.animation:AddAnimation(0, rankAnimation[self.rankIndex]..rankAnimationHz.idle, true, 0)

	--npc播放动画
	LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Scene, Const.SceneViewEMO.RevealScene.BigWin, Const.SceneViewEMO.RevealScene.BigWinStart, anim[self.rankIndex])
	-- self.effect_note:Play()
	-- self.effect_guitar:Play()
	-- self.effect_coin:Play()
	-- self.effect_light:Play()
	if self.rankIndex > 1 then self.effectCoins[self.rankIndex - 1]:Stop() end
	self.effectCoins[self.rankIndex]:Play()
	self.effectBigWinFire:Play()
	LMessage:Dispatch(LuaEvent.Sound.Play, "bigwin", 2)
end

--滚分完成事件
function RankScrollNumEffect:OnCompleteEvent()

	self.num.transform:DOScale(1.5, 0.2):SetEase(EaseType.OutQuad):OnComplete(function()
		self.num.transform:DOScale(1, 0.2):SetEase(EaseType.InQuad):OnComplete(function()
			if self.rankIndex == self.rankCount then
				self:EndScrollNum()
				LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Scene, Const.SceneViewEMO.RevealScene.BigWin, Const.SceneViewEMO.RevealScene.BigWinRollStop)
			else
				self:StartScrollNum()
			end
		end)
	end)
	LMessage:Dispatch(LuaEvent.Sound.Play, "bigwin", 3)
end

--滚分中断事件
function RankScrollNumEffect:OnKillEvent()
	self:EndScrollNum()
	self.num.transform:DOKill()
	self.endScore = math.reduce(Globals.gameModel.playBet * self.odds, 100)
	local showEnd = math.floor(self.endScore * Globals.gameModel.slot * Globals.gameModel.platformArg.multiplier)
	self.num:SetValue(showEnd)
	LMessage:Dispatch(LuaEvent.Sound.Play, "bigwin", 3)
end

--滚分终止
function RankScrollNumEffect:EndScrollNum()
	
	if not self.noAddScore then
		self.noAddScore = true
		Globals.gameModel:AddWinOdds(self.odds, true)
	end
	
	-- 免费游戏自动解绑（暂时不自动了！）
	-- if Globals.gameModel.rule == Const.GameRule.Free then
	-- 	-- self:UnButton()
	-- 	self:Stop()
	-- end
end
-- 解绑button，并执行callback
function RankScrollNumEffect:UnButton()
	--解绑take按键事件
	LMessage:Dispatch(LuaEvent.SmallGame.KeyEvent, Const.KeyEvent.UnBind, Const.KeyType.Take)
	self.button:SetEnable(false)
	if self.callBack then
		local callBack = self.callBack
		self.callBack = false
		callBack()
	end
end
function RankScrollNumEffect:Stop()
	if not self.isPlaying then
		return
	end
	self.isPlaying = false
	self.num:StopScroll()
	-- self.effect_note:Stop()
	-- self.effect_guitar:Stop()
	-- self.effect_coin:Stop()
	-- self.effect_light:Stop()
	
	self.effectCoins[self.rankIndex]:Stop()
	self.effectBigWinFire:Stop()
	self.animation:SetAnimation(0, rankAnimation[self.rankIndex]..rankAnimationHz.leave, false)
	self.num.transform:DOScale(0, 0.3):OnComplete(function()
		--恢复npc状态
		LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Scene, Const.SceneViewEMO.RevealScene.BigWin, Const.SceneViewEMO.RevealScene.BigWinStop)
		self.character:DOFade(0, 0.2):SetDelay(0.5)
		self.fade:DOFade(0, 0.5):OnComplete(function()
			self.gameObject:SetActive(false)

			-- 其他游戏手动解绑
			self:UnButton()

			-- if self.callBack then
			-- 	local callBack = self.callBack
			-- 	self.callBack = false
			-- 	callBack()
			-- end
		end)

		
	end)
	
	LMessage:Dispatch(LuaEvent.Sound.Play, "bigwin", 4)
end


return RankScrollNumEffect