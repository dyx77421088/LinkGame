-- ResTasks.lua
-- 资源加载相关的公共Task
-- @author zhangliang
-- 2021.8.4
local Task = require "Base.Task.Task"
local TaskAux = require "Base.Task.TaskAux"

local TaskStatus = TaskAux.TaskStatus

local function LoadAsync(alwaysLoadFromAB, path, cb, progressCb, noClear, type)
    local resType
    if alwaysLoadFromAB then
        local resLoader = CS.Framework.ResLoader.Instance
        resType = resLoader.resType
        resLoader.resType = CS.Framework.ResType.Assetbundle
    end

    xpcallex(function()
        Globals.resMgr:LoadAsync(path, cb, progressCb, noClear, type)
    end)

    if alwaysLoadFromAB then
        local resLoader = CS.Framework.ResLoader.Instance
        resLoader.resType = resType
    end
end

local _M = {}

-- #region LoadAssetTask
-- 加载Asset, 参数与ResMgr.LoadAsync一致
-- @prefabPath: prefab路径
-- @type: asset类型
-- @noClear: 是否在过场景的时候不自动卸载，true为不卸载
-- @alwaysLoadFromAB: 总是从AB包加载，default:false
local LoadAssetTask = BaseClass("LoadAssetTask", Task)
_M.LoadAssetTask = LoadAssetTask

function LoadAssetTask.__ctor(self, prefabPath, type, noClear, alwaysLoadFromAB)
    Task.__ctor(self)
    self.prefabPath = prefabPath
    self.type = type
    self.noClear = noClear
    self.alwaysLoadFromAB = alwaysLoadFromAB
end

function LoadAssetTask._OnStart(self)
    LoadAsync(self.alwaysLoadFromAB, self.prefabPath, function(asset)
        if ObjectUtils.IsNotNil(asset) then
            self:_Finish(TaskStatus.Success, asset)
        else
            self:_Finish(TaskStatus.Error, "Failed to load: " .. self.prefabPath)
        end
    end, nil, self.noClear, self.type)
end
-- #endregion LoadAssetTask

-- #region InstantiateAssetTask
-- 加载并Instantiate一个Asset
-- @prefabPath: prefab路径
-- @instantiateArgs: table, unpack并传递给GameObject.Instantiate的参数
-- @type: asset类型
-- @noClear: 是否在过场景的时候不自动卸载，true为不卸载
-- @alwaysLoadFromAB: 总是从AB包加载，default:false
local InstantiateAssetTask = BaseClass("InstantiateAssetTask", Task)
_M.InstantiateAssetTask = InstantiateAssetTask

function InstantiateAssetTask.__ctor(self, prefabPath, instantiateArgs, type, noClear, alwaysLoadFromAB)
    Task.__ctor(self)
    self.prefabPath = prefabPath
    self.instantiateArgs = instantiateArgs or G_EmptyTable
    self.type = type or ClassType.GameObject
    self.noClear = noClear
    self.alwaysLoadFromAB = alwaysLoadFromAB
end

function InstantiateAssetTask._OnStart(self)
    LoadAsync(self.alwaysLoadFromAB, self.prefabPath, function(asset)
        if ObjectUtils.IsNotNil(asset) then
            local ok, ret = pcall(GameObject.Instantiate, asset, table.unpack(self.instantiateArgs))
            self:_Finish(ok and TaskStatus.Success or TaskStatus.Error, ret)
        else
            self:_Finish(TaskStatus.Error, "Failed to load: " .. self.prefabPath)
        end
    end, nil, self.noClear, self.type)
end
-- #endregion InstantiateAssetTask

return _M