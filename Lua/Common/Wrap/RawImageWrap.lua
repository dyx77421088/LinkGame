--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:包装UnityEngine.UI.RawImage
--     创建时间:2022/05/18 
--------------------------------------------------------------------------------
local GraphicWrap = require "Common.Wrap.GraphicWrap"

local RawImageWrap = BaseClass("RawImageWrap", GraphicWrap)

function RawImageWrap:__ctor(go)
    self.csRawImage = go:GetComponent(ClassType.RawImage)
	self.keepNativeSize = false
end

function RawImageWrap:SetNativeSize(keepNativeSize)
    self.keepNativeSize = keepNativeSize
end

function RawImageWrap:SetColor(color)
	self.csRawImage.color = color
end

function RawImageWrap:GetColor(color)
    return self.csRawImage.color
end

function RawImageWrap:SetAlpha(alpha)
	local c = self.csRawImage.color
	c.a = alpha
	self.csRawImage.color = c
end

function RawImageWrap:SetTexture(tex)
	-- body
	if tex == self.csRawImage.texture then
		return
	end
	if self.releaseLastRT then
		self:ReleaseRT()
	end
	if ObjectUtils.IsNil(self.csRawImage) then return end
	self.csRawImage.texture = tex
	if self.keepNativeSize then
		self.csRawImage:SetNativeSize()
	end
end

--"Textures/Movie/bg_purple.png"
function RawImageWrap:LoadTexture(atlasName, texName, cb)
	if not self.csRawImage then
		printerror("csRawImage is missing")
		return
	end
	local id = ComUtils.GetUniqueID()
	self.lastLoadID = id
    Globals.resMgr:LoadImage(atlasName, texName, callback("OnTexLoadDone", id, cb))
end

function RawImageWrap:OnTexLoadDone(id, cb, tex)
	if self.lastLoadID ~= id then
		return
	end
	self:SetTexture(tex)
	if cb then
		cb(self)
	end
end

function RawImageWrap:SetImageNil(self)
	self.csRawImage.texture = nil
	self.lastLoadID = nil
	self.csRawImage.enabled = false
end

--设置大小
function RawImageWrap:SetSize(width, height)
	if self.rect == nil then
		self.rect = self.gameObject:GetComponent(ClassType.RectTransform)
	end
	self.rect.sizeDelta = Vector2(width, height)
end

return RawImageWrap