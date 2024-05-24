-- TaskAPI.lua
-- @author: zhangliang
-- @note:
--  A simple implementation of async-task style programming interface
--  see Example.lua for usage
-- @TODO:
--  tasks hierachy visualizer, use gameObject hierachy to show running tasks info
-- 2021.7.29
local TaskAux = require "Base.Task.TaskAux"

local _M = {}

-- extend TaskAPI by importing builtin/other Tasks modules
-- build <create task> and <await task> api
-- eg. here is a module m contains a Task definitions: m.AbcTask
-- after importing, there APIs area generated on TaskAPI module:
--  TaskAPI.AbcTask(), function that creates AbcTask
--  TaskAPI.AwaitAbc(), function that created AbcTask and await on it
local function ExtendTaskAPIFromModule(moduleOrPath, createAwaitAPI)
    local m = moduleOrPath
    if type(m) == "string" then
        m = require(moduleOrPath)
    end

    for k, v in pairs(m) do
        if type(v) == "table" then
            if v.clsname then
                local name, taskClass = k, v
                -- build api that create a task
                _M[name] = function(...)
                    return taskClass.New(...)
                end
                -- build api that create and await on a task
                if createAwaitAPI then
                    local prefix = string.match(name, "^(.*)Tasks?$")
                    _M["Await" .. prefix] = function(...)
                        return _M.Await(taskClass.New(...))
                    end
                end
            else
                ExtendTaskAPIFromModule(v, createAwaitAPI)
            end
        end
    end
end

xpcallex(function()
    ExtendTaskAPIFromModule("Base.Task.BuiltinTasks", false)
    ExtendTaskAPIFromModule("Base.Task.CommonTasks.TaskInit", true)
end)

-- [internal]
-- #region local function
local function _Await(any, propagateError, ...)
    if type(any) == "function" then
        any = _M.CoroutineTask(any, ...)
    elseif TaskAux.IsTween(any) then
        any = _M.TweenTask(any)
    end

    local ok, results
    if TaskAux.IsTask(any) then
        local task = any
        Globals.taskMgr:_AddTask(task)
        if (not task:IsDone()) then
            coroutine.yield(task)
        end
        local hasError = task:HasError()
        results = hasError and task:Error() or task:GetResults()
        ok = (not hasError)
    else
        ok = true
        coroutine.yield(any)
    end

    if propagateError then
        if (not ok) then
            error(results)
        else
            if results then
                return table.unpack(results)
            end
        end
    else
        if (ok and results) then
            return ok, table.unpack(results)
        else
            return ok, results
        end
    end
end
-- #endregion local function

-- Async code entrance
-- @func: function, this function is a async procedure that can use Await* APIs to await on tasks
function _M.Async(func, ...)
    return Globals.taskMgr:_AddTask(_M.CoroutineTask(func, ...))
end

-- post a Task in non-async code and use a callback to receive finish event
-- @task: Task
-- @onDoneCallback: Action<Task>, when Task finish running, this callback will be invoked
function _M.Post(task, onDoneCallback)
    if TaskAux.IsTask(task) then
        task:OnDone(onDoneCallback)
        Globals.taskMgr:_AddTask(task)
    end
    return task
end

-- #region Await* APIs
-- Await on a function, Task, Tween or anything else
-- Await* APIs can be used inside this function
-- NOTE:
--  any error will propagate up(throw exception),
--  which means if a error occured in this function or task, stack will rewind immediately,
--  and further code will not be executed.
function _M.Await(any, ...)
    return _Await(any, true, ...)
end

-- Await on a function, Task, Tween or anything else, catch error and stop error propagation
-- Await* APIs can be used inside this function
-- NOTE:
--  this function will not propagate error(not throw exception)
-- @return: like pcall
--  first return value is a boolean flag
--  if true, followed by the return value of the function or task
--  if false, followed by error message
function _M.AwaitCatchError(any, ...)
    return _Await(any, false, ...)
end

-- Await until next frame
function _M.AwaitNextFrame()
    return _M.Await(nil)
end

-- Await until next late update
function _M.AwaitLateUpdate()
    return _M.Await(_M.WaitForLateUpdateTask())
end

-- Await until next fixed update
function _M.AwaitFixedUpdate()
    return _M.Await(_M.WaitForFixedUpdateTask())
end

-- Await until this end of frame
function _M.AwaitEndOfFrame()
    return _M.Await(_M.WaitForEndOfFrameTask())
end

-- Await until <seconds> pass
-- @seconds: seconds
-- @realtime: use realtime instead of UnityEngine.Time.time which can be affected by time scale
function _M.AwaitSeconds(seconds, realtime)
    return _M.Await(_M.WaitForSecondsTask(seconds, realtime))
end

-- Await until predicate function returns true
-- @pred: Func<bool>, predicate function
function _M.AwaitUntil(pred)
    return _M.Await(_M.WaitUntilTask(pred))
end

-- Await while predicate function returns true
-- @pred: Func<bool>, predicate function
function _M.AwaitWhile(pred)
    return _M.Await(_M.WaitWhileTask(pred))
end

-- Await on all Tasks, continue when all of them have finshed running
-- NOTE:
--  this function will not propagate error from Tasks
--  if you want to know if there is any error in individual Tasks, you will have to check each one of them
function _M.AwaitAll(...)
    if select("#", ...) > 0 then
        return _M.Await(_M.ParallelTasks(true, ...))
    end
end

-- Await on any Tasks, continue when any of them has finshed running
-- NOTE:
--  await for the first one out, but the other Tasks are still running, we just not waiting them but we won't interrupt them
--  this function will not propagate error from Tasks
--  if you want to know if there is any error in individual Tasks, you will have to check each one of them
function _M.AwaitAny(...)
    if select("#", ...) > 0 then
        return _M.Await(_M.ParallelTasks(false, ...))
    end
end

-- Run Tasks one after another, wait until all of them are finished
-- NOTE:
--  this function will not propagate error from Tasks
--  and if one Task in the middle has error, it won't stop running and just jump to the next one.
function _M.AwaitSequential(...)
    if select("#", ...) > 0 then
        return _M.Await(_M.SequentialTasks(...))
    end
end
-- #endregion Await* APIs

return _M