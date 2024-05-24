--[[ 
	scene 场景中的 npc、bigNpc相关的代码控制
 ]]
 local SceneNpcView = BaseClass("SceneNpcView", UIItem)
 local ConfigData = Globals.configMgr:GetConfig("SlotData")
 local ClassData = Globals.configMgr:GetConfig("ClassData")
 local sceneFireBallView = require(ClassData.SceneFireBallView) -- 火球对象
 local ButtonItem = require "GameLogic.Module.Slot.Common.ButtonItem"

 local NameStr = {
	Npc = "npc",
	BigNpc = "bigNpc",
	FireBall = "fireBall",
	Character = "character", -- npc的显示点
	CharacterClickBtn = "npc/click", -- 点击npc的按钮
 }
 -- 是否使用相机记录npc
 local useCamera = ConfigData.useCamera or false

------------------------------------------初始化相关的 start-------------------------------------------------------
function SceneNpcView:__delete()

end
function SceneNpcView:__ctor(parent, baseView)
	self:InitItem(parent, nil, baseView)
end
function SceneNpcView:Initialize()
	self.character = self:GetChild(NameStr.Character, ClassType.RawImage)
	self.clickBtn = ButtonItem.New(self:GetChild(NameStr.CharacterClickBtn), self.mBaseView)
	self.clickBtn:AddOnClick(self.clickBtn, callback(self, "OnClickBtn"))

	-- 使用相机
	if useCamera then
		Globals.resMgr:LoadObject(ConfigData.prefabName, Const.SlotObject.NamStr.Npc, callback(self, "OnLoadObject", nil)) -- 加载npc
		Globals.resMgr:LoadObject(ConfigData.prefabName, Const.SlotObject.NamStr.BigNpc, callback(self, "OnLoadObject", nil)) -- 加载bignpc
	else
		-- npc放到场景中去了，不使用相机
		self:OnLoadObject(nil, self:GetChild(NameStr.Npc))
		self:OnLoadObject(nil, self:GetChild(NameStr.BigNpc))
	end
	
	
end
-- 加载完成后的回调
function SceneNpcView:OnLoadObject(arguments, object)
	if object.gameObject.name == Const.SlotObject.NamStr.Npc then
		self:OnLoadNpcObject(object)
	elseif object.gameObject.name == Const.SlotObject.NamStr.BigNpc then
		self:OnLoadBigNpcObject(object)
	elseif object.gameObject.name == Const.SlotObject.NamStr.XiaZa then -- 下砸特效
		local xiaza = object
		if ObjectUtils.IsGameObject(object) then
			xiaza = {gameObject = object, transform = object.transform, particle = object:GetComponent(ClassType.ParticleSystem)}
		end
		self:OnLoadXiaZa(xiaza, arguments)
	end
end
-- free => normal
function SceneNpcView:OnLoadXiaZa(xiaza, arguments)
	xiaza.transform:SetParent(Globals.uiMgr:Get_EffectContainer().transform)
	xiaza.transform.position = arguments.position
	xiaza.transform.localScale = Vector3(13, 13, 13)
	xiaza.particle:Play()

	-- 3秒后回收
	Globals.timerMgr:AddTimer(function ()
		Globals.poolMgr:Push(Const.SlotObject.NamStr.XiaZa, xiaza) -- 放回池子
	end, 0, 3)
end
-- 加载npc的object
function SceneNpcView:OnLoadNpcObject(object)
	-- local characterMod = GameObject.Instantiate(object)
	-- 使用相机就要new一个，不然就直接用
	local characterMod = useCamera and GameObject.Instantiate(object) or object.transform
	local characterTrans = characterMod.transform
	-- 使用相机npc放到指定的位置
	if useCamera then characterTrans:SetParent(Globals.cameraMgr:GetModelRender()) end
	characterTrans.localPosition = useCamera and Vector3(0, 0, 24) or Vector3(0, 0, 0)
	characterTrans.localEulerAngles = Vector3(0, 180, 0)
	characterTrans.localScale = useCamera and Vector3(30, 30, 30) or Vector3(700, 700, 700)
	self.characterAnim = characterMod:GetComponent(ClassType.Animator)
	self.npcGo = characterMod.gameObject
	local dynLoadManager = characterMod:GetComponent(ClassType.DynLoadManager)
	self.npcFireBallPos = dynLoadManager.GameObjects[0].transform

	-- 加载火球对象
	local k = self:GetChild(NameStr.FireBall)
	self.sceneFireBallView = sceneFireBallView.New(self:GetChild(NameStr.FireBall), self.mBaseView, self.npcFireBallPos)
	self.sceneFireBallView:FireBallMove(Const.SceneViewEMO.FireBallType.Idle)

	self:AddUIEvent(characterMod, callback(self, "OnAnimEvent")) -- 添加动画的事件回调方法

	if useCamera then
		Globals.cameraMgr:InitCamera(self.character, 60)
		self.character.gameObject:SetActive(true)
	end
	characterMod.gameObject:SetActive(true)
end
-- bignpc
function SceneNpcView:OnLoadBigNpcObject(object)
	-- local characterMod = GameObject.Instantiate(object)
	-- 使用相机就要new一个，不然就直接用
	local characterMod = useCamera and GameObject.Instantiate(object) or object.transform
	local characterTrans = characterMod.transform
	-- 使用相机bignpc放到指定的位置
	if useCamera then characterTrans:SetParent(Globals.cameraMgr:GetModelRender()) end

	characterTrans.localPosition = useCamera and Vector3(0, 0, 0) or Vector3(-82, -82, 322)
	characterTrans.localEulerAngles = Vector3(0, 180, 0)
	characterTrans.localScale = useCamera and Vector3(16, 16, 16) or Vector3(300, 300, 300)

	-- bignpc一些东西后续是要使用的
	self.bigCharacterAnim = characterMod:GetChild(0):GetComponent(ClassType.Animator)
	self.bigNpcGo = characterMod.gameObject
	-- local dynLoadManager = characterMod:GetComponent(ClassType.DynLoadManager)
	-- self.npcFireBallPos = dynLoadManager.GameObjects[0].transform
	self:AddUIEvent(characterMod:GetChild(0), callback(self, "OnAnimEvent"))
	characterMod.gameObject:SetActive(false)
end
-- 设置bignpc的回调函数（在free=》normal中大恶魔砸地之后用到）
function SceneNpcView:SetBigNpcCallBack(callbk)
	self.bigNpcCallBack = callbk
end
------------------------------------------初始化相关的 end-------------------------------------------------------

------------------------------------动画相关的 start----------------------------------------------------------
function SceneNpcView:SetNpcTrigger(trigger)
	self.characterAnim:SetTrigger(trigger)
end
function SceneNpcView:SetBigNpcTrigger(trigger)
	self.bigCharacterAnim:SetTrigger(trigger)
end
-- 点击npc播放动画
function SceneNpcView:OnClickBtn()
	G_printerror("进来播放动画了!!!")
	if self.isCharacterAnim then
		return
	end
	
	self.isCharacterAnim = true
	local randNum = math.random(1, 3)
	if randNum == 1 then
		self.characterAnim:SetTrigger(Const.SceneViewEMO.NameStr.Animation.Fly)
	elseif randNum == 2 then
		self.characterAnim:SetTrigger(Const.SceneViewEMO.NameStr.Animation.RotateOne)
	elseif randNum == 3 then
		self.characterAnim:SetTrigger(Const.SceneViewEMO.NameStr.Animation.PaoZhuan)
	else
		G_printerror("未知的")
		self.characterAnim:SetTrigger(Const.SceneViewEMO.NameStr.Animation.Fly)
	end
end

-- 动画的事件
function SceneNpcView:OnAnimEvent(trigger, param)
	-- 小恶魔的动画事件
	self:OnNpcAnimEvent(param)
	-- 大恶魔的动画事件
	self:OnBigNpcAnimEvent(param)
end

-- 小恶魔的动画事件放这里面处理
function SceneNpcView:OnNpcAnimEvent(param)
	if param == Const.SceneViewEMO.NameStr.Animation.Event.PaoHuoQiuStart then -- 抛火球的开始事件
		G_printerror("npc抛火球")
		-- self.wildCnt = 0
		self.sceneFireBallView:FireBallMove(Const.SceneViewEMO.FireBallType.Start)
		-- Globals.poolMgr:Pop(ConfigData.prefabName, "ng_eff_fireBall_hand_my", callback(self, "OnLoadObject", nil))
	elseif param == Const.SceneViewEMO.NameStr.Animation.Event.PaoHuoQiuFire then -- 抛出事件
		G_printerror("npc抛出火球！！")
		self.sceneFireBallView:FireBallMove(Const.SceneViewEMO.FireBallType.Fly)
	elseif param == Const.SceneViewEMO.NameStr.Animation.Event.PaoHuoQiuEnd then -- 结束抛火球事件
		G_printerror("npc结束火球！！")
		self.sceneFireBallView:FireBallMove(Const.SceneViewEMO.FireBallType.End)
	elseif param == Const.SceneViewEMO.NameStr.Animation.Event.Idle and not self.bBigWin then -- idle
		self.isCharacterAnim = false
		self.sceneFireBallView:FireBallMove(Const.SceneViewEMO.FireBallType.Idle)

	elseif param == Const.SceneViewEMO.NameStr.Animation.Event.FlyEnd then -- fly结束
		if self.bBigWin then
			self.characterAnim:SetTrigger(Const.SceneViewEMO.NameStr.Animation.Win3)
		else
			self.isCharacterAnim = false
		end
	elseif param == Const.SceneViewEMO.NameStr.Animation.Event.Win01End then
		if self.bBigWin then
			self.characterAnim:SetTrigger(Const.SceneViewEMO.NameStr.Animation.Win3)
		else
			self.isCharacterAnim = false
		end
	elseif param == Const.SceneViewEMO.NameStr.Animation.Event.Win02End then
		if self.bBigWin then
			self.characterAnim:SetTrigger(Const.SceneViewEMO.NameStr.Animation.Win3)
		else
			self.isCharacterAnim = false
		end
	elseif param == Const.SceneViewEMO.NameStr.Animation.Event.Win03End then
		if self.bBigWin then
			self.characterAnim:SetTrigger(Const.SceneViewEMO.NameStr.Animation.Fly)
		else
			self.isCharacterAnim = false
		end
	elseif param == Const.SceneViewEMO.NameStr.Animation.Event.BianShenEnd then -------- 变身！！！！！！！
		-- 小恶魔隐藏，大恶魔显示
		self.npcGo:SetActive(false)
		self.bigNpcGo:SetActive(true)
		self.bigCharacterAnim:SetTrigger(Const.SceneViewEMO.NameStr.Animation.BianShen)
	else
		self.sceneFireBallView:FireBallMove(Const.SceneViewEMO.FireBallType.Hide)
	end
end
-- 大恶魔的动画事件放这里面处理
function SceneNpcView:OnBigNpcAnimEvent(param)
	if param == Const.SceneViewEMO.NameStr.Animation.Event.AttackPlane then
		G_printerror("我是大恶魔，我进行播放了这个动画了！！！！！！！！！！！！！！！！！")
		-- rollview中对恶魔砸下之后效果响应, 第n列播放特效
		LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Effect, Const.RollViewEMO.RevealEffect.Magma, self.collects[self.colllectsIndex])
		self.colllectsIndex = self.colllectsIndex + 1
		-- 播放砸地的音乐
	elseif param == Const.SceneViewEMO.NameStr.Animation.Event.AttackPlaneEnd then
		if not self:ZaDi() then-- 继续砸地(当返回为false的时候说明已经砸完了，需要继续获取结果的请求了)
			G_printerror("全部砸完了，需要获取结果")
			LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Effect, Const.RollViewEMO.RevealEffect.MagmaShowChess)
		end 
	elseif param == Const.SceneViewEMO.NameStr.Animation.Event.AttackBianShenStart then -- 在变身开始的时候调用，因为变身光的那个特效要慢一些
		G_printerror("播放火焰特效的同时回调！！！！")
		if self.bigNpcCallBack then 
			self.bigNpcCallBack()  
			self.bigNpcCallBack = nil
			-- end, 0, 2)
		end
	elseif param == Const.SceneViewEMO.NameStr.Animation.Event.AttackBianShen then
		-- 播放火焰的特效
		Globals.poolMgr:Pop(ConfigData.prefabName, Const.SlotObject.NamStr.XiaZa,
					callback(self, "OnLoadObject", {position=Vector3(0,0,0)}))
		-- 执行回调并附空（免费到普通中，恶魔砸地transitionview中的一些变化）
		-- G_printerror("播放火焰特效的同时回调！！！！")
		-- if self.bigNpcCallBack then 
		-- 	self.bigNpcCallBack()  
		-- 	self.bigNpcCallBack = nil
		-- 	-- end, 0, 2)
		-- end
	end
end

-- 砸地
function SceneNpcView:ZaDi()
	-- 砸地动画
	if self.colllectsIndex <= #self.collects then
		self:SetBigNpcTrigger(Const.SceneViewEMO.NameStr.Animation.AttackPlanes[self.collects[self.colllectsIndex]]) 
		
		return true
	end
	return false
end
-- 大恶魔抛火球（大锤子砸地）
function SceneNpcView:RevealSceneFreeFireBall()
	self.colllectsIndex = 1
	if not self:ZaDi() then -- 如果一次都没有执行，说明没有砸地
		-- 请求结果
		LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Result)
	end
end
-- 小恶魔抛火球
function SceneNpcView:RevealSceneNormalFireBall()
	-- 这个地方有动画监听的，在播放这个动画的时候会把火球丢出
	self:SetNpcTrigger(Const.SceneViewEMO.NameStr.Animation.PaoHuoQiu) 
	-- self.throwParticle:Play()
	LMessage:Dispatch(LuaEvent.Sound.Play, "effect_coin", 1)
end
------------------------------------动画相关的 end----------------------------------------------------------

-- 免费场景=》普通场景下 需要做的操作 
function SceneNpcView:FreeToNomarl()
	-- 大恶魔隐藏，小恶魔显示
	self.npcGo:SetActive(true)
	self.bigNpcGo:SetActive(false)

	if ConfigData.debugFreeToNormal then Time.timeScale = ConfigData.debugFreeToNormalXEMTimeScale end
	-- 小恶魔显示的一些动画
	local pos = self.npcGo.transform.position
	self.npcGo.transform.localScale = Vector3(0,0,0);
	self.npcGo.transform.position = pos + (ConfigData.useCamera and Vector3(-5, 0, 0) or Vector3(-350, 0, 0))
	self.npcGo.transform:DOScale(ConfigData.useCamera and 30 or 700, 1.3)
	G_printerror("小子的卫视是", pos, pos + (ConfigData.useCamera and Vector3(0, 6, 0) or Vector3(0, 100, 0)))
	self.npcGo.transform:DOLocalMove(pos + (ConfigData.useCamera and Vector3(0, 6, 0) or Vector3(0, 180, 0)), 0.5):SetEase(EaseType.OutQuart):OnComplete(function ()
		self.npcGo.transform:DOLocalMove(pos, 0.2):SetEase(EaseType.InQuart)
	end);
end










return SceneNpcView
