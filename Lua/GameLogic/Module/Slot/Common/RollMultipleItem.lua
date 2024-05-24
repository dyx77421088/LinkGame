--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:用来定义占据多格的棋子
--     创建时间:2023/12/20
--------------------------------------------------------------------------------
local RollItem = require "GameLogic.Module.Slot.Common.RollItem"
local RollMultipleItem = BaseClass("RollMultipleItem", RollItem)
local ClassData = Globals.configMgr:GetConfig("ClassData")
local ImageWrap = require "Common.Wrap.ImageWrap"
local Follower = require (ClassData.Follower)


function RollMultipleItem:Initialize()
	self.rectTransform = self:GetChild("", ClassType.RectTransform)
	self.rectTransform.pivot = Vector2(0.5, 1)
	self.rectTransform.anchorMin = Vector2(0.5, 0.5)
	self.rectTransform.anchorMax = Vector2(0.5, 0.5)
	self.image = ImageWrap.New(self:GetChild("image"))
	self.image:SetNativeSize(true)
	self.cells = 1 --占用数量
	self.master = false
	self.vassals = {}
end

function RollMultipleItem:AddFollower(transform)
	if not self.follower then
		self.follower = {}
	end
	table.insert(self.follower, Follower.New(transform, self.mBaseView, self.image))
end

function RollMultipleItem:SetRegion(region)
	self.region = region
	self.rectTransform.sizeDelta = Vector2(0, self.region)
end

function RollMultipleItem:OnLoadSprite(image, component)
	local vec = component.transform.localScale
	if not self.image.transform.localScale:Equals(vec) then
		self.image.transform.localScale = vec
		self:DoFollowScale()
	end
	self:LoadFollower()
end

function RollItem:SetResult(value, immediate)
	if immediate then
		self:ResetResult(value)
	else
		self.result = value
	end
end

function RollMultipleItem:SetCell(cells)
	--绑定座位
	local master = self:FindEmptyCell()
	if master then
		self.master = master
		self:SetEnable(false)
		table.insert(master.vassals, self)
	else
		self:AdjustCell(cells)
	end
end

--检查是否有空位
function RollMultipleItem:FindEmptyCell()
	if self.result and self.state ~= Const.ScrollType.Idle then
		local master = self.previous.master
		if not master and self.previous.cells > 1 then
			master = self.previous
		end
		if master and master.result == self.result and master:GetEmptyCellCount() > 0 then
			return master
		end
	end
	return false
end

function RollMultipleItem:GetEmptyCellCount()
	return self.cells - #self.vassals - 1
end

function RollMultipleItem:SetEnable(enable)
	if self.enable == enable then
		return
	end
	self.enable = enable
	if self.enable then
		--修复链接
		self.previous:SetLatter(self)
		self.latter:SetPrevious(self)
		self.state = self.previous.state
		self.moveSpeed = self.previous.moveSpeed
		self.result = false
		self:SetPos(self.previous:GetPos())
		self.cells = 0
		self:SetValue()
		self:SetIsPop(true)
	else
		--切断链接
		self.previous:SetLatter(self.latter)
		self.latter:SetPrevious(self.previous)
		self.state = Const.ScrollType.Idle
		self:ClearFollower()
		self:SetIsPop(false)
	end
end

function RollMultipleItem:AdjustCell(cells)
	if self.cells == cells then
		return
	end
	
	local increment = (cells - self.cells) * self.region
	self.rectTransform.sizeDelta = Vector2(0, cells * self.region)
	self:AdjustPos(increment)
	self.cells = cells
end

function RollMultipleItem:Distance(item)
	local distance = self.region * self.cells
	if self ~= item then
		local latter = self.latter
		while (latter) do
			distance = distance + latter.region * latter.cells
			if latter == item then
				break
			end
			latter = latter.latter
		end
	end
	
	return distance
end

function RollMultipleItem:LoadFollower(...)
	if not self.follower then
		return
	end
	if not self.enable and self.master then
		self.master:LoadFollower(...)
		return
	end
	
	if self.state == Const.ScrollType.Idle then
		if self.result then
			local objectName = self.idleName..self.result
			self.arguments[objectName] = ... or self.arguments[objectName]
			Globals.poolMgr:Pop(self.objectAtlasName, objectName, callback(self, "OnLoadObject", 1, objectName))
		end
	elseif self.state == Const.ScrollType.Scroll or self.state == Const.ScrollType.Stop then
		local objectName = self.scrollName..self.value
		self.arguments[objectName] = ... or self.arguments[objectName]
		Globals.poolMgr:Pop(self.objectAtlasName, objectName, callback(self, "OnLoadObject", 1, objectName))
	elseif self.state == Const.ScrollType.Rebound then
		if self.result then
			local objectName = self.reboundName..self.result
			self.arguments[objectName] = ... or self.arguments[objectName]
			if self.cells > 1 then
				Globals.poolMgr:Pop(self.objectAtlasName, objectName, callback(self, "OnLoadObject", 1, objectName))
			else
				Globals.poolMgr:Pop(self.objectAtlasName, objectName, callback(self, "OnLoadObject", 2, objectName))
			end
		else
			self:ClearFollower()
		end
	elseif self.state == Const.ScrollType.Finish then
		if self.result then
			local objectName = self.finishName..self.result
			self.arguments[objectName] = ... or self.arguments[objectName]
			if self.cells > 1 then
				Globals.poolMgr:Pop(self.objectAtlasName, objectName, callback(self, "OnLoadObject", 1, objectName))
			else
				Globals.poolMgr:Pop(self.objectAtlasName, objectName, callback(self, "OnLoadObject", 2, objectName))
			end
		end
	end
end

function RollMultipleItem:Scrolling()
	if self.state == Const.ScrollType.Scroll or self.state == Const.ScrollType.Stop then
		self.moveSpeed = self.moveSpeed + self.addSpeed * Time.deltaTime
		self.moveSpeed = math.min(self.moveSpeed, self.maxSpeed)
		local pos = self:GetPos() + self.direction * (self.moveSpeed * Time.deltaTime)
		self:SetPos(pos)
		if Vector3.Dot(pos - self.direction * self.stopDistance, self.direction) > 0 then
			if self.deepest then
				local cellCnt = self.latter:GetEmptyCellCount()
				if Vector3.Dot(pos - self.direction * (self.region * cellCnt + self.stopDistance), self.direction) > 0 then
					self:ScrollBack()
				else
					self:DoFollowPos()
				end
			else
				pos = pos - self.direction * self:Distance(self.previous)
				self:SetPos(pos)
				self:SetValue()
				--解绑座位
				if #self.vassals > 0 then
					for i = #self.vassals, 1, -1 do
						self.vassals[i].master = nil
						self.vassals[i]:SetEnable(true)
						self.vassals[i] = nil
					end
				end
			end
		else
			self:DoFollowPos()
		end
	end
end

function RollMultipleItem:ScrollBack()
	self.state = Const.ScrollType.Rebound
	local direction = self.direction
	local vector = Vector3(math.abs(direction.y), math.abs(direction.x), 0)
	local firstPos = Vector3.Scale(self:GetPos(), vector)
	local cellCnt = self.latter:GetEmptyCellCount()
	firstPos = firstPos + direction * (self.region * cellCnt)
	self:SetPos(firstPos + direction * self.stopDistance)
	self.transform:DOLocalMove(firstPos, self.stopTime):SetEase(EaseType.OutBack):OnUpdate(function()
		self:DoFollowPos()
	end):OnComplete(function()
		self.state = Const.ScrollType.Finish
		if cellCnt > 0 then
			local pos = firstPos - direction * self:Distance(self.previous)
			self:SetPos(pos)
		else
			self:SetPos(firstPos)
		end
	end)
	self:SetValue(self.value)
	local item = self
	local latter = item.latter
	while (latter ~= self) do
		local curr = latter
		curr.state = Const.ScrollType.Rebound
		local target = firstPos - (direction * self.latter:Distance(curr))
		curr:SetPos(target + direction * self.stopDistance)
		curr.transform:DOLocalMove(target, self.stopTime):SetEase(EaseType.OutBack):OnUpdate(function()
			curr:DoFollowPos()
		end):OnComplete(function()
			curr.state = Const.ScrollType.Finish
			curr:SetPos(target)
		end)
		curr:SetValue(curr.value)
		item = curr
		latter = item.latter
	end
end


return RollMultipleItem