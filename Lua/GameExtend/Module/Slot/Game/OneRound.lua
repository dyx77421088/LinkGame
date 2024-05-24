--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:用来执行一局结果
--     创建时间:2023/09/20  
--------------------------------------------------------------------------------
local OneRound = require "GameLogic.Module.Slot.Game.OneRound"
local ConfigData = Globals.configMgr:GetConfig("SlotData")
OneRound = BaseClass("OneRoundEditor", OneRound)

--改变阵列
function OneRound:AlterMatrix()
	local wildData = self.algorithm.WildData
	
	-- 修改金币
	if wildData then
		local value
		for k, v in ipairs(wildData) do
			while (v > 0) do
				value = v % 10
				v = math.floor(v / 10)

				-- 在这个位置下有彩金，则设置为彩金
				if self:CheckJackpot(value, k) then self.matrix[k][value] = Const.ChessType.Jackpot
				else 
					self.matrix[k][value] = Const.ChessType.Wild
				end
			end
		end
	end
end
function OneRound:CheckJackpot(row, col)
	for _, value in ipairs(Globals.gameModel.jackpot) do
		if value[1] == row and value[2] == col then return true end
	end
	return false
end
--改变赔率
function OneRound:AlterOdds()
	if self.wildScale and #self.wildScale == 5 then
		local arrays = self.result.arrays[Const.ResultType.Win]
		if #arrays > 0 then
			self.result.totalOdds = 0
			for i = 1, #arrays do
				local scale = 0
				for k, v in ipairs(arrays[i].chessPos) do
					scale = scale + self.wildScale[k][v]
				end
				if scale > 1 then
					arrays[i].odds = arrays[i].odds * scale
				end
				self.result.totalOdds = self.result.totalOdds + arrays[i].odds
			end
		end
	end


	-- if Globals.gameModel.rule == Const.GameRule.Free then
	-- 	-- 更改免费的总赔率
	-- 	Globals.gameModel.roundOdds = Globals.gameModel.roundOdds + self.result.totalOdds
	-- else
	-- 	Globals.gameModel.roundOdds = self.result.totalOdds
	-- end
	
	-- 这tm的要自己统计scatter的个数，然后后面还需要添加到self.result.arrays[Const.ResultType.Free]数组里面（那个为金币的scatter就不用添加进来了，只要个数就可以了）
	local scatterPos = {}
	for k, v in ipairs(self.matrix) do
		for i = 1, #v do
			if not ConfigData.awards.freeOnLine and v[i] == Const.ChessType.Scatter then
				table.insert(scatterPos, k*10+i) --不依赖线坐标要绑定列, 这玩意要坐标是因为后面要跟着动，（wildscatter已经是动的了，所以不用加进来）
			end
		end
	end
	-- 免费线
	local scatterWildCount = Globals.gameModel.scatterWildCount or 0
	if #scatterPos + scatterWildCount >= ConfigData.awards.freeOnCount then
		if not self.result.arrays[Const.ResultType.Free] then self.result.arrays[Const.ResultType.Free] = {} end

		
		self.result.arrays[Const.ResultType.Free].chessPos = scatterPos
		self:AddGiveCount(#scatterPos + scatterWildCount)
	end
end
-- 增加免费次数
function OneRound:AddGiveCount(scatterCount)
	if not self.result.arrays then return end

	G_printerror("个数是+======================》", scatterCount)
	-- 根据游戏类型不同获得不同的免费次数
	local giveFreeCount = Globals.gameModel.rule == Const.GameRule.Free and ConfigData.awards.freeGiveFreeCount or ConfigData.awards.normalGiveFreeCount
	-- 最大个数不能超过givefreecount的长度， 最少为1个
	scatterCount = math.min(scatterCount < 1 and 1 or scatterCount, #giveFreeCount)
	-- 赔率
	self.result.arrays[Const.ResultType.Free].odds = ConfigData.chess.odds[Const.ChessType.Scatter][scatterCount]

	Globals.gameModel.giveFreeCount = giveFreeCount[scatterCount] -- 记录一下获得的免费次数(在免费到免费需要显示)
	-- 修改免费次数（免费场景下是 += ，普通场景就是直接赋值）
	if Globals.gameModel.rule == Const.GameRule.Free then
		Globals.gameModel.isFreeToFree = true -- 还是加个变量记录当前是从免费到免费的吧
		Globals.gameModel.totalGiveTime = Globals.gameModel.totalGiveTime + giveFreeCount[scatterCount]
		-- 当前次数不变
		Globals.gameModel.remainGiveTime = Globals.gameModel.remainGiveTime + giveFreeCount[scatterCount]
	else
		Globals.gameModel.isFreeToFree = false
		Globals.gameModel.totalGiveTime = giveFreeCount[scatterCount]
		Globals.gameModel.remainGiveTime = giveFreeCount[scatterCount]
		-- 进入免费游戏时候显示的免费次数，在免费游戏结束之后需要显示
		Globals.gameModel.normalGiveTime = Globals.gameModel.giveFreeCount
	end
end

--检查数据合法性
function OneRound:AlgorithmValid(data)
	if not data then
		printerror("获取游戏结果为空")
		if _ErrorPause then
			ComUtils.SetTimeScale(0) -- 暂停
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
	elseif data.OpenType == Const.OpenType.Give then
		if Globals.gameModel.rule ~= Const.GameRule.Free then
			printerror("非免费玩法不能有赠送局！")
			if _ErrorPause then
				ComUtils.SetTimeScale(0)
			end
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
	end
end
return OneRound