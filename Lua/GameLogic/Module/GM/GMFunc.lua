--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:进行GM方法配置的地方,如果时小游戏变种的项目不要放在这里，放在GMFunExt文件
--     创建时间:2022/05/06 
--------------------------------------------------------------------------------
LuaEvent.GM = {
    HideGMPanel = "HideGMPanel",
}

local GMFunc = {
    ClickRunGM = {
        {
            --大类名称
            {"name", "常用"} ,
            --具体方法 
            --函数名/显示名/是否需要输入参数/提示/默认设置
            {"SetRunSpeed", "运行速度", false},
            --{"TestSound", "测试音效", false},
			{"TestMemory", "内存分析", true, "参数格式:TestMemory 文件保存路径", "TestMemory " .. UnityEngine.Application.dataPath .. "/../Memory/"},
            {"TestTransfer", "测试传闻", true, "参数格式:TestTransfer 文本内容 传闻滚动类型(1从右到左/2从下到上)", "TestTransfer 这是一条测试传闻信息！！！"},
			{"TestMessage", "测试飘字", true, "参数格式:TestMessage 文本内容", "TestMessage 这是一条测试飘字信息！！！"},
        },
        {
            --大类名称
            {"name", "小游戏"} ,
            --具体方法 
            --函数名/显示名/是否需要输入参数/提示/默认设置
            {"SetDebugModel", "设置开奖", true, "参数格式:SetDebugModel 模式(0正常/1指定) 结果(0输/1赢/2免费奖/3Bonus奖/4Link奖)", "SetDebugModel 1 1"},
            {"GetDebugModel", "显示调试数据", false},
        }
    }
}

function GMFunc.SetRunSpeed()
    Globals.uiMgr:OpenView("GMRunSpeedView")
    LMessage:Dispatch(LuaEvent.GM.HideGMPanel)
end

function GMFunc.TestMemory(path)
	path = path or UnityEngine.Application.dataPath .. "/../Memory/"
	Util.MakeSureDir(path)
	collectgarbage("collect")
	local file = path .. "_G" .. os.date("_%m_%d_%H_%M_%S_") .. ".txt";
	local content = "Memory used: " .. collectgarbage("count") .. "Kbytes\n\n"
	content = content .. get_debug_str_simple(_G)
	Util.WriteAllText(file, content)
	
	Globals.uiMgr:FloatMsg("成功生成！")
	LMessage:Dispatch(LuaEvent.GM.HideGMPanel)
end

function GMFunc.TestSound()
    if(not ComUtils.IsTestSound()) then
        Globals.uiMgr:FloatMsg("不在测试音效平台，当前功能无效")
        return
    end
    Globals.uiMgr:OpenView("SoundView")
    LMessage:Dispatch(LuaEvent.GM.HideGMPanel)
end

function GMFunc.TestTransfer(content, moveType)
    if(not content) then
        return
    end
    Globals.uiMgr:ShowTransfer({content = content, pause = true, moveType = moveType and tonumber(moveType) or nil})
    LMessage:Dispatch(LuaEvent.GM.HideGMPanel)
end

function GMFunc.TestMessage(content)
	if(not content) then
        return
    end
	Globals.uiMgr:FloatMsg(content)
	LMessage:Dispatch(LuaEvent.GM.HideGMPanel)
end

function GMFunc.SetDebugModel(model, resultType)
	Globals.pipeMgr:Send(EEvent.PipeMsg.DebugModel, {id = "SetDebugModel", data = {Mode = tonumber(model), ResultType = tonumber(resultType)}})
end

function GMFunc.GetDebugModel()
	Globals.uiMgr:OpenView("GMAlgorithmView")
    LMessage:Dispatch(LuaEvent.GM.HideGMPanel)
end

local ClassData = Globals.configMgr:GetConfig("ClassData")
local GMFuncExt = require (ClassData.GMFuncExt)
local quickOverride = false
local clickRunDictExt = {}
local addCache = {}
local clickRunDict = {}
local function Override()
    if(not GMFuncExt.ClickRunGM or #GMFuncExt.ClickRunGM <= 0) then
        return
    end
    --把GMFuncExt.ClickRunGM创建映射
    for i, funcList in ipairs(GMFuncExt.ClickRunGM) do
        local name = funcList[1][2]
        clickRunDictExt[name] = {}
        addCache[name] = funcList
        for j = 2, #funcList do
            local funcKey = funcList[j][1]
            clickRunDictExt[name][funcKey] = funcList[j]
        end
    end
    --看看GMfunc.ClickRunGM中有没有需要覆盖的
    for i, funcList in ipairs(GMFunc.ClickRunGM) do
        local name = funcList[1][2]
        for j = 2, #funcList do
            local funcKey = funcList[j][1]
            if(clickRunDictExt[name] and clickRunDictExt[name][funcKey]) then
                GMFunc.ClickRunGM[i][j] = clickRunDictExt[name][funcKey]
            end
        end
        clickRunDict[name] = true
    end
    --完整的没有的模块直接append到GMFunc.ClickRunGM
    for name, funcList in pairs(addCache) do
        if(not clickRunDict[name]) then
            table.insert(GMFunc.ClickRunGM, funcList)
        end
    end
end
if(quickOverride) then
    GMFunc.ClickRunGM = table.extend(GMFunc.ClickRunGM, GMFuncExt.ClickRunGM)
else
    Override()
end
for key, value in pairs(GMFuncExt) do
    if(key ~= "ClickRunGM") then
        GMFunc[key] = GMFuncExt[key]
    end
end


return GMFunc