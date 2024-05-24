--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:界面基础类，UIItem只能是Viewbase的子项目，默认UIViewBase是异步加载，UIItem是同步的
--------------------------------------------------------------------------------
local UIShareInterface = require "BaseLogic.UI.UIShareInterface"
local GUIWeight = Const.GUIWeight
local UIViewBase = BaseClass("UIViewBase",UIShareInterface)
local _p = {} --私有函数
UIViewBase.isUIViewBase = true
local _hideMainUITime = 0
local _openOtherTime = 0

function UIViewBase:__ctor(cb)
    self:AddLoadComplete(cb)
end

function UIViewBase:Init(uiName, assetPath)
    self.uiName = uiName
    self.prefabPath = assetPath
end

function UIViewBase:__defaultVar()
    return {
		prefabPath = "",
		weight = GUIWeight.Pop,
		-- isFullScreen = 0, -- 1 ：全屏界面,  0：非全屏界面
		-- isHideCarmera = 1 , -- 1隐藏 （isFullScreen == 1 生效） 0 不隐藏 
		isHideMainUI = false, --是否打开时隐藏主界面,
		isHideOtherView = false, --关闭后重新打开,
		isCloseOtherView = false,--关闭后不打开,
		closeTime = 0,
		isInitialize = false,
		rectTransform = false,
		-- uiPrefab = nil,
		isDefalut = false,
		-- isOpen = false, --如果界面没加载完就SetIsPop(false)会出问题，所以初始值不能是false
		__subItemList = nil,
		depth = -1,
    }
end

--特殊的界面需要在ShowSelf跟SetDepth的时候都处理一下
function UIViewBase:SetDepth(value)
    if self.depth == value then
        return
    end
    self.depth = value
    UIUtils.SetCanvasSortingOrder(self.uiPrefab, self.depth)
end

function UIViewBase:BreakDepth(value)
	Globals.uiMgr:RemoveDepthData(self)
	UIUtils.SetCanvasSortingOrder(self.uiPrefab, value)
end

function UIViewBase:GetDepth()
    -- body
    return self.depth
end

local hideMainIgnore = {}
local hidePopIgnore = {}
local CloseOtherIgnore = {}

--处理打开事件,不要在这里写处理逻辑，重载自己处理
function UIViewBase:ShowSelf()
    
end


--处理关闭事件,不要在这里写处理逻辑，重载自己处理
function UIViewBase:HideSelf()

end

function UIViewBase:PopUp()
    if self.uiPrefab == nil then
        printerror("============================UIViewBase:PopUp:> uiPrefab == nil")
        return
    end
    Globals.uiMgr:AddUIDepthData(self)
    self:SetActive(true)
    if self.isHideMainUI then
        Globals.uiMgr:HideOtherView(GUIWeight.Main, self, hideMainIgnore)
        _hideMainUITime = _hideMainUITime + 1
    end

    -- 打开当前界面- 隐藏当前所有打开的界面
    if self.isHideOtherView then
        Globals.uiMgr:HideOtherView(GUIWeight.Pop, self, hidePopIgnore)
        _openOtherTime = _openOtherTime + 1
    end
    if self.isCloseOtherView then
        Globals.uiMgr:CloseOtherView(GUIWeight.Pop, self, CloseOtherIgnore)
    end
    self.closeTime = 0
    self:ShowSelf()
    LMessage:Dispatch(LuaEvent.UI.UIViewBasePopChange, self.uiName, true)
end

function UIViewBase:PopDown()
    if self.uiPrefab == nil then
        return
    end

    Globals.uiMgr:RemoveDepthData(self)
    
    self:SetActive(false)
    -- print("UIViewBase:HideSelf", self.isHideMainUI, _hideMainUITime)
    if self.isHideMainUI == true then
        _hideMainUITime = _hideMainUITime - 1 
        if _hideMainUITime <= 0 then
            _hideMainUITime = 0
            Globals.uiMgr:ShowOtherView(GUIWeight.Main)
        end
    end

    if self.isHideOtherView then
        _openOtherTime = _openOtherTime - 1
        if (_openOtherTime <= 0) then
            _openOtherTime = 0 
            Globals.uiMgr:ShowOtherView(GUIWeight.Pop)
        else
            Globals.uiMgr:ShowNextView(GUIWeight.Pop)
        end
    end

    self.closeTime = Time.realtimeSinceStartup
    self:HideSelf()
    LMessage:Dispatch(LuaEvent.UI.UIViewBasePopChange, self.uiName, false)
end

-- 适配屏幕
function UIViewBase:AspectScreen()
    self:AspectOffsetFitter()
    self:AspectRatioFitter("Bg")
end

function UIViewBase:GetIsPop()
    return self.isOpen
end

function UIViewBase:SetIsPop(value, fromInitPrefab)
    if fromInitPrefab then --initprefab已经有xpcall了，这里就不再包一层
        self:SetIsPopPCall(value)
        return
    end
    local function SetIsPopPCall_xp()
        self:SetIsPopPCall(value)
    end
    --try catch代码
    if not xpcall(SetIsPopPCall_xp, printerror) then
        self.isOpen = false
        if ObjectUtils.IsNotNil(self.UIprefab) then
            self:SetActive(false)
        end
    end
end

function UIViewBase:SetIsPopPCall(value)
    -- print("UIViewBase:SetIsPop:" , self.uiName , self.isOpen , self.isSocketBack)
    if not self.isInitialize then
        self.cacheOpen = value
        return
    end
    --titleBar需要重置层级
    if (self.isOpen ~= value) then
        self.isOpen = value
        if value then
            self:PopUp()
        else
            self:PopDown()
        end
    end
end
    
function UIViewBase:AddLoadComplete(func)
    if self.isInitialize == false then
        if self.loadComplete == nil then
            self.loadComplete = LuaDelegate.New(func)
        else
            self.loadComplete = self.loadComplete + func    
        end        
    else
        func(self)
    end
end

function UIViewBase:Initialize()

end

--==============================--
--desc:自适应全屏
--time:2018-06-21 03:53:31
--@path:
--@return 
--==============================--
function UIViewBase:AspectRatioFitter( path )
    if not self:HasChild(path) then
        return 
    end
    
    local go = self:GetChild(path)

    local zrectTtran =  go:GetComponent("RectTransform")
    if not zrectTtran then
        return
    end
    zrectTtran.pivot = Vector2(0.5, 0.5)
    zrectTtran.anchorMin = Vector2(0, 0)
    zrectTtran.anchorMax = Vector2(1, 1)
    local off = Globals.uiMgr.Get_OffSet()
    zrectTtran.offsetMin = Vector2( - off, 0)
    zrectTtran.offsetMax = Vector2( off, 0)
end

--==============================--
--desc:自适应 部分手机偏移
--time:2018-06-21 04:02:23
--@return 
--==============================--
function UIViewBase:AspectOffsetFitter()
     -- 设置偏移 - iphone X 等机型偏移
     self.rectTransform.pivot = Vector2(0.5, 0.5)
     self.rectTransform.anchorMin = Vector2(0, 0)
     self.rectTransform.anchorMax = Vector2(1, 1)
     local off = Globals.uiMgr.Get_OffSet()
     self.rectTransform.offsetMin = Vector2(off, 0)
     self.rectTransform.offsetMax = Vector2(-off, 0)
end

function UIViewBase:AddUnInitCB(subItem)
    if self.__subItemList == true then
        return
    end
    self.__subItemList = self.__subItemList or {}
    table.insert(self.__subItemList, subItem)
end

function UIViewBase:RemoveUnInitCB(subItem)
    if self.__subItemList == true then
        return
    end
    table.removebyvalue(self.__subItemList, subItem)
end

--比__delete先执行，不然很多子界面列表会空
function UIViewBase:UnInitSubItems()
    local subItems = self.__subItemList
    if subItems == true or subItems == nil then
        return
    end
    self.__subItemList = true --防止上面的删除进入
    for _, item in ipairs(subItems) do
        item:Dispose()
    end
    subItems = nil
end

function UIViewBase:__delete()
    self:UnBindAllEvent()
    self.timer = false
    self.rectTransform = false
    LMessage:Dispatch(LuaEvent.UI.DisposeUIView, self.uiName)
    Globals.resMgr:UnloadAssetBundle(self.prefabPath,false)
    self.loadUIHandler = false
    if self:GetIsPop() then
        printerror("Before __delete view must be close")
    end
    if ObjectUtils.IsNotNil(self.uiPrefab) then
        printext(self.uiName, self.uiPrefab.name)
        GameObject.Destroy(self.uiPrefab)
    end
    self.uiPrefab = nil
    self.prefabPath = nil
end

-- 实例化UI预制
function UIViewBase:StartLoadView()
    if self.loadUIHandler then
        error("UIViewBase:InstantiatePanel call twice")
        return
    end

    self.loadUIHandler = function(prefab)
        if not self.loadUIHandler then
            printerror(self.prefabPath .."delete before loadComplete")
            return 
        end
        if (prefab == nil) then
            printerror(self.prefabPath .."加载资源为NULL")
            Globals.uiMgr:DestroyView(self)
            return
        end
        self:InitPrefab(GameObject.Instantiate(prefab))   
    end
    Globals.resMgr:LoadResource(self.prefabPath,self.loadUIHandler)
end

function UIViewBase:InitPrefab(prefab)
    -- self:InitPrefabPCall(prefab)
    -- if true then return end
    --try catch
    local function InitPrefabPCall_xp()
        self:InitPrefabPCall(prefab)
    end
    if not xpcall(InitPrefabPCall_xp, printerror) then
        pcall(function ()
            Globals.uiMgr:DestroyView(self)
        end) --尝试一下销毁
        if ObjectUtils.IsNotNil(prefab) then --删除掉
            GameObject.DestroyImmediate(prefab)
        end
        if self.prefabPath then --把引用计数减掉
            Globals.resMgr:UnloadAssetBundle(self.prefabPath,false)
        end
    end
end

function UIViewBase:InitPrefabPCall( prefab)
    if (prefab ~= nil)then
        self.uiPrefab = prefab
        self.uiPrefab.name = self.uiName
        self:RecordGameObject()
        self.rectTransform = self:GetChild("", "RectTransform")
        if(not self.noUIRoot) then --不挂到UIRoot下面
            self.uiPrefab.transform:SetParent(Globals.uiMgr:Get_WeightTransform(self.weight), false)
            self.rectTransform.pivot = Vector2(0.5, 0.5)
            self.rectTransform.anchorMin = Vector2(0, 0)
            self.rectTransform.anchorMax = Vector2(1, 1)
            self.rectTransform.anchoredPosition = Vector2.zero
            self.rectTransform.offsetMin = Vector2.zero
            self.rectTransform.offsetMax = Vector2.zero
        end
        self.uiPrefab.layer = LayerUtils.UI
    else
        printerror(StrUtilText("初始化失败"),self.prefabPath)
        return
    end
    self:Initialize()
    self.isInitialize = true
	
	local zloadComplete = self.loadComplete
    if (zloadComplete ~= nil) then
        zloadComplete(self)
        self.loadComplete = nil
    end

    if self.cacheOpen == nil then
        self:SetIsPop(true, true) 
    else
        self:SetIsPop(self.cacheOpen, true)
        if self.cacheOpen == false then
            self.closeTime = Time.realtimeSinceStartup
        end
    end
end

function UIViewBase:SetActive(value)
    if not self.isInitialize or self.isActive == value then
        return
    end
    self.isActive = value
    -- if value then
    --     ----隐藏相机
    --     if self.isFullScreen == 1 then
    --         if self.isHideCarmera == 1 then
    --             Globals.cameraMgr:HideCamera()
    --         end
    --     end
    -- else
    --     --显示相机
    --     if self.isFullScreen == 1 then
    --         if self.isHideCarmera == 1 then
    --             Globals.cameraMgr:ShowCamera()
    --         end
    --     end
    -- end
    self:ChangeZPos()
end

function UIViewBase:ChangeZPos()
    if self.uiPrefab == nil then
        return
    end
    local localPos = self.rectTransform.localPosition
    if self.isActive then        
        -- 下面试设置Z值深度
        localPos.z = 0
    else
        localPos.z = -100000
    end
    self.rectTransform.localPosition = localPos
end

function UIViewBase:GetActive()
    if self.uiPrefab == nil then
        return false
    end      
    return self.uiPrefab.activeSelf
end

function UIViewBase:AddCloseBtn(name)
    name = name or "closeBtn"
    local close = self:GetChild(name)  
    self:AddOnClick(close.gameObject, callback(self, "OnCloseBtnHandler"))
end

function UIViewBase:OnCloseBtnHandler(go)
    self:SetIsPop(false)
end

function UIViewBase:GetUIPrefabObj()
    if self.uiPrefab == nil then
        return nil
    end
    return self.uiPrefab
end

return UIViewBase