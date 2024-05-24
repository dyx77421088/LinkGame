local Task = require "Base.Task.Task"
local TaskAux = require "Base.Task.TaskAux"

-- Task usage and tests
local function log(...)
    print(string.format("[TaskExample][%d]:", Time.frameCount), ...)
end

local function DoSomething(...)
    log("DoSomething", Time.time, ...)
    TaskAPI.AwaitSeconds(0.5)
    log("DoSomething, after 0.5s", Time.time)
    TaskAPI.AwaitNextFrame()
    log("DoSomething, after a frame")
    TaskAPI.Await(1.2)
    log("DoSomething, after anything")
    return "hello"
end

local function SyncFunc()
    log("SyncFunc 1")
    log("SyncFunc 2")
end

local function MultiReturnValues()
    TaskAPI.AwaitNextFrame()
    return "hello", "world", 1, 2, 3
end

log("--------------------test 1--------------------")
TaskAPI.Async(function()
    log("start")
    log(TaskAPI.Await(DoSomething, 1, 2, 3))

    log("SyncFunc start immediately")
    TaskAPI.Await(SyncFunc)
    log("SyncFunc Finished")

    log("MultiReturnValues start")
    log(TaskAPI.Await(MultiReturnValues))
    log("MultiReturnValues Finished")

    log("SyncFunc start at next frame")
    TaskAPI.Await(TaskAPI.CoroutineTask(SyncFunc):DelayOneFrame())
    log("SyncFunc Finished")

    log("wait for next frame, start")
    TaskAPI.AwaitNextFrame()
    log("wait for next frame, end")

    log("wait for seconds, start:", Time.time)
    TaskAPI.AwaitSeconds(3)
    log("wait for seconds, end:", Time.time)

    log("wait until, start:", Time.time)
    local value = { v = false }
    TaskAPI.AwaitAll(
        TaskAPI.WaitUntilTask(function() return value.v end),
        TaskAPI.SequentialTasks(
            TaskAPI.WaitForSecondsTask(1),
            TaskAPI.CoroutineTask(function()
                value.v = true
                log("set value to true", Time.time)
            end)))
    log("wait until, end:", Time.time)

    log("wait while, start:", Time.time)
    TaskAPI.AwaitAny(
        TaskAPI.WaitWhileTask(function() return value.v end),
        TaskAPI.ParallelTasks(true,
            TaskAPI.CoroutineTask(function()
                TaskAPI.AwaitSeconds(1)
                value.v = false
                log("A> set value to false", Time.time)
            end),
            TaskAPI.CoroutineTask(function()
                TaskAPI.AwaitSeconds(0.5)
                value.v = false
                log("B> set value to false", Time.time)
            end)))
    log("wait while, end:", Time.time)

    TaskAPI.AwaitCatchError(function()
        log("AwaitCatchError",
            TaskAPI.AwaitCatchError(function()
                error("AwaitCatchError: this is an error")
                log("you won't see this log")
            end))

        TaskAPI.Await(function()
            log("Await error test")
            error("Await: this is an error")
            log("you won't see this log")
        end)

        log("you won't see this log")
    end)
end)

-- log("--------------------test 2--------------------")
-- TaskAPI.Async(function()
--     TaskAPI.AwaitNextFrame()
--     log("in update queue")
--     TaskAPI.AwaitLateUpdate()
--     log("in late update queue")
--     TaskAPI.Await(nil)
--     log("back in update update queue")
--     TaskAPI.AwaitFixedUpdate()
--     log("in fixed update queue")
--     TaskAPI.Await(nil)
--     log("back in update update queue")
--     TaskAPI.AwaitEndOfFrame()
--     log("in end of frame queue")
--     TaskAPI.Await(nil)
--     log("back in update update queue")
-- end)

-- log("--------------------test 3--------------------")
-- local TaskA = BaseClass("TaskA", Task)

-- function TaskA.__ctor(self)
--     Task.__ctor(self)
-- end

-- function TaskA.SetFinish(self)
--     self:_Finish(TaskAux.TaskStatus.Success)
-- end

-- local TaskB = BaseClass("TaskB", Task)

-- function TaskB.__ctor(self)
--     Task.__ctor(self)
-- end

-- function TaskB._OnUpdate(self)
--     log("TaskB Done")
--     self:_Finish(TaskAux.TaskStatus.Success)
-- end

-- TaskAPI.Async(function()
--     local TaskA_1 = TaskA.New()
--     local TaskA_2 = TaskA.New()

--     TaskAPI.Async(function()
--         TaskAPI.Await(TaskA_1)
--         log("TaskA(1) Done")
--     end)

--     TaskAPI.Async(function()
--         TaskAPI.Await(TaskA_2)
--         log("TaskA(2) Done")
--     end)

--     TaskAPI.AwaitNextFrame()
--     TaskA_1:SetFinish()
--     TaskA_1:Then(TaskB.New())
--     TaskA_2:SetFinish()
-- end)

-- log("--------------------test 4--------------------")
-- TaskAPI.Async(function()
--     local go = GameObject.Find("/TestObject")
--     if ObjectUtils.IsNil(go) then
--         go = GameObject("TestObject")
--     end
--     go.transform.localPosition = Vector3.zero

--     log("DOMove")
--     local tween = go.transform:DOMove(Vector3(1, 1, 1), 1)
--     TaskAPI.Await(tween)
--     log("DOMove end")

--     log("Await on dead tween")
--     TaskAPI.Await(tween)
--     log("Await on dead tween end")

--     log("kill DOMove halfway")
--     go.transform.localPosition = Vector3.zero
--     tween = go.transform:DOMove(Vector3(1, 1, 1), 1)
--     TaskAPI.AwaitAll(
--         tween,
--         TaskAPI.CoroutineTask(function()
--             TaskAPI.AwaitSeconds(0.5)
--             tween:Kill()
--             log("kill")
--         end))

--     log("kill use Interrupt")
--     go.transform.localPosition = Vector3.zero
--     tween = go.transform:DOMove(Vector3(1, 1, 1), 1)
--     tweenTask = TaskAPI.TweenTask(tween)
--     TaskAPI.AwaitAll(
--         tweenTask,
--         TaskAPI.CoroutineTask(function()
--             TaskAPI.AwaitSeconds(0.5)
--             tweenTask:Interrupt()
--             log("interrupt")
--         end))
-- end)