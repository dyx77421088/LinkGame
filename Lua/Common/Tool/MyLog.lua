--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:各自打印自己的日志 每个程序一个颜色
--     创建时间:22/02/2021 
--------------------------------------------------------------------------------
local Debugger = UnityEngine.Debug
-- local LogType = CS.UnityEngine.LogType
-- Debugger.unityLogger.logEnabled = true

--在这里添加自己的名字
local author = {
    [1] = "yhj",
	[2] = "zjy",
	[3] = "hzp",
	[4] = "lyy",
}

--按照名字和序号的映射在这里添加自己日志的颜色
local logColor = {
    [1] = "#008BFF",
    [2] = "#FF8C00",
    [3] = "#B2FF00",
    [4] = "#00FFEA",
    [5] = "#FF00FF",
    [6] = "#905DD9",
    [7] = "#33F1F0",
    [8] = "#203EB4",
    [9] = "mauve",
    [10] = "yellow",
    [11] = "green",
}

local showLog = nil

--==============================--
--addby:yjp
--desc:显示其他人的log，填写0默认显示所有的开发者的日志
--@param: int 开发者序号, int 开发者序号, int 开发者序号....
--return:nil
--time:2021-02-22 17:47:00
--==============================--
local function ShowOtherLog(...)
    local arg = { ... }
    if #arg == 0 then
        showLog = nil
        return
    end
    showLog = {}
    if arg[1] == 0 then
        for k, v in pairs(author) do
            showLog[k] = true
        end
        return
    end
    for k, v in pairs(arg) do
        showLog[(v)] = true
    end
end

--填上需要显示的log
-- ShowOtherLog(1)
--填0表示全部显示
ShowOtherLog(0)

--==============================--
--addby:yjp
--desc:给字体染色
--@nTag:int  在logColor中的颜色序号 
--return:拼接好的带颜色标记的字符串
--time:2021-02-22 17:49:33
--==============================--
local function ToColorStr(nTag, str)
    return debug.traceback("<color=" .. logColor[nTag] .. ">[" .. author[nTag] .. "]" .. str .. "</color>")
end

--==============================--
--addby:yjp
--desc:是否打印当前开发者序号的日志
--@nTag:int 开发者序号 
--return:bool 是否打印
--time:2021-02-22 17:52:03
--==============================--
local function CheckIsShow(nTag)
    if showLog == nil then
        return false
    end
    return showLog[nTag]
end


function G_ConcartStr(...)
    local arg_len = select("#", ...)
    local arg = { ... }
    for i = 1, arg_len do --arg里面有nil会导致报错
        arg[i] = tostring(arg[i])
    end
    local str = table.concat(arg, " ,")
    return str
end

--==============================--
--addby:yjp
--desc:全局打印方法 不过是通过调用Unity的Debugger去打印
--@param:跟print的参数一样的传入
--return:nil
--time:2021-02-22 19:13:34
--==============================--
function G_print(...)
    local str =  string.format("%s\n\n<filePath>%s</filePath><line>%s</line>", debug.traceback(G_ConcartStr(...)), debug.getinfo(2).short_src , debug.getinfo(2).currentline)
    Debugger.Log(str)
end

--==============================--
--addby:yjp
--desc:全局打印警告信息 不过是通过调用Unity的Debugger去打印
--@param:跟print的参数一样的传入
--return:nil
--time:2021-02-22 19:14:17
--==============================--
function G_printWarning(...)
    local str =  string.format("%s\n\n<filePath>%s</filePath><line>%s</line>", debug.traceback(G_ConcartStr(...)), debug.getinfo(2).short_src , debug.getinfo(2).currentline)
    Debugger.LogWarning(str)
end

--==============================--
--addby:yjp
--desc:全局打印错误信息 不过是通过调用Unity的Debugger去打印
--@param:跟print的参数一样的传入
--return:nil
--time:2021-02-22 19:21:09
--==============================--
function G_printerror(...)
    local str =  string.format("[非报错提示:]%s\n\n<filePath>%s</filePath><line>%s</line>", debug.traceback(G_ConcartStr(...)), debug.getinfo(2).short_src , debug.getinfo(2).currentline)
    Debugger.LogError(str)
end

--打印超过1.0e14的值, string.format 里面的%d，不能传入超过一定值。不然直接变成负数
function G_PrintUnit64(num)
    if num >= 1.0e14 then
        local low = num % 1.0e9
        local high = math.floor(num / 1.0e9)
        return string.format("%s%09d", tostring(high), low)
        -- print(tostring(high) .. string.format("%09d", low))
    else
        return tostring(num)
    end
end

function G_DumpTable(t)
    for k, v in pairs(t) do
        if v ~= nil then
            print("Key: {0}, Value: {1}", tostring(k), tostring(v))
        else
            print("Key: {0}, Value nil", tostring(k))
        end
    end
end

function G_PrintTable(tab)
    local str = {}
    local hasLog = {}
    local function internal(tab, indent)
        for k, v in pairs(tab) do
            if type(v) == "table" then    
                table.insert(str, indent)
                table.insert(str, tostring(k))
                table.insert(str, ":\n")            
                if (hasLog[v]) then
                    table.insert(str, indent .. "死循环输出过滤" .. "\n")
                    return
                end
                hasLog[v] = true
                internal(v, indent .. ' ')
            else
                table.insert(str, indent)
                table.insert(str, tostring(k))
                table.insert(str, ": ")
                table.insert(str, tostring(v))
                table.insert(str, "\n")
            end
        end
    end

    internal(tab, '')
    return table.concat(str, '')
end

function G_PrintLua(name, lib)
    local m
    lib = lib or _G

    for w in string.gmatch(name, "%w+") do
        lib = lib[w]
    end

    m = lib

    if (m == nil) then
        print("Lua Module {0} not exists", name)
        return
    end

    print("-----------------Dump Table {0}-----------------", name)
    if (type(m) == "table") then
        for k, v in pairs(m) do
            print("Key: {0}, Value: {1}", k, tostring(v))
        end
    end

    local meta = getmetatable(m)
    print("-----------------Dump meta {0}-----------------", name)

    while meta ~= nil and meta ~= m do
        for k, v in pairs(meta) do
            if k ~= nil then
                print("Key: {0}, Value: {1}", tostring(k), tostring(v))
            end
        end

        meta = getmetatable(meta)
    end

    print("-----------------Dump meta Over-----------------")
    print("-----------------Dump Table Over-----------------")
end

----
--==============================--
--addby:yjp
--desc:局部方法  输出日志
--@param:跟print的参数一样的传入
--return:nil
--time:2021-02-22 19:28:23
--==============================--
local function _MyLog(...)
    if CheckIsShow(_Author) then
        local str =  string.format("%s\n\n<filePath>%s</filePath><line>%s</line>", ToColorStr(_Author, G_ConcartStr(...)), debug.getinfo(2).short_src , debug.getinfo(2).currentline)
        Debugger.Log(str)
    end
end

--==============================--
--addby:yjp
--desc:局部方法 打印错误日志
--@param:跟print的参数一样的传入
--return:
--time:2021-02-22 19:41:14
--==============================--
local function _MyLogError(...)
    if CheckIsShow(_Author) then
        local str =  string.format("%s\n\n<filePath>%s</filePath><line>%s</line>", ToColorStr(_Author, G_ConcartStr(...)), debug.getinfo(2).short_src , debug.getinfo(2).currentline)
        Debugger.LogError(str)
    end
end

--==============================--
--addby:yjp
--desc:局部方法 打印警告日志
--@param:跟print的参数一样的传入
--return:nil
--time:2021-02-22 19:42:53
--==============================--
local function _MyLogWarn(...)
    if CheckIsShow(_Author) then
        local str =  string.format("%s\n\n<filePath>%s</filePath><line>%s</line>", ToColorStr(_Author, G_ConcartStr(...)), debug.getinfo(2).short_src , debug.getinfo(2).currentline)
        Debugger.LogWarning(str)
    end
end

--==============================--
--addby:yjp
--desc:动态改变打印编号
--@value:int  设置编号
--return:nil
--time:2021-02-22 19:43:27
--==============================--
function MyLog_SetAuthor(value) -- MyLog_SetAuthor(8)
    ShowOtherLog(value)
end

--==============================--
--addby:yjp
--desc:设置是否开启日志,暂时用不了,UnityLogger类没有导出
--@enabled:bool 是否开启
--time:2020-11-27 20:21:00
--==============================--
function MyLog_SetLogEnable(enabled)
    do
        return
    end
    Debugger.unityLogger.logEnabled = enabled
end

--==============================--
--addby:yjp
--desc:是否开启日志打印
--@isActive:bool 是否开启
--return:nil
--time:2021-02-22 19:47:27
--==============================--
function ShowMyLog(isActive)
    local function nothing() end
    MyLog = isActive and _MyLog or nothing
    MyLogError = isActive and _MyLogError or nothing
    MyLogWarn = isActive and _MyLogWarn or nothing
end

ShowMyLog(true)