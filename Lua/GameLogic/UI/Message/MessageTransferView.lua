--用来做系统传闻
local MessageTransferView = BaseClass("MessageTransferView", UIViewBase)
local DOTween = DG.Tweening.DOTween
Const.TransferMoveType = {
    moveLocalX = 1,
    moveLocalY = 2,
}
--从右向左移动速度
local moveXSpeed = 100
--从右向左移动停留时间
local moveXPause = 3
--从下到上移动速度
local moveYSpeed = 100
--从下向上移动暂停时间
local moveYPause = 4.5
--消息容量，在等待队列中的消息容量
local msgCapacity = 99

--样式有几种
local TransferStyle = 1 

function MessageTransferView:__ctor()
    self.contentTxt = false
    self.msgQueue = false
    self.isShowing = false
    self.curShowData = false
    self.maskList = {}
    self.contentTxtList = {}
    self.weight = Const.GUIWeight.Message
end

function MessageTransferView:Initialize()
    self.panel = self:GetChild("Panel")
    for i = 1, TransferStyle do
        local contentText =  self:GetChild("Panel/Mask" .. i .."/Text","Text")
        table.insert(self.contentTxtList, contentText)

        local mask = self:GetChild("Panel/Mask" .. i)
        table.insert(self.maskList, mask)
    end
    self.msgQueue = {}
    self.panel.gameObject:SetActive(false)
end

function MessageTransferView:SwitchMask(style, bgName)
    Globals.resMgr:LoadSprite("Common/Common",bgName,function(sprite)
        local mask = self:GetChild("Panel/Mask" .. style, ClassType.Image)
        mask.sprite = sprite
    end)
end

--[[
    data = {
        content = "消息内容",
        style = 1,...TransferStyle  --传闻样式，默认1
        moveType = Const.TransferMoveType.moveLocalX --从右向左或者从下向上,默认从右向左
        pause = false, --是否在中间暂停
        pauseTime = 1, --在中间暂停是时间，没有则使用默认时间
    }
]]
function MessageTransferView:AddMessage(data)
    data.style = data.style or 1
    data.moveType = data.moveType or Const.TransferMoveType.moveLocalX
    if (self.isShowing == true) then
        --如果超出容量了，就移除队首的消息
        if(#self.msgQueue >= msgCapacity) then
            table.remove(self.msgQueue, 1)
        end
        table.insert(self.msgQueue, data)
    else
        self:ShowOneMessage(data)
    end
end

--传文的展示分三段处理  飘到中间显示  停留显示  飘出传文并消失
function MessageTransferView:ShowOneMessage(data)
    printext("MessageTransferView:ShowMessage", table.tostring(data))
    coroutine.stop(self.moveCorutine)
    self.moveCorutine = coroutine.start(function()
        self.curShowData = data
        self.isShowing = true
        self.panel.gameObject:SetActive(true)
        for i = 1, TransferStyle do
            self.maskList[i].gameObject:SetActive(false)
        end
        self.maskList[data.style].gameObject:SetActive(true)

        local contentText = self.contentTxtList[data.style]
        contentText.text = data.content

        local textWidth = contentText.preferredWidth
        local textHeight = contentText.preferredHeight
        -- local textWidth = string.utf8len(data.content) * 22
        --printError(string.utf8len(data.content), textWidth, contentText.preferredWidth)
        local maskWidth = self.maskList[data.style].rect.width
        -- printerror("maskWidth :",maskWidth , "  textWidth:" , textWidth)
        self:KillDoTween()
        self.moveSeq = DOTween.Sequence()
        --传闻进入
        if(data.moveType == Const.TransferMoveType.moveLocalX) then
            contentText.transform.anchoredPosition = Vector2((maskWidth + textWidth) / 2, 0)
            self.moveSeq:Append(contentText.transform:DOLocalMoveX(0, (maskWidth + textWidth) / (2 * moveXSpeed)))
            coroutine.wait((maskWidth + textWidth) / (2 * moveXSpeed))
        else
            contentText.transform.anchoredPosition = Vector2(0, -textHeight)
            self.moveSeq:Append(contentText.transform:DOLocalMoveY(0, textHeight / moveYSpeed))
            coroutine.wait(textHeight / moveYSpeed)
        end
        --传闻停留
        if(data.pause and data.moveType == Const.TransferMoveType.moveLocalX) then
            coroutine.wait(data.pauseTime or moveXPause)
        elseif(data.pause and data.moveType == Const.TransferMoveType.moveLocalY) then
            coroutine.wait(data.pauseTime or moveYPause)
        end
        --传闻退出
        self:KillDoTween()
        self.moveSeq = DOTween.Sequence()
        if(data.moveType == Const.TransferMoveType.moveLocalX) then
            self.moveSeq:Append(contentText.transform:DOLocalMoveX(-(maskWidth + textWidth) / 2, (maskWidth + textWidth) /  (2 * moveXSpeed)))
            -- coroutine.wait((maskWidth + textWidth) / (2 * moveXSpeed))
        else
            self.moveSeq:Append(contentText.transform:DOLocalMoveY(textHeight, textHeight / moveYSpeed))
            -- coroutine.wait(textHeight / moveYSpeed)
        end
        self.moveSeq:AppendCallback(callback(self, "MoveEnd"))
    end)
end

function MessageTransferView:KillDoTween()
	if(self.moveSeq) then
		self.moveSeq:Kill()
		self.moveSeq = nil
	end
end

function MessageTransferView:MoveEnd()
    self.isShowing = false
    self:KillDoTween()
    if(not self.msgQueue or #self.msgQueue <= 0) then
        self:SetIsPop(false)
        return
    end
    self:ShowMessage(table.remove(self.msgQueue,1))
end


function MessageTransferView:__delete()
    self.msgQueue = false
    self.isShowing = false
    self.contentTxtList = false
    self.maskList = false
end

return MessageTransferView