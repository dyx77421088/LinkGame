--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:滚动条 包装UnityEngine.UI.Scrollbar
--     创建时间:2022/05/18 
--------------------------------------------------------------------------------
local ScrollbarWrap = BaseClass("ScrollbarWrap")

function ScrollbarWrap:__ctor(go)
    self.csScrollbar = go:GetComponent(ClassType.Scrollbar)
    self.transform = go.transform
    self.gameObject = go.gameObject
end

function ScrollbarWrap:SetScrollbarValue(value)
    self.csScrollbar.value = value
end

function ScrollbarWrap:OnValueChanged(cb)
    self.csScrollbar.onValueChanged:AddListener(cb)
end

return ScrollbarWrap