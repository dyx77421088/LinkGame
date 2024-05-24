-- BuiltinTasks.lua
-- @author: zhangliang
-- @note: builtin tasks
-- 2021.7.29
local Task = require "Base.Task.Task"
local TaskAux = require "Base.Task.TaskAux"

local Log = TaskAux.Log
local TaskStatus = TaskAux.TaskStatus

local _M = {}

-- #region CoroutineTask
local CoroutineTask = BaseClass("CoroutineTask", Task)
_M.CoroutineTask = CoroutineTask

local function VarargsToArray(array, ...)
    local len = math.max(select("#", ...), #array)
    for i = 1, len do
        array[i] = select(i, ...)
    end
    return array
end

function CoroutineTask.__ctor(self, func, ...)
    Task.__ctor(self)
    self.args = VarargsToArray({}, ...)
    self.co = coroutine.create(func)
end

function CoroutineTask._OnUpdate(self)
    self.args = VarargsToArray(
        self.args,
        coroutine.resume(self.co, table.unpack(self.args)))

    local ok, firstArg = self.args[1], self.args[2]
    table.remove(self.args, 1)

    Log(self, "coroutine.resume", ok, coroutine.status(self.co), firstArg, TaskAux.IsTask(firstArg))
    if (not ok) then
        self:_Finish(TaskStatus.Error, firstArg .. "\n" .. debug.traceback(self.co))
    else
        if coroutine.status(self.co) == "suspended" then
            if TaskAux.IsTask(firstArg) then
                Globals.taskMgr:_AddDependency(self, firstArg)
            end
        else
            self:_Finish(TaskStatus.Success, table.unpack(self.args))
        end
    end
end
-- #endregion CoroutineTask

-- #region WaitForFrame
-- WaitForNextFrame
-- WaitForLateUpdate
-- WaitForFixedUpdate
-- WaitForEndOfFrame
for k, v in pairs(TaskAux.UpdateTag) do
    if v ~= TaskAux.UpdateTag.Update then
        local clsname = "WaitFor" .. k .. "Task"
        local cls = BaseClass(clsname, Task)
        _M[clsname] = cls

        cls.__ctor = function(self)
            Task.__ctor(self)
            self.updateTag = v
            self.firstUpdate = true
        end

        cls._OnUpdate = function(self)
            if self.firstUpdate then
                self.firstUpdate = false
                return
            end
            self:_Finish(TaskStatus.Success)
        end
    end
end
-- #endregion WaitFromFrame

-- #region WaitForSecondsTask
local WaitForSecondsTask = BaseClass("WaitForSecondsTask", Task)
_M.WaitForSecondsTask = WaitForSecondsTask

function WaitForSecondsTask.__ctor(self, seconds, realtime)
    Task.__ctor(self)
    self.seconds = seconds
    self.realtime = realtime
    self.startTime = realtime and Time.realtimeSinceStartup or Time.time
end

function WaitForSecondsTask._OnUpdate(self)
    local now = self.realtime and Time.realtimeSinceStartup or Time.time
    if now - self.startTime >= self.seconds then
        self:_Finish(TaskStatus.Success)
    end
end
-- #endregion WaitForSecondsTask

-- #region WaitUntilTask
local WaitUntilTask = BaseClass("WaitUntilTask", Task)
_M.WaitUntilTask = WaitUntilTask

function WaitUntilTask.__ctor(self, pred)
    Task.__ctor(self)
    self.pred = pred
    self.compareWithValue = true
end

function WaitUntilTask._OnUpdate(self)
    if self.pred() == self.compareWithValue then
        self:_Finish(TaskStatus.Success)
    end
end
-- #endregion WaitUntilTask

-- #region WaitWhileTask
local WaitWhileTask = BaseClass("WaitWhileTask", WaitUntilTask)
_M.WaitWhileTask = WaitWhileTask

function WaitWhileTask.__ctor(self, pred)
    WaitUntilTask.__ctor(self, pred)
    self.compareWithValue = false
end
-- #endregion WaitWhileTask

-- #region SequentialTasks
local SequentialTasks= BaseClass("SequentialTasks", Task)
_M.SequentialTasks= SequentialTasks

function SequentialTasks.__ctor(self, ...)
    Task.__ctor(self)
    self.tasks = TaskAux.VarargsToTaskArray(_M, ...)
    self.index = 0
end

function SequentialTasks._OnUpdate(self)
    local task = self.tasks[self.index]
    if (not task) or task:IsDone() then
        self.index = self.index + 1
        if self.index > #self.tasks then
            self:_Finish(TaskStatus.Success)
        else
            task = self.tasks[self.index]
            if task and (not task:IsDone()) then
                Globals.taskMgr:_AddTask(task)
                Globals.taskMgr:_AddDependency(self, task)
            end
        end
    end
end
-- #endregion SequentialTasks

-- #region ParallelTasks
local ParallelTasks= BaseClass("ParallelTasks", Task)
_M.ParallelTasks= ParallelTasks

function ParallelTasks.__ctor(self, waitAll, ...)
    Task.__ctor(self)
    self.tasks = TaskAux.VarargsToTaskArray(_M, ...)
    self.waitAll = waitAll
end

function ParallelTasks._OnStart(self)
    table.removebyvalue(self.tasks, nil, true)
    for _, task in ipairs(self.tasks) do
        if (not task:IsDone()) then
            Globals.taskMgr:_AddTask(task)
            if self.waitAll then
                Globals.taskMgr:_AddDependency(self, task)
            end
        end
    end
end

function ParallelTasks._OnUpdate(self)
    local allDone = true
    local anyDone = false
    for _, task in ipairs(self.tasks) do
        if task:IsDone() then
            anyDone = true
        else
            allDone = false
        end
    end

    if ((not self.waitAll) and anyDone) or (self.waitAll and allDone) then
        self:_Finish(TaskStatus.Success)
    end
end
-- #endregion ParallelTasks

-- #region TweenTask
local TweenTask= BaseClass("TweenTask", Task)
_M.TweenTask= TweenTask

function TweenTask.__ctor(self, tween)
    Task.__ctor(self)
    self.tween = tween
end

function TweenTask._OnUpdate(self)
    if (not self.tween) or (not self.tween:IsPlaying()) then
        self:_Finish(TaskStatus.Success)
    end
end

function TweenTask._OnInterrupt(self)
    if self.tween and self.tween:IsPlaying() then
        self.tween:Kill()
    end
end
-- #endregion SequentialTasks

return _M