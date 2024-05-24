--[[
    拆分Utils, 把Transform相关的工具函数放在这里
    author:xym
    time:2021-02-04 20:31:17
]]

local TransformUtils = {}


--返回所有孩子节点Table，支持过滤
function TransformUtils.GetAllChilds(transform, process)
	local cnt = transform.childCount
	local list = {}
	if process then
		for i=0, cnt-1 do
			local obj = process(transform:GetChild(i), i+1, list)
			if obj then
				table.insert(list, obj)
			end
		end
	else
		for i=0, cnt-1 do
			table.insert(list, transform:GetChild(i))
		end
	end
	return list
end


--找到子节点或者子节点上的组件
function TransformUtils.GetChild(compOrGameObject, path, componentName)
    local transform = compOrGameObject.transform:Find(path)
    if (ObjectUtils.IsNil(transform)) then
        --printwarning("所给路径不存在子节点:", path)
        return
    elseif(componentName) then
        local comp = transform:GetComponent(componentName)
        if(ObjectUtils.IsNil(comp)) then
        	--printwarning("不存在组件：", path, componentName)
        	return
        end
        return comp
	else
		return transform
	end    
end

--判断子节点是否存在
function TransformUtils.HasChild(compOrGameObject, path)
	local transform = compOrGameObject.transform:Find(path)
	if(ObjectUtils.IsNil(transform)) then
		return false
	else
		return true
	end
end

function TransformUtils.NormalizeTrans(compOrGameObject)
	local transform = compOrGameObject.transform
	if(ObjectUtils.IsNotNil(transform)) then
		transform.localScale = Vector3.one
		transform.localEulerAngles = Vector3.zero
		transform.localPosition = Vector3.zero
	end
end


function TransformUtils.CloneChildItemIfNeed(childTransform, needCount)
	local existChildItem = TransformUtils.GetAllChilds(childTransform.parent)
	local ret = {}
	if #existChildItem < needCount then
		for i=1, needCount - #existChildItem do
			local cloneItem = GameObject.Instantiate(childTransform, childTransform.parent, false)
			table.insert(existChildItem, cloneItem)
		end
	end
	for i = 1, needCount do
		existChildItem[i]:SetActive(true)
		table.insert(ret, existChildItem[i])
	end
	for i = needCount+1, #existChildItem do
		existChildItem[i]:SetActive(false)
	end
	return ret
end


function TransformUtils.GetMissingComponent(obj, componentName)
	local comp = obj.transform:GetComponent(componentName)
	if(comp) then
		return comp
	end
	comp = obj.transform:AddComponent(componentName)
	return comp
end

function TransformUtils.SetLocalPos(transform, setFunc)
	local pos = transform.localPosition
	setFunc(pos)
	transform.localPosition = pos
end

--==============================--
--addby:yjp
--@rectTransform:某个UI节点
--@sreenPoint:屏幕坐标
--@camera: ui相机
--@return:
--time:2022-04-26 16:34:36
--==============================--
function TransformUtils.RectangleContainsScreenPoint(rectTransform, screenPoint, camera)
	return UnityEngine.RectTransformUtility.RectangleContainsScreenPoint(rectTransform, screenPoint, camera)
end

function TransformUtils.ScreenPointToLocalPointInRectangle(rectTransform, screenPoint, camera, localPoint)
	return UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(rectTransform, screenPoint, camera, localPoint)
end

function TransformUtils.ScreenPointToWorldPointInRectangle(rectTransform, screenPoint, camera, worldPoint)
	return UnityEngine.RectTransformUtility.ScreenPointToWorldPointInRectangle(rectTransform, screenPoint, camera, worldPoint)
end

function TransformUtils.WorldToScreenPoint(camera, worldPoint)
	return UnityEngine.RectTransformUtility.WorldToScreenPoint(camera, worldPoint)
end

--检查物体是否在摄像机渲染内
function TransformUtils.CheckObjectInsideCamera(camera, gameObject)
	local position = gameObject.transform.position
	local viewPoint = camera:WorldToViewportPoint(position)
	return viewPoint.x >= 0 and viewPoint.x <= 1 and viewPoint.y >= 0 and viewPoint.y <= 1
end


return TransformUtils