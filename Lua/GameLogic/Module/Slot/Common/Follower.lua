--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:用来执行追随者
--     创建时间:2023/09/20  
--------------------------------------------------------------------------------
local Follower = BaseClass("Follower", UIItem)


function Follower:__ctor(parent, baseView, master)
	self:InitItem(parent, nil, baseView)
	self.master = master
end

function Follower:DoFollowPos()
	self.transform.position = self.master.transform.position
end

function Follower:DoFollowScale()
	self.transform.localScale = self.master.transform.localScale
end

--追随者添加物体
function Follower:Push(objectName, object, siblingIndex)
	if self.objectName == objectName then
		Globals.poolMgr:Push(objectName, object)
		return self.object
	end
	
	self:Clear()
	object.transform:SetParent(self.transform)
	TransformUtils.NormalizeTrans(object)
	ComUtils.ResetAnim(object)
	--避免打断合批
	if siblingIndex then
		self.transform:SetSiblingIndex(siblingIndex)
	end
	
	self.objectName = objectName
	self.object = object
	
	return self.object
end

--清除追随者下的物体,不回收
function Follower:Drop()
	if not self.object then
		return
	end
	local objectName = self.objectName
	local object = self.object
	self.objectName = nil
	self.object = nil
	
	return objectName, object
end

--回收追随者下的物体
function Follower:Clear()
	if not self.objectName or not self.object then
		return
	end
	
	Globals.poolMgr:Push(self.objectName, self.object)
	self.objectName = nil
	self.object = nil
end


return Follower