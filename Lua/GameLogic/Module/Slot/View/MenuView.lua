--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:菜单View
--     创建时间:2023/09/20  
--------------------------------------------------------------------------------
local MenuView = BaseClass("MenuView", UIItem)
local ClassData = Globals.configMgr:GetConfig("ClassData")
local ButtonItem = require (ClassData.ButtonItem)
local NumberItem = require "GameLogic.UI.Number.NumberItem"
local TextWrap = require "Common.Wrap.TextWrap"
local volumes = {0, 0.25, 0.60, 1}

Const.KeyEvent = {
	Bind = 1, --绑定按键事件
	UnBind = 2, --解绑按键事件
	Click = 3, --点击按键
	Enable = 4, --激活按键
	Disable = 5, --失效按键
}

Const.KeyType = {
	Spin = 1, --旋转按键
	Stop = 2, --停止按键
	Auto = 3, --自动按键
	Start = 4, --开始按键
	Take = 5, --取分按键
}

function MenuView:__ctor(parent, baseView)
	self:InitItem(parent, nil, baseView)
end

function MenuView:Initialize()
	self.extendAnim = self:GetChild("extend", ClassType.Animator)
	self:AddUIEvent(self.extendAnim, callback(self, "OnUIEvent"))
	self.scoreGo = self:GetChild("score").gameObject
	self.dollarGo = self:GetChild("dollar").gameObject
	self.tipGo = self:GetChild("back/tip").gameObject
	self.winGo = self:GetChild("back/win").gameObject
	local onInstantiate_slot = function(num)
		local parent = Globals.resMgr:LoadPlatAtlas("Atlas/slotnumber")
		local num = parent.transform:Find(num).gameObject
		return GameObject.Instantiate(num)
	end
	local onInstantiate_bet = function(num)
		local parent = Globals.resMgr:LoadPlatAtlas("Atlas/betnumber")
		local num = parent.transform:Find(num).gameObject
		return GameObject.Instantiate(num)
	end
	local onInstantiate_win = function(num)
		local parent = Globals.resMgr:LoadPlatAtlas("Atlas/winnumber")
		local num = parent.transform:Find(num).gameObject
		return GameObject.Instantiate(num)
	end
	
	self.slotValue = NumberItem.New(self:GetChild("value/slot"), nil, self.mBaseView)
	self.slotValue:SetInstantiateNumCallBack(onInstantiate_slot)
	self.betValue_dollar = NumberItem.New(self:GetChild("value/bet_dollar"), nil, self.mBaseView)
	self.betValue_dollar:SetInstantiateNumCallBack(onInstantiate_bet)
	self.betValue_score = NumberItem.New(self:GetChild("value/bet_score"), nil, self.mBaseView)
	self.betValue_score:SetInstantiateNumCallBack(onInstantiate_bet)
	self.winValue = NumberItem.New(self:GetChild("value/win"), nil, self.mBaseView)
	self.winValue:SetInstantiateNumCallBack(onInstantiate_win)
	self.creditValue_dollar = NumberItem.New(self:GetChild("value/credit_dollar"), nil, self.mBaseView)
	self.creditValue_dollar:SetInstantiateNumCallBack(onInstantiate_bet)
	self.creditValue_score = NumberItem.New(self:GetChild("value/credit_score"), nil, self.mBaseView)
	self.creditValue_score:SetInstantiateNumCallBack(onInstantiate_bet)
	self.handText = TextWrap.New(self:GetChild("hands"))
	self.jackpotText = TextWrap.New(self:GetChild("jackpot"))
	self.betText = TextWrap.New(self:GetChild("dollar/bet/text"))
	self.winText = TextWrap.New(self:GetChild("back/win/text"))
	self.creditText = TextWrap.New(self:GetChild("back/credit/text"))
	
	local process_voice = function(tran, i, list)
		local btn = ButtonItem.New(tran, self.mBaseView)
		btn:AddOnClick(btn, callback(self, "OnClickVoiceBtn", i), Const.SoundType.Button_Voice)
		for _, v in pairs(list) do
			v:AddRelate(btn, true)
		end
		return btn
	end
	self.voices = TransformUtils.GetAllChilds(self:GetChild("extend/voice"), process_voice)
	for _, v in pairs(self.voices) do
		v:SetEnable(false)
	end
	
	self.introduceBtn = ButtonItem.New(self:GetChild("extend/introduce"), self.mBaseView)
	self.introduceBtn:AddOnClick(self.introduceBtn, callback(self, "OnClickIntroduceBtn"), Const.SoundType.Button_Introduce)
	self.introduceBtn:SetEnable(false)
	
	self.exitBtn = ButtonItem.New(self:GetChild("items/exit"), self.mBaseView)
	self.exitBtn:AddOnClick(self.exitBtn, callback(self, "OnClickExitBtn"))
	
	self.infoBtn = ButtonItem.New(self:GetChild("items/info"), self.mBaseView)
	self.infoBtn:AddOnClick(self.infoBtn, callback(self, "OnClickInfoBtn"), Const.SoundType.Button_Info)

	self.previewBtn = ButtonItem.New(self:GetChild("items/preview"), self.mBaseView)
	self.previewBtn:AddOnClick(self.previewBtn, callback(self, "OnClickPreviewBtn"), Const.SoundType.Button_Preview)

	self.spinBtn = ButtonItem.New(self:GetChild("items/spin"), self.mBaseView)
	self.spinBtn:AddOnClick(self.spinBtn, callback(self, "OnClickSpinBtn"), Const.SoundType.Button_Spin)
	self:AddUIEvent(self.spinBtn, callback(self, "OnUIEvent"))

	self.stopBtn = ButtonItem.New(self:GetChild("items/stop"), self.mBaseView)
	self.stopBtn:AddOnClick(self.stopBtn, callback(self, "OnClickStopBtn"), Const.SoundType.Button_Stop)

	self.stopAutoBtn = ButtonItem.New(self:GetChild("items/stopauto"), self.mBaseView)
	self.stopAutoBtn:AddOnClick(self.stopAutoBtn, callback(self, "OnClickStopAutoBtn"), Const.SoundType.Button_StopAuto)

	self.startBtn = ButtonItem.New(self:GetChild("items/start"), self.mBaseView)
	self.startBtn:AddOnClick(self.startBtn, callback(self, "OnClickStartBtn"), Const.SoundType.Button_Start)

	self.takeBtn = ButtonItem.New(self:GetChild("items/take"), self.mBaseView)
	self.takeBtn:AddOnClick(self.takeBtn, callback(self, "OnClickTakeBtn"), Const.SoundType.Button_Take)

	self.slotBtn = ButtonItem.New(self:GetChild("dollar/slot"), self.mBaseView)
	self.slotBtn:AddOnClick(self.slotBtn, callback(self, "OnClickSlotBtn"), Const.SoundType.Button_Slot)

	self.reduceBetBtn_dollar = ButtonItem.New(self:GetChild("dollar/bet/reduce"), self.mBaseView)
	self.reduceBetBtn_dollar:AddOnClick(self.reduceBetBtn_dollar, callback(self, "OnClickReduceBetBtn"), Const.SoundType.Button_Bet)

	self.increaseBtn_dollar = ButtonItem.New(self:GetChild("dollar/bet/increase"), self.mBaseView)
	self.increaseBtn_dollar:AddOnClick(self.increaseBtn_dollar, callback(self, "OnClickIncreaseBetBtn"), Const.SoundType.Button_Bet)

	self.reduceBetBtn_score = ButtonItem.New(self:GetChild("score/bet/reduce"), self.mBaseView)
	self.reduceBetBtn_score:AddOnClick(self.reduceBetBtn_score, callback(self, "OnClickReduceBetBtn"), Const.SoundType.Button_Bet)

	self.increaseBtn_score = ButtonItem.New(self:GetChild("score/bet/increase"), self.mBaseView)
	self.increaseBtn_score:AddOnClick(self.increaseBtn_score, callback(self, "OnClickIncreaseBetBtn"), Const.SoundType.Button_Bet)

	self.effects = {}
	local effects = TransformUtils.GetAllChilds(self:GetChild("effect"))
	for _, effect in pairs(effects) do
		local go = effect.gameObject
		go:SetActive(false)
		self.effects[go.name] = go
	end
	
	self.events = {}
	
	LMessage:Dispatch(LuaEvent.Loading.AddLoaded, 1)
end

function MenuView:ShowSelf()
	self.reduceBetBtn = Globals.gameModel.platformArg.bDollar and self.reduceBetBtn_dollar or self.reduceBetBtn_score
	self.increaseBtn = Globals.gameModel.platformArg.bDollar and  self.increaseBtn_dollar or self.increaseBtn_score
	self.betValue = Globals.gameModel.platformArg.bDollar and self.betValue_dollar or self.betValue_score
	self.creditValue = Globals.gameModel.platformArg.bDollar and self.creditValue_dollar or self.creditValue_score
	self.dollarGo:SetActive(Globals.gameModel.platformArg.bDollar)
	self.scoreGo:SetActive(not Globals.gameModel.platformArg.bDollar)
	self.betText.gameObject:SetActive(Globals.gameModel.platformArg.bDollar)
	self.creditText.gameObject:SetActive(Globals.gameModel.platformArg.bDollar)
	self.previewBtn:SetIsPop(Globals.gameModel.platformArg.bPreview)
	self.spinBtn:AddRelate(self.stopBtn, true)
	self.spinBtn:AddRelate(self.startBtn, true)
	self.spinBtn:AddRelate(self.takeBtn, true)
	self.stopBtn:AddRelate(self.startBtn, true)
	self.stopBtn:AddRelate(self.takeBtn, true)
	self.startBtn:AddRelate(self.takeBtn, true)
	self.stopBtn:SetEnable(false)
	self.startBtn:SetEnable(false)
	self.takeBtn:SetEnable(false)
	self.stopAutoBtn:SetIsPop(false)
	self.spinBtn:SetIsPop(false)
	self.spinBtn:SetIsPop(true)
	self:Reset()
end

function MenuView:Reset()
	self.exitBtn:SetEnable(false)
	self.previewBtn:SetEnable(false)
	self.reduceBetBtn:SetEnable(false)
	self.increaseBtn:SetEnable(false)
	self.slotBtn:SetEnable(false)
	self.spinBtn:SetEnable(false)
	self.winText.gameObject:SetActive(false)
	self.winGo:SetActive(false)
	self.tipGo:SetActive(true)
	self.winValue:SetIsPop(false)
	self.handText:SetText("Hands: " .. Globals.gameModel.roundCnt)
end

function MenuView:LateUpdate()
	--自动点击start take按键
	if Globals.gameModel.autoGame and table.nums(self.events) > 0 then
		for k, v in pairs(self.events) do
			if v.autoTimer > 0 then
				v.autoTimer = v.autoTimer - Time.deltaTime
			else
				v.button:ClickSelf()
			end
		end
	end
end

function MenuView:OnUIEvent(trigger, param)
	--spinBtn按下
	if param == "spin_down" then
		self.spinDown = true
		self.spinTimer = 0
		Globals.timerMgr:AddTimer(function()
			if self.spinDown then
				self.spinTimer = self.spinTimer + Time.deltaTime
				if self.spinTimer > 1.5 then
					self:OnHoldSpinBtn()
					return false
				end
				return true
			end
		end, 0, 0)
	--spinBtn按起
	elseif param == "spin_up" then
		self.spinDown = false
		self.spinTimer = 0
	--extend显示
	elseif param == "extend_show" then
		for _, v in pairs(self.voices) do
			v:SetEnable(true)
		end
		self.introduceBtn:SetEnable(true)
		self.showExtend = not self.showExtend
	--extend隐藏
	elseif param == "extend_hide" then
		self.showExtend = not self.showExtend
	end
end

function MenuView:OnPrepare(msg)
	if msg.state and msg.state < Const.RoundState.End then
		self.exitBtn:SetEnable(false)
		self.previewBtn:SetEnable(false)
		self.reduceBetBtn:SetEnable(false)
		self.increaseBtn:SetEnable(false)
		self.slotBtn:SetEnable(false)
		self.spinBtn:SetEnable(false)
	else
		self.exitBtn:SetEnable(true)
		self.previewBtn:SetEnable(true)
		self.reduceBetBtn:SetEnable(true)
		self.increaseBtn:SetEnable(true)
		self.slotBtn:SetEnable(true)
		self.spinBtn:SetEnable(true)
		if not msg.gameId then
			self.tipGo:SetActive(true)
			self.winText.gameObject:SetActive(false)
			self.winGo:SetActive(false)
			self.winValue:SetIsPop(false)
		end
	end
	
	local volume = Globals.soundMgr:GetVolume()
	local curVolIdx = table.findItem(volumes, volume)
	if curVolIdx < 0 then
		printerror("音量初始化错误！")
		if _ErrorPause then
			ComUtils.SetTimeScale(0)
		end
	else
		self.voices[curVolIdx]:SetIsPop(false)
		self.voices[curVolIdx]:SetIsPop(true)
	end
	
	--演示模式自动跑
	if Globals.gameModel.platformArg.bReproduct then
		Globals.timerMgr:AddTimer(function()
			self:OnHoldSpinBtn()
		end, 0, 3)
	end
end

function MenuView:OnOneRound()
	if Globals.gameModel.rule == Const.GameRule.Normal then
		self:Reset()
	else
		self.spinBtn:SetEnable(false)
	end
	Globals.timerMgr:AddTimer(function()
		self.stopBtn:SetIsPop(true)
	end, 0, 0.5)
end

function MenuView:OnBetResult()
	self.stopBtn:SetEnable(true)
	Globals.pipeMgr:Send(EEvent.PipeMsg.GameInfo, {state = true, stop = true})
end

function MenuView:OnStopRound(immediate, ...)
	if immediate then
		self.stopBtn:SetEnable(false)
		Globals.pipeMgr:Send(EEvent.PipeMsg.GameInfo, {state = true, stop = false})
	end
end

function MenuView:OnFinishRound(immediate, column)
	if immediate then
		self.stopBtn:SetEnable(false)
		Globals.pipeMgr:Send(EEvent.PipeMsg.GameInfo, {state = true, stop = false})
	end
end

function MenuView:OnReveal(revealType, ...)
	if revealType == Const.RevealType.Finish then
		if Globals.gameModel.rule == Const.GameRule.Normal then
			self.exitBtn:SetEnable(true)
			self.previewBtn:SetEnable(true)
			self.reduceBetBtn:SetEnable(true)
			self.increaseBtn:SetEnable(true)
			self.slotBtn:SetEnable(true)
			self.spinBtn:SetEnable(true)
			self.spinBtn:SetIsPop(true)
		end
	end
end

function MenuView:OnNumerical(...)
	local category = select(1, ...) or false
	local bEffect = select(2, ...) or false
	local format = "$%."..Globals.gameModel.platformArg.decimal.."f"
	if not category or category == "PlayBet" then
		if Globals.gameModel.platformArg.bDollar then
			local slot = math.floor(100 / Globals.gameModel.slot)
			if slot == 100 then
				self.slotValue:SetValue("1$")
			else
				self.slotValue:SetValue(slot.."D")
			end
			self.betText:SetText(string.format(format, Globals.gameModel.playBet*Globals.gameModel.platformArg.multiplier))
		end
		self.betValue:SetValue(math.floor(Globals.gameModel.playBet*Globals.gameModel.slot*Globals.gameModel.platformArg.multiplier))
		if bEffect and Globals.gameModel.playBet == Globals.gameModel.platformArg.maxPlayBet then
			local effectname = Globals.gameModel.platformArg.bDollar and "playBet_dollar" or "playBet_score"
			Globals.soundMgr:PlayEffect(Const.SoundType.Button_MaxBet)
			self.effects[effectname]:SetActive(true)
			Globals.timerMgr:AddTimer(function()
				self.effects[effectname]:SetActive(false)
			end, 0, 0.7)
		end
	end
	if not category or category == "Win" then
		if Globals.gameModel.platformArg.bDollar then
			self.winText:SetText(string.format(format, Globals.gameModel.win*Globals.gameModel.platformArg.multiplier))
		end
		if bEffect then
			self.winValue:ScrollNum(nil, math.floor(Globals.gameModel.win*Globals.gameModel.slot*Globals.gameModel.platformArg.multiplier), 0, 0.5)
			self.winValue.transform:DOScale(1.5, 0.5):SetEase(EaseType.OutSine):OnComplete(function()
				self.winValue.transform:DOScale(1, 0.2):SetEase(EaseType.InSine):SetDelay(0.2)
				self.winText.gameObject:SetActive(Globals.gameModel.platformArg.bDollar)
			end)
			self.effects["win"]:SetActive(true)
			Globals.timerMgr:AddTimer(function()
				self.effects["win"]:SetActive(false)
			end, 0, 1)
		else
			self.winValue:SetValue(math.floor(Globals.gameModel.win*Globals.gameModel.slot*Globals.gameModel.platformArg.multiplier))
			self.winText.gameObject:SetActive(Globals.gameModel.platformArg.bDollar)
		end
		if category == "Win" and not self.winValue:GetIsPop() then
			self.tipGo:SetActive(false)
			self.winGo:SetActive(true)
			self.winValue:SetIsPop(true)
		end
	end
	if not category or category == "Credit" then
		if Globals.gameModel.platformArg.bDollar then
			self.creditText:SetText(string.format(format, Globals.gameModel.credit*Globals.gameModel.platformArg.multiplier))
		end
		if bEffect then
			self.creditValue:ScrollNum(nil, math.floor(Globals.gameModel.credit*Globals.gameModel.slot*Globals.gameModel.platformArg.multiplier), 0, 0.5):OnComplete(function()
				self.creditValue:SetValue(math.floor(Globals.gameModel.credit*Globals.gameModel.slot*Globals.gameModel.platformArg.multiplier))
			end)
			self.effects["credit"]:SetActive(true)
			Globals.timerMgr:AddTimer(function()
				self.effects["credit"]:SetActive(false)
			end, 0, 1)
		else
			self.creditValue:SetValue(math.floor(Globals.gameModel.credit*Globals.gameModel.slot*Globals.gameModel.platformArg.multiplier))
		end
	end
	if not category or category == "Jackpot" then
		local content = ""
		if Globals.gameModel.platformArg.bDollar then
			if Globals.gameModel.jackpot.minLocal then
				local minLocal = string.format(format, Globals.gameModel.jackpot.minLocal*Globals.gameModel.platformArg.multiplier)
				content = content .. "JP min: " .. minLocal .. "   "
			end
			if Globals.gameModel.jackpot.minLink then
				local minLink = string.format(format, Globals.gameModel.jackpot.minLink*Globals.gameModel.platformArg.multiplier)
				content = content .. "Link JP min: " .. minLink
			end
			
		else
			if Globals.gameModel.jackpot.minLocal then
				content = content .. "JP min: " .. Globals.gameModel.jackpot.minLocal .. "   "
			end
			if Globals.gameModel.jackpot.minLink then
				content = content .. "Link JP min: " .. Globals.gameModel.jackpot.minLink
			end
		end
		self.jackpotText:SetText(content)
	end
end

function MenuView:OnKeyEvent(...)
	local keyEvent = select(1, ...)
	local keyType = select(2, ...)
	local callBack = select(3, ...)
	local autoTimer = select(4, ...) or 5
	--绑定
	if keyEvent == Const.KeyEvent.Bind and keyType and callBack then
		self.events[keyType] = {callBack = callBack, autoTimer = autoTimer}
		if keyType == Const.KeyType.Start then
			self.events[keyType].button = self.startBtn
			self.startBtn:SetEnable(true)
			self.startBtn:SetIsPop(true)
			Globals.pipeMgr:Send(EEvent.PipeMsg.GameInfo, {state = true, start = true})
		elseif keyType == Const.KeyType.Take then
			self.events[keyType].button = self.takeBtn
			self.takeBtn:SetEnable(true)
			self.takeBtn:SetIsPop(true)
			Globals.pipeMgr:Send(EEvent.PipeMsg.GameInfo, {state = true, take = true})
		end
	--解绑
	elseif keyEvent == Const.KeyEvent.UnBind and keyType then
		self.events[keyType] = nil
		if keyType == Const.KeyType.Start then
			self.startBtn:SetEnable(false)
			Globals.pipeMgr:Send(EEvent.PipeMsg.GameInfo, {state = true, start = false})
		elseif keyType == Const.KeyType.Take then
			self.takeBtn:SetEnable(false)
			Globals.pipeMgr:Send(EEvent.PipeMsg.GameInfo, {state = true, take = false})
		end
	--激活
	elseif keyEvent == Const.KeyEvent.Enable and keyType then
		if keyType == Const.KeyType.Spin then
			self.spinBtn:SetIsPop(true)
			self.spinBtn:SetEnable(true)
		elseif keyType == Const.KeyType.Stop then
			self.stopBtn:SetIsPop(true)
			self.stopBtn:SetEnable(true)
			Globals.pipeMgr:Send(EEvent.PipeMsg.GameInfo, {state = true, stop = true})
		elseif keyType == Const.KeyType.Auto then
			self.stopAutoBtn:SetIsPop(true)
		elseif keyType == Const.KeyType.Start then
			self.startBtn:SetIsPop(true)
			self.startBtn:SetEnable(true)
			Globals.pipeMgr:Send(EEvent.PipeMsg.GameInfo, {state = true, start = true})
		elseif keyType == Const.KeyType.Take then
			self.takeBtn:SetIsPop(true)
			self.takeBtn:SetEnable(true)
			Globals.pipeMgr:Send(EEvent.PipeMsg.GameInfo, {state = true, take = true})
		end
	--失效
	elseif keyEvent == Const.KeyEvent.Disable and keyType then
		if keyType == Const.KeyType.Spin then
			self.spinBtn:SetEnable(false)
		elseif keyType == Const.KeyType.Stop then
			self.stopBtn:SetEnable(false)
			Globals.pipeMgr:Send(EEvent.PipeMsg.GameInfo, {state = true, stop = false})
		elseif keyType == Const.KeyType.Auto then
			self.stopAutoBtn:SetIsPop(false)
		elseif keyType == Const.KeyType.Start then
			self.startBtn:SetEnable(false)
			Globals.pipeMgr:Send(EEvent.PipeMsg.GameInfo, {state = true, start = false})
		elseif keyType == Const.KeyType.Take then
			self.takeBtn:SetEnable(false)
			Globals.pipeMgr:Send(EEvent.PipeMsg.GameInfo, {state = true, take = false})
		end
	--点击
	elseif keyEvent == Const.KeyEvent.Click then
		local msg = select(2, ...)
		if msg and msg.id == "Auto" then
			if Globals.gameModel.autoGame then
				self:OnClickStopAutoBtn()
			else
				self:OnHoldSpinBtn()
			end
		elseif msg and msg.id == "Play" then
			if self.spinBtn:GetIsPop() and self.spinBtn:GetEnable() then
				self:OnClickSpinBtn()
			elseif self.stopBtn:GetIsPop() and self.stopBtn:GetEnable() then
				self:OnClickStopBtn()
			elseif self.startBtn:GetIsPop() and self.startBtn:GetEnable() then
				self.startBtn:ClickSelf()
			elseif self.takeBtn:GetIsPop() and self.takeBtn:GetEnable() then
				self.takeBtn:ClickSelf()
			end
		end
	end
end

function MenuView:OnClickVoiceBtn(index)
	index = index >= #self.voices and 1 or index+1
	Globals.soundMgr:SetVolume(volumes[index], volumes[index])
	self.voices[index]:SetIsPop(true)
end

function MenuView:OnClickIntroduceBtn()
	Globals.uiMgr:OpenView("IntroduceView")
	self:OnClickInfoBtn()
end

function MenuView:OnClickExitBtn()
	LMessage:Dispatch(LuaEvent.Common.GameQuit, Const.QuitReason.Client, "客户端主动退出")
end

function MenuView:OnClickInfoBtn()
	if self.showExtend then
		for _, v in pairs(self.voices) do
			v:SetEnable(false)
		end
		self.introduceBtn:SetEnable(false)
		self.extendAnim:SetTrigger("Hide")
	else
		self.extendAnim:SetTrigger("Show")
	end
end

function MenuView:OnClickPreviewBtn()
	Globals.uiMgr:OpenView("PreviewerView", function()
		if Globals.gameModel.state ~= Const.GameState.Idle then
			Globals.uiMgr:HideView("PreviewerView")
		end
	end)
end

function MenuView:OnClickSpinBtn()
	LMessage:Dispatch(LuaEvent.SmallGame.StartRound)
end

function MenuView:OnHoldSpinBtn()
	Globals.gameModel.autoGame = true
	self.stopAutoBtn:SetIsPop(true)
end

function MenuView:OnClickStopBtn()
	LMessage:Dispatch(LuaEvent.SmallGame.StopRound, true)
end

function MenuView:OnClickStopAutoBtn()
	Globals.gameModel.autoGame = false
	self.stopAutoBtn:SetIsPop(false)
end

function MenuView:OnClickStartBtn()
	if self.events[Const.KeyType.Start] then
		--解绑一定要在callBack里面写
		local callBack = self.events[Const.KeyType.Start].callBack
		self.events[Const.KeyType.Start] = nil
		callBack()
	end
end

function MenuView:OnClickTakeBtn()
	if self.events[Const.KeyType.Take] then
		--解绑一定要在callBack里面写
		local callBack = self.events[Const.KeyType.Take].callBack
		self.events[Const.KeyType.Take] = nil
		callBack()
	end
end

function MenuView:OnClickSlotBtn()
	Globals.uiMgr:OpenView("DenomView", function()
		if Globals.gameModel.state ~= Const.GameState.Idle then
			Globals.uiMgr:HideView("DenomView")
		end
	end)
end

function MenuView:OnClickReduceBetBtn()
	Globals.gameModel:SetLastBet()
end

function MenuView:OnClickIncreaseBetBtn()
	Globals.gameModel:SetNextBet()
end


return MenuView