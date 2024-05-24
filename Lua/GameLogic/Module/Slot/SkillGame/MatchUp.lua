--------------------------------------------------------------------------------
--     作者:ygj
--     文件描述:快速配对技巧性游戏
--     创建时间:2023/11/08 
--------------------------------------------------------------------------------
local MatchUpItem = BaseClass("MatchUpItem")

function MatchUpItem:__ctor(prefab, baseView)
	self.gameObject = prefab
	self.transform = prefab.transform
	self.mBaseView = baseView
	self:Initialize()
end

function MatchUpItem:Initialize()
    self.animator = self.transform:GetComponent("Animator")
    self.image = self.transform:Find("result"):GetComponent("Image")
    local button = self.transform:GetComponent("Button")
    button.onClick:AddListener(function ()
        self:OnClick()
    end)
end

function MatchUpItem:OnClick()
    if self.isOpen or not self.mBaseView:CanClick() then
		return
	end
	
    self.isOpen = true
    self.animator:SetTrigger("Open")
    self.mBaseView:ClickCallBack(self)
end

function MatchUpItem:Eliminate()
    self.animator:SetTrigger("Eliminate")
end

function MatchUpItem:Close()
    self.isOpen = false
    self.animator:SetTrigger("Close")
end

function MatchUpItem:SetValue(data)
    self.value = data.value
    self.image.sprite = data.sprite
    self.animator:Play("Normal")
    self.isOpen = false
end


local MatchUp = BaseClass("MatchUp", UIItem)
local ButtonItem = require "GameLogic.Module.Slot.Common.ButtonItem"

local easy = {       
    gameTime = 60, --游戏时间  
    levelCount = 3, --关卡数目
    levelGameTime = {60, 60, 60}, --等级游戏时间
    linkIconCount = 8, --多少种图标
    levellinkIconCount = {3,6,8}, --等级图标数量，默认linkIconCount
    linkCount = 2, --需要多少个才能消除
    levelLinkCount = {}, --等级消除个数配置，默认linkCount
}
local normal = {           
    gameTime = 60,      
    levelCount = 5,      
    levelGameTime = {60, 60, 60, 60, 60},       
    linkIconCount = 8,        
    levellinkIconCount = {3,6,8,10,12},  
    linkCount = 2,            
    levelLinkCount = {},      
}
local hard = {           
    gameTime = 280,     
    levelCount = 7,          
    levelGameTime = {},
    linkIconCount = 8,        
    levellinkIconCount = {6,8,10,12,12,15,15},  
    linkCount = 2,            
    levelLinkCount = {},    
}
--难度配置
local config = {easy, normal, hard}
local layoutInfo = {
	[6] =  {col = 2, row = 3, cellSize = Vector2(150, 150)},
	[12] = {col = 3, row = 4, cellSize = Vector2(150, 150)},
	[16] = {col = 4, row = 4, cellSize = Vector2(150, 150)},
	[20] = {col = 4, row = 5, cellSize = Vector2(130, 130)},
	[24] = {col = 4, row = 6, cellSize = Vector2(110, 110)},
	[30] = {col = 5, row = 6, cellSize = Vector2(110, 110)},
}
--动画播放状态
local AnimState = {
    Normal = 0,         --待机
    Open = 1,           --翻开
    Eliminate = 2,      --消除
    Close = 3,          --关闭
}
--操作状态
local ClickState = {
    Click = 0,          --可以点击
    NoClick = 1,        --不能点击
    Waitting = 2,       --等待动画播放完成
}

function MatchUp:__defaultVar()
	return {
		sprites = {},
		itemArray = {},
		matchCnt = {},
		selectArray = {},
	}
end

function MatchUp:__ctor(parent, baseView)
	self:InitItem(parent, nil, baseView)
end

function MatchUp:Initialize()
	local sprites = TransformUtils.GetAllChilds(self:GetChild("res/sprite"))
	for _, v in ipairs(sprites) do
		local image = v:GetComponent(ClassType.Image)
		table.insert(self.sprites, image.sprite)
	end
	self.itemPrefab = self:GetChild("res/linkItem").gameObject
	self.game = self:GetChild("game")
	self.timertext = self:GetChild("game/decoration/timer", ClassType.Text)
	self.info = self:GetChild("game/decoration/info").gameObject
	self.infotext = self.info:GetComponent(ClassType.Text)
	self.closeBtn = ButtonItem.New(self:GetChild("game/decoration/close"), self.mBaseView)
	self.closeBtn:AddOnClick(self.closeBtn, callback(self, "OnClickCloseBtn"))
	self.fadeAnim = self:GetChild("game/fade", ClassType.Animator)
	local fadeTrigger = self:GetChild("game/fade", ClassType.LuaEventTrigger)
	fadeTrigger:SetLuaChunk(self)
	fadeTrigger:SetLuaCbFunc(self.StartAnimEvent)
	self.contentTrans = self:GetChild("game/content")
	self.content = self.contentTrans.gameObject
	self.gridLayout = self.content:GetComponent(ClassType.GridLayoutGroup)
	self.lose = self:GetChild("game/lose").gameObject
	self.win = self:GetChild("game/win").gameObject
	self.exitBtn = ButtonItem.New(self:GetChild("game/exit"), self.mBaseView)
	self.exitBtn:AddOnClick(self.exitBtn, callback(self, "OnClickExitBtn"))
	self.exitImg = self:GetChild("game/exit", ClassType.Image)
end

function MatchUp:Reset()
	local OnInstantiate = function(i, gameObject)
		local item = MatchUpItem.New(gameObject, self)
		item.transform:SetParent(self.contentTrans)
        return item
    end
    local OnSetData = function(i, item)
        item:SetValue(self:SetLinkValue())
    end
	
	table.clear(self.matchCnt)
	table.clear(self.selectArray)
    self.selectValue = 0
    self.animState = AnimState.Normal
    self.state = ClickState.Click
    self.clickTimer = 0
    self.score = 0
    self.roundId = self.roundId + 1
	self.timer = next(config[self.level].levelGameTime) and config[self.level].levelGameTime[self.roundId] or self.timer
	self.clockTimer = math.floor(self.timer)
	self.timertext.text = tostring(self.clockTimer)
	self.linkCount = next(config[self.level].levelLinkCount) and config[self.level].levelLinkCount[self.roundId] or config[self.level].linkCount
	self.linkIconCount = next(config[self.level].levellinkIconCount) and config[self.level].levellinkIconCount[self.roundId] or config[self.level].linkIconCount
	self.linkIconCount = math.min(#self.sprites, self.linkIconCount)
	self.infotext.text = self.roundId .. " - " .. self.roundCnt
    ComUtils.SimpleReuse(self.itemArray, self.itemPrefab, self.linkCount * self.linkIconCount, OnInstantiate, OnSetData)
    self:SetGridLayoutGroup(self.linkCount * self.linkIconCount)
end

function MatchUp:OnUpdate()
    if not self.isPlaying then
		return
	end
	
	self.timer = self.timer - Time.deltaTime
	if math.floor(self.timer) < self.clockTimer then
		self.clockTimer = math.floor(self.timer)
		self.timertext.text = tostring(self.clockTimer)
	end
	
    if self.clickTimer <= 0 and self.state == ClickState.NoClick then
        self:ResetItem()
    elseif self.clickTimer <= 0 and self.state == ClickState.Waitting then
        if self.score == self.linkIconCount and self.roundId == self.roundCnt then
			self.isWin = true
			self:GameOver()
		elseif self.score == self.linkIconCount then
			self:Reset()
		end
		self.state = ClickState.Click
    else
        self.clickTimer = self.clickTimer - Time.deltaTime
    end
	
	if self.timer <= 0 then
		self.isWin = false
		self:GameOver()
	end
end

function MatchUp:StartAnimEvent(trigger, factor)
    if factor == "StartGame" then
		self.closeBtn:SetEnable(true)
		self.content:SetActive(true)
		self.isPlaying = true
    end
end

--填入结果
function MatchUp:SetLinkValue()
    local value = math.random(1, self.linkIconCount)
    while self.matchCnt[value] and self.matchCnt[value] >= self.linkCount do
        value = math.random(1, self.linkIconCount)
    end
    self.matchCnt[value] = self.matchCnt[value] and (self.matchCnt[value] + 1) or 1

    return {value = value, sprite = self.sprites[value]}
end

function MatchUp:SetGridLayoutGroup(count)
	local groupInfo = layoutInfo[count]
	self.gridLayout.constraintCount = groupInfo.col
	self.gridLayout.cellSize = groupInfo.cellSize
end

--初始化选择的方块
function MatchUp:ResetItem()
    for _, v in ipairs(self.selectArray) do
        if self.animState == AnimState.Eliminate then
            v:Eliminate()
        elseif self.animState == AnimState.Close then
            v:Close()
        end
    end
    table.clear(self.selectArray)
    self.selectValue = 0
    self.clickTimer = 0.2
    self.state = ClickState.Waitting
end

--点击方块回调
function MatchUp:ClickCallBack(item)
    table.insert(self.selectArray, item)
    self.clickTimer = 0.5
    if self.selectValue > 0 and self.selectValue ~= item.value then
        self.animState = AnimState.Close
        self.state = ClickState.NoClick
        return 
    end
    self.selectValue = item.value
    if #self.selectArray == self.linkCount then
        self.score = self.score + 1
        self.animState = AnimState.Eliminate
        self.state = ClickState.NoClick
    end
end

function MatchUp:CanClick()
    return self.isPlaying and self.state == ClickState.Click
end

function MatchUp:ShowView(level)
	self.level = level
	self.isWin = false
	self.isPlaying = false
	self.roundId = 0
	self.roundCnt = config[self.level].levelCount
	self:Reset()
	self.exitImg:DOFade(0, 0)
	self.closeBtn:SetEnable(false)
	self.content:SetActive(false)
	self.lose:SetActive(false)
	self.win:SetActive(false)
	self.exitBtn:SetEnable(false)
	self.exitBtn:SetIsPop(false)
	self.game.localPosition = Vector3(0, -800, 0)
	self:SetIsPop(true)
	self.game:DOLocalMoveY(-80, 0.5):SetEase(EaseType.InQuad):OnComplete(function()
		self.fadeAnim:SetTrigger("show")
	end)
end

function MatchUp:OnClickCloseBtn()
	self.isWin = false
	self.isPlaying = false
	self.closeBtn:SetEnable(false)
	self.game:DOLocalMoveY(-800, 0.5):SetEase(EaseType.InBack):OnComplete(function()
		self:SetIsPop(false)
		self.mBaseView:StopSkillGame(self.isWin)
	end)
end

function MatchUp:OnClickExitBtn()
	self.exitBtn:SetEnable(false)
	self.game:DOLocalMoveY(-800, 0.5):SetEase(EaseType.InBack):OnComplete(function()
		self:SetIsPop(false)
		self.mBaseView:StopSkillGame(self.isWin)
	end)
end

function MatchUp:GameOver()
	self.isPlaying = false
	self.lose:SetActive(not self.isWin)
	self.win:SetActive(self.isWin)
	self.closeBtn:SetEnable(false)
	self.exitBtn:SetIsPop(true)
	self.exitImg:DOFade(1, 0.5):OnComplete(function()
		self.exitBtn:SetEnable(true)
	end)
end


return MatchUp