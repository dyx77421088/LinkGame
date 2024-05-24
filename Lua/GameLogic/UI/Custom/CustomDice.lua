--------------------------------------------------------------------------------
--     cmh
--     文件描述:骰子, 占卜师涉及功能界面
--------------------------------------------------------------------------------
local CustomDice = BaseClass(UIItem)
function CustomDice:__ctor(parent, baseView)
	self:InitItem(parent, nil, baseView)
end

function CustomDice:Initialize()
    self.name = false
    self.value = 0
    self.showTag = false

    self.effectRoot = self:GetChild("effect")

    --骰子下方文本
	if self:HasChild("name") then
        self.txt_name = self:GetChild("name", "Text")
        self.txt_name.text = ""
    end
    --骰子右下角标志
	if self:HasChild("tag") then
        self.go_tag = self:GetChild("tag")
        self.go_tag:SetActive(false)
	end

    
	----test
	if self:HasChild("num") then
        self.txt_num = self:GetChild("num", "Text")
        self.txt_num.text = ""
	end
end

--==============================--
--desc:骰子动画调用。  
--      会在骰子播放完毕后做对应结果显示
--time:2019-04-10 07:59:48
--@value: 骰子点数
--@showTag: 是否展示tag, true则展示
--@name: 名字
--==============================--
function CustomDice:Show(value, showTag, name, callback)
    self:InitData(value, showTag, name, callback)
    self:ShowEffect()
end

--==============================--
--desc:初始化
--==============================--
function CustomDice:InitData(value, showTag, name, callback)
    self.name = name
    self.value = value
    self.showTag = showTag
    self.callback = callback
end

function CustomDice:SetName(str)
    if self.txt_name then
        self.txt_name.text = str
    end
end

function CustomDice:ShowSelf()
    -- self:ShowEffect(s)
    if self.go_tag  then
        self.go_tag:SetActive(false)
    end
end

function CustomDice:HideSelf()
	if self.effect_id then
        UIEffectManager.Remove(self.effect_id) 
        self.effect_id = false
    end
    if self.timer_id then
        self.timer_id = TimerManager.Remove(self.timer_id)
    end
    if self.callback then
        self.callback = false
    end
    if self.go_tag  then
        self.go_tag:SetActive(false)
    end
end

function CustomDice:ShowResult()
    if self.txt_name then
        self.txt_name.text =  self.name
    end
    if self.go_tag and self.showTag then
        self.go_tag:SetActive(true)
    end
    if self.txt_num then
        self.txt_num.text = string.format(StrUtilText("%s点"), self.value)
    end
    if self.callback then
        self.callback()
    end
end

function CustomDice:Clear()
    if self.effect_id then
        UIEffectManager.Remove(self.effect_id) 
        self.effect_id = false
    end
    if self.timer_id then
        self.timer_id = TimerManager.Remove(self.timer_id)
    end
    if self.go_tag  then
        self.go_tag:SetActive(false)
    end
end

--播放掷骰子特效
function CustomDice:ShowEffect(value)
    value = value or self.value
    local path = "common_shaizi_"..value

	if self.effect_id then
		UIEffectManager.Remove(self.effect_id)
		self.effect_id = false
    end
    if self.go_tag  then
        self.go_tag:SetActive(false)
    end
    self:SetTimer()
    self.effect_id = UIEffectManager.Show(path, self.effectRoot, Vector3.zero, Vector3.one, true)
end

function CustomDice:SetTimer()
    if self.timer_id then
        self.timer_id = TimerManager.Remove(self.timer_id)
    end
    local z_func = function()
        self:ShowResult()
    end
    self.timer_id = TimerManager.Add(z_func, 1.2)
end

function CustomDice:__delete()
    self:HideSelf()
end

return CustomDice 