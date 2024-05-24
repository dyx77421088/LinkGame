--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:用来处理摄像机
--     创建时间:2023/09/20  
--------------------------------------------------------------------------------
local CameraMgr = Singleton("CameraMgr")


function CameraMgr:__ctor()
	self.uiCamera = UnityEngine.Camera.main
	
	local camera = GameObject.Find("Camera")
	if not camera then
		camera = GameObject.New("Camera", ClassType.Camera)
	end
	camera.transform.localPosition = Vector3(0, 0, 10000)
	camera:SetActive(false)
	self.camera = camera:GetComponent(ClassType.Camera)
	
	local modelRender = GameObject.Find("ModelRender")
	if not modelRender then
		modelRender = GameObject.New("ModelRender")
	end
	self.modelRender = modelRender.transform
	self.modelRender.localPosition = Vector3(0, 0, 10000)
end

function CameraMgr:__delete()
	self:ResetUICamera()
	GameObject.Destroy(self.renderTexture)
	GameObject.Destroy(self.camera.gameObject)
	GameObject.Destroy(self.modelRender.gameObject)
end

function CameraMgr:SetUICamera(clearFlags, orthographic, fieldOfView, farClipPlane, ...)
	--备份设置
	self.backConfig = {
		clearFlags = self.uiCamera.clearFlags,
		orthographic = self.uiCamera.orthographic,
		fieldOfView = self.uiCamera.fieldOfView,
		farClipPlane = self.uiCamera.farClipPlane,
		cullingMask = self.uiCamera.cullingMask,
	}
	
	self.uiCamera.clearFlags = clearFlags
	self.uiCamera.orthographic = orthographic
	self.uiCamera.fieldOfView = fieldOfView
	self.uiCamera.farClipPlane = farClipPlane
	self.uiCamera.cullingMask = LayerUtils.GetLayerMask(...)
end

function CameraMgr:ResetUICamera()
	if self.backConfig then
		self.uiCamera.clearFlags = self.backConfig.clearFlags
		self.uiCamera.orthographic = self.backConfig.orthographic
		self.uiCamera.fieldOfView = self.backConfig.fieldOfView
		self.uiCamera.farClipPlane = self.backConfig.farClipPlane
		self.uiCamera.cullingMask = self.backConfig.cullingMask
	end
end

function CameraMgr:InitCamera(texture, fieldOfView, withOutTexture)
    local RectTransform = texture.rectTransform
    local zwidth = RectTransform.rect.width
    local zheight = RectTransform.rect.height
    local wRadio = 2048 / zwidth
    local hRadio = 2048 / zheight
    local maxRadio = math.min(wRadio, hRadio)
    local cameraRadio = zwidth / zheight
    self.camera.farClipPlane = 200
    self.camera.cullingMask =  LayerUtils.GetLayerMask(LayerUtils.Character)
    self.camera.backgroundColor = Color.New(0,0,0,0)
    self.camera.allowHDR = false
    self.camera.allowMSAA = false
    self.camera.fieldOfView = fieldOfView
    self.renderTexture = false
    if not withOutTexture then
        self.camera.clearFlags = UnityEngine.CameraClearFlags.SolidColor
        self.camera.aspect = cameraRadio
        self.renderTexture = UnityEngine.RenderTexture.New(zwidth *maxRadio, zheight *maxRadio, 24, UnityEngine.RenderTextureFormat.ARGB32)
        self.renderTexture.useMipMap = false
        self.renderTexture.anisoLevel = 0
        self.camera.targetTexture = self.renderTexture
        texture.texture = self.renderTexture
    else
        self.camera.clearFlags = UnityEngine.CameraClearFlags.Depth
        self.camera.depth = 1
    end
	self.camera.gameObject:SetActive(true)
end

function CameraMgr:GetUICamera()
	return self.uiCamera
end

function CameraMgr:GetCamera()
	return self.camera
end

function CameraMgr:GetRenderTexture()
	return self.renderTexture
end

function CameraMgr:GetModelRender()
	return self.modelRender
end


return CameraMgr