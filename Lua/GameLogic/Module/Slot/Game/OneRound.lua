--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:用来执行一局结果
--     创建时间:2023/09/20  
--------------------------------------------------------------------------------
local OneRound = BaseClass("OneRound")
local ClassData = Globals.configMgr:GetConfig("ClassData")
local OneLine = require (ClassData.OneLine)


Const.OpenType = {
	Normal = 0, --普通开奖
	Give = 1, --赠送开奖
}

Const.ResultType = {
	Lose = 0, --输
	Win = 1, --赢
	Free = 2, --免费奖
	Bonus = 3, --彩金奖
	Link = 4, --公共奖
}

Const.RoundState = {
	Get = 0, --获取结果   
	Complete = 1, --显示结果
	Calculate = 2, --计算结果
	End = 3, --本局结束
}


function OneRound:__ctor(rows, columns, lines, chessOdds)
	self.rows = rows
	self.columns = columns
	self.lines = lines
	self.chessOdds = chessOdds
	self.result = {}
end

--获取到结果
function OneRound:SetResult(data)
	self:AlgorithmValid(data)
	
	self.algorithm = data
	self.resultType = data.ResultType
	self.openType = data.OpenType
	self.lotteryId = data.LotteryId or 0
	self.baseBet = data.TotalBet or 0
	self.freeBet = data.TotalFreeBet or 0
	self.bonusBet = data.BonusBet or 0
	self.linkBet = data.LinkBet or 0
	self:ProcessResult(data.Matrix)
end

--重载到结果
function OneRound:ReloadResult(msg)
	if not msg or not msg.gameId or msg.gameId ~= Globals.gameModel.platformArg.gameId then
		return
	end
	
	--获取结果(仅Skill才会)
	if msg.state == Const.RoundState.Get then
		self.algorithm = msg.gameResult
	--显示结果
	elseif msg.state == Const.RoundState.Complete then
		self.algorithm = msg.lastRound and msg.lastRound.gameResult or msg.gameResult
		local message = "Unexpected exit!"
		if Globals.gameModel.rule == Const.GameRule.Free then
			message = LanguageUtils.Translate("意外退出！ 继续免费奖。剩余: %d 次，总: %d 次。", Globals.gameModel.remainGiveTime, Globals.gameModel.totalGiveTime)
		elseif Globals.gameModel.rule == Const.GameRule.Bonus then
			message = LanguageUtils.Translate("意外退出！ 继续彩金奖。")
		elseif Globals.gameModel.rule == Const.GameRule.Link then
			message = LanguageUtils.Translate("意外退出！ 继续幸运奖。")
		end
		Globals.pipeMgr:Send(EEvent.PipeMsg.UIEvent, {id = "ShowMessage", msg = message, info = Globals.gameModel.rule})
	--上局已结束
	else
		self.algorithm = msg.gameResult
	end
	
	self.state = msg.state
	self.resultType = msg.resultType
	self.lotteryId = msg.gameResult.LotteryId or 0
	self.freeBet = msg.gameResult.TotalFreeBet or 0
	self.bonusBet = msg.gameResult.BonusBet or 0
	self.linkBet = msg.gameResult.LinkBet or 0
	self.freeOdds = msg.curBet
	self.openType = self.algorithm.OpenType
	self.baseBet = self.algorithm.TotalBet or 0
	self.lastRound = msg.lastRound and msg.lastRound.gameResult or msg.gameResult
	
	self:ProcessResult(self.algorithm.Matrix)
end

--转换阵列,由【左-右,下-上】转换【下-上,左-右】
function OneRound:ProcessResult(matrix)
	self.matrix = {}
	for i = 1, self.columns do
		if not self.matrix[i] then
			self.matrix[i] = {}
		end
		for m = 1, self.rows do
			self.matrix[i][m] = matrix[(m-1)*self.columns+i] + 1
		end
	end
end

--检查数据合法性
function OneRound:AlgorithmValid(data)
	if not data then
		printerror("获取游戏结果为空")
		if _ErrorPause then
			ComUtils.SetTimeScale(0)
		end
		return
	end
	
	--按开奖类型检查
	if data.OpenType == Const.OpenType.Normal then
		if Globals.gameModel.remainGiveTime > 0 then
			printerror("赠送局还未完成！")
			if _ErrorPause then
				ComUtils.SetTimeScale(0)
			end
		end
		Globals.gameModel.roundOdds = (data.TotalBet or 0) + (data.TotalFreeBet or 0) + (data.BonusBet or 0) + (data.LinkBet or 0)
		Globals.gmModel:AddWinOdds(Globals.gameModel.roundOdds)
	elseif data.OpenType == Const.OpenType.Give then
		if Globals.gameModel.rule ~= Const.GameRule.Free then
			printerror("非免费玩法不能有赠送局！")
			if _ErrorPause then
				ComUtils.SetTimeScale(0)
			end
		end
		--因玩法不同,会增加免费次数
		Globals.gameModel.totalGiveTime = Globals.gameModel.totalGiveTime + (data.AddFreeTime or 0)
		Globals.gameModel.remainGiveTime = Globals.gameModel.remainGiveTime + (data.AddFreeTime or 0)
		self.freeOdds = self.freeOdds + (data.TotalBet or 0)
		if Globals.gameModel.remainGiveTime == 0 then
			Globals.pipeMgr:Send(EEvent.PipeMsg.EndRound, {gameId = Globals.gameModel.platformArg.gameId})
		end
	end
	
	--按结果类型检查
	if data.ResultType == Const.ResultType.Free then
		if Globals.gameModel.rule ~= Const.GameRule.Normal then
			printerror("非普通玩法不能进入免费游戏！")
			if _ErrorPause then
				ComUtils.SetTimeScale(0)
			end
		end
		Globals.gameModel.totalGiveTime = data.ShowFreeTime or (data.TotalFreeTime or 0)
		Globals.gameModel.remainGiveTime = data.ShowFreeTime or (data.TotalFreeTime or 0)
		self.freeOdds = data.TotalBet
	elseif data.ResultType == Const.ResultType.Bonus then
		if Globals.gameModel.rule ~= Const.GameRule.Normal then
			printerror("非普通玩法不能进入小游戏！")
			if _ErrorPause then
				ComUtils.SetTimeScale(0)
			end
		end
	elseif data.ResultType == Const.ResultType.Link then
		if Globals.gameModel.rule ~= Const.GameRule.Normal then
			printerror("非普通玩法不能进入公共游戏！")
			if _ErrorPause then
				ComUtils.SetTimeScale(0)
			end
		end
	end
	
	--发送收取到结果
	if (data.ResultType <= Const.ResultType.Win or data.ResultType == Const.ResultType.Bonus) and data.OpenType == Const.OpenType.Normal then
		Globals.pipeMgr:Send(EEvent.PipeMsg.EndRound, {gameId = Globals.gameModel.platformArg.gameId})
	end
end

--计算结果
function OneRound:Calculate()
	--更改阵列
	self:AlterMatrix()
	
	--依赖中奖线
	self.result.totalOdds = 0
	self.result.winning = false
	self.result.arrays = false
	for i = 1, #self.lines do
		local oneLine = OneLine.New()
		oneLine:CheckInLine(i, self.matrix, self.lines[i], self.chessOdds)
		if oneLine.resultType >= Const.ResultType.Win then
			if not self.result.arrays then
				self.result.arrays = {}
			end
			table.insert(self.result.arrays, oneLine)
			self.result.winning = true
			self.result.totalOdds = self.result.totalOdds + oneLine.odds
		end
	end
	--不依赖中奖线
	local oneLine = OneLine.New()
	oneLine:CheckOutLine(self.matrix, self.chessOdds)
	if oneLine.resultType > Const.ResultType.Win then
		if not self.result.arrays then
			self.result.arrays = {}
		end
		table.insert(self.result.arrays, oneLine)
		self.result.winning = true
		self.result.totalOdds = self.result.totalOdds + oneLine.odds
	end
	
	--整理中奖线
	if self.result.arrays then
		local arrays = {}
		for k, v in ipairs(self.result.arrays) do
			if not arrays[v.resultType] then
				arrays[v.resultType] = {}
			end
			table.insert(arrays[v.resultType], v)
		end
		self.result.arrays = arrays
	end
	
	--更改赔率
	self:AlterOdds()
	
	--核对算法
	if not Globals.gameModel.platformArg.bLocalMode then
		if self.result.totalOdds ~= self.baseBet then
			printerror(string.format("赔率出错! 前端赔率: %d, 算法赔率: %d", self.result.totalOdds, self.baseBet))
			if _ErrorPause then
				ComUtils.SetTimeScale(0)
			end
		end
		if Globals.gameModel.rule == Const.GameRule.Free and Globals.gameModel.remainGiveTime == 0 and self.freeOdds ~= Globals.gameModel.roundOdds then
			printerror(string.format("免费总赔率出错! 前端赔率: %d, 算法赔率: %d", self.freeOdds, Globals.gameModel.roundOdds))
			if _ErrorPause then
				ComUtils.SetTimeScale(0)
			end
		end
	end
end

--改变阵列
function OneRound:AlterMatrix()
	--todo 阵列因玩法不同会变动
	
end

--改变赔率
function OneRound:AlterOdds()
	--todo 赔率因玩法不同会变动
	
end

function OneRound:GetAlgorithm()
	return self.algorithm
end

function OneRound:GetLastRound()
	return self.lastRound
end


return OneRound