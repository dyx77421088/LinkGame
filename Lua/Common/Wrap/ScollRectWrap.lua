--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:滚动框ScrollRect 包装ScrollRect
--     创建时间:2022/05/18 
--------------------------------------------------------------------------------
local ScrollRectWrap = BaseClass("ScrollRectWrap")

function ScrollRectWrap:__ctor(go)
    self.gameObject = go.gameObject
    self.transform = go.transform
    self.csScrollRect = go:GetComponent(ClassType.ScrollRect)
end

function ScrollRectWrap:SetHorizontalEnable(enable)
    self.csScrollRect.horizontal = enable
end

function ScrollRectWrap:SetVerticalEnable(enable)
    self.csScrollRect.vertical = enable
end

return ScrollRectWrap