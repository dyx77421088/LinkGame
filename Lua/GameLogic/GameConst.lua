--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:定义GameLogic目录一些常见的常量
--     创建时间:2022/04/23 
--------------------------------------------------------------------------------
--退出小游戏原因
Const.QuitReason = {
    Client = 1, 	--用户主动点了退出
    Kick = 2, 		--服务端踢了前端
    Net = 3,  		--其他原因，归结到网络那了
}

--游戏类型
Const.GameType = {
	Base = 0,
	Wheel = 1,		--轮盘
	Slot = 2,		--拉霸
	Card = 3,		--卡牌
	[1] = "Wheel",
	[2] = "Slot",
	[3] = "Card",
}