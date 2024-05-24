--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:音效Item，显示一条音效信息
--     创建时间:2022/07/26 
--------------------------------------------------------------------------------
local SoundNameData = Globals.configMgr:GetConfig("SoundData")
local SoundItem = BaseClass("SoundItem", UIItem)
local Path = System.IO.Path
local File = System.IO.File

function SoundItem:__ctor(parent, type, baseView)
    self.type = type
    self:InitItem(parent, nil,  baseView)
end

function SoundItem:__delete()

end

function SoundItem:Initialize()
    if(self.type == 2) then
        LuaUIEventListener.SetOnBeginDrag(self.gameObject, callback(self, "OnBeginDrag"))
        LuaUIEventListener.SetOnDrag(self.gameObject, callback(self, "OnDrag"))
        LuaUIEventListener.SetOnEndDrag(self.gameObject, callback(self, "OnEndDrag"))
    end
    self.move = self:GetChild("move")
    self.startPosition = self.move.anchoredPosition
    self.highLight = self:GetChild("move/highLight")
    self.highLight.gameObject:SetActive(false)
    self.tryBtn = self:GetChild("move/btnTry")
    self:AddOnClick(self.tryBtn, callback(self, "OnClickTryBtn"))
    self.downLoadBtn = self:GetChild("move/btnDownload")
    self:AddOnClick(self.downLoadBtn, callback(self, "OnClickDownLoadBtn"))
    self.nameText = self:GetChild("move/name", ClassType.Text)
    self.revertBtn = self:GetChild("move/revertBtn")
    self:AddOnClick(self.revertBtn, callback(self, "OnClickRevertBtn"))
    self.revertBtn.gameObject:SetActive(false)
    self.downLoadBtn.gameObject:SetActive(self.type == 1)
    self.deleteBtn = self:GetChild("move/btnDelete")
    self:AddOnClick(self.deleteBtn, callback(self, "OnClickDeleteBtn"))
    self.deleteBtn.gameObject:SetActive(self.type == 2)
end

function SoundItem:OnBeginDrag(eventData)
    local delta = eventData.delta
    local theta = math.atan(delta.y, delta.x)
    --不是竖直拖动不做处理
    local min = math.angle2radian(65)
    local max = math.angle2radian(115)
    if  math.angle2radian(65) < theta and theta < math.angle2radian(115) then
        self.mBaseView.importScroll:OnBeginDrag(eventData)
        return
    end
    min = math.angle2radian(-65)
    max = math.angle2radian(-115)
    if math.angle2radian(-115) < theta and theta < math.angle2radian(-65) then
        self.mBaseView.importScroll:OnBeginDrag(eventData)
        return
    end
    self.isDraging = true
    --禁用scrollView滚动
    self.mBaseView.importScroll.enabled = false
end

function SoundItem:OnDrag(eventData)
    if not self.isDraging then
        self.mBaseView.importScroll:OnDrag(eventData)
         return
    end
    local uiCamera = Globals.cameraMgr:GetUICamera()
    local screenPoint = Globals.touchMgr:GetTouchPosition()
    local hasValue, anchoredPosition = false, Vector2.zero
    hasValue, anchoredPosition = TransformUtils.ScreenPointToLocalPointInRectangle(self.transform , screenPoint, uiCamera, anchoredPosition) 
    if(hasValue) then
        self.move.anchoredPosition = anchoredPosition
        self.mBaseView:ShowHighLightItem()--高亮显示托上去的item
    end
end

function SoundItem:OnEndDrag(eventData)
    if not self.isDraging then
        self.mBaseView.importScroll:OnEndDrag(eventData)
        return
    end
    self.move.anchoredPosition = self.startPosition
    self.mBaseView:EndDragImportItem(self)
    self.isDraging = false
    self.mBaseView.importScroll.enabled = true
end

-- function SoundItem:OnDragItem(luaTrigger, param)
--     if(param == "Drag") then
--         if(not self.canDrag) then
--             return
--         end
--         local screenPoint = Globals.touchMgr:GetTouchPosition()
--         local isIn, localPoint = false, Vector2.zero
--         isIn, localPoint = TransformUtils.ScreenPointToLocalPointInRectangle(self.transform, screenPoint, Globals.cameraMgr:GetUICamera(), localPoint)
--         self.move.anchoredPosition = localPoint
--         self.mBaseView:ShowHighLightItem()--高亮显示托上去的item
--     elseif(param == "EndDrag") then
--         self.move.anchoredPosition = self.startPosition
--         self.mBaseView:EndDragImportItem(self)
--     elseif(param == "PointerDown") then
--         self:RemoveTimer()
--         Globals.timerMgr:AddTimer(function()
--             self.canDrag = true
--         end, 0, 1)
--     elseif(param == "PointerUp") then
--         self:RemoveTimer()
--     end
-- end

function SoundItem:RemoveTimer()
    if(self.clickTimer) then
        self.clickTimer = Globals.timerMgr:DelTimer(self.clickTimer)
        self.clickTimer = nil
    end
    self.canDrag = false
end

local lastItem
local lastId
function SoundItem:OnClickTryBtn(go)
    if(lastItem and lastId) then
        if(lastItem.type == 1) then
            Globals.soundMgr:StopEffect(lastId)
        else
            Globals.soundMgr:StopExtraEffect(lastId)
        end
    end
    if(self.type == 1) then
        local id = string.replace(self.data.assetPath, "Assets/SmallGame/Bundle/", "")
        local arr = string.split(id, ".")
        id = arr[1]
        if(string.contains(self.data.assetPath, "Effect")) then
            Globals.soundMgr:PlayEffect(id)
        else
            Globals.soundMgr:PlayEffect(id)
            -- Globals.soundMgr:PlayMusic(id)
        end
        lastId = id
    else
        Globals.soundMgr:PlayExtraEffect(self.resName)
        lastId = self.resName
    end
    lastItem = self
end

function SoundItem:OnClickDownLoadBtn(go)
    if(self.type == 1) then
        AudioResMgr.AudioRes.DownLoad(self.data.assetId, self.mBaseView.downLoadPath .. "/" .. Path.GetFileName(self.data.assetPath))
    end
end

function SoundItem:OnClickRevertBtn(go)
    self.nameText.text = Path.GetFileName(self.resName)
    self.mBaseView:OnImportRevert(self)
    self.revertBtn.gameObject:SetActive(false)
end

function SoundItem:OnClickDeleteBtn(go)
    if(self.type == 1) then
        return
    end
    File.Delete(self.resName)
    self:SetIsPop(false)
end

function SoundItem:SetType(type)
    self.type = type
end

function SoundItem:SetData(data)
    self.data = data
    if(self.type == 1) then--左边已经使用的游戏中音效
        local id = string.replace(self.data.assetPath, "Assets/SmallGame/Bundle/Sound/", "")
        local arr = string.split(id, ".")
        local name = ""
        if(SoundNameData["Bundle/Sound/" .. arr[1]]) then
            name = SoundNameData["Bundle/Sound/" .. arr[1]].name
        end
        self.nameText.text = id .. "[" .. name .. "]"
    else                    --右边导入的需要覆盖原有音效的音效
        self.nameText.text = "<color=#00ff00>" .. Path.GetFileName(self.data.originalRes) .. " => </color>" .. Path.GetFileName(self.data.replaceRes)
        self.revertBtn.gameObject:SetActive(true)
    end
end

function SoundItem:GetData()
    return self.data
end

function SoundItem:SetResName(name)
    self.resName = name
    self.nameText.text = Path.GetFileName(self.resName)
end

function SoundItem:GetResName()
    return self.resName
end

function SoundItem:ShowHighLightItem()
    local screenPoint = Globals.touchMgr:GetTouchPosition()
    local isContains = TransformUtils.RectangleContainsScreenPoint(self.move, screenPoint, Globals.cameraMgr:GetUICamera())
    self.highLight.gameObject:SetActive(isContains)
    return isContains
end

function SoundItem:HideHighLight()
    self.highLight.gameObject:SetActive(false)
end

function SoundItem:ShowSelf()

end

function SoundItem:HideSelf()

end

return SoundItem