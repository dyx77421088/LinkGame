--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:配置游戏所需要的所有配置
--     创建时间:2023/02/07 
--------------------------------------------------------------------------------
Const.ChessType = {
	Fork = 11, -- 叉子
	Wild = 12, -- 金币
	Scatter = 13, -- 小恶魔
	WildScatter = 14, -- 火焰击中scatter显示的金币
	Jackpot = 15, -- 彩金图标
}
-- SlotObject prefab下的一些名
Const.SlotObject = {
	NamStr = {
		-- FireBall = "effect/ng_eff_fireBall_hand_my", -- 球和火焰的父节点（slotObject下的）
		-- FireBall = "effect/ng_eff_fireBall_free01", -- 球和火焰的父节点（slotObject下的）
		FireBall = "effect/fireBall", -- 球和火焰的父节点（slotObject下的）
		-- FireBall = "effect/fireBallCs", -- 测试用的
		-- FireBallTarget = "effect/ng_eff_fireBall_free01", -- 可以设置目标的
		FireBrust = "effect/ng_eff_FireBrust", -- 火球爆炸特效（slotObject下的）
		XiaZa = "effect/ng_eff_TransforToNor_xiazha", -- 恶魔下砸的特效
		JianShe = "effect/fg_eff_jianshe", -- 岩浆到棋子上的溅射效果

		Npc = "npc", -- npc
		BigNpc = "bigNpc", -- bigNpc
	}
}
local ConfigData = {
	--资源
	atlasName = "Slot/Main/SlotAtlas",
	prefabName = "Slot/Main/SlotObject", -- slotObject目录
	-- 小恶魔丢火球相关的配置
	fireBall = {
		sceneMoveTime = 0.5, -- 从scene场景移动的时间
		sceneFireBrustTime = 0.5, -- scenne场景火球爆炸持续时间（然后再分裂）

		rollMoveTime = 0.4, -- 在滚轮场景中火球移动到棋子的时间
		rollInterval = 0.1, -- 火球之间的间隔时间
		rollBrustTime = 1, -- 火球爆炸的持续时间
		rollFlMoveTime = 0.5, -- 火球遇到叉子之后要分裂，飞行的时间
	},
	--滚轮
	roll = {
		direction = Vector3.down, --滚动方向 (0, -1, 0)
		rows = 3, --界面棋子行数
		columns = 5, --界面棋子列数
		count = 30, --棋子总数量,每列上下最少加一个((rows+2)*columns)
		regions = 222, --棋子行距
		spaces = {0, 209, 415, 621, 832}, --棋子列距
		cells = {}, --棋子占用数量(例:10号棋子2个占用,cells = {[10] = 2})
		stopTime = 1.2, --自动停下时间
		intervalTime = 0, --每列停下间隔时间
		speeds = 2800, -- 速度
		rollBacks = {
			startDistance = 30, --棋子开始滚动拉升距离
			startTime = 0.2, --棋子开始滚动拉升时间
			stopDistance = 150, --棋子回滚距离
			stopTime = 0.3, --棋子回滚时间
		},
	},
	--物种
	chess = {
		count = 12, --物种总数量
		showCnt = 12, --滚动物种显示数量
		odds = { --物种赔率
			{0, 0, 100, 160, 240},
			{0, 0, 100, 160, 240},
			{0, 0, 120, 200, 240}, 
			{0, 0, 120, 200, 240},
			{0, 0, 200, 240, 400}, 
			{0, 0, 200, 240, 400},
			{0, 0, 240, 320, 600},
			{0, 0, 240, 320, 600},
			{0, 0, 320, 400, 800},
			{0, 0, 0, 0, 0},
			{0, 0, 0, 0, 0},
			{0, 0, 0, 0, 0, 0, 0, 0, 0},
			{0, 0, 0, 0, 0, 0, 0, 0, 0},
			{0, 0, 0, 0, 0},
			{0, 0, 0, 0, 0},
			{0, 0, 0, 0, 0},
		},
	},
	--中奖线(序号从下到上递增)
	lines = {
		{ 2, 2, 2, 2, 2 },
		{ 1, 1, 1, 1, 1 },
		{ 3, 3, 3, 3, 3 },
		{ 1, 2, 3, 2, 1 },
		{ 3, 2, 1, 2, 3 },
		
		{ 1, 1, 2, 1, 1 },
		{ 3, 3, 2, 3, 3 },
		{ 2, 3, 3, 3, 2 },
		{ 2, 1, 1, 1, 2 },
		{ 1, 2, 2, 2, 1 },
		
		{ 3, 2, 2, 2, 3 },
		{ 1, 2, 1, 2, 1 },
		{ 3, 2, 3, 2, 3 },
		{ 2, 1, 2, 1, 2 },
		{ 2, 3, 2, 3, 2 },
		
		{ 2, 2, 1, 2, 2 },
		{ 2, 2, 3, 2, 2 },
		{ 1, 3, 1, 3, 1 },
		{ 3, 1, 3, 1, 3 },
		{ 2, 1, 3, 1, 2 },
		
		{ 2, 3, 1, 3, 2 },
		{ 1, 1, 3, 1, 1 },
		{ 3, 3, 1, 3, 3 },
		{ 1, 3, 3, 3, 1 },
		{ 3, 1, 1, 1, 3 },
		
		{ 1, 3, 2, 3, 1 },
		{ 3, 1, 2, 1, 3 },
		{ 1, 1, 2, 3, 3 },
		{ 3, 3, 2, 1, 1 },
		{ 2, 1, 2, 3, 2 },
	},
	--奖项
	awards = {
		freeOnCount = 3, --触发免费数量
		freeOnLine = false, --棋子依赖线
		bonusOnCount = _MaxNumber, --触发大奖数量
		bonusOnLine = false,
		linkOnCount = _MaxNumber, --触发公共奖数量
		linkOnLine = false,

		-- normalGiveFreeCount = {0, 0, 7, 10, 15}, -- 普通游戏触发的免费次数，3个图标为7次 ...
		-- freeGiveFreeCount = {0, 0, 3, 4, 5}, -- 免费游戏触发的免费次数， 3个图标为3次 ...

		-- 测试所以设置赠送的次数少一点
		normalGiveFreeCount = {0, 0, 2, 3, 3}, 
		freeGiveFreeCount = {0, 0, 1, 1, 1},
	},
	--赢分等级
	winPoints = {0, 5, 10},
-- 火球砸中fork（叉子）把周围的替换成wild (以叉子为中心替换四周的)
	forkRepWildPos = {{0, 1}, {0, -1}, {1, 0}, {-1, 0}},
	-- forkRepWildPos = {{0, 1}, {0, -1}, {1, 0}, {-1, 0}, {1, 1}, {1, -1}, {-1, 1}, {-1, -1}},
	caijin = {"MINI", "MINOR", "MAJOR", "MEGA", "GRAND"}, -- 彩金(在恶魔下方显示的spine)
	caijin2 = {"JACKPOT", "MINOR", "MAJOR", "MEGA", "GRAND"}, -- 彩金(屏幕中间的spine)

	-- sceneJackpot 相关的
	isChangeJackpot = true, -- 是否改变从1开始改变彩金
	isMoveJackpot = true,  -- 场景上的彩金否移动
	jackpotMoveTime = 1, -- 移动时间
	jackpotScrollTime = 1, -- 滚分的时间

	useCamera = false, -- 是否使用摄像机观察npc

	debugFireBall = false, -- debug火球，时间缩放为debugTimeScale
	debugTimeScale = 0.2, -- debug的倍速

	debugFreeToNormal = false, -- debug免费游戏到普通游戏
	debugFreeToNormalZaDiTimeScale = 1, -- 大恶魔砸地速度
	debugFreeToNormalXEMTimeScale = 1, -- 小恶魔出来的速度
	timeScale = 1, -- 最初的速度

	-- 是否debug link游戏（为true每次结果表现都会进）
	debugLinkGame = true,
}
Time.timeScale = ConfigData.timeScale
return ConfigData