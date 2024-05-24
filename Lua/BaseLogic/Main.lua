math.randomseed(tostring(os.time()):reverse():sub(1, 7))
------------------------------------------------------ 

--主入口函数。从这里开始lua逻辑
function Main()
	require "GameLogic.GameInit"
	require "BaseLogic.GameMainUpdate"
	GameMainUpdate:Initialize()

	
end