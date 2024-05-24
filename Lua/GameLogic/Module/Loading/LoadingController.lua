--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:Loading模块的Controller，处理加载过程中的逻辑
--     创建时间:2022/04/23 
--------------------------------------------------------------------------------
local json = require 'cjson' 
local LoadingController = Singleton("LoadingController")

function LoadingController:__ctor()

end

function LoadingController:__delete()
    LMessage:UnRegister(LuaEvent.Common.ApplicationStart, self.OnApplicationStart)
    LMessage:UnRegister(LuaEvent.Loading.OpenLoading, self.onOpenLoading)
	LMessage:UnRegister(LuaEvent.Loading.AddNeedLoad, self.onAddNeedLoad)
	LMessage:UnRegister(LuaEvent.Loading.AddLoaded, self.onAddLoaded)
	LMessage:UnRegister(LuaEvent.SmallGame.Prepare, self.onPrepare)
	LMessage:UnRegister(LuaEvent.SmallGame.UIEvent, self.onUIEvent)
end

function LoadingController:Initialize()
    self.onApplicationStart = LMessage:Register(LuaEvent.Common.ApplicationStart, "OnApplicationStart", self)
    self.onOpenLoading = LMessage:Register(LuaEvent.Loading.OpenLoading, "OnOpenLoading", self)
    self.onAddNeedLoad = LMessage:Register(LuaEvent.Loading.AddNeedLoad, "OnAddNeedLoad", self)
    self.onAddLoaded = LMessage:Register(LuaEvent.Loading.AddLoaded, "OnAddLoaded", self)
	self.onPrepare = LMessage:Register(LuaEvent.SmallGame.Prepare, "OnPrepare", self)
	self.onUIEvent = LMessage:Register(LuaEvent.SmallGame.UIEvent, "OnUIEvent", self)
end

function LoadingController:OnApplicationStart()
    LMessage:Dispatch(LuaEvent.Loading.OpenLoading)
end

function LoadingController:OnOpenLoading()
    if(Globals.gameModel.platformArg.bHallLoading) then
        self:EnterHallLoading()
    else
        self:EnterSelfLoading()
    end
end

function LoadingController:OnAddNeedLoad(value)
    Globals.loadingModel.needLoad = Globals.loadingModel.needLoad + value
end

function LoadingController:OnAddLoaded(value)
    Globals.loadingModel.loaded = Globals.loadingModel.loaded + value
    local progress = Globals.loadingModel.loaded / Globals.loadingModel.needLoad
    self:SetProgress(progress)
end

function LoadingController:OnPrepare(msg)
	Globals.pipeMgr:Send(EEvent.PipeMsg.UIEvent, {id = "Loading", step = 3})
end

function LoadingController:OnUIEvent(msg)
	if msg.id == "Loading" then
		if msg.step == 4 and not Globals.gameModel.platformArg.bHallLoading then
			Globals.uiMgr:HideView("LoadingView")
		end
	end
end

function LoadingController:EnterHallLoading()
    Globals.soundMgr:Enable(false)
    Globals.pipeMgr:Send(EEvent.PipeMsg.UIEvent, {id = "Loading", step = 1})
    LMessage:Dispatch(LuaEvent.Loading.LoadedLoading)
    print("开始加载大厅Loading")
end

function LoadingController:EnterSelfLoading()
    Globals.soundMgr:Enable(false)
    Globals.uiMgr:OpenView("LoadingView", function(view)
        LMessage:Dispatch(LuaEvent.Loading.LoadedLoading)
    end)
	print("开始加载自身Loading")
end

function LoadingController:SetProgress(progress)
    if Globals.gameModel.platformArg.bHallLoading then
        Globals.pipeMgr:Send(EEvent.PipeMsg.UIEvent, {id = "Loading", step = 2, progress = progress})
    else
        Globals.uiMgr:OpenView("LoadingView", function(view)
			view:SetProgress(progress)
        end)
    end
	if(progress == 1) then
		Globals.timerMgr:AddTimer(function()
			Globals.soundMgr:Enable(true)
			--请求开始数据
			Globals.pipeMgr:Send(EEvent.PipeMsg.Prepare, {gameId = Globals.gameModel.platformArg.gameId, version = _Version})
		end, 0, 0.5)
	end
end

return LoadingController