--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:包装UnityEngine.UI.Image
--     创建时间:2022/05/18 
--------------------------------------------------------------------------------
local GraphicWrap = require "Common.Wrap.GraphicWrap"
local ImageWrap = BaseClass("ImageWrap", GraphicWrap)

function ImageWrap:__ctor(go)
    self.csImage = go:GetComponent(ClassType.Image)
	if not self.csImage then
		printerror(tostring(go) .. "  has no Image")
	end
    self.keepNativeSize = false
    self.lastLoadID = nil
end

function ImageWrap:SetNativeSize(keepNativeSize)
    self.keepNativeSize = keepNativeSize
end

--清空当前显示
function ImageWrap:SetImageNil()
	self.csImage.sprite = nil
	self.lastLoadID = nil
end

function ImageWrap:GetSprite()
	return self.csImage.sprite
end

function ImageWrap:SetSprite(sprite)
	self.csImage.sprite = sprite
end

function ImageWrap:LoadSprite(atlasName, spriteName, cb)
	local id = ComUtils.GetUniqueID()
	self.lastLoadID = id
    Globals.resMgr:LoadSprite(atlasName, spriteName, callback(self, "OnSpriteLoadDone", id, cb))
end

function ImageWrap:OnSpriteLoadDone(id, cb, sp, com)
	if self.lastLoadID ~= id then
		return
	end
	if self.csImage.sprite ~= sp then
		self.csImage.sprite = sp
		if self.keepNativeSize then
			self.csImage:SetNativeSize()
		end
	end
	if cb ~= nil then
		cb(self, com)
	end
end

function ImageWrap:SetColor(color)
	self.csImage.color = color
end

function ImageWrap:SetColor255(r, g, b, a)
    if(self.csImage) then
        self.csImage.color = CastUtils.Color255(r, g, b, a)
    end
end

function ImageWrap:SetAlpha(alpha)
	local c = self.csImage.color
	c.a = alpha
	self.csImage.color = c
end

function ImageWrap:DOFade(alpha, duration)
	self.csImage:DOFade(alpha, duration)
end

return ImageWrap