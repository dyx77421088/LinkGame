--公共事件
LuaEvent.Common = {
	ApplicationStart = "ApplicationStart",
	ApplicationUpdate = "ApplicationUpdate",
	ApplicationLateUpdate = "ApplicationLateUpdate",
	ApplicationFixedUpdate = "ApplicationFixedUpdate",
	ApplicationPause = "ApplicationPause",
	GameQuit = "GameQuit",
}

--UI公共事件
LuaEvent.UI = {
	UIViewBasePopChange = "UIViewBasePopChange",--某个界面弹出或者隐藏
	DisposeUIView = "DisposeUIView", --销毁界面
}

--加载事件
LuaEvent.Loading = {
    OpenLoading = "OpenLoading",
	LoadedLoading = "LoadedLoading", --加载完加载界面
    SetProgress = "SetProgress",
    AddNeedLoad = "AddNeedLoad", --增加需要加载的资源
    AddLoaded = "AddLoaded", --增加已经加载完的资源
	CloseLoading = "CloseLoading",
}

--音效事件
LuaEvent.Sound = {
	Play = "Play",
	Pause = "Pause",
	Stop = "Stop",
}