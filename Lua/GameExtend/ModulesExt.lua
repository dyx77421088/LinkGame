--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:绑定所有功能模块的Model和Controller,这个文件专门用来覆盖GameLogic/Modules.lua中的Model和Controller
--     创建时间:2022/05/13 
--------------------------------------------------------------------------------
local ModulesExt = {}
ModulesExt.Model = {
	soundModel = "GameExtend.Module.Sound.SoundModel",
}

ModulesExt.Contoller = {
	SoundController = "GameExtend.Module.Sound.SoundController",
}

return ModulesExt