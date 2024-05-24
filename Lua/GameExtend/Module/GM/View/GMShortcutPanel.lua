local GMShortcutPanel = require "GameLogic.Module.GM.View.GMShortcutPanel"
GMShortcutPanel = BaseClass("GMShortcutPanelEditor", GMShortcutPanel)

 
--快捷键菜单
function GMShortcutPanel:GetButtons()
	return {
		{"加速×1", "SetSpeed"},
		{"RANDOM", "SetDebugModel", 0},
		{"LOSE", "SetDebugModel", 1, 0},
		{"WIN", "SetDebugModel", 1, 1},
		{"FREE GAME", "SetDebugModel", 1, 2},
		{"BONUS GAME", "SetDebugModel", 1, 3},
		{"LINK GAME", "SetDebugModel", 1, 4},
	}
end

 
return GMShortcutPanel