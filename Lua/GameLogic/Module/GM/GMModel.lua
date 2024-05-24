--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:用来的作为调试阶段用
--     创建时间:2022/04/21 
--------------------------------------------------------------------------------
local GMModel = Singleton("GMModel")


function GMModel:__defaultVar()
	return {
		playScore = 0,
		winScore = 0,
	}
end

function GMModel:AddPlayOdds(odds)
	if not Globals.gameModel.platformArg.bDebugMode then
		return
	end
	
	self.playScore = self.playScore + math.reduce(Globals.gameModel.playBet * odds, 100)
end

function GMModel:AddPlayScore(score)
	if not Globals.gameModel.platformArg.bDebugMode then
		return
	end
	
	self.playScore = self.playScore + score
end

function GMModel:AddWinOdds(odds)
	if not Globals.gameModel.platformArg.bDebugMode then
		return
	end
	
	self.winScore = self.winScore + math.reduce(Globals.gameModel.playBet * odds, 100)
end

function GMModel:AddWinScore(score)
	if not Globals.gameModel.platformArg.bDebugMode then
		return
	end
	
	self.winScore = self.winScore + score
end


return GMModel