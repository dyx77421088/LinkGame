--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:绑定了LuaBehaviour，用来在Lua端提供Awake,Start,Update,FixedUpdate等各个阶段的逻辑
--     创建时间:2022/04/22 
--------------------------------------------------------------------------------
GameMainUpdate = {}
local inst = nil
function GameMainUpdate:Initialize()
    if not inst then
		inst = GameObject("GameMainUpdate")
		Util.SetFacade(inst, 1)
		inst:AddComponent(typeof(LuaFramework.LuaBehaviour))
		if _FrameRate ~= nil then
			UnityEngine.Application.targetFrameRate = _FrameRate
		end
		if _QualityLevel ~= nil then
			UnityEngine.QualitySettings.SetQualityLevel(_QualityLevel)
		end
	end
end

function GameMainUpdate:Awake()
    print("Lua Awake....")
    self.onGameQuit = LMessage:Register(LuaEvent.Common.GameQuit, "OnGameQuit", self)
end

function GameMainUpdate:Start()
    print("Lua Start....")
    LMessage:Dispatch(LuaEvent.Common.ApplicationStart)
end

--每帧都是先Update 再LateUpdate
function GameMainUpdate:Update()
    ComUtils.CheckUnload()
    Globals.timerMgr:Update()
    Globals.uiMgr:Update()
    Globals.configMgr:Update()
    LMessage:Dispatch(LuaEvent.Common.ApplicationUpdate)
end

function GameMainUpdate:LateUpdate()
    Globals.timerMgr:LateUpdate()
    LMessage:Dispatch(LuaEvent.Common.ApplicationLateUpdate)
end

function GameMainUpdate:OnApplicationPause()
    LMessage:Dispatch(LuaEvent.Common.ApplicationPause)
end

function GameMainUpdate:OnGameQuit(reasonType, reasonDesc)
	Globals.timerMgr:Dispose()
    Globals.uiMgr:Dispose()
	Globals.cameraMgr:Dispose()
	Globals.processMgr:Dispose()
	Globals.poolMgr:Dispose()
    Globals.soundMgr:Dispose()
    Globals.resMgr:Dispose()
    Globals.pipeMgr:Dispose()
    Globals.touchMgr:Dispose()
	Globals.ioMgr:Dispose()
	Globals.configMgr:Dispose()
    self:Dispose()
	ComUtils.SetTimeScale(1)
    EventManager.Inst:Send(EEvent.Common.EndGame, reasonType, reasonDesc)
end

function GameMainUpdate:Dispose()
	if inst then
		GameObject.Destroy(inst)
	end
    LMessage:UnRegister(LuaEvent.Common.GameQuit, self.onGameQuit)
end