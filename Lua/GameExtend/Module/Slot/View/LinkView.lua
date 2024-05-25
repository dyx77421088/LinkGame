local LinkView = require "GameLogic.Module.Slot.View.LinkView"
LinkView = BaseClass("LinkViewEditor", LinkView)
local ScrollShade = require "GameLogic.Module.Slot.Game.ScrollShade"
local ButtonItem = require "GameLogic.Module.Slot.Common.ButtonItem"
local NumberItem = require "GameLogic.UI.Number.NumberItem"
local ImageWrap = require "Common.Wrap.ImageWrap"

local NameStr = {
	scrollGroup = {
		"root/scroll_1/AnimatorController/symTest/TestSymbolGrounp",-- 第一个滚轮区中棋子的group
		"root/scroll_2/AnimatorController/symTest/TestSymbolGrounp", -- 第二个滚轮区中棋子的group
		"root/scroll_3/AnimatorController/symTest/TestSymbolGrounp", -- 第三个滚轮区中棋子的group
	} ,
}
local config = {
	-- scrollInitSizeDelta = Vector2(180, 90), -- 棋子初始化的宽高（因为如果为金币或炸弹要改变num的宽高的，后面要再设回来）
	speed = 30, -- 滚动的速度（每次y轴+这么多）
	scrollTurnCount = 10, -- 滚多少圈后才停下来

	scrollHl = {
		{5, 5}, -- 第一个滚轮区是5行5列
		{5, 5}, -- 第二个滚轮区是5行5列
		{3, 5}, -- 第三个滚轮区是3行5列
	},

	downV2 = Vector2(0, -25), -- 每次滚完一个回弹的距离（向下的距离）
	downTime = 0.2,
	upV2 = Vector2(0, 0), -- 向上的距离
	upTime = 0,
	birthTime = 1, -- 回到出生点所要的时间

	-- 在随机中数字最小的取值和最大的取值
	minScore = 1,
	maxScore = 10,
	-- 在minScoreCount到maxScoreCount随机一个数字，矩阵不足这么多数字的话要补一些
	minScoreCount = {105, 6, 3}, -- 在矩阵中最少要有这么多个格子有数字，除了连成行的再补一些
	maxScoreCount = {200, 15, 7}, -- 在矩阵中最多要有这么多个格子有数字
}
-- local oneItmeHeight = 106 -- 一个棋子的高度设置为这么多
function LinkView:InitScene()
	self:InitScrollGroup(1)
	self:InitScrollGroup(2)
	self:InitScrollGroup(3)

	self.dynLoadManager = self:GetChild("root/CS", ClassType.DynLoadManager)
	self.dynLoadManagerScore = self.dynLoadManager.GameObjects[0]
	self.dynLoadManagerZhaDan = self.dynLoadManager.GameObjects[1]
	self.dynLoadManagerJinBi = self.dynLoadManager.GameObjects[2]
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
								birthPosition: Vector2, -- 这里获取的是本来应该占的位置
								rectTransform: rectTransform, -- 这个是棋子的transfom，主要是通过修改它的值实现滚动
								gameObject: gameObject,
								image: ImageWrap, -- 这个才是真正的棋子显示的图片（金币和炸弹部分）
								num: NumberItem, -- 这个才是真正的棋子显示的图片（数字部分），
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
		-- num:SetValue(6)
		return {birthPosition=nil, rectTransform = tran:GetComponent(ClassType.RectTransform), 
				gameObject = tran.gameObject, image= ImageWrap.New(tran), num = num}
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
			-- for i, v in ipairs(value.scrollItems) do
			-- 	-- v.birthPosition = v.rectTransform.anchoredPosition
			-- 	v.birthPosition = v.rectTransform.transform.position
			-- end
			-- 设置它的宽和高（主要是这样就可以设置遮罩的宽高）
			-- value.rectTransform.sizeDelta = Vector2(192.2, oneItmeHeight * (#value.scrollItems - 2))
			-- 设置完遮罩后棋子的位置需要调整一下(改变了宽高，棋子就会重新排列，所以我们就要用一开始存的position)
			for i, v in ipairs(value.scrollItems) do
				-- v.rectTransform.anchoredPosition = v.birthPosition
				-- v.rectTransform.transform.position = v.birthPosition
				v.birthPosition = v.rectTransform.anchoredPosition
			end
		end
	end, 0, 0.1)
end

-- openview 的时候调用
function LinkView:ShowSelf()
	-- 绑定start按键事件
	LMessage:Dispatch(LuaEvent.SmallGame.KeyEvent, Const.KeyEvent.Bind, Const.KeyType.Start, callback(self, "OnClickBtn"))
end

function LinkView:OnClickBtn()
	local scrollIndex = 1
	local scrollScore = 0
	local score = tonumber(self.dynLoadManagerScore.name)
	local zhaDanCount = tonumber(self.dynLoadManagerZhaDan.name)
	local jinBiCount = tonumber(self.dynLoadManagerJinBi.name)
	self.matrix = self:RandomMatrix(scrollIndex, scrollScore, score, zhaDanCount, jinBiCount)

	G_printerror("我获得 的矩阵是")
    for i = 1, 5 do
        local str = ""
        for j = 1, 5 do
            str = str .. " " .. self.matrix[i][j]
        end
        G_printerror(str)
    end

	self:StartScroll(1, config.scrollTurnCount)
	-- self:StartScroll(2)
	-- self:StartScroll(3)
	-- 解绑start按键事件
	LMessage:Dispatch(LuaEvent.SmallGame.KeyEvent, Const.KeyEvent.UnBind, Const.KeyType.Start)
end


-- scrollIndex: 哪一块区域滚动，， scrollCount ：滚多少轮
function LinkView:StartScroll(scrollIndex, scrollCount)

	scrollIndex = math.clamp(scrollIndex, 1, 3) -- 只有三个滚轮区
	scrollCount = not scrollCount and 5 or scrollCount -- 默认值设置为5
	-- 初始化一下这个滚轮区的一些信息（包括有位置、最后呈现的矩阵）
	self:InitScrollInfo(scrollIndex)
	for index, value in ipairs(self.scrollGroup[scrollIndex].groupItems) do	
		local currentScrollCount = 0 -- 当前滚了多少轮了
		-- 记录每一列中第一个棋子和最后一个棋子的下标（方便之后转了一圈最后一个棋子回到前面去）
		value.firstIndex = 1
		value.endIndex = #value.scrollItems

		Globals.timerMgr:AddTimer(function ()
			for i, v in ipairs(value.scrollItems) do
				-- if b then v.rectTransform:DOMoveY(v.rectTransform.anchoredPosition.y - 0.1, 0) end
				v.rectTransform.anchoredPosition = Vector2(v.rectTransform.anchoredPosition.x, v.rectTransform.anchoredPosition.y - config.speed );
				-- v.rectTransform:DOAnchorPos(v.rectTransform.anchoredPosition + Vector2(0, -20), 0.1)

				-- -- 因为滚动了之后不能直接用firstIndex + 1 表示firstIndex的下一个棋子了如：612345 第一个个棋子是6那么它的下一个棋子应该为1
				-- local firstNextIndex = (value.firstIndex + #value.scrollItems - 1 + 1) % #value.scrollItems + 1
				-- 如果第一个的位置等于第二个的出生位置，那么就是应该是要把最后一个的位置放到第一个位置了（这里操作的方式是
				if math.abs(value.scrollItems[value.firstIndex].rectTransform.anchoredPosition.y - value.scrollItems[2].birthPosition.y) <= config.speed then
					-- 最后一个棋子回到第一个出生点（这个出生点不会随着棋子变化的，如第一个棋子滚到了第四个第五个但它的出生点还是那个位置）
					-- value.scrollItems[value.endIndex].transform.position = Vector3(value.scrollItems[1].birthPosition.x, value.scrollItems[1].birthPosition.y, value.scrollItems[1].birthPosition.z)
					-- value.scrollItems[value.endIndex].rectTransform.anchoredPosition = value.scrollItems[1].birthPosition

					-- 修改最后一个棋子的下标(如：234561 => 当前是1为最后一个棋子，那么把1放到最前面，那么就是 123456，应该修改为6，公式为(1 + 6 - 1 - 1) % 6 + 1)
					value.firstIndex = value.endIndex
					value.endIndex = (value.endIndex + #value.scrollItems - 1 - 1) % #value.scrollItems + 1

					-- 这七个棋子都排一下位置吧
					for k = 1, #value.scrollItems do
						value.scrollItems[(value.firstIndex + #value.scrollItems - 1 + k - 1) % #value.scrollItems + 1].rectTransform.anchoredPosition = value.scrollItems[k].birthPosition
					end

					-- 第一个位置随机图片
					self:RandomScrollItem(value.scrollItems[value.firstIndex], value.firstIndex, index, scrollIndex, currentScrollCount)

					-- 当1再次回到第一个位置的时候说明滚完一轮了
					if value.firstIndex == 1 then
						currentScrollCount = currentScrollCount + 1
					end
				end
			end

			if currentScrollCount == scrollCount then
				-- 停止滚动的一些操作TODD
				self:ScrollEnd(value)
				return false
			end
			return true
		end, 0, (index - 1) * 0.2)
	end
end

-- 这个位置给他随机一个值 (如果是最后一次的滚动，那么就给他指定的值)
function LinkView:RandomScrollItem(scrollItem, h, l, scrollIndex, currentScrollCount)
	-- 最后一行给指定的值
	if currentScrollCount == config.scrollTurnCount - 1 then
		-- 因为多了两行所以要判断一下
		if h - 1 >= 1 and h - 1 <= config.scrollHl[scrollIndex][1] then
			scrollItem.num:SetValue(self.matrix[h - 1][l] == 0 and "" or self.matrix[h - 1][l])
		else
			scrollItem.num:SetValue("")
		end	
		return
	end
	local rand = math.random(1, 100)
	if rand <= 50 then -- 空白
		scrollItem.num:SetValue("")
	elseif rand <= 80 then -- 随机数字
		scrollItem.num:SetValue(math.random(1, 20))
	elseif rand <= 95 then -- 金币
		scrollItem.num:SetValue("j")
	else -- 炸弹
		scrollItem.num:SetValue("z")
	end
	
end

function LinkView:ScrollEnd(groupItem)
	-- v.rectTransform.anchoredPosition = 
	-- Vector2(v.rectTransform.anchoredPosition.x, v.rectTransform.anchoredPosition.y - config.speed );
				
	-- 完成之后有一个回弹的动画
	for index, value in ipairs(groupItem.scrollItems) do
		local seq = DOTween.Sequence()
		
		seq:Append(value.rectTransform:DOAnchorPos(value.rectTransform.anchoredPosition + config.downV2, config.downTime))-- 下移动一点
		-- seq:Append(value.rectTransform:DOAnchorPos(value.rectTransform.anchoredPosition + config.upV2, config.upTime))-- 回弹上去
		seq:Append(value.rectTransform:DOAnchorPos(value.birthPosition, config.birthTime)) -- 真正的位置

        seq:SetLoops(1, LoopType.Restart)
		seq:Play()
	end

	-- 绑定start按键事件
	LMessage:Dispatch(LuaEvent.SmallGame.KeyEvent, Const.KeyEvent.Bind, Const.KeyType.Start, callback(self, "OnClickBtn"))
end

function LinkView:InitScrollInfo(index)
	for index, value in ipairs(self.scrollGroup[index].groupItems) do
		for i, v in ipairs(value.scrollItems) do
			v.rectTransform.anchoredPosition = v.birthPosition
		end
	end

	-- 随机这个滚轮区最终呈现的矩阵，
	local rand = math.random(1, 100)

end
-------------------------------------------------#regin 随机矩阵的部分-----------------------------------------------------------
-- 随机一下矩阵，不过它必须要有能返回指定的结果的
-- scrollIndex: 哪个滚轮区块， scrollScore: 滚轮区的分数 （2，3滚轮区第一二行要加上这个b玩意的）
--  score: 目标分数， zhaDanCount: 炸弹数量， jinBiCount :金币数量
function LinkView:RandomMatrix(scrollIndex, scrollScore, score, zhaDanCount, jinBiCount)
	scrollIndex = math.clamp(scrollIndex, 1, #config.scrollHl)
	-- 矩阵的各个值的表示： 0：空白  "j"：金币  "z":炸弹   其它的正整数：分数
	local matrix = {}
	local h, l = config.scrollHl[scrollIndex][1], config.scrollHl[scrollIndex][2] -- 第三个滚轮区只有三行，其他的有五行
	for i = 1, h do -- 初始化矩阵的值
		matrix[i] = {}
		for j = 1, l do
			matrix[i][j] = 0
		end
	end
	
	-- 记录随机的分数的分布（1哪些行应该为连成的分数，2哪些列连成的分数，3哪斜连成的分数）,scoreItemCount需要随机的数的个数
	local needScoreItems = self:RandomHLX(score, scrollScore, scrollIndex)
	

	-- 这些是连成一条线的数字
	local currentScore, currentCount, randomScore = 0, 0, 0
	for i = 1, #needScoreItems do
		randomScore = self:RandomScore(score - currentScore, #needScoreItems - currentCount)
		currentScore = currentScore + randomScore
		currentCount = currentCount + 1
		matrix[needScoreItems[i][1]][needScoreItems[i][2]] = randomScore
	end

	-- 除了这些还需要一些随机的位置放些数字，要求不能连成线
	local hCount, bH, bL, currHCount = math.random(config.minScoreCount[scrollIndex], config.maxScoreCount[scrollIndex]) - #needScoreItems, 0, 0, 0
	local maxCount = 1000 -- 最多随机这多多次，还没有全部随机完也不随机了
	-- while currHCount < hCount do
	-- 	-- 随机行和列
	-- 	bH, bL = math.random(1, h), math.random(1, l)
	-- 	-- 判断这个行和列是否可以放进去
	-- 	if self:PdNewItem(matrix, bH, bL) then
	-- 		matrix[bH][bL] = math.random(config.minScore, config.maxScore)
	-- 		currHCount = currHCount + 1
	-- 	end
		
	-- 	maxCount = maxCount - 1
	-- 	if maxCount <= 0 then break end
	-- end


	-- 随机炸弹位置和金币的位置
	while zhaDanCount > 0 do
		-- 随机行和列
		bH, bL = math.random(1, h), math.random(1, l)
		if matrix[bH][bL] == 0 then
			matrix[bH][bL] = "z"
			zhaDanCount = zhaDanCount - 1
		end
	end
	while jinBiCount > 0 do
		-- 随机行和列
		bH, bL = math.random(1, h), math.random(1, l)
		if matrix[bH][bL] == 0 then
			matrix[bH][bL] = "j"
			jinBiCount = jinBiCount - 1
		end
	end
	return matrix
end
--[[ 
	判断随机的行和列是否可以放进去
	1.该位置不能有值
	2.该位置放了之后不能再次形成一条线
 ]]
function LinkView:PdNewItem(matrix, h, l)
	if matrix[h][l] ~= 0 then return false end
	local canH, canL, canX1, canX2 = true, true, false, false
	for index, value in ipairs(matrix[h]) do -- 判断行
		if index ~= l and value == 0 then 
			canH = false
			break
		end
	end
	for index, value in ipairs(matrix) do -- 判断列
		if index ~= h and value[l] == 0 then 
			canL = false
			break
		end
	end
	-- 判断对角(1, 1) (2, 2) (3, 3) (4, 4) (5, 5) or (5, 1) (4, 2) (3, 3) (2, 4) (1, 5)
	if h == l or h + l == #matrix[1] + 1 then
		canX1, canX2 = true, true

		for i = 1, #matrix do
			if i ~= h and matrix[i][i] == 0 then canX1 = false end
			if i ~= l and matrix[#matrix - i + 1][i] == 0 then canX2 = false end
		end
	end
	return not canH and not canL and not canX1 and not canX2
end
--[[ 
	随机行列斜的分布
	例如：hlxLink = {{4}, {}, {}} 表示第四行需要有一行的数据
	矩阵可以返回如：(第四行必须是全部都是非0数字，其它行必须不能全部非0)
	1 2 0 0 0
	2 0 0 2 0
	0 0 0 0 0
	1 2 3 4 5
	1 2 0 1 0
	needScoreItems 返回需要随机的数字的下标
	如上应返回 {{4, 1}, {4, 2}, {4, 3}, {4, 4}, {4, 5}}
	ps:hlxLink = {{4}, {1}, {}} 行和列都不为空，则返回的needScoreItems个数应该是9个(相交一个)
 ]]
function LinkView:RandomHLX(score, scrollScore, scrollIndex)
	-- 这个滚轮区中行列斜的个数
	local h, l = config.scrollHl[scrollIndex][1], config.scrollHl[scrollIndex][2]
	local x = math.min(h, l) -- 斜的个数
	-- 记录随机的分数的分布（1哪些行应该为连成的分数，2哪些列连成的分数，3哪斜连成的分数）,行列斜需要取的个数
	local hlxLink, hlxCount = {{}, {}, {}}, {0, 0, 0}
	local matrix = {}
	for i = 1, h do -- 初始化矩阵的值
		matrix[i] = {}
		for j = 1, l do
			matrix[i][j] = 0
		end
	end
	-- 如果是滚轮区2，3，那么中上还有一个固定的分数，用2记录它
	if scrollIndex > 1 then matrix[1][3], matrix[2][3] = 2, 2 end
	-- 如果scrollIndex > 1那么就要加scrollScore，分为三种情况：
	-- 1. 如果用了scrollScore必会大于score
	-- 2. 如果不用必会小于score
	-- 3. 用了和不用都可以得到正确的score
	-- 如果分数不为空，那么必有一行或对角线连成数字
	if score > 0 then
		-- 需要随机的线的个数，如100，而取的最大值只有10，那么它至少要随机到10个数字，也就是两行或两列（一行一列必有相交的，所以就只有9个数），或者行列斜和为3以上
		-- 当然也有最小值，如8， 取的最小值为1，那么最多只能有行列斜的和为1，因为如果为2的话那么就最小值也是9了
		local currentMinSumScore, currentMaxSumScore, randomHlx, randomHlxIndex = 0, 0, 0, 0
		local sortRandomHlx, count, b ={}, 0, false -- 排序之后的行列斜，添加了的个数

		local maxCount = 5 -- 行列斜的和最多是5
		local maxRandomHlxIndexCount = 1000
		while currentMaxSumScore < score and count < maxCount do
			count = count + 1
			randomHlx = math.random(1, scrollIndex == 3 and 2 or 3) -- 随机一个（第三个滚轮区没有斜着得分的，所以它只有行列）
			hlxCount[randomHlx] = hlxCount[randomHlx] + 1
			-- 随机行列斜
			maxRandomHlxIndexCount = 1000 -- 最多试错这么多次，不成立就直接出来
			while maxRandomHlxIndexCount > 0 do
				randomHlxIndex = math.random(1, randomHlx == 3 and 2 or config.scrollHl[scrollIndex][randomHlx])
				-- 不能已经包含了这个index了
				b = true
				for index, value in ipairs(hlxLink[randomHlx]) do if value == randomHlxIndex then b = false end end
				if b then -- 如果这个index没有被使用
					-- 估算它的得分的范围
					local tMin, tMax, zeroCount = 0, 0, 0
					if randomHlx == 1 then -- 表示行
						for j = 1, l do if matrix[randomHlxIndex][j] == 0 then zeroCount = zeroCount + 1 end end
					elseif randomHlx == 2 then -- 表示列
						for j = 1, h do if matrix[j][randomHlxIndex] == 0 then zeroCount = zeroCount + 1 end end
					elseif randomHlx == 3 then -- 对角线
						for j = 1, x do -- 对角线的五个棋子
							if randomHlxIndex == 1 then -- 正的当x=5 (1, 1) (2, 2) (3, 3) (4, 4) (5, 5)
								if matrix[j][j] == 0 then zeroCount = zeroCount + 1 end
							else -- 反的当x=5 (5, 1) (4, 2) (3, 3) (2, 4) (1, 5)
								if matrix[x - j + 1][j] == 0 then zeroCount = zeroCount + 1 end
							end
						end
					end

					tMin = config.minScore * zeroCount
					tMax = config.maxScore * zeroCount
					-- 如果这b玩意是第二或第三个滚轮区，那么中间有得分，且 是行的话那就是一二行碰到了得分，列的话是第三列
					if scrollIndex > 1 and (randomHlx == 1 and randomHlxIndex <= 2 or randomHlx == 2 and randomHlxIndex == 3) then
						tMin = scrollScore + tMin
						tMax = scrollScore + tMax
					end

					-- 判断预计加进来的数是否能用呢(如果能获得的最小值都比预计得分高了，那就是不行的，否则才行)
					if not (tMin + currentMinSumScore > score) then
						-- 把这个线添加进去
						table.insert(hlxLink[randomHlx], randomHlxIndex)
						-- 更新矩阵
						if randomHlx == 1 then -- 表示行
							for j = 1, l do if matrix[randomHlxIndex][j] == 0 then matrix[randomHlxIndex][j] = 1 end end
						elseif randomHlx == 2 then -- 表示列
							for j = 1, h do if matrix[j][randomHlxIndex] == 0 then matrix[j][randomHlxIndex] = 1 end end
						elseif randomHlx == 3 then -- 对角线
							for j = 1, x do -- 对角线的五个棋子
								if randomHlxIndex == 1 then -- 正的当x=5 (1, 1) (2, 2) (3, 3) (4, 4) (5, 5)
									if matrix[j][j] == 0 then matrix[j][j] = 1 end
								else -- 反的当x=5 (5, 1) (4, 2) (3, 3) (2, 4) (1, 5)
									if matrix[x - j + 1][j] == 0 then matrix[x - j + 1][j] = 1 end
								end
							end
						end
						currentMinSumScore = currentMinSumScore + tMin
						currentMaxSumScore = currentMaxSumScore + tMax
						break
					end
				end

				maxRandomHlxIndexCount = maxRandomHlxIndexCount - 1
			end

			G_printerror("我就来速记行列写了", count, randomHlx)
		end
		-- local hOrL1 = math.random(1, 2) -- 行还是列
		-- local hOrL2 = math.random(1, 2) -- 行还是列
		-- local hL1 = {math.random(1, h), math.random(1, l)} -- 哪一行或列1
		-- local hL2 = {math.random(1, h), math.random(1, l)} -- 哪一行或列2
		-- local xie = math.random(1, 2) -- 如果随到对角线，是正向的还是斜向的

		-- -- 如果是第三个滚轮区，那么它有且只有一个行或列有（没得斜的）
		-- if scrollIndex == 3 then
		-- 	table.insert(hlxLink[hOrL1], math.random(1, config.scrollHl[3][hOrL1]))
		-- else

		-- 	-- 随机一波
		-- 	local random1 = math.random(1, 100)
		-- 	if random1 <= 50 then -- 百分之五十的概率这只有一行或列
		-- 		table.insert(hlxLink[hOrL1], hL1[hOrL1])
		-- 	elseif random1 <= 70 then -- 百分之二十的概率只有对角线的线
		-- 		table.insert(hlxLink[3], xie)
		-- 	elseif random1 <= 90 then -- 百分之二十的概率两行或两列，或一行一列
		-- 		table.insert(hlxLink[hOrL1], hL1[hOrL1]) -- 先添加一个
		-- 		table.insert(hlxLink[hOrL2], hL2[hOrL2]) -- 再添加第二个
		-- 		-- 如果最后一个和第一个相同，那么就重新随机
		-- 		while hOrL1 == hOrL2 and hL1[hOrL1] == hL2[hOrL2] do
		-- 			hL2[hOrL2] = math.random(1, 5)
		-- 			hlxLink[hOrL2][#hlxLink[hOrL2]] = hL2[hOrL2]
		-- 		end 
		-- 	else -- 一行（列）加一个对角线
		-- 		table.insert(hlxLink[hOrL1], hL1[hOrL1]) 
		-- 		table.insert(hlxLink[3], xie) 
		-- 	end
		-- end
	end

	-- 返回这些家伙的下标
	local needScoreItems = {}
	-- local hasH, hasL = -1, -1
	-- for index, value in ipairs(hlxLink) do
	-- 	for i, v in ipairs(value) do
	-- 		if index == 1 then -- 表示行
	-- 			for j = 1, l do -- 第v行的5个棋子下标
	-- 				needScoreItems[#needScoreItems+1] = {v, j}
	-- 			end
	-- 			hasH = v -- 表示有行
	-- 		elseif index == 2 then -- 表示列
	-- 			for j = 1, h do -- 第v列的n个棋子下标(第三个滚轮区只有三行)
	-- 				if j ~= hasH then -- 与行相交的棋子是不需要添加进来的
	-- 					needScoreItems[#needScoreItems+1] = {j, v}
	-- 				end
	-- 			end
	-- 			hasL = v -- 表示有列
	-- 		elseif index == 3 then -- 对角线
	-- 			for j = 1, x do -- 对角线的五个棋子
	-- 				if v == 1 then -- 正的当x=5 (1, 1) (2, 2) (3, 3) (4, 4) (5, 5)
	-- 					if j ~= hasH and j ~= hasL then -- 与行相交的棋子是不需要添加进来的
	-- 						needScoreItems[#needScoreItems+1] = {j, j}
	-- 					end
	-- 				else -- 反的当x=5 (5, 1) (4, 2) (3, 3) (2, 4) (1, 5)
	-- 					if x - j + 1 ~= hasH and j ~= hasL then -- 与行相交的棋子是不需要添加进来的
	-- 						needScoreItems[#needScoreItems+1] = {x - j + 1, j}
	-- 					end
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- end
	for i = 1, h do
		local str = ""
		for j = 1, l do
			str = str .. " " .. matrix[i][j]
			if matrix[i][j] == 1 then needScoreItems[#needScoreItems+1] = {i, j} end
		end
		G_printerror(str)
	end
	G_printerror("需要need的个数是", #needScoreItems)
	return needScoreItems
end
--[[ 
	随机分数
	score: 在count个数中要达到这么多分数
	count: 总共需要随机的个数
 ]]
function LinkView:RandomScore(score, count)
	-- 有时候并不能分配完（如minScore=1,maxScore=5,而5个数我还得到50，那么前4个取5，第五个返回30！），反正我就直接返回就好了
	if count == 1 then return score end 
	local min = score - (count - 1) * config.maxScore -- 下限是后count-1个数全部取最大值
	local max = score - (count - 1) * config.minScore -- 上限是后count-1个数全部取最小值
	min = math.max(min, config.minScore)
	max = math.min(max, config.maxScore)
	if min > max then return 0 end
	return math.random(min, max)
end


------------------------------------------------#endregin-------------------------------------------------------------------------





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