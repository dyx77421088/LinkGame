--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:所有需要显示的界面加在这里
--     创建时间:2021/10/26 
--------------------------------------------------------------------------------
local ViewData = {
	--飘字
	["MessageView"] = {viewPath = "GameLogic.UI.Message.MessageView", prefabPath = "Prefab/UI/Common/MessageView"},
	--传闻
	["MessageTransferView"] = {viewPath = "GameLogic.UI.Message.MessageTransferView", prefabPath = "Prefab/UI/Common/MessageTransferView"},
	--加载界面
	["LoadingView"] = {viewPath = "GameLogic.Module.Loading.View.LoadingView", prefabPath = "Prefab/UI/Loading/LoadingView"},
	--GM指令界面
	["GMView"] = {viewPath = "GameLogic.Module.GM.View.GMView", prefabPath = "Prefab/UI/GM/GMView"},
	--GM查看算法信息界面
	["GMAlgorithmView"] = {viewPath = "GameLogic.Module.GM.View.GMAlgorithmView", prefabPath = "Prefab/UI/GM/GMAlgorithmView"},
	--GM设置速度界面
	["GMRunSpeedView"] = {viewPath = "GameLogic.Module.GM.View.GMRunSpeedView", prefabPath = "Prefab/UI/GM/GMRunSpeedView"},
	--测试音效界面
	["SoundView"] = {viewPath = "GameLogic.Module.Sound.View.SoundView", prefabPath = "Prefab/UI/Sound/SoundView"},
}

return ViewData
