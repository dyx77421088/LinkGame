--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:场景视图逻辑
--     创建时间:2023/09/20  
--------------------------------------------------------------------------------
local SceneView = BaseClass("SceneView", UIItem)


function SceneView:__ctor(parent, baseView)
	self:InitItem(parent, nil, baseView)
end

function SceneView:__delete()
	self:PushWithTags()
end

function SceneView:Initialize()
	self:PopWithTags()
	LMessage:Dispatch(LuaEvent.Loading.AddLoaded, 1)
end

--用Tags拿取节点
function SceneView:PopWithTags()
	self.tags = {}
	local logo = GameObject.FindGameObjectWithTag("Logo")
	if logo then
		local rootTrans = logo.transform:Find("root")
		local position = rootTrans.localPosition
		local logoTrans = self.logo or self.transform
		rootTrans:SetParent(logoTrans)
		TransformUtils.NormalizeTrans(rootTrans)
		rootTrans.localPosition = position
		self.tags["Logo"] = rootTrans
	end
	
	local jackpot = GameObject.FindGameObjectWithTag("Jackpot")
	if jackpot then
		local rootTrans = jackpot.transform:Find("root")
		local position = rootTrans.localPosition
		local logoTrans = self.jackpot or self.transform
		rootTrans:SetParent(logoTrans)
		TransformUtils.NormalizeTrans(rootTrans)
		rootTrans.localPosition = position
		self.tags["Jackpot"] = rootTrans
	end
end

--用Tags放回节点
function SceneView:PushWithTags()
	if self.tags then
		for k, v in pairs(self.tags) do
			local position = v.localPosition
			local go = GameObject.FindGameObjectWithTag(k)
			if go then
				v:SetParent(go.transform)
				TransformUtils.NormalizeTrans(v)
				v.localPosition = position
			end
		end
	end
end

function SceneView:OnIncreaseCover(...)
	
end

function SceneView:OnDecreaseCover(...)
	
end

function SceneView:OnUIEvent(...)
	
end

function SceneView:OnPrepare(...)
	
end

function SceneView:OnOneRound()
	
end

function SceneView:OnReveal(revealType, ...)
	--中奖前场景表现
	if revealType == Const.RevealType.Scene then
		self:RevealScene(...)
	--中奖时场景表现
	elseif revealType == Const.RevealType.Result then
		self:RevealResult(...)
	--特效时场景表现
	elseif revealType == Const.RevealType.Effect then
		self:RevealEffect(...)
	--切换场景
	elseif revealType == Const.RevealType.Switch then
		self:RevealSwitch(...)
	--结束时场景表现
	elseif revealType == Const.RevealType.Finish then
		self:RevealFinish(...)
	end
end

function SceneView:RevealScene(...)
	
end

function SceneView:RevealResult(...)
	
end

function SceneView:RevealEffect(...)
	
end

function SceneView:RevealSwitch(...)
	
end

function SceneView:RevealFinish(...)
	
end

function SceneView:OnNumerical(...)
	
end


return SceneView