--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:这个目录下的ViewData是用用来配置需要覆盖的或者新增的界面的
--     创建时间:2022/05/13 
--------------------------------------------------------------------------------
local ViewData = {
    --游戏界面
    ["SlotView"] = {viewPath = "GameLogic.Module.Slot.View.SlotView", prefabPath = "Prefab/UI/Slot/Main/SlotView"},
	--比例界面
	["DenomView"] = {viewPath = "GameLogic.Module.Slot.View.DenomView", prefabPath = "Prefab/UI/Slot/Denom/DenomView"},
	--说明界面
	["IntroduceView"] = {viewPath = "GameLogic.Module.Slot.View.IntroduceView", prefabPath = "Prefab/UI/Slot/Introduce/IntroduceView"},
	--预览界面
	["PreviewerView"] = {viewPath = "GameLogic.Module.Slot.View.PreviewerView", prefabPath = "Prefab/UI/Slot/Previewer/PreviewerView"},
	--技巧游戏界面
	["SkillView"] = {viewPath = "GameLogic.Module.Slot.View.SkillView", prefabPath = "Prefab/UI/Slot/SkillGame/SkillView"},
	--过渡界面
	["TransitionView"] = {viewPath = "GameExtend.Module.Slot.View.TransitionView", prefabPath = "Prefab/UI/Slot/Pop/TransitionView"},
	--轮盘界面
	["WheelView"] = {viewPath = "GameExtend.Module.Slot.View.WheelView", prefabPath = "Prefab/UI/Slot/Pop/WheelView"},
	--link游戏
	["LinkView"] = {viewPath = "GameExtend.Module.Slot.View.LinkView", prefabPath = "Prefab/UI/Slot/Link/LinkView"},
}

return ViewData