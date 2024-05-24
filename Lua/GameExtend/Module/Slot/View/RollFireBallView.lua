--[[ 
	roll 场景中的 火球相关的代码控制
 ]]
 local RollFireBallView = BaseClass("RollFireBallView", UIItem)
 local ConfigData = Globals.configMgr:GetConfig("SlotData")
 local ClassData = Globals.configMgr:GetConfig("ClassData")

------------------------------------------#regin 初始化、加载对象相关的-------------------------------------------------------
function RollFireBallView:__delete()
end
function RollFireBallView:__ctor()
	self.wildData = {}
	self.collects = {}
	self.chessData = {}
end
function RollFireBallView:Initialize()
	
end
-- 加载对象
function RollFireBallView:OnLoadObject(arguments, object)
	if object.gameObject.name == Const.SlotObject.NamStr.FireBall then
		self:OnLoadFireBallObject(arguments, object)
	elseif object.gameObject.name == Const.SlotObject.NamStr.FireBrust then -- 金币替换棋子的特效
		self:OnLoadFireBallBrustObject(arguments, object)
	end
end
-- 加载火球对象
function RollFireBallView:OnLoadFireBallObject(arguments, object)
	-- 记录这一次放火球是否全部完成了
	--[[ 
		存放类似于这样的形式：
		{
			{ --------- 假设第一个火球击中的是普通图标（col和row为火球击中之后图标的col和row）
				col = 1,
				row = 1,
				isOk = true,
			},
			{ --------如果击中的是不是普通图标，那么需要散开，散开的坐标在rep中
				col = 1,
				row = 1,
				isOk = true,
				rep = {
					{
						col = 1,
						row = 1,
						isOk = true
					},
					{
						col = 1,
						row = 1,
						isOk = true
					}
				}
			}, 
			{ --------- 假设第三个火球击中的是普通图标
				col = 1,
				row = 1,
				isOk = true,
			},
			-- 一共最多是五个火球
		}
	]]
	if not self.fireBallIsOk then  self.fireBallIsOk = {{}, {}, {}, {}, {}} end
	self.scatterWild = 0 -- 这个是记录scatterwild的个数的（既是wild又是scatter）
	-- self.total = arguments.total -- 目标火球的个数
	Globals.gameModel.scatterWildCount = 0 -- 放全局中去，方便之后的访问
	local fireBallItem = object
	if ObjectUtils.IsGameObject(object) then
		fireBallItem = { gameObject = object, transform = object.transform }
	end
	if arguments.startPos or arguments.targetPos then -- 火球遇到叉子溅射
		self:ForkFireDown(arguments, fireBallItem)
	elseif arguments.column then
		G_printerror("这个是之前的吧？？")
		-- self:FireBallFly(arguments, fireBallItem)
	else
		-- { index = v, total = 5 }
		self:FireBallDown(arguments, fireBallItem)
	end
end
-- 加载火球爆炸对象
function RollFireBallView:OnLoadFireBallBrustObject(arguments, object)
	local downItem = object
	if ObjectUtils.IsGameObject(object) then
		downItem = { gameObject = object, transform = object.transform, particle = object:GetComponent(ClassType
		.ParticleSystem) }
	end
	local parent = Globals.uiMgr:Get_EffectContainer()
	downItem.transform:SetParent(parent.transform)
	TransformUtils.NormalizeTrans(downItem.transform)
	downItem.transform.position = arguments.targetPos
	downItem.transform.localScale = Vector3(1, 1, 1)
	downItem.particle:Play()
	-- 在火球爆炸持续时间 的一些时间 后替换成金币
	Globals.timerMgr:AddTimer(function ()
		if arguments.callBack then arguments.callBack() end
		-- 修改跟随的特效
		self:updateFollowBox(false)
	end, 0, ConfigData.fireBall.rollBrustTime / 3)

	Globals.timerMgr:AddTimer(function()
		downItem.particle:Stop()
		Globals.poolMgr:Push(Const.SlotObject.NamStr.FireBrust, downItem)
		
		-- 火球已经全部发射完了
		-- if arguments.index == arguments.total then
		if self.fireBallIsOk == nil then return end
		-- 统计完成的火球数TODD
		local isOkCount = self:CheckFireBallIsOkCount()
		G_printerror("火球的个数", self.total, isOkCount)
		if self.total == isOkCount then
			self.fireBallIsOk = nil
			-- 这个玩意还是放到全局去吧
			Globals.gameModel.scatterWildCount = self.scatterWild
			-- 设置一下速度（debug）
			if ConfigData.debugFireBall then Time.timeScale = ConfigData.timeScale end
			if not self.frupsChess then
				LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Result)
				self:ResetData()
			elseif arguments.column then
				LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Result)
				self:ResetData()
				
			else
				self.frupsChess:LoadFollower()
			end

			
		end
	end, 0, ConfigData.fireBall.rollBrustTime)
	LMessage:Dispatch(LuaEvent.Sound.Play, "effect_coin", 3)
end
------------------------------------#endregin----------------------------------------------------------


------------------------------------#region 火球相关的 start--------------------------------------------

-- 修改金币， addValue 值例如{{1, 12}, {2, 3}, {3, -1}}，表示添加1列的金币12，2列添加3, 3列清空  添加已存在的金币不影响
function RollFireBallView:addWild(addValue)
	for index, value in ipairs(addValue) do
		self.changeWildData[value[1]] = value[2] <= 0 and 0 or value[2] + self.changeWildData[value[1]] * (10 ^ #tostring(value[2]))
	end
end



-- 检测这个火球是否已经是OK的了 
function RollFireBallView:CheckFireBallIsOk(fireBall)
	if not fireBall then return true end
	local isOk = fireBall.isOk
	if isOk then self:addWild({{fireBall.col, fireBall.row}}) end
	if fireBall.rep then -- 如果存在rep（分裂之后的火球要砸中的点）
		for index, value in ipairs(fireBall.rep) do
			isOk = isOk and self:CheckFireBallIsOk(value)
		end
	end
	return isOk
end
-- 检测火球isOk的个数
function RollFireBallView:CheckFireBallIsOkCount()
	local count = 0
	self:addWild({{1, 0}, {2, 0}, {3, 0}, {4, 0}, {5, 0}}) -- 把五列的金币置零
	for index, value in ipairs(self.fireBallIsOk) do -- 循环五个点的位置，看有几个火球已经完成任务了
		if self:CheckFireBallIsOk(value) then count = count + 1 end
	end
	return count
end
-- 棋子替换成wild， col:列     row：行    fireBallIndex: 第几个火球
function RollFireBallView:ChessesReplaceWild(col, row, fireBall)
	fireBall.row = row
	fireBall.col = col
	-- fork需要替换的点
	local forkReplace, value = ConfigData.forkRepWildPos, self.chesses[col][row].result
	if value == Const.ChessType.Wild then -- 已经是金币了
		fireBall.isOk = true
		return true 
	end 
	if value == Const.ChessType.Fork then -- 叉子
		fireBall.isOk = true -- 叉子这个位置为已经ok了
		fireBall.rep = {}
		local rep = fireBall.rep -- 散开的点
		self.chesses[col][row]:ResetResult(Const.ChessType.Wild, true)
		for index, value in ipairs(forkReplace) do
			local c, r = col + value[1], row + value[2]
			if c > 0 and r > 0 and c <= ConfigData.roll.columns and r <= ConfigData.roll.rows then
				table.insert(rep, {col = c, row = r, isOk = false}) -- 当rep表中的所有ikOk都为true时表示这个火球完成任务了
			end
		end
		
		-- 添加一个动画，替换出wild (startPos:从哪个位置开始，rep：需要替换的wild的位置)
		LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Scene, Const.RollViewEMO.RevealScene.FireBallToFork, 
						{startPos = self.chesses[col][row].transform, rep = rep})
		-- 直接替换
		-- for index, value in ipairs(rep) do
		-- 	self.chesses[value.col][value.row]:ResetResult(Const.ChessType.Wild, true)
		-- end
	elseif value == Const.ChessType.Scatter then -- 角色
		fireBall.isOk = true
		self.chesses[col][row]:ResetResult(Const.ChessType.WildScatter, true)
		-- 替换成金币之后还需要让 scatterWild++
		self.scatterWild = self.scatterWild + 1
		return true
	else -- 如果是普通棋子，那就直接替换
		fireBall.isOk = true
		self.chesses[col][row]:ResetResult(Const.ChessType.Wild, true)
		return true
	end
	return false
end
-- 落下
function RollFireBallView:FireBallDown(arguments, fireBallItem)
	fireBallItem.transform:SetParent(arguments.parent)
	TransformUtils.NormalizeTrans(fireBallItem.transform)
	Globals.timerMgr:AddTimer(function()
		-- fireBallItem.transform.position = collectCoins[arguments.index].transform.position
		fireBallItem.transform.position = arguments.birthPos
		fireBallItem.transform.localScale = Vector3(16, 16, 16)
		fireBallItem.gameObject:SetActive(true)

		local str = tostring(self.wildData[arguments.index])
		local randNum = math.random(1, string.len(str))
		local char = string.sub(str, randNum, randNum)
		local value = tonumber(char)
		str = string.gsub(str, char, "", 1)
		self.wildData[arguments.index] = string.tonumber(str)

		local targetPos = self.chesses[arguments.index][value].transform.position
		local vec = (targetPos - fireBallItem.transform.position) * 1
		local midPos = targetPos - vec
		arguments.targetPos = targetPos
		-- fireBallItem.transform:DOMove(midPos, ConfigData.fireBall.rollMoveTime * 0.6):SetEase(EaseType.OutQuad):OnComplete(function()
			fireBallItem.transform:DOMove(targetPos, ConfigData.fireBall.rollMoveTime):SetEase(EaseType.InQuad) -- 先慢后快
		-- end)
		fireBallItem.transform:DOScale(17 * 1.5, ConfigData.fireBall.rollMoveTime * 1):SetEase(EaseType.OutQuad):OnComplete(function()
			-- if true then return end
			fireBallItem.transform:DOScale(0, ConfigData.fireBall.rollMoveTime * 0.2):SetEase(EaseType.InQuad):SetDelay(0.5):OnComplete(function()
				Globals.poolMgr:Push(Const.SlotObject.NamStr.FireBall, fireBallItem) -- 特效回收
			end)
			
			-- 还需要替换的个数
			self.fireBallCount = (self.fireBallCount or 0) + 1
			arguments.callBack = function ()
				-- 棋子替换成wild（如果火球击中的是普通的点，那么就说明这个火球已经完成任务了，index这个位置标为true，当有total个true时就表示全部完成了）
				self:ChessesReplaceWild(arguments.index, value, self.fireBallIsOk[arguments.index])
			end
			Globals.poolMgr:Pop(ConfigData.prefabName, Const.SlotObject.NamStr.FireBrust, callback(self, "OnLoadObject", arguments))
			
			-- self.chesses[arguments.index][value]:ResetResult(Const.ChessType.Wild, true)
		end)
		LMessage:Dispatch(LuaEvent.Sound.Play, "effect_coin", 2)
	end, 0, (arguments.index - 1) * ConfigData.fireBall.rollInterval)
end

-- 从fork的位置飞出火球发射到周围
function RollFireBallView:ForkFireDown(arguments, fireBallItem)
	local col, row = arguments.targetPos.col, arguments.targetPos.row
	fireBallItem.transform:SetParent(arguments.parent)
	TransformUtils.NormalizeTrans(fireBallItem.transform)
	fireBallItem.transform.position = arguments.startPos.position -- 初始化位置
	fireBallItem.transform.position.z = 0
	fireBallItem.transform.localScale = Vector3(16, 16, 16)
	fireBallItem.gameObject:SetActive(true)
	local targetPos = self.chesses[col][row].transform.position
	arguments.targetPos = targetPos

	local firBallTime = ConfigData.fireBall.rollFlMoveTime
	-- fireBallItem.transform:DOMove(midPos, 11.5):SetEase(EaseType.OutQuad):OnComplete(function()
		fireBallItem.transform:DOMove(targetPos, firBallTime):SetEase(EaseType.InQuad)
	-- end)
	fireBallItem.transform:DOScale(17, firBallTime * 0.8):SetEase(EaseType.OutQuad):OnComplete(function()
		fireBallItem.transform:DOScale(0, firBallTime * 0.2):SetEase(EaseType.InQuad):SetDelay(0.5):OnComplete(function()
			Globals.poolMgr:Push(Const.SlotObject.NamStr.FireBall, fireBallItem) -- 特效回收
			arguments.callBack = function ()
				-- 棋子替换成wild
				self:ChessesReplaceWild(col, row, arguments.rep[arguments.index])  -- 再次递归
			end
			Globals.poolMgr:Pop(ConfigData.prefabName, Const.SlotObject.NamStr.FireBrust, callback(self, "OnLoadObject", arguments))
			-- self.chesses[col][row]:ResetResult(Const.ChessType.Wild, true)
		end)
	end)
	LMessage:Dispatch(LuaEvent.Sound.Play, "effect_coin", 2)
end
------------------------------------#endregin----------------------------------------------------------


---------------------------------#regin 在rollview的sceneview订阅中执行的相关的 start------------------
function RollFireBallView:RevealSceneStartFireBall(wildData)
	-- local algorithm = self.oneRound:GetAlgorithm()
	-- local wildData = algorithm.WildData
	local collects = {}
	-- 这个是放火球的，然后存放到self.wildData中
	for k, v in ipairs(wildData) do
		-- G_printerror("v=>>>>>>>>>", v)
		if v > 0 and self.wildData[k] ~= v then
			if not self.wildData[k] then
				table.insert(collects, k)
			end
			self.wildData[k] = v
		end
	end

	for k, v in ipairs(collects) do
		if not table.contains(self.collects, v) then
			table.insert(self.collects, v)
		end
	end
	--发送npc抛金币消息（飞向的位置）
	LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Scene, Const.SceneViewEMO.RevealScene.FireBallStart, collects)
end

-- n个火球new出来并飞向指定位置的棋子
function RollFireBallView:RevealSceneFireBallFly(arguments)
	-- if #self.collects == 5 or self.frupsChess then
	if #self.collects > 0 then

		--金币下落替换棋子
		-- if #self.collects == 5 then
		-- self.total = #self.collects -- 目标要完成多少个火球的任务
		self.total = #self.collects -- 目标要完成的火球的个数
		for k, v in ipairs(self.collects) do
			Globals.poolMgr:Pop(ConfigData.prefabName, Const.SlotObject.NamStr.FireBall,
				callback(self, "OnLoadObject", {index = v, birthPos = arguments.birthPos, parent =  arguments.parent }))
		end
			--宝箱抛金币
		-- else
		-- 	self.frupsChess:LoadFollower()
		-- end
	else
		LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Result)
	end
end
-- 碰到叉子了！！
function RollFireBallView:RevealSceneFireBallToFork(pos, parent)
	G_printerror("pos.rep的长度是", #pos.rep)
	for index, v in ipairs(pos.rep) do
		local fc = callback(self, "OnLoadObject", { startPos = pos.startPos, targetPos = v, index = index, rep = pos.rep, parent = parent})
		Globals.poolMgr:Pop(ConfigData.prefabName, Const.SlotObject.NamStr.FireBall, fc)
	end
end
-------------------------------------#endregin------------------------------------------------------------
-- 跟随棋子的发光特效 active：是否显示， 因为只有在获得结果的时候才是要显示的
function RollFireBallView:updateFollowBox(active)
	G_printerror("我就来修改特效了啊啊啊啊啊啊啊啊啊啊啊")
	local findNmae = "ng_eff_box"
	-- self.chesses[col][row].follower[2].transform
	for i = 1, ConfigData.roll.columns do -- 列数
		for j = 1, ConfigData.roll.rows do -- 行数
			local childs = TransformUtils.GetAllChilds(self.chesses[i][j].follower[2].transform)
			if #childs > 0 then
				local t = childs[1]:Find(findNmae)
				if t then
					if not active then 
						t.transform.gameObject:SetActive(false) 
					else -- 改变缩放
						t.transform.gameObject:SetActive(true) 
						-- 有一些棋子过于大了，所以在外部是给它有一个缩放的如金币 (0.85, 0.85, 1)
						local sf = self.chesses[i][j].follower[2].transform.localScale.x
						-- 为了使它保持在16的缩放，所以要再乘以 1 / sf
						t.transform.localScale = Vector3(16, 16, 16) * (1 / sf)
					end
				end
				
			else
				G_printerror("没有childs", self.chesses[i][j].follower[2].transform.name)
			end
		end
	end
end

-- 一局完成之后重置 统计的 火球表等一些数据
function RollFireBallView:ResetData()
	table.clear(self.wildData)
	table.clear(self.collects)
	Globals.gameModel.scatterWildCount = 0
	self.scatterWild = 0
	self.total = nil
	for _, v in pairs(self.chessData) do
		if v.value then
			v.value = 0
		end
	end
end
-- 获取一局游戏数据时的监听
function RollFireBallView:OnBetResult(msg, chesses)
	-- 这个是需要改变的金币的数据，因为放火球的时候会使场景中的棋子变为金币，所以在最后计算结果的时候应该是要修改矩阵的
	-- 修改这个地方影响OneRound:AlterMatrix 中的wildData  
	-- 存放的数据如 {123, 1, 13, 0, 3} ===》 表示第一列 1、2、3行位置有金币， 第二列 1 行有金币 ......
	self.changeWildData = msg.WildData
	self.chesses = chesses
	G_printerror("msg", table.serialize(msg))
	Globals.gameModel.jackpot = {}
	-- 处理一下矩阵， 当有为jackpot的棋子的时候先用 xx 代替，然后记录这个棋子的位置
	for index, value in ipairs(msg.Matrix) do
		-- 棋子从0开始的, 把行列放入Globals.gameModel.jackpot
		if value + 1 == Const.ChessType.Jackpot then 
			table.insert(Globals.gameModel.jackpot, {math.floor((index - 1) / 5) + 1, (index - 1) % 5 + 1}) 
			-- 修改棋子暂时显示的是xx（从0开始） ===== 也可以在场景中修改SlotAtlas下的chess_idle，15改为需要显示的图标，用下列这行代码就不需要15了（主要是没有jackpot显示的图标）
			msg.Matrix[index] = math.random(0, 9) -- 随机！！ [0, 9] => [1, 10] 
			-- G_printerror("随机到的id是", msg.Matrix[index])
		end
	end
	G_printerror("处理完之后的矩阵", table.serialize(msg.Matrix))
	-- 根据传过来的WheelBet确定彩金的类别，（1到#ConfigData.caijin这个范围）
	self.caijinIndex = math.clamp(math.reduce((msg.WheelBet or 0), 10000), 1, #ConfigData.caijin)

	
end
function RollFireBallView:GetCaijinIndex()
	return self.caijinIndex
end
return RollFireBallView
