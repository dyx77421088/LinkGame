--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:场景过渡逻辑
--     创建时间:2023/12/10  
--------------------------------------------------------------------------------
local TransitionView = BaseClass("TransitionView", UIViewBase)
local NumberItem = require "GameLogic.UI.Number.NumberItem"
local ButtonItem = require "GameLogic.Module.Slot.Common.ButtonItem"
local ConfigData = Globals.configMgr:GetConfig("SlotData")


function TransitionView:__ctor()
	self.weight = Const.GUIWeight.Main
end

function TransitionView:Initialize()
	self.free = self:GetChild("free").gameObject
	self.freeAnim = self:GetChild("free/spine", ClassType.SkeletonGraphic).AnimationState
	self.freeAnim.Complete = self.freeAnim.Complete + callback(self, "OnAnimEvent")
	self.fade = self:GetChild("free/click", ClassType.Image)
	self.clickBtn = ButtonItem.New(self:GetChild("free/click"), self)
	self.clickBtn:AddOnClick(self.clickBtn, callback(self, "OnClickBtn"))
	self.tipnum = NumberItem.New(self:GetChild("free/bone/num"), self:GetChild("free/bone/num/0").gameObject, self)
	self.tipnum:SetAtlasParam(ConfigData.atlasName, "tipnumber/")

	-- 免费游戏完成之后获得的金币数
	self.freeOutWinNum = NumberItem.New(self:GetChild("free/bone/freeOut/winNum"), self:GetChild("free/bone/freeOut/winNum/0").gameObject, self)
	self.freeOutWinNum:SetAtlasParam(ConfigData.atlasName, "bigwinnumber/")
	self.freeOutFreeNum = NumberItem.New(self:GetChild("free/bone/freeOut/freeNum"), self:GetChild("free/bone/freeOut/freeNum/0").gameObject, self)
	self.freeOutFreeNum:SetAtlasParam(ConfigData.atlasName, "tipnumber/")

	self.freeOutWinNum.gameObject:SetActive(false)
	self.freeOutFreeNum.gameObject:SetActive(false)
	self.free:SetActive(false)
end

-- 加载变身的特效
function TransitionView:OnLoadObject(object)
	self.transition = object
	if ObjectUtils.IsGameObject(object) then
		-- self.transition = {gameObject = object, transform = object.transform, particle = object:GetComponent(ClassType.ParticleSystem)}
		-- local normal = object:GetChild("normalToFree")
		-- local free = object:GetChild("freeToNormal")
		G_printerror(type(object))
		local normal = object.transform:GetChild(0)
		local free = object.transform:GetChild(1)
		self.normalToFree = {gameObject = normal.gameObject, transform = normal.transform, particle = normal:GetComponent(ClassType.ParticleSystem)}
		self.freeToNormal = {gameObject = free.gameObject, transform = free.transform, particle = free:GetComponent(ClassType.ParticleSystem)}
	end
	local transform = self.transition.transform
	local canvas = Globals.uiMgr:Get_EffectContainer()
	transform:SetParent(canvas.transform)
	transform.localScale = Vector3(1, 1, 1)
	transform.localPosition = Vector3.zero

	transform = self.normalToFree.transform
	transform.localPosition = Vector3(-61, 564, 0)
	transform.localScale = Vector3(1, 1, 1)
	self.normalToFree.gameObject:SetActive(false)

	transform = self.freeToNormal.transform
	transform.localPosition = Vector3(10, 120, -200)
	transform.localScale = Vector3(1, 1, 1)
	self.freeToNormal.gameObject:SetActive(false)
end

-- 点击按钮的操作也是一样的
function TransitionView:OnClickBtn()
	-- 菜单栏的这个按键解绑
	LMessage:Dispatch(LuaEvent.SmallGame.KeyEvent, Const.KeyEvent.UnBind, Const.KeyType.Start)
	self.clickBtn:SetEnable(false)
	self.fade:DOFade(0, 0.5)
	self.freeAnim:SetAnimation(0, self.tipnum.gameObject.activeSelf and "WIN3" or "WON3", false)
	LMessage:Dispatch(LuaEvent.Sound.Play, "transition", Const.GameRule.Free, 3)
end

function TransitionView:OnAnimEvent(trackEntry)
	if trackEntry.Animation.Name == "WIN2" then
		self.tipnum.gameObject:SetActive(true)
		self.freeOutFreeNum.gameObject:SetActive(false)
		self.freeOutWinNum.gameObject:SetActive(false)
		local currValue = 0
		self.tipnum:ScrollNum(0, self.giveTime, 0, 1):OnUpdate(function(value)
			if math.floor(value) > currValue then
				currValue = math.floor(value)
				LMessage:Dispatch(LuaEvent.Sound.Play, "transition", Const.GameRule.Free, 2)
			end
		end)
		Globals.timerMgr:AddTimer(function()
			self.clickBtn:SetEnable(true)
			-- 开始按钮也是可以点击的
			LMessage:Dispatch(LuaEvent.SmallGame.KeyEvent, Const.KeyEvent.Bind, Const.KeyType.Start, callback(self, "OnClickBtn"))
		end, 0, 1)
	elseif trackEntry.Animation.Name == "WIN3" then -- 点击任意键,或开始按钮后
		if Globals.gameModel.isFreeToFree then -- 免费到免费
			-- 切换为免费场景
			LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Switch, Const.GameRule.Free, Const.GameRule.Free, 0)
			Globals.timerMgr:AddTimer(callback(self, "OnTransitionEnd"), 0, 0)
			LMessage:Dispatch(LuaEvent.Sound.Play, "transition", Const.GameRule.Free, 4)
		else
			self.free:SetActive(false)

			-- 角色播放变身特效

			-- scene场景播放变身动画
			LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Scene, Const.SceneViewEMO.RevealScene.PlayAnim, Const.SceneViewEMO.NameStr.Animation.BianShen)
			-- 播放特效
			self.normalToFree.gameObject:SetActive(true)
			self.normalToFree.particle:Play()

			-- 一些渲染
			Globals.processMgr:OpenProcess("RadialBlur", callback(self, "OnPostProcess"))
			Globals.timerMgr:AddTimer(function()
				-- 切换为免费场景
				LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Switch, Const.GameRule.Normal, Const.GameRule.Free, 2)
			end, 0, 1)
			Globals.timerMgr:AddTimer(callback(self, "OnTransitionEnd"), 0, 2.5)
			LMessage:Dispatch(LuaEvent.Sound.Play, "transition", Const.GameRule.Free, 4)
		end

	elseif trackEntry.Animation.Name == "WON3" then
		LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Finish)
		self:OnTransitionEnd()
	elseif trackEntry.Animation.Name == "WON2" then
		local currValue = 0
		
		self.freeOutFreeNum.gameObject:SetActive(true)
		self.freeOutWinNum.gameObject:SetActive(true)
		self.freeOutFreeNum:SetValue(Globals.gameModel.normalGiveTime)
		local odd = Globals.gameModel.win*Globals.gameModel.slot*Globals.gameModel.platformArg.multiplier
		self.freeOutWinNum:ScrollNum(0, odd, 0, 3):OnUpdate(function(value)
			if math.floor(value) > currValue then
				currValue = math.floor(value)
				LMessage:Dispatch(LuaEvent.Sound.Play, "transition", Const.GameRule.Free, 2)
			end
		end):OnComplete(function ()
			-- LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Finish)
		end)
		Globals.timerMgr:AddTimer(function()
			self.clickBtn:SetEnable(true)
			-- 开始按钮也是可以点击的
			LMessage:Dispatch(LuaEvent.SmallGame.KeyEvent, Const.KeyEvent.Bind, Const.KeyType.Take, callback(self, "OnClickBtn"))
		end, 0, 1)
	end
end

function TransitionView:OnPostProcess(volume)
	local profile = volume.profile
	--模糊后处理
	if profile:HasSettings(typeof(XPostProcessing.RadialBlurV2)) then
		local setting = profile.settings[0]
		local value, duration = 0, 0
		Globals.timerMgr:AddTimer(function()
			if duration < 1 and value < 0.5 then
				value = value + Time.deltaTime
				setting.BlurRadius.value = value
			elseif duration > 1.4 and value > 0 then
				value = value - Time.deltaTime
				setting.BlurRadius.value = value
			elseif duration < 2.5 and value < 0 then
				setting.BlurRadius.value = 0
			elseif duration >= 2.5 then
				return false
			end
			duration = duration + Time.deltaTime
			return true
		end)
	end
end
-- 2.5秒之后过渡的end操作
function TransitionView:OnTransitionEnd()
	Globals.poolMgr:Push("transition", self.transition) -- 放回池子
	Globals.processMgr:CloseProcess("RadialBlur") -- 转场的帷幕关闭
	Globals.uiMgr:HideView("TransitionView")
	G_printerror("在这个地方，当前的规则是：", Globals.gameModel.rule)
	--绑定开始按钮事件
	if self.newRule == Const.GameRule.Free then
		LMessage:Dispatch(LuaEvent.SmallGame.KeyEvent, Const.KeyEvent.Bind, Const.KeyType.Start, function()
			--解绑
			LMessage:Dispatch(LuaEvent.SmallGame.KeyEvent, Const.KeyEvent.UnBind, Const.KeyType.Start)
			-- RollView.lua下的rollState设为Const.ScrollType.Idle
			LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Finish)
		end)
		LMessage:Dispatch(LuaEvent.Sound.Play, "transition", Const.GameRule.Free, 5)
	elseif self.newRule == Const.GameRule.Normal then
	end
end

function TransitionView:ShowSelf()
	self:SetDepth(0) -- pop 0
	Globals.poolMgr:Pop(ConfigData.prefabName, "transition", callback(self, "OnLoadObject"))
	if self.oldRule == Const.GameRule.Normal and self.newRule == Const.GameRule.Free then
		self.clickBtn:SetEnable(false)
		self.tipnum:SetValue(0)
		self.free:SetActive(true)
		self.fade:DOFade(0.7, 0.5)
		self.freeAnim:SetAnimation(0, "WIN2", false)
		self.freeAnim:AddAnimation(0, "WIN1", true, 0)
		LMessage:Dispatch(LuaEvent.Sound.Play, "transition", Const.GameRule.Free, 1)

		-- 如果是免费游戏，自动按按钮 (暂时不自动了！！)
		-- if Globals.gameModel.isFreeToFree then
		-- 	Globals.timerMgr:AddTimer(function ()
		-- 		self:OnClickBtn()
		-- 	end, 0, 3)
		-- end
	elseif self.oldRule == Const.GameRule.Free and self.newRule == Const.GameRule.Normal then
		-- scene场景播放变身动画（在恶魔砸中地面的那个切片执行回调函数，在scene场景中的动画监听中）
		LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Scene, Const.SceneViewEMO.RevealScene.PlayBigAnim, Const.SceneViewEMO.NameStr.Animation.Attack, callback(self, "FreeToNormal"))

		
	end
end

-- 免费到普通，在恶魔播放动画砸地的时候触发的
function TransitionView:FreeToNormal()
	G_printerror("TransitionView:FreeToNormal")
	-- debug
	if ConfigData.debugFreeToNormal then 
		ConfigData.timeScale = Time.timeScale
		Time.timeScale = ConfigData.debugFreeToNormalZaDiTimeScale 
	end
	-- 播放特效
	self.freeToNormal.gameObject:SetActive(true)
	self.freeToNormal.particle:Play()
	G_printerror("播放特效了~！！")

	-- if true then return end
	-- 为了给特效持续时间，所以加个计时器
	Globals.timerMgr:AddTimer(function ()
		 G_printerror("播放完了！")
		-- Globals.processMgr:OpenProcess("RadialBlur", callback(self, "OnPostProcess"))
		-- 场景的一些变化
		LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Switch, Const.GameRule.Free, Const.GameRule.Normal, 1)
		LMessage:Dispatch(LuaEvent.Sound.Play, "transition", Const.GameRule.Normal, 4)
		Globals.timerMgr:AddTimer(function ()

			-- 播放bigwin
			self.free:SetActive(true)
			self.tipnum.gameObject:SetActive(false)
			self.freeAnim:SetAnimation(0, "WON2", false)
			self.freeAnim:AddAnimation(0, "WON1", true, 0)
			self.fade:DOFade(0.7, 0.5)
			-- self:OnTransitionEnd()

			if ConfigData.debugFreeToNormal then 
				Time.timeScale = ConfigData.timeScale
			end
		end, 0, 2)
	end, 0, 1.5)
	

end
return TransitionView