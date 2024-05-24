local LinkView = require "GameLogic.Module.Slot.View.LinkView"
LinkView = BaseClass("LinkViewEditor", LinkView)
local ScrollShade = require "GameLogic.Module.Slot.Game.ScrollShade"
local ButtonItem = require "GameLogic.Module.Slot.Common.ButtonItem"
local NumberItem = require "GameLogic.UI.Number.NumberItem"

local NameStr = {
	scrollGroup = {
		"root/scroll_1/AnimatorController/symTest/TestSymbolGrounp",-- 第一个滚轮区中棋子的group
		"root/scroll_2/AnimatorController/symTest/TestSymbolGrounp", -- 第二个滚轮区中棋子的group
		"root/scroll_3/AnimatorController/symTest/TestSymbolGrounp", -- 第三个滚轮区中棋子的group
	} ,
}
local oneItmeHeight = 106 -- 一个棋子的高度设置为这么多
function LinkView:InitScene()
	self:InitScrollGroup(1)
	self:InitScrollGroup(2)
	self:InitScrollGroup(3)
end

-- 初始化滚轮区
function LinkView:InitScrollGroup(index)
	--[[ 
		self.scrollGroup的数据结构为
		[
			{
				root: transform, -- 最外层的那个对象的transform对象
				horizontalLayout: horizontalLayoutGroup, -- 最外层的那个对象的horizontalLayoutGroup组件
				groupItems: [-- 里面包含了五列
					{ 
						transform: transform, -- 这一列的transform 对象
						gameObject: gameObject, -- gameObject
						verticalLayout: VerticalLayoutGroup, -- 垂直的组件，控制这一列棋子的分布
						scrollItems : [-- 这一列中的行的个数，咱有三个滚轮区，12是五行五列，3是三行五列
							{ 
								position: Vector3, -- 这里获取的是本来应该占的位置
								transform: transform, -- 这个是棋子的transfom，主要是通过修改它的值实现滚动
								gameObject: gameObject,
								num: NumberItem, -- 这个才是真正的棋子显示的图片，
							},
							......
						]
					},
					......
				]
			}
		]
	 ]]

	index = math.clamp(index, 1, #NameStr.scrollGroup) -- 大小范围在1-3之间
	if not self.scrollGroup then self.scrollGroup = {} end
	if not self.scrollGroup[index] then self.scrollGroup[index] = {} end

	local onInstantiate_time = function(num)
		local parent = Globals.resMgr:LoadPlatAtlas("Atlas/linkviewnumber")
		local num = parent.transform:Find(num).gameObject
		return GameObject.Instantiate(num)
	end
	local scrollItemProcess = function (tran, i, list)
		local num = NumberItem.New(tran, tran:GetChild(0).gameObject, self)
		num:SetInstantiateNumCallBack(onInstantiate_time)
		num:SetValue(6)
		return {birthPosition=nil, transform = tran, gameObject = tran.gameObject, num = num}
	end
	local scrollGroupProcess = function(tran, i, list)

		local scrollItems = TransformUtils.GetAllChilds(tran, scrollItemProcess)
		local verticalLayout = tran:GetComponent(ClassType.VerticalLayoutGroup)
		verticalLayout.enabled = true -- 先打开
		return {rectTransform = tran:GetComponent(ClassType.RectTransform), transform = tran, gameObject = tran.gameObject, 
			verticalLayout = verticalLayout, scrollItems = scrollItems}
	end

	self.scrollGroup[index].root = self:GetChild(NameStr.scrollGroup[index])
	-- 水平布局先打开，主要是设置一下位置
	self.scrollGroup[index].horizontalLayout = self.scrollGroup[index].root:GetComponent(ClassType.HorizontalLayoutGroup)
	self.scrollGroup[index].horizontalLayout.enabled = true -- 先打开

	self.scrollGroup[index].groupItems = TransformUtils.GetAllChilds(self.scrollGroup[index].root, scrollGroupProcess)


	Globals.timerMgr:AddTimer(function ()
		-- 改变位置了
		self.scrollGroup[index].horizontalLayout.enabled = false -- 关闭
		for index, value in ipairs(self.scrollGroup[index].groupItems) do
			value.verticalLayout.enabled = false -- 关闭

			-- 在改变遮罩之前记录一下棋子应该在的位置
			for i, v in ipairs(value.scrollItems) do
				v.birthPosition = v.transform.position
			end
			-- 设置它的宽和高（主要是这样就可以设置遮罩的宽高）
			value.rectTransform.sizeDelta = Vector2(192.2, oneItmeHeight * (#value.scrollItems - 2))
			-- 设置完遮罩后棋子的位置需要调整一下(改变了宽高，棋子就会重新排列，所以我们就要用一开始存的position)
			for i, v in ipairs(value.scrollItems) do
				v.transform.position = v.birthPosition
			end
		end
	end, 0, 0.1)
end

-- openview 的时候调用
function LinkView:ShowSelf()
	-- 绑定start按键事件
	LMessage:Dispatch(LuaEvent.SmallGame.KeyEvent, Const.KeyEvent.Bind, Const.KeyType.Start, callback(self, "OnClickBtn"))
end

local b = true
function LinkView:OnClickBtn()
	for index, value in ipairs(self.scrollGroup[1].groupItems) do	
		Globals.timerMgr:AddTimer(function ()
			for i, v in ipairs(value.scrollItems) do
				print(index)
				if b then v.transform:DOMoveY(v.transform.position.y - 0.1, 0) end

				if index == 1 then
					-- G_printerror("我倒是要看看这会不会改变", math.abs(value.scrollItems[1].transform.position.y - value.scrollItems[2].birthPosition.y))
					-- G_printerror(value.scrollItems[1].transform.position.y, value.scrollItems[2].birthPosition.y)
				end
				-- 如果第一个的位置等于第二个的出生位置，那么就是应该是要把最后一个的位置放到第一个位置了（这里操作的方式是
				if i == 1 and math.abs(value.scrollItems[1].transform.position.y - value.scrollItems[2].birthPosition.y) <= 0.1 then
					G_printerror("进来i需改了")
					for j = #value.scrollItems, 1, -1 do
						G_printerror("修改！！", j, value.scrollItems[j].birthPosition)
						value.scrollItems[j].transform.position = value.scrollItems[j].birthPosition
						if j > 1 then value.scrollItems[j].num:SetValue(value.scrollItems[j - 1].num.value) end
					end
					-- 新的num
					value.scrollItems[1].num:SetValue(math.random(1, 20))
					b = false
				end
			end
			return true
		end, 0, (index - 1) * 1)
	end
	-- 解绑start按键事件
	LMessage:Dispatch(LuaEvent.SmallGame.KeyEvent, Const.KeyEvent.UnBind, Const.KeyType.Start)
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