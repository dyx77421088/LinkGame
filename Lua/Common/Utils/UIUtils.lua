
--[[
    拆分Utils, UI相关的工具函数都放在这里
    author:xym
    time:2021-02-04 15:44:23
]]
local Camera = UnityEngine.Camera
local RectTransform = UnityEngine.RectTransform
-- local RectTransformUtility = UnityEngine.RectTransformUtility
local UIUtils = {}

--==============================--
--addby:yjp
--desc:设置界面的oder
--@gameObject: 界面对象
--@order: 界面要设置的order
--@return:
--time:2022-04-21 17:07:19
--==============================--
function UIUtils.SetCanvasSortingOrder(gameObject, order)
    local childPanel = gameObject.gameObject:GetComponentsInChildren(ClassType.Canvas, true)
    local mainOrder = 0
    local panel = gameObject.gameObject:GetComponent(ClassType.Canvas)
    if(panel) then
        mainOrder = panel.sortingOrder
    end
    for idx = 0, childPanel.Length - 1 do
        childPanel[idx].overrideSorting = true
        local offset = childPanel[idx].sortingOrder - mainOrder
        --offset = offset > 0 and offset or 1
        childPanel[idx].sortingOrder = offset + order
    end
	local renderers = gameObject.gameObject:GetComponentsInChildren(ClassType.Renderer, true)
	for idx = 0, renderers.Length - 1 do
		local offset = renderers[idx].sortingOrder - mainOrder
		renderers[idx].sortingOrder = offset + order
	end
    if panel then
        panel.overrideSorting = true
        panel.sortingOrder = order
    end
end

function UIUtils.SetCanvasSortingLayer(gameObject, sortingLayer)
	local childPanel = gameObject.gameObject:GetComponentsInChildren(ClassType.Canvas, true)
	for idx = 0, childPanel.Length - 1 do
		if type(sortingLayer) == "number" then
			childPanel[idx].sortingLayerID = sortingLayer
		else
			childPanel[idx].sortingLayerName = sortingLayer
		end
	end
	childPanel = gameObject.gameObject:GetComponentsInChildren(ClassType.Renderer, true)
	for idx = 0, childPanel.Length - 1 do
		if type(sortingLayer) == "number" then
			childPanel[idx].sortingLayerID = sortingLayer
		else
			childPanel[idx].sortingLayerName = sortingLayer
		end
	end
end

function UIUtils.SetCanvasSortingEnable(gameObject, enable)
	local childPanel = gameObject:GetComponentsInChildren(ClassType.Canvas, true)
    for idx = 0, childPanel.Length - 1 do
        childPanel[idx].overrideSorting = enable
    end
	local rectTransform = gameObject:GetComponent(ClassType.RectTransform)
	LayoutRebuilder.ForceRebuildLayoutImmediate(rectTransform)
end

-- 需要考虑屏幕拉伸的情况, 根据CanvasScaler配置不同, 计算方法会不一样
function UIUtils.ScreenPos2CanvasPos(v2)
    local size = UIUtils.ScreenExpandSize()
    local Screen = UnityEngine.Screen
    local x = v2.x / Screen.width * size.x
    local y = v2.y / Screen.height * size.y
    return Vector2(x, y)
end

function UIUtils.ChangeTransformKeepChild(rectTransform, func)
	--deteach child
	local childs = {}
	for i = 0, rectTransform.childCount-1 do
		table.insert(childs, rectTransform:GetChild(i))
	end
	for _, child in pairs(childs) do
		child:SetParent(rectTransform.parent, true)
	end
	func(rectTransform)
	--attach child
	for _, child in ipairs(childs) do
		child:SetParent(rectTransform, true)
	end
end

function UIUtils.SetSize(rectTransform, vec2Size)--无视适配策略直接设置size
	local Axis = UnityEngine.RectTransform.Axis
	rectTransform:SetSizeWithCurrentAnchors(Axis.Horizontal, vec2Size.x)
	rectTransform:SetSizeWithCurrentAnchors(Axis.Vertical, vec2Size.y)
end


function UIUtils.SyncRectPosAndSize(rect, targetRect, mulw, mulh)
	rect.pivot = targetRect.pivot
	rect.position = targetRect.position
	local r = targetRect.rect
	if not mulw then
		mulw = 1
	end
	if not mulh then
		mulh = 1
	end
	rect.sizeDelta = Vector2(r.width * mulw, r.height * mulh)
end

function UIUtils.SyncDragPos(trans, pos)
    local uiCamera = Globals.cameraMgr:GetUICamera()
    local uiRoot = Globals.uiMgr:GetUIRootObj()
 	local canvas = uiRoot:GetComponent(ClassType.Canvas)
	local npos = uiCamera:ScreenToWorldPoint(Vector3(pos.x, pos.y, canvas.planeDistance))
	trans.position = Vector3(npos.x, npos.y, npos.z)
	local p = trans.localPosition
	trans.localPosition = Vector3(p.x, p.y, 0)
end


--获得第一个子节点的Text组件,设置文字
function UIUtils.SetChildText(transform, text)
	local textComp = transform:GetComponentInChildren(ClassType.Text)
	textComp.text = text
end

--本次运行游戏唯一id
local setImageTask = {
	
}

function UIUtils.SetImagePath(obj, imgPath, keepNativeSize, cb)
    local taskId = ComUtils.GetUniqueID()
     local transform = obj.transform
    local instanceId = transform:GetInstanceID()
    setImageTask[instanceId] = taskId
	Globals.resMgr:LoadSprite(imgPath, 
    function(imgRes)
            if Framework.Helpers.IsObjectExist(transform) then
                if setImageTask[instanceId] ~= taskId then
                    return
                end
                local imgComp = nil
				if string.startwith(imgPath, "Atlas") then
                    imgComp = transform:GetComponent(ClassType.Image)
                    --加个报错，不好查问题
                    if(not imgComp) then
                        printerror("当前对象没有RawImage组件", obj.transform.name, obj, imgPath)
                    end
					imgComp.sprite = imgRes
                else -- texture2d
                    imgComp = transform:GetComponent(ClassType.RawImage)
                    if(not imgComp) then
                        printerror("当前对象没有RawImage组件", obj.transform.name, obj, imgPath)
                    end
                    imgComp.texture = imgRes
				end
                if keepNativeSize == true then
                    imgComp:SetNativeSize()
                end
            else
				print("ComUtils.SetImage "..imgPath .."failed")
            end
            setImageTask[instanceId] = nil
            if cb then
                cb(imgRes)
            end
		end
	)
end

function UIUtils.GetTextPreferredWidth(txtComp)
    local settings = txtComp:GetGenerationSettings(Vector2.zero)
    local width = txtComp.cachedTextGeneratorForLayout:GetPreferredWidth(txtComp.text, settings) / txtComp.pixelsPerUnit
    return width < txtComp.transform.sizeDelta.x and width or txtComp.transform.sizeDelta.x
end

function UIUtils.GetTextPreferredHeight(txtComp)
    local settings = txtComp:GetGenerationSettings(Vector2(txtComp.transform.rect.size.x, 0))
    local height = txtComp.cachedTextGeneratorForLayout:GetPreferredHeight(txtComp.text, settings) / txtComp.pixelsPerUnit
    return height
    -- return height < self.text_dialog.transform.sizeDelta.y and height or self.text_dialog.transform.sizeDelta.y
end

-- 当锚点不重合的时候可以使用
-- @param.textComp: ClassType.Text类型，文本框
-- @param.maxWidth: 文本框最大宽度（最小宽度为0，故不是设置最小宽度）
function UIUtils.GetTextPreferredWidth2(textComp, maxWidth)
    local settings = textComp:GetGenerationSettings(Vector2.zero)
    local width = textComp.cachedTextGeneratorForLayout:GetPreferredWidth(textComp.text, settings) / textComp.pixelsPerUnit
    return width < maxWidth and width or maxWidth
end
-- 当锚点不重合的时候可以使用
function UIUtils.GetTextPreferredHeight2(textComp, width)
    local settings = textComp:GetGenerationSettings(Vector2(width, 0))
    local height = textComp.cachedTextGeneratorForLayout:GetPreferredHeight(textComp.text, settings) / textComp.pixelsPerUnit
    return height
end


--根据Img图像调整rawImage宽高比
function UIUtils.SizeAdjustment(rawImage, img)
	if ObjectUtils.IsNil(rawImage) then
		return
	end
    -- rawImage.width
    local uISize = Globals.uiMgr:GetUISize()
    local screenRate = uISize.x / uISize.y
	local rectRaw = rawImage:GetComponent(ClassType.RectTransform)
	local adjustX = nil
	local adjustY = nil
	if not ObjectUtils.IsNil(img) then
		local imgRate = img.width / img.height
		local oriSize = rectRaw.rect.size
		local oriRate = oriSize.x / oriSize.y
		adjustX = uISize.x
		adjustY = uISize.x / imgRate
	else
		adjustX = uISize.x
		adjustY = uISize.y
	end
	rectRaw:SetSizeWithCurrentAnchors(RectTransform.Axis.Horizontal, adjustX)
	rectRaw:SetSizeWithCurrentAnchors(RectTransform.Axis.Vertical, adjustY)
end

-- 获取物体屏幕坐标
function UIUtils.GetScreenPoint(objTrans, camera)
    local viewport = camera:WorldToViewportPoint(objTrans.position)
    local uiSize = Globals.uiMgr:GetUISize()
    local rect = camera.rect
    local screenPoint = Vector3(uiSize.x * ((viewport.x * rect.width + rect.x)  - 0.5), uiSize.y * ((viewport.y * rect.height + rect.y) - 0.5), 0)
    return screenPoint
end
--将图片不拉伸进行缩放 保持长宽比
function UIUtils.ConvertImgToMask(rect, width, height)
    local imgWidth = rect.sizeDelta.x
    local imgHeight = rect.sizeDelta.y
    local newWidth = width
    local newHeight = height
    local widthFactor = width / imgWidth
    local heightFactor = height / imgHeight
    local scale = math.max(widthFactor, heightFactor)
    newWidth = imgWidth * scale
    newHeight = imgHeight * scale
    rect.sizeDelta = Vector2(newWidth, newHeight+1)
end

--使图片置灰
local grayMat
local loadCallBack
function UIUtils.SetGrey(image, grey)
    if grey and grayMat then
        image.material = grayMat
    elseif(not grayMat) then
        loadCallBack = loadCallBack or LuaDelegate.New()
        loadCallBack = loadCallBack + function()
            if(ObjectUtils.IsNil(image)) then
                return
            end
            image.material = grayMat
        end
        Globals.resMgr:LoadResource("Material/UIGrey", function(obj)
            grayMat = obj
            if(loadCallBack) then
                loadCallBack()
                loadCallBack = nil
            end
        end)
    else
        image.material = nil
    end
end

function UIUtils.SetEnableColor(go, enable, includeClick)
    local image = go:GetComponent(ClassType.Image)
    local rawImg = go:GetComponent(ClassType.RawImage)
    local text = go:GetComponent(ClassType.Text)
    local graphics = go:GetComponentsInChildren(ClassType.Image, true)
    local rawImgs = go:GetComponentsInChildren(ClassType.RawImage, true)
    local texts = go:GetComponentsInChildren(ClassType.Text, true)
    if(not ObjectUtils.IsNil(image)) then
        UIUtils.SetGrey(image, not enable)
    end
    if(not ObjectUtils.IsNil(rawImg)) then
        UIUtils.SetGrey(rawImg, not enable)
    end
    if(not ObjectUtils.IsNil(text)) then
        UIUtils.SetGrey(text, not enable)
    end
    for i = 0, graphics.Length - 1 do
        local graphic = graphics[i]
        UIUtils.SetGrey(graphic, not enable)
    end
    for i = 0, rawImgs.Length - 1 do
        local graphic = rawImgs[i]
        UIUtils.SetGrey(graphic, not enable)
    end
    for i = 0, texts.Length - 1 do
        local graphic = texts[i]
        UIUtils.SetGrey(graphic, not enable)
    end
    if(includeClick) then
        local btn = go:GetComponent(ClassType.Button)
        if(btn) then
            btn.interactable = enable
        end
        if(not ObjectUtils.IsNil(image)) then
            image.raycastTarget = enable
        end
    end
end

function UIUtils.IsPointerOverGameObject()
	return UnityEngine.EventSystems.EventSystem.current.IsPointerOverGameObject()
end

function UIUtils.GetCurrentSelectedGameObject()
	return UnityEngine.EventSystems.EventSystem.current.currentSelectedGameObject
end

return UIUtils