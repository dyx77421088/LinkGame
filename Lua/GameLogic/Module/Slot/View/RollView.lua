--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:滚轮View
--     创建时间:2023/09/20  
--------------------------------------------------------------------------------
local RollView = BaseClass("RollView", UIItem)
local ConfigData = Globals.configMgr:GetConfig("SlotData")
local ClassData = Globals.configMgr:GetConfig("ClassData")
local RollItem = require (ClassData.RollItem)
local ScrollShade = require (ClassData.ScrollShade)
local ScrollFocus = require (ClassData.ScrollFocus)
local OneRound = require (ClassData.OneRound)
local _MaxNumber = _MaxNumber

Const.ScrollType = {
	Idle = 0, --待机
	Begin = 1, --开始
	Scroll = 2, --滚动
	Stop = 3, --停止
	Rebound = 4, --回滚
	Finish = 5, --结束
}

Const.RevealType = {
	Scene = 0, --场景表现
	Result = 1, --结果表现
	Effect = 2, --特效表现
	Switch = 3, --转场表现
	Finish = 4, --表现结束
}

Const.RecallType = {
	Request = "Request", --请求
	Get = "Get", --获取
}


function RollView:__defaultVar()
	return {
		rollTimer = 0,
		rollTime = ConfigData.roll.stopTime, --滚轮自动停止时间
		rollState = Const.ScrollType.Idle, --滚轮状态
		stopIds = {}, --当前停止的列
		chesses = {}, --滚轮显示棋子
		deepests = {}, --滚轮最深度棋子
	}
end

function RollView:__ctor(parent, baseView)
	self:InitItem(parent, nil, baseView)
end

function RollView:Initialize()
	self.shade = ScrollShade.New(self:GetChild("reel/shade"), self.mBaseView)
	self.focus = ScrollFocus.New(self:GetChild("focus"), self.mBaseView)
	self.oneRound = OneRound.New(ConfigData.roll.rows, ConfigData.roll.columns, ConfigData.lines, ConfigData.chess.odds)
	self:InitRollItem()
	
	LMessage:Dispatch(LuaEvent.Loading.AddLoaded, 1)
end

function RollView:InitRollItem()
	local OnLoadSprite = function(item)
		--调整item占用
		item:SetCell(ConfigData.roll.cells[item.value] or 1)
	end
	
	local OnInstantiate = function(i, go)
		return RollItem.New(go, self.mBaseView, ConfigData.chess.showCnt)
	end
	
	--层级不同分多个追随者
	local scrollFollow = self:GetChild("reel/follow")
	local finishFollow = self:GetChild("follow")
	local groupItems = {}
	local OnSetData = function(i, item)
		item:AddLoadSprite(OnLoadSprite)
		item:AddFollowerReveal(callback(self, "RevealChess"))
		item:SetDirection(ConfigData.roll.direction)
		item:SetAtlasParam()
		item:SetScrollParam(ConfigData.roll.speeds, ConfigData.roll.rollBacks)
		item:SetRegion(ConfigData.roll.regions)
		local sumPerGroup = math.floor(ConfigData.roll.count/ConfigData.roll.columns)
		local groupId = math.floor((i-1)/sumPerGroup)+1
		local index = (i-1)%sumPerGroup+1
		item:SetGroupId(groupId)
		item:SetName(groupId.."_"..index)
		--增加滚动追随者
		if scrollFollow then
			local follower = GameObject.New(groupId.."_"..index)
			follower.transform:SetParent(scrollFollow)
			TransformUtils.NormalizeTrans(follower)
			item:AddFollower(follower)
		end
		--增加停止追随者
		if finishFollow then
			local follower = GameObject.New(groupId.."_"..index)
			follower.transform:SetParent(finishFollow)
			TransformUtils.NormalizeTrans(follower)
			item:AddFollower(follower)
		end
		--绑定棋子关系
		if not groupItems[groupId] then
			groupItems[groupId] = {}
		else
			local itemCount = #groupItems[groupId]
			local previous = groupItems[groupId][itemCount]
			item:SetPrevious(previous)
			previous:SetLatter(item)
			if itemCount == sumPerGroup - 1 then
				groupItems[groupId][1]:SetPrevious(item)
				item:SetLatter(groupItems[groupId][1])
			end
		end
		table.insert(groupItems[groupId], item)
		--初始化item位置
		local vector = Vector3(math.abs(ConfigData.roll.direction.y), math.abs(ConfigData.roll.direction.x), 0)
		local pos = (vector * ConfigData.roll.spaces[item.groupId]) - (ConfigData.roll.direction * (ConfigData.roll.regions * (index - 1)))
		item:SetPos(pos)
		--初始化只让面板上棋子有追随者
		if index > 1 and index <= ConfigData.roll.rows + 1 then
			item:ResetResult(math.random(1, ConfigData.chess.showCnt))
		else
			item:SetValue()
		end
	end
	
	--初始化棋子
	self.itemPrefab = self:GetChild("reel/chess/0")
	self.itemPrefab.gameObject:SetActive(false)
	self.items = {}
	ComUtils.SimpleReuse(self.items, self.itemPrefab, ConfigData.roll.count, OnInstantiate, OnSetData)
end

function RollView:Update()
	if self.rollState == Const.ScrollType.Scroll or self.rollState == Const.ScrollType.Stop then
		for _, item in ipairs(self.items) do
			item:Scrolling()
		end
		if self.rollState == Const.ScrollType.Scroll then
			self.rollTimer = self.rollTimer + Time.deltaTime
			if Globals.gameModel.receive and self.rollTimer >= self.rollTime then
				--找还在滚动的第一列
				for column = 1, ConfigData.roll.columns do
					if not self.deepests[column] then
						LMessage:Dispatch(LuaEvent.SmallGame.StopRound, false, column)
						break
					end
				end
			end
		elseif self.rollState == Const.ScrollType.Stop then
			--回滚
			for _, id in pairs(self.stopIds) do
				if self.deepests[id]:GetState() == Const.ScrollType.Rebound then
					self.stopIds[_] = nil
					LMessage:Dispatch(LuaEvent.SmallGame.FinishRound, false, id)
				end
			end
			--停止
			if table.nums(self.deepests) == ConfigData.roll.columns then
				for _, item in pairs(self.deepests) do
					if item:GetState() ~= Const.ScrollType.Finish then
						return
					end
				end
				LMessage:Dispatch(LuaEvent.SmallGame.FinishRound, true)
			end
		end
	end
end

function RollView:LateUpdate()
	if self.rollState == Const.ScrollType.Idle then
		if (Globals.gameModel.rule == Const.GameRule.Normal and Globals.gameModel.autoGame) or (Globals.gameModel.rule == Const.GameRule.Free and Globals.gameModel.remainGiveTime > 0) then
			LMessage:Dispatch(LuaEvent.SmallGame.StartRound)
		end
	end
	if self.rollState == Const.ScrollType.Idle and not Globals.gameModel:IsLocked() and Globals.gameModel.state == Const.GameState.Idle and Globals.gameModel.credit <= 0 then
		Globals.gameModel.exitTimer = Globals.gameModel.exitTimer + Time.deltaTime
		if Globals.gameModel.exitTimer > 60 then
			LMessage:Dispatch(LuaEvent.Common.GameQuit, Const.QuitReason.Client, "客户端长时间待机退出")
		end
	else
		Globals.gameModel.exitTimer = 0
	end
end

function RollView:OnPrepare(msg)
	--重载结果数据
	self.oneRound:ReloadResult(msg)
	--重载棋子阵列
	if self.oneRound.matrix then
		for col = 1, ConfigData.roll.columns do
			local matrix = self.oneRound.matrix[col]
			local chess = self:FindDeepestItem(col)
			self.chesses[col] = {}
			for row = 1, ConfigData.roll.rows do
				chess = chess.latter
				chess.state = Const.ScrollType.Rebound
				self.chesses[col][row] = chess
				chess:ResetResult(matrix[row])
			end
		end
	end
	--重载滚轮状态
	if Globals.gameModel.state == Const.GameState.Idle then
		self.rollState = Const.ScrollType.Idle
	else
		self.rollState = Const.ScrollType.Finish
	end
	--重载场景状态
	LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Scene, Const.RecallType.Request)
end

function RollView:OnOneRound()
	self.rollTimer = 0
	self.rollState = Const.ScrollType.Scroll
	table.clear(self.deepests)
	table.clear(self.stopIds)
	self.shade:Show(_MaxNumber)
	for _, item in ipairs(self.items) do
		item:StartScroll()
	end
end

function RollView:OnBetResult(msg)
	self.oneRound:SetResult(msg)
end

function RollView:OnStopRound(immediate, ...)
	if self.rollState ~= Const.ScrollType.Scroll and self.rollState ~= Const.ScrollType.Stop then
		return
	end
	
	self.rollState = Const.ScrollType.Stop
	if immediate then
		self.focus:Focus(_MaxNumber)
		for col = 1, ConfigData.roll.columns do
			self:StopRoundByGroup(col, true)
		end
	else
		local len = select("#", ...)
		for i = 1, len do
			local col = select(i, ...)
			self:StopRoundByGroup(col, false)
		end
	end
end

function RollView:OnFinishRound(immediate, column)
	if self.rollState == Const.ScrollType.Finish then
		return
	end
	
	--完全停下 -> 中奖表现[棋子中奖动画、BIG WIN...]
	if immediate then
		self.rollState = Const.ScrollType.Finish
		LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Scene)
	--回滚阶段 -> 滚轮表现[遮罩、焦点框...]
	else
		--音效
		LMessage:Dispatch(LuaEvent.Sound.Play, "chess_down", self.oneRound.matrix[column])
		--隐藏遮罩
		self.shade:Hide(column)
		--焦点框
		if table.nums(self.deepests) == ConfigData.roll.columns then
			self.focus:Focus(_MaxNumber)
		else
			for i = 1, ConfigData.roll.columns do
				if not self.deepests[i] then
					if self:IsRevealFocus() then
						self.focus:Focus(ConfigData.roll.spaces[i])
						self.shade:Hide(i)
						Globals.timerMgr:AddTimer(function()
							--此列还没停止
							if not self.deepests[i] then
								LMessage:Dispatch(LuaEvent.SmallGame.StopRound, false, i)
							end
						end, 0, self.focus:GetFocusTime())
					else
						Globals.timerMgr:AddTimer(function()
							--此列还没停止
							if not self.deepests[i] then
								LMessage:Dispatch(LuaEvent.SmallGame.StopRound, false, i)
							end
						end, 0, ConfigData.roll.intervalTime)
					end
					break
				end
			end
		end
	end
end

function RollView:OnReveal(revealType, ...)
	if revealType == Const.RevealType.Scene then
		self:RevealScene(...)
	elseif revealType == Const.RevealType.Result then
		self:RevealResult(...)
	elseif revealType == Const.RevealType.Effect then
		self:RevealEffect(...)
	elseif revealType == Const.RevealType.Switch then
		self:RevealSwitch(...)
	elseif revealType == Const.RevealType.Finish then
		self:RevealFinish(...)
	end
end

function RollView:OnNumerical(...)
	
end

function RollView:OnKeyEvent(...)
	local keyEvent = select(1, ...)
	if keyEvent == Const.KeyEvent.Click and Globals.gameModel.receive and (self.rollState == Const.ScrollType.Scroll or self.rollState == Const.ScrollType.Stop) then
		local msg = select(2, ...)
		if msg and msg.id == "Stop1" then
			LMessage:Dispatch(LuaEvent.SmallGame.StopRound, false, 1)
		elseif msg and msg.id == "Stop2" then
			LMessage:Dispatch(LuaEvent.SmallGame.StopRound, false, 2)
		elseif msg and msg.id == "Stop3" then
			LMessage:Dispatch(LuaEvent.SmallGame.StopRound, false, 3)
		elseif msg and msg.id == "Stop4" then
			LMessage:Dispatch(LuaEvent.SmallGame.StopRound, false, 4)
		elseif msg and msg.id == "Stop5" then
			LMessage:Dispatch(LuaEvent.SmallGame.StopRound, false, 5)
		end
	end
end

function RollView:OnGameEvent(msg)
	if msg.id == "GetJackpot" then
		local lotteryType = msg.jpType
		local lotteryId = msg.jpId
		local score = msg.score or 0
		--本地彩金
		if lotteryType == 1 then
			LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Effect, Const.EffectType.JackPot, score, nil, lotteryId)
		--中心彩金
		elseif lotteryType == 2 then
			lotteryId = 6 - lotteryId
			Globals.gameModel:AddLock()
			LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Effect, Const.EffectType.JackPot, score, function()
				Globals.gameModel:RemoveLock()
			end, lotteryId)
		end
	end
end

function RollView:OnUIEvent(msg)
	--重载上局数据
	if msg.id == "HideMessage" and msg.info == Globals.gameModel.rule then
		LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Scene, Const.RecallType.Get)
	end
end

--寻找深度最高的棋子
function RollView:FindDeepestItem(groupId)
	for _, item in ipairs(self.items) do
		if item.groupId == groupId and item:IsDeepest() then
			return item
		end
	end
end

--根据组号停止
function RollView:StopRoundByGroup(groupId, immediate)
	if self.deepests[groupId] then
		if immediate then
			--检查是否在回滚
			if self.deepests[groupId]:IsScrolling() then
				self.deepests[groupId]:SetDeepest(false)
				for _, v in ipairs(self.chesses[groupId]) do
					v:SetResult(false)
				end
			else
				return
			end
		else
			return
		end
	end
	
	if not self.chesses[groupId] then
		self.chesses[groupId] = {}
	end
	--设定棋子头部
	local chess = self:FindDeepestItem(groupId)
	if immediate then
		chess = chess.latter
	else
		chess = chess.previous
	end
	self.deepests[groupId] = chess
	chess:SetDeepest(true)
	--棋子赋值
	local matrix = self.oneRound.matrix[groupId]
	chess = chess.latter
	for i = 1, ConfigData.roll.rows do
		self.chesses[groupId][i] = chess
		chess:SetResult(matrix[i], immediate)
		chess = chess.latter
	end
	--棋子停止
	for _, item in ipairs(self.items) do
		if item.groupId == groupId then
			item:StopScroll()
		end
	end
	table.insert(self.stopIds, groupId)
end

--判断显示焦点框
function RollView:IsRevealFocus()
	local chesses = {}
	for column, chess in pairs(self.deepests) do
		if chess then
			table.insertto(chesses, self.oneRound.matrix[column])
		end
	end
	if table.hasNums(chesses, Const.ChessType.Scatter) >= ConfigData.awards.freeOnCount - 1 or
		table.hasNums(chesses, Const.ChessType.Bonus) >= ConfigData.awards.bonusOnCount - 1 or
		table.hasNums(chesses, Const.ChessType.Link) >= ConfigData.awards.linkOnCount - 1 then
		return true
	end
	
	return false
end

--中奖前场景变化
function RollView:RevealScene(...)
	LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Result)
end

--游戏结果
function RollView:RevealResult(...)
	self.oneRound:Calculate()
	local result = self.oneRound.result
	--没中奖
	if not result.winning then
		LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Effect, Const.EffectType.Normal, 0, callback(self, "CheckSwitch"))
	--中奖
	else
		self.shade:Show(_MaxNumber)
		--普通奖
		if result.arrays[Const.ResultType.Win] then
			local totalOdds = 0
			for _, lineClss in ipairs(result.arrays[Const.ResultType.Win]) do
				totalOdds = totalOdds + lineClss.odds
				for i = 1, #lineClss.chessPos do
					self.chesses[i][lineClss.chessPos[i]]:LoadFollower()
				end
			end
			LMessage:Dispatch(LuaEvent.Sound.Play, "chess_win", Const.ResultType.Win, result.arrays[Const.ResultType.Win], self.chesses)
			LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Effect, Const.EffectType.Normal, totalOdds, callback(self, "CheckSwitch"))
		--特殊奖
		else
			local specialType = Const.ResultType.Lose
			for i = Const.ResultType.Free, Const.ResultType.Link do
				if result.arrays[i] then
					specialType = i
					break
				end
			end
			if specialType > Const.ResultType.Lose then
				local totalOdds = 0
				for _, lineClss in ipairs(result.arrays[specialType]) do
					totalOdds = totalOdds + lineClss.odds
					for i = 1, #lineClss.chessPos do
						self.chesses[math.floor(lineClss.chessPos[i]/10)][lineClss.chessPos[i]%10]:LoadFollower()
					end
				end
				LMessage:Dispatch(LuaEvent.Sound.Play, "chess_win", specialType, result.arrays[specialType], self.chesses)
				LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Effect, Const.EffectType.Normal, totalOdds, callback(self, "CheckSwitch", specialType))
			else
				printerror("中奖结果类型未定义！")
				if _ErrorPause then
					ComUtils.SetTimeScale(0)
				end
			end
		end
	end
end

--赢分特效
function RollView:RevealEffect(...)
	
end

--切换场景
function RollView:RevealSwitch(...)
	LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Finish)
end

--表现结束
function RollView:RevealFinish(...)
	self.rollState = Const.ScrollType.Idle
end

--表现棋子动画
function RollView:RevealChess(chess, gameObject, ...)
	--todo 操作棋子中奖动画
	ComUtils.ResetAnim(gameObject)
end

--检查切换场景
function RollView:CheckSwitch(resultType)
	--免费场景->普通场景
	if Globals.gameModel.rule == Const.GameRule.Free and Globals.gameModel.remainGiveTime == 0 then
		LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Switch, Const.GameRule.Free, Const.GameRule.Normal)
	--普通场景->免费场景
	elseif resultType == Const.ResultType.Free then
		LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Switch, Const.GameRule.Normal, Const.GameRule.Free)
	--普通场景->小游戏场景
	elseif resultType == Const.ResultType.Bonus then
		LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Switch, Const.GameRule.Normal, Const.GameRule.Bonus)
	--普通场景->公共游戏场景
	elseif resultType == Const.ResultType.Link then
		LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Switch, Const.GameRule.Normal, Const.GameRule.Link)
	else
		LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Finish)
	end
end


return RollView