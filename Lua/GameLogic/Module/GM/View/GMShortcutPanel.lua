--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:GM快捷键功能
--     创建时间:20234/01/31  
--------------------------------------------------------------------------------
local GMShortcutPanel = BaseClass("GMShortcutPanel", UIItem)
local ClassData = Globals.configMgr:GetConfig("ClassData")
local GMFunc = require (ClassData.GMFunc)


function GMShortcutPanel:__ctor(parent, path, baseView)
    self:InitItem(parent, path, baseView)
end

function GMShortcutPanel:Initialize()
	local buttons = self:GetButtons()
	local OnInstantiate = function(index, gameObject)
		local transform = gameObject.transform
		local rectTransform = gameObject:GetComponent(ClassType.RectTransform)
		local direction = self:GetButtonDir()
		transform.localPosition = Vector3.Scale(CastUtils.V2toV3(rectTransform.sizeDelta) * index, direction)
		local text = transform:GetChild(0):GetComponent(ClassType.Text)
		local item = {gameObject = gameObject, transform = transform, text = text}
		
		return item
	end
	local OnSetData = function(index, item)
		local buttonData = buttons[index]
		local param = {}
		for i = 3, #buttonData do
			table.insert(param, buttonData[i])
		end
		item.text.text = buttonData[1]
		item.funcName = buttonData[2]
		item.param = param
		self:AddOnClick(item.gameObject, callback(self, "OnClickBtn", item))
	end
	
	
	self.items = {}
    ComUtils.SimpleReuse(self.items, self:GetChild("0").gameObject, #buttons, OnInstantiate, OnSetData)
end

--快捷键菜单
function GMShortcutPanel:GetButtons()
	return {
		{"倍速", "SetRunSpeed"},
		{"AUDIO", "SetDebugModel", 2},
		{"RANDOM", "SetDebugModel", 0},
		{"LOSE", "SetDebugModel", 1, 0},
		{"WIN", "SetDebugModel", 1, 1},
		{"FREE GAME", "SetDebugModel", 1, 2},
		{"BONUS GAME", "SetDebugModel", 1, 3},
		{"LINK GAME", "SetDebugModel", 1, 4},
	}
end

--生成菜单方向
function GMShortcutPanel:GetButtonDir()
	return Vector3.up
end

function GMShortcutPanel:OnClickBtn(item)
	local funcName = item.funcName
	local param = item.param
	if not GMFunc[funcName] then
		printerror("功能方法还未定义")
        return
	else
		GMFunc[funcName](table.unpack(param))
	end
	local func_text_name = funcName .. "_Text"
    if GMFunc[func_text_name] then
        item.text.text = GMFunc[func_text_name]() or ""
	else
		for _, v in pairs(self.items) do
			if v == item then
				v.text.color = Color.green
			else
				v.text.color = Color.white
			end
		end
    end
end

function GMShortcutPanel:ShowSelf()
    LMessage:Dispatch(LuaEvent.SmallGame.IncreaseCover, "GMShortcutPanel")
	self.transform.anchoredPosition = self.mBaseView.gmBtn.anchoredPosition
end

function GMShortcutPanel:HideSelf()
    Globals.timerMgr:AddTimer(function()
        LMessage:Dispatch(LuaEvent.SmallGame.DecreaseCover, "GMShortcutPanel")
    end, 0, 0.1)
end


return GMShortcutPanel