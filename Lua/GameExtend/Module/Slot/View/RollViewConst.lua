--[[ 
	定义一些scene场景中用的常量的
 ]]

 Const.RollViewEMO = {
	NameStr = {
		-- 普通 --》 免费 场景之间的切换的时候，需隐藏或显示这些
		Normal = "back/normal",
		NormalForce = "force/normal",
		Free = "back/free",
		FreeForce = "force/free",

		-- 免费场景中的 current OF total
		Current = "force/free/TopFourMagma/topBox/current",
		Total = "force/free/TopFourMagma/topBox/total",

		-- 岩浆
		MagmasEffects = "effect/magmas", 
	},

	-- 在rollview 中 RevealScene 相关的
	RevealScene = {
		FireBallEnd = "FireBallEnd", -- 丢火球结束状态
		FireBallToFork = "FireBallToFork", -- 火球碰到了叉子
		
		BigWin = 6, -- bigwin的时候scene的表现
		PlayAnim = 7, -- scene场景中播放npc动画
	},
	-- 在rollview 中 revealeffect相关的
	RevealEffect = {
		Magma = "magma", -- 播放岩浆特效
		MagmaShowChess = "magmaShowChess", -- 恶魔全部砸完了，就需要播放棋子显示出来的效果了
		
	}
}