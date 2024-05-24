--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:配置游戏所需要的所有配置
--     创建时间:2023/02/07 
--------------------------------------------------------------------------------
--棋子类型需要根据实际情况重新定义
Const.ChessType = {
	Wild = 9,
	Scatter = 10,
}

local ConfigData = {
	--资源
	atlasName = "Slot/Main/SlotAtlas",
	prefabName = "Slot/Main/SlotObject",
	--滚轮
	roll = {
		direction = Vector3.down, --滚动方向
		rows = 3, --界面棋子行数
		columns = 5, --界面棋子列数
		count = 25, --棋子总数量,每列上下最少加一个((rows+2)*columns)
		regions = 222, --棋子行距
		spaces = {0, 209, 415, 621, 832}, --棋子列距
		cells = {}, --棋子占用数量(例:10号棋子2个占用,cells = {[10] = 2})
		stopTime = 1.2, --自动停下时间
		intervalTime = 0.25, --每列停下间隔时间
		speeds = {
			minSpeed = 2000, --滚动初始速度
			maxSpeed = 2500, --滚动最大速度
			addSpeed = 500, -- 滚动加速度
		},
		rollBacks = {
			startDistance = 30, --棋子开始滚动拉升距离
			startTime = 0.2, --棋子开始滚动拉升时间
			stopDistance = 50, --棋子回滚距离
			stopTime = 0.3, --棋子回滚时间
		},
	},
	--物种
	chess = {
		count = 12, --物种总数量
		showCnt = 12, --滚动物种显示数量
		odds = { --物种赔率
			{0, 0, 12, 20, 40},
			{0, 0, 12, 20, 40},
			{0, 0, 12, 20, 40},
			{0, 0, 12, 40, 100},
			{0, 0, 12, 40, 100},
			{0, 0, 12, 40, 100},
			{0, 0, 20, 60, 200},
			{0, 0, 40, 100, 300},
			{0, 0, 60, 200, 500},
			{0,0, 0, 0, 0},
			{0, 0, 0, 0, 0},
			{0, 0, 0, 0, 0},
		},
	},
	--中奖线(序号从下到上递增)
	lines = {
		{2, 2, 2, 2, 2},
		{3, 3, 3, 3, 3},
		{1, 1, 1, 1, 1},
		{3, 2, 1, 2, 3},
		{1, 2, 3, 2, 1},
		{3, 2, 3, 2, 3},
		{2, 3, 2, 3, 2},
		{2, 1, 2, 1, 2},
		{1, 2, 3, 2, 1},
	},
	--奖项
	awards = {
		freeOnCount = 3, --触发免费数量
		freeOnLine = false, --棋子依赖线
		bonusOnCount = _MaxNumber, --触发大奖数量
		bonusOnLine = false,
		linkOnCount = _MaxNumber, --触发公共奖数量
		linkOnLine = false,
	},
	--赢分等级
	winPoints = {0, 5, 10},
}

return ConfigData