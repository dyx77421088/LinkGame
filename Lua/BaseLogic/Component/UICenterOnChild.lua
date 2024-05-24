--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:为让滚动视图滚动结束后找到最近的某个子物体居中显示
--     创建时间:2022/05/24 
--------------------------------------------------------------------------------
local AxisType = {
    Vertical = 1,
    Horizontal = 2,
}


local Input = UnityEngine.Input
local UICenterOnChild = BaseClass("UICenterOnChild", UIItem)

function UICenterOnChild:__ctor(scrollView, content, baseView)
    self.minIndex = nil
    self.maxIndex = nil
    self._centering = false --是否在滚动到中心的过程中
    self._targetPos = nil --需要滚动到的目标位置
    self.gameObject = scrollView.gameObject
    self.transform = scrollView.transform
    self.scrollRect = scrollView
    self.content = content
    self.onCenter = nil
    self.onScroll = nil
    self.onScrollFinish = nil
    self.axisType = 0
    self.centerSpeed = 0.5
    for i = 0, self.content.transform.childCount - 1 do
        local child = self.content.transform:GetChild(i)
        child.pivot = Vector2(0,1)
    end
    self:InitItem(scrollView.gameObject, nil, baseView)
end

function UICenterOnChild:SetRange(min, max)
    self.minIndex = min
    self.maxIndex = max
end

function UICenterOnChild:SetCenterSpeed(speed)
    self.centerSpeed = speed
end

function UICenterOnChild:SetOnCenter(onCenter)
    self.onCenter = onCenter
end

function UICenterOnChild:SetOnScroll(onScroll)
    self.onScroll = onScroll
end

function UICenterOnChild:SetOnScrollFinish(onScrollFinish)
    self.onScrollFinish = onScrollFinish
end

function UICenterOnChild:SetLocateAtIndex(index)
    if(not self.childPosList) then
        return
    end
    if(index <= 0 or index > table.getn(self.childPosList)) then
        return
    end
    if(self.minIndex) then
        index = math.max(self.minIndex, index)
    end
    if(self.maxIndex) then
        index = math.min(self.maxIndex, index)
    end
    self._targetPos = self.childPosList[index]
    self._centering = true;
    local centerChild = self.content.transform:GetChild(index - 1).gameObject;
    if(self.onCenter) then
        self.onCenter(centerChild, index)
    end
end

function UICenterOnChild:__delete()

end

function UICenterOnChild:Initialize()
    if(not self.scrollRect) then
        printerror("CenterOnChild:No ScrollRect");
        return
    end
    local luaTrigger = self.gameObject:GetComponent("LuaEventTrigger")
    if(not luaTrigger) then
        printerror("CenterOnChild gameObject has no LuaEventTrigger")
        return
    end
    luaTrigger:SetLuaCbFunc(callback(self, "OnEventTrigger"))

    self.axisType =  self.scrollRect.horizontal == true and AxisType.Horizontal or AxisType.Vertical
    -- self.scrollRect.movementType = UnityEngine.UI.ScrollRect.MovementType.Unrestricted
    self:ReSize()
end

function UICenterOnChild:ShowSelf()
    if(self.onUpdate) then
        LMessage:UnRegister(LuaEvent.Common.ApplicationUpdate, self.onUpdate)
    end
    self.onUpdate = LMessage:Register(LuaEvent.Common.ApplicationUpdate, "Update", self)
end

function UICenterOnChild:HideSelf()
    if(self.onUpdate) then
        LMessage:UnRegister(LuaEvent.Common.ApplicationUpdate, self.onUpdate)
    end
end

function UICenterOnChild:ReSize()
    local grid = self.content:GetComponent(ClassType.GridLayoutGroup)
    if(not grid) then
        printerror("CenterOnChild: No GridLayoutGroup on the ScrollRect's content")
        return
    end
    --每个单元格的尺寸
    local cellSize = grid.cellSize
    local spaceSize = grid.spacing
    local lastSpaceSize = grid.spacing
    local paddingLeft = grid.padding.left
    local paddingTop = grid.padding.top
    self.unitSize = Vector2(cellSize.x + spaceSize.x, cellSize.y + spaceSize.y)
    self.childPosList = {}
    local scrollTrans = self.scrollRect.gameObject:GetComponent(ClassType.RectTransform);
    local contentTrans = self.content:GetComponent(ClassType.RectTransform);
    if(self.axisType == AxisType.Horizontal) then
        --计算第一个子物体位于中心时的位置
        local childPosX = scrollTrans.rect.width * 0.5 - cellSize.x * 0.5 - paddingLeft--水平的公式
        table.insert(self.childPosList, childPosX)
        --计算能容纳多少个子对象
        local containerWidth = contentTrans.rect.width
        --containerWidth 加上spaceSize.x是因为计算间隔的时候会少一个间隔
        local childCount = math.ceil((containerWidth + lastSpaceSize.x) / (cellSize.x + spaceSize.x))
        --取计算出的childCount和子对象数目的最大值 
        childCount = math.max(childCount, contentTrans.childCount)
        --缓存所有子物体位于中心时的位置
        for i = 1, childCount - 1 do
            childPosX = childPosX - (cellSize.x + spaceSize.x)
            table.insert(self.childPosList, childPosX)
        end
    else
        local childPosY = contentTrans.localPosition.y - (scrollTrans.rect.height * 0.5 - cellSize.y * 0.5 - paddingTop) --垂直的公式
        table.insert(self.childPosList, childPosY)
        --计算能容纳多少个子对象
        local containerHeight = contnetTrans.rect.height;
        --containerHeight加上spaceSize.y是因为计算间隔的时候会少一个间隔
        local childCount = math.ceil((containerHeight + lastSpaceSize.y) / (cellSize.y + spaceSize.y))
        --取计算出的childCount和子对象数目的最大值（使用UIWrapContent或者子对象有缩放的问题）
        childCount = math.max(childCount, contentTrans.childCount)
        --缓存所有子物体位于中心时的位置
        for i = 1, childCount - 1 do
            childPosY = childPosY + cellSize.y + spaceSize.y
            table.insert(self.childPosList, childPosY)
        end
    end
end

function UICenterOnChild:Update()
    -- printerror("Update:", self._centering)
    if(not self._centering) then
        --坑，偶尔会没有触发EndDrag，根据最后拖动的时间来判断吧
        if(self.lastDragTime and Time.realtimeSinceStartup - self.lastDragTime > 0.1 and not self:IsInTouch()) then
            self:OnEventTrigger(nil, "EndDrag")
        end
        return
    end
    local contentTrans = self.content:GetComponent(ClassType.RectTransform)
    local v = contentTrans.localPosition
    if(self.axisType == AxisType.Horizontal) then
        v.x = math.lerp(contentTrans.localPosition.x, self._targetPos, self.centerSpeed)
        contentTrans.localPosition = v;
        if (self.onScroll) then
            self.onScroll(v.x)
        end
        if (math.abs(contentTrans.localPosition.x - self._targetPos) < 0.1) then
            self._centering = false;
            self.scrollRect:StopMovement()
            if (self.onScrollFinish) then
                self.onScrollFinish()
            end
        end
    else
        v.y = math.lerp(contentTrans.localPosition.y, self._targetPos, self.centerSpeed)
        contentTrans.localPosition = v;
        if (self.onScroll) then
            self.onScroll(v.y)
        end
        if (math.abs(contentTrans.localPosition.y - self._targetPos) < 0.1) then
            self._centering = false;
            self.scrollRect:StopMovement();
            if (self.onScrollFinish) then
                self.onScrollFinish()
            end
        end
    end
end

function UICenterOnChild:OnEventTrigger(luaTrigger, param)
    -- printerror("OnEventTrigger----------")
    if(param == "Drag") then
        self._centering = false
        if(self.onScroll) then
            local contnetTrans = self.content:GetComponent(ClassType.RectTransform)
            local pos = self.axisType == AxisType.Horizontal and contnetTrans.localPosition.x or contnetTrans.localPosition.y
            self.onScroll(pos)
        end
        self.lastDragTime = Time.realtimeSinceStartup
    elseif(param == "EndDrag") then
        -- printerror("EndDrag..............")
        self._centering = true
        self.lastDragTime = false
        local contnetTrans = self.content:GetComponent(ClassType.RectTransform)
        local distance = 0
        if(self.axisType == AxisType.Horizontal) then
            distance = contnetTrans.localPosition.x - self.beginPosition
            local sign = distance / math.abs(distance)
             --滑动距离超过100就算要滑动到下一页
            local addDistance = math.abs(distance) > 100 and self.unitSize.x * sign / 2 or 0
            self._targetPos = self:FindClosestPos(contnetTrans.localPosition.x + addDistance)
        else
            distance = contnetTrans.localPosition.y - self.beginPosition
            local sign = distance / math.abs(distance)
             --滑动距离超过100就算要滑动到下一页
            local addDistance = math.abs(distance) > 100 and self.unitSize.y * sign / 2 or 0
            self._targetPos = self:FindClosestPos(contnetTrans.localPosition.y + addDistance)
        end
    elseif(param == "BeginDrag") then
        -- printerror("BeginDrag.............")
        if(self.axisType == AxisType.Horizontal) then
            self.beginPosition = self.content.localPosition.x
        else
            self.beginPosition = self.content.localPosition.y
        end
    end
end

function UICenterOnChild:FindClosestPos(currentPos)
    local childIndex = 1
    local closest = 0
    local distance = 10000000

    for i, p in ipairs(self.childPosList) do
        local d = math.abs(p - currentPos);
        if (d < distance) then
            distance = d
            childIndex = i
        end
    end
    print(currentPos,  "  " , childIndex)

    childIndex = math.min(childIndex, self.content.transform.childCount)
    childIndex = math.max(childIndex, 1)
    if(self.minIndex) then
        childIndex = math.max(self.minIndex, childIndex)
    end
    if(self.maxIndex) then
        childIndex = math.min(self.maxIndex, childIndex)
    end
    closest = self.childPosList[childIndex]
    local centerChild = self.content.transform:GetChild(childIndex - 1).gameObject
    if (self.onCenter) then
        self.onCenter(centerChild, childIndex)
    end
    return closest
end


function UICenterOnChild:IsInTouch()
    if(ComUtils.IsMobile()) then
        -- printext("IsInTouch: ============>", Input.touchCount, Input.GetTouch(0).phase)
        return Input.touchCount > 0
    else
        return Input.GetMouseButton(0)
    end
end

return UICenterOnChild