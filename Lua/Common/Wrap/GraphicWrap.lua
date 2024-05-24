--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:Image RawImage Text的基类，需要继承后使用
--     创建时间:2022/05/18 
--------------------------------------------------------------------------------
local GraphicWrap = BaseClass("GraphicWrap")

function GraphicWrap:__ctor(go)
    self.gameObject = go.gameObject
    self.transform = go.transform
end

function GraphicWrap:SetEnableColor(enable, includeClick)
   UIUtils.SetEnableColor(self.gameObject, enable, includeClick) 
end

return GraphicWrap