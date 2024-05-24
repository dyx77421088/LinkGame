--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:用来定义一个类
--     创建时间:2022/04/23  
--------------------------------------------------------------------------------
local setmetatable = setmetatable
--对继承关系中从父类到子类的__ctor方法进行处理，如果在子类中已经执行了父类的__ctor方法，那么父类就不再执行__ctor方法
--子类尽量不要重复调用父类的__ctor和__delete方法吧，已经自动帮你调用了
local preCreateProcess
preCreateProcess = function(c)
    if c.super then
        for i, supterItem in ipairs(c.super) do
            preCreateProcess(supterItem)
        end
    end
    if c.__ctor then
        if(type(c.__ctor) == "function") then
            local __ctor = c.__ctor
            c.__ctor = {}
            c.hasInit = false
            --妈的防止多重继承的时候如果继承的A和B如果有共同的祖先的话就会被重复执行
            setmetatable(c.__ctor, {
                __call = function(t, ...)
                    if c.hasInit then
                        return
                    end
                    __ctor(...)
                    print("Create Object:", c.clsname)
                    c.hasInit = true
                end
            })
        else
            c.hasInit = false
        end
    end
end

local preDeleteProcess
preDeleteProcess = function(c)
    if c.super then
        for i, supterItem in ipairs(c.super) do
            preDeleteProcess(supterItem)
        end
    end

    if c.__delete then
        if(type(c.__delete) == "function") then
            local __delete = c.__delete
            c.__delete = {}
            c.hasDelete = false
            --妈的防止多重继承的时候如果继承的A和B如果有共同的祖先的话就会被重复执行
            setmetatable(c.__delete, {
                __call = function(t, ...)
                    if c.hasDelete then
                        return
                    end
                    __delete(...)
                    print("Delete Object:", c.clsname)
                    c.hasDelete = true
                end
            })
        else
            c.hasDelete = false
        end
    end
end

local create
create = function(c, self, ...)
    if c.super then
        for i, supterItem in ipairs(c.super) do
            create(supterItem, self, ...)
        end
    end
    if c.__ctor and not c.hasInit then
        c.__ctor(self, ...)
    end
end

local deleteMe = function(self)
    if self._use_delete_method then
        return
    end
    --销毁以前预先处理一下所有基类的析构函数，把标记置为false，都是没有调用过析构
    preDeleteProcess(self.clstype)

    local delete 
    delete = function(cls, self)
        if(cls.__delete and not cls.hasDelete) then
            cls.__delete(self)
        end
        if(cls.super) then
            for i, superItem in ipairs(cls.super) do
                delete(superItem, self)
            end
        end
    end
    delete(self.clstype, self)
    self._use_delete_method = true
end

__creteDefaultFunc = function(str)
    local tempStr = "return {" .. str .. "}"
    return assert(loadstring(tempStr))
end

function walkclass(cls, cb)
	local _allkeys = {}
	local function walkcb(k, v) 
		if _allkeys[k] == nil then
			_allkeys[k] = v
			cb(k, v) 
		end
	end
	cls.walk(walkcb)
end

function walkclass_method(cls, cb)
	local function walkcb(k, v) 
		if type(k) == "string" and type(v) == "function" then
			cb(k, v) 
		end
	end
	walkclass(cls, walkcb)
end

function walkclass_obj_by_clsname(cls, cb, clsname)
	local function walkcb(k, v) 
		if type(k) == "string" and type(v) == "table" and v.clsname == clsname then
			cb(k, v) 
		end
	end
	walkclass(cls, walkcb)
end

function combine_class(clsname, ...)
	local cls = BaseClass(clsname, ...)
	local args = {...}
	cls.New = function(...)
		local self = setmetatable({clstype=cls}, {__index=cls})
		for _, v in ipairs(args) do
			if v and v.__ctor then
				v.__ctor(self, ...)
			end
		end
		return self
	end
	return cls
end

local MetaKey = 
{
	["clsname"] = true,
	["super"] = true,
	["__ctor"] = true,
	["__delete"] = true,
	["Dispose"] = true,
	["hasInit"] = true,
}
function BaseClass(clsname, ...)
    local super = {...}
    -- 生成一个类类型
    local class_type = {
        ["clsname"] = clsname,
        ["super"] = false,
        ["__ctor"] = false,
        ["__delete"] = false,
        ["Dispose"] = deleteMe,
    }

    class_type.New = function(...)
        -- 生成一个类对象
        local obj
        if class_type.__defaultVar then
            obj = class_type.__defaultVar()
            obj.clstype = class_type
        else
            obj = {
                ["clstype"] = class_type,
            }
        end
        setmetatable(obj, {__index = class_type})
        --Create之前先预处理一下，把所有基类构造标记都置为false,表示所有基类都还没构造过
        preCreateProcess(class_type)
        -- 调用初始化方法
        create(class_type, obj, ...)

        return obj
    end
    if #super > 0 then
        class_type.super = super
        setmetatable(class_type, {
            __index = 
            function(_, k)
                if(MetaKey[k]) then
                    return rawget(_, k)
                end
				for i, v in ipairs(super) do
					local ret = v[k]
					if ret ~= nil then
						return ret
					end
				end
			end,
        } )
    end
    class_type.walk = function(cb)
		for k, v in pairs(class_type) do
			cb(k, v)
		end
        if(#super <= 0) then
            return
        end
        for i, basecls in ipairs(super) do
            if basecls.clsname ~= nil then
                basecls.walk(cb)
            else
                for k, v in pairs(basecls) do
                    cb(k, v)
                end
            end
        end
	end
    --preProcess(class_type)
    return class_type
end