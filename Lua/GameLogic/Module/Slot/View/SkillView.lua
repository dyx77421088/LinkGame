--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:技巧游戏视图主逻辑
--     创建时间:2023/09/20  
--------------------------------------------------------------------------------
local SkillView = BaseClass("SkillView", UIViewBase)
local ClassData = Globals.configMgr:GetConfig("ClassData")
local ButtonItem = require (ClassData.ButtonItem)
local StickBall = require (ClassData.StickBall)
local MatchUp = require (ClassData.MatchUp)

Const.SkillGameType = {
	StickBall = 1,
	MatchUp = 2,
}


function SkillView:Initialize()
	self.stickball = StickBall.New(self:GetChild("stickball"), self)
	self.matchup = MatchUp.New(self:GetChild("matchup"), self)
	self.enterBtn = ButtonItem.New(self:GetChild("enter"), self)
	self.enterBtn:AddOnClick(self.enterBtn, callback(self, "StartSkillGame"))
	self.entertext = self:GetChild("enter/info", ClassType.Text)
	self.enterAnim = self:GetChild("enter", ClassType.Animator)
	local trigger = self:GetChild("enter", ClassType.LuaEventTrigger)
	trigger:SetLuaChunk(self)
	trigger:SetLuaCbFunc(self.OnAnimEvent)
end

function SkillView:ShowSelf()
	self.skillId = math.reduce(Globals.gameModel.platformArg.skillGame, 10)
	self.skillLvl = Globals.gameModel.platformArg.skillGame % 10
	local score = math.floor((Globals.gameModel.playBet - Globals.gameModel.win) * 1.05)
	self.entertext.text = "Play Skill Game to win " .. score
	self.enterBtn:SetEnable(false)
	self.enterBtn:SetIsPop(true)
	self.stickball:SetIsPop(false)
	self.matchup:SetIsPop(false)
	self.enterAnim:SetTrigger("show")
	
	self:BindEvent(LuaEvent.Common.ApplicationUpdate, "Update")
	self:BindEvent(LuaEvent.SmallGame.StartRound, "OnStartRound")
end

function SkillView:HideSelf()
	self:UnBindAllEvent()
	Globals.gameModel:RemoveLock()
	LMessage:Dispatch(LuaEvent.SmallGame.DecreaseCover, self.uiName)
end

function SkillView:Update()
	if not self.isPlaying then
		return
	end
	
	if self.skillId == Const.SkillGameType.StickBall then
		self.stickball:OnUpdate()
	elseif self.skillId == Const.SkillGameType.MatchUp then
		self.matchup:OnUpdate()
	end
end

function SkillView:OnStartRound()
	if self.isPlaying then
		return
	end
	
	self.isPlaying = false
	self.enterBtn:SetEnable(false)
	self.enterAnim:SetTrigger("hide")
end

function SkillView:OnAnimEvent(trigger, factor)
	if factor == "show" then
		self.enterBtn:SetEnable(true)
	elseif factor == "hide" then
		self.enterBtn:SetIsPop(false)
		if not self.isPlaying then
			self:SetIsPop(false)
		end
	end
end

function SkillView:StartSkillGame()
	self.isPlaying = true
	self.enterBtn:SetEnable(false)
	self.enterAnim:SetTrigger("hide")
	Globals.gameModel:AddLock()
	if self.skillId == Const.SkillGameType.StickBall then
		self.stickball:ShowView(self.skillLvl)
	elseif self.skillId == Const.SkillGameType.MatchUp then
		self.matchup:ShowView(self.skillLvl)
	end
	LMessage:Dispatch(LuaEvent.SmallGame.IncreaseCover, self.uiName)
end

function SkillView:StopSkillGame(isWin)
	if isWin then
		local playScore = Globals.gameModel.playBet - Globals.gameModel.win
		local winScore = math.floor(playScore * 1.05)
		Globals.pipeMgr:Send(EEvent.PipeMsg.GameInfo, {skillGameID = self.skillId - 1, playScore = playScore, winScore = winScore})
	end
	self.isPlaying = false
	self:SetIsPop(false)
end


return SkillView