--只写函数就行了。不要写其他了，所以也不要继承baseclass了
local UIShareInterface = {}

function UIShareInterface:RecordGameObject()
    self.gameObject = self.uiPrefab.gameObject
    self.transform = self.gameObject.transform
	self.gameObject.layer = LayerUtils.UI
end

function UIShareInterface:GetChild(name,monoBehaviour,gameObject)
    gameObject = gameObject or self.gameObject
    return TransformUtils.GetChild(gameObject, name, monoBehaviour)
end

function UIShareInterface:HasChild(name, gameObject)    
    gameObject = gameObject or self.gameObject
    return TransformUtils.HasChild(gameObject, name)
end

function UIShareInterface:BindEvent(evantName, func_name)
    if not self.eventMap then
        self.eventMap = {}
    end
    if not self.eventMap[evantName] then
        self.eventMap[evantName] = LMessage:Register(evantName, func_name, self)
    end    
end

function UIShareInterface:UnBindAllEvent()
    if self.eventMap then
        for evantName, event_id in pairs(self.eventMap) do
            self.eventMap[evantName] = LMessage:UnRegister(evantName, event_id)
        end
    end
end

function UIShareInterface:UnBindEvent(evantName)
    if self.eventMap then
        local event_id = self.eventMap[evantName]
        self.eventMap[evantName] = LMessage:UnRegister(evantName, event_id)
    end
end

--==============================--
--addby:yjp
--desc:添加点击事件
--@gameObject 传入需要绑定的节点
--@func: 回调参数 最好不要直接绑定对象方，可以使用callback方法包一下，这样可以在运行Unity的时候更改了方法直接进行热重载，如果直接绑定的话热重载不了
--@uiSound_id: 音效路径
--@return:
--time:2022-05-09 14:57:57
--==============================--
function UIShareInterface:AddOnClick(gameObject, func, uiSound_id)
    if not gameObject then
        printerror("AddOnClick gameObject is Nil")
        return
    end

    if not func then
        printerror("AddOnClick func is Nil")
        return
    end
    uiSound_id = uiSound_id or "Sound/Effect/Button/Button_Normal"
    local btn = gameObject.gameObject:GetComponent("Button")
    if btn then
        local UI_Event_Handler = function(...)
            Globals.soundMgr:PlayEffect(uiSound_id)
            func(...)
        end
        btn.onClick:AddListener(UI_Event_Handler)
        return btn
    end
    local luaTrigger = gameObject.gameObject:GetComponent("LuaEventTrigger")
    if(not luaTrigger) then
        printerror("AddOnClick gameObject has no Button or LuaEventTrigger")
        return
    end
    local UI_Event_Handler = function(luaTrigger, param)
        Globals.soundMgr:PlayEffect(uiSound_id)
        if(param ~= "PointerClick") then
            return
        end
        func(gameObject)
    end
    -- luaTrigger:SetLuaChunk(self)
    luaTrigger:SetLuaCbFunc(UI_Event_Handler)
	return luaTrigger
end

--移除点击事件
function UIShareInterface:RemoveOnClick(gameObject)
    if gameObject == nil then
        printerror("AddOnClick gameObject is Nil")
        return
    end
    local btn = gameObject.gameObject:GetComponent("Button")
    if btn then
        btn.onClick:RemoveAllListeners()
    end
    local luaTrigger = gameObject.gameObject:GetComponent("LuaEventTrigger")
    if(not luaTrigger) then
        return
    end
    -- luaTrigger:SetLuaChunk(self)
    luaTrigger:SetLuaCbFunc(nil)
end

function UIShareInterface:AddUIEvent(gameObject, func)
    if not gameObject then
        printerror("AddOnClick gameObject is Nil")
        return
    end

    if not func then
        printerror("AddOnClick func is Nil")
        return
    end
    local luaTrigger = gameObject.gameObject:GetComponent("LuaEventTrigger")
    if(not luaTrigger) then
        printerror("AddOnClick gameObject has no LuaEventTrigger")
        return
    end
    -- luaTrigger:SetLuaChunk(obj)
    luaTrigger:SetLuaCbFunc(func)
end

function UIShareInterface:RemoveUIEvent(gameObject)
    if not gameObject then
        printerror("AddOnClick gameObject is Nil")
        return
    end
    local luaTrigger = gameObject.gameObject:GetComponent("LuaEventTrigger")
    if(not luaTrigger) then
        printerror("AddOnClick gameObject has no LuaEventTrigger")
        return
    end
    luaTrigger:SetLuaChunk(nil)
    luaTrigger:SetLuaCbFunc(nil)
end

----image相关---------
--统一通过这个管理加载的图片，做好公用和释放，先用Resources.Load撑住
function UIShareInterface:LoadImage(url, image, setNativeSize)
    Globals.resMgr:LoadImage(url, image, setNativeSize)
end

---setNativeSize 0 / 1
function UIShareInterface:LoadSprite(image, Atlas, imageName,setNativeSize)
    Globals.resMgr:LoadSprite(image, Atlas, imageName, setNativeSize)
end

return UIShareInterface
----------------