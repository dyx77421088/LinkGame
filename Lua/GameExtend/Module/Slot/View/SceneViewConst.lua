--[[ 
	定义一些scene场景中用的常量的
 ]]

Const.SceneViewEMO = {
	NameStr = {
		-- FireBallBirthPos = "firePos/birthPos", -- 火球抛出的出生点
		-- FireBallFlyPos = "firePos/flyPos", -- 火球抛出到这个点才开始分裂
		Npc = "npc", -- npcView（sceneNpcView.lua中管理）
		Effect = {
			FireBall = "effect/ng_eff_fireBall_hand_my", -- 球和火焰的父节点（slotview/scene下的）
			Qiu = "effect/ng_eff_fireBall_hand_my/qiu", -- 球的特效名
			HuoYan = "effect/ng_eff_fireBall_hand_my/Particle System (1)", -- 火焰的特效名
			YanJiang = "effect/ng_eff_MagmaSputterUp", -- 岩浆跳特效
			-- YanJiang = "effect/ng_eff_MagmaSputterUp", -- 岩浆跳特效
			
		},
		Animation = { -- npc的动画
			Idle = "Idle", -- idle 状态 （大小恶魔共用）
			BianShen = "BianShen", -- 变身动画 （大小恶魔共用）

			------------------------小恶魔专有的动画-------------------------------
			-- 这三个是普通赢奖和点击npc的动作
			Fly = "Fly", -- 飞
			RotateOne = "RotateOne", -- 三叉戟转一圈
			PaoZhuan = "PaoZhuan", -- 三叉戟前方转一圈

			PaoHuoQiu = "PaoHuoQiu", -- 抛火球

			-- 这三个是bigwin的时候播放的
			Win1 = "Win01",
			Win2 = "Win02",
			Win3 = "Win03",
			-----------------------------------------------------------------------

			------------------------大恶魔专有的动画-------------------------------
			Attack = "Attack", -- 这个动画是免费场景转换到普通场景的时候会锤地面
			-- （trigger）砸场景的动画，也可以用AttackPlane（int） = 1，2，3，4，5 ,不过用int的话播放完了需把它设为0，不然要一直播放的
			AttackPlane = "AttackPlane",
			AttackPlanes = {"AttackPlane1", "AttackPlane2", "AttackPlane3", "AttackPlane4", "AttackPlane5"},
			AttackPlane1 = "AttackPlane1",
			AttackPlane2 = "AttackPlane2",
			AttackPlane3 = "AttackPlane3",
			AttackPlane4 = "AttackPlane4",
			AttackPlane5 = "AttackPlane5",
			-----------------------------------------------------------------------

			Event = { -- 事件
				Idle = "Idle", -- idle 状态
				FlyEnd = "FlyEnd", -- 飞结束的事件
				PaoHuoQiuStart = "PaoHuoQiuStart", -- 抛火球的开始时的事件
				PaoHuoQiuFire = "PaoHuoQiuFire", -- 抛火球的发射时的事件
				PaoHuoQiuEnd = "PaoHuoQiuEnd", -- 抛火球的结束时的事件
				Win01End = "Win01End", -- 执行win动画结束后的事件
				Win02End = "Win02End", -- 执行win动画结束后的事件
				Win03End = "Win03End", -- 执行win动画结束后的事件

				BianShenStart = "BianShenStart", -- 小恶魔变身开始的事件
				BianShenEnd = "BianShenEnd", -- 小恶魔变身结束的事件


				------------------大恶魔相关的事件----------------------------------------
				AttackPlane = "AttackPlane", -- 锤子已经砸中平台的事件，12345都用的这个
				AttackPlaneEnd = "AttackPlaneEnd", -- 锤子砸中平台结束的事件，12345都用的这个
				AttackBianShenStart = "AttackBianShenStart", -- 砸地之后砸出一个小恶魔（免费场景=》普通场景）开始阶段
				AttackBianShen = "AttackBianShen", -- 砸地之后砸出一个小恶魔（免费场景=》普通场景）
			}
		}
	},
	FireBallType = {
		Idle = 1, -- idle 状态
		Start = 2, -- 开始状态
		Fly = 3, -- 火球抛出的状态
		End = 4, -- 火球停止 => 回到idle状态
		Hide = 5, -- 火球上下浮动暂时隐藏
	},

	-- 在sceneview 中 RevealScene 相关的
	RevealScene = {
		FireBallStart = "FireBallStart", -- 开始丢火球
		-- 丢火球结束在rollview中

		BigWin = 6, -- bigwin的时候scene的表现
		PlayAnim = "PlayAnim", -- scene场景中播放npc动画
		PlayBigAnim = "PlayBigAnim", -- scene场景中播放bigNpc动画
		JackpotShow = "JackpotShow", -- 在场景中显示彩金及彩金数值
		JackpotPlay = "JackpotPlay", -- 在场景中彩金开始滚动数值
		JackpotHide = "JackpotHide", -- 在场景中隐藏彩金及彩金数值

		BigWinStart = "BigWinStart", -- bigwin开始状态
		BigWinRollStop = "BigWinRollStop", -- 滚分结束（有多级bigwin，这是一个结束了之后)
		BigWinStop = "BigWinStop", -- bigwin停止
	}
}