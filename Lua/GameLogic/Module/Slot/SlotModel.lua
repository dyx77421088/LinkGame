--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:Slot主游戏界面Model，用来处理数据
--     创建时间:2023/02/08 
--------------------------------------------------------------------------------
local json = require "cjson"
local util = require "cjson.util"
local SlotModel = Singleton("SlotModel")
local Denom = {1, 2, 5, 10, 100}
local PlayBetArray = {25, 50, 75, 100, 150, 200, 250, 300, 350, 400, 450, 500}

Const.GameState = {
	None = 0,
	Idle = 1,
	Play = 2,
	Reveal = 3,
}

Const.GameRule = {
	None = 0,
	Normal = 1,
	Free = 2,
	Bonus = 3,
	Link = 4,
}

function SlotModel:__defaultVar()
	return {
		platformArg = {}, --大厅传参
		gameBet = {}, --押注配置
		gameName = "", --游戏名称
		coverNum = 0, --遮挡住主界面的元素数目
		credit = 0, --玩家分数
		slot = 0, --分值比
		playBet = 0, --押注
		win = 0, --赢分
		roundOdds = 0, --每局总赔率
		totalGiveTime = 0, --总计赠送次数
		remainGiveTime = 0, --剩余赠送次数
		state = Const.GameState.None, --游戏状态
		rule = Const.GameRule.None, --游戏玩法
		receive = false, --接收结果
		locks = 0, --锁
		autoGame = false, --自动游戏
		roundCnt = 0, --局数
		exitTimer = 0, --退出计时器
	}
end

function SlotModel:__ctor()
	self:LoadPlatformArg()
	self:InitPlayData()
end

--平台配置
function SlotModel:LoadPlatformArg()
	local smallGameStartArg = GlobalShare.smallGameStartArg
    GlobalShare.smallGameStartArg = ""
    if smallGameStartArg ~= "" then
        local data = json.decode(smallGameStartArg)
		self.platformArg.gameId = data.gameId
		self.platformArg.multiplier = data.multiplier or 0.01
		self.platformArg.decimal = data.decimal or 2
		self.platformArg.defaultBet = data.defaultBet
		self.platformArg.minPlayBet = data.minPlayBet
		self.platformArg.maxPlayBet = data.maxPlayBet
		self.platformArg.playBet = data.playBet or false
		self.platformArg.slot = data.slot or false
		self.platformArg.bReproduct = data.bReproduct or false
		self.platformArg.bLocalMode = data.bReproduct or data.bLocalMode
		self.platformArg.bDebugMode = data.bDebugMode or false
		self.platformArg.bLocked = data.bLocked or false
		self.platformArg.bDollar = data.bDollar or false
		self.platformArg.bPreview = data.bPreview or false
		self.platformArg.bHallLoading = data.bHallLoading or false
		self.platformArg.soundParam = data.soundParam or G_EmptyTable
		self.platformArg.skillGame = data.skillGame or 0
	else
		self.platformArg.multiplier = 0.01
		self.platformArg.decimal = 2
		self.platformArg.defaultBet = PlayBetArray[1]
		self.platformArg.minPlayBet = PlayBetArray[1]
		self.platformArg.maxPlayBet = PlayBetArray[#PlayBetArray]
		self.platformArg.bReproduct = false
		self.platformArg.bLocalMode = true
		self.platformArg.bDebugMode = true
		self.platformArg.bLocked = false
		self.platformArg.bDollar = true
		self.platformArg.bPreview = true
		self.platformArg.bHallLoading = false
		self.platformArg.soundParam = G_EmptyTable
		self.platformArg.skillGame = 0
    end
end

function SlotModel:InitPlayData()
	self.gameBet.betArray = {}
	self.gameBet.initArray = {}
	
	local betArray = {}
	for k, v in ipairs(PlayBetArray) do
		if v >= self.platformArg.minPlayBet and v <= self.platformArg.maxPlayBet then
			table.insert(betArray, v)
		end
	end
	if self.platformArg.bDollar then
		for i = 1, #Denom do
			local array = {}
			for k, v in ipairs(betArray) do
				if v % Denom[i] == 0 then
					table.insert(array, v)
				end
			end
			self.gameBet.betArray[i] = array
			if #array > 0 then
				self.gameBet.initArray[i] = array[1]
			end
		end
	else
		self.gameBet.betArray[1] = betArray
		self.gameBet.initArray[1] = self.platformArg.defaultBet
	end
	
	if self.platformArg.slot and self.platformArg.playBet then
		self:SetPlayBet(self.platformArg.playBet, self.platformArg.slot)
	else
		self:SetSlot(1)
	end
end
--增加遮挡的ui层数
function SlotModel:IncreaseCover()
    self.coverNum = self.coverNum + 1
end

--减少遮挡的ui层数
function SlotModel:DecreaseCover()
    self.coverNum = self.coverNum - 1
end

--判断是否有ui元素挡在GameView上
function SlotModel:HasCoverObject()
    return self.coverNum > 0
end

function SlotModel:GameInfo(msg)
	--获取分数
	if msg.credit then
		self.credit = msg.credit
		LMessage:Dispatch(LuaEvent.SmallGame.Numerical, "Credit", msg.effect)
	end
	--修改分数
	if msg.score then
		self.credit = self.credit + msg.score
		LMessage:Dispatch(LuaEvent.SmallGame.Numerical, "Credit", msg.effect)
	end
	--彩金信息
	if msg.jackpot then
		self.jackpot.minLocal = msg.jackpot.minLocal or self.jackpot.minLocal
		self.jackpot.minLink = msg.jackpot.minLink or self.jackpot.minLink
	end
end

function SlotModel:GameEvent(msg)
	--锁
	if msg.id == "Lock" then
		self.platformArg.bLocked = msg.value == 1
	--退出游戏
	elseif msg.id == "QuitGame" then
		LMessage:Dispatch(LuaEvent.Common.GameQuit, Const.QuitReason.Client, "退出演示")
	end
end

function SlotModel:KeyEvent(msg)
	--最大押注
	if msg.id == "MaxPlayBet" then
		if self.state == Const.GameState.Idle and self.rule == Const.GameRule.Normal and not self:IsLocked() then
			self:SetPlayBet(self.platformArg.maxPlayBet)
		end
	--说明书
	elseif msg.id == "Introduce" then
		if not Globals.uiMgr:IsViewPop("IntroduceView") then
			Globals.uiMgr:OpenView("IntroduceView")
		end
	--返回游戏
	elseif msg.id == "Stop2" then
		if Globals.uiMgr:IsViewPop("IntroduceView") then
			Globals.uiMgr:HideView("IntroduceView")
		end
		if Globals.uiMgr:IsViewPop("DenomView") then
			Globals.uiMgr:HideView("DenomView")
		end
		if Globals.uiMgr:IsViewPop("PreviewerView") then
			Globals.uiMgr:HideView("PreviewerView")
		end
	--面额选择
	elseif msg.id == "Stop3" then
		if self.state == Const.GameState.Idle and self.rule == Const.GameRule.Normal then
			Globals.uiMgr:OpenView("DenomView")
		end
	--押分切换
	elseif msg.id == "Stop5" then
		if self.state == Const.GameState.Idle and self.rule == Const.GameRule.Normal and not self:IsLocked() then
			Globals.gameModel:SetNextBet()
		end
	end
end

function SlotModel:Setting(msg)
	--音量设置
	if msg.id == "Volume" then
		if self.platformArg.soundParam == G_EmptyTable then
			self.platformArg.soundParam = {}
		end
		self.platformArg.soundParam.platMusic = msg.platMusic
		self.platformArg.soundParam.platEffect = msg.platEffect
		Globals.soundMgr:UpdateVolume()
	--调试按钮
	elseif msg.id == "GM" then
		if not msg.value then
			Globals.uiMgr:HideView("GMView")
		elseif msg.value and self.platformArg.bDebugMode then
			Globals.uiMgr:OpenView("GMView")
		end
	--屏幕旋转
	elseif msg.id == "FlipScreen" then
		self.platformArg.flipAngle = msg.value
	end
end

function SlotModel:Prepare(msg)
	self.credit = msg.credit or 0
	self.jackpot = msg.jackpot or {minLocal = 25, minLink = 75}
	if msg and msg.gameId and msg.gameId == self.platformArg.gameId then
		self.win = 0
		self:SetPlayBet(msg.playBet, msg.slot)
		self:AddWinOdds(msg.curBet)
		--获取结果(仅Skill才会)
		if msg.state == Const.RoundState.Get then
			self.rule = msg.resultType
			self.state = Const.GameState.Play
		--显示结果
		elseif msg.state == Const.RoundState.Complete then
			self.rule = msg.resultType
			self.state = Const.GameState.None
		--上局已结束
		else
			self.rule = Const.GameRule.Normal
			self.state = Const.GameState.Idle
			Globals.pipeMgr:Send(EEvent.PipeMsg.GameInfo, {state = true, ready = true, normal = true})
		end
		self.roundOdds = msg.totalBet
		self.totalGiveTime = msg.showTime + msg.freeIndex
		self.remainGiveTime = msg.showTime
	else
		self.rule = Const.GameRule.Normal
		self.state = Const.GameState.Idle
		Globals.pipeMgr:Send(EEvent.PipeMsg.GameInfo, {state = true, ready = true, normal = true})
	end
	
	LMessage:Dispatch(LuaEvent.SmallGame.Numerical)
end

function SlotModel:StartRound()
	if self:IsLocked() or self.state ~= Const.GameState.Idle or (self.remainGiveTime <= 0 and self.credit <= 0) then
		return
	end
	LMessage:Dispatch(LuaEvent.SmallGame.OneRound)
end

function SlotModel:OneRound()
	if self.state ~= Const.GameState.Idle then
		return
	end
	
	self.state = Const.GameState.Play
	self.receive = false
	local openType = self.remainGiveTime > 0 and Const.OpenType.Give or Const.OpenType.Normal
	if openType == Const.OpenType.Normal then
		self.win = 0
		self.roundCnt = self.roundCnt + 1
		self:CheckPlayBet()
		LMessage:Dispatch(LuaEvent.SmallGame.Numerical, "Win")
		Globals.gmModel:AddPlayScore(self.playBet)
	else
		self.remainGiveTime = self.remainGiveTime - 1
		LMessage:Dispatch(LuaEvent.SmallGame.Numerical, "FreeTime")
	end
	local msg = {gameId = self.platformArg.gameId, playBet = self.playBet, slot = self.slot, openType = openType}
	Globals.pipeMgr:Send(EEvent.PipeMsg.OneRound, msg)
	Globals.pipeMgr:Send(EEvent.PipeMsg.GameInfo, {state = true, ready = false})
end

function SlotModel:BetResult(msg)
	self.receive = true
end

function SlotModel:FinishRound(immediate, column)
	if immediate then
		self.state = Const.GameState.Reveal
	end
end

function SlotModel:Reveal(revealType, ...)
	if revealType == Const.RevealType.Switch then
		local oldRule = select(1, ...)
		local newRule = select(2, ...)
		if self.rule == oldRule then
			self.rule = newRule
			if oldRule == Const.GameRule.Free and newRule == Const.GameRule.Normal then
				self.totalGiveTime = 0
			end
		end
		Globals.pipeMgr:Send(EEvent.PipeMsg.GameInfo, {state = true, normal = newRule == Const.GameRule.Normal})
	elseif revealType == Const.RevealType.Finish then
		self.state = Const.GameState.Idle
		if self.rule == Const.GameRule.Normal then
			Globals.pipeMgr:Send(EEvent.PipeMsg.GameInfo, {credit = true, win = self.win, effect = self.win > 0})
			if self.win < self.playBet and self.platformArg.skillGame > 0 then
				Globals.uiMgr:OpenView("SkillView")
			end
		end
		Globals.pipeMgr:Send(EEvent.PipeMsg.GameInfo, {state = true, ready = true})
	end
end

function SlotModel:SetSlot(index)
	self.slot = math.floor(100/Denom[index])
	self.playBet = self.gameBet.initArray[index]
	LMessage:Dispatch(LuaEvent.SmallGame.Numerical)
	Globals.pipeMgr:Send(EEvent.PipeMsg.Setting, {id = "PlayBet", playBet = self.playBet, slot = self.slot})
end

function SlotModel:SetNextBet()
	local slotIndex = table.findItem(Denom, math.floor(100/self.slot))
	local index = table.findItem(self.gameBet.betArray[slotIndex], self.playBet)
	index = index >= #self.gameBet.betArray[slotIndex] and 1 or index + 1
	self.playBet = self.gameBet.betArray[slotIndex][index]
	LMessage:Dispatch(LuaEvent.SmallGame.Numerical, "PlayBet", true)
	Globals.pipeMgr:Send(EEvent.PipeMsg.Setting, {id = "PlayBet", playBet = self.playBet, slot = self.slot})
end

function SlotModel:SetLastBet()
	local slotIndex = table.findItem(Denom, math.floor(100/self.slot))
	local index = table.findItem(self.gameBet.betArray[slotIndex], self.playBet)
	index = index <= 1 and #self.gameBet.betArray[slotIndex] or index - 1
	self.playBet = self.gameBet.betArray[slotIndex][index]
	LMessage:Dispatch(LuaEvent.SmallGame.Numerical, "PlayBet", true)
	Globals.pipeMgr:Send(EEvent.PipeMsg.Setting, {id = "PlayBet", playBet = self.playBet, slot = self.slot})
end

function SlotModel:SetPlayBet(playBet, slot)
	if slot then
		self.slot = slot
	else
		local slotIndex = 1
		for k, v in ipairs(self.gameBet.betArray) do
			local index = table.findItem(v, playBet)
			if index > 0 then
				slotIndex = k
				break
			end
		end
		self:SetSlot(slotIndex)
	end
	self.playBet = playBet
	LMessage:Dispatch(LuaEvent.SmallGame.Numerical, "PlayBet")
	Globals.pipeMgr:Send(EEvent.PipeMsg.Setting, {id = "PlayBet", playBet = self.playBet, slot = self.slot})
end

function SlotModel:SetAdaptPlayBet(credit)
	local array = {}
	for k, v in ipairs(self.gameBet.betArray) do
		for i = 1, #v do
			table.insert(array, v[i])
		end
	end
	local playBet = array[#array]
	for k, v in ipairs(array) do
		if credit < v and k == 1 then
			playBet = 1
			break
		elseif credit < v and k > 1 then
			playBet = array[k - 1]
			break
		elseif credit == v then
			playBet = array[k]
			break
		end
	end
	self:SetPlayBet(playBet)
end

function SlotModel:CheckPlayBet()
	--没有分数
	if self.credit == 0 then
		self:SetPlayBet(self.platformArg.minPlayBet)
	--分数不足最小押注
	elseif self.credit < self.platformArg.minPlayBet then
		self:SetPlayBet(self.credit)
	--分数不够本次押注,自动换成下一档押注
	elseif self.credit < self.playBet then
		self:SetAdaptPlayBet(self.credit)
	--分数足够最小押注,押注小于最小押注
	elseif self.playBet < self.platformArg.minPlayBet then
		self:SetPlayBet(self.platformArg.minPlayBet)
	end
end

--加分数
function SlotModel:AddWinScore(score, bEffect)
	bEffect = bEffect or false
	self.win = self.win + score
	LMessage:Dispatch(LuaEvent.SmallGame.Numerical, "Win", bEffect)
end

--加赔率
function SlotModel:AddWinOdds(odds, bEffect)
	bEffect = bEffect or false
	self.win = self.win + math.reduce(self.playBet * odds, 100)
	LMessage:Dispatch(LuaEvent.SmallGame.Numerical, "Win", bEffect)
end

function SlotModel:AddLock()
	if self.locks == 0 then
		Globals.pipeMgr:Send(EEvent.PipeMsg.GameEvent, {id = "Lock", value = true})
	end
	self.locks = self.locks + 1
end

function SlotModel:RemoveLock()
	if self.locks == 1 then
		Globals.pipeMgr:Send(EEvent.PipeMsg.GameEvent, {id = "Lock", value = false})
	end
	self.locks = self.locks - 1
	self.locks = math.max(self.locks, 0)
end

function SlotModel:IsLocked()
	return self.locks > 0 or self.platformArg.bLocked
end

function SlotModel:GetSoundParam()
	return self.platformArg.soundParam
end

function SlotModel:SetSoundParam(music, effect)
	if self.platformArg.soundParam == G_EmptyTable then
		self.platformArg.soundParam = {}
	end
	self.platformArg.soundParam.gameMusic = music
	self.platformArg.soundParam.gameEffect = effect
	Globals.pipeMgr:Send(EEvent.PipeMsg.Setting, {id = "Volume", gameMusic = music, gameEffect = effect})
end

return SlotModel