--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:Slot视图主逻辑
--     创建时间:2023/09/20  
--------------------------------------------------------------------------------
local SlotView = BaseClass("SlotView", UIViewBase)
local ClassData = Globals.configMgr:GetConfig("ClassData")
local PlatSimulate = require (ClassData.PlatSimulate)
local SceneView = require (ClassData.SceneView)
local RollView = require (ClassData.RollView)
local MenuView = require (ClassData.MenuView)
local EffectView = require (ClassData.EffectView)

function SlotView:__ctor()
	self.weight = Const.GUIWeight.Main
	self.isDefalut = true
end

function SlotView:Initialize()
	LMessage:Dispatch(LuaEvent.Loading.AddNeedLoad, 4)
	--加载大厅模拟器
	if Globals.gameModel.platformArg.bLocalMode then
		self.simulate = PlatSimulate.getInstance()
		self.simulate:Initialize()
	end
	self.sceneView = SceneView.New(self:GetChild("scene"), self)
	self.rollView = RollView.New(self:GetChild("scroll"), self)
	self.menuView = MenuView.New(self:GetChild("menu"), self)
	self.effectView = EffectView.New(self:GetChild("effect"), self)
end

function SlotView:ShowSelf()
	self:BindEvent(LuaEvent.Common.ApplicationUpdate, "Update")
	self:BindEvent(LuaEvent.Common.ApplicationLateUpdate, "LateUpdate")
	self:BindEvent(LuaEvent.SmallGame.IncreaseCover, "OnIncreaseCover")
	self:BindEvent(LuaEvent.SmallGame.DecreaseCover, "OnDecreaseCover")
	self:BindEvent(LuaEvent.SmallGame.Prepare, "OnPrepare")
	self:BindEvent(LuaEvent.SmallGame.OneRound, "OnOneRound")
	self:BindEvent(LuaEvent.SmallGame.BetResult, "OnBetResult")
	self:BindEvent(LuaEvent.SmallGame.StopRound, "OnStopRound")
	self:BindEvent(LuaEvent.SmallGame.FinishRound, "OnFinishRound")
	self:BindEvent(LuaEvent.SmallGame.Reveal, "OnReveal")
	self:BindEvent(LuaEvent.SmallGame.Numerical, "OnNumerical")
	self:BindEvent(LuaEvent.SmallGame.KeyEvent, "OnKeyEvent")
	self:BindEvent(LuaEvent.SmallGame.GameEvent, "OnGameEvent")
	self:BindEvent(LuaEvent.SmallGame.UIEvent, "OnUIEvent")
end

function SlotView:HideSelf()
	self:UnBindAllEvent()
	if self.simulate then
		self.simulate:Dispose()
	end
end

function SlotView:Update()
	self.rollView:Update()
end

function SlotView:LateUpdate()
	self.menuView:LateUpdate()
	self.rollView:LateUpdate()
end

function SlotView:OnIncreaseCover(...)
	self.sceneView:OnIncreaseCover(...)
end

function SlotView:OnDecreaseCover(...)
	self.sceneView:OnDecreaseCover(...)
end

--准备游戏
function SlotView:OnPrepare(msg)
	self.sceneView:OnPrepare(msg)
	self.menuView:OnPrepare(msg)
	self.rollView:OnPrepare(msg)
end

--开始滚动
function SlotView:OnOneRound()
	self.sceneView:OnOneRound()
	self.menuView:OnOneRound()
	self.rollView:OnOneRound()
	self.effectView:OnOneRound()
end

--获取结果
function SlotView:OnBetResult(msg)
	self.menuView:OnBetResult(msg)
	self.rollView:OnBetResult(msg)
end

--停止滚动
function SlotView:OnStopRound(immediate, ...)
	self.menuView:OnStopRound(immediate, ...)
	self.rollView:OnStopRound(immediate, ...)
end

--完成滚动
function SlotView:OnFinishRound(immediate, column)
	self.menuView:OnFinishRound(immediate, column)
	self.rollView:OnFinishRound(immediate, column)
end

--游戏表现
function SlotView:OnReveal(revealType, ...)
	self.sceneView:OnReveal(revealType, ...)
	self.menuView:OnReveal(revealType, ...)
	self.rollView:OnReveal(revealType, ...)
	self.effectView:OnReveal(revealType, ...)
end

--分值表现
function SlotView:OnNumerical(...)
	self.sceneView:OnNumerical(...)
	self.menuView:OnNumerical(...)
	self.rollView:OnNumerical(...)
end

--按键事件
function SlotView:OnKeyEvent(...)
	self.menuView:OnKeyEvent(...)
	self.rollView:OnKeyEvent(...)
end

--游戏事件
function SlotView:OnGameEvent(...)
	self.rollView:OnGameEvent(...)
end

--UI事件
function SlotView:OnUIEvent(...)
	self.sceneView:OnUIEvent(...)
	self.rollView:OnUIEvent(...)
end


return SlotView