local UIShareInterface = require "BaseLogic.UI.UIShareInterface"
local UIItem = BaseClass("UIItem", UIShareInterface)
UIItem.isUIItem = true

function UIItem:InitItem(parent, path, baseView, loadAsync)
    self.assetPath = path
    self.parent = parent
    self.mBaseView = baseView
    self.isOpen = false
    self.loadAsync = loadAsync or false
    if self.mBaseView ~= nil then
        --mBaseView必须是GuiViewBase
        self.mBaseView:AddUnInitCB(self)
    else
        printerror("MonitorLogOut:\nUIItem has nil baseView", self)
    end
    self.isInitialize = false
    self.loadType = baseView.type
    --     ///注意此处的逻辑，如果没有路径资源，或者没有父类GUIViewBase
    --     ///说明只是一个空壳 - 相当于，将父类对象作为自己的壳。即显示对象
    if self.assetPath == nil then
        self:InitPrefab(parent)
    else
        self.loadUIHandler = function(prefab)
            if not self.loadUIHandler then
                printerror(self.assetPath .."delete before loadComplete")
                return 
            end
            -- local prefab = Globals.resMgr:LoadResource(self.assetPath, self.assetPath) 
            if prefab == nil then
                printerror(self.assetPath .."加载资源为NULL")
                return
            end
            self:InitPrefab(GameObject.Instantiate(prefab))   
        end
        -- if self.loadAsync  then
            Globals.resMgr:LoadResource(self.assetPath,self.loadUIHandler)
        -- else
            -- self.loadUIHandler()
        -- end
    end
end

function UIItem:AddLoadComplete(func)
    if self.isInitialize == false then
        if self.loadComplete == nil then
            self.loadComplete = LuaDelegate.New(func)
        else
            self.loadComplete = self.loadComplete + func    
        end        
    else
        func()
    end
end

-- function UIItem:AddSingleLoadComplete(func)
--     if self.isInitialize == false then
--         self.loadComplete = func    
--     else
--         func()
--     end
-- end

function UIItem:InitPrefab(prefab)
    if (prefab ~= nil) then
        self.uiPrefab = prefab
        if(self.assetPath) then
            self.uiPrefab.transform:SetParent(self.parent.transform, false)
        end
        self:RecordGameObject()
        self:Initialize()
        self.isInitialize = true
        if self.cacheOpen == nil then
            self:SetIsPop(true) 
        else
            self:SetIsPop(self.cacheOpen)
        end
        -- self:SetIsPop(true)
        local zloadComplete = self.loadComplete
        if (zloadComplete ~= nil) then
            zloadComplete()
            self.loadComplete = nil
        end
    else
        printerror(self.assetPath .. "=NULL")
    end
end

function UIItem:Initialize()
    
end

function UIItem:SetPos(x, y)
    if self.transform == nil then
        return
    end
    if type(x) == "number" then
        self.transform.localPosition = Vector3(x, y, 0)
    else
        self.transform.localPosition = x
    end

end

function UIItem:SetScale(x,y,z)

end

function UIItem:GetPos()
    return self.transform.localPosition
end

function UIItem:SetName(name)
    if self.gameObject ~= nil then
        self.gameObject.name = name
    end
end

function UIItem:Get_GameObject()
    return self.gameObject
end

function UIItem:ChangeParent(parent)
    if self.transform == nil then
        return
    end
    self.parent = parent
    self.transform:SetParent(parent.transform, true)
end

--不要直接调用UIItem的HideSelf
function UIItem:HideSelf()
end

--不要直接调用UIItem的ShowSelf
function UIItem:ShowSelf()

end

function UIItem:SetIsPop(value)
    if(not self.isInitialize) then
        self.cacheOpen = value
        return
    end
    if self.isOpen == value then
        return
    end
    self.isOpen = value
    if self.gameObject ~= nil then
        self.gameObject:SetActive(value)
    end
    if value then
        self:ShowSelf()
    else
        self:HideSelf()
    end
end

function UIItem:GetIsPop()
    return self.isOpen
end

--会删除uiitem对应的obj，如果跟着主角面一起销毁的，不需要调用这个
function UIItem:DestroyObj()
    self.DestroyUIPrefab = true
    self:Dispose()
end

function UIItem:__delete()
    if self.mBaseView then
        self.mBaseView:RemoveUnInitCB(self)
    end
    if self.loadAsync == true then
        self.loadUIHandler = false
        Globals.resMgr:UnloadAssetBundle(self.assetPath,false)
    end
    self.loadComplete = nil
    self.loadAsync = false
    if self.uiPrefab ~= nil then
        if self.DestroyUIPrefab then
            GameObject.Destroy(self.uiPrefab)
        end
		self.gameObject = nil
		self.transform = nil
        self.uiPrefab = nil
    end
    self.isOpen = false
    self.parent = false
    self.mBaseView = false
end


return UIItem
