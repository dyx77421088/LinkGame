--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:Slot主界面控制器，控制主界面游戏逻辑
--     创建时间:2023/02/08 
--------------------------------------------------------------------------------
local json = require 'cjson'
local SlotController = Singleton("SlotController")


function SlotController:__delete()
	--公共事件
	LMessage:UnRegister(LuaEvent.SmallGame.IncreaseCover, self.onIncreaseCover)
	LMessage:UnRegister(LuaEvent.SmallGame.DecreaseCover, self.onDecreaseCover)
	--逻辑事件
	LMessage:UnRegister(LuaEvent.Loading.LoadedLoading, self.onLoadedLoading)
	LMessage:UnRegister(LuaEvent.SmallGame.StartRound, self.onStartRound)
	LMessage:UnRegister(LuaEvent.SmallGame.OneRound, self.onOneRound)
	LMessage:UnRegister(LuaEvent.SmallGame.StopRound, self.onStopRound)
	LMessage:UnRegister(LuaEvent.SmallGame.FinishRound, self.onFinishRound)
	LMessage:UnRegister(LuaEvent.SmallGame.Reveal, self.onReveal)
	--平台事件
	Globals.pipeMgr:UnBind(EEvent.PipeMsg.Broadcast)
	Globals.pipeMgr:UnBind(EEvent.PipeMsg.GameInfo)
	Globals.pipeMgr:UnBind(EEvent.PipeMsg.GameEvent)
	Globals.pipeMgr:UnBind(EEvent.PipeMsg.UIEvent)
	Globals.pipeMgr:UnBind(EEvent.PipeMsg.KeyEvent)
	Globals.pipeMgr:UnBind(EEvent.PipeMsg.Setting)
	Globals.pipeMgr:UnBind(EEvent.PipeMsg.Prepare)
	Globals.pipeMgr:UnBind(EEvent.PipeMsg.OneRound)
	Globals.pipeMgr:UnBind(EEvent.PipeMsg.PreviewBet)
end

function SlotController:Initialize()
	--公共事件
    self.onIncreaseCover = LMessage:Register(LuaEvent.SmallGame.IncreaseCover, "OnIncreaseCover", self)
    self.onDecreaseCover = LMessage:Register(LuaEvent.SmallGame.DecreaseCover, "OnDecreaseCover", self)
	--逻辑事件
	self.onLoadedLoading = LMessage:Register(LuaEvent.Loading.LoadedLoading, "OnLoadedLoading", self)
	self.onStartRound = LMessage:Register(LuaEvent.SmallGame.StartRound, "OnStartRound", self)
	self.onOneRound = LMessage:Register(LuaEvent.SmallGame.OneRound, "OnOneRound", self)
	self.onStopRound = LMessage:Register(LuaEvent.SmallGame.StopRound, "OnStopRound", self)
	self.onFinishRound = LMessage:Register(LuaEvent.SmallGame.FinishRound, "OnFinishRound", self)
	self.onReveal = LMessage:Register(LuaEvent.SmallGame.Reveal, "OnReveal", self)
	--平台事件
	Globals.pipeMgr:Bind(EEvent.PipeMsg.Broadcast, "OnBroadcast", self)
	Globals.pipeMgr:Bind(EEvent.PipeMsg.GameInfo, "OnGameInfo", self)
	Globals.pipeMgr:Bind(EEvent.PipeMsg.GameEvent, "OnGameEvent", self)
	Globals.pipeMgr:Bind(EEvent.PipeMsg.UIEvent, "OnUIEvent", self)
	Globals.pipeMgr:Bind(EEvent.PipeMsg.KeyEvent, "OnKeyEvent", self)
	Globals.pipeMgr:Bind(EEvent.PipeMsg.Setting, "OnSetting", self)
	Globals.pipeMgr:Bind(EEvent.PipeMsg.Prepare, "OnPrepare", self)
	Globals.pipeMgr:Bind(EEvent.PipeMsg.OneRound, "OnBetResult", self)
	Globals.pipeMgr:Bind(EEvent.PipeMsg.PreviewBet, "OnPreviewBet", self)
end

function SlotController:OnLoadedLoading()
	Globals.resMgr:PreLoad()
    Globals.uiMgr:OpenView("SlotView")
end

--------------------------逻辑消息--------------------------------------
function SlotController:OnIncreaseCover()
    Globals.gameModel:IncreaseCover()
end

function SlotController:OnDecreaseCover()
    Globals.gameModel:DecreaseCover()
end

function SlotController:OnStartRound()
	Globals.gameModel:StartRound()
end

function SlotController:OnOneRound()
	Globals.gameModel:OneRound()
end

function SlotController:OnStopRound(immediate, ...)
	
end

function SlotController:OnFinishRound(immediate, column)
	Globals.gameModel:FinishRound(immediate, column)
end

function SlotController:OnReveal(revealType, ...)
	Globals.gameModel:Reveal(revealType, ...)
end

--------------------------平台消息--------------------------------------
function SlotController:OnBroadcast(msg)
	if not msg then
		return
	end
	
	Globals.uiMgr:ShowTransfer({content = msg.content, pause = true})
end

function SlotController:OnGameInfo(msg)
	Globals.gameModel:GameInfo(msg)
end

function SlotController:OnGameEvent(msg)
	Globals.gameModel:GameEvent(msg)
	LMessage:Dispatch(LuaEvent.SmallGame.GameEvent, msg)
end

function SlotController:OnUIEvent(msg)
	LMessage:Dispatch(LuaEvent.SmallGame.UIEvent, msg)
end

function SlotController:OnKeyEvent(msg)
	Globals.gameModel:KeyEvent(msg)
	LMessage:Dispatch(LuaEvent.SmallGame.KeyEvent, Const.KeyEvent.Click, msg)
end

function SlotController:OnSetting(msg)
	Globals.gameModel:Setting(msg)
	LMessage:Dispatch(LuaEvent.SmallGame.Setting, msg)
end

function SlotController:OnPrepare(msg)
	Globals.gameModel:Prepare(msg)
	LMessage:Dispatch(LuaEvent.SmallGame.Prepare, msg)
end

function SlotController:OnBetResult(msg)
	Globals.gameModel:BetResult(msg)
	LMessage:Dispatch(LuaEvent.SmallGame.BetResult, msg)
end

function SlotController:OnPreviewBet(msg)
	LMessage:Dispatch(LuaEvent.SmallGame.PreviewBet, msg)
end
------------------------------------------------------------------------

return SlotController