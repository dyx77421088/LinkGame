--------------------------------------------------------------------------------
--      Copyright (c) 2015 - 2016 , 蒙占志(topameng) topameng@gmail.com
--      All rights reserved.
--      Use, modification and distribution are subject to the "MIT License"
--------------------------------------------------------------------------------
-- zsm修改:list变种实现，只能使用next()进行循环，需要进入list的节点必须带有 _next = 0, _prev = 0, removed = true属性
-- 这个list是一个闭环循环，也就是_next永远指向下一个，_prev指向上一个，list本身作为一个root节点,所以self._prev指向最后一个点
-- _next ,_prev永远有值，在列表为空时，指向自己(_root._next => _root； _root._prev => root)，当有A,B,C时循环如下：
-- root._next => A._next => B._next => C._next => root._next => A._next => B._next ...
-- root._prev => C._prev => B._prev => A._prev => root._prev => C._prev => B._prev ...
local setmetatable = setmetatable

local list = {}
list.__index = list

function list.New()
	local t = {length = 0, _prev = 0, _next = 0, nextnode = false}
	t._prev = t
	t._next = t
	return setmetatable(t, list)
end

function list:Clear()
	self._next = self
	self._prev = self
	self.length = 0
	self.nextnode = false
end

function list:Push(node)
	if not node._removed then return end
	local lastNode = self._prev
	self._prev = node  --尾节点
	node._next = self  --指向root，构成循环
	node._prev = lastNode
	lastNode._next = node

	node._removed = false
	self.length = self.length + 1
end

function list:Pop()
	local _prev = self._prev
	self:Remove(_prev)
	if _prev == self then
		return nil
	end
	return _prev
end

function list:Unshift(node)
	if not node._removed then return end
	local firstNode = self._next
	self._next = node
	node._prev = self --指向root，root始终是头节点
	node._next = firstNode
	firstNode._prev = node

	node._removed = false
	self.length = self.length + 1
	return node
end

function list:Shift()
	local _next = self._next
	if _next == self then
		return nil
	end
	self:Remove(_next)
	return _next
end

function list:Find(v, iter)
	iter = iter or self

	repeat
		if v == iter then
			return iter
		else
			iter = iter._next
		end		
	until iter == self

	return nil
end

function list:Findlast(v, iter)
	iter = iter or self

	repeat
		if v == iter then
			return iter
		end

		iter = iter._prev
	until iter == self

	return nil
end

function list:Remove(iter)
	if iter._removed then return end
	local _prev = iter._prev
	local _next = iter._next
	_next._prev = _prev
	_prev._next = _next

--这一段是保证删除列表的值时，循环能够继续，而_prev, _next必须清除，不然容易形成引用，导致所持有的对象无法gc掉
--原有tolua的list是没有iter._prev, iter._next = false, false这段语句的
	if self.nextnode == iter then
		self.nextnode = _next
	end
	iter._prev, iter._next = false, false

	self.length = math.max(0, self.length - 1)
	iter._removed = true
end

--开始了就必须调用end
function list:StartNext()
	-- body
	if self._next == self then
		return nil
	end
	local _next = self._next
	self.nextnode = _next._next
	return _next
end

function list:Next()
	if self.nextnode == self then
		self.nextnode = false
		return nil
	end
	local _next = self.nextnode
	self.nextnode = _next._next
	return _next
end

function list:EndNext()
	self.nextNode = false
end

function list:Erase(v)
	local iter = self:Find(v)

	if iter then
		self:Remove(iter)		
	end
end

function list:Insert(node, iter)	
	if not iter then
		return self:Push(node)
	end
	if not node._removed then return end
	node._next = iter.next
	node._prev = iter
	iter.next._prev = node
	iter.next = node
	node._removed = false
	self.length = self.length + 1
	return node
end

function list:Head()
	local _next = self._next
	return _next == self and nil or _next
end

function list:Last()
	local _prev = self._prev
	return _prev == self and nil or _prev
end

-- local b = list.New()
-- print(b.length)
-- local testList = {}
-- local g = nil
-- for i = 1, 10 do
-- 	local c = {index = i, _prev = 0, _next = 0, _removed = true}
-- 	testList[i] = c
-- 	b:Push(c)
-- 	-- print(b.length)
-- end
-- print("unshift end")

-- for i = 1, 3 do
-- 		b:Remove(testList[i])
-- 	end
-- 	b:Remove(testList[6])
-- 	b:Remove(testList[10])
-- print("fStart", b.length, b, b._prev, b._next)
-- local iter = b:StartNext()
-- local c = 100
-- while iter do   
-- 	-- b:Remove(iter)
-- 	print("while", iter.index, b.length)
-- 	-- for i = 1, 9 do
-- 	-- 	b:Remove(testList[i])
-- 	-- end
--     iter = b:Next()
	
--     c = c - 1
--     if c < 0 then
--     	break
--     end
-- end

-- print("fEnd", b.length, b, b._prev, b._next)
-- local iter = b:StartNext()
-- local c = 100
-- while iter do   
-- 	print("while2", iter.index)
-- 	b:Remove(iter)
--     iter = b:Next()
--     c = c - 1
--     if c < 0 then
--     	break
--     end
-- end

return list