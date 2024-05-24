--------------------------------------------------------------------------------
--     作者:ygj
--     文件描述:见缝插针技巧性游戏
--     创建时间:2023/09/20  
--------------------------------------------------------------------------------
local StickBall = BaseClass("StickBall", UIItem)
local ButtonItem = require "GameLogic.Module.Slot.Common.ButtonItem"

local easy = {           
    {pointer = 3, speed = 60},
    {pointer = 7, speed = 60},
}
local normal = {           
    {pointer = 3, speed = 60},
    {pointer = 7, speed = 120},
    {pointer = 13, speed = 180},
}
local hard = {           
    {pointer = 3, speed = 60},
    {pointer = 7, speed = 120},
    {pointer = 13, speed = 180},
    {pointer = 18, speed = 180},
    {pointer = 22, speed = 180},
}
--难度配置
local config = {easy, normal, hard}
local pointerPath = "coreball/pointer"
local boundaryAngle = 8
local totalTime = 15

function StickBall:__defaultVar()
	return {
		launchers = {},
		pointers = {},
		angles = {},
	}
end

function StickBall:__ctor(parent, baseView)
	self:InitItem(parent, nil, baseView)
end

function StickBall:Initialize()
	self.pointPrefab = self:GetChild("pointer").gameObject
	self.game = self:GetChild("game")
	self.leveltext = self:GetChild("game/level", ClassType.Text)
	self.wheel = self:GetChild("game/wheel")
	self.wheelPool = self:GetChild("game/wheel/pool")
	self.fire = self:GetChild("game/fire")
	self.centertext = self:GetChild("game/center/text", ClassType.Text)
	self.lose = self:GetChild("game/lose").gameObject
	self.win = self:GetChild("game/win").gameObject
	self.launchBtn = ButtonItem.New(self:GetChild("game/launch"), self.mBaseView)
	self.launchBtn:AddOnClick(self.launchBtn, callback(self, "OnClickLaunchBtn"))
	self.closeBtn = ButtonItem.New(self:GetChild("game/close"), self.mBaseView)
	self.closeBtn:AddOnClick(self.closeBtn, callback(self, "OnClickCloseBtn"))
	self.closeImg = self:GetChild("game/close", ClassType.Image)
	local launchers = TransformUtils.GetAllChilds(self:GetChild("game/launcher"))
	for _, v in ipairs(launchers) do
		local item = {
			gameObject = v.gameObject,
			text = v:Find("text"):GetComponent(ClassType.Text),
		}
		table.insert(self.launchers, item)
	end
end

function StickBall:Reset()
    self.roundId = self.roundId + 1
    self.clickTime = 0
	self.speed = config[self.level][self.roundId].speed
	self.leveltext.text = self.roundId .. " - " .. self.roundCnt
	for i = 1, #self.pointers do
		self.pointers[i].textTrans:SetParent(self.pointers[i].transform)
		Globals.poolMgr:Push(pointerPath, self.pointers[i])
	end
	table.clear(self.pointers)
	table.clear(self.angles)
	self.pointerCnt = config[self.level][self.roundId].pointer
	for i = 1, self.pointerCnt do
		local pointerItem = self:InstPointer()
		pointerItem.text.text = ""
		table.insert(self.pointers, pointerItem)
		
		while(self:JudgeAngle(self.wheel.localEulerAngles.z)) do
			self.wheel.localEulerAngles = Vector3(0, 0, math.random(0, 360))
		end
		table.insert(self.angles, self.wheel.localEulerAngles.z)
		pointerItem.transform:SetParent(self.wheel)
		--避免打断合批
		pointerItem.textTrans:SetParent(self.wheelPool)
		pointerItem.transform:SetAsFirstSibling()
		
	end
	for i = 1, #self.launchers do
		self.launchers[i].gameObject:SetActive(true)
	end
	self:ShowGameInfo()
end

function StickBall:OnUpdate()
    if self.isPlaying then
		UnityEngine.Transform.Rotate(self.wheel, 0, 0, -self.speed * Time.deltaTime)
	end
end

function StickBall:ShowView(level)
	self.level = 2 --level
    self.isWin = false
	self.isPlaying = false
    self.roundId = 0
	self.roundCnt = #config[self.level]
    self:Reset()
	self.launchBtn:SetEnable(false)
	self.lose:SetActive(false)
	self.win:SetActive(false)
	self.closeBtn:SetEnable(false)
	self.closeBtn:SetIsPop(false)
	self.closeImg:DOFade(0, 0)
	self:SetIsPop(true)
	self.game.localPosition = Vector3(0, -1100, 0)
	self.game:DOLocalMoveY(-200, 0.5):SetEase(EaseType.InQuad):OnComplete(function()
		self.launchBtn:SetEnable(true)
		self.isPlaying = true
	end)
end

function StickBall:InstPointer()
	local pointerItem = Globals.poolMgr:Pop(nil, pointerPath)
	if not pointerItem then
		local go = GameObject.Instantiate(self.pointPrefab, self.fire)
		local transform = go.transform
		local textTrans = transform:Find("text")
		local text = textTrans:GetComponent(ClassType.Text)
		go:SetActive(true)
		pointerItem = {transform = transform, textTrans = textTrans, text = text}
	else
		pointerItem.transform:SetParent(self.fire)
		TransformUtils.NormalizeTrans(pointerItem.transform)
	end
	
	return pointerItem
end

function StickBall:ShowGameInfo()
	self.centertext.text = totalTime - self.clickTime
	local fillCnt = 0
	for i = #self.launchers, 1, -1 do
		local index = totalTime - self.clickTime - i + 1
		if index <= 0 then
			self.launchers[i].gameObject:SetActive(false)
			fillCnt = fillCnt + 1
		else
			self.launchers[i].text.text = totalTime - self.clickTime - (#self.launchers - i) + fillCnt
		end
	end
end

function StickBall:JudgeAngle(angleValue)
    for i = 1, #self.angles do
        if math.abs(self.angles[i] - angleValue) <= boundaryAngle 
            or (angleValue <= boundaryAngle and self.angles[i] >= 360 - boundaryAngle and math.abs(angleValue + 360 - self.angles[i]) <= boundaryAngle)
            or (angleValue >= 360 - boundaryAngle and self.angles[i] <= boundaryAngle and math.abs(self.angles[i] + 360 - angleValue) <= boundaryAngle) then
            return true
        end
    end
    return false
end

function StickBall:OnClickLaunchBtn()
    if not self.isPlaying then
        return
    end
	
	local pointerItem = self:InstPointer()
	pointerItem.text.text = totalTime - self.clickTime
	table.insert(self.pointers, pointerItem)
	pointerItem.transform:SetParent(self.wheel)
	--避免打断合批
	pointerItem.textTrans:SetParent(self.wheelPool)
	pointerItem.transform:SetAsFirstSibling()
	self.clickTime = self.clickTime + 1
    self:ShowGameInfo()
	if not self:JudgeAngle(self.wheel.localEulerAngles.z) then
		table.insert(self.angles, self.wheel.localEulerAngles.z)
	else
		self.isWin = false
		self:GameOver()
	end
	if self.isPlaying and self.clickTime == totalTime and self.roundId == self.roundCnt then
		self.isWin = true
		self:GameOver()
	elseif self.isPlaying and self.clickTime == totalTime then
		self:Reset()
	end
end

function StickBall:OnClickCloseBtn()
	self.closeBtn:SetEnable(false)
	self.launchBtn:SetEnable(false)
	self.game:DOLocalMoveY(-1100, 0.5):SetEase(EaseType.InBack):OnComplete(function()
		self:SetIsPop(false)
		self.mBaseView:StopSkillGame(self.isWin)
	end)
end

function StickBall:GameOver()
	self.isPlaying = false
	self.lose:SetActive(not self.isWin)
	self.win:SetActive(self.isWin)
	self.closeBtn:SetIsPop(true)
	self.closeImg:DOFade(1, 0.5):OnComplete(function()
		self.closeBtn:SetEnable(true)
	end)
end

return StickBall