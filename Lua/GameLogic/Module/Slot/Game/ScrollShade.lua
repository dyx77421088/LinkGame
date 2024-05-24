--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:用来执行滚动遮罩
--     创建时间:2023/09/20  
--------------------------------------------------------------------------------
local ScrollShade = BaseClass("ScrollShade", UIItem)
local _MaxNumber = _MaxNumber


function ScrollShade:__ctor(parent, baseView)
	self:InitItem(parent, nil, baseView)
end

function ScrollShade:Initialize()
	local process = function(transform)
		local component = transform:GetComponent(ClassType.Image)
		if ObjectUtils.IsNil(component) then
			component = v:GetComponent(ClassType.RawImage)
		end
		return {gameObject = transform.gameObject, component = component}
	end
	
	self.items = TransformUtils.GetAllChilds(self.transform, process)
	self:Hide(_MaxNumber)
end

function ScrollShade:Show(index, fade, duration)
	fade = fade or 0.4
	duration = duration or 0.5
	if index == _MaxNumber then
		for k, item in ipairs(self.items) do
			self:Show(k, fade, duration)
		end
	elseif self.items[index] then
		local item = self.items[index]
		if item.tweener then
			DOTween.Kill(item.tweener)
			item.tweener = nil
		end
		item.tweener = item.component:DOFade(fade, duration):SetEase(EaseType.InSine):OnStart(function()
			item.gameObject:SetActive(true)
		end):OnComplete(function()
			item.tweener = nil
		end)
	end
end

function ScrollShade:Hide(index, fade, duration)
	fade = fade or 0
	duration = duration or 0.2
	if index == _MaxNumber then
		for k, item in ipairs(self.items) do
			self:Hide(k, fade, duration)
		end
	elseif self.items[index] then
		local item = self.items[index]
		if item.tweener then
			DOTween.Kill(item.tweener)
			item.tweener = nil
		end
		item.tweener = item.component:DOFade(fade, duration):OnComplete(function()
			item.gameObject:SetActive(false)
			item.tweener = nil
		end)
	end
end


return ScrollShade