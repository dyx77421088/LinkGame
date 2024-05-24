--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:模拟生成游戏结果
--     创建时间:2023/09/20  
--------------------------------------------------------------------------------
local GameResult = BaseClass("GameResult")


--普通局
function GameResult:Generate(appointType, appointId)
	if not appointType then
		local randNum = math.random(0, 10000)
		if randNum < 4000 then
			appointType = Const.ResultType.Lose
		elseif randNum < 7000 then
			appointType = Const.ResultType.Win
		elseif randNum < 8500 then
			appointType = Const.ResultType.Free
		elseif randNum < 9500 then
			appointType = Const.ResultType.Bonus
		else
			appointType = Const.ResultType.Link
		end
	end
	if appointType == Const.ResultType.Lose then
		return self:GenerateForLose(appointId)
	elseif appointType == Const.ResultType.Win then
		return self:GenerateForWin(appointId)
	elseif appointType == Const.ResultType.Free then
		return self:GenerateForFree(appointId)
	elseif appointType == Const.ResultType.Bonus then
		return self:GenerateForBonus(appointId)
	elseif appointType == Const.ResultType.Link then
		return self:GenerateForLink(appointId)
	end
end

--赠送局
function GameResult:GenerateForGive()
	local container = {
		'{"OpenType":1,"ResultType":1,"Matrix":[0,1,2,3,4, 4,3,2,1,0, 0,1,2,3,4, 4,3,2,1,0],"TotalBet":0}',
	}
	
	local appointId = math.random(1, #container)
	return container[appointId]
end

--输局
function GameResult:GenerateForLose(appointId)
	local container = {
		'{"OpenType":0,"ResultType":0,"Matrix":[0,1,2,3,4, 4,3,2,1,0, 0,1,2,3,4, 4,3,2,1,0],"TotalBet":0}',
	}
	
	appointId = appointId or math.random(1, #container)
	return container[appointId], Const.ResultType.Lose, appointId
end

--赢局
function GameResult:GenerateForWin(appointId)
	local container = {
		'{"OpenType":0,"ResultType":1,"Matrix":[0,0,0,3,4, 1,1,2,3,4, 2,1,2,3,4, 3,1,2,3,4],"TotalBet":224}',
	}
	
	appointId = appointId or math.random(1, #container)
	return container[appointId], Const.ResultType.Win, appointId
end

--免费局
function GameResult:GenerateForFree(appointId)
	local container = {
		'{"OpenType":0,"ResultType":2,"Matrix":[10,10,10,3,4, 4,3,2,1,0, 0,1,2,3,4, 4,3,2,1,0],"TotalFreeTime":10,"TotalBet":0}',
	}
	
	appointId = appointId or math.random(1, #container)
	return container[appointId], Const.ResultType.Free, appointId
end

--小游戏局
function GameResult:GenerateForBonus(appointId)
	local container = {
		'{"OpenType":0,"ResultType":3,"Matrix":[11,11,11,3,4, 4,3,2,1,0, 0,1,2,3,4, 4,3,2,1,0],"BonusBet":1000,"BonusData":[],"TotalBet":0}',
	}
	
	appointId = appointId or math.random(1, #container)
	return container[appointId], Const.ResultType.Bonus, appointId
end

--公共游戏局
function GameResult:GenerateForLink(appointId)
	local container = {
		'{"OpenType":0,"ResultType":4,"Matrix":[12,12,12,3,4, 4,3,2,1,0, 0,1,2,3,4, 4,3,2,1,0],"LinkBet":2000,"LinkData":[],"TotalBet":0}',
	}
	
	appointId = appointId or math.random(1, #container)
	return container[appointId], Const.ResultType.Link, appointId
end

--音效调试结果
function GameResult:GenerateInOrder(appointId)
	local container = {
		'{"OpenType":0,"ResultType":1,"IDVec":[16305],"Matrix":[1,2,3,4,5,0,0,0,4,5,1,2,3,4,5],"TotalBet":60}',
	}
	
	appointId = appointId or math.random(1, #container)
	return container[appointId], appointId
end

return GameResult