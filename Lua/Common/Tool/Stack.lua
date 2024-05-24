--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:用Lua模拟堆栈
--     创建时间:2022/04/28 
--------------------------------------------------------------------------------
local Stack = BaseClass("Stack")

function Stack.__ctor(self)
    self.list = {}
end

--入栈
function Stack.Push(self, data)
    table.insert(self.list, data)
end

--出栈
function Stack.Pop(self)
    return table.remove(self.list)
end

--堆栈大小
function Stack.Size(self)
    return #self.list
end

--判断堆栈是否为空
function Stack.Empty(self)
    return #self.list == 0
end

--清空数据
function Stack.Clear(self)
    if #self.list > 0 then
        self.list = {}
    end
end

--删除头结点（栈底）
function Stack.Shift(self)
    return table.remove(self.list, 1)
end

--获取栈顶数据（不弹出）
function Stack.Peek(self)
    return self.list[#self.list]
end

--获取堆栈列表
function Stack.GetList(self)
    return self.list
end

return Stack