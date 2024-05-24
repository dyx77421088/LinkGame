--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:require BaseLogic目录下的文件
--     创建时间:2022/04/21 
--------------------------------------------------------------------------------
require "Common.Init"--初始化Common目录文件
require "BaseLogic.Event.EEvent"
require "BaseLogic.Event.LuaEvent"
require "BaseLogic.BaseConst"
UIItem = require "BaseLogic.UI.UIItem"
UIViewBase = require "BaseLogic.UI.UIViewBase"
require "Common.Core.strict"
require "GameExtend.Module.Slot.View.Debug"

local define ={
	poolMgr = "BaseLogic.Manager.PoolMgr",
    ioMgr = "BaseLogic.Manager.IOMgr",
    timerMgr = "BaseLogic.Manager.TimerMgr",
    resMgr = "BaseLogic.Manager.ResMgr",
    uiMgr = "BaseLogic.Manager.UIMgr",
	cameraMgr = "BaseLogic.Manager.CameraMgr",
    soundMgr = "BaseLogic.Manager.SoundMgr",
    pipeMgr = "BaseLogic.Manager.PipeMgr",
    touchMgr = "BaseLogic.Manager.TouchMgr",
    configMgr = "BaseLogic.Manager.ConfigMgr",
	processMgr = "BaseLogic.Manager.ProcessMgr",
}
Globals.InitMgrs(define)
 
