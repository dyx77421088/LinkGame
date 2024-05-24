--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:事件派发对象，专门用来存储事件方法，进行事件触发时候的派发
--     创建时间:2022/05/10 
--------------------------------------------------------------------------------
local EventDispatcher = BaseClass("EventDispatcher")

function EventDispatcher:__ctor()
	self.event_list = {}
	self.bind_id_dic = {}
	self.bind_id = 0
	self.lock = false
	if _IsEditor then
		self.check_dic = {}
	end
end

function EventDispatcher:__delete()
	--self.timer_quest_manager:Stop()
	self.event_list = false
	self.bind_id_dic = false
	self.bind_id = 0
	self.lock = false
end

function EventDispatcher:CheckSameFunc(event_id, func_name, obj, bind_id)
	local temp = self.check_dic[event_id]
	if temp == nil then
		temp = {}
		self.check_dic[event_id] = temp
	end
    local event_func = nil
	if(type(func_name) == "string") then
		event_func = obj[func_name]
	else
		event_func = func_name
	end
	local key = tostring(event_func) .. tostring(obj)
	local id = temp[key]
	if id then
		if self.bind_id_dic[id] then
			return true
		end
	end
	temp[key] = bind_id
	temp[bind_id] = key
	return false
end

function EventDispatcher:RemoveCheck(event_id, bind_id)
	local temp = self.check_dic[event_id]
	if temp == nil then
		return
	end
	local key = temp[bind_id]
	if key ~= nil then
		temp[key] = nil
	end
	temp[bind_id] = nil
end

--==============================--
--addby:yjp
--desc:注册事件
--@event_id:绑定的事件名称
--@func_name: 绑定的方法名或者传入方法也行，尽量传入名称吧，传方法会绑死方法不利于lua热重载
--@return:
--time:2022-05-10 16:05:29
--==============================--
function EventDispatcher:Register(event_id, func_name, obj)
	if type(event_id) ~= "string" then
		printerror("Try to Bind which event_id is not string", event_id)
		return false
	end
	if(not func_name) then
		printerror("Try to Bind nil function")
		return
	end
    if(type(func_name) == "string" and not obj[func_name]) then
        printerror("obj has not function", obj, func_name)
        return false
    end

	if self.check_dic then
		if self:CheckSameFunc(event_id, func_name, obj, self.bind_id + 1) then
			printerror("Try to bind the same event_func and obj again")
			return
		end
	end
	local tmp_func = nil
	if(type(func_name) == "string") then
		tmp_func = callback(obj, func_name)
	elseif(obj) then
		tmp_func = function(...)
			func_name(obj, ...)
		end
	else
		tmp_func = func_name
	end

	local tmp_event = self.event_list[event_id]
	if tmp_event == nil then
		tmp_event = {size = 0, pool = {}}
		self.event_list[event_id] = tmp_event
	end

	local u_id = nil
	if not self.lock and #tmp_event.pool > 0 then
		u_id = table.remove(tmp_event.pool)
	else
		tmp_event.size = tmp_event.size + 1
		u_id = tmp_event.size
	end
	tmp_event[u_id] = tmp_func
	self.bind_id = self.bind_id + 1
	self.bind_id_dic[self.bind_id] = u_id
	return self.bind_id
end

--return false是为了外面可以重置bind_id ，例如 self.GameLoopEvent_id = EventDispatcher:UnBind(event_id, self.GameLoopEvent_id)
function EventDispatcher:UnRegister(event_id, bind_id)
	if type(event_id) ~= "string" then
		printerror("Try to UnBind which event_id is not string", event_id)
		return false
	end
    if(not bind_id) then
        return
    end
	if type(bind_id) ~= "number" then
		printerror("Try to UnBind which bind_id is not number", bind_id)
		return false
	end
	local u_id = self.bind_id_dic[bind_id]
	if u_id == nil then
		return false
	end
	local tmp_event = self.event_list[event_id]
	if tmp_event == nil then
		return false
	end
	if not tmp_event[u_id] then
		return false
	end
	if self.check_dic  then
		self:RemoveCheck(event_id, bind_id)
	end
	tmp_event[u_id] = false
	self.bind_id_dic[bind_id] = nil
	table.insert(tmp_event.pool, u_id)
	return false
end

function EventDispatcher:UnAllRegister(event_id)
	if not event_id then
		return
	end
    local tmp_event = self.event_list[event_id]
	if tmp_event == nil then
		return
	end
    self.event_list[event_id] = nil
    if(self.check_dic and self.check_dic[event_id]) then
        for key, bind_id in ipairs(self.check_dic[event_id]) do
            if(self.bind_id_dic[key]) then
                self.bind_id_dic[key] = nil
            end
        end
        self.check_dic[event_id] = nil
    end
end

function EventDispatcher:Dispatch(event_id, ...)
	local tmp_event = self.event_list[event_id]
	if tmp_event == nil then
		return
	end
	self.lock = true --lock之后值会往数组最后添加，所以当帧内新增跟删除的事件不会被执行
	local len = tmp_event.size
	local func = nil
	for i = 1, len do
		func = tmp_event[i]
		if func then
			func(...)
		end
	end
	self.lock = false
end

function EventDispatcher:HasEvent(bind_id)
	-- body
	return self.bind_id_dic[bind_id] ~= nil
end

function EventDispatcher:Clear()
	self.event_list = {}
	self.bind_id_dic = {}
	self.bind_id = 0
	self.lock = false
	if self.check_dic then
		self.check_dic = {}
	end
end


return EventDispatcher