--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:专门用来记录每个操作的Record对象，方便后续进行撤销和重做
--     创建时间:2022/04/28 
--------------------------------------------------------------------------------
local Record = BaseClass("Record")
function Record.__ctor(self, size)
    --撤销堆栈和重做堆栈的最大长度
    self.maxSize = size or 10
    --撤销堆栈 上一步
    self.undoStack = Stack.New()
    --重做堆栈 下一步
    self.redoStack = Stack.New()
end

function Record.Clear(self)
    self.undoStack:Clear()
    self.redoStack:Clear()
end

 --获取可撤销栈 栈顶的数据,用于展示
function Record.GetTopValue(self)
    return self.undoStack:Peek()
end

--//添加记录,
--把数据直接添加到可撤销栈内,并且清空可重做栈
function Record.AddRecord(self, data)
    --当可撤销栈的大小大于最大的限制的话,那么需要删除头结点
    if (self.undoStack:Size() >= self.maxSize) then
        self.undoStack:Shift()
    end
    self.undoStack:Push(data)
    self.redoStack:Clear()
end

--撤销
--检测可撤销栈是否为空，为空的话什么也不做
--不然把可撤销栈出栈的数据添加到可重做栈内
function Record.UndoRecord(self)
    if (self.undoStack:Empty()) then
        return
    end
    local data = self.undoStack:Pop()
    self.redoStack:Push(data)
end

function Record.GetCanUndo(self)
    return not self.undoStack:Empty()
end

-- --把最新的设置加入到空的重做栈
-- function Record.AddRedo(self, data)
--     if(not self.redoStack:Empty()) then
--         return 
--     end
--     self.undoStack:Push(data)
-- end

--
--检测可重做栈是否为空，为空的话什么也不做
--把可重做栈出栈的数据添加到可撤销栈内
function Record.RedoRecord(self)
    if (self.redoStack:Empty()) then
        return
    end
    local data = self.redoStack:Pop()
    self.undoStack:Push(data)
end

function Record.GetCanRedo(self)
    return not self.redoStack:Empty()
end

function Record.GetUndoStack(self)
    return self.undoStack:GetList()
end

function Record.GetUndoStackSize(self)
    return self.undoStack:Size()
end 

function Record.GetRedoStack(self)
    return self.redoStack:GetList()
end

function Record.GetRedoStackSize(self)
    return self.redoStack:Size()
end

return Record