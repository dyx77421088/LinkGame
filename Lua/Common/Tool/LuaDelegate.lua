--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:有序的lua委托，按照添加顺序来执行
--     创建时间:2022/05/07 
--------------------------------------------------------------------------------

local lua_delegate = {}

function  lua_delegate.add(a, b)  
    if(table.contains(a, b)) then
        printerror("重复添加委托")  
        return
    end
    table.insert(a, b)
    return a
end

function  lua_delegate.tostring(set)
    local l = {}
    for i, e in pairs(set) do
        l[#l + 1] = tostring(e)
    end
    return  "{" .. table.concat(l, ", ") .. "}"
end

function  lua_delegate.sub (a, b)
    if(table.removebyvalue(a, b) <= 0) then
        printerror("试图移除不存在的委托")
    end
    return a
end

function lua_delegate.fire(funcTable, ...)
    for i, func in ipairs(funcTable) do
        func(...)
    end
end

local __cb_metat_able = {
    __add = lua_delegate.add,
    __sub = lua_delegate.sub,
    __call = function(t,...)
        return lua_delegate.fire(t, ...)
    end
    ,
    __tostring = lua_delegate.tostring
}

function  lua_delegate.New(func)
    local set = {}
    if func ~= nil then
        table.insert(set, func)
    end
    setmetatable(set, __cb_metat_able)
    return set    
end


return lua_delegate


--测试代码
-- local function testC(id)
--     print("testc" .. id)
-- end

-- local function testD(id)
--     print("testd" .. id)
-- end

-- s1 = lua_delegate.New ()
-- -- s2 = lua_delegate.New ()

-- print("start")
-- s1 = s1 + testC
-- print("start2")
-- s1 = s1 - testD
-- print("start2")
-- -- print(s1)
-- -- for v in pairs(s1) do
-- --     print(v)
-- -- end
-- -- print("start3")
-- s1(1)