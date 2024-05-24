--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:算法界面，对比客户端和服务端的算法数据是否对的上
--     创建时间:2022/05/06 
--------------------------------------------------------------------------------
local GMAlgorithmView = BaseClass("GMAlgorithmView", UIViewBase)

function GMAlgorithmView:__ctor(cb)
	self.weight = Const.GUIWeight.GM
end

function GMAlgorithmView:__delete()

end

function GMAlgorithmView:Initialize()
    --关闭按钮
    self:AddCloseBtn("BG/closeBtn")
    self.txtServer = self:GetChild("BG/server", ClassType.Text)
	self.txtClient = self:GetChild("BG/client", ClassType.Text)
end

function GMAlgorithmView:ShowSelf()
    self:BindEvent(LuaEvent.SmallGame.DebugModel, "OnDebugModel")
    self.timer_id = Globals.timerMgr:AddTimer(callback(self, "SendGetDebugMode"), 1, 0)
    LMessage:Dispatch(LuaEvent.SmallGame.IncreaseCover, self.uiName)
end

function GMAlgorithmView:HideSelf()
    self:UnBindAllEvent()
    Globals.timerMgr:DelTimer(self.timer_id)
    LMessage:Dispatch(LuaEvent.SmallGame.DecreaseCover, self.uiName)
end

function GMAlgorithmView:SendGetDebugMode()
    Globals.pipeMgr:Send(EEvent.PipeMsg.DebugModel, {id = "GetDebugModel"})
	return true
end

function GMAlgorithmView:OnDebugModel(msg)
	if msg.id == "GetDebugModel" then
		local content = '';
		
		
		--汇总玩分数据
		if msg.dwPlayScore then
			content = content .. '总玩分:' .. msg.dwPlayScore .. " \t"
		end
		if msg.dwWinScore then
			content = content .. '总赢分:' .. msg.dwWinScore .. " \t"
		end
		content = content  .. " \n"
		
		--偏差
		if msg.dwPreviewPlayScoreError then
			content = content .. '玩分误差:' .. msg.dwPreviewPlayScoreError .. "\t"
		end
		if msg.dwPreviewWinScoreError then
			content = content .. '赢分误差:' .. msg.dwPreviewWinScoreError .. "\t"
		end
		if msg.dwFreeGameBetError then
			content = content .. '免费游戏误差:' .. msg.dwFreeGameBetError .. "\t"
		end
		content = content  .. " \n\n"
		
		--汇总次数数据
		if msg.dwTotalPlayTime then
			content = content .. '总玩次数:' .. msg.dwTotalPlayTime .. " \t"
		end
		if msg.dwAllComboTime then
			content = content .. '中奖次数:' .. msg.dwAllComboTime .. " \t"
		end
		if msg.dwLooseTime then
			content = content .. '不中奖次数:' .. msg.dwLooseTime .. " \t"
		end
		content = content  .. " \n"
		
		--普通数据
		if msg.dwNormalOpenTime then
			content = content .. '普通奖次数:' .. msg.dwNormalOpenTime .. " \t"
		end
		--全盘奖数据
		if msg.dwAllInOneTime then
			content = content .. '全盘奖次数:' .. msg.dwAllInOneTime .. " \t"
		end
		content = content  .. " \n"
		
		--免费数据
		if msg.dwFreeWinTime then
			content = content .. '免费奖次数:' .. msg.dwFreeWinTime .. " \t"
		end
		if msg.dwGiveOpenTime then
			content = content .. '赠送次数:' .. msg.dwGiveOpenTime .. " \t"
		end
		if msg.dwTotalFreeBet then
			content = content .. '免费总赔率:' .. msg.dwTotalFreeBet .. " \t"
		end
		content = content  .. " \n"
		
		--小游戏数据
		if msg.dwBonusWinTime then
			content = content .. '小游戏次数:' .. msg.dwBonusWinTime .. " \t"
		end
		if msg.dwTotalBonusBet then
			content = content .. '小游戏总赔率:' .. msg.dwTotalBonusBet .. " \t"
		end
		if msg.dwBonusWinScore then
			content = content .. '小游戏总赢分:' .. msg.dwBonusWinScore .. " \t"
		end
		content = content  .. " \n"
		
		--公共游戏数据
		if msg.dwLinkWinTime then
			content = content .. '公共游戏次数:' .. msg.dwLinkWinTime .. " \t"
		end
		if msg.dwTotalLinkBet then
			content = content .. '公共游戏总赔率:' .. msg.dwTotalLinkBet .. " \t"
		end
		if msg.dwLinkWinScore then
			content = content .. '公共游戏总赢分:' .. msg.dwLinkWinScore .. " \t"
		end
		content = content  .. " \n\n"
		
		--算法彩金调试信息
		if msg.dwLocalJpAccum then
			content = content .. '算法累计到本地彩金中分值:' .. msg.dwLocalJpAccum .. " \t"
		end
		if msg.dwLocalJpPool then
			content = content .. '实际累计到本地彩金中的币值:' .. msg.dwLocalJpPool .. " \t"
		end
		if msg.dwCenterJpAccum then
			content = content .. '算法累计到中央彩金中分值:' .. msg.dwCenterJpAccum .. "\n"
		end
		
		--前端彩金调试信息
		if msg.jackpot then
			--中心大彩金
			local exists = false;
			for _, v in pairs(msg.jackpot) do
				if v.jpType == 2 and v.id == 1 then
					content = content .. '中心大彩金 \t 次数:' .. v.count .. " \t " .. '分数:' .. v.score .. "\n"
					exists = true
					break
				end
			end
			if not exists then
				content = content .. '中心大彩金 \t 次数:' .. 0 .. " \t " .. '分数:' .. 0 .. "\n"
			end
			--中心小彩金
			exists = false
			for _, v in pairs(msg.jackpot) do
				if v.jpType == 2 and v.id == 2 then
					content = content .. '中心小彩金 \t 次数:' .. v.count .. " \t " .. '分数:' .. v.score .. "\n"
					exists = true
					break
				end
			end
			if not exists then
				content = content .. '中心小彩金 \t 次数:' .. 0 .. " \t " .. '分数:' .. 0 .. "\n"
			end
			--本地大彩金
			exists = false
			for _, v in pairs(msg.jackpot) do
				if v.jpType == 1 and v.id == 3 then
					content = content .. '本地大彩金 \t 次数:' .. v.count .. " \t " .. '分数:' .. v.score .. "\n"
					exists = true
					break
				end
			end
			if not exists then
				content = content .. '本地大彩金 \t 次数:' .. 0 .. " \t " .. '分数:' .. 0 .. "\n"
			end
			--本地中彩金
			exists = false
			for _, v in pairs(msg.jackpot) do
				if v.jpType == 1 and v.id == 2 then
					content = content .. '本地中彩金 \t 次数:' .. v.count .. " \t " .. '分数:' .. v.score .. "\n"
					exists = true
					break
				end
			end
			if not exists then
				content = content .. '本地中彩金 \t 次数:' .. 0 .. " \t " .. '分数:' .. 0 .. "\n"
			end
			--本地小彩金
			exists = false
			for _, v in pairs(msg.jackpot) do
				if v.jpType == 1 and v.id == 1 then
					content = content .. '本地小彩金 \t 次数:' .. v.count .. " \t " .. '分数:' .. v.score .. "\n"
					exists = true
					break
				end
			end
			if not exists then
				content = content .. '本地小彩金 \t 次数:' .. 0 .. " \t " .. '分数:' .. 0 .. "\n"
			end
			--汇总
			for _, v in pairs(msg.jackpot) do
				if v.jpType == 0 and v.id == 0 then
					content = content .. '彩金总共 \t\t 次数:' .. v.count .. " \t " .. '分数:' .. v.score .. "\n"
					break
				end
			end
		end
		
		self.txtServer.text = content
		
		
		content = ''
		--前端分数
		content = content .. '前端总玩分:' .. Globals.gmModel.playScore .. "\t" .. '前端总赢分:' .. Globals.gmModel.winScore
		content = content .. "\n"
		
		self.txtClient.text = content
	end
end

return GMAlgorithmView