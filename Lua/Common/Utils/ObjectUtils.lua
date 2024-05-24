--[[
    拆分Utils.lua，将Unity.Object相关的工具函数都放在这里
    author:xym
    time:2021-02-04 15:44:23
]]
local ObjectUtils = {}

--Untiy对象Destroy后, ==nil判断还是false
function ObjectUtils.IsNil(obj)
	if type(obj) == "userdata" then
		return obj:Equals(nil)
	end
	if type(obj) == "table" and obj.transform then
		return obj.transform:Equals(nil)
	end
	return (obj == nil)
end

--IsNil取反
function ObjectUtils.IsNotNil(obj)
    return (not ObjectUtils.IsNil(obj))
end

function ObjectUtils.IsGameObject(obj)
	return ObjectUtils.IsNotNil(obj) and type(obj) == "userdata" and obj.gameObject and obj.name
end

--包装物体
function ObjectUtils.RecordGameObject(obj)
	return {transform = obj.transform, gameObject = obj.gameObject}
end

--复制并且用创建新的lua对象
function ObjectUtils.Clone(clsObj, ...)
	local go = GameObject.Instantiate(clsObj.gameObject)
	return clsObj.clstype.New(go, ...)
end

function ObjectUtils.DisableGameObejctCollider(gameObject)
	local allComps = gameObject:GetComponentsInChildren(ClassType.Collider)
	local len = allComps.Length
	if len > 0 then
		for i=0, len -1 do
			local comp = allComps[i]
			print("collider enabled:", comp.gameObject.name)
			comp.enabled = false
		end
	end
end

function ObjectUtils.DisableCollider(name)
	local go = GameObject.Find(name)
	if go then
		ObjectUtils.DisableGameObejctCollider(go)
	else
		print(name, "is nil")
	end
end


function ObjectUtils.SetRenderEnable(gameObject, enable)
	--中评隐藏go 铰链约束失效问题临时解决
	local allComps = gameObject.transform:GetComponentsInChildren(ClassType.Renderer, true)
	local len = allComps.Length
	if len > 0 then
		for i=0, len -1 do
			local comp = allComps[i]
			comp.enabled = enable
		end
	end
end

function ObjectUtils.PlayParticleSystem(go, includeInactive)
	includeInactive = includeInactive == nil and true or false
	local list = CastUtils.Array2Table(go:GetComponentsInChildren(ClassType.ParticleSystem, includeInactive))
	for i, v in ipairs(list) do
		v:Play()
	end
end

function ObjectUtils.DisablePhysicsThisFrame(go)--移动位置前调用
	local comp = go and go:GetComponent(typeof(CS.PhysXStateController))
	if comp then
		comp:DisableOneFrame()
	end
end

function ObjectUtils.Destroy(obj)
	if obj ~= nil then
		GameObject.Destroy(obj.gameObject)
	end
end

return ObjectUtils