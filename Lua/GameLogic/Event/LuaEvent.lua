--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:扩展Lua事件，全部定义小游戏中需要用到的事件
--     创建时间:2022/04/21 
--------------------------------------------------------------------------------
LuaEvent.SmallGame = {
	IncreaseCover = "IncreaseCover",  --增加遮挡的ui层数
    DecreaseCover = "DecreaseCover", --减少遮挡的ui层数
	Prepare = "Prepare", --准备游戏
	StartRound = "StartRound", --开始
    OneRound = "OneRound", --开始一局
    BetResult = "BetResult", --获取结果
    StopRound = "StopRound", --停止一局
	FinishRound = "FinishRound", --结束一局
	Reveal = "Reveal", --游戏表现
	Numerical = "Numerical", --分值表现
	PreviewBet = "PreviewBet", --预览
	DebugModel = "DebugModel", --调试
	Setting = "Setting", --游戏设置
	GameEvent = "GameEvent", --游戏事件
	UIEvent = "UIEvent", --UI事件
	KeyEvent = "KeyEvent", --按键事件
}