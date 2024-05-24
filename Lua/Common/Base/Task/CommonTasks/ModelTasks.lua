-- ModelTasks.lua
-- Model相关的Task
-- @author: zhangliang
-- 2021.8.4
local Task = require "Base.Task.Task"
local TaskAux = require "Base.Task.TaskAux"

local _M = {}

-- #region ChangeModelTask
-- 更换角色模型, 参数是Model.ChangeModelByModelId的子集，只取了需要用到的一部分
-- @model: Model
-- @heroId: 需要更换的id
-- @forceLODLevel: [optional], 强制使用第几个级别的LOD模型
local ChangeModelTask = BaseClass("ChangeModelTask", Task)
_M.ChangeModelTask = ChangeModelTask

function ChangeModelTask.__ctor(self, model, heroId, forceLODLevel)
    Task.__ctor(self)
    self.model = model
    self.heroId = heroId
    self.forceLODLevel = forceLODLevel
end

function ChangeModelTask._OnStart(self)
    self.model:SetClientAvatarHero(self.heroId)
    self.model:SetDressDoneCb(function()
        self:_Finish(TaskAux.TaskStatus.Success)
    end)

    self.model:ChangeModelByModelId(
        Globals.swsMgr:GetHeroModeID(self.heroId),
        nil,
        false,
        self.forceLODLevel)
end
-- #endregion ChangeModelTask

return _M