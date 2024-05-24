--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:Denom视图主逻辑
--     创建时间:2023/09/20  
--------------------------------------------------------------------------------
local DenomView = BaseClass("DenomView", UIViewBase)
local NumberItem = require "GameLogic.UI.Number.NumberItem"
local ButtonItem = require "GameLogic.Module.Slot.Common.ButtonItem"
local values = {"1D", "2D", "5D", "10D", "1C"}


function DenomView:Initialize()
	local onInstantiate = function(num)
		local parent = Globals.resMgr:LoadPlatAtlas("Atlas/denomnumber")
		local num = parent.transform:Find(num).gameObject
		return GameObject.Instantiate(num)
	end
	
	local keys = TransformUtils.GetAllChilds(self:GetChild("keys"))
	for index, key in pairs(keys) do
		local keyValue = NumberItem.New(key:GetChild(0), nil, self)
		keyValue:SetInstantiateNumCallBack(onInstantiate)
		keyValue:SetValue(values[index])
		
		local keyBtn = ButtonItem.New(key, self)
		keyBtn:AddOnClick(keyBtn, callback(self, "OnClickBtn", index))
	end
end

function DenomView:OnClickBtn(index)
	Globals.gameModel:SetSlot(index)
	Globals.uiMgr:HideView("DenomView")
end

function DenomView:ShowSelf()
	Globals.gameModel:AddLock()
	LMessage:Dispatch(LuaEvent.SmallGame.IncreaseCover, self.uiName)
	Globals.pipeMgr:Send(EEvent.PipeMsg.GameInfo, {state = true, denom = true})
	ComUtils.SetTimeScale(0.5)
end

function DenomView:HideSelf()
	Globals.gameModel:RemoveLock()
	LMessage:Dispatch(LuaEvent.SmallGame.DecreaseCover, self.uiName)
	Globals.pipeMgr:Send(EEvent.PipeMsg.GameInfo, {state = true, denom = false})
	ComUtils.SetTimeScale(1)
end


return DenomView