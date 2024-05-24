local NumberItem = BaseClass("NumberItem", UIItem)

function NumberItem:__defaultVar()
	return {
		numInsts = {},
		onLoadSprite = false, --设置加载数字图片的回调，可以自己独立加载
		spritePrefix = "", --图片前缀
		spriteAtlas = "", --图集名称
		onInstantiate = false, --通过外面的方法实例化
		instPool = {}, --用来存储实例化后回收的数字池
		replaceDic = {["."] = "A", [","] = "B", ["$"] = "C"},
	}
end

function NumberItem:__ctor(parent, numPrefab, baseView, replaceDic)
    self:InitItem(parent, nil, baseView)
    self.numPrefab = numPrefab
    if(self.numPrefab) then
        self.numPrefab.gameObject:SetActive(false)
    end
	if replaceDic then
		self.replaceDic = replaceDic
	end
end

function NumberItem:__delete()
    self:StopScroll()
    for _, numInst in ipairs(self.numInsts) do
		GameObject.Destroy(numInst.go)
	end
	for _, numInst in ipairs(self.instPool) do
		GameObject.Destroy(numInst.go)
	end
    self.onLoadSprite = false
    self.onInstantiate = false
	self.numInsts = nil
	self.instPool = nil
end

function NumberItem:Initialize()

end

function NumberItem:SetInstantiateNumCallBack(onInstantiate)
    self.onInstantiate = onInstantiate
end

--设置加载数字图片的回调，可以自己独立加载
function NumberItem:SetLoadSpriteCallBack(callBack)
    self.onLoadSprite = callBack
end

--设置需要加载图集的名称和图片前缀
function NumberItem:SetAtlasParam(atlasName, spritePrefix)
    self.spritePrefix = spritePrefix --图片前缀
    self.spriteAtlas = atlasName --图集名称
end

--滚动开始事件
function NumberItem:OnStart(callBack)
	self.startCb = callBack
	
	return self
end

--滚动更新事件
function NumberItem:OnUpdate(callBack)
	self.updateCb = callBack
	
	return self
end

--滚动完成事件
function NumberItem:OnComplete(callBack)
	self.completeCb = callBack
	
	return self
end

--滚动中断事件
function NumberItem:OnKill(callBack)
	self.killCb = callBack
	
	return self
end

--==============================--
--addby:yjp
--desc:滚分
--@startNum:起始数字
--@endNum:结束数字
--@decimal:小数位数 默认0
--@duration:滚分时间
--@delayTime: 滚分延迟
--@return:
--time:2022-05-10 11:40:07
--==============================--
function NumberItem:ScrollNum(startNum, endNum, decimal, duration, delayTime)
    if(not startNum and (not self.value or type(self.value) ~= "string")) then
        printerror("请设置起始数字")
        return self
    end
    startNum = startNum or tonumber(self.value)
    if(not endNum) then
        printerror("请设置结束数字")
        return self
    end
    if(startNum == endNum) then
        self:SetValue(startNum)
        return self
    end
    -- printerror("ScrollNum", startNum, endNum)
    duration = duration or 1
    delayTime = delayTime or 0
    local curTime = 0
    self:StopScroll()
    self:SetValue(startNum)
    self.scrollTimer_id = Globals.timerMgr:AddTimer(function()
		if curTime == 0 and self.startCb then
			local cb = self.startCb
			self.startCb = nil
			cb()
		end
        curTime = curTime + Time.deltaTime
        local curValue = 0
        if(curTime >= duration) then
            curValue = endNum
        else
            curValue = startNum + (endNum - startNum) / duration * curTime
            curValue = curValue * math.pow(10, decimal)
            curValue = math.round(curValue)
            curValue = curValue / math.pow(10, decimal)
            curValue = math.max(0, curValue)
        end
        self:SetValue(curValue)
		if self.updateCb then
			local cb = self.updateCb
			cb(curValue)
		end
		if curTime <= duration then
			return true
		else
			self.scrollTimer_id = nil
			self.killCb = nil
			self.updateCb = nil
			if self.completeCb then
				local cb = self.completeCb
				self.completeCb = nil
				cb()
			end
		end
    end,0, delayTime)
	
	return self
end

function NumberItem:StopScroll()
	if self.scrollTimer_id then
		Globals.timerMgr:DelTimer(self.scrollTimer_id)
		if self.killCb then
			local cb = self.killCb
			self.killCb = nil
			cb()
		end
		self.startCb = nil
		self.updateCb = nil
		self.completeCb = nil
	end
end

function NumberItem:SetValue(numberArr)
    if(type(numberArr) == "number") then
        numberArr = tostring(numberArr)
    end
    if(self.value == numberArr) then
        return
    end
    self.value = numberArr
    if(self.onInstantiate) then
        self:InstantiateByCallBack(numberArr)
    else
        self:InstaiateSelf(numberArr)
    end
end

--通过回调进行实例化
function NumberItem:InstantiateByCallBack(numberArr)
    local instNum = #self.numInsts
    for i = 1, instNum do
        local inst = table.remove(self.numInsts)
        self:Despawn(inst)
    end
    for i = 1, #numberArr do
        local num = nil
        if(type(numberArr) == "string") then
            num = string.sub(numberArr, i, i)
        else
            num = numberArr[i]
        end
		num = self:SwitchNum(tostring(num))
        local numInst = self:Spawn(num)
        if(not numInst) then
            local go = self.onInstantiate(num)
            go.transform:SetParent(self.parent.transform)
            go.transform.localScale = Vector3.one
			go.transform.localEulerAngles = Vector3.zero
            local pos = go.transform.localPosition
            pos.z = 0
            go.transform.localPosition = pos
			numInst = {go = go, num = num}
        end
        numInst.go.transform:SetAsLastSibling()
        table.insert(self.numInsts, numInst)
    end
end

--自行实例化
function NumberItem:InstaiateSelf(numberArr)
    for i = 1, #numberArr do
        if(i > #self.numInsts) then
            local go = GameObject.Instantiate(self.numPrefab, self.parent.transform)
            go.transform.localScale = Vector3.one
			go.transform.localEulerAngles = Vector3.zero
			local numInst = {}
			numInst.go = go
			numInst.image = go:GetComponent(ClassType.Image)
			numInst.active = false
            table.insert(self.numInsts, numInst)
        end
		if not self.numInsts[i].active then
			self.numInsts[i].active = true
			self.numInsts[i].go:SetActive(true)
		end

        local num = nil
        if(type(numberArr) == "string") then
            num = string.sub(numberArr, i, i)
        else
            num = numberArr[i]
        end
		self.numInsts[i].num = self:SwitchNum(tostring(num))
        --通过回调加载图片
        if(self.onLoadSprite) then
            self.onLoadSprite(self.numInsts[i])
        --自行加载图片
        else
            Globals.resMgr:LoadSprite(self.spriteAtlas, self.spritePrefix .. self.numInsts[i].num, function(img)
                --加载出来之前已经被销毁了
                if(not self.numInsts) then
                    return
                end
				self.numInsts[i].image.sprite = img 
            end)
        end
    end
    for i = #numberArr + 1, #self.numInsts do
        self.numInsts[i].go:SetActive(false)
		self.numInsts[i].active = false
    end
end

--取对象
function NumberItem:Spawn(num)
    if(not self.instPool[num] or #self.instPool[num] <= 0) then
        return
    end
    local list = self.instPool[num]
    local inst = table.remove(list)
    inst.go:SetActive(true)
    return inst
end

--放回
function NumberItem:Despawn(inst)
    inst.go:SetActive(false)
    local num = inst.num
    self.instPool[num] = self.instPool[num] or {}
    table.insert(self.instPool[num], inst)
end


function NumberItem:SwitchNum(num)
	return self.replaceDic[num] or num
end

return NumberItem