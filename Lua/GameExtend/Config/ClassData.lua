--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:所有可实例化的Lua脚本都在这列举,方便重写引用
--     创建时间:2023/09/20  
--------------------------------------------------------------------------------
local ClassData = {
	--GM
	GMPanel = "GameLogic.Module.GM.View.GMPanel",
	--GMShortcutPanel = "GameLogic.Module.GM.View.GMShortcutPanel",
	GMFunc = "GameLogic.Module.GM.GMFunc",
	GMFuncExt = "GameLogic.Module.GM.GMFuncExt",
	
	--公共类
	ButtonItem = "GameLogic.Module.Slot.Common.ButtonItem",
	EffectItem = "GameLogic.Module.Slot.Common.EffectItem",
	RollItem = "GameLogic.Module.Slot.Common.RollItem",
	RollMultipleItem = "GameLogic.Module.Slot.Common.RollMultipleItem",
	Follower = "GameLogic.Module.Slot.Common.Follower",
	
	--功能类
	OneLine = "GameLogic.Module.Slot.Game.OneLine",
	--OneRound = "GameLogic.Module.Slot.Game.OneRound",
	ScrollFocus = "GameLogic.Module.Slot.Game.ScrollFocus",
	ScrollShade = "GameLogic.Module.Slot.Game.ScrollShade",
	
	
	--技巧游戏类
	MatchUp = "GameLogic.Module.Slot.SkillGame.MatchUp",
	StickBall = "GameLogic.Module.Slot.SkillGame.StickBall",
	
	--模拟类
	PlatSimulate = "GameLogic.Module.Slot.Simulate.PlatSimulate",
	--GameResult = "GameLogic.Module.Slot.Simulate.GameResult",
	
	--特效类
	NormalEffect = "GameLogic.Module.Slot.Effect.SpurtCoinEffect",
	--BigWinEffect = "GameLogic.Module.Slot.Effect.SpurtCoinEffect",
	--JackPotEffect = "GameLogic.Module.Slot.Effect.JackPotCoinEffect",
	
	--主逻辑类
	SlotView = "GameLogic.Module.Slot.View.SlotView",
	--SceneView = "GameLogic.Module.Slot.View.SceneView",
	--RollView = "GameLogic.Module.Slot.View.RollView",
	MenuView = "GameLogic.Module.Slot.View.MenuView",
	EffectView = "GameLogic.Module.Slot.View.EffectView",
	DenomView = "GameLogic.Module.Slot.View.DenomView",
	IntroduceView = "GameLogic.Module.Slot.View.IntroduceView",
	PreviewerView = "GameLogic.Module.Slot.View.PreviewerView",
	SkillView = "GameLogic.Module.Slot.View.SkillView",
	
	-- 拓展类
	MagmaView = "GameExtend.Module.Slot.View.MagmaView",
	SceneJackpotView = "GameExtend.Module.Slot.View.SceneJackpotView", -- scene彩金
	SceneFireBallView = "GameExtend.Module.Slot.View.SceneFireBallView", -- scene火球
	SceneNpcView = "GameExtend.Module.Slot.View.SceneNpcView", -- scene的npc
	RollFireBallView = "GameExtend.Module.Slot.View.RollFireBallView", -- scene的npc
	
	--继承类(修改)
	GMShortcutPanel = "GameExtend.Module.GM.View.GMShortcutPanel",
	
	SceneView = "GameExtend.Module.Slot.View.SceneView",
	RollView = "GameExtend.Module.Slot.View.RollView",
	
	OneRound = "GameExtend.Module.Slot.Game.OneRound",
	GameResult = "GameExtend.Module.Slot.Simulate.GameResult",
	
	BigWinEffect = "GameExtend.Module.Slot.Effect.RankScrollNumEffect",
	JackPotEffect = "GameExtend.Module.Slot.Effect.JackpotScrollNumEffect",
}

return ClassData
