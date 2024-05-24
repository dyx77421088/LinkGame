-- DevLog.lua
-- @author: zhangliang
-- @note:
--  定义开发中要用的log，一般提交前都会把LogLevel提升到Warning以上
--  自定义log的prefix，过滤的时候用得上
--  参考TaskAux.lua:
--      1. 使用DefineLogFunctions函数给TaskAux增加这些Log函数: LogVerbose, Log, LogWarning, LogError
--      2. 在Task相关的开发模块中把TaskAux包含进来，然后使用：TaskAux.Log(...)
-- 2021.7.30
local _M = {}

_M.LogLevel = {
    Verbose = 0,
    Info    = 1,
    Warning = 2,
    Error   = 3,
    None    = 4,
}

local logFunc = {
    [_M.LogLevel.Verbose] = function(...) print(...) end,
    [_M.LogLevel.Info] = function(...) print(...) end,
    [_M.LogLevel.Warning] = function(...) printwarning(...) end,
    [_M.LogLevel.Error] = function(...) printerror(...) end,
}

function _M.DefineLogFunctions(module, logLevel, prefixFunc)
    module = module or {}
    module.logLevel = logLevel

    local function log(_logLevel, ...)
        if _logLevel >= module.logLevel then
            local argIndex, prefix = prefixFunc(...)
            logFunc[_logLevel](prefix, select(argIndex, ...))
        end
    end

    local function logformat(_logLevel, ...)
        if _logLevel >= module.logLevel then
            local argIndex, prefix = prefixFunc(...)
            local fmt = select(argIndex, ...)
            logFunc[_logLevel](prefix, string.format(fmt, select(argIndex + 1, ...)))
        end
    end

    for k, v in pairs(_M.LogLevel) do
        local key = "Log"
        if k ~= "Info" then
            key = key .. k
        end

        module["Is" .. k] = function()
            return v >= module.logLevel
        end

        module[key] = function(...)
            log(v, ...)
        end

        module[key .. "Format"] = function(...)
            logformat(v, ...)
        end
    end

    return module
end

return _M