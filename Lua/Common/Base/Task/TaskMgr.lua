-- TaskMgr.lua
-- @author: zhangliang
-- @note:
--  DO NOT USE Globals.taskMgr directly, which only served as a driver of <Task> mechanism
--  USE functions defined in TaskAPI.lua instead
-- 2021.7.29
local TaskAux = require "Base.Task.TaskAux"
local TaskVisualizer = require "Base.Task.TaskVisualizer"

local TaskStatus = TaskAux.TaskStatus
local UpdateTag = TaskAux.UpdateTag

local _M = BaseClass("TaskMgr")

function _M.__ctor(self)
    self.behaviourObject = nil  -- CS.Framework.BehaviourEvent on "TaskMgr" gameObject
    self.idGenerator = 0        -- generate id for tasks
    self.taskRoots = {}         -- List<Task>, task roots
    self.allTasks = {}          -- Map<id, Task>, task mapping
    self.tasksToUpdate = {}     -- copy and update to allow add/remove ops when updating
    self.taskVisualizer = nil
end

function _M.Init(self)
    local behaviourObject = nil
    local objs = GameObject.FindObjectsOfType(typeof(CS.Framework.BehaviourEvent))
    for i = 0, objs.Length - 1 do
        if objs[i].gameObject.name == "TaskMgr" then
            behaviourObject = objs[i]
            break
        end
    end

    if ObjectUtils.IsNil(behaviourObject) then
        local go = GameObject("TaskMgr")
        GameObject.DontDestroyOnLoad(go)
		behaviourObject = go:GetMissingComponent(typeof(CS.Framework.BehaviourEvent))
    end

    local function updateFunc(ut)
        return callback(self, "_DoUpdate", ut)
    end

    behaviourObject.updateEvent = updateFunc(UpdateTag.Update)
    behaviourObject.lateUpdateEvent = updateFunc(UpdateTag.LateUpdate)
    behaviourObject.fixedUpdateEvent = updateFunc(UpdateTag.FixedUpdate)
    behaviourObject.endofFrameEvent = updateFunc(UpdateTag.EndOfFrame)
    self.behaviourObject = behaviourObject

    if Globals.isEditor then
        self.taskVisualizer = TaskVisualizer.New()
        local taskMgrComponent = self.behaviourObject.gameObject:GetMissingComponent(typeof(CS.TaskAPI.Debug.TaskMgr))
        taskMgrComponent.enableTaskVisualizer = TaskAux.EnableTaskVisualizer
    end
end

-- [internal]
-- NOTE:
--  1. allow task to be added even if task has finished as long as task is not already in <allTasks> map
--     reason is to let tasks that depends on this task to have a chance to be executed
--  2. always remove a task in _DoUpdate loop since dependencies are resolved in there
function _M._AddTask(self, task)
    if (not self.allTasks[task:Id()]) then
        if (not task:Id()) then
            local nextId = self.idGenerator
            self.idGenerator = self.idGenerator + 1
            task.id = nextId
        end

        self.allTasks[task:Id()] = task
        if (not task:_HasDependencies()) then
            table.insert(self.taskRoots, task)
        end

        if (not task.delayOneFrame) then
            task:_Start()
            if (not task:IsDone()) then
                task:_Update()
            end
        end

        TaskAux.LogVerbose(task, "_AddTask", (not task:_HasDependencies()), UpdateTag[task.updateTag])
    end
    return task
end

local function _AddToList(list, v)
    list = list or {}
    if (not table.ifind(list, v)) then
        table.insert(list, v)
    end
    return list
end

local function _ClearList(list)
    if list then
        for i = 1, #list do
            list[i] = nil
        end
    end
end

-- [internal]
-- set task depends on targetTask
-- DO NOT check if task is done or is in <allTasks> map because:
--  1. a finished target task that is still in <allTasks> map will have its dependencies resolved in _DoUpdate loop
--  2. a finished target task that is not in <allTaks> map can be added again when the time user sees fit
--  3. a target task that has not been added before will have its chance to run in the future
function _M._AddDependency(self, task, targetTask)
    targetTask.children = _AddToList(targetTask.children, task)
    task.dependencies = _AddToList(task.dependencies, targetTask)
    table.removebyvalue(self.taskRoots, task)
    TaskAux.LogVerboseFormat(task, "_AddDependency, %s -> %s", task:ToString(), targetTask:ToString())
end

-- [internal]
function _M._AllDependenciesDone(_, task)
    if task:_HasDependencies() then
        for _, targetTask in ipairs(task.dependencies) do
            if targetTask and (not targetTask:IsDone()) then
                return false
            end
        end
    end
    return true
end

-- [internal]
function _M._DoUpdate(self, updateTag)
    for _, task in ipairs(self.taskRoots) do
        if task.updateTag == updateTag then
            table.insert(self.tasksToUpdate, task)
        end
    end

    while #self.tasksToUpdate > 0 do
        TaskAux.LogVerbose(nil, "_DoUpdate", UpdateTag[updateTag], #self.tasksToUpdate)
        local task = self.tasksToUpdate[1]
        table.remove(self.tasksToUpdate, 1)

        if (not task:HasAdded()) then
            self:_AddTask(task)
        elseif (not task:IsDone()) then
            if task:Status() == TaskStatus.None then
                task:_Start()
            end

            if (not task:IsDone()) then
                task:_Update()
            end
        end

        TaskAux.LogVerbose(task, "_DoUpdate, Done:", task:IsDone())

        if task:IsDone() then
            self.allTasks[task:Id()] = nil
            table.removebyvalue(self.taskRoots, task)

            if task:_HasChildren() then
                local insertPos = 1
                for _, childTask in ipairs(task.children) do
                    if childTask and self:_AllDependenciesDone(childTask) then
                        _ClearList(childTask.dependencies)
                        table.insert(self.taskRoots, insertPos, childTask)
                        table.insert(self.tasksToUpdate, insertPos, childTask)
                        insertPos = insertPos + 1
                        TaskAux.LogVerbose(task, "_DoUpdate, add tasksToUpdate", childTask:ToString(), #self.tasksToUpdate)
                    end
                end
            end
        end
    end

    if updateTag == UpdateTag.EndOfFrame and self.taskVisualizer then
        self.taskVisualizer:Update()
    end
end

return _M