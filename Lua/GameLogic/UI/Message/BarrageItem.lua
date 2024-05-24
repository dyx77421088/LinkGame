local BarrageItem = BaseClass(UIItem)

function BarrageItem:__ctor(parent,baseView)
    self.preferredWidth = false
    self.anchoredPosition = false
    self:InitItem(parent,PathUtils.GetUIAssetPath("Barrage/BarrageItem"),baseView)
end

function BarrageItem:Initialize()
    self.rectTransform = self:GetChild("","RectTransform")
    self.contentTxt = self:GetChild("","EmojiText")
end

function BarrageItem:GetPreferredWidth()
    if(not self.preferredWidth) then
        self.preferredWidth = self.contentTxt.preferredWidth
    end
    return self.preferredWidth
end

function BarrageItem:SetText(text)
    self.contentTxt.text = text
    self.preferredWidth = false
end

function BarrageItem:SetAnchoredPosition(vec2)
    self.rectTransform.anchoredPosition = vec2
    self.anchoredPosition = vec2
end

function BarrageItem:GetAnchoredPosition()
    return self.anchoredPosition
end

function BarrageItem:__delete()
    self.contentTxt = nil
    self.preferredWidth = nil
    self.rectTransform = nil
end

return BarrageItem
