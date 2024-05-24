--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:引用的C#类型
--     创建时间:2021/09/24 
--------------------------------------------------------------------------------
--导不出来的类直接用字符串，参考Scrollbar
ClassType = {
}

local define = {
	--UnityEngine
	Transform = "typeof(UnityEngine.Transform)",
	Component = "typeof(UnityEngine.Component)",
	SpriteRenderer = "typeof(UnityEngine.SpriteRenderer)",
	Renderer = "typeof(UnityEngine.Renderer)",
	SkinnedMeshRenderer = "typeof(UnityEngine.SkinnedMeshRenderer)",
	LineRenderer = "typeof(UnityEngine.LineRenderer)",
	Material = "typeof(UnityEngine.Material)",

	AudioSource = "typeof(UnityEngine.AudioSource)",
	AudioClip = "typeof(UnityEngine.AudioClip)",
	VideoClip = "typeof(UnityEngine.Video.VideoClip)",
	VideoPlayer = "typeof(UnityEngine.Video.VideoPlayer)",

	Animator = "typeof(UnityEngine.Animator)",
	AnimatorStateInfo = "typeof(UnityEngine.AnimatorStateInfo)",
	AnimationCurve = "typeof(UnityEngine.AnimationCurve)",
	AnimcurveListWrapper = "typeof(UnityEngine.AnimcurveListWrapper)",
	AnimationClip = "typeof(UnityEngine.AnimationClip)",
	Light = "typeof(UnityEngine.Light)",
	Camera = "typeof(UnityEngine.Camera)",
	GameObject = "typeof(UnityEngine.GameObject)",
	Canvas = "typeof(UnityEngine.Canvas)",
	RectTransform = "typeof(UnityEngine.RectTransform)",
	EventTrigger = "typeof(UnityEngine.EventSystems.EventTrigger)",
	Behaviour = "typeof(UnityEngine.Behaviour)",
	MonoBehaviour = "typeof(UnityEngine.MonoBehaviour)",
	TrackedReference = "typeof(UnityEngine.TrackedReference)",
	Physics = "typeof(UnityEngine.Physics)",
	Time = "typeof(UnityEngine.Time)",
	WWW = "typeof(UnityEngine.WWW)",
	AssetBundle = "typeof(UnityEngine.AssetBundle)",

	TextAsset = "typeof(UnityEngine.TextAsset)",
	Texture = "typeof(UnityEngine.Texture)",
	Texture2D = "typeof(UnityEngine.Texture2D)",
	RenderTexture = "typeof(UnityEngine.RenderTexture)",
	Screen = "typeof(UnityEngine.Screen)",
	Resources = "typeof(UnityEngine.Resources)",
	TextureFormat = "typeof(UnityEngine.TextureFormat)",
	Rect = "typeof(UnityEngine.Rect)",
	Vector3 = "typeof(UnityEngine.Vector3)",
	MeshRenderer = "typeof(UnityEngine.MeshRenderer)",
	NavMeshAgent = "typeof(UnityEngine.AI.NavMeshAgent)",
	NavMeshObstacle = "typeof(UnityEngine.AI.NavMeshObstacle)",
	CanvasGroup = "typeof(UnityEngine.CanvasGroup)",
	Collider = "typeof(UnityEngine.Collider)",
	BoxCollider = "typeof(UnityEngine.BoxCollider)",
	MeshCollider = "typeof(UnityEngine.MeshCollider)",
	CapsuleCollider = "typeof(UnityEngine.CapsuleCollider)",
	SphereCollider = "typeof(UnityEngine.SphereCollider)",
	Collision = "typeof(UnityEngine.Collision)",
	Gizmos = "typeof(UnityEngine.Gizmos)",
	Rigidbody = "typeof(UnityEngine.Rigidbody)",
	ParticleSystemRenderer = "typeof(UnityEngine.ParticleSystemRenderer)",
	ShaderVariantCollection = "typeof(UnityEngine.ShaderVariantCollection)",
	Shader = "typeof(UnityEngine.Shader)",
	RuntimeAnimatorController = "typeof(UnityEngine.RuntimeAnimatorController)",
	CharacterController = "typeof(UnityEngine.CharacterController)",
	--UI
	Text = "typeof(UnityEngine.UI.Text)",
	ButtonClickedEvent = "typeof(UnityEngine.UI.Button.ButtonClickedEvent)",
	UnityEventBase = "typeof(UnityEngine.Events.UnityEventBase)",
	UnityEvent = "typeof(UnityEngine.Events.UnityEvent)",
	Button = "typeof(UnityEngine.UI.Button)",
	Image = "typeof(UnityEngine.UI.Image)",
	Sprite = "typeof(UnityEngine.UI.Sprite)",
	Graphic = "typeof(UnityEngine.UI.Graphic)",
	InputField = "typeof(UnityEngine.UI.InputField)",
	DoubleTapInputField = "typeof(UnityEngine.UI.DoubleTapInputField)",
	InputFieldScaler = "typeof(UnityEngine.UI.InputFieldScaler)",
	GraphicRaycaster = "typeof(UnityEngine.UI.GraphicRaycaster)",
	HorizontalLayoutGroup = "typeof(UnityEngine.UI.HorizontalLayoutGroup)",
	VerticalLayoutGroup = "typeof(UnityEngine.UI.VerticalLayoutGroup)",
	GridLayoutGroup = "typeof(UnityEngine.UI.GridLayoutGroup)",
	GridLayout = "typeof(UnityEngine.GridLayout)",
	Toggle = "typeof(UnityEngine.UI.Toggle)",
	ToggleGroup = "typeof(UnityEngine.UI.ToggleGroup)",
	ToggleEvent = "typeof(UnityEngine.UI.Toggle.ToggleEvent)",
	ContentSizeFitter = "typeof(UnityEngine.UI.ContentSizeFitter)",
	ScrollRect = "typeof(UnityEngine.UI.ScrollRect)",
	Rect = "typeof(UnityEngine.Rect)",
	ScrollRectEvent = "typeof(UnityEngine.UI.ScrollRect.ScrollRectEvent)",
	Scrollbar = "typeof(UnityEngine.UI.Scrollbar)",
	RawImage = "typeof(UnityEngine.UI.RawImage)",
	CanvasScaler = "typeof(UnityEngine.UI.CanvasScaler)",
	Slider = "typeof(UnityEngine.UI.Slider)",
	SliderEvent = "typeof(UnityEngine.UI.Slider.SliderEvent)",
	Dropdown = "typeof(UnityEngine.UI.Dropdown)",
	DropdownEvent = "typeof(UnityEngine.UI.Dropdown.DropdownEvent)",
	OptionData = "typeof(UnityEngine.UI.Dropdown.OptionData)",
	OptionDataList = "typeof(UnityEngine.UI.Dropdown.OptionDataList)",
	LayoutElement = "typeof(UnityEngine.UI.LayoutElement)",
	Shadow = "typeof(UnityEngine.UI.Shadow)",
	RectMask2D = "typeof(UnityEngine.UI.RectMask2D)",
	EventSystem = "typeof(UnityEngine.EventSystems.EventSystem)",
	Mask = "typeof(UnityEngine.UI.Mask)",
	ParticleSystem = "typeof(UnityEngine.ParticleSystem)",
	--PostProcess
	PostProcessLayer = "typeof(UnityEngine.Rendering.PostProcessing.PostProcessLayer)",
	PostProcessVolume = "typeof(UnityEngine.Rendering.PostProcessing.PostProcessVolume)",
	--Spine
	SkeletonAnimation = "typeof(Spine.Unity.SkeletonAnimation)",
	SkeletonAnimationState = "typeof(Spine.AnimationState)",
	SkeletonGraphic = "typeof(Spine.Unity.SkeletonGraphic)",
	--SWS
	PathRenderer = "typeof(SWS.SkinnedMeshRenderer)",
	PathManager = "typeof(SWS.PathManager)",
	BezierPathManager = "typeof(SWS.BezierPathManager)",
	SplineMove = "typeof(SWS.splineMove)",
	--脚本
	LuaEventTrigger = "typeof(LuaEventTrigger)",
	DynLoadManager = "typeof(DynLoadManager)",
	PostProcessEffect = "typeof(PostProcessEffect)",
	CurveMovement = "typeof(CurveMovement)",
}

setmetatable(ClassType, {__index = function(t, k)
	local v = rawget(ClassType, k)
	if not v then
		local s = define[k]
		if s then
			v = load("return " .. s)()
			if v then
				rawset(ClassType, k, v)
			else
			-- if not table.indexof(ClassType.nullable, k) then
				error(k .. " Can not find is CS")
			-- end
			end
		else
			error(k.." not define in ClassType.lua")
		end
	end
	return v
end})

return ClassType