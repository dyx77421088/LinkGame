local BarrageView = BaseClass("BarrageView", UIViewBase)
local BarrageItem = require "Base.UI.Message.BarrageItem"
local _SpeedX = 750/8
local _DistanceX = 100
local _DistanceY = 60
local _DefaultStartY = -138
local _StartY = _DefaultStartY
local _ChatBarrageItem_Stack  --弹幕消息项缓冲池
local function InitPool()
    _ChatBarrageItem_Stack = Stack.New()
end
local function SetStartY(y)
    _StartY = y
end
function BarrageView:__ctor()
    self.passTime = 0
    self.msgCacheList = {}
    self.itemListArray = {}
    self.itemListArray[1] = {}
    self.itemListArray[2] = {}
    self.itemListArray[3] = {}
    InitPool()
    self.weight = GE.GUIWeight.Cheat
end

function BarrageView:ShowSelf()
    if(self.msgCacheList and #self.msgCacheList > 0) then
        if(not self.gameLoop_Id) then
            self.gameLoop_Id = Globals.eventMgr:Bind(EventConst.Common.GameLoop,self.Update,self)
        end
    end
    self.passTime = 0
end

function BarrageView:HideSelf()
    if(self.gameLoop_Id) then
        self.gameLoop_Id = Globals.eventMgr:UnBind(EventConst.Common.GameLoop,self.gameLoop_Id)
    end
end
--paramTable = {insertFront = true插到前面, startY = -138弹幕最高那一排的Y坐标}
function BarrageView:ShowOneBarrageMsgHandler(msg, paramTab)
    local paramTable = paramTab or {}
    local insertFront = paramTable.insertFront
    local startY = paramTable.startY or _DefaultStartY
    SetStartY(startY)
    if(insertFront) then
        table.insert(self.msgCacheList,1,msg)
    else
        table.insert(self.msgCacheList,msg)
    end
    if(not self.isInitialize) then
        return
    end
    if(not self.gameLoop_Id) then
        self.gameLoop_Id = Globals.eventMgr:Bind(EventConst.Common.GameLoop,self.Update,self)
    end
end

function BarrageView:Update(deltaTime)
    self.passTime = self.passTime + deltaTime
    -- if(self.passTime > 0.05) then
        --更新所有弹幕位置
        local isEmpty = self:UpdateAllItemAnchoredPosition(self.passTime)
        self.passTime = 0
        if(#self.msgCacheList > 0) then
            isEmpty = false  --弹幕仍然有消息要更新
            local perfectPos,trackIndex = self:GetPerfectAnchoredPosition()
            if(not perfectPos) then
                return
            end
            local msg = table.remove(self.msgCacheList)
            local barrageItem = _ChatBarrageItem_Stack:Pop() or BarrageItem.New(self.UIprefab,self)
            barrageItem:SetIsPop(true)
            barrageItem:SetText(msg)
            barrageItem:SetAnchoredPosition(perfectPos)
            table.insert(self.itemListArray[trackIndex],barrageItem)  --把弹幕项加入对应轨道
        end
        if(isEmpty and self.gameLoop_Id) then  --如果没有弹幕消息，暂时不更新了
            self.gameLoop_Id = Globals.eventMgr:UnBind(EventConst.Common.GameLoop,self.gameLoop_Id)
            self:Close()
        end
    -- end
end

function BarrageView:GetPerfectAnchoredPosition()
    local pos = Vector2(Screen.width,_StartY)
    local minIndex = 0
    local minPosX = Screen.width
    for i,itemList in ipairs(self.itemListArray) do
        if(#itemList > 0) then  --当前轨道有消息
            local item = itemList[#itemList]
            local anchoredPos = item:GetAnchoredPosition()
            local newPosX = item:GetPreferredWidth() + anchoredPos.x + _DistanceX
            if(minPosX > newPosX - i * _DistanceX) then
                minPosX = newPosX
                minIndex = i
            end
        elseif(minIndex == 0) then                   --当前轨道没有消息
            minIndex = i
        end
    end
    if(minIndex ~= 0) then
        return Vector2(Screen.width + minIndex * _DistanceX, _StartY - _DistanceY*minIndex),minIndex
    else   --所有轨道都还有消息,并且都还在屏幕最右边
        return false,0
    end
end

function BarrageView:UpdateAllItemAnchoredPosition(deltaTime)
    local isEmpty = true  --判断还有没有弹幕消息需要更新
    for i, itemList in ipairs(self.itemListArray) do
        if(#itemList > 0) then
            isEmpty = false
            local deleteIndex = 0
            for i = 1,#itemList do
                local anchoredPos = itemList[i]:GetAnchoredPosition()
                anchoredPos.x = anchoredPos.x - _SpeedX*deltaTime
                local width = itemList[i]:GetPreferredWidth()
                if(anchoredPos.x + width < 0) then
                    itemList[i]:SetIsPop(false)
                    deleteIndex = i
                else
                    itemList[i]:SetAnchoredPosition(anchoredPos)
                end
            end
            if(deleteIndex ~= 0) then  --移除跑到屏幕外的Item
                _ChatBarrageItem_Stack:Push(table.remove(itemList,deleteIndex))
            end
        end
    end
    return isEmpty
end

function BarrageView:Close()
    self:SetIsPop(false)    
    for i,itemList in ipairs(self.itemListArray) do  --把所有的弹幕消息Item回收
        if(#itemList > 0) then
            for j = #itemList,1,-1 do
                itemList[j]:SetIsPop(false)
                _ChatBarrageItem_Stack:Push(table.remove(itemList,j))
            end
        end
    end
    self.msgCacheList = {}
end

function BarrageView:__delete()
    _ChatBarrageItem_Stack = nil
    self.msgCacheList = nil
    self.itemListArray[1] = nil
    self.itemListArray[2] = nil
    self.itemListArray[3] = nil
    self.itemListArray = nil
end

return BarrageView