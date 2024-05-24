--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:资源加载类
--     创建时间:2021/10/26 
--------------------------------------------------------------------------------
local ResMgr = Singleton("ResMgr")
local Application = UnityEngine.Application
local resMgr = LuaHelper.GetResManager(CurAppType)
local AssetData = nil
function ResMgr:__ctor()
    self.atlasPrefabs = {}
    self.callBackDict = {}
	self.commonAtlas = {}
end

function ResMgr:__delete()
    for atlasName, atlas in pairs(self.atlasPrefabs) do
        self:UnloadAssetBundle(atlasName, true)
    end
    self.atlasPrefabs = nil
    self.callBackDict = nil
	self.commonAtlas = nil
end

--初始化加载一些常用的小资源
function ResMgr:Initialize()
    if _IsEditor then
        if not ComUtils.FileExists(Application.dataPath .. "/SmallGame/Lua/GameExtend/Config/AssetData.lua") then
            printerror("请先打包一次资源，记录资源数据")
            return
        end
    end
    AssetData = Globals.configMgr:GetConfig("AssetData")
end

function ResMgr:GetAssetData(path)
    if(not AssetData) then
        printerror("请先打包一次资源，记录资源数据", path)
        return
    end
    local assetData = AssetData["Bundle/" .. path]
    if(not assetData) then
        printerror("不存在该路径的资源，请检查路径是否正确，或者是否已经打包该资源", path)
        return 
    end
    return assetData
end

--预加载
function ResMgr:PreLoad()
	local callBack = function()
		LMessage:Dispatch(LuaEvent.Loading.AddLoaded, 1)
	end
	local viewData = Globals.configMgr:GetConfig("ViewData")
	local views = table.values(viewData)
	for _, view in pairs(views) do
		if view.preLoad then
			LMessage:Dispatch(LuaEvent.Loading.AddNeedLoad, 1)
			self:LoadResource(view.prefabPath, callBack)
		end
	end
end

--获取公共资源
function ResMgr:LoadPlatAtlas(path)
	local go = self.commonAtlas[path]
	if not go then
		go = GameObject.Find("CommonAtlas/"..path)
		if go then
			self.commonAtlas[path] = go
		end
	end
	
	return go
end

--加载UIAssetBundle资源包
function ResMgr:LoadResource(path, callBack)
    local assetData = self:GetAssetData(path)
    if(not assetData) then
        return
    end
    print("准备加载资源：", path, assetData.assetId)
    resMgr:LoadResource(assetData.assetId, function(objs)
        print("加载资源成功：", path, assetData.assetId)
        callBack(objs[0], path)
	end)
end

function ResMgr:LoadExtraAudio(path, callBack)
    print("准备加载外部资源：", path)
    resMgr:LoadExtraAudio(path, function(objs)
        print("加载外部资源成功：", path)
        callBack(objs[0], path)
	end)
end

--加载精灵
function ResMgr:LoadSprite(atlasName, spriteName, callBack)
    local zfunc = function(image)
        callBack(image.sprite, image)
    end
    self:LoadObject(atlasName, "Atlas/" .. spriteName, zfunc, ClassType.Image)
end

--加载图片
function ResMgr:LoadImage(atlasName, imageName, callBack)
    local zfunc = function(image)
        callBack(image.texture, image)
    end
    self:LoadObject(atlasName, "UITexture/" .. imageName, zfunc, ClassType.RawImage)
end

--加载预制体资源
function ResMgr:LoadObject(atlasName, objectName, callBack, componentType)
    local path = "Prefab/UI/" .. atlasName
    if(self.atlasPrefabs[path]) then
        local go = self.atlasPrefabs[path]
        local child = TransformUtils.GetChild(go, objectName, componentType)
        callBack(child)
    elseif(self.callBackDict[path]) then --之前已经调用过图集加载，只是还未加载出来
        table.insert(self.callBackDict[path], {callBack, objectName, componentType})
    else
        self.callBackDict[path] = self.callBackDict[path] or {}
        table.insert(self.callBackDict[path], {callBack, objectName, componentType})
        self:LoadResource(path, function(go)
            go:SetActive(false)
            self.atlasPrefabs[path] = go
            if(self.callBackDict[path]) then
                for _, param in ipairs(self.callBackDict[path]) do
                    local callBack = param[1]
                    local objName = param[2]
                    local compType = param[3]
                    local child = TransformUtils.GetChild(go, objName, compType)
                    callBack(child)
                end
            end
            self.callBackDict[path] = nil
        end)
    end
end

function ResMgr:UnloadAssetBundle(path, isThorough)
    local assetData = self:GetAssetData(path)
	printext("unload ab:"..assetData.assetBundle)
    return resMgr:UnloadAssetBundle(assetData.assetBundle, isThorough)
end

return ResMgr
