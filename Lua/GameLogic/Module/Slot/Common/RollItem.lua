--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:用来定义棋子
--     创建时间:2023/09/20  
--------------------------------------------------------------------------------
local RollItem = BaseClass("RollItem", UIItem)
local ClassData = Globals.configMgr:GetConfig("ClassData")
local ImageWrap = require "Common.Wrap.ImageWrap"
local Follower = require (ClassData.Follower)


function RollItem:__defaultVar()
	return {
		groupId = 0, --组号
		region = 0, --区域大小,在滚动方向占据位置大小
		state = Const.ScrollType.Idle,
		direction = Vector3.down, --滚动方向
		enable = false, --激活状态
		image = false,
		follower = false, --跟随节点
		value = false, --值
		result = false, --结果值
		deepest = false, --停止为最深棋子
		previous = false, --滚动方向前一个棋子
		latter = false, --滚动方向后一个棋子
		arguments = {}, --回调参数
	}
end

function RollItem:__ctor(parent, baseView, range)
	self:InitItem(parent, nil, baseView)
	self.range = range or 1
	self.enable = true
end

function RollItem:Initialize()
	self.image = ImageWrap.New(self.gameObject)
	self.image:SetNativeSize(true)
end

function RollItem:SetAtlasParam(...)
	self.atlasName = select(1, ...) or "Slot/Main/SlotAtlas"
	self.objectAtlasName = select(2, ...) or "Slot/Main/SlotObject"
	self.idleName = select(3, ...) or "chess_idle/"
	self.scrollName = select(4, ...) or "chess_scroll/"
	self.reboundName = select(5, ...) or "chess_rebound/"
	self.finishName = select(6, ...) or "chess_finish/"
end

function RollItem:SetDirection(direction)
	self.direction = direction
end

function RollItem:SetScrollParam(speeds, rollBacks)
	if speeds and type(speeds) == "table" then
		self.addSpeed = speeds.addSpeed or 0
		self.minSpeed = speeds.minSpeed
		self.maxSpeed = speeds.maxSpeed or speeds.minSpeed
		self.moveSpeed = speeds.minSpeed
	elseif speeds and type(speeds) == "number" then
		self.addSpeed = 0
		self.minSpeed = speeds
		self.maxSpeed = speeds
		self.moveSpeed = speeds
	end
	if rollBacks then
		self.startDistance = rollBacks.startDistance or 30
		self.startTime = rollBacks.startTime or 0.2
		self.stopDistance = rollBacks.stopDistance or 30
		self.stopTime = rollBacks.stopTime or 0.2
	end
end

function RollItem:SetGroupId(id)
	self.groupId = id
end

function RollItem:SetRegion(region)
	self.region = region
end

function RollItem:SetLatter(latter)
	self.latter = latter
end

function RollItem:SetPrevious(previous)
	self.previous = previous
end

function RollItem:SetCell()
	
end

function RollItem:SetPos(x, y)
    if self.transform == nil then
        return
    end
    if type(x) == "number" then
        self.transform.localPosition = Vector3(x, y, 0)
    else
        self.transform.localPosition = x
    end
	self:DoFollowPos()
end

function RollItem:SetEnable(enable)
	if self.enable == enable then
		return
	end
	self.enable = enable
	if self.enable then
		--修复链接
		self.previous:SetLatter(self)
		self.latter:SetPrevious(self)
		self:SetPos(self.previous:GetPos())
		self:AdjustPos(self.region)
		self.state = self.previous.state
		self.moveSpeed = self.previous.moveSpeed
		self.result = false
		self:SetIsPop(true)
		self:SetValue()
	else
		--切断链接
		self.previous:SetLatter(self.latter)
		self.latter:SetPrevious(self.previous)
		self.state = Const.ScrollType.Idle
		self:ClearFollower()
		self:SetIsPop(false)
	end
end

function RollItem:AdjustPos(increment)
	local pos = self:GetPos()
	self:SetPos(pos - self.direction * increment)
	local latter = self.latter
	local latterPos = latter:GetPos()
	while(Vector3.Dot(latterPos - pos, self.direction) <= 0 and self ~= latter) do
		latter:SetPos(latterPos - self.direction * increment)
		latter = latter.latter
		latterPos = latter:GetPos()
	end
end

function RollItem:AddFollower(transform)
	if not self.follower then
		self.follower = {}
	end
	table.insert(self.follower, Follower.New(transform, self.mBaseView, self))
end

function RollItem:AddFollowerReveal(func)
	self.DoFollowReveal = func
end

function RollItem:DoFollowPos()
	if self.follower then
		for _, v in pairs(self.follower) do
			v:DoFollowPos()
		end
	end
end

function RollItem:DoFollowScale()
	if self.follower then
		for _, v in pairs(self.follower) do
			v:DoFollowScale()
		end
	end
end

function RollItem:LoadFollower(...)
	if not self.enable or not self.follower then
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
			Globals.poolMgr:Pop(self.objectAtlasName, objectName, callback(self, "OnLoadObject", 2, objectName))
		else
			self:ClearFollower()
		end
	elseif self.state == Const.ScrollType.Finish then
		if self.result then
			local objectName = self.finishName..self.result
			self.arguments[objectName] = ... or self.arguments[objectName]
			Globals.poolMgr:Pop(self.objectAtlasName, objectName, callback(self, "OnLoadObject", 2, objectName))
		end
	end
end

function RollItem:DropFollower()
	if self.follower then
		for _, v in pairs(self.follower) do
			local objectName, object =  v:Drop()
			if objectName or object then
				return objectName, object
			end
		end
	end
end

function RollItem:ClearFollower()
	if self.follower then
		for _, v in pairs(self.follower) do
			v:Clear()
		end
	end
end

function RollItem:OnLoadSprite(image, component)
	if not self.enable then
		return
	end
	
	local vec = component.transform.localScale
	if not self.transform.localScale:Equals(vec) then
		self.transform.localScale = vec
		self:DoFollowScale()
	end
	self:LoadFollower()
end

function RollItem:AddLoadSprite(func)
	local zfunc = self.OnLoadSprite
	self.OnLoadSprite = LuaDelegate.New(zfunc) + LuaDelegate.New(func)
end

function RollItem:OnLoadObject(followerId, objectName, object)
	if not self.follower and object then
		Globals.poolMgr:Push(objectName, object)
		return
	end
	
	if object then
		for k, v in pairs(self.follower) do
			if k == followerId then
				object = v:Push(objectName, object, self.value)
				if self.DoFollowReveal then
					self:DoFollowReveal(object, self.arguments[objectName])
					self.arguments[objectName] = nil
				end
			else
				v:Clear()
			end
		end
		self:SetIsPop(false)
	else
		self:ClearFollower()
		self:SetIsPop(true)
	end
end

function RollItem:SetValue(value)
	value = self.result or value
	value = value or math.random(1, self.range)
	self.value = value
	
	if self.state == Const.ScrollType.Scroll then
		self.image:LoadSprite(self.atlasName, self.scrollName..self.value, callback(self, "OnLoadSprite"))
	elseif self.idleName then
		self.image:LoadSprite(self.atlasName, self.idleName..self.value, callback(self, "OnLoadSprite"))
	end
end

function RollItem:SetResult(value)
	self.result = value
end

function RollItem:ResetResult(value, ...)
	self.result = value
	if self.state == Const.ScrollType.Idle then
		local objectName = self.idleName..self.result
		self.arguments[objectName] = ... or self.arguments[objectName]
	elseif self.state == Const.ScrollType.Scroll or self.state == Const.ScrollType.Stop then
		local objectName = self.scrollName..self.result
		self.arguments[objectName] = ... or self.arguments[objectName]
	elseif self.state == Const.ScrollType.Rebound then
		local objectName = self.reboundName..self.result
		self.arguments[objectName] = ... or self.arguments[objectName]
	elseif self.state == Const.ScrollType.Finish then
		local objectName = self.finishName..self.result
		self.arguments[objectName] = ... or self.arguments[objectName]
	end
	self:SetValue()
end

function RollItem:SetDeepest(value)
	self.deepest = value
end

function RollItem:Distance(item)
	local distance = self.region
	if self ~= item then
		local latter = self.latter
		while (latter) do
			distance = distance + latter.region
			if latter == item then
				break
			end
			latter = latter.latter
		end
	end
	
	return distance
end

function RollItem:IsDeepest()
	local previousPos = self.previous:GetPos()
	local pos = self:GetPos()
	return Vector3.Dot(previousPos - pos, self.direction) <= 0
end

function RollItem:GetState()
	return self.state
end

function RollItem:IsScrolling()
	return self.state == Const.ScrollType.Scroll or self.state == Const.ScrollType.Stop
end

function RollItem:StartScroll()
	if not self.enable then
		return
	end
	
	self.state = Const.ScrollType.Begin
	self.moveSpeed = self.minSpeed
	self.result = false
	self.deepest = false
	self.transform:DOLocalMove(self:GetPos() - self.direction * self.startDistance, self.startTime):SetEase(EaseType.OutQuad):OnUpdate(function()
		self:DoFollowPos()
	end):OnComplete(function()
		self.state = Const.ScrollType.Scroll
		--重置跟随者
		self:SetValue(self.value)
	end)
end

function RollItem:Scrolling()
	if self.state == Const.ScrollType.Scroll or self.state == Const.ScrollType.Stop then
		self.moveSpeed = self.moveSpeed + self.addSpeed * Time.deltaTime
		self.moveSpeed = math.min(self.moveSpeed, self.maxSpeed)
		local pos = self:GetPos() + self.direction * (self.moveSpeed * Time.deltaTime)
		self:SetPos(pos)
		if Vector3.Dot(pos - self.direction * self.stopDistance, self.direction) > 0 then
			if self.deepest then
				self:ScrollBack()
			else
				pos = pos - self.direction * self:Distance(self.previous)
				self:SetPos(pos)
				self:SetValue()
			end
		else
			self:DoFollowPos()
		end
	end
end

function RollItem:StopScroll()
	if not self.enable then
		return
	end
	
	self.state = Const.ScrollType.Stop
end

function RollItem:ScrollBack()
	if not self.enable then
		return
	end
	
	self.state = Const.ScrollType.Rebound
	local direction = self.direction
	local vector = Vector3(math.abs(direction.y), math.abs(direction.x), 0)
	local pos = Vector3.Scale(self:GetPos(), vector)
	self:SetPos(pos + direction * self.stopDistance)
	self.transform:DOLocalMove(pos, self.stopTime):SetEase(EaseType.OutBack):OnUpdate(function()
		self:DoFollowPos()
	end):OnComplete(function()
		self.state = Const.ScrollType.Finish
		self:SetPos(pos)
	end)
	self:SetValue()
	local item = self
	local latter = item.latter
	while (latter ~= self) do
		local curr = latter
		curr.state = Const.ScrollType.Rebound
		curr:SetPos(item:GetPos() - direction * curr.region)
		local target = pos - (direction * self.latter:Distance(curr))
		curr.transform:DOLocalMove(target, self.stopTime):SetEase(EaseType.OutBack):OnUpdate(function()
			curr:DoFollowPos()
		end):OnComplete(function()
			curr.state = Const.ScrollType.Finish
			curr:SetPos(target)
		end)
		curr:SetValue()
		item = curr
		latter = item.latter
	end
end


return RollItem