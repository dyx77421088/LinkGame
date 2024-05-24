--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:场景视图逻辑
--     创建时间:2023/09/20  
--------------------------------------------------------------------------------
require "GameExtend.Module.Slot.View.SceneViewConst"
local SceneView = require "GameLogic.Module.Slot.View.SceneView"
SceneView = BaseClass("SceneViewEditor", SceneView)
local ButtonItem = require "GameLogic.Module.Slot.Common.ButtonItem"
local ConfigData = Globals.configMgr:GetConfig("SlotData")
local ClassData = Globals.configMgr:GetConfig("ClassData")
local SceneJackpotView = require(ClassData.SceneJackpotView)
local SceneNpcView = require(ClassData.SceneNpcView)

------------------------------------初始化相关的 start--------------------------------------------------------
function SceneView:__delete()
	-- LMessage:UnRegister(LuaEvent.Common.ApplicationUpdate, self.OnUpdate)
end
function SceneView:Initialize()
	self.fire_posy = 0 -- 火球的y轴动态变化
	self.dir = 1 -- 方向
	self.logo = self:GetChild("logo")
	self.jackpot = self:GetChild("jackpot")
	self.normal = self:GetChild("normal").gameObject
	self.free = self:GetChild("free").gameObject
	-- self.character = self:GetChild("character", ClassType.RawImage)
	-- self.clickBtn = ButtonItem.New(self:GetChild("character/click"), self.mBaseView)
	self.SceneJackpotView = SceneJackpotView.New(self:GetChild("jackpots"), self.mBaseView)
	
	self.throwTrans = self:GetChild("throw")
	
	-- 在npcview中管理火球
	self.SceneNpcView = SceneNpcView.New(self:GetChild(Const.SceneViewEMO.NameStr.Npc), self.mBaseView)
	-- self.clickBtn:AddOnClick(self.clickBtn, callback(self, "OnClickBtn"))
	self.isOpen = true
	self.isCharacterAnim = false
	
	self.normal:SetActive(true)
	self.free:SetActive(false)
	self:PopWithTags()
	Globals.processMgr:GetNoPostProcCanvas()
	LMessage:Dispatch(LuaEvent.Loading.AddLoaded, 1)
	-- self.OnUpdate = LMessage:Register(LuaEvent.Common.ApplicationUpdate, callback(self, "Update"))
	G_printerror("我加载完毕了")
end
-- 加载完成后的回调
function SceneView:OnLoadObject(arguments, object)
end

---------------------------------------初始化相关的 end---------------------------------------------

------------------------------------#regin 一些订阅的方法（在父类订阅了）start----------------------------------------


-- 根据表现类型进行revealType
function SceneView:RevealScene(...)
	local program = select(1, ...)
	if not program then return end
	--npc抛火球
	if program == Const.SceneViewEMO.RevealScene.FireBallStart then
		self.collects = select(2, ...)
		self.SceneNpcView.collects = self.collects
		G_printerror("Const.SceneViewEMO.RevealScene.FireBallStart进来了", table.serialize(self.collects))
		if Globals.gameModel.rule == Const.GameRule.Free then
			self.SceneNpcView:RevealSceneFreeFireBall()
		else
			if self.collects and #self.collects > 0 then
				self.SceneNpcView:RevealSceneNormalFireBall()
			else
				--npc抛火球结束
				LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Scene, Const.RollViewEMO.RevealScene.FireBallEnd)
			end
		end
	elseif program == Const.SceneViewEMO.RevealScene.PlayAnim then
		G_printerror("npc播放动画的了")
		local type = select(2, ...) -- 播放的动画的trigger
		self.SceneNpcView:SetNpcTrigger(type)
	elseif program == Const.SceneViewEMO.RevealScene.PlayBigAnim then
		local type, callbk = select(2, ...) -- 播放的动画的trigger和回调（或没有回调）
		self.SceneNpcView:SetBigNpcTrigger(type)
		-- self.bigNpcCallBack = callbk
		self.SceneNpcView:SetBigNpcCallBack(callbk)
	--BIG WIN流程
	elseif program == Const.SceneViewEMO.RevealScene.BigWin then
		local index = select(2, ...)
		local type = select(3, ...) -- 播放的动画的trigger
		G_printerror("index = ", index)
		--滚分
		if index == Const.SceneViewEMO.RevealScene.BigWinStart then
			self.bBigWin = true
			self.SceneNpcView:SetNpcTrigger(type)
		--滚分结束
		elseif index == Const.SceneViewEMO.RevealScene.BigWinRollStop then
			-- self.characterAnim:SetTrigger("show")
		--结束
		elseif index == Const.SceneViewEMO.RevealScene.BigWinStop then
			self.bBigWin = false
			self.SceneNpcView:SetNpcTrigger(Const.SceneViewEMO.NameStr.Animation.Win1)
			-- self.SceneNpcView.character.gameObject:SetActive(true) -- 不使用相机了
			-- self.SceneNpcView.character:DOFade(1, 0.2):SetDelay(0.5):OnComplete(function()
				self.isCharacterAnim = false
			-- end)
		end
	elseif program == Const.SceneViewEMO.RevealScene.JackpotShow then
		local arguments =  select(2, ...)
		G_printerror("滚动！！！！！！！！！！！！！")
		self.SceneJackpotView:Move(arguments.jackpotId, arguments.jackpotNumPos, function ()
			-- 滚动数字！！！！
			LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Scene, Const.SceneViewEMO.RevealScene.JackpotPlay, arguments)
		end)
	elseif program == Const.SceneViewEMO.RevealScene.JackpotPlay then
		local arguments =  select(2, ...)
		-- arguments内容有 = {jackpotId=1, startScore=1, endScore=2, callBk=functions}
		self.SceneJackpotView:Play(arguments)
	elseif program == Const.SceneViewEMO.RevealScene.JackpotHide then
		local index, callBk =  select(2, ...)
		self.SceneJackpotView:Hide(index, callBk)
		-- self.SceneJackpotView:Play(arguments.jackpotId, arguments.odds, arguments.callBk)
	end
end
-- 根据赢分的多少展示一些特效和动画
-- 第一个参数，特效类型
-- 第二个参数  倍率
function SceneView:RevealEffect(...)
	local effectType = select(1, ...)
	local odds = select(2, ...)
	--普通赢分
	if effectType == Const.EffectType.Normal then
		if odds > 0 then
			local oddsScale = odds / 100
			local effectId = 0
			for i = #ConfigData.winPoints, 1, -1 do
				if oddsScale >= ConfigData.winPoints[i] then
					effectId = i
					break
				end
			end
			if effectId == #ConfigData.winPoints then
				self.isCharacterAnim = true
				-- 场景中的character进行跳跃，并隐藏（bigwin中的角色显示出来）
				-- self.characterAnim:SetTrigger("jump")
				self.SceneNpcView.character:DOFade(0, 0.2):SetDelay(0.5):OnComplete(function()
					self.SceneNpcView.character.gameObject:SetActive(false)
				end)
			elseif effectId > 0 then
				self.isCharacterAnim = true
				local randNum = math.random(0, 1000)
				if Globals.gameModel.rule == Const.GameRule.Free then
					G_printerror("免费游戏的动作")
				else
					if randNum < 333 then
						self.SceneNpcView:SetNpcTrigger(Const.SceneViewEMO.NameStr.Animation.Fly)
					elseif randNum < 666 then
						self.SceneNpcView:SetNpcTrigger(Const.SceneViewEMO.NameStr.Animation.RotateOne)
					else
						self.SceneNpcView:SetNpcTrigger(Const.SceneViewEMO.NameStr.Animation.PaoZhuan)
					end
				end
			end
		end
	--BIG WIN
	elseif effectType == Const.EffectType.BigWin then
		G_printerror("进入bigwin了！！！！！！！！！！！！！！！！！")
		self.isCharacterAnim = true
		self.SceneNpcView:SetNpcTrigger(Const.SceneViewEMO.NameStr.Animation.Fly)
		self.sceneFireBallView:FireBallMove(Const.SceneViewEMO.FireBallType.Hide) -- 火球隐藏
		self.SceneNpcView.character:DOFade(0, 0.2):SetDelay(0.5):OnComplete(function()
			self.character.gameObject:SetActive(false)
		end)
	--彩金赢分
	elseif effectType == Const.EffectType.JackPot then
		self.isCharacterAnim = true
		self.SceneNpcView:SetNpcTrigger("jump")
	end
end

function SceneView:RevealSwitch(...)
	local oldRule = select(1, ...)
	local newRule = select(2, ...)
	local program = select(3, ...)
	--普通场景->免费场景
	if oldRule == Const.GameRule.Normal and newRule == Const.GameRule.Free and program == 2 then
		self.normal:SetActive(false)
		self.free:SetActive(true)
	--免费场景->普通场景
	elseif oldRule == Const.GameRule.Free and newRule == Const.GameRule.Normal and program == 1 then
		self.normal:SetActive(true)
		self.free:SetActive(false)
		
		self.SceneNpcView:FreeToNomarl()
	elseif oldRule == Const.GameRule.Normal and newRule == Const.GameRule.Link then
		self:SetIsPop(false)
	end
end
-- 一局开始的时候
function SceneView:OnOneRound()
	self.SceneJackpotView:Hide()
end
------------------------------------endregin----------------------------------------
return SceneView