--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:特殊玩法转盘抽奖逻辑
--     创建时间:2023/12/10  
--------------------------------------------------------------------------------
local WheelView = BaseClass("WheelView", UIViewBase)
local NumberItem = require "GameLogic.UI.Number.NumberItem"
local ButtonItem = require "GameLogic.Module.Slot.Common.ButtonItem"
local odds = {500, 700, 1000, 2000, 3000, 4000, 3000, 2500, 1500, 500}
local freetimes = {}


function WheelView:__ctor()
	self.weight = Const.GUIWeight.Main
end

function WheelView:Initialize()
	local numTrans = self:GetChild("wheelnumber")
	local onInstantiate = function(num)
		local gameObject = numTrans:Find(num).gameObject
		return GameObject.Instantiate(gameObject)
	end
	self.root = self:GetChild("root")
	self.wheel = self:GetChild("root/wheel")
	self.button = ButtonItem.New(self:GetChild("root/force/button"), self)
	self.button:AddOnClick(self.button, callback(self, "OnClickBtn"))
	self.effect_win = self:GetChild("effect_win", ClassType.ParticleSystem)
	self.effect_show = self:GetChild("effect_show", ClassType.ParticleSystem)
	self.effect_click = self:GetChild("effect_click", ClassType.ParticleSystem)
	local list = TransformUtils.GetAllChilds(self:GetChild("root/wheel"))
	self.numbers = {}
	self.frees = {}
	self.jackpots = {}
	for i = 1, #list do
		local gameObject = list[i].gameObject
		local name = gameObject.name
		local numIdx = tonumber(name)
		if numIdx then
			local num = NumberItem.New(list[i], nil, self)
			num:SetInstantiateNumCallBack(onInstantiate)
			self.numbers[i] = num
			self.frees[i] = false
			self.jackpots[i] = false
		elseif string.contains(name, "free") then
			self.frees[i] = tonumber(string.sub(name, 5))
			self.numbers[i] = false
			self.jackpots[i] = false
		else
			self.jackpots[i] = name
			self.numbers[i] = false
			self.frees[i] = false
		end
	end
end

function WheelView:OnClickBtn()
	--如果绑定了事件一定要解绑
	LMessage:Dispatch(LuaEvent.SmallGame.KeyEvent, Const.KeyEvent.UnBind, Const.KeyType.Start)
	self.button:SetEnable(false)
	self.effect_click:Play()
	LMessage:Dispatch(LuaEvent.Sound.Play, "effect_wheel", 2)
	
	local randNum, odds = 0, 0
	--分数或者彩金
	G_printerror("财经的分数是", self.wheelBet)
	if self.wheelBet > 0 then
		self.jackpot = math.reduce(self.wheelBet, 10000)
		odds = self.wheelBet % 10000
		if self.jackpot > 0 then
			local mate = {"mini", "minor", "major"}
			randNum = math.random(1, #self.jackpots)
			while (self.jackpots[randNum] ~= mate[self.jackpot]) do
				randNum = math.random(1, #self.jackpots)
			end
		else
			randNum = math.random(1, #self.numbers)
			while (not self.numbers[randNum] or self.numbers[randNum].odds ~= odds) do
				randNum = math.random(1, #self.numbers)
				G_printerror(randNum)
			end
		end
	--免费
	elseif self.giveTime > 0 then
		randNum = math.random(1, #self.frees)
		while (not self.frees[randNum] or self.frees[randNum] ~= self.giveTime) do
			randNum = math.random(1, #self.frees)
		end
	else
	end
	-- 随机转8-10圈，随机的位置+3-7的偏移量
	local angle = math.random(8, 10) * 360 + (randNum - 1) * 18 + math.random(3, 7)
	local timer = math.random(5, 7)
	self.wheel:DOLocalRotate(Vector3(0, 0, -angle), timer, RotateMode.FastBeyond360):SetEase(EaseType.InOutCirc):OnComplete(function()
		self.wheel:DOLocalRotate(Vector3(0, 0, -angle + 5), 0.6):OnComplete(function()
			self.effect_win:Play()
			LMessage:Dispatch(LuaEvent.Sound.Play, "effect_wheel", 3)
			if self.jackpot and self.jackpot > 0 then
				self.root:DOScale(1.2, 0.3):SetDelay(4):OnComplete(function()
					self.root:DOScale(0, 0.5):OnComplete(function()
						--发送请求彩金消息(在平台PlatSimulate:OnGameEvent计算分数，再调用自己的OnGameEvent方法)
						Globals.pipeMgr:Send(EEvent.PipeMsg.GameEvent, {id = "GetJackpot", playBet = Globals.gameModel.playBet})
					end)
				end):OnStart(function()
					self.effect_win:Stop()
					LMessage:Dispatch(LuaEvent.Sound.Play, "effect_wheel", 4)
				end)
			elseif odds > 0 then
				self.root:DOScale(1.2, 0.3):SetDelay(4):OnComplete(function()
					self.root:DOScale(0, 0.5):OnComplete(function()
						Globals.uiMgr:HideView("WheelView")
						LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Effect, Const.EffectType.Normal, odds, function()
							Globals.gameModel.rule = Const.GameRule.Normal
							LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Finish)
						end)
					end)
				end):OnStart(function()
					self.effect_win:Stop()
					LMessage:Dispatch(LuaEvent.Sound.Play, "effect_wheel", 4)
				end)
			else
				self.root:DOScale(1.2, 0.3):SetDelay(4):OnComplete(function()
					self.root:DOScale(0, 0.5):OnComplete(function()
						Globals.uiMgr:HideView("WheelView")
						LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Switch, Const.GameRule.Normal, Const.GameRule.Free, 1)
					end)
				end):OnStart(function()
					self.effect_win:Stop()
					LMessage:Dispatch(LuaEvent.Sound.Play, "effect_wheel", 4)
				end)
			end
		end)
	end)
end

function WheelView:ShowSelf()
	self:SetDepth(280)
	self:BindEvent(LuaEvent.SmallGame.GameEvent, "OnGameEvent")
	
	local win, index = 0, 0
	for k, v in pairs(self.numbers) do
		if v then
			index = index + 1
			win = math.reduce(odds[index] * Globals.gameModel.playBet, 100)
			v.odds = odds[index]
			v:SetValue(math.floor(win*Globals.gameModel.slot*Globals.gameModel.platformArg.multiplier))
		end
	end
	self.root.localScale = Vector3.zero
	self.wheel.localEulerAngles = Vector3.zero
	self.effect_show:Play()
	self.root:DOScale(1.2, 0.5):OnComplete(function()
		self.root:DOScale(1, 0.2):OnComplete(function()
			self.button:SetEnable(true)
			--绑定start按键事件
			LMessage:Dispatch(LuaEvent.SmallGame.KeyEvent, Const.KeyEvent.Bind, Const.KeyType.Start, callback(self, "OnClickBtn"))
		end)
	end)
	
	LMessage:Dispatch(LuaEvent.Sound.Play, "effect_wheel", 1)
end

function WheelView:HideSelf()
	self:UnBindAllEvent()
end

function WheelView:OnGameEvent(msg)
	if msg.id == "GetJackpot" then
		Globals.uiMgr:HideView("WheelView")
		LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Effect, Const.EffectType.JackPot, msg.score, function()
			Globals.gameModel.rule = Const.GameRule.Normal
			LMessage:Dispatch(LuaEvent.SmallGame.Reveal, Const.RevealType.Finish)
		end, self.jackpot)
	end
end


return WheelView