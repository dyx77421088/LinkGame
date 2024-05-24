
--[[ 
	岩浆的item
	cs中的修改代码
	mat.SetFloat("_Disturbance_Pow", myCurveValue);
	mat1.SetFloat("_Dissolve", myCurveValue);
	Matyanjiang.SetFloat("_MaskPercentage", myYanjiangValue);
 ]]
 local MagmaView = BaseClass("MagmaView", UIItem)
 local ConfigData = Globals.configMgr:GetConfig("SlotData")
 local ClassData = Globals.configMgr:GetConfig("ClassData")

 local NameStr = {
	DisturbancePow = "_Disturbance_Pow",
	Dissolve = "_Dissolve",
	MaskPercentage = "_MaskPercentage", -- 岩浆
	MagmaObject01 = "MagmaObject01", -- 显示拨开岩浆用的
	MaskSoft = "_MaskSoft", -- 拨开岩浆显示的框框的border
	Width = "_Width", -- 拨开岩浆显示的宽度
	Height = "_Height", -- 拨开岩浆显示的高度
 }
------------------------------------------初始化相关的-------------------------------------------------------
function MagmaView:__delete()
	LMessage:UnRegister(LuaEvent.Common.ApplicationUpdate, self.OnUpdate)
end
function MagmaView:__ctor(parent, baseView)
	self:InitItem(parent, nil, baseView)
end
function MagmaView:Initialize()
	self.OnUpdate = LMessage:Register(LuaEvent.Common.ApplicationUpdate, callback(self, "Update"))
	local process = function(tran)
		local gameObject = tran.gameObject
		gameObject:SetActive(false)
		return gameObject
	end
	self.magmas = TransformUtils.GetAllChilds(self.transform, process)

	-- 通过修改material 实现岩浆的一些操作
	local dynLoadManager = self.gameObject:GetComponent(ClassType.DynLoadManager)
	-- 这两个暂时没看出有啥用
	self.matDisturbancePow = dynLoadManager.Materials[0]
	self.matDissolve = dynLoadManager.Materials[1]
	-- 这个是 0-1 控制岩浆的显示
	self.matYanjiang = dynLoadManager.Materials[2]

	self:InitYanJiang()
end
function MagmaView:OnLoadObject(arguments, object)
	if not object then return end
	if object.gameObject.name == Const.SlotObject.NamStr.JianShe then
		local transform = object.transform
		transform:SetParent(Globals.uiMgr:Get_EffectContainer().transform)
		transform.position = arguments.chess.transform.position
		transform.localPosition = transform.localPosition + Vector3(4, 128, 0)
		transform.localScale = Vector3(13, 13, 13)

		-- 暂时保存，方便之后的回收
		self.jianShe = self.jianShe or {}
		self.jianShe[#self.jianShe+1] = object
	end
end
function MagmaView:Update()
	if self.startShowWild and self.chessObj and #self.chessObj > 0 then 
		if self.startDoTween then
			self.startDoTween = false
			for _, value in ipairs(self.chessObj) do
				-- z一秒钟移动到-100 移动完之后隐藏岩浆
				value.transform:DOLocalMoveZ(-100, 3)
			end

			-- 3秒钟之后执行岩浆退出操作
			Globals.timerMgr:AddTimer(function ()
				self:HideAllYanjiang()
			end, 0, 3.5)
		end
		self.objPos = self.objPos or {}
		for i = 1, #self.chessObj do
			self.objPos[i] = Vector4(self.chessObj[i].transform.position.x,self.chessObj[i].transform.position.y,self.chessObj[i].transform.position.z,1)
		end
		UnityEngine.Shader.SetGlobalVectorArray(NameStr.MagmaObject01, self.objPos)
	end
end
-- 初始化岩浆
function MagmaView:InitYanJiang()
	self.matDisturbancePow:SetFloat(NameStr.DisturbancePow, 0);
	self.matDissolve:SetFloat(NameStr.Dissolve, 0);
	self.matYanjiang:SetFloat(NameStr.MaskPercentage, 1) -- 显示岩浆
	self.matYanjiang:SetFloat(NameStr.MaskSoft, 2) -- 拨开岩浆的框框大小
	self.matYanjiang:SetFloat(NameStr.Width, 9.6) -- 拨开岩浆的宽度
	self.matYanjiang:SetFloat(NameStr.Height, 10.88) -- 拨开岩浆的高度
	
	self.startShowWild = false
	self.startDoTween = false
end
function MagmaView:ShowYanjiang(yangjiangIndex)
	if not self.isStart then self.isStart = true self:InitYanJiang() end
	-- 上下的缩放
	-- self.magmas[yangjiangIndex].transform:DOScaleY(0, 0)
	-- self.magmas[yangjiangIndex].transform:DOScaleY(1, 2)
	-- 拨开岩浆 从 0=>1 持续1秒
	-- self.matYanjiang:DOFloat(0, NameStr.MaskPercentage, 0)
	-- self.matYanjiang:DOFloat(1, NameStr.MaskPercentage, 1)
	self.magmas[yangjiangIndex]:SetActive(true)
end

function MagmaView:HideYanjiang()
	-- 把岩浆材质的 _MaskPercentage 属性 1秒钟变成0
	self.matYanjiang:DOFloat(0, NameStr.MaskPercentage, 1)
end
-- 隐藏所有的岩浆
function MagmaView:HideAllYanjiang()
	-- 隐藏岩浆
	self.matYanjiang:DOFloat(0, NameStr.MaskPercentage, 2):SetEase(EaseType.OutQuad):OnComplete(function ()
		for _, value in ipairs(self.magmas) do
			value:SetActive(false)
		end
		self.startShowWild = false
		self.startDoTween = false
		self.isStart = false
		-- 回收溅射效果
		for _, value in ipairs(self.jianShe) do Globals.poolMgr:Push(Const.SlotObject.NamStr.JianShe, value) end
		-- 棋子的z轴置为0
		for _, value in ipairs(self.chessObj) do
			-- z移动到0 移动完之后隐藏岩浆
			value.transform:DOLocalMoveZ(0, 0)
		end
		self.chessObj = {} -- 清空
		-- 执行回调并赋空
		if self.hideCallback then self.hideCallback() self.hideCallback = nil end
	end)  

	
end
-- 开始拨开岩浆，显示里面的棋子
function MagmaView:StartShowWild(hideCallback)
	self.startShowWild = true
	self.startDoTween = true -- 这个只执行一次

	self.hideCallback = hideCallback -- 完成显示棋子之后的回调
end
-- 显示出棋子(chess:砸中这一列的棋子，col：哪一列，)
function MagmaView:ShowChess(chess, col, caijinIndex)
	local caij, scatterWildCount = ConfigData.caijin, 0
	-- 这个是添加的全部
	-- self.chessObj = chess
	-- for _, value in ipairs(chess) do
	-- 	value.transform:DOLocalMoveZ(-100, 1) -- 一秒钟移动到-100
	-- end

	-- 事实上只需要添加最上方的那个棋子就可以了的（最多是五列）
	if not self.chessObj or #self.chessObj == ConfigData.roll.columns then self.chessObj = {} end 
	
	-- 只需要修改最上方棋子动态拨开岩浆
	self.chessObj[#self.chessObj+1] = chess[ConfigData.roll.rows]
	chess[ConfigData.roll.rows].transform:DOLocalMoveZ(0, 0) -- z轴设为0
	-- 溅射效果
	Globals.poolMgr:Pop(ConfigData.prefabName, Const.SlotObject.NamStr.JianShe, callback(self, "OnLoadObject", {chess = chess[ConfigData.roll.rows]}))
	-- 拨开之后棋子变成金币
	for row, value in ipairs(chess) do
		-- 判断这个位置是否是jackpot
		if self:CheckJackpot(row, col) then 
			value:ResetResult(Const.ChessType.Jackpot, true)
			-- 根据彩金类型显示不同的spine动画
			local animation = value.follower[2].transform:GetChild(0):Find("jackpotSpine"):GetComponent(ClassType.SkeletonGraphic).AnimationState
			animation:SetAnimation(0, caij[caijinIndex or 1].."2", true)
			
		else
			scatterWildCount = scatterWildCount + (value.result == Const.ChessType.Scatter and 1 or 0)
			value:ResetResult(value.result == Const.ChessType.Scatter and Const.ChessType.WildScatter or Const.ChessType.Wild, true)
		end
	end
	
	local objPos = {}
	-- 这b玩意每次打开unity它只接受一次值，你给他设置为多大他就只有多大，所以第一次最好设置大一些，因为有五列，我就给objPos设置长度为5了
	for i = 1, ConfigData.roll.columns do
		local k = self.chessObj[(i - 1) % #self.chessObj + 1].transform.position
		objPos[i] = Vector4(k.x, k.y, k.z, 1)
	end
	
	UnityEngine.Shader.SetGlobalVectorArray(NameStr.MagmaObject01, objPos)

	return scatterWildCount
end
function MagmaView:CheckJackpot(row, col)
	for _, value in ipairs(Globals.gameModel.jackpot) do
		if value[1] == row and value[2] == col then return true end
	end
	return false
end
return MagmaView
