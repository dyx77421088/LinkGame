function disable_global(isDisable)
    __STRICT = isDisable
end

local Globals = {}
Globals.classes = {}--定义一下全局一些类放在这里，方便LuaBehaviour调用
function Globals.InitMgrs(define)
	for k,v in pairs(define) do
		local cls = require(v)
        if(cls.getInstance) then
            rawset(Globals, k, cls.getInstance())
        elseif(cls.New) then
            rawset(Globals, k, cls.New())
        else
            rawset(Globals, k, cls)
        end
	end
	for k,v in pairs(define) do
		local c = Globals[k]
		if c.Initialize then
			c:Initialize()
		end
	end
end

function Globals.DisposeMgrs(define)
    for k, v in pairs(define) do
        local mgr = rawget(Globals)
        if(mgr) then
            mgr:Dispose()
        end
        Globals[k] = nil
    end
end

return Globals