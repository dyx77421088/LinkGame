--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:封装一次UnityEngine.UI.Text
--     创建时间:2022/05/18 
--------------------------------------------------------------------------------
local GraphicWrap = require "Common.Wrap.GraphicWrap"
local TextWrap = BaseClass("TextWrap", GraphicWrap)

function TextWrap:__ctor(go)
    self.csText = go:GetComponent(ClassType.Text)
    self.maxWidth = nil
    self.content = nil
    self.color = nil
end

--最大宽度设置，超过则换行
function TextWrap:SetMaxWidth(maxWidth)
	self.maxWidth = maxWidth
end

function TextWrap:SetText(text)
	if self.content == text then
		return false
	end
	self.content = text
	self.csText.text = text
	if self.maxWidth then
		self.csText:ConstraintWidth(self.maxWidth, Globals.uiMgr:Get_UIRoot())
	end
	return true
end


function TextWrap:GetText(self)
	if self.content then
		return self.content
	end
	return self.csText.text
end


function TextWrap:SetColor(color)
	if self.color == color then
		return false
	end
	self.color = color
	self.csText.color = color
	return true
end


function TextWrap:GetColor(self)
	if self.color then
		return self.color
	end
	return self.csText.color
end

function TextWrap:SetColor255(r, g, b, a)
	if self.csText then
		self.csText.color = CastUtils.Color255(r, g, b, a)
	end
end

function TextWrap:SetFontSize(size)
	if self.csText then
		self.csText.fontSize = size
	end
end

return TextWrap