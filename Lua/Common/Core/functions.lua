local weakid = 0
local weakObjs = setmetatable({}, {__mode="kv"})
local Debug = UnityEngine.Debug
local callback_newargs = {}
local function make_callback(id, getobjfunc, funcname, ...)
    getobjfunc = getobjfunc or getrefobj
	local args = { ... }
    local len1 = select("#", ...)

	return function(...)
		local real = getobjfunc(id)
		if not real then
			return false
		end
		for i = 1, len1 do
			callback_newargs[i] = args[i]
		end
		local len2 = select("#", ...)
		for i = 1, len2 do
			local t = select(i, ...)
			callback_newargs[len1 + i] = t
		end
		return real[funcname](real, table.unpack(callback_newargs, 1, len1 + len2))
	end
end

--用闭包实现回调, 最后的回调参数是(闭包参数+传入参数) 
--1.保存调用的函数名，方便热更。
--2.给全局的类注册回调，因为是弱引用luaobj，不会造成释放不了
--3.luaobj有transform变量，则用transform来判断C#对象是否存在，销毁的对象不会回调
--4.#{...}和select("#", ...)得到的数量不一样, 前者不会把结尾的nil参数算进去, 而select返回的是调用时所有明确传入的参数数量(即使是结尾nil)
function callback(luaobj, funcname, ...)
    assert(luaobj[funcname], "callback error! not define funcname: " .. funcname)
    return make_callback(weakref(luaobj), getrefobj, funcname, ...)
end

local function getviewobj(id)
    local obj = getrefobj(id)
    if obj then
        if (nil == obj.isDestroyed) or obj.isDestroyed then
            obj = nil
        end
    end
    return obj
end

-- 和callback逻辑一致, 但是viewObj必须是一个继承自ViewBase的table
-- 只有view没有destroy的情况下才会调用其callback
function viewcallback(viewobj, funcname, ...)
	assert(viewobj[funcname], "callback error! not define funcname: " .. funcname)
    return make_callback(weakref(viewobj), getviewobj, funcname, ...)
end

--回调是先回检查lua对象obj是否存在
function validcall(obj, f)
	local weakid = weakref(obj)
	return function(...)
		local real = getrefobj(weakid)
		if real then
			return f(real, ...)
		end
	end
end


--弱引用对象，返回弱应用id
function weakref(obj)
	local id = weakid
	weakObjs[id] = obj
	weakid = weakid + 1
	return id
end

--由弱引用id获取弱引用对象
function getrefobj(id)
	if id then
		local o = weakObjs[id]
		if o then
			if type(o) == "table" and o.transform and ObjectUtils.IsNil(o.transform) then
				weakObjs[id] = nil
			else
				return o
			end
		else
			weakObjs[id] = nil
		end
	end
end

function CSharpGC()
	Util.Gc(0, 0)
	--UnityEngine.Resources.UnloadUnusedAssets()
	Util.Gc(1, 0)
end

function LuaGC()
    local c = collectgarbage("count")
    print("Begin gc count = ", c)
    collectgarbage("collect")
    c = collectgarbage("count")
    print("End gc count = ", c)
end

--封装upack 兼容旧版本的Lua代码
-- function unpack(...)
-- 	return table.unpack(...)
-- end

function printf(fmt, ...)
	print(string.format(tostring(fmt), ...))
end

function printerrorf(fmt, ...)
	printerror((string.format(tostring(fmt), ...)))
end

function get_debug_str_simple(...)
	local args = {}
	local len = select("#", ...)
	for i=1, len do
		local v = select(i, ...)
		if type(v) == "table" then
			table.insert(args, table.tostring(v, 99,tostring(v)))
		else
			table.insert(args, tostring(v))
		end
		
	end
	return table.concat(args, " ")
end

function get_debug_str(...)
	return get_debug_str_simple(...).."\n"..debug.traceback()
end

function printext(...)
	print(get_debug_str(...))
end

function printerror(...)
	local err = get_debug_str(...)
	if(ComUtils.Is_Dev()) then
		Debug.LogError(err)
	else
		LogManager.Log(err, 3)
	end
end

function printwarning(...)
	local err = get_debug_str(...)
	if(ComUtils.Is_Dev()) then
		Debug.LogWarning(err)
	else
		LogManager.Log(err, 2)
	end
end

-- TODO: 有bug, 手机上index取出是nil
function printfunc(...)
    if ComUtils.GetOpenLog() then
        local args = { ... }
        local ok, err = pcall(function()
            local dinfo = debug.getinfo(4)
            local _, index = string.find(dinfo.source, ".*/")
            local moduleName = string.sub(dinfo.source, index + 1)
            local funcname = (dinfo.name and dinfo.name ~= "?") and dinfo.name or string.match(debug.traceback("", 4), "([A-Za-z_]+[A-Za-z0-9]*)'")
            local content = string.format("%s.%s@line:%d", moduleName, funcname, dinfo.currentline)
            if args[1] then
                content = content .. " => " .. tostring(args[1])
            end
            print(content, select(2, table.unpack(args)))
        end)

        if (not ok) then
            printerror(err)
        end
    end
end

--xpcall封装, 会打印报错时的堆栈调用
function xpcallex(f, ...)
    if ComUtils.Is_Dev() then
        local args = {...}
        local len = select("#", ...)
        return xpcall(function()
            return f(table.unpack(args, 1, len)) end,
            printerror)
    else
        return xpcall(f, printerror, ...)
    end
end

function safefunc(f)
	return function(...)
		return xpcallex(f, ...)
	end
end

--深度比较两个对象
function equal(t1, t2)
    if t1 == t2 then
        return true
    end
    if type(t1) == "table" and type(t2) == "table" then
        if t1.transform and t2.transform then
            return t1.transform:GetInstanceID() == t2.transform:GetInstanceID()
        end
        if table.nums(t1) ~= table.nums(t2) then
            return false
        end
        for k, v in pairs(t1) do
            if not equal(v, t2[k]) then
                return false
            end
        end
        return true
    end
    return false
end

--如果第三方插件函数有问题，可以热更luawrapobj处理
function luawrapobj(uObj)
	local wrapobj= {}
	setmetatable(wrapobj, {__index = function(t, k)
		local var = rawget(t, k)
		if var then
			return var
		end
		return uObj[k]
	end})
	return wrapobj
end


--给LuaBehaviour用
function NewMonoLuaObj(monoName, gameObject)
	local newObj = {gameObject = gameObject}
	local cls = rawget(_G, monoName)
	if(cls == nil) then
		cls = rawget(Globals.classes, monoName)
	end
    if cls == nil then
        printerror(monoName.."为空")
    end
	setmetatable(newObj, {__index = cls})
	return newObj
end



--[[--

检查并尝试转换为数值，如果无法转换则返回 0

@param mixed value 要检查的值
@param [integer base] 进制，默认为十进制

@return number

]]
function checknumber(value, base)
	return tonumber(value, base) or 0
end

--[[--

检查并尝试转换为整数，如果无法转换则返回 0

@param mixed value 要检查的值

@return integer

]]
function checkint(value)
	return math.round(checknumber(value))
end

--[[--

检查并尝试转换为布尔值，除了 nil 和 false，其他任何值都会返回 true

@param mixed value 要检查的值

@return boolean

]]
function checkbool(value)
	return (value ~= nil and value ~= false)
end

--[[--

检查值是否是一个表格，如果不是则返回一个空表格

@param mixed value 要检查的值

@return table

]]
function checktable(value)
	if type(value) ~= "table" then value = {} end
	return value
end

--[[--

如果表格中指定 key 的值为 nil，或者输入值不是表格，返回 false，否则返回 true

@param table hashtable 要检查的表格
@param mixed key 要检查的键名

@return boolean

]]
function isset(hashtable, key)
	local t = type(hashtable)
	return (t == "table" or t == "userdata") and hashtable[key] ~= nil
end

--[[--

深度克隆一个值

~~~ lua

-- 下面的代码，t2 是 t1 的引用，修改 t2 的属性时，t1 的内容也会发生变化
local t1 = {a = 1, b = 2}
local t2 = t1
t2.b = 3    -- t1 = {a = 1, b = 3} <-- t1.b 发生变化

-- clone() 返回 t1 的副本，修改 t2 不会影响 t1
local t1 = {a = 1, b = 2}
local t2 = clone(t1)
t2.b = 3    -- t1 = {a = 1, b = 2} <-- t1.b 不受影响

~~~

@param mixed object 要克隆的值

@return mixed

]]
function clone(object)
	local lookup_table = {}
	local function _copy(object)
		if type(object) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end
		local new_table = {}
		lookup_table[object] = new_table
		for key, value in pairs(object) do
			new_table[_copy(key)] = _copy(value)
		end
		return setmetatable(new_table, getmetatable(object))
	end
	return _copy(object)
end



--[[--

如果对象是指定类或其子类的实例，返回 true，否则返回 false

~~~ lua

local Animal = BaseClass("Animal")
local Duck = BaseClass("Duck", Animal)

print(iskindof(Duck.New(), "Animal")) -- 输出 true

~~~

@param mixed obj 要检查的对象
@param string classname 类名

@return boolean

]]
function iskindof(obj, classname)
	local t = type(obj)
	local mt
	if t == "table" then
		mt = getmetatable(obj)
	elseif t == "userdata" then
		mt = tolua.getpeer(obj)
	end

	while mt do
		if mt.__cname == classname then
			return true
		end
		mt = mt.super
	end

	return false
end

--[[--

载入一个模块

import() 与 require() 功能相同，但具有一定程度的自动化特性。

假设我们有如下的目录结构：

~~~

app/
app/classes/
app/classes/MyClass.lua
app/classes/MyClassBase.lua
app/classes/data/Data1.lua
app/classes/data/Data2.lua

~~~

MyClass 中需要载入 MyClassBase 和 MyClassData。如果用 require()，MyClass 内的代码如下：

~~~ lua

local MyClassBase = require("app.classes.MyClassBase")
local MyClass = BaseClass("MyClass", MyClassBase)

local Data1 = require("app.classes.data.Data1")
local Data2 = require("app.classes.data.Data2")

~~~

假如我们将 MyClass 及其相关文件换一个目录存放，那么就必须修改 MyClass 中的 require() 命令，否则将找不到模块文件。

而使用 import()，我们只需要如下写：

~~~ lua

local MyClassBase = import(".MyClassBase")
local MyClass = BaseClass("MyClass", MyClassBase)

local Data1 = import(".data.Data1")
local Data2 = import(".data.Data2")

~~~

当在模块名前面有一个"." 时，import() 会从当前模块所在目录中查找其他模块。因此 MyClass 及其相关文件不管存放到什么目录里，我们都不再需要修改 MyClass 中的 import() 命令。这在开发一些重复使用的功能组件时，会非常方便。

我们可以在模块名前添加多个"." ，这样 import() 会从更上层的目录开始查找模块。

~

不过 import() 只有在模块级别调用（也就是没有将 import() 写在任何函数中）时，才能够自动得到当前模块名。如果需要在函数中调用 import()，那么就需要指定当前模块名：

~~~ lua

# MyClass.lua

# 这里的 ... 是隐藏参数，包含了当前模块的名字，所以最好将这行代码写在模块的第一行
local CURRENT_MODULE_NAME = ...

local function testLoad()
	local MyClassBase = import(".MyClassBase", CURRENT_MODULE_NAME)
	# 更多代码
end

~~~

@param string moduleName 要载入的模块的名字
@param [string currentModuleName] 当前模块名

@return module

]]
function import(moduleName, currentModuleName)
	local currentModuleNameParts
	local moduleFullName = moduleName
	local offset = 1

	while true do
		if string.byte(moduleName, offset) ~= 46 then -- .
			moduleFullName = string.sub(moduleName, offset)
			if currentModuleNameParts and #currentModuleNameParts > 0 then
				moduleFullName = table.concat(currentModuleNameParts, ".") .. "." .. moduleFullName
			end
			break
		end
		offset = offset + 1

		if not currentModuleNameParts then
			if not currentModuleName then
				local n,v = debug.getlocal(3, 1)
				currentModuleName = v
			end

			currentModuleNameParts = string.split(currentModuleName, ".")
		end
		table.remove(currentModuleNameParts, #currentModuleNameParts)
	end

	return require(moduleFullName)
end


local isDump = DEBUG_DUMP
function dump(value, desciption, nesting)
	if not isDump then 
		return
	end
	nesting = nesting or 3
	if type(nesting) ~= "number" then nesting = 3 end

	local lookupTable = {}
	local result = {}

	local function _v(v)
		if type(v) == "string" then
			v = "\"" .. v .. "\""
		end
		return tostring(v)
	end

	local traceback = string.split(debug.traceback("", 2), "\n")
	print("dump from: " .. string.trim(traceback[3]))

	local function _dump(value, desciption, indent, nest, keylen)
		desciption = desciption or "<var>"
		local spc = ""
		if type(keylen) == "number" then
			spc = string.rep(" ", keylen - string.len(_v(desciption)))
		end
		if type(value) ~= "table" then
			result[#result +1 ] = string.format("%s%s%s = %s", indent, _v(desciption), spc, _v(value))
		elseif lookupTable[value] then
			result[#result +1 ] = string.format("%s%s%s = *REF*", indent, desciption, spc)
		else
			lookupTable[value] = true
			if nest > nesting then
				result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, desciption)
			else
				result[#result +1 ] = string.format("%s%s = {", indent, _v(desciption))
				local indent2 = indent.."    "
				local keys = {}
				local keylen = 0
				local values = {}
				for k, v in pairs(value) do
					keys[#keys + 1] = k
					local vk = _v(k)
					local vkl = string.len(vk)
					if vkl > keylen then keylen = vkl end
					values[k] = v
				end
				table.sort(keys, function(a, b)
					if type(a) == "number" and type(b) == "number" then
						return a < b
					else
						return tostring(a) < tostring(b)
					end
				end)
				for i, k in ipairs(keys) do
					_dump(values[k], k, indent2, nest + 1, keylen)
				end
				result[#result +1] = string.format("%s}", indent)
			end
		end
	end
	_dump(value, desciption, "- ", 1)

	for i, line in ipairs(result) do
		print(line)
	end
end


function require_and_import(moduleName, ...)
	local md = require(moduleName)
	local len = select("#", ...)
	local ret = {}
	for i = 1, len do
		table.insert(ret, md[select(i, ...)])
	end
	return table.unpack(ret)
end

function reload_module(module_name)
	disable_global(false)
	local old_module = package.loaded[module_name]

	if old_module == nil then
		return false
	end

	ComUtils.clsCache = {}

	package.loaded[module_name] = nil
	require (module_name)

	local new_module = package.loaded[module_name]
	for k, v in pairs(new_module) do
		old_module[k] = v
	end

	package.loaded[module_name] = old_module
	-- package.loaded[module_name] = nil
	local view = Globals.uiMgr:GetView("GMView")
	disable_global(true)
	return true
end

function UnloadLuaFile(_package)
    package.loaded[_package]=nil
end

function require_once(path)
    local ret = require(path)
    UnloadLuaFile(path)
    return ret
end

function show_all_loaded()
	local loaded = {}
	for k,v in pairs(package.loaded) do
		local str = tostring(k) .. " -> " .. tostring(v)
		table.insert(loaded, str)
	end

	local s = table.concat(loaded, "\n", 1, #loaded)
	print(s)
end

function lamda(func, obj)
	local zfunc = function(...)
		func(obj,...)
	end
	return zfunc
end

function if_else(a, b, c)
	if(a) then
		return b
	else
		return c
	end
end

function try(block)
    local try = block[1]
    assert(try)

    local catch=block[2]
    local finally=catch and block[3]

	--traceback 可以自定义格式
    local results = table.pack(xpcall(try, debug.traceback))
    local ok = results[1]
    if not ok then
        if catch then
            catch(results[2])
        end
    end

    if finally then
        finally()
    end
end
function catch(block)
    return block[1]
end
function finally(block)
    return block[1]
end