--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:音效控制模块，处理音效播放逻辑
--     创建时间:2024/01/20 
--------------------------------------------------------------------------------
local SoundController = Singleton("SoundController")


function SoundController:__ctor()

end

function SoundController:__delete()
	LMessage:UnRegister(LuaEvent.SmallGame.Prepare, self.onPrepare)
	LMessage:UnRegister(LuaEvent.SmallGame.OneRound, self.onOneRound)
	LMessage:UnRegister(LuaEvent.SmallGame.FinishRound, self.onFinishRound)
	LMessage:UnRegister(LuaEvent.SmallGame.Reveal, self.onReveal)
	LMessage:UnRegister(LuaEvent.Sound.Play, self.onPlay)
	LMessage:UnRegister(LuaEvent.Sound.Pause, self.onPause)
	LMessage:UnRegister(LuaEvent.Sound.Stop, self.onStop)
end

function SoundController:Initialize()
	--逻辑事件
	self.onPrepare = LMessage:Register(LuaEvent.SmallGame.Prepare, "OnPrepare", self)
	self.onOneRound = LMessage:Register(LuaEvent.SmallGame.OneRound, "OnOneRound", self)
	self.onFinishRound = LMessage:Register(LuaEvent.SmallGame.FinishRound, "OnFinishRound", self)
	self.onReveal = LMessage:Register(LuaEvent.SmallGame.Reveal, "OnReveal", self)
	--音效事件
	self.onPlay = LMessage:Register(LuaEvent.Sound.Play, "OnPlay", self)
	self.onPause = LMessage:Register(LuaEvent.Sound.Pause, "OnPause", self)
	self.onStop = LMessage:Register(LuaEvent.Sound.Stop, "OnStop", self)
end

--进入游戏音效
function SoundController:OnPrepare(msg)
	Globals.soundMgr:PlayMusic(Const.SoundType.Music_Normal)
end

--滚轮开始音效
function SoundController:OnOneRound()
	G_printerror("开始一句后播放滚动音效")
	Globals.soundMgr:PlayEffect(Const.SoundType.Scroll_BGM)
end

--滚轮结束音效
function SoundController:OnFinishRound(immediate, ...)
	if immediate then
		Globals.soundMgr:StopEffect(Const.SoundType.Scroll_BGM)
	end
end

--表现音效
function SoundController:OnReveal(revealType, ...)
	if revealType == Const.RevealType.Finish then
		if Globals.gameModel.rule == Const.GameRule.Normal then
			Globals.soundMgr:FadeMusic(Const.SoundType.Music_Normal.volume)
		elseif Globals.gameModel.rule == Const.GameRule.Free then
			Globals.soundMgr:FadeMusic(Const.SoundType.Music_Free.volume)
		elseif Globals.gameModel.rule == Const.GameRule.Bonus then
			Globals.soundMgr:FadeMusic(Const.SoundType.Music_Bonus.volume)
		elseif Globals.gameModel.rule == Const.GameRule.Link then
			Globals.soundMgr:FadeMusic(Const.SoundType.Music_Link.volume)
		end
	end
end

function SoundController:OnPlay(...)
	local id = select(1, ...)
	--棋子下落音效
	if id == "chess_down" then
		local matrix = select(2, ...)
		local playing = false
		for _, v in ipairs(matrix) do
			if Const.SoundType["Scroll_Down_"..v] then
				playing = true
				Globals.soundMgr:PlayEffect(Const.SoundType["Scroll_Down_"..v])
			end
		end
		if not playing then
			Globals.soundMgr:PlayEffect(Const.SoundType.Scroll_Down)
		end
	--棋子中奖音效
	elseif id == "chess_win" then
		local resultType = select(2, ...)
		local lines = select(3, ...)
		local chesses = select(4, ...)
		local chessId = 0
		local chessVal = 0
		local playing = false
		if resultType == Const.ResultType.Win then
			for _, lineClss in ipairs(lines) do
				for i = 1, #lineClss.chessPos do
					chessVal = chesses[i][lineClss.chessPos[i]].value
					if chessVal > chessId then
						chessId = chessVal
					end
				end
			end
		else
			for _, lineClss in ipairs(lines) do
				for i = 1, #lineClss.chessPos do
					chessVal = chesses[math.floor(lineClss.chessPos[i]/10)][lineClss.chessPos[i]%10].value
					if chessVal > chessId then
						chessId = chessVal
					end
				end
			end
		end
		while chessId > 0 do
			if Const.SoundType["Scroll_Win_"..chessId] then
				playing = true
				Globals.soundMgr:PlayEffect(Const.SoundType["Scroll_Win_"..chessId])
				break
			end
			chessId = chessId - 1
		end
		if not playing then
			Globals.soundMgr:PlayEffect(Const.SoundType.Scroll_Win)
		end
	--焦点框音效
	elseif id == "scroll_focus" then
		local program = select(2, ...)
		if program == 1 then
			Globals.soundMgr:PlayEffect(Const.SoundType.Scroll_Focus_On)
		elseif program == 2 then
			Globals.soundMgr:PlayEffect(Const.SoundType.Scroll_Focus_Move)
		elseif program == 3 then
			Globals.soundMgr:PlayEffect(Const.SoundType.Scroll_Focus_Off)
		end
	--普通WIN音效
	elseif id == "effect_win" then
		local odds = select(2, ...)
		local ConfigData = Globals.configMgr:GetConfig("SlotData")
		local oddsScale = odds / 100
		local effectId = 0
		for i = #ConfigData.winPoints, 1, -1 do
			if oddsScale >= ConfigData.winPoints[i] then
				effectId = i
				break
			end
		end
		if Const.SoundType["Effect_Win_"..effectId] then
			Globals.soundMgr:PlayEffect(Const.SoundType["Effect_Win_"..effectId])
		else
			Globals.soundMgr:PlayEffect(Const.SoundType.Effect_Win)
		end
	--BIGWIN音效
	elseif id == "bigwin" then
		local program = select(2, ...)
		if program == 1 then
			Globals.soundMgr:PlayMusic(Const.SoundType.Music_BigWin)
		elseif program == 2 then
			Globals.soundMgr:PlayEffect(Const.SoundType.BigWin_On)
			Globals.soundMgr:PlayEffect(Const.SoundType.BigWin_Number_On)
		elseif program == 3 then
			Globals.soundMgr:PlayEffect(Const.SoundType.BigWin_Number_Off)
		elseif program == 4 then
			Globals.soundMgr:PlayEffect(Const.SoundType.BigWin_Off)
			if Globals.gameModel.rule == Const.GameRule.Normal then
				Globals.soundMgr:PlayMusic(Const.SoundType.Music_Normal)
			elseif Globals.gameModel.rule == Const.GameRule.Free then
				Globals.soundMgr:PlayMusic(Const.SoundType.Music_Free)
			elseif Globals.gameModel.rule == Const.GameRule.Bonus then
				Globals.soundMgr:PlayMusic(Const.SoundType.Music_Bonus)
			elseif Globals.gameModel.rule == Const.GameRule.Link then
				Globals.soundMgr:PlayMusic(Const.SoundType.Music_Link)
			end
		end
	--彩金音效
	elseif id == "jackpot" then
		Globals.soundMgr:PlayEffect(Const.SoundType.Effect_Win_2)
	--过渡音效
	elseif id == "transition" then
		local rule = select(2, ...)
		local program = select(3, ...)
		if rule == Const.GameRule.Normal then
			if program == 4 then
				Globals.soundMgr:StopMusic()
				Globals.soundMgr:PlayEffect(Const.SoundType.Transition_Free_On)
			end
		elseif rule == Const.GameRule.Free then
			if program == 1 then
				Globals.soundMgr:PlayEffect(Const.SoundType.Transition_Free_Tip_On)
			elseif program == 2 then
				Globals.soundMgr:PlayEffect(Const.SoundType.Transition_Free_Tip_Number)
			elseif program == 3 then
				Globals.soundMgr:PlayEffect(Const.SoundType.Transition_Free_Tip_Off)
			elseif program == 4 then
				Globals.soundMgr:StopMusic()
				Globals.soundMgr:PlayEffect(Const.SoundType.Transition_Free_On)
			elseif program == 5 then
				Globals.soundMgr:PlayMusic(Const.SoundType.Music_Free)
			end
		elseif rule == Const.GameRule.Bonus then
			if program == 1 then
				Globals.soundMgr:StopMusic()
				Globals.soundMgr:PlayEffect(Const.SoundType.Transition_Bonus_On)
			else
				Globals.soundMgr:PlayMusic(Const.SoundType.Music_Bonus)
			end
		elseif rule == Const.GameRule.Link then
			if program == 1 then
				Globals.soundMgr:StopMusic()
				Globals.soundMgr:PlayEffect(Const.SoundType.Transition_Link_On)
			else
				Globals.soundMgr:PlayMusic(Const.SoundType.Music_Link)
			end
		end
	--金币音效
	elseif id == "effect_coin" then
		local program = select(2, ...)
		if program == 1 then
			Globals.soundMgr:PlayEffect(Const.SoundType.Effect_Coin_On)
		elseif program == 2 then
			Globals.soundMgr:PlayEffect(Const.SoundType.Effect_Coin_Rotate)
		elseif program == 3 then
			Globals.soundMgr:StopEffect(Const.SoundType.Effect_Coin_Rotate)
			Globals.soundMgr:PlayEffect(Const.SoundType.Effect_Coin_Off)
		end
	--轮盘音效
	elseif id == "effect_wheel" then
		local program = select(2, ...)
		if program == 1 then
			Globals.soundMgr:PlayEffect(Const.SoundType.Effect_Wheel_On)
		elseif program == 2 then
			Globals.soundMgr:PlayEffect(Const.SoundType.Effect_Wheel_Rotate)
		elseif program == 3 then
			Globals.soundMgr:PlayEffect(Const.SoundType.Effect_Wheel_Win)
		elseif program == 4 then
			Globals.soundMgr:PlayEffect(Const.SoundType.Effect_Wheel_Off)
		end
	end
end

function SoundController:OnStop(...)
	
end

function SoundController:OnPause(...)
	
end


return SoundController