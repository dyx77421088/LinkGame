--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:绑定所有功能模块的Model和Controller
--     创建时间:2022/05/13 
--------------------------------------------------------------------------------
local Model = 
{
    loadingModel = "GameLogic.Module.Loading.LoadingModel",
    gmModel = "GameLogic.Module.GM.GMModel",
	soundModel = "GameLogic.Module.Sound.SoundModel",
    gameModel = "GameLogic.Module.Slot.SlotModel",
}

local Controller = 
{
    LoadingController = "GameLogic.Module.Loading.LoadingController",
    GMController = "GameLogic.Module.GM.GMController",
	SoundController = "GameLogic.Module.Sound.SoundController",
    GameController = "GameLogic.Module.Slot.SlotController",
}
local ModulesExt = require "GameExtend.ModulesExt"
for key, path in pairs(ModulesExt.Model) do
    Model[key] = path
end

for key, path in pairs(ModulesExt.Contoller) do
    Controller[key] = path
end

-- -- 设置随机数
-- math.randomseed(tostring(os.time()):reverse():sub(1,7))

-- disable_global(true)
local tempTable = {}
for _, path in pairs(Model) do
    local m = require(path)
    if m == nil or type(m) == "boolean" then
        error("Model did not return self:" .. path)
        return
    elseif tempTable[_] then
        error("Repeat Model:" .. path)
        return
    end
    if m.getInstance then
        tempTable[_] = m.getInstance()
    else
        tempTable[_] = m
    end
end
-- disable_global(false)
local initTable = {}
for _, m in pairs(tempTable) do
    --加入到Globals表
    Globals[_] = m 
    if m.InitComplete then
        initTable[_] = m
    end
end
--有些Model需要在初始化的时候访问其他Model，这时候就需要所有的Model都初始化完了再执行
for _, m in pairs(initTable) do
    m:InitComplete()
end
-- disable_global(true)
tempTable = {}
for _, path in pairs(Controller) do
    if tempTable[path] then
        error("Repeat Controller:" .. path)
        return
    end
    tempTable[path] = true
    local m = require(path)
    if m == nil or type(m) == "boolean" then
        error("Controller did not return self:" .. path)
        return
    end
    local inst = m.getInstance()
    inst:Initialize()
end
-- disable_global(false)