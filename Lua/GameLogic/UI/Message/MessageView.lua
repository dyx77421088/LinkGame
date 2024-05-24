local MessageView = BaseClass("MessageView", UIViewBase)
local Stack = require "Common.Tool.Stack"
local DOTween = DG.Tweening.DOTween
local _defaultStartPos = Vector3(0,-200,0)
local _defaultEndPos = Vector3(0,0,0)
local _defaultDuration = 2

function MessageView:__ctor(cb)
    self.contentTxt = false
    self.contentTxtList = false
    self.timer_id = false
    self.weight = Const.GUIWeight.Message
end

function MessageView:__delete()
    self.contentTxt  = false
    self.timer_id = false
    self.contentTxtList = false
    self.dataStack = nil
    if(self.curData) then
        self.curData.seq:Kill()
        self.curData.seq = nil
        self.curData = nil
    end
end

function MessageView:Initialize()
    self.contentTxt = self:GetChild("Text")
    self.contentTxt.gameObject:SetActive(false)
	self.dataStack = Stack.New()
    self.contentTxtList = {}
end

-- 执行
function MessageView:GameLoopUpdate(deltaTime)
    self:ShowInfolist()
end

-- 添加数据
function MessageView:AddMessage(str, config)
    local data = self.dataStack:Pop() or {str = ""}
    data.str = str
    if(config) then
        for key, value in pairs(config) do
            data[key] = value
        end
    end
    table.insert( self.contentTxtList, data)
    self:ShowInfolist()
end

local function RemoveChildTimer(child)
    if child == nil then
        return
    end
    GameObject.Destroy(child)
end

-- 显示飘字
function MessageView:ShowMessage(data)
    local instance = data.child or GameObject.Instantiate(self.contentTxt.gameObject)
    local instrans = instance.transform
    instrans:SetParent(self.transform, false)

    instance:SetActive(true)
    local childConText = instance:GetComponent(ClassType.Text)
    childConText.text = data.str
    data.child = instance
    self:FlyMessage(data)
end

-- 执行动画
function MessageView:FlyMessage(data)
    self.curData = data
    local go = data.child.gameObject
    local startPos = data.startPos or _defaultStartPos
    local endPos = data.endPos or _defaultEndPos
    self.isShowing = true
    data.child.transform.anchoredPosition = startPos
    -- 执行完回调
    local moveComplete = function()
        if(ObjectUtils.IsNotNil(data.child)) then
            data.child:SetActive(false)
        end
        if(data.seq) then
            data.seq:Kill()
            data.seq = nil
        end
        --显示完了回收数据
        self.dataStack:Push(data)
        self.isShowing = false
        self.curData = nil
        self:ShowInfolist()
    end
    if(data.seq) then
        data.seq:Kill()
        data.seq = nil
    end
    data.seq = DOTween.Sequence()
    data.seq:Append(data.child.transform:DOLocalMove(endPos, data.duration or _defaultDuration)):AppendCallback(moveComplete)
end

function MessageView:ShowInfolist()
    if(self.isShowing) then
        return
    end
    if (#(self.contentTxtList) > 0) then 
        local zdata = table.remove( self.contentTxtList, 1)
        self:ShowMessage(zdata)
    else
        self:SetIsPop(false)
    end
end


return MessageView