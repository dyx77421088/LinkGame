-- <summary>
-- UI管理器, 用于管理所有的游戏gui的加载,显示,查找.
-- </summary>
local UIMgr = Singleton("UIMgr")
local GUIWeight = Const.GUIWeight
local one_view_weight = 1000
local ConfigData = Globals.configMgr:GetConfig("SlotData")

-- 让cheatView里面的Views不被销毁
local m_gmViews = {

}

local EffectContainer = nil
function UIMgr:__ctor()
    self.uiWeightList = {}
    self.uiRoot = GameObject.Find("UIRoot")
    self.gameRoot = self.uiRoot.transform:Find("Game")
    for i = 1, GUIWeight.Count - 1 do
        local child = GameObject(GUIWeight[i])
        child.transform:SetParent(self.gameRoot, false)
        local rectTransform = child:AddComponent(ClassType.RectTransform)
        rectTransform.pivot = Vector2(0.5, 0.5)
        rectTransform.anchorMin = Vector2(0.5, 0.5)
        rectTransform.anchorMax = Vector2(0.5, 0.5)
        rectTransform.sizeDelta = Vector2(1080, 1920)
        child.layer = LayerUtils.UI
        self.uiWeightList[i] = child.transform
    end
    EffectContainer = GameObject("EffectContainer")
    EffectContainer.transform:SetParent(self.gameRoot, false)
    EffectContainer.layer = LayerUtils.UI
    -- 界面列表
    self.m_Views = {}
    self.disposeTime = 0
    self.m_LockNGUIEvent = false
    self:InitUIDepthData()
end

function UIMgr:__delete()
    self:ResetCanvas()
    for name, view in pairs(self.m_Views) do
        self:DestroyView(name)
    end
    for i, child in ipairs(self.uiWeightList) do
        GameObject.Destroy(child.gameObject)
    end
    self.uiWeightList = nil
    GameObject.Destroy(EffectContainer)
    EffectContainer = nil
    self.m_Views = false
    self.uiRoot = false
end

--==============================--
--addby:zhoujy
--desc:UIRoot Canvas初始化，需要调整其参数须在其他地方手动调用此函数 
--@return:
--time:2024-3-7 12:22:39
--==============================--
function UIMgr:InitCanvas(planeDistance)
    self.canvas = self.uiRoot:GetComponent(ClassType.Canvas)
    if not self.canvas then
        printerror("未找到UIRoot Canvas组件，InitCanvas失败！")
        return
    end
    --备份设置
    self.backConfig = {
        planeDistance = self.canvas.planeDistance
    }

    --判空处理
    planeDistance = planeDistance or 500

    --初始化
    self.canvas.planeDistance = planeDistance
end

function UIMgr:ResetCanvas()
    if self.backConfig then
        self.canvas.planeDistance = self.backConfig.planeDistance
    end
end

function UIMgr:Get_EffectContainer()
    return EffectContainer
end

function UIMgr:Get_WeightTransform(weight)
    return self.uiWeightList[weight]
end

function UIMgr:GetCanvasScaler()
	if(not self.canvasScaler) then
        self.canvasScaler = self.uiRoot:GetComponent(ClassType.CanvasScaler)
    end
	return self.canvasScaler
end

function UIMgr:GetCanvasSize()
    if(not self.canvasScaler) then
        self.canvasScaler = self.uiRoot:GetComponent(ClassType.CanvasScaler)
    end
    if(not self.canvasScaler) then
        return Vector2(1920,1080)
    else
        return self.canvasScaler.referenceResolution
    end
end

--调试用
function UIMgr:Set_AllWeightParentActive(ignore, value)
    for weight, transform in pairs(self.uiWeightList) do
        if weight ~= ignore then
            transform.gameObject:SetActive(value)
        end
    end
end

function UIMgr:Get_UIRoot()
    return self.uiRoot
end

function UIMgr:Get_GameRoot()
	return self.gameRoot
end

function UIMgr:Get_OffSet()
    return 80
end

--初始化面板层级
function UIMgr:InitUIDepthData()
    self.uiZOffset = {}
    self.uiDepthData = {}
    local len = GUIWeight.Count
    for i = 1, len-1 do
        self.uiDepthData[i] = -one_view_weight
        self.uiZOffset[i] = 0 --Z值不一样，直接在最上层结构加了Z值(pop 跟alert 层的Z值不一样)
    end
end

-- 添加界面,调整canvas的层级
function UIMgr:AddUIDepthData(view)
    local weight = view.weight
    local znewDepth = self.uiDepthData[weight] + one_view_weight
    view:SetDepth(znewDepth)
    self.uiDepthData[weight] =  znewDepth
end

-- 删除界面,调整canvas的层级
function UIMgr:RemoveDepthData(view)
    local zdepth = view.depth
    local zmax = 0
    view:SetDepth(0)
    -- 遍历上层界面 - 依次递减 
    for _,mView in pairs(self.m_Views) do
        local depth = mView.depth
        if (mView.weight == view.weight and mView:GetIsPop() == true and mView.depth > zdepth) then
            local znewdpth = depth - one_view_weight
            mView:SetDepth(znewdpth)
            if znewdpth > zmax then
                zmax = znewdpth
            end
        end
    end

    -- 记录当前最高层
    if zmax == 0 then
        self.uiDepthData[view.weight] = zdepth - one_view_weight
    else
        self.uiDepthData[view.weight] = zmax 
    end
end

local disposeDuration = 60
local closeTime = 10
function UIMgr:SetDisposeTime(disTime, cTime)
    disposeDuration = disTime
    closeTime = cTime
end

function UIMgr:Update()
    local deltaTime = Time.deltaTime
    self.disposeTime = self.disposeTime + deltaTime
    if self.disposeTime > disposeDuration then
        self.disposeTime = 0
        self:DisposeInactiveView()
    end
end

function UIMgr:DisposeInactiveView()
    self.inDispose = true
    local nowTime = Time.realtimeSinceStartup
    for _,view in pairs(self.m_Views) do
        if(view:GetIsPop() == false and view.isDefalut == false and view.closeTime > 0 and  nowTime - view.closeTime > closeTime) then
            self:DestroyView(view)
        end
    end
    self.inDispose = false
end

--切场景的时候调用
function UIMgr:ForceDisposeInactiveView()
    self.inDispose = true
    for _,view in pairs(self.m_Views) do
        if(view:GetIsPop() == false and view.isDefalut == false and view.closeTime > 0) then
            self:DestroyView(view)
        end
    end
    self.inDispose = false
end

function UIMgr:DestroyView(view)
    if type(view) == "string" then
        print(view, self.m_Views[view])
        view = self.m_Views[view]

        if view == nil then
            return
        end
    end
    -- Debuger.Log(view.uiName)
    self.m_Views[view.uiName] = nil
    view:SetIsPop(false)
    view:UnInitSubItems()
    view:Dispose()
    view = nil
end

--外部不要调用这个函数
function UIMgr:CreateView(uiname, callBack )
    local viewbase = self.m_Views[uiname]
    if viewbase == nil then
        local ViewData = Globals.configMgr:GetViewData()
        local viewData = ViewData[uiname]
        if(not viewData) then
            printerror(string.format("请先定义%s并把界面加到UI.ViewData中", uiname))
            return
        end
        local viewPath = viewData.viewPath
        local prefabPath = viewData.prefabPath
        local classUI = require(viewPath)
        if classUI == nil then 
            printerror("找不到界面类：" .. uiname)
            return
        end
        viewbase = classUI.New()
        -- print("UIMgr:CreateView", uiname, viewbase)
        --cheatView里的views不被销毁 
        if m_gmViews[uiname] then
            viewbase.isDefalut = true
        end
        self.m_Views[uiname] = viewbase
        viewbase:Init(uiname, prefabPath or viewbase.prefabPath)
        if(callBack) then
            viewbase:AddLoadComplete(callBack)
        end
        viewbase:StartLoadView()
    end
    return viewbase
end

--==============================--
--addby:yjp
--desc:显示界面
--@param:
--@return:
--time:2021-10-26 16:36:56
--==============================--
function UIMgr:OpenView(uiname, callBack)
    local zView = self.m_Views[uiname]
    -- print("UIMgr:ShowOrLoadView", uiname, zView)
    if zView ~= nil then
		if(callBack) then
            zView:AddLoadComplete(callBack)
        end
        zView:SetIsPop(true)
    else
        zView = self:CreateView(uiname, callBack)
    end

    return zView
end

function UIMgr:GetView(viewName)
   return self.m_Views[viewName]
end

function UIMgr:ShowView(viewName)
    local zView = self.m_Views[viewName]
    if zView~= nil then
        zView:SetIsPop(true)
    end
end

function UIMgr:HideView(viewName)
    local zView = self.m_Views[viewName]

    if zView~= nil then
       zView:SetIsPop(false)
    end
end

function UIMgr:HideAllView()
    for _,mView in pairs(self.m_Views) do
        if mView ~= nil then
            mView:SetIsPop(false)
        end
    end
end

function UIMgr:HideOtherView(Weight, ignoreView, ignoreDic)
    for viewName,mView in pairs(self.m_Views) do
        if mView.weight == Weight and mView ~= ignoreView and mView:GetIsPop() == true and (ignoreDic == nil or ignoreDic[viewName] == nil)  then
            mView:SetActive(false)
        end
    end
end

function UIMgr:CloseOtherView(Weight, ignoreView, ignoreDic)
    for viewName,mView in pairs(self.m_Views) do
        if mView.weight == Weight and mView ~= ignoreView and (ignoreDic == nil or ignoreDic[viewName] == nil) then
            mView:SetIsPop(false)
        end
    end
end

function UIMgr:ShowNextView(Weight)
    for viewName,mView in pairs(self.m_Views) do
        if mView.weight == Weight and mView:GetIsPop() == true  and mView.isHideOtherView == true then
           mView:SetActive(true)
           return
        end
    end
end

function UIMgr:ShowOtherView(Weight)
    for _,mView in pairs(self.m_Views) do
        if mView:GetIsPop() == true and mView.weight == Weight then
           mView:SetActive(true)
        end
    end
end

function UIMgr:HideWhenSceneLoad()

end

function UIMgr:IsViewPop(viewName)
    local view = self:GetView(viewName)
    if view ~= nil then
        return view:GetIsPop()
    end
    return false
end

function UIMgr:GetChild(viewName,name)
    local  view = self:GetView(viewName)
    if  view ~= nil then
        return view:GetChild(name)
    end
    return nil
end

--------------------------------------飘字，弹幕等-----------------------------------------------------------
Const.MsgPosType = {
	Default = 0,
	RightBottom = 1,
}
local MsgPos = {
	[Const.MsgPosType.Default] = {startPos = Vector3(0, -150, 0),endPos = Vector3(0,0,0),duration = 1.5},
	[Const.MsgPosType.RightBottom] = {startPos = Vector3(150, -300), endPos = Vector3(150, -180), duration = 1.5},
}
--==============================--
--addby:yjp
--desc:显示飘字
--@text:飘字文本
--@config:可选参数 可以设置startPos, endPos, duration, icon等
--@return:nil
--time:2021-11-01 20:13:10
--==============================--
function UIMgr:FloatMsg(text, config)
	config = config or {}
	local msgPosType = config.msgPosType or Const.MsgPosType.Default
    local zfunc = function(view)
		view:AddMessage(text, config)
    end
    Globals.uiMgr:OpenView("MessageView", zfunc)
end

--==============================--
--addby:yjp
--desc:显示传闻
--@data:可选参数 
--[[
    data = {
        content = "消息内容",
        style = 1,...TransferStyle  --传闻样式，默认1
        moveType = Const.TransferMoveType.moveLocalX --从右向左或者从下向上,默认从右向左
        pause = false, --是否在中间暂停
        pauseTime = 1, --在中间暂停是时间，没有则使用默认时间
    }
]]
--@return:
--time:2021-11-01 20:46:05
--==============================--
function UIMgr:ShowTransfer(data)
    local zfunc = function(view)
		view:AddMessage(data)
    end
    Globals.uiMgr:OpenView("MessageTransferView", zfunc)
end
--------------------------------------飘字，弹幕等-----------------------------------------------------------

return UIMgr
