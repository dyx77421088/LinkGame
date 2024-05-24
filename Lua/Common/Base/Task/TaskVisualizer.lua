-- TaskVisualizer.lua
-- @author: zhangliang
-- @note: Task可视化初步实现，辅助调试
-- 2021.8.16
local TaskAux = require "Base.Task.TaskAux"
local TaskNode = CS.TaskAPI.Debug.TaskNode

local _M = BaseClass("TaskVisualizer")

function _M.__ctor(self)
    self.taskMgr = Globals.taskMgr
    self.taskMgrTransform = self.taskMgr.behaviourObject.transform
    self.activeTaskRoot = self:_CreateTaskRoot("ActiveTasks")
    self.taskPoolRoot = self:_CreateTaskRoot("TaskPool")
    self.enabled = TaskAux.EnableTaskVisualizer
end

function _M.SetEnable(self, value)
    self.enabled = value
end

function _M.Dispose(self)
    if (not self.disposed) then
        self.disposed = true
        self:_ClearTaskNodes()
        for i = self.taskPoolRoot.childCount, 1, -1 do
            GameObject.Destroy(self.taskPoolRoot:GetChild(i - 1).gameObject)
        end
    end
end

function _M.Update(self)
    if (not self.disposed) then
        self:_ClearTaskNodes()
        if self.enabled then
            self:_UpdateTaskNodes()
        end
    end
end

function _M._CreateTaskRoot(self, name)
    local root = self.taskMgrTransform:Find(name)
    if ObjectUtils.IsNil(root) then
        local go = GameObject(name)
        root = go.transform
        root:SetParent(self.taskMgrTransform, false)
    end

    for i = root.childCount, 1, -1 do
        GameObject.Destroy(root.GetChild(i - 1).gameObject)
    end

    return root
end

function _M._ClearTaskNodes(self, parent, moveSelf)
    parent = parent or self.activeTaskRoot
    for i = parent.childCount, 1, -1 do
        self:_ClearTaskNodes(parent:GetChild(i - 1), true)
    end
    if moveSelf then
        parent:SetParent(self.taskPoolRoot, false)
    end
end

function _M._UpdateTaskNodes(self, tasks, parentTaskNode)
    tasks = tasks or self.taskMgr.taskRoots
    for _, task in ipairs(tasks) do
        if type(task) == "number" then
            task = self.taskMgr.allTasks[task]
        end

        local taskNode
        if self.taskPoolRoot.childCount > 0 then
            local t = self.taskPoolRoot:GetChild(0)
            taskNode = t:GetComponent(typeof(TaskNode))
        else
            local go = GameObject()
            taskNode = go:AddComponent(typeof(TaskNode))
        end

        local parent = parentTaskNode and parentTaskNode.transform or self.activeTaskRoot
        taskNode.transform:SetParent(parent, false)
        taskNode.gameObject.name = task:ToString()
        taskNode.id = task.id
        taskNode.debugInfo = string.format([[
Status: %s
DelayOneFrame: %s
UpdateTag: %s]],
            TaskAux.TaskStatus[task.status],
            task.delayOneFrame,
            TaskAux.UpdateTag[task.updateTag])
        taskNode.error = task.error

        taskNode.children:Clear()
        taskNode.dependencies:Clear()
        if parentTaskNode then
            taskNode.dependencies:Add(parentTaskNode)
            parentTaskNode.children:Add(taskNode)
        end

        if task.children then
            self:_UpdateTaskNodes(task.children, taskNode)
        end
    end
end

return _M