--[[ 
	scene 场景中的 彩金得分控制
 ]]
 local SceneJackpotView = BaseClass("SceneJackpotView", UIItem)
 local NumberItem = require "GameLogic.UI.Number.NumberItem"
 local ConfigData = Globals.configMgr:GetConfig("SlotData")
 local ClassData = Globals.configMgr:GetConfig("ClassData")

------------------------------------------初始化相关的-------------------------------------------------------
function SceneJackpotView:__delete()

end
function SceneJackpotView:__ctor(parent, baseView)
	self:InitItem(parent, nil, baseView)
end
local jackpotNumber = {"jackpotNumber/mini/", "jackpotNumber/minor/", "jackpotNumber/major/", "jackpotNumber/mega/", "jackpotNumber/grand/"}
function SceneJackpotView:Initialize()
	local index = 1
	local process = function(tran)
		local gameObject, transform = tran.gameObject, tran.transform
		G_printerror("是否为空", transform == nil)
		gameObject:SetActive(true)
		local num = NumberItem.New(transform:GetChild(0), transform:GetChild(0):GetChild(0).gameObject, self.mBaseView)
		num:SetAtlasParam(ConfigData.atlasName, jackpotNumber[(index - 1) % #jackpotNumber + 1])
		num.gameObject:SetActive(false)
		index = index + 1
		return {transform = transform, rectTransform = transform:GetComponent(ClassType.RectTransform), 
				gameObject = gameObject, num = num, particle = transform:Find("effect"):GetComponent(ClassType.ParticleSystem)
		}
	end
	self.jackpots = TransformUtils.GetAllChilds(self.transform, process)
end
function SceneJackpotView:OnLoadObject(arguments, object)
	
end

function SceneJackpotView:Move(jackpotIndex, pos, callBk)
	self.jackpotIndex = math.clamp(jackpotIndex, 1, 5) -- 5种彩金
	local transform = self.jackpots[self.jackpotIndex].rectTransform
	-- 记录一下原始的位置
	self.pos = transform.position
	self.scale = transform.localScale
	G_printerror("我保存了这个缩放了", self.scale)
	
	transform.localScale = Vector3(0, 0, 0)
	transform:DOMove(pos, ConfigData.jackpotMoveTime)
	transform:DOScale(Vector3(1.2, 1.2, 1.2), ConfigData.jackpotMoveTime):SetEase(EaseType.OutQuad):OnComplete(callBk)

	-- 暂时不移动了
	-- callBk()
end
function SceneJackpotView:Hide(jackpotId, callBk)
	jackpotId = self.jackpotIndex or jackpotId
	if not jackpotId then
		for index, jackpot in ipairs(self.jackpots) do
			jackpot.num.gameObject:SetActive(false)
			-- jackpot.particle:Stop()
		end
		if callBk then callBk() end
	elseif not self.pos then
		self.jackpots[jackpotId].num.gameObject:SetActive(false)
		if callBk then callBk() end
	else
		self.jackpots[jackpotId].num.gameObject:SetActive(false)
		-- self.jackpots[jackpotId].particle:Stop()

		local transform = self.jackpots[jackpotId].rectTransform
		transform:DOMove(self.pos, ConfigData.jackpotMoveTime)
		G_printerror("这个位置的缩放是", self.scale)
		transform:DOScale(self.scale, 3):SetEase(EaseType.OutQuad):OnComplete(callBk)
	end
end
-- function SceneJackpotView:Play(jackpotIndex, odds, callBk)
function SceneJackpotView:Play(arguments)
	G_printerror("arguments = ", table.serialize(arguments))
	local startScore = math.floor(arguments.startScore * Globals.gameModel.slot * Globals.gameModel.platformArg.multiplier)
	local endScore = math.floor(arguments.endScore * Globals.gameModel.slot * Globals.gameModel.platformArg.multiplier)
	G_printerror("开始", startScore, endScore)
	self.jackpotIndex = math.clamp(arguments.jackpotId, 1, 5) -- 5种彩金
	-- self.jackpots[self.jackpotIndex].particle:Play()
	self.jackpots[self.jackpotIndex].num.gameObject:SetActive(true)
	-- 滚分
	self.jackpots[self.jackpotIndex].num:ScrollNum(startScore, endScore, 0, ConfigData.jackpotScrollTime):OnComplete(function ()
		-- 滚分完成之后数字要缩放一下
		self.jackpots[self.jackpotIndex].num.transform:DOScale(1.5, 0.5):OnComplete(function()
			self.jackpots[self.jackpotIndex].num.transform:DOScale(1, 0.2):OnComplete(function()
				arguments.callBk()
			end)
		end)
		
	end)
end
return SceneJackpotView
