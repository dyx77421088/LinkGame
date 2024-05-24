--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:加载界面
--     创建时间:2022/04/23 
--------------------------------------------------------------------------------
local NumberItem = require "GameLogic.UI.Number.NumberItem"
local LoadingView = BaseClass("LoadingView", UIViewBase)

function LoadingView:__ctor()
	self.weight = Const.GUIWeight.Loading
end

function LoadingView:__delete()
end

function LoadingView:Initialize()
    print("开始加载本地Loading...")
	self.root = self:GetChild("root")
	self.root.gameObject:SetActive(true)
	self.loading = self:GetChild("root/loading", ClassType.Text)
	self.loading.text = LanguageUtils.Translate("加载中...")
	self.percent = self:GetChild("root/percent", ClassType.Text)
end

function LoadingView:ShowSelf()
	self:SetProgress(0)
	LMessage:Dispatch(LuaEvent.SmallGame.IncreaseCover, self.uiName)
end

function LoadingView:HideSelf()
	LMessage:Dispatch(LuaEvent.SmallGame.DecreaseCover, self.uiName)
end

function LoadingView:SetProgress(val)
	self.percent.text = string.ToPercentString(val)
end

return LoadingView