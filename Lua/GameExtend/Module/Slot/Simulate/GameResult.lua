--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:模拟生成游戏结果
--     创建时间:2023/09/20  
--------------------------------------------------------------------------------
local GameResult = require "GameLogic.Module.Slot.Simulate.GameResult"
GameResult = BaseClass("GameResultEditor", GameResult)


--赠送局
function GameResult:GenerateForGive()
	local container = {
		-- '{"OpenType":1,"ResultType":0,"IDVec":[],"Matrix":[12,14,5,0,8,8,0,5,0,8,2,2,5,5,8],"WildData":[1,0,1,0,1],"WheelBet":20000 ,"TotalBet":0}', -- bigwin
		-- '{"OpenType":1,"ResultType":0,"IDVec":[],"Matrix":[12,14,5,0,8,8,12,5,12,8,2,2,5,5,8],"WildData":[1,0,1,0,1],"WheelBet":20000 ,"TotalBet":0}', -- bigwin之后免费
		-- '{"OpenType":1,"ResultType":0,"IDVec":[],"Matrix":[14,12,5,0,8,8,0,5,0,8,2,2,5,5,8],"WildData":[1,0,1,0,1],"WheelBet":10000 ,"TotalBet":0}', -- mini
		'{"OpenType":1,"ResultType":0,"IDVec":[],"Matrix":[14,12,5,0,8,8,0,5,0,8,2,2,5,5,8],"WildData":[1,0,1,0,1],"WheelBet":50000 ,"TotalBet":0}', -- grand
		-- '{"OpenType":1,"ResultType":0,"IDVec":[],"Matrix":[12,12,12,0,8,8,0,5,0,8,2,12,5,12,8],"WildData":[0,0,0,0,0],"TotalBet":0}', -- 赠送局
		-- '{"OpenType":1,"ResultType":0,"IDVec":[],"Matrix":[0,0,0,0,0,1,1,1,1,1,0,6,1,1,11],"WildData":[0,0,0,0,0],"TotalBet":0}', -- 普通得分
		-- '{"OpenType":1,"ResultType":0,"IDVec":[],"Matrix":[0,0,0,0,0,1,1,1,1,1,0,6,1,1,11],"WildData":[1,0,0,0,0],"TotalBet":0}', -- 普通得分
		-- '{"OpenType":1,"ResultType":0,"IDVec":[],"Matrix":[0,0,0,0,0,1,1,1,1,1,0,6,1,1,11],"WildData":[0,1,0,0,0],"TotalBet":0}', -- 普通得分
		-- '{"OpenType":1,"ResultType":0,"IDVec":[],"Matrix":[0,0,0,0,0,1,1,1,1,1,0,6,1,1,11],"WildData":[0,0,1,0,0],"TotalBet":0}', -- 普通得分
		-- '{"OpenType":1,"ResultType":0,"IDVec":[],"Matrix":[0,0,0,0,0,1,1,1,1,1,0,6,1,1,11],"WildData":[0,0,0,1,0],"TotalBet":0}', -- 普通得分
		-- '{"OpenType":1,"ResultType":0,"IDVec":[],"Matrix":[0,0,0,0,0,1,1,1,1,1,0,6,1,1,11],"WildData":[0,0,0,0,1],"TotalBet":0}', -- 普通得分


		-- '{"OpenType":1,"ResultType":0,"IDVec":[],"Matrix":[2,5,5,0,8,8,0,5,0,8,2,2,5,5,8],"WildData":[1,0,0,0,0],"TotalBet":0}',
		-- '{"OpenType":1,"ResultType":0,"IDVec":[],"Matrix":[4,8,4,8,1,0,1,1,0,8,4,0,11,0,8],"WildData":[0,1,0,0,0],"TotalBet":0}',
		-- '{"OpenType":1,"ResultType":0,"IDVec":[],"Matrix":[3,1,8,11,2,3,3,8,2,1,2,8,8,1,3],"WildData":[0,0,1,0,0],"TotalBet":0}',
		-- '{"OpenType":1,"ResultType":0,"IDVec":[],"Matrix":[1,4,11,4,1,6,2,2,2,2,6,1,2,6,1],"WildData":[0,0,0,1,0],"TotalBet":0}',
		-- '{"OpenType":1,"ResultType":0,"IDVec":[],"Matrix":[3,7,4,11,4,4,2,3,4,7,2,7,3,2,3],"WildData":[0,0,0,0,1],"TotalBet":0}',
		-- '{"OpenType":1,"ResultType":0,"IDVec":[],"Matrix":[1,4,1,3,1,2,4,1,2,3,4,3,2,3,4],"WildData":[0,0,0,0,0],"TotalBet":0}',
		-- '{"OpenType":1,"ResultType":0,"IDVec":[],"Matrix":[1,6,8,6,4,11,6,4,8,4,1,8,4,1,11],"WildData":[0,0,0,0,0],"TotalBet":0}',
		-- '{"OpenType":1,"ResultType":0,"IDVec":[],"Matrix":[5,0,7,5,0,5,0,11,7,5,8,0,5,8,11],"WildData":[0,0,0,0,0],"TotalBet":0}',
		-- '{"OpenType":1,"ResultType":0,"IDVec":[],"Matrix":[1,4,6,1,4,0,4,6,6,4,0,0,6,1,1],"WildData":[0,0,0,0,0],"TotalBet":0}',
		-- '{"OpenType":1,"ResultType":0,"IDVec":[],"Matrix":[2,6,5,2,7,7,5,6,2,6,7,5,7,5,6],"WildData":[0,0,0,0,0],"TotalBet":0}',
		-- '{"OpenType":1,"ResultType":0,"IDVec":[],"Matrix":[6,4,5,11,4,5,1,6,5,4,5,4,1,4,6],"WildData":[0,0,0,0,0],"TotalBet":0}',
		-- '{"OpenType":1,"ResultType":0,"IDVec":[],"Matrix":[5,4,7,8,8,5,4,7,7,4,5,4,8,5,4],"WildData":[0,0,0,0,0],"TotalBet":0}',
		-- '{"OpenType":1,"ResultType":0,"IDVec":[],"Matrix":[11,4,3,0,4,0,4,1,3,4,1,0,3,1,3],"WildData":[0,0,0,0,0],"TotalBet":0}',
		-- '{"OpenType":1,"ResultType":0,"IDVec":[],"Matrix":[6,2,5,8,8,0,6,2,2,6,6,8,5,5,5],"WildData":[0,0,0,0,0],"TotalBet":0}',
		
		-- '{"OpenType":1,"ResultType":1,"IDVec":[22302,24302],"Matrix":[8,2,2,5,6,6,5,5,11,8,2,2,5,5,6],"WildData":[1,2,1,1,1],"TotalBet":80}',
		-- '{"OpenType":1,"ResultType":1,"IDVec":[5403],"Matrix":[3,7,8,2,2,0,3,2,3,8,0,0,3,8,7],"WildData":[2,3,3,1,1],"TotalBet":80}',
		-- '{"OpenType":1,"ResultType":1,"IDVec":[23508],"Matrix":[8,8,5,8,8,5,7,5,7,7,7,0,8,5,7],"WildData":[3,3,2,3,1],"TotalBet":480}',
		-- '{"OpenType":1,"ResultType":1,"IDVec":[9303,16303,17303,20303],"Matrix":[7,7,3,7,4,3,3,1,1,1,4,3,3,4,4],"WildData":[1,2,2,1,1],"TotalBet":160}',
		-- '{"OpenType":1,"ResultType":1,"IDVec":[14305,30305],"Matrix":[8,7,8,8,5,5,7,5,7,7,8,5,1,8,7],"WildData":[2,1,1,1,3],"TotalBet":120}',
		-- '{"OpenType":1,"ResultType":1,"IDVec":[20307],"Matrix":[3,0,7,5,5, 7,3,10,3,3, 3,7,0,5,0],"WildData":[23,12,3,133,2],"TotalBet":80}',
		-- '{"OpenType":1,"ResultType":1,"IDVec":[1400,16400],"Matrix":[5,3,1,3,5, 0,0,10,1,1, 5,5,0,5,3],"WildData":[222,11,3,11,23],"TotalBet":120}',
		-- '{"OpenType":1,"ResultType":1,"IDVec":[9403],"Matrix":[0,8,7,8,7, 3,7,0,3,7, 0,3,10,3,0],"WildData":[21,123,1,13,2],"TotalBet":80}',
		-- '{"OpenType":1,"ResultType":1,"IDVec":[22302,24302],"Matrix":[8,2,2,5,6, 6,5,10,1,8, 2,2,5,5,6],"WildData":[12,133,3,111,2],"TotalBet":80}',
		-- '{"OpenType":1,"ResultType":1,"IDVec":[4301,7302,17301,29402],"Matrix":[2,2,1,3,6, 7,1,10,3,3, 1,3,3,2,1],"WildData":[13,122,3,12,2],"TotalBet":160}',
		-- '{"OpenType":1,"ResultType":1,"IDVec":[16306,22302],"Matrix":[3,5,2,3,5,6,6,5,8,5,2,2,6,3,6],"WildData":[0,0,0,0,0],"TotalBet":120}',
		-- '{"OpenType":1,"ResultType":1,"IDVec":[13400],"Matrix":[0,2,0,4,4,7,0,4,0,0,7,4,7,2,2],"WildData":[0,0,0,0,0],"TotalBet":60}',
		-- '{"OpenType":1,"ResultType":1,"IDVec":[2304],"Matrix":[8,2,7,2,4,7,2,7,2,7,4,4,4,7,8],"WildData":[0,0,0,0,0],"TotalBet":60}',
		-- '{"OpenType":1,"ResultType":1,"IDVec":[24300],"Matrix":[8,0,0,2,2,5,8,2,1,8,0,2,1,1,11],"WildData":[0,0,0,0,0],"TotalBet":20}',
		-- '{"OpenType":1,"ResultType":1,"IDVec":[21302],"Matrix":[0,2,5,7,5,2,0,11,11,5,0,5,2,0,5],"WildData":[0,0,0,0,0],"TotalBet":40}',
		-- '{"OpenType":1,"ResultType":1,"IDVec":[9301,24500],"Matrix":[2,0,0,0,2,1,3,11,3,2,0,1,1,3,0],"WildData":[0,0,0,0,0],"TotalBet":260}',
		-- '{"OpenType":1,"ResultType":1,"IDVec":[5403],"Matrix":[3,7,8,2,2,0,3,2,3,8,0,0,3,8,7],"WildData":[0,0,0,0,0],"TotalBet":80}',
		-- '{"OpenType":1,"ResultType":1,"IDVec":[21302],"Matrix":[0,2,5,7,5,2,0,11,11,5,0,5,2,0,5],"WildData":[0,0,0,0,0],"TotalBet":40}',
		-- '{"OpenType":1,"ResultType":1,"IDVec":[11307],"Matrix":[7,6,5,6,5,5,7,7,5,1,1,6,6,1,1],"WildData":[0,0,0,0,0],"TotalBet":80}',
		-- '{"OpenType":1,"ResultType":1,"IDVec":[19406],"Matrix":[6,0,6,0,5,5,0,0,7,5,7,6,5,6,0],"WildData":[0,0,0,0,0],"TotalBet":120}',
	}
	
	local appointId = math.random(1, #container)
	return container[appointId]
end

--输局
function GameResult:GenerateForLose(appointId)
	local container = {
		-- -- 普通得分
		-- '{"OpenType":1,"ResultType":0,"IDVec":[],"Matrix":[0,0,0,0,0,1,1,1,1,1,0,6,1,1,11],"WildData":[0,0,0,0,0],"TotalBet":0}', 
		-- -- 普通的丢金币
		-- '{"OpenType":0,"ResultType":1,"IDVec":[9303,16303,17303,20303],"Matrix":[7,7,3,7,4,3,3,1,1,1,4,3,3,4,4],"WildData":[0,2,2,1,1],"TotalBet":160}', 
		-- 丢火球但只有普通得分
		'{"OpenType":0,"ResultType":1,"IDVec":[9303,16303,17303,20303],"Matrix":[1,2,3,4,5,1,2,3,4,5,1,2,3,4,5],"WildData":[1,1,2,1,1],"TotalBet":160}', 
		-- '{"OpenType":0,"ResultType":1,"IDVec":[9303,16303,17303,20303],"Matrix":[1,2,3,4,5,1,2,3,4,5,1,2,3,4,5],"WildData":[1,0,2,1,1],"TotalBet":160}', 
		-- '{"OpenType":0,"ResultType":1,"IDVec":[9303,16303,17303,20303],"Matrix":[1,2,3,4,5,1,2,3,4,5,1,2,3,4,5],"WildData":[1,0,2,1,1],"TotalBet":160}', 
		-- '{"OpenType":0,"ResultType":1,"IDVec":[9303,16303,17303,20303],"Matrix":[1,2,3,4,5,1,2,3,4,5,1,2,3,4,5],"WildData":[1,0,2,1,1],"TotalBet":160}', 
		-- -- 丢到叉子上分裂
		'{"OpenType":0,"ResultType":0,"IDVec":[],"Matrix":[2,10,10,12,8,8,0,5,0,8,2,2,5,5,8],"WildData":[12,1,3,0,1],"TotalBet":0}', 
		-- 进入免费局
		'{"OpenType":0,"ResultType":0,"IDVec":[],"Matrix":[12,12,12,0,8,12,12,5,12,8,2,2,5,12,8],"WildData":[0,0,0,0,0],"TotalBet":0}', 
		-- bigwin之后再免费局
		'{"OpenType":0,"ResultType":0,"IDVec":[],"Matrix":[1,1,1,1,1,12,12,12,2,8,2,2,5,3,6],"WildData":[2,1,2,1,3],"TotalBet":0}', 


		--[['{"OpenType":0,"ResultType":0,"IDVec":[],"Matrix":[4,8,4,8,1,0,1,1,0,8,4,0,11,0,8],"WildData":[0,1,0,0,0],"TotalBet":0}',
		'{"OpenType":0,"ResultType":0,"IDVec":[],"Matrix":[3,1,8,11,2,3,3,8,2,1,2,8,8,1,3],"WildData":[0,0,1,0,0],"TotalBet":0}',
		'{"OpenType":0,"ResultType":0,"IDVec":[],"Matrix":[1,4,11,4,1,6,2,2,2,2,6,1,2,6,1],"WildData":[0,0,0,1,0],"TotalBet":0}',
		'{"OpenType":0,"ResultType":0,"IDVec":[],"Matrix":[3,7,4,11,4,4,2,3,4,7,2,7,3,2,3],"WildData":[0,0,0,0,1],"TotalBet":0}',
		'{"OpenType":0,"ResultType":0,"IDVec":[],"Matrix":[3,2,8,8,3,3,2,11,7,7,8,7,2,2,3],"WildData":[1,0,1,0,0],"TotalBet":0}',
		'{"OpenType":0,"ResultType":0,"IDVec":[],"Matrix":[0,5,5,5,7,0,1,11,5,1,1,0,5,1,0],"WildData":[0,1,1,0,0],"TotalBet":0}',
		'{"OpenType":0,"ResultType":0,"IDVec":[],"Matrix":[7,3,6,3,3,11,6,6,3,7,2,2,6,3,2],"WildData":[0,0,1,1,0],"TotalBet":0}',
		'{"OpenType":0,"ResultType":0,"IDVec":[],"Matrix":[4,2,3,3,2,8,2,3,4,8,4,3,8,4,3],"WildData":[0,0,1,0,1],"TotalBet":0}',
		'{"OpenType":0,"ResultType":0,"IDVec":[],"Matrix":[0,3,0,4,3,3,4,4,3,3,0,11,0,1,4],"WildData":[1,0,0,1,0],"TotalBet":0}',
		
		'{"OpenType":0,"ResultType":0,"IDVec":[],"Matrix":[0,4,0,6,0,4,4,6,6,4,0,6,1,1,11],"WildData":[0,0,0,0,0],"TotalBet":0}',
		'{"OpenType":0,"ResultType":0,"IDVec":[],"Matrix":[1,4,1,3,1,2,4,1,2,3,4,3,2,3,4],"WildData":[0,0,0,0,0],"TotalBet":0}',
		'{"OpenType":0,"ResultType":0,"IDVec":[],"Matrix":[1,6,8,6,4,11,6,4,8,4,1,8,4,1,11],"WildData":[0,0,0,0,0],"TotalBet":0}',
		'{"OpenType":0,"ResultType":0,"IDVec":[],"Matrix":[5,0,7,5,0,5,0,11,7,5,8,0,5,8,11],"WildData":[0,0,0,0,0],"TotalBet":0}',
		'{"OpenType":0,"ResultType":0,"IDVec":[],"Matrix":[1,4,6,1,4,0,4,6,6,4,0,0,6,1,1],"WildData":[0,0,0,0,0],"TotalBet":0}',
		'{"OpenType":0,"ResultType":0,"IDVec":[],"Matrix":[2,6,5,2,7,7,5,6,2,6,7,5,7,5,6],"WildData":[0,0,0,0,0],"TotalBet":0}',
		'{"OpenType":0,"ResultType":0,"IDVec":[],"Matrix":[6,4,5,11,4,5,1,6,5,4,5,4,1,4,6],"WildData":[0,0,0,0,0],"TotalBet":0}',
		'{"OpenType":0,"ResultType":0,"IDVec":[],"Matrix":[5,4,7,8,8,5,4,7,7,4,5,4,8,5,4],"WildData":[0,0,0,0,0],"TotalBet":0}',
		'{"OpenType":0,"ResultType":0,"IDVec":[],"Matrix":[11,4,3,0,4,0,4,1,3,4,1,0,3,1,3],"WildData":[0,0,0,0,0],"TotalBet":0}',
		'{"OpenType":0,"ResultType":0,"IDVec":[],"Matrix":[6,2,5,8,8,0,6,2,2,6,6,8,5,5,5],"WildData":[0,0,0,0,0],"TotalBet":0}',--]]
	}
	
	appointId = appointId or math.random(1, #container)
	return container[appointId], Const.ResultType.Lose, appointId
end

--赢局
function GameResult:GenerateForWin(appointId)
	local container = {
		'{"OpenType":0,"ResultType":0,"IDVec":[],"Matrix":[0,0,0,0,0,4,4,6,6,4,0,6,1,1,11],"WildData":[0,0,0,0,0],"TotalBet":0}',
		'{"OpenType":0,"ResultType":0,"IDVec":[],"Matrix":[1,1,1,1,1,2,4,1,2,3,4,3,2,3,4],"WildData":[0,0,0,0,0],"TotalBet":0}',
		'{"OpenType":0,"ResultType":0,"IDVec":[],"Matrix":[2,2,2,2,2,11,6,4,8,4,1,8,4,1,11],"WildData":[0,0,0,0,0],"TotalBet":0}',
		'{"OpenType":0,"ResultType":0,"IDVec":[],"Matrix":[3,3,3,3,3,5,0,11,7,5,8,0,5,8,11],"WildData":[0,0,0,0,0],"TotalBet":0}',
		'{"OpenType":0,"ResultType":0,"IDVec":[],"Matrix":[4,4,4,4,4,0,4,6,6,4,0,0,6,1,1],"WildData":[0,0,0,0,0],"TotalBet":0}',
		'{"OpenType":0,"ResultType":0,"IDVec":[],"Matrix":[5,5,5,5,5,7,5,6,2,6,7,5,7,5,6],"WildData":[0,0,0,0,0],"TotalBet":0}',
		'{"OpenType":0,"ResultType":0,"IDVec":[],"Matrix":[6,6,6,6,6,5,1,6,5,4,5,4,1,4,6],"WildData":[0,0,0,0,0],"TotalBet":0}',
		'{"OpenType":0,"ResultType":0,"IDVec":[],"Matrix":[7,7,7,7,7,5,4,7,7,4,5,4,8,5,4],"WildData":[0,0,0,0,0],"TotalBet":0}',
		'{"OpenType":0,"ResultType":0,"IDVec":[],"Matrix":[8,8,8,8,8,0,4,1,3,4,1,0,3,1,3],"WildData":[0,0,0,0,0],"TotalBet":0}',
		'{"OpenType":0,"ResultType":0,"IDVec":[],"Matrix":[9,9,9,9,9,0,6,2,2,6,6,8,5,5,5],"WildData":[0,0,0,0,0],"TotalBet":0}',
		'{"OpenType":0,"ResultType":1,"IDVec":[2304],"Matrix":[1,11,1,2,1,1,6,11,6,4,4,4,4,6,2],"WildData":[0,0,0,0,0],"TotalBet":60}',
		'{"OpenType":0,"ResultType":1,"IDVec":[9303,16303,17303,20303],"Matrix":[7,7,3,7,4,3,3,1,1,1,4,3,3,4,4],"WildData":[1,2,2,1,1],"TotalBet":160}',
		'{"OpenType":0,"ResultType":1,"IDVec":[6308,14308,28308,30308],"Matrix":[3,0,10,0,0, 8,5,8,3,8, 8,8,3,11,3],"WildData":[22,222,3,1,2],"TotalBet":400}',
		--[['{"OpenType":0,"ResultType":1,"IDVec":[22302,24302],"Matrix":[8,2,2,5,6,6,5,5,11,8,2,2,5,5,6],"WildData":[1,2,1,1,1],"TotalBet":80}',
		'{"OpenType":0,"ResultType":1,"IDVec":[5403],"Matrix":[3,7,8,2,2,0,3,2,3,8,0,0,3,8,7],"WildData":[2,3,3,1,1],"TotalBet":80}',
		'{"OpenType":0,"ResultType":1,"IDVec":[23508],"Matrix":[8,8,5,8,8,5,7,5,7,7,7,0,8,5,7],"WildData":[3,3,2,3,1],"TotalBet":480}',
		'{"OpenType":0,"ResultType":1,"IDVec":[9303,16303,17303,20303],"Matrix":[7,7,3,7,4,3,3,1,1,1,4,3,3,4,4],"WildData":[1,2,2,1,1],"TotalBet":160}',
		'{"OpenType":0,"ResultType":1,"IDVec":[14305,30305],"Matrix":[8,7,8,8,5,5,7,5,7,7,8,5,1,8,7],"WildData":[2,1,1,1,3],"TotalBet":120}',
		'{"OpenType":0,"ResultType":1,"IDVec":[20302],"Matrix":[4,5,2,4,1,2,4,1,4,5,1,2,5,5,1],"WildData":[1,1,3,3,2],"TotalBet":40}',
		'{"OpenType":0,"ResultType":1,"IDVec":[15307],"Matrix":[11,7,4,4,7,7,4,7,1,3,1,1,4,11,7],"WildData":[1,3,1,1,3],"TotalBet":80}',
		'{"OpenType":0,"ResultType":1,"IDVec":[20302],"Matrix":[4,5,2,4,1,2,4,1,4,5,1,2,5,5,1],"WildData":[2,1,3,1,3],"TotalBet":40}',
		'{"OpenType":0,"ResultType":1,"IDVec":[9403],"Matrix":[0,8,7,8,7,3,7,0,3,7,0,3,3,3,0],"WildData":[3,3,2,1,2],"TotalBet":80}',
		'{"OpenType":0,"ResultType":1,"IDVec":[6308,14308,20308,22308,28308,30308],"Matrix":[2,6,8,6,6,8,6,8,0,11,8,8,0,11,6],"WildData":[2,1,3,1,2],"TotalBet":600}',
		
		'{"OpenType":0,"ResultType":1,"IDVec":[20307],"Matrix":[3,0,7,5,5, 7,3,10,5,3, 3,7,0,5,0],"WildData":[23,12,3,133,2],"TotalBet":80}',
		'{"OpenType":0,"ResultType":1,"IDVec":[1400,16400],"Matrix":[5,3,1,3,5, 0,0,10,0,1, 5,5,0,5,3],"WildData":[222,11,3,11,23],"TotalBet":120}',
		'{"OpenType":0,"ResultType":1,"IDVec":[9403],"Matrix":[0,8,7,8,7, 3,7,0,3,7, 3,3,10,3,0],"WildData":[21,123,1,13,2],"TotalBet":80}',
		'{"OpenType":0,"ResultType":1,"IDVec":[22302,24302],"Matrix":[8,2,2,5,6, 6,5,10,5,8, 2,2,5,5,6],"WildData":[12,133,3,111,2],"TotalBet":80}',
		'{"OpenType":0,"ResultType":1,"IDVec":[4301,7302,17301,29402],"Matrix":[2,2,1,3,6, 2,1,10,3,3, 1,3,3,2,1],"WildData":[13,122,3,12,2],"TotalBet":160}',
		'{"OpenType":0,"ResultType":1,"IDVec":[1308,14308,15308,30308],"Matrix":[6,8,10,0,0, 8,8,8,4,0, 4,8,4,0,4],"WildData":[2,11,23,133,2],"TotalBet":400}',
		'{"OpenType":0,"ResultType":1,"IDVec":[6308,14308,28308,30308],"Matrix":[3,0,10,0,0, 8,5,8,3,8, 8,8,3,11,3],"WildData":[22,222,3,1,2],"TotalBet":400}',
		'{"OpenType":0,"ResultType":1,"IDVec":[13400],"Matrix":[0,2,0,4,4, 7,0,10,0,1, 7,4,7,2,2],"WildData":[2,113,33,12,13],"TotalBet":60}',
		'{"OpenType":0,"ResultType":1,"IDVec":[13307],"Matrix":[7,8,7,1,6, 1,7,1,1,8, 6,8,10,8,8],"WildData":[2,13,11,12,12],"TotalBet":80}',
		'{"OpenType":0,"ResultType":1,"IDVec":[6400,26300,28300],"Matrix":[4,4,10,5,8, 4,8,0,5,4, 0,0,5,0,4],"WildData":[2,23,33,123,2],"TotalBet":100}',
		
		'{"OpenType":0,"ResultType":1,"IDVec":[16306,22302],"Matrix":[3,5,2,3,5,6,6,5,8,5,2,2,6,3,6],"WildData":[0,0,0,0,0],"TotalBet":120}',
		'{"OpenType":0,"ResultType":1,"IDVec":[13400],"Matrix":[0,2,0,4,4,7,0,4,0,0,7,4,7,2,2],"WildData":[0,0,0,0,0],"TotalBet":60}',
		'{"OpenType":0,"ResultType":1,"IDVec":[2304],"Matrix":[8,2,7,2,4,7,2,7,2,7,4,4,4,7,8],"WildData":[0,0,0,0,0],"TotalBet":60}',
		'{"OpenType":0,"ResultType":1,"IDVec":[24300],"Matrix":[8,0,0,2,2,5,8,2,1,8,0,2,1,1,11],"WildData":[0,0,0,0,0],"TotalBet":20}',
		'{"OpenType":0,"ResultType":1,"IDVec":[21302],"Matrix":[0,2,5,7,5,2,0,11,11,5,0,5,2,0,5],"WildData":[0,0,0,0,0],"TotalBet":40}',
		'{"OpenType":0,"ResultType":1,"IDVec":[9301,24500],"Matrix":[2,0,0,0,2,1,3,11,3,2,0,1,1,3,0],"WildData":[0,0,0,0,0],"TotalBet":260}',
		'{"OpenType":0,"ResultType":1,"IDVec":[5403],"Matrix":[3,7,8,2,2,0,3,2,3,8,0,0,3,8,7],"WildData":[0,0,0,0,0],"TotalBet":80}',
		'{"OpenType":0,"ResultType":1,"IDVec":[21302],"Matrix":[0,2,5,7,5,2,0,11,11,5,0,5,2,0,5],"WildData":[0,0,0,0,0],"TotalBet":40}',
		'{"OpenType":0,"ResultType":1,"IDVec":[11307],"Matrix":[7,6,5,6,5,5,7,7,5,1,1,6,6,1,1],"WildData":[0,0,0,0,0],"TotalBet":80}',
		'{"OpenType":0,"ResultType":1,"IDVec":[19406],"Matrix":[6,0,6,0,5,5,0,0,7,5,7,6,5,6,0],"WildData":[0,0,0,0,0],"TotalBet":120}',
		'{"OpenType":0,"ResultType":1,"IDVec":[4302,22402],"Matrix":[3,6,2,3,1,1,2,6,1,6,2,2,3,2,6],"WildData":[0,0,0,0,0],"TotalBet":120}',
		'{"OpenType":0,"ResultType":1,"IDVec":[13400],"Matrix":[0,2,0,4,4,7,0,4,0,0,7,4,7,2,2],"WildData":[0,0,0,0,0],"TotalBet":60}',
		'{"OpenType":0,"ResultType":1,"IDVec":[21302],"Matrix":[0,2,5,7,5,2,0,11,11,5,0,5,2,0,5],"WildData":[0,0,0,0,0],"TotalBet":40}',
		'{"OpenType":0,"ResultType":1,"IDVec":[2304],"Matrix":[1,11,1,2,1,1,6,11,6,4,4,4,4,6,2],"WildData":[0,0,0,0,0],"TotalBet":60}',
		'{"OpenType":0,"ResultType":1,"IDVec":[2308,6308,25308,27308,28308],"Matrix":[8,5,0,5,1,5,0,8,0,0,8,8,8,0,11],"WildData":[0,0,0,0,0],"TotalBet":500}',
		'{"OpenType":0,"ResultType":1,"IDVec":[6307,13301,28507],"Matrix":[1,3,1,7,7,3,1,7,3,3,7,7,8,1,1],"WildData":[0,0,0,0,0],"TotalBet":460}',
		'{"OpenType":0,"ResultType":1,"IDVec":[2304],"Matrix":[1,11,1,2,1,1,6,11,6,4,4,4,4,6,2],"WildData":[0,0,0,0,0],"TotalBet":60}',
		'{"OpenType":0,"ResultType":1,"IDVec":[8305,12401,27308],"Matrix":[8,5,5,1,5,5,1,8,1,8,1,8,1,6,8],"WildData":[0,0,0,0,0],"TotalBet":220}',
		'{"OpenType":0,"ResultType":1,"IDVec":[13406,17406],"Matrix":[6,8,6,8,2,6,6,7,6,8,8,2,7,2,7],"WildData":[0,0,0,0,0],"TotalBet":240}',
		'{"OpenType":0,"ResultType":1,"IDVec":[5302,11302,13302],"Matrix":[2,3,2,11,3,1,2,2,1,1,11,6,2,6,3],"WildData":[0,0,0,0,0],"TotalBet":120}',
		'{"OpenType":0,"ResultType":1,"IDVec":[7301,26301,29301],"Matrix":[1,1,5,7,5,3,5,1,1,3,1,5,7,5,7],"WildData":[0,0,0,0,0],"TotalBet":60}',
		'{"OpenType":0,"ResultType":1,"IDVec":[2304],"Matrix":[8,2,7,2,4,7,2,7,2,7,4,4,4,7,8],"WildData":[0,0,0,0,0],"TotalBet":60}',
		'{"OpenType":0,"ResultType":1,"IDVec":[12303,18303],"Matrix":[5,3,11,5,7,0,3,0,5,5,3,7,3,0,7],"WildData":[0,0,0,0,0],"TotalBet":80}',
		'{"OpenType":0,"ResultType":1,"IDVec":[23508],"Matrix":[8,8,5,8,8,5,7,5,7,7,7,0,8,5,7],"WildData":[0,0,0,0,0],"TotalBet":480}',
		'{"OpenType":0,"ResultType":1,"IDVec":[19303,20303],"Matrix":[3,8,3,6,8,3,8,8,6,3,6,3,8,6,6],"WildData":[0,0,0,0,0],"TotalBet":80}',
		'{"OpenType":0,"ResultType":1,"IDVec":[6407,14407,28307,30307],"Matrix":[1,4,1,1,4,7,4,7,1,1,7,7,4,7,4],"WildData":[0,0,0,0,0],"TotalBet":400}',
		'{"OpenType":0,"ResultType":1,"IDVec":[25304],"Matrix":[4,5,5,5,4,11,8,5,8,4,8,4,4,5,0],"WildData":[0,0,0,0,0],"TotalBet":60}',
		'{"OpenType":0,"ResultType":1,"IDVec":[18407],"Matrix":[3,7,5,7,4,11,4,3,4,5,7,5,7,4,5],"WildData":[0,0,0,0,0],"TotalBet":120}',
		'{"OpenType":0,"ResultType":1,"IDVec":[6305,10305,28305],"Matrix":[8,4,3,8,8,3,5,5,8,8,5,5,4,3,5],"WildData":[0,0,0,0,0],"TotalBet":180}',
		'{"OpenType":0,"ResultType":1,"IDVec":[9403],"Matrix":[0,8,7,8,7,3,7,0,3,7,0,3,3,3,0],"WildData":[0,0,0,0,0],"TotalBet":80}',--]]
	}
	appointId = appointId or math.random(1, #container)
	return container[appointId], Const.ResultType.Win, appointId
end

--免费局
function GameResult:GenerateForFree(appointId)
	local container = {
		-- 隐藏一波
		-- '{"OpenType":0,"ResultType":2,"IDVec":[],"Matrix":[0,4,11,6,0,4,11,6,6,4,0,6,1,1,11],"WildData":[0,0,0,0,0],"WheelBet":500,"TotalBet":0}',
		--[['{"OpenType":0,"ResultType":2,"IDVec":[],"Matrix":[1,4,11,3,11,2,4,11,2,3,4,3,2,3,4],"WildData":[0,0,0,0,0],"WheelBet":700,"TotalBet":0}',
		'{"OpenType":0,"ResultType":2,"IDVec":[],"Matrix":[11,6,8,6,4,11,6,4,8,4,1,8,4,1,11],"WildData":[0,0,0,0,0],"WheelBet":1000,"TotalBet":0}',
		'{"OpenType":0,"ResultType":2,"IDVec":[],"Matrix":[5,0,7,11,0,5,0,11,7,5,8,0,5,8,11],"WildData":[0,0,0,0,0],"WheelBet":2000,"TotalBet":0}',
		'{"OpenType":0,"ResultType":2,"IDVec":[],"Matrix":[11,4,6,1,4,0,4,6,6,4,0,0,6,11,11],"WildData":[0,0,0,0,0],"WheelBet":2500,"TotalBet":0}',
		'{"OpenType":0,"ResultType":2,"IDVec":[],"Matrix":[2,11,5,2,7,11,5,6,11,6,7,5,7,5,6],"WildData":[0,0,0,0,0],"WheelBet":3000,"TotalBet":0}',
		'{"OpenType":0,"ResultType":2,"IDVec":[],"Matrix":[5,4,11,8,11,5,4,7,7,4,5,11,8,5,4],"WildData":[0,0,0,0,0],"WheelBet":4000,"TotalBet":0}',--]]
		-- 隐藏一波
		-- '{"OpenType":0,"ResultType":2,"IDVec":[],"Matrix":[11,4,3,0,4,0,4,11,3,4,1,0,3,11,3],"WildData":[0,0,0,0,0],"WheelBet":10000,"TotalBet":0}',
		--[['{"OpenType":0,"ResultType":2,"IDVec":[],"Matrix":[6,2,5,11,8,11,6,11,2,6,6,8,5,5,5],"WildData":[0,0,0,0,0],"WheelBet":20000,"TotalBet":0}',--]]
		-- 隐藏一波
		'{"OpenType":0,"ResultType":2,"IDVec":[],"Matrix":[3,2,8,11,3,3,2,11,7,7,8,11,2,2,3],"WildData":[0,0,0,0,0],"TotalFreeTime":15,"TotalFreeBet":2000,"TotalBet":0}',
		--[['{"OpenType":0,"ResultType":2,"IDVec":[],"Matrix":[0,5,5,5,7,0,11,11,5,11,1,0,5,1,0],"WildData":[0,0,0,0,0],"TotalFreeTime":7,"TotalFreeBet":3000,"TotalBet":0}',
		'{"OpenType":0,"ResultType":2,"IDVec":[],"Matrix":[7,3,6,3,3,11,6,6,3,11,11,2,6,3,2],"WildData":[0,0,0,0,0],"TotalFreeTime":10,"TotalFreeBet":4000,"TotalBet":0}',
		'{"OpenType":0,"ResultType":2,"IDVec":[],"Matrix":[4,2,3,11,2,11,2,3,4,8,4,11,8,4,3],"WildData":[0,0,0,0,0],"TotalFreeTime":12,"TotalFreeBet":5000,"TotalBet":0}',
		'{"OpenType":0,"ResultType":2,"IDVec":[],"Matrix":[0,3,0,4,3,11,4,4,3,3,0,11,0,11,4],"WildData":[0,0,0,0,0],"TotalFreeTime":15,"TotalFreeBet":6000,"TotalBet":0}',--]]
	}
	
	appointId = appointId or math.random(1, #container)
	return container[appointId], Const.ResultType.Free, appointId
end

--小游戏局
function GameResult:GenerateForBonus(appointId)
	local container = {
		
	}
	
	appointId = appointId or math.random(1, #container)
	return container[appointId], Const.ResultType.Bonus, appointId
end

--公共游戏局
function GameResult:GenerateForLink(appointId)
	G_printerror("获得link的局")
	local container = {
		
	}
	
	appointId = appointId or math.random(1, #container)
	G_printerror("id = ", appointId)
	return container[appointId], Const.ResultType.Link, appointId
end


return GameResult