-- CommonTasks.TaskInit.lua
-- CommonTasks初始化，这里会require所有在CommonTasks目录下的lua
-- require是手动加的，有没有更好的方法？
-- @author zhangliang
-- 2021.8.4
return require("Base.Task.TaskAux").ExportTaskModules(
    "Base.Task.CommonTasks",
    "ModelTasks",
    "ResTasks")