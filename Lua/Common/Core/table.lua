--table扩展
--table用来打印的字符串
function table.tostring(t, maxlayer, name)
	local tableDict = {}
	local layer = 0
	maxlayer = maxlayer or 999
	local function cmp(t1, t2)
		return tostring(t1) < tostring(t2)
	end
	local function table_r (t, name, indent, full, layer)
		local id = not full and name or type(name)~="number" and tostring(name) or '['..name..']'
		local tag = indent .. id .. ' = '
		local out = {}  -- result
		if type(t) == "table" and layer < maxlayer then
			if tableDict[t] ~= nil then
				table.insert(out, tag .. '{} -- ' .. tableDict[t] .. ' (self reference)')
			else
				tableDict[t]= full and (full .. '.' .. id) or id
				if next(t) then -- Table not empty
					table.insert(out, tag .. '{')
					local keys = {}
					for key,value in pairs(t) do
						table.insert(keys, key)
					end
					table.sort(keys, cmp)
					for i, key in ipairs(keys) do
						local value = t[key]
						-- if value and type(value) == "userdata" then
						--     print(">>>>>>>>>>>>>>>>>>>>", key, value)
						-- end
						table.insert(out,table_r(value,key,indent .. '|  ',tableDict[t], layer + 1))
					end
					table.insert(out,indent .. '}')
				else table.insert(out,tag .. '{}') end
			end
		else
			local val = type(t)~="number" and type(t)~="boolean" and '"'..tostring(t)..'"' or tostring(t)
			table.insert(out, tag .. val)
		end
		return table.concat(out, '\n')
	end
	return table_r(t,name or 'Table', '', '', layer)
end

function table.unpack(...)
	return unpack(...)
end


function table.print(t, name, maxlayer)
	print(table.tostring(t, maxlayer, name))
end

--table用来保存到本地的字符串
--show_index 列表的情况是否显示key
function table.serialize(t, name, show_index)
	local LINEW = 80
	show_index = show_index or false
	local function p(o, name, indent, send, list_max_count)
		local s = ""
		s = s .. string.rep("\t", indent)
		if name ~= nil then
			if type(name) == "number" then
				if show_index or (tonumber(name) > list_max_count) then
					name = string.format("[%d]", name)
				else
					name = nil
				end
			else
				name = tostring(name)
				if indent ~= 0 then
					if not string.match(name, "^[A-Za-z_][A-Za-z0-9_]*$") then
						name = string.format("[\"%s\"]", name)
					end
				end
			end
			if name ~= "" and name ~= nil then
				s = s .. name .. "="
			end
		end
		if type(o) == "table" then
			s = s.."{"
			local temp = ""
			local keys = {}
			for k, v in pairs(o) do
				table.insert(keys, k)
			end
			pcall(function() table.sort(keys) end)
			for i, k in ipairs(keys) do
				local v = o[k]
				if show_index then
					temp = temp .. p(v, k, indent+1, ",")
				else
					temp = temp .. p(v, k, indent+1, ",", #o)
				end
				
			end

			local temp2 = string.gsub(temp, "[\n\t]", "")
			if #temp2 < LINEW then
				temp = temp2
			else
				s = s .. "\n"
				temp = temp .. string.rep("\t", indent)
			end
			s = s .. temp .. "}" .. send .. "\n"
		else
			if type(o) == "string" then
				-- o = "[[" .. o .. "]]"
				o = '"' .. o .. '"'
			elseif o == nil then
				o = "nil"
			end
			s = s .. tostring(o) .. send .. "\n"
		end
		return s
	end
	if show_index then
		return p(t, name, 0, "")
	else
		return p(t, name, 0, "", #t)
	end
end

--序列化成python的dict
function table.serializeToPython(t, name, show_index)
	local LINEW = 80
	show_index = show_index or false
	local function p(o, name, indent, send, list_max_count)
		local s = ""
		s = s .. string.rep("\t", indent)
		if name ~= nil then
			if type(name) == "number" then
				if show_index or (tonumber(name) > list_max_count) then
					name = string.format("[%d]", name)
				else
					name = nil
				end
			else
				name = tostring(name)
				if indent ~= 0 then
					if not string.match(name, "^[A-Za-z_][A-Za-z0-9_]*$") then
						name = string.format("[\"%s\"]", name)
					end
				end
			end
			if name ~= "" and name ~= nil then
				s = s .. "'" .. name .. "'" .. " : "
			end
		end
		if type(o) == "table" then
			local function f(pre, post)
				s = s..pre
				local temp = ""
				local keys = {}
				for k, v in pairs(o) do
					table.insert(keys, k)
				end
				pcall(function() table.sort(keys) end)
				for i, k in ipairs(keys) do
					local v = o[k]
					if show_index then
						temp = temp .. p(v, k, indent+1, ",")
					else
						temp = temp .. p(v, k, indent+1, ",", #o)
					end
					
				end

				local temp2 = string.gsub(temp, "[\n\t]", "")
				if #temp2 < LINEW then
					temp = temp2
				else
					s = s .. "\n"
					temp = temp .. string.rep("\t", indent)
				end
				s = s .. temp .. post .. send .. "\n"
			end
			if #o == table.nums(o) then
				f("[", "]")
			else
				f("{", "}")
			end
		else
			if type(o) == "string" then
				-- o = "[[" .. o .. "]]"
				o = "'" .. o .. "'"
			elseif o == nil then
				o = "nil"
			end
			s = s .. tostring(o) .. send .. "\n"
		end
		return s
	end
	local sContent =  "# coding=utf-8\n"..name .." = "
	if show_index then
		sContent = sContent .. p(t, "", 0, "")
	else
		sContent = sContent .. p(t, "", 0, "", #t)
	end
	return sContent
end

function table.nums(t)
	local count = 0
	for k, v in pairs(t) do
		count = count + 1
	end
	return count
end

function table.keys(hashtable)
	local keys = {}
	for k, v in pairs(hashtable) do
		keys[#keys + 1] = k
	end
	return keys
end

function table.values(hashtable)
	local values = {}
	for k, v in pairs(hashtable) do
		values[#values + 1] = v
	end
	return values
end

function table.orderedPairs(hashtable, sortFunction)
	local a = {}
	for n in pairs(hashtable) do table.insert(a, n) end
	if sortFunction == nil then
		sortFunction = function(a , b)
			if tostring(a) < tostring(b) then 
				return true
			end
		end
	end
	table.sort(a, sortFunction)
	local i = 0                 -- iterator variable
	local iter = function ()    -- iterator function
		i = i + 1
		if a[i] == nil then return nil
		else return a[i], hashtable[a[i]]
		end
	end
	return iter
end

--[[--

将来源表格中所有键及其值复制到目标表格对象中，如果存在同名键，则覆盖其值

~~~ lua

local dest = {a = 1, b = 2}
local src  = {c = 3, d = 4}
table.merge(dest, src)
-- dest = {a = 1, b = 2, c = 3, d = 4}

~~~

@param table dest 目标表格
@param table src 来源表格

]]
function table.merge(dest, src)
	for k, v in pairs(src) do
		dest[k] = v
	end
	return dest
end

function table.extend(dest, src)
	for _, v in ipairs(src) do
		table.insert(dest, v)
	end
	return dest
end

--[[--

在目标表格的指定位置插入来源表格，如果没有指定位置则连接两个表格

~~~ lua

local dest = {1, 2, 3}
local src  = {4, 5, 6}
table.insertto(dest, src)
-- dest = {1, 2, 3, 4, 5, 6}

dest = {1, 2, 3}
table.insertto(dest, src, 5)
-- dest = {1, 2, 3, nil, 4, 5, 6}

~~~

@param table dest 目标表格
@param table src 来源表格
@param [integer begin] 插入位置

]]
function table.insertto(dest, src, begin)
	begin = checkint(begin)
	if begin <= 0 then
		begin = #dest + 1
	end

	local len = #src
	for i = 0, len - 1 do
		dest[i + begin] = src[i + 1]
	end
end

--[[

从表格中查找指定值，返回其索引，如果没找到返回 false

~~~ lua

local array = {"a", "b", "c"}
print(table.indexof(array, "b")) -- 输出 2

~~~

@param table array 表格
@param mixed value 要查找的值
@param [integer begin] 起始索引值
@param [integer endIndex]

@return integer

]]
function table.indexof(array, value, begin, endIndex)
	if not array then
		return false
	end
	begin = begin or 1
	local len = #array
	endIndex = endIndex or len
	if endIndex > len then
		endIndex = len
	end
	for i = begin, endIndex do
		if array[i] == value then return i end
	end
	return false
end

--[[--

从表格中查找指定值，返回其 key，如果没找到返回 nil

~~~ lua

local hashtable = {name = "dualface", comp = "chukong"}
print(table.keyof(hashtable, "chukong")) -- 输出 comp

~~~

@param table hashtable 表格
@param mixed value 要查找的值

@return string 该值对应的 key

]]
function table.keyof(hashtable, value)
	for k, v in pairs(hashtable) do
		if v == value then return k end
	end
	return nil
end

--[[--

从表格中删除指定值，返回删除的值的个数

~~~ lua

local array = {"a", "b", "c", "c"}
print(table.removebyvalue(array, "c", true)) -- 输出 2

~~~

@param table array 表格
@param mixed value 要删除的值
@param [boolean removeall] 是否删除所有相同的值

@return integer

]]
function table.removebyvalue(array, value, removeall)
	local c, i, max = 0, 1, #array
	while i <= max do
		if array[i] == value then
			table.remove(array, i)
			c = c + 1
			i = i - 1
			max = max - 1
			if not removeall then break end
		end
		i = i + 1
	end
	return c
end

--[[--

对表格中每一个值执行一次指定的函数，并用函数返回值更新表格内容

~~~ lua

local t = {name = "dualface", comp = "chukong"}
table.map(t, function(v, k)
	-- 在每一个值前后添加括号
	return "[" .. v .. "]"
end)

-- 输出修改后的表格内容
for k, v in pairs(t) do
	print(k, v)
end

-- 输出
-- name [dualface]
-- comp [chukong]

~~~

fn 参数指定的函数具有两个参数，并且返回一个值。原型如下：

~~~ lua

function map_function(value, key)
	return value
end

~~~

@param table t 表格
@param function fn 函数

]]
function table.map(t, fn)
	for k, v in pairs(t) do
		t[k] = fn(v, k)
	end
end

--[[--

对表格中每一个值执行一次指定的函数，但不改变表格内容

~~~ lua

local t = {name = "dualface", comp = "chukong"}
table.walk(t, function(v, k)
	-- 输出每一个值
	print(v)
end)

~~~

fn 参数指定的函数具有两个参数，没有返回值。原型如下：

~~~ lua

function map_function(value, key)

end

~~~

@param table t 表格
@param function fn 函数

]]
function table.walk(t, fn)
	for k,v in pairs(t) do
		fn(v, k)
	end
end

--[[--

对表格中每一个值执行一次指定的函数，如果该函数返回 false，则对应的值会从表格中删除

~~~ lua

local t = {name = "dualface", comp = "chukong"}
table.filter(t, function(v, k)
	return v ~= "dualface" -- 当值等于 dualface 时过滤掉该值
end)

-- 输出修改后的表格内容
for k, v in pairs(t) do
	print(k, v)
end

-- 输出
-- comp chukong

~~~

fn 参数指定的函数具有两个参数，并且返回一个 boolean 值。原型如下：

~~~ lua

function map_function(value, key)
	return true or false
end

~~~

@param table t 表格
@param function fn 函数

]]
function table.filter(t, fn)
	for k, v in pairs(t) do
		if not fn(v, k) then t[k] = nil end
	end
end

--[[--

遍历表格，确保其中的值唯一

~~~ lua

local t = {"a", "a", "b", "c"} -- 重复的 a 会被过滤掉
local n = table.unique(t)

for k, v in pairs(n) do
	print(v)
end

-- 输出
-- a
-- b
-- c

~~~

@param table t 表格

@return table 包含所有唯一值的新表格

]]
function table.unique(t)
	local check = {}
	local n = {}
	for k, v in pairs(t) do
		if not check[v] then
			n[k] = v
			check[v] = true
		end
	end
	return n
end

-- 使数组的值唯一且去掉nil
function table.iunique(t)
    local beginIndex = 1
    local endIndex = #t
	local check = {}
	local n = {}
	
	for i=beginIndex, endIndex do
	    local v = t[i]
		if v and not check[v] then
			n[#n + 1] = v
			check[v] = true
		end
	end
	return n
end

--@biref 随机返回一个item
--@author zfz
function table.random( t )
	if t == nil or table.nums(t) == 0 then
		return
	end
	local keyset = {}
	for k in pairs(t) do
	    table.insert(keyset, k)
	end
	return t[keyset[math.random(#keyset)]]
end

function table.randomKey( t )
	if t == nil or table.nums(t) == 0 then
		return
	end
	local keyset = {}
	for k in pairs(t) do
	    table.insert(keyset, k)
	end
	return keyset[math.random(#keyset)]
end

--洗牌
function table.shuffle( list )
	if list == nil or #list == 0 then 
		return list
	end

	local shuffledList = {}
	-- 复制区域列表
	for i, v in ipairs(list) do
		shuffledList[i] = v
	end
	local areasCount = #shuffledList

	for i = 1, areasCount do
		local randomIndex = math.random(i, areasCount)
		-- Swap
		local swapTemp = shuffledList[i]
		shuffledList[i] = shuffledList[randomIndex]
		shuffledList[randomIndex] = swapTemp
	end
	return shuffledList
end

--截取list
function table.sub( list, beginIndex, endIndex )
	if list == nil or #list == 0 then 
		return list
	end

	beginIndex = beginIndex or 1
	local len = #list
	endIndex = endIndex or len
	endIndex = math.min(endIndex, len)

	local retList = {}
	for i=beginIndex, endIndex do
		retList[#retList + 1] = list[i]
	end
	return retList
end

--@获取table里面有个value
function table.hasNums(t, value)
	if t == nil or table.nums(t) == 0 then
		return 0
	end
	local nums = 0
	for _, v in pairs(t) do
		if v == value then
			nums = nums + 1
		end
	end
	return nums
end

-- 寻找无序列表里的值，返回key
function table.findInDisorder(t, pred)
	if type(pred) == "function" then
		for k, v in pairs(t) do
			if pred(t[k]) then
				return k
			end
		end
	else
		for k, v in pairs(t) do
			if t[k] == pred then
				return k
			end
		end
	end
end

function table.containsKey(t, key)
	for k, v in pairs(t) do
		if k == key then
			return true
		end
	end
	return false
end

--寻找列表里的值，返回key
function table.ifind(t, pred, begin, endIndex)
	begin = begin or 1
	local len = #t
	endIndex = endIndex or len
	endIndex = math.min(endIndex, len)

	if type(pred) == "function" then
		for i = begin, endIndex do
			if pred(t[i]) then
				return i
			end
		end
	else
		for i = begin, endIndex do
			if t[i] == pred then
				return i
			end
		end
	end
end

-- 去掉满足条件的所有元素
function table.iremoveall(array, pred)
	local i = 1
	while array[i] do
		if pred(array[i]) then
			table.remove(array, i)
		else
			i = i + 1
		end
	end
end

-- 求差集   去掉 array1中 array2 的元素
function table.subtraction(array1, array2)
	if array1 == nil or array2 == nil then
		return array1
	end

	for i, v in ipairs(array2) do
		table.removebyvalue(array1, v, true)
	end	
end

-- 深复制table
function table.copy(object)
	local lookup_table = {}
	local function _copy(object)
		if type(object) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end
		local new_table = {}
		lookup_table[object] = new_table
		for index, value in pairs(object) do
			new_table[_copy(index)] = _copy(value)
		end
		return new_table
	end
	return _copy(object)
end

-- 浅复制table
function table.icopy(t)
	local ret = {}
	for k, v in pairs(t) do
		ret[k] = v
	end
	return ret
end

--... key的列表，其中有一个获取不到了则返回nil
function table.safeget(dict, ...)
	local len = select("#", ...)
	local v= dict
	for i= 1, len do
		local key = select(i, ...)
		v = v[key]
		if v == nil then
			-- printf("%s is nil", key)
			return nil
		end
	end
	return v
end

--... key的列表，其中有一个获取不到了则赋值一个{}继续添加，最后inert v 进去
function table.safeinsert(dict, v, ...)
	local len = select("#", ...)
	local parent = dict
	for i= 1, len do
		local key = select(i, ...)
		if not parent[key] then
			parent[key] = {}
		end
		parent = parent[key]
	end
	table.insert(parent, v)
end

--... key的列表，其中有一个获取不到了则赋值一个{}继续添加，最后用v覆盖上去
function table.safeset(dict, v, ...)
	local args = {...}
	local len = select("#", ...)
	local parent = dict
	for i= 1, len do
		local key = select(i, ...)
		if i==len then
			parent[key] = v
		else
			if not parent[key] then
				parent[key] = {}
			end
			parent = parent[key]
		end
	end
end

function table.reverse(t)
	local newTab = {}
	for i, v in ipairs(t) do
		-- table.insert(newTab, 1, v)
		newTab[#t + 1 - i] = t[i]
	end
	return newTab
end

function table.islist(t)
	local len = #t
	for i=1, len do
		if t[i] == nil then
			return false
		end
	end
	return true
end

function table.IsNilOrEmpty(t)
	return (t == nil) or (not next(t))
end

function table.swap(t, k1, k2)
	local temp = t[k1]
	t[k1] = t[k2]
	t[k2] = temp
end

function table.fromclist(clist)
    local ret  = {}
    for i = 0, clist.Count - 1 do
        ret[i + 1] = clist[i]
    end
    return ret
end

function table.fromcarray(array)
    local ret  = {}
    for i = 0, array.Length - 1 do
        ret[i + 1] = array[i]
    end
    return ret
end

function table.CompareNoOrder(a, b)
	if #a == #b then
		for index, value in pairs(a) do
			if not table.keyof(b, value) then
				return false
			end
		end
		return true
	end
	return false
end
function table.randomByWeight(weightTable)
	local max = 0
	local sacle = 10000
	local randomList = {}
	for k, weight in pairs(weightTable) do
		local range = math.floor(sacle*weight)
		local newMax = max+range
		table.insert(randomList, {max, newMax, k})
		max = newMax
	end
	local randomVal = math.random(1, max)
	-- print("randomByWeight", randomVal, randomList)
	for i, v in pairs(randomList) do
		local min, max, ret = v[1], v[2], v[3]
		if randomVal > min and randomVal <= max then
			return ret
		end
	end
end

function table.indexStrToNum(list, recursively)
    local ret  = {}
	for k, v in pairs(list) do
		local key = k
		local val = v
		if type(key) == "string" then
			key = tonumber(key) or key
		end
		if recursively and type(val) == "table" then
			val = table.indexStrToNum(val, recursively)
		end
		ret[key] = val
	end
    return ret
end

function table.indexNumToStr(list, recursively)
    local ret  = {}
	for k, v in pairs(list) do
		local key = k
		local val = v
		if type(key) == "number" then
			key = tostring(key) or key
		end
		if recursively and type(val) == "table" then
			val = table.indexStrToNum(val, recursively)
		end
		ret[key] = val
	end
    return ret
end

function table.copyAndToNum(object)
	local lookup_table = {}
	local function _copy(object)
		if type(object) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end
		local new_table = {}
		lookup_table[object] = new_table
		for index, value in pairs(object) do
			if condition then
				
			end
			new_table[_copy(index)] = _copy(value)
		end
		return new_table
	end
	return _copy(object)
end

local function less(a, b)
    return a - b
end

local function lowerbound(t, v, comp, l, r)
    comp = comp or less
    l = l or 1
    r = r or #t
    if l <= r then
        local m = math.floor((l + r) / 2)
        local c = comp(v, t[m])
        if c < 0 then
            return lowerbound(t, v, comp, l, m - 1)
        else
            return lowerbound(t, v, comp, m + 1, r)
        end
    else
        return math.min(l, r)
    end
end

table.lowerbound = lowerbound

local table_update_removekeys = {}
table.update = function(source, data, doRemoveKeys)
    for k, v in pairs(data) do
        local t = source[k]
        if type(t) == type(v) and type(t) == "table" then
            table.update(t, v, doRemoveKeys)
        else
            source[k] = v
        end
    end

    if doRemoveKeys then
        local len = 0
        for k in pairs(source) do
            if (not data[k]) then
                len = len + 1
                table_update_removekeys[len] = k
            end
        end

        for i = 1, len do
            source[table_update_removekeys[i]] = nil
            table_update_removekeys[i] = nil
        end
    end
end

function table.removeFirst(t)
	if #t >= 1 then
		return table.remove(t, 1)
	end
end

function table.removeByKey(t, key)
	t[key] = nil
end

function table.contains(t, value)
	for k, v in pairs(t) do
		if v == value then return true end
	end
	return false
end


--排序多个对象
--objDict obj必须是一个table or class or userdata，通过GetIDFunc函数可以返回唯一ID
--cmpValGetter 传入table中的一个对象 然后用这个对象生成CompareVal,注意CompareVal不能相等
--idGetter 传入table中的一个对象 然后返回唯一ID
--isReverse 默认值False
--		Flase, 按CompareVal降序排列
--		True, 按CompareVal升序排列
function table.sortobjs(objDict, cmpValGetter, idGetter, isReverse)
	local cmpList = {}
	local sortVals = {}
	local function cmpFunc(obj1, obj2)
		local id1 = idGetter(obj1)
		local id2 = idGetter(obj2)
		if isReverse then
			return sortVals[id1] < sortVals[id2]
		else
			return sortVals[id2] < sortVals[id1]
		end
	end
	for _, obj in pairs(objDict) do
		local val = cmpValGetter(obj)
		if val then
			sortVals[idGetter(obj)] = val
			table.insert(cmpList, obj)
		end
	end
	table.sort(cmpList, cmpFunc)
	return cmpList
end

function table.uniqueInsert(t, e, order)
	if(table.contains(t, e)) then
		return
	end
	order = order or table.getn(t)
	table.insert(t, order + 1, e)
end

--删除table所有元素
function table.clear(t)
    for k, _ in pairs(t) do
        t[k] = nil
    end
end

--在表寻找指定结果(arrayTable: 遍历表, item: 查询项, defaultItem: 缺省项)
function table.findItem(t, item, defaultItem)
	if not t then return -1 end
	local index = -1
	for i, v in ipairs(t) do
		if defaultItem and v == defaultItem then
			index = i
		end
		if item and v == item then
			index = i
			break
		end
	end
	return index
end
