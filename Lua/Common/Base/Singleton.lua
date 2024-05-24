function Singleton(className, ...)
	local obj = BaseClass(className, ...)
	local _instance = nil
	obj.getInstance = function()
		if _instance == nil then
			_instance = obj.New()
		end
		return _instance
	end
	return obj
end