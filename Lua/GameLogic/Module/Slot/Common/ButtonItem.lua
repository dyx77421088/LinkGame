local ButtonItem = BaseClass("ButtonItem", UIItem)

function ButtonItem:__defaultVar()
	return {
		interactable = true,
		relateHides = false,
		relateEnables = false,
	}
end

function ButtonItem:__ctor(parent, baseView)
	if not parent then return end
	self:InitItem(parent, nil, baseView)
end

function ButtonItem:Initialize()
	self.button = self:GetChild("", ClassType.Button)
	self.image = self:GetChild("", ClassType.Image)
	if not self.image then
		self.image = self:GetChild("title", ClassType.Image)
	end
end

function ButtonItem:SetEnable(enable)
	if self.interactable == enable then
		return
	end
	self.interactable = enable
	self.button.interactable = enable
end

function ButtonItem:ClickSelf()
	if self.interactable then
		self.button.onClick:Invoke()
	end
end

function ButtonItem:ShowSelf()
	if self.relateHides then
		for _, item in pairs(self.relateHides) do
			item:SetIsPop(false)
		end
	end
	if self.relateEnables then
		for _, item in pairs(self.relateEnables) do
			item:SetEnable(false)
		end
	end
end

function ButtonItem:AddRelate(item, hide)
	if self == item then return end

	if hide then
		if not self.relateHides then
			self.relateHides = {}
		end
		if table.indexof(self.relateHides, item) then
			return
		end
		table.insert(self.relateHides, item)
	else
		if not self.relateEnables then
			self.relateEnables = {}
		end
		if table.indexof(self.relateEnables, item) then
			return
		end
		table.insert(self.relateEnables, item)
	end
	item:AddRelate(self, hide)
end

function ButtonItem:GetEnable()
	return self.interactable
end


return ButtonItem