--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:用来计算单条中奖线
--     创建时间:2023/09/20  
--------------------------------------------------------------------------------
local OneLine = BaseClass("OneLine")
local ConfigData = Globals.configMgr and Globals.configMgr:GetConfig("SlotData")

function OneLine:__defaultVar()
	return {
		lineId = 0,
		resultType = Const.ResultType.Lose,
		odds = 0,
		chessType = 0,
		chessPos = {},
	}
end

function OneLine:CheckInLine(lineId, matrix, line, chessOdds)
	local index = 1
	local pos = line[index]
	local chess = matrix[index][pos]
	local wildOdds = 0
	local wildPos = {}
	self.lineId = lineId
	self.chessType = chess
	table.insert(self.chessPos, pos)
	table.insert(wildPos, pos)
	for index = 2, #line do
		pos = line[index]
		chess = matrix[index][pos]
		if self.chessType > Const.ChessType.Wild then
			if chess == self.chessType then
				table.insert(self.chessPos, pos)
			else
				break
			end
		elseif self.chessType == Const.ChessType.Wild then
			if chess == self.chessType then
				table.insert(self.chessPos, pos)
				table.insert(wildPos, pos)
				wildOdds = chessOdds[Const.ChessType.Wild][#wildPos]
			elseif chess < Const.ChessType.Wild then
				self.chessType = chess
				table.insert(self.chessPos, pos)
			else
				break
			end
		elseif chess == self.chessType or chess == Const.ChessType.Wild then
			table.insert(self.chessPos, pos)
		else
			break
		end
	end
	local chessNum = #self.chessPos
	if self.chessType == Const.ChessType.Scatter and ConfigData.awards.freeOnLine and ConfigData.awards.freeOnCount <= chessNum then
		self.resultType = Const.ResultType.Free
		self.odds = chessOdds[self.chessType][chessNum]
	elseif self.chessType == Const.ChessType.Bonus and ConfigData.awards.bonusOnLine and ConfigData.awards.bonusOnCount <= chessNum then
		self.resultType = Const.ResultType.Bonus
		self.odds = chessOdds[self.chessType][chessNum]
	elseif self.chessType == Const.ChessType.Link and ConfigData.awards.linkOnLine and ConfigData.awards.linkOnCount <= chessNum then
		self.resultType = Const.ResultType.Link
		self.odds = chessOdds[self.chessType][chessNum]
	else
		local odds = chessOdds[self.chessType][chessNum]
		if wildOdds > odds and wildOdds > 0 then
			self.resultType = Const.ResultType.Win
			self.odds = wildOdds
			self.chessPos = wildPos
		elseif odds >= wildOdds and odds > 0 then
			self.resultType = Const.ResultType.Win
			self.odds = odds
		end
	end
end

function OneLine:CheckOutLine(matrix, chessOdds)
	if ConfigData.awards.freeOnLine and ConfigData.awards.bonusOnLine and ConfigData.awards.linkOnLine then
		return
	end
	
	local scatterPos, bonusPos, linkPos = {}, {}, {}
	for k, v in ipairs(matrix) do
		for i = 1, #v do
			if not ConfigData.awards.freeOnLine and v[i] == Const.ChessType.Scatter then
				table.insert(scatterPos, k*10+i) --不依赖线坐标要绑定列
			end
			if not ConfigData.awards.bonusOnLine and v[i] == Const.ChessType.Bonus then
				table.insert(bonusPos, k*10+i)
			end
			if not ConfigData.awards.linkOnLine and v[i] == Const.ChessType.Link then
				table.insert(linkPos, k*10+i)
			end
		end
	end
	local chessNum = #scatterPos
	if chessNum >= ConfigData.awards.freeOnCount then
		self.resultType = Const.ResultType.Free
		self.odds = chessOdds[Const.ChessType.Scatter][chessNum]
		self.chessPos = scatterPos
		return
	end
	chessNum = #bonusPos
	if chessNum >= ConfigData.awards.bonusOnCount then
		self.resultType = Const.ResultType.Bonus
		self.odds = chessOdds[Const.ChessType.Bonus][chessNum]
		self.chessPos = bonusPos
		return
	end
	chessNum = #linkPos
	if chessNum >= ConfigData.awards.linkOnCount then
		self.resultType = Const.ResultType.Link
		self.odds = chessOdds[Const.ChessType.Link][chessNum]
		self.chessPos = linkPos
	end
end

return OneLine