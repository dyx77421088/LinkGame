--------------------------------------------------------------------------------
--     作者: 运行过程生成，不要自己改！不需要自己改！不需要自己改！
--     文件描述: 收集GameExtend/Config目录下的所有配置文件,运行过程中加载这里收集的配置去覆盖原有配置
--     创建时间: 2024/4/12
--------------------------------------------------------------------------------
local data = {
	["AssetData"] = "GameExtend.Config.AssetData", -- 声音资源
	["SlotData"] = "GameExtend.Config.SlotData",
	["ClassData"] = "GameExtend.Config.ClassData", -- 自定义的可实例化的lua
	["Cs"] = "GameExtend.Config.Cs",
	["ViewData"] = "GameExtend.Config.ViewData", -- 界面资源
	["SoundData"] = "GameExtend.Config.SoundData", -- 声音
}
return data