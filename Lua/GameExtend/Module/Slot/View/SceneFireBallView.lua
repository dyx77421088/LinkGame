--[[ 
	scene 场景中的 火球相关的代码控制
 ]]
 local SceneFireBallView = BaseClass("SceneFireBallView", UIItem)
 local ConfigData = Globals.configMgr:GetConfig("SlotData")
 local ClassData = Globals.configMgr:GetConfig("ClassData")

 local NameStr = {
	FireBall = "ng_eff_fireBall_hand_my",
	FireBallBirthPos = "firePos/birthPos", -- 火球抛出的出生点
	FireBallFlyPos = "firePos/flyPos", -- 火球抛出到这个点才开始分裂
 }

------------------------------------------初始化相关的-------------------------------------------------------
function SceneFireBallView:__delete()

end
function SceneFireBallView:__ctor(parent, baseView, npcFireBallPos)
	self.npcFireBallPos = npcFireBallPos
	self:InitItem(parent, nil, baseView)
end
function SceneFireBallView:Initialize()
	self.effect_fire_main = self:GetChild(NameStr.FireBall)
	self.effect_fire_main_pos = self.effect_fire_main.transform.position
	
	self.fireBallBirthPos = self:GetChild(NameStr.FireBallBirthPos)
	self.fireBallFlyPos = self:GetChild(NameStr.FireBallFlyPos)
end
function SceneFireBallView:OnLoadObject(arguments, object)
	if object.gameObject.name == Const.SlotObject.NamStr.FireBall then
		local flyItem = object
		if ObjectUtils.IsGameObject(object) then
			flyItem = {gameObject = object, transform = object.transform, particle = object:GetComponent(ClassType.ParticleSystem)}
		end
		self:FireBallFly(flyItem, arguments) -- 先飞一段距离
	elseif object.gameObject.name == Const.SlotObject.NamStr.FireBrust then -- 爆炸特效
		local boomItem = object
		if ObjectUtils.IsGameObject(object) then
			boomItem = {gameObject = object, transform = object.transform, particle = object:GetComponent(ClassType.ParticleSystem)}
		end
		self:FireBallBoom(boomItem, arguments) -- 火球爆炸
	end
end

------------------------------------火球相关的----------------------------------------------------------
-- 根据类型显示或播放火球
function SceneFireBallView:FireBallMove(type)
	-- 当前状态不需要改变
	if self.FireBallType == type then return end

	if type == Const.SceneViewEMO.FireBallType.Idle then -- idle
		if not self.fireMoveSeq then 
			-- 火球上下浮动
			-- self.fireMoveSeq = DOTween.Sequence();
			-- self.effect_fire_main.transform.position = self.effect_fire_main_pos
			-- local y = self.effect_fire_main.transform.position.y
			-- self.fireMoveSeq:Append(self.effect_fire_main.transform:DOMoveY(y + 5, 2):SetEase(EaseType.OutQuad))
			-- self.fireMoveSeq:Append(self.effect_fire_main.transform:DOMoveY(y, 2):SetEase(EaseType.OutQuad))
			-- self.fireMoveSeq:SetLoops(-1) -- 设置为无限循环播放

			-- 修改一下z轴
			self.effect_fire_main.transform:DOMoveZ(self.npcFireBallPos.transform.position.z, 0)
			-- 不使用DOTween，用计时器，然后根据世界坐标中的火球的位置设置值（这样可以跟着手动作动）
			self.fireMoveSeq = Globals.timerMgr:AddTimer(function ()
				if self.FireBallType == Const.SceneViewEMO.FireBallType.Idle then
					self.effect_fire_main.transform:DOMoveY(self.npcFireBallPos.transform.position.y, 0)
				end
				return true
			end, 0, 0.1)
		end 
		-- 继续
		self:SetFireActive(true, function ()
			-- if self.fireMoveSeq then self.fireMoveSeq:Play() end
		end)
		-- 世界坐标上的火球停止
		if self.npcFireBallPos then
			self.npcFireBallPos.gameObject:SetActive(false)
		end
		
	elseif type == Const.SceneViewEMO.FireBallType.Start then -- 开始
		-- 设置一下速度（debug）
		if ConfigData.debugFireBall then 
			ConfigData.timeScale = Time.timeScale 
			Time.timeScale = ConfigData.debugTimeScale 
		end
		-- 暂停上下浮动的动画
		self:SetFireActive(false, function ()
			G_printerror("开始丢火球之后，把场景上的火球隐藏")
			-- if self.fireMoveSeq then self.fireMoveSeq:Pause() end
		end)
		if self.npcFireBallPos then
			self.npcFireBallPos.gameObject:SetActive(true)-- 世界坐标上的那个火球显示
			-- 设置它的缩放大小
			self.npcFireBallPos.transform.localScale = Vector3(0.03, 0.03, 0.03)
			-- 一段时间时候它的缩放大小为0
			self.npcFireBallPos.transform:DOScale(0, 2)
		end
	elseif type == Const.SceneViewEMO.FireBallType.Fly then -- 火球飞
		self.npcFireBallPos.gameObject:SetActive(false) -- 世界坐标上的那个火球隐藏
		-- 记录一下这个火球的位置
		self.fireBallBirthPos = self.npcFireBallPos.transform.position
		-- new新的火球特效
		Globals.poolMgr:Pop(ConfigData.prefabName, Const.SlotObject.NamStr.FireBall, callback(self, "OnLoadObject", nil))

	elseif type == Const.SceneViewEMO.FireBallType.End then -- 结束了
		-- 设置一下速度（debug）
		-- Time.timeScale = 1
		
		self:FireBallMove(Const.SceneViewEMO.FireBallType.Idle)
	elseif type == Const.SceneViewEMO.FireBallType.Hide then
		-- 暂停上下浮动的动画
		self:SetFireActive(false, function ()
			-- if self.fireMoveSeq then self.fireMoveSeq:Pause() end
		end)
	end
	-- 保存当前的状态
	self.FireBallType = type
end

-- 设置火球的显示和隐藏
function SceneFireBallView:SetFireActive(active, OnComplete)
	if active then
		self.effect_fire_main.gameObject:SetActive(true)
		self.effect_fire_main.transform.localScale = Vector3.zero
		self.effect_fire_main.transform:DOScale(16, 1):SetEase(EaseType.OutQuad):OnComplete(OnComplete)
	else
		-- 慢慢缩小，直到隐藏
		self.effect_fire_main.transform:DOScale(0, 1):SetEase(EaseType.OutQuad):OnComplete(function ()
			self.effect_fire_main.gameObject:SetActive(false)
			if OnComplete then OnComplete() end
		end)
	end
end

-- 火球从npc手上飞到屏幕
function SceneFireBallView:FireBallFly(flyItem, arguments)
	local parent = Globals.uiMgr:Get_EffectContainer()
	flyItem.transform:SetParent(parent.transform)
	TransformUtils:NormalizeTrans(flyItem.transform)
	flyItem.transform.localScale = Vector3(16, 16, 16)
	-- 优先参数，然后若不适用摄像机，那么npc是在场景上的，记录出生点
	if arguments and arguments.startPos then
		flyItem.transform.position = arguments.startPos
	elseif not ConfigData.useCamera then
		flyItem.transform.position = self.fireBallBirthPos
	else
		flyItem.transform.position = self.fireBallBirthPos.position
	end

	flyItem.transform:DOScale(Vector3.zero, 0)
	flyItem.transform:DOScale(Vector3(16, 16, 16), ConfigData.fireBall.sceneMoveTime)
	self.endPos = self.fireBallFlyPos.position -- 飞到指定的位置
	flyItem.transform:DOMove(self.endPos, ConfigData.fireBall.sceneMoveTime):SetEase(EaseType.OutQuad):OnComplete(function()
		
		-- flyItem.particle:Stop()
		Globals.poolMgr:Push(Const.SlotObject.NamStr.FireBall, flyItem)
		-- 火球裂开（特效显示，分裂在特效完成之后）
		-- Globals.poolMgr:Pop(ConfigData.prefabName, Const.SlotObject.NamStr.FireBrust, callback(self, "OnLoadObject", arguments))

		-- 不播放爆炸特效，直接new新的火球
		LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Scene, Const.RollViewEMO.RevealScene.FireBallEnd, {birthPos = self.endPos})
	end)
end
-- 火球爆炸
function SceneFireBallView:FireBallBoom(boomItem, arguments)
	local parent = Globals.uiMgr:Get_EffectContainer()
	boomItem.transform:SetParent(parent.transform)
	G_printerror("下来的时候的名字是", boomItem.gameObject.name)
	TransformUtils:NormalizeTrans(boomItem.transform)
	boomItem.transform.localScale = Vector3(1, 1, 1)
	boomItem.transform.position = self.endPos -- 火球最后飞到了这里
	boomItem.particle:Play()
	G_printerror("我到这里还能运行")
	Globals.timerMgr:AddTimer(function()
		boomItem.particle:Stop()
		Globals.poolMgr:Push(Const.SlotObject.NamStr.FireBrust, boomItem)
		LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Scene, Const.RollViewEMO.RevealScene.FireBallEnd, {birthPos = self.endPos})
	end, 0, ConfigData.fireBall.sceneFireBrustTime)
end
-------------------------------------------------------------------------------------------------------
return SceneFireBallView
