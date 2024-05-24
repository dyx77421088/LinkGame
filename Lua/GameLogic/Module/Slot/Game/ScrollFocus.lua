--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:用来执行滚动焦点框
--     创建时间:2023/09/20  
--------------------------------------------------------------------------------
local ScrollFocus = BaseClass("ScrollFocus", UIItem)
local _MaxNumber = _MaxNumber


function ScrollFocus:__ctor(parent, baseView)
	self:InitItem(parent, nil, baseView)
end

function ScrollFocus:Initialize()
	self.node = self:GetChild("root")
	self.animator = self.node:GetComponent(ClassType.Animator)
	local trigger = self.node:GetComponent(ClassType.LuaEventTrigger)
	trigger:SetLuaChunk(self)
	trigger:SetLuaCbFunc(self.OnUIEvent)
	self.isOpen = true
	self:SetIsPop(false)
end

function ScrollFocus:OnUIEvent(trigger, param)
	if param == "hide" then
		self:SetIsPop(false)
	end
end

function ScrollFocus:Focus(x)
	if x == _MaxNumber then
		if self:GetIsPop() then
			LMessage:Dispatch(LuaEvent.Sound.Play, "scroll_focus", 3)
			self.animator:SetTrigger("hide")
		end
	elseif not self:GetIsPop() then
		LMessage:Dispatch(LuaEvent.Sound.Play, "scroll_focus", 1)
		self.node.localPosition = Vector3(x, 0, 0)
		self:SetIsPop(true)
		self.animator:SetTrigger("show")
	else
		LMessage:Dispatch(LuaEvent.Sound.Play, "scroll_focus", 2)
		self.node:DOLocalMoveX(x, 0.2)
		self.animator:SetTrigger("move")
	end
end

function ScrollFocus:GetFocusTime()
	return 1.4
end


return ScrollFocus