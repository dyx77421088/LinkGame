--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:场景视图逻辑
--     创建时间:2023/09/20
--------------------------------------------------------------------------------
local RollView = require "GameLogic.Module.Slot.View.RollView"
require "GameExtend.Module.Slot.View.RollViewConst"
RollView = BaseClass("RollViewEditor", RollView)
local ConfigData = Globals.configMgr:GetConfig("SlotData")
local ClassData = Globals.configMgr:GetConfig("ClassData")
local ScrollShade = require(ClassData.ScrollShade)
local ScrollFocus = require(ClassData.ScrollFocus)
local MagmaView = require(ClassData.MagmaView)
local OneRound = require(ClassData.OneRound)
local RollFireBallView = require(ClassData.RollFireBallView)
local NumberItem = require "GameLogic.UI.Number.NumberItem"

------------------------------------------#regin 初始化相关的-------------------------------------------------------
function RollView:__delete()
end
function RollView:Initialize()
	self.reel = self:GetChild("reel")
	self.chess = self:GetChild("reel/chess")
	self.shade = ScrollShade.New(self:GetChild("reel/shade"), self.mBaseView)
	self.focus = ScrollFocus.New(self:GetChild("focus"), self.mBaseView)
	self.oneRound = OneRound.New(ConfigData.roll.rows, ConfigData.roll.columns, ConfigData.lines, ConfigData.chess.odds)
	self.RollFireBallView = RollFireBallView.New()
	-- 初始化岩浆特效
	self.magmaView = MagmaView.New(self:GetChild("effect/magmas"), self.mBaseView)
	self:InitRollItem()


	self.normal = { back = self:GetChild("back/normal").gameObject }
	self.normal.force = self:GetChild("force/normal").gameObject
	self.free = { back = self:GetChild("back/free").gameObject }
	self.free.force = self:GetChild("force/free").gameObject



	-- 初始化 current OF total  （数字）
	self.free.current = NumberItem.New(self:GetChild(Const.RollViewEMO.NameStr.Current),
		self:GetChild(Const.RollViewEMO.NameStr.Current.."/0").gameObject, self.mBaseView)
	self.free.current:SetAtlasParam(ConfigData.atlasName, "freenumber/")
	self.free.total = NumberItem.New(self:GetChild(Const.RollViewEMO.NameStr.Total), self:GetChild(Const.RollViewEMO.NameStr.Total.."/0").gameObject,
		self.mBaseView)
	self.free.total:SetAtlasParam(ConfigData.atlasName, "freenumber/")

	self.normal.back:SetActive(true)
	self.normal.force:SetActive(true)
	self.free.back:SetActive(false)
	self.free.force:SetActive(false)

	self.wildData = {}
	self.chessData = {}

	LMessage:Dispatch(LuaEvent.Loading.AddLoaded, 1)
end
------------------------------------------#endregion----------------------------------------------------------

------------------------------------------#regin 表现结果相关的-----------------------------------------------------
--表现场景
function RollView:RevealScene(...)
	if ConfigData.debugLinkGame then
		LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Switch, Const.GameRule.Normal, Const.GameRule.Link)
		return
	end


	local program = select(1, ...)
	--判断是否收集金币
	if not program then
		self.RollFireBallView:RevealSceneStartFireBall(self.oneRound:GetAlgorithm().WildData) -- 开始丢火球！！
		--npc抛金币结束
	elseif program == Const.RollViewEMO.RevealScene.FireBallEnd then
		local arguments = select(2, ...) or {}
		arguments.parent = self.mBaseView.effectView.transform
		self.RollFireBallView:RevealSceneFireBallFly(arguments)
	elseif program == Const.RollViewEMO.RevealScene.FireBallToFork then
		--火球碰到叉子分叉替换棋子
			local pos = select(2, ...)
			self.RollFireBallView:RevealSceneFireBallToFork(pos, self.mBaseView.effectView.transform)
		-- end
	end
end

-- 完成普通得分之后的操作（还需要计算特殊奖啊）
function RollView:WinAfter(result, specialType)
	
	if specialType > Const.ResultType.Lose then
		local totalOdds = 0
		for _, lineClss in ipairs(result.arrays[specialType]) do
			totalOdds = totalOdds + lineClss.odds
			for i = 1, #lineClss.chessPos do
				self.chesses[math.floor(lineClss.chessPos[i] / 10)][lineClss.chessPos[i] % 10]:LoadFollower()
			end
		end
		LMessage:Dispatch(LuaEvent.Sound.Play, "chess_win", specialType, result.arrays[specialType], self
		.chesses)

		LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Effect, Const.EffectType.Normal, totalOdds,
			callback(self, "CheckSwitch", specialType))
	else
		self:CheckSwitch()
	end
end
-- 判断是否有彩金 
function RollView:CaiJinResult()
	local matrix = self.oneRound.matrix
	local wildData = self.oneRound:GetAlgorithm().WildData
	for index, value in ipairs(matrix) do
		if wildData[index] ~= 0 then -- 只有恶魔砸中了才会进行彩金判断
			for _, n in ipairs(value) do
				if n == Const.ChessType.Jackpot then 
					--发送请求彩金消息(在平台PlatSimulate:OnGameEvent计算分数，再调用自己的 OnGameEvent 方法)
					Globals.pipeMgr:Send(EEvent.PipeMsg.GameEvent, {id = "GetJackpot", playBet = Globals.gameModel.playBet})
					G_printerror("我中彩金了", index, n)
					return true 
				end
			end
		end
	end
	return false
end

--游戏结果
function RollView:RevealResult(...)
	-- 我是测试用的，直接打开linkview
	if ConfigData.debugLinkGame then
		LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Switch, Const.GameRule.Normal, Const.GameRule.Link)
		return
	end

	self.oneRound:Calculate() -- 计算中奖的倍率
	-- 彩金得分优先
	if self:CaiJinResult() then return end
	local result = self.oneRound.result
	--没中奖
	if not result.winning then
		LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Effect, Const.EffectType.Normal, 0,
			callback(self, "CheckSwitch"))
		--中奖
	else
		self.shade:Show(_MaxNumber)
		local specialType = Const.ResultType.Lose
		for i = Const.ResultType.Free, Const.ResultType.Link do
			if result.arrays[i] then
				specialType = i
				break
			end
		end
		--普通奖
		if result.arrays[Const.ResultType.Win] then
			local totalOdds = 0
			for _, lineClss in ipairs(result.arrays[Const.ResultType.Win]) do
				totalOdds = totalOdds + lineClss.odds
				for i = 1, #lineClss.chessPos do
					-- 这个是让图片动起来
					self.chesses[i][lineClss.chessPos[i]]:LoadFollower()
				end
			end
			LMessage:Dispatch(LuaEvent.Sound.Play, "chess_win", Const.ResultType.Win, result.arrays
			[Const.ResultType.Win], self.chesses)
			-- 播放特效，完了之后切换场景
			LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Effect, Const.EffectType.Normal, totalOdds,callback(self, "WinAfter",result, specialType))
			--特殊奖
		else
			self:WinAfter(result, specialType)
		end
	end
end

function RollView:RevealSwitch(...)
	local oldRule = select(1, ...)
	local newRule = select(2, ...)
	local program = select(3, ...)

	if oldRule == Const.GameRule.Free and newRule == Const.GameRule.Free then -- 免费到免费
		self.free.current:SetValue(Globals.gameModel.totalGiveTime - Globals.gameModel.remainGiveTime)
		self.free.total:ScrollNum(nil, Globals.gameModel.totalGiveTime, 0, 2):OnUpdate(function(value)
			LMessage:Dispatch(LuaEvent.Sound.Play, "transition", Const.GameRule.Free, 2)
		end):OnComplete(function ()
			self:CheckSwitch()
		end)
		
	--普通场景->免费场景
	elseif oldRule == Const.GameRule.Normal and newRule == Const.GameRule.Free then
		if not program then -- 打开过度场景,点击任意键之后才会到免费场景   
			Globals.timerMgr:AddTimer(function()
				Globals.uiMgr:OpenView("TransitionView", function(viewbase)
					viewbase.oldRule = oldRule
					viewbase.newRule = newRule
					viewbase.giveTime = Globals.gameModel.giveFreeCount or Globals.gameModel.totalGiveTime
				end)
			end, 0, 0.5)
			--切换场景
		elseif program == 2 then -- 这才是真正的到free场景
			self.normal.back:SetActive(false)
			self.normal.force:SetActive(false)
			self.free.back:SetActive(true)
			self.free.force:SetActive(true)
			self.free.current:SetValue(Globals.gameModel.totalGiveTime - Globals.gameModel.remainGiveTime)
			self.free.total:SetValue(Globals.gameModel.totalGiveTime)
			-- 调整棋子的位置
			self:ResetReel(Const.GameRule.Free)
		end
		--免费场景->普通场景
	elseif oldRule == Const.GameRule.Free and newRule == Const.GameRule.Normal then
		if not program then
			Globals.timerMgr:AddTimer(function()
				Globals.uiMgr:OpenView("TransitionView", function(viewbase)
					viewbase.oldRule = oldRule
					viewbase.newRule = newRule
				end)
			end, 0, 0.5)
		elseif program == 1 then
			self.normal.back:SetActive(true)
			self.normal.force:SetActive(true)
			self.free.back:SetActive(false)
			self.free.force:SetActive(false)
			self:ResetReel(Const.GameRule.Normal)
		end
	elseif oldRule == Const.GameRule.Normal and newRule == Const.GameRule.Link then -- 普通到link场景
		self:SetIsPop(false) -- 隐藏
		Globals.uiMgr:OpenView("LinkView", function(viewbase)
		end)
	end
end

function RollView:RevealEffect(...)
	-- 更改roll中的box (修改跟随的特效)
	self.RollFireBallView:updateFollowBox(true)
	local type, index = select(1, ...)
	if type == Const.RollViewEMO.RevealEffect.Magma then
		self.magmaView:ShowYanjiang(index) -- 显示岩浆
		self.scatterWild = (self.scatterWild or 0) + self.magmaView:ShowChess(self.chesses[index], index, self.RollFireBallView:GetCaijinIndex()) -- 岩浆泼中的棋子(修改为金币，并返回scatterWild的个数)
		-- 修改金币 (这一列三个都是金币，所以是123)
		self.RollFireBallView:addWild({{index, 123}})
	elseif type == Const.RollViewEMO.RevealEffect.MagmaShowChess then
		self.magmaView:StartShowWild(function ()
			-- 这个玩意还是放到全局去吧
			Globals.gameModel.scatterWildCount = self.scatterWild or 0
			-- 请求结果
			LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Result)
			self.RollFireBallView:ResetData()
		end)
	end
end


function RollView:RevealChess(chess, gameObject, ...)
	if chess.value == Const.ChessType.Wild then
		-- local item = self.chessData[gameObject]
		-- if not item then
		-- 	item = {
		-- 		gameObject = gameObject,
		-- 		transform = gameObject.transform,
		-- 		num = NumberItem.New(gameObject.transform:Find("num"), gameObject.transform:Find("num/0").gameObject,
		-- 		self.mBaseView),
		-- 		value = 0,
		-- 	}
		-- 	item.num:SetAtlasParam(ConfigData.atlasName, "wildnumber/")
		-- 	self.chessData[gameObject] = item
		-- end
		-- if ... then
		-- 	item.value = item.value + 1
		-- end
		-- if item.value > 1 then
		-- 	item.num:SetValue("X" .. item.value)
		-- 	item.num:SetIsPop(true)
		-- else
		-- 	item.num:SetIsPop(false)
		-- end
	elseif chess.value == Const.ChessType.Fork and chess.state == Const.ScrollType.Finish then
		G_printerror("注釋了！！撒旦")
		--填满收集金币
		-- for i = 1, 5 do
		-- 	end
		-- end
		-- ComUtils.ResetAnim(gameObject, "open")
		-- --发送frups抛金币消息
		
		-- else
		-- 	local len, coinCnt, columns = 0, 0, {}
		-- 	for k, v in pairs(self.wildData) do
		-- 		if v then
		-- 			len = string.len(tostring(v))
		-- 			for i = 1, len do
		-- 				table.insert(columns, k)
		-- 			end
		-- 			coinCnt = coinCnt + len
		-- 		end
		-- 	end
		-- 	Globals.timerMgr:AddTimer(function()
		-- 		for k = 1, coinCnt do
		-- 			Globals.poolMgr:Pop(ConfigData.prefabName, "wildcoin",
		-- 				callback(self, "OnLoadObject", { index = k, total = coinCnt, column = columns[k], parent =  self.mBaseView.effectView.transform}))
		-- 		end
		-- 	end, 0, 0.6)
		-- end
	else
		ComUtils.ResetAnim(gameObject)
	end
end
---------------------------------------endregion------------------------------------------------------

-------------------------------------------------------------------------------------------------------------
-- 获取一局游戏数据时的监听
function RollView:OnBetResult(msg)
	self.oneRound:SetResult(msg)
	-- 把 chesses 放进去，因为火球砸中替换棋子要用到
	self.RollFireBallView:OnBetResult(msg, self.chesses)

end
local freeSpaces = { 0, 200, 400, 600, 800 }
function RollView:ResetReel(rule)
	if rule == Const.GameRule.Free then
		self.reel.localPosition = self.reel.localPosition + Vector3(0, -20, 0)
		self.focus.transform.localPosition = self.focus.transform.localPosition + Vector3(0, -20, 0)
		self.chess.localPosition = Vector3(-400, -445, 0)
		for _, chess in ipairs(self.items) do
			local pos = chess.transform.localPosition
			pos = Vector3(freeSpaces[chess.groupId], pos.y, pos.z)
			chess:SetPos(pos)
		end
	elseif rule == Const.GameRule.Normal then
		self.reel.localPosition = self.reel.localPosition - Vector3(0, -20, 0)
		self.focus.transform.localPosition = self.focus.transform.localPosition - Vector3(0, -20, 0)
		self.chess.localPosition = Vector3(-417, -445, 0)
		local vector = Vector3(math.abs(ConfigData.roll.direction.y), math.abs(ConfigData.roll.direction.x), 0)
		for _, chess in ipairs(self.items) do
			local pos = chess.transform.localPosition
			pos = Vector3(ConfigData.roll.spaces[chess.groupId], pos.y, pos.z)
			chess:SetPos(pos)
		end
	end
end
-- 这玩意主要是要从平台获得分数score
function RollView:OnGameEvent(msg)
	if msg.id == "GetJackpot" then
		LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Effect, Const.EffectType.JackPot, msg.score, function()
			-- 先让scene场景中的jackpot 回到原来的位置，然后再执行 CheckSwitch
			LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Scene, Const.SceneViewEMO.RevealScene.JackpotHide, self.RollFireBallView:GetCaijinIndex(), callback(self, "CheckSwitch"))
		end, self.RollFireBallView:GetCaijinIndex())
	end
end
function RollView:OnNumerical(...)
	local category = select(1, ...) or false
	if category == "FreeTime" then
		self.free.current:SetValue(Globals.gameModel.totalGiveTime - Globals.gameModel.remainGiveTime)
		self.free.total:SetValue(Globals.gameModel.totalGiveTime)
	end
end

return RollView
