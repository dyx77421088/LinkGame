--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:用来作为GM控制器
--     创建时间:2022/04/21 
--------------------------------------------------------------------------------
local GMController = Singleton("GMController")

function GMController:__ctor()

end

function GMController:__delete()
    LMessage:UnRegister(LuaEvent.Common.ApplicationStart, self.onApplicationStart)
	LMessage:UnRegister(LuaEvent.SmallGame.UIEvent, self.onUIEvent)
	--平台事件
	Globals.pipeMgr:UnBind(EEvent.PipeMsg.DebugModel)
end

function GMController:Initialize()
    self.onApplicationStart = LMessage:Register(LuaEvent.Common.ApplicationStart, "OnApplicationStart", self)
	self.onUIEvent = LMessage:Register(LuaEvent.SmallGame.UIEvent, "OnUIEvent", self)
	--平台事件
	Globals.pipeMgr:Bind(EEvent.PipeMsg.DebugModel, "OnDebugModel", self)
end

function GMController:OnApplicationStart()
    if(Globals.gameModel.platformArg.bDebugMode) then
        Globals.uiMgr:OpenView("GMView")
    end
end

function GMController:OnUIEvent(msg)
	--关闭加载界面
	if msg.id == "Loading" and msg.step == 4 then
		local autoGame = Util.ReadINI('Debug', 'AutoGame', 0)
		local autoLoad = Util.ReadINI('Debug', 'AutoLoad', 0)
		if autoGame > 0 and (autoGame == 1 or autoGame - 1 == Globals.gameModel.platformArg.gameId) then
			Globals.timerMgr:AddTimer(function()
				LMessage:Dispatch(LuaEvent.SmallGame.KeyEvent, Const.KeyEvent.Click, {id = "Auto"})
			end, 0, 3)
		end
		if autoLoad > 0 and (autoLoad == 1 or autoLoad - 1 == Globals.gameModel.platformArg.gameId) then
			Globals.timerMgr:AddTimer(function()
				LMessage:Dispatch(LuaEvent.Common.GameQuit, Const.QuitReason.Client, "客户端调试加载资源退出")
			end, 0, 5)
		end
	end
end

function GMController:OnDebugModel(msg)
	if msg.id == "SetDebugModel" then
		Globals.uiMgr:FloatMsg("Set Mode Successfully")
		LMessage:Dispatch(LuaEvent.GM.HideGMPanel)
	end
	LMessage:Dispatch(LuaEvent.SmallGame.DebugModel, msg)
end

return GMController