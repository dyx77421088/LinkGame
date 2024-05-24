--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:Previewer视图主逻辑
--     创建时间:2023/09/20  
--------------------------------------------------------------------------------
local PreviewerView = BaseClass("PreviewerView", UIViewBase)
local ClassData = Globals.configMgr:GetConfig("ClassData")
local ButtonItem = require (ClassData.ButtonItem)
local NumberItem = require "GameLogic.UI.Number.NumberItem"
local TextWrap = require "Common.Wrap.TextWrap"


function PreviewerView:Initialize()
	local onInstantiate = function(num)
		local parent = Globals.resMgr:LoadPlatAtlas("Atlas/previewnumber")
		local num = parent.transform:Find(num).gameObject
		return GameObject.Instantiate(num)
	end
	self.previewValue = NumberItem.New(self:GetChild("num"), nil, self)
	self.previewValue:SetInstantiateNumCallBack(onInstantiate)
	self.previewText = TextWrap.New(self:GetChild("text"))
	self.feature = self:GetChild("feature").gameObject
	self.backBtn = ButtonItem.New(self:GetChild("back"), self)
	self.backBtn:AddOnClick(self.backBtn, callback(self, "OnClickBackBtn"))
end

function PreviewerView:OnClickBackBtn()
	Globals.uiMgr:HideView("PreviewerView")
end

function PreviewerView:ShowSelf()
	self:BindEvent(LuaEvent.SmallGame.PreviewBet, "OnPreviewBet")
	Globals.gameModel:AddLock()
	Globals.gameModel:CheckPlayBet()
	LMessage:Dispatch(LuaEvent.SmallGame.IncreaseCover, self.uiName)
	Globals.pipeMgr:Send(EEvent.PipeMsg.PreviewBet, {playBet = Globals.gameModel.playBet})
end

function PreviewerView:HideSelf()
	self:UnBindAllEvent()
	Globals.gameModel:RemoveLock()
	LMessage:Dispatch(LuaEvent.SmallGame.DecreaseCover, self.uiName)
	Globals.pipeMgr:Send(EEvent.PipeMsg.GameInfo, {state = true, previewer = false})
	ComUtils.SetTimeScale(1)
end

function PreviewerView:OnPreviewBet(msg)
	local value = msg.TotalBet
	print(value)
	if value == 100000 then
		self.previewText.gameObject:SetActive(false)
		self.previewValue:SetIsPop(false)
		self.feature:SetActive(true)
	else
		self.feature:SetActive(false)
		self.previewValue:SetIsPop(true)
		local odds = value % 100000
		local score = math.reduce(odds * Globals.gameModel.playBet, 100)
		self.previewValue:SetValue(math.floor(score*Globals.gameModel.slot*Globals.gameModel.platformArg.multiplier))
		if Globals.gameModel.platformArg.bDollar then
			local format = "$%."..Globals.gameModel.platformArg.decimal.."f"
			self.previewText:SetText(string.format(format, score*Globals.gameModel.platformArg.multiplier))
			self.previewText.gameObject:SetActive(true)
		end
	end
	Globals.pipeMgr:Send(EEvent.PipeMsg.GameInfo, {state = true, previewer = true})
	ComUtils.SetTimeScale(0.5)
end


return PreviewerView