--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:用来处理对象池
--     创建时间:2023/09/20  
--------------------------------------------------------------------------------
local PoolMgr = Singleton("PoolMgr")
local Stack = require "Common.Tool.Stack"
local ObjectUtils = ObjectUtils
local TransformUtils = TransformUtils


function PoolMgr:__ctor()
	self.list = {}
end

function PoolMgr:__delete()
	self.list = nil
	GameObject.Destroy(self.gameObject)
end

function PoolMgr:Initialize()
	self.gameObject = GameObject("Pool")
	self.transform = self.gameObject.transform
	self.transform.localPosition = Vector3(0,0,-100000)
	self.gameObject:SetActive(false)
end

function PoolMgr:Push(objectName, object)
	if not self.list[objectName] then
		self.list[objectName] = Stack.New()
	end
	self.list[objectName]:Push(object)
	if object.transform ~= nil and ObjectUtils.IsNotNil(object) then
		object.transform:SetParent(self.transform)
		TransformUtils.NormalizeTrans(object.transform)
	end
end

function PoolMgr:Pop(atlasName, objectName, callBack)
	local object = nil
	if self.list[objectName] then
		object = self.list[objectName]:Pop()
	end
	
	if object and callBack then
		callBack(object)
	elseif object then
		return object
	elseif atlasName and objectName and callBack then
		Globals.resMgr:LoadObject(atlasName, objectName, function(prefab)
			if prefab then
				object = GameObject.Instantiate(prefab.gameObject)
				object.name = objectName
			end
			callBack(object)
		end)
	elseif callBack then
		callBack()
	end
end

function PoolMgr:Size(objectName)
	if not self.list[objectName] then
		return 0
	end
	return self.list[objectName]:Size()
end

function PoolMgr:Empty(objectName)
	if not self.list[objectName] then
		return true
	end
	return self.list[objectName]:Empty()
end


return PoolMgr