--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:用来统一管理屏幕后处理
--     创建时间:2023/12/10  
--------------------------------------------------------------------------------
local ProcessMgr = Singleton("ProcessMgr")
local TransformUtils = TransformUtils


function ProcessMgr:__ctor()
	local uiCamera = UnityEngine.Camera.main
	self.postProcLayer = uiCamera.transform:GetComponent(ClassType.PostProcessLayer)
	if self.postProcLayer then
		self.postProcLayer.enabled = false
	end
	self.postProEffect = uiCamera.transform:GetComponent(ClassType.PostProcessEffect)
	self.postProcVolumes = {}
	self.customMaterials = {}
end

function ProcessMgr:__delete()
	if self.postProcLayer then
		self.postProcLayer.enabled = false
	end
	if self.postProEffect then
		self.postProEffect:Stop()
	end
	for _, v in pairs(self.postProcVolumes) do
		v.isGlobal = false
	end
	if self.gameObject then
		GameObject.Destroy(self.gameObject)
	end
	if self.canvas then
		GameObject.Destroy(self.canvas)
	end
end

function ProcessMgr:Initialize()
	Globals.resMgr:LoadResource("Prefab/PostProcess/PostProcess", function(obj)
		if self.gameObject == nil then
			self.gameObject = GameObject.Instantiate(obj)
			self.transform = self.gameObject.transform
		end
		local childs = TransformUtils.GetAllChilds(self.transform:Find("Processing"))
		for k, v in ipairs(childs) do
			local volume = v:GetComponent(ClassType.PostProcessVolume)
			volume.isGlobal = false
			self.postProcVolumes[v.name] = volume
		end
		local dynLoadManager = self.transform:Find("Custom"):GetComponent(ClassType.DynLoadManager)
		if dynLoadManager then
			for i = 0, dynLoadManager.Materials.Length - 1 do
				local mate = dynLoadManager.Materials[i]
				self.customMaterials[mate.name] = mate
			end
		end
	end)
end

--创建不进行后处理的画布
function ProcessMgr:GetNoPostProcCanvas()
	if not self.canvas then
		self.canvas = GameObject.New("NoPostProcessCanvas", ClassType.Canvas, ClassType.CanvasScaler, ClassType.GraphicRaycaster)
		local canvas = self.canvas:GetComponent(ClassType.Canvas)
		canvas.renderMode = RenderMode.ScreenSpaceOverlay
		canvas.sortingOrder = 1
		local canvasScaler = self.canvas:GetComponent(ClassType.CanvasScaler)
		local uiCanvasScaler = Globals.uiMgr:GetCanvasScaler()
		canvasScaler.uiScaleMode = uiCanvasScaler.uiScaleMode
		canvasScaler.referenceResolution = uiCanvasScaler.referenceResolution
		canvasScaler.screenMatchMode = uiCanvasScaler.screenMatchMode
	end
	
	return self.canvas.transform
end

function ProcessMgr:OpenProcess(volumeName, callBack)
	local volume = self.postProcVolumes[volumeName]
	if self.postProcLayer and volume then
		self.postProcLayer.enabled = true
		volume.isGlobal = true
		if callBack then
			callBack(volume)
		end
	end
end

function ProcessMgr:CloseProcess(volumeName)
	local volume = self.postProcVolumes[volumeName]
	if self.postProcLayer and volume then
		self.postProcLayer.enabled = false
		volume.isGlobal = false
	end
end

function ProcessMgr:PlayProcess(mateName, callBack)
	local material = self.customMaterials[mateName]
	if material then
		self.postProEffect:Play(material)
		if callBack then
			callBack(material)
		end
	end
end

function ProcessMgr:StopProcess()
	if self.postProEffect then
		self.postProEffect:Stop()
	end
end


return ProcessMgr