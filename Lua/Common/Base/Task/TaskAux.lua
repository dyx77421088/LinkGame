-- TaskAux.lua
-- @author: zhangliang
-- @note: Task aux function
-- 2021.7.29
local DevLog = require "Common.Base.Task.DevLog"

local _M = {}

_M.EnableTaskVisualizer = false

local function BiTable(t)
    local rev = {}
    for k, v in pairs(t) do
        rev[v] = k
    end
    for k, v in pairs(rev) do
        t[k] = v
    end
    return t
end

_M.TaskStatus = BiTable({
    None        = 0,
    Running     = 1,
    Success     = 2,
    Error       = 3,
    Interrupt   = 4,
})

_M.UpdateTag = BiTable({
    Update      = 1,
    LateUpdate  = 2,
    FixedUpdate = 3,
    EndOfFrame  = 4,
})

DevLog.DefineLogFunctions(_M, DevLog.LogLevel.Warning, function(...)
    local task = select(1, ...)
    local prefix = string.format("[Task][%d", Time.frameCount)
    if task then
        prefix = string.format("%s@%s]:", prefix, task:ToString())
    else
        prefix = prefix .. "]:"
    end
    return 2, prefix
end)

function _M.VarargsToTaskArray(BuiltinTasks, ...)
    local ret = G_EmptyTable
    local len = select("#", ...)
    if len == 1 then
        local item = ...
        if type(item) == "table" and #item > 0 then
            ret = item
        else
            ret = { item }
        end
    elseif len > 1 then
        ret = { ... }
    end

    for i = #ret, 1, -1 do
        local item = ret[i]
        if (not _M.IsTask(item)) then
            if _M.IsTween(item) then
                ret[i] = BuiltinTasks.TweenTask.New(item)
            else
                table.remove(ret, i)
                _M.LogError(string.format("Argument %d is NOT a Task", i))
            end
        end
    end

    return ret
end

function _M.IsTask(obj)
    return obj and type(obj) == "table" and obj.IsTask
end

function _M.IsTween(obj)
    return obj and type(obj) == "userdata" and string.startwith(tostring(obj), "DG.Tweening")
end

function _M.ExportTaskModules(basePath, ...)
    local moduleNames = { ... }
    local ret = {}
    for _, name in ipairs(moduleNames) do
        local m = require(basePath .. "." .. name)
        ret[name] = m
    end
    return ret
end

return _M