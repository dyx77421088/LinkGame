--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:公共游戏视图逻辑
--     创建时间:2024/03/30  
--------------------------------------------------------------------------------
local LinkView = BaseClass("LinkView", UIViewBase)

function LinkView:__ctor()
	self.weight = Const.GUIWeight.Main
	self.isDefalut = true
	self.roundOdds = 0
end

function LinkView:Initialize()
	--加载公共资源
	local viewPrefab = Globals.resMgr:LoadPlatAtlas("Object/linkview")
	if viewPrefab then
		local gameObject = GameObject.Instantiate(viewPrefab, self.transform)
		gameObject.name = "root"
		gameObject:SetActive(true)
		TransformUtils.NormalizeTrans(gameObject.transform)
	end
	self:InitScene()
end

function LinkView:InitScene()
	
end

--保存数据
function LinkView:SaveData()
	local data = {}
	Globals.pipeMgr:Send(EEvent.PipeMsg.GameEvent, {id = "RoundData", gameId = Globals.gameModel.platformArg.gameId, gameResult = data})
end

--本局结束
function LinkView:EndRound()
	--核对算法
	if not Globals.gameModel.platformArg.bLocalMode then
		if self.roundOdds ~= self.oneRound.algorithm.LinkBet then
			printerror(string.format("赔率出错! 前端赔率: %d, 算法赔率: %d", self.roundOdds, self.oneRound.algorithm.LinkBet))
			if _ErrorPause then
				ComUtils.SetTimeScale(0)
			end
		end
	end
	Globals.pipeMgr:Send(EEvent.PipeMsg.EndRound, {gameId = Globals.gameModel.platformArg.gameId})
end


return LinkView