local ButtonType = {
    Class = 1, --大类
    SubClass = 2, --功能类
}
local ButtonItem = BaseClass("ButtonItem", UIItem)
local ClassData = Globals.configMgr:GetConfig("ClassData")
local GMFunc = require (ClassData.GMFunc)

function ButtonItem:__ctor(go, baseView, basePanel)
    self.basePanel = basePanel
    self:InitItem(go, nil, baseView)
end

function ButtonItem:Initialize()
    self.text = self:GetChild("Text", ClassType.Text)
    self:AddOnClick(self.gameObject, callback(self, "OnClickBtnItem"))
end

function ButtonItem:OnClickBtnItem(go)
    if(self.type == ButtonType.Class) then
        self:OnClickClassBtn(go)
    else
        self:OnClickSubClassBtn(go)
    end
end

function ButtonItem:OnClickClassBtn(go)
    self.basePanel:InitSubBtnList(self.data)
end

function ButtonItem:OnClickSubClassBtn(go)
    local funcName = self.data[1]
    local hasParam = self.data[3]
    local tips = self.data[4]
    local defautParam = self.data[5]
    if(hasParam) then
        self.basePanel.inputField.text = defautParam or funcName
        self.basePanel.tipText.text = tips or ""
    elseif(not GMFunc[funcName]) then
        printerror("功能方法还未定义")
        return
    else
        GMFunc[funcName]()
    end
    local func_text_name = self.data[1] .. "_Text"
    if(GMFunc[func_text_name]) then
        self.text.text = GMFunc[func_text_name]() or ""
    end
end

function ButtonItem:SetData(data, type)
    self.type = type
    self.data = data
    if(type == ButtonType.Class and self.data[1][1] == "name") then
        self.text.text = self.data[1][2]
    else
        self.text.text = data[2]
        local funcName = data[1] .. "_Text"
        if(GMFunc[funcName]) then
            self.text.text = GMFunc[funcName]()
        end
    end
end

function ButtonItem:GetData()
    return self.data
end

local GMPanel = BaseClass("GMPanel", UIItem)
function GMPanel:__ctor(parent, path, baseView)
    self:InitItem(parent, path, baseView)
end

function GMPanel:__delete()

end

function GMPanel:Initialize()
    --关闭按钮
    self.closeBtn = self:GetChild("closeBtn")
    self:AddOnClick(self.closeBtn.gameObject, callback(self, "OnClickCloseBtn"))
    --执行按钮
    self.sendBtn = self:GetChild("sendBtn")
    self:AddOnClick(self.sendBtn.gameObject, callback(self, "OnClickSendBtn"))
    --输入框
    self.inputField = self:GetChild("InputField", ClassType.InputField)
    --提示文本
    self.tipText = self:GetChild("Text", ClassType.Text)
    --大类按钮
    self.classScrollView = self:GetChild("ClassScrollView", ClassType.ScrollRect)
    self.classContent = self:GetChild("ClassScrollView/Viewport/Content")
    self.classBtnPrefab = self:GetChild("ClassScrollView/Viewport/Content/ClassBtn")
    self.classBtnPrefab.gameObject:SetActive(false)
    --小类按钮
    self.subScrollView = self:GetChild("SubScrollView", ClassType.ScrollRect)
    self.subContent = self:GetChild("SubScrollView/Viewport/Content")
    self.subClassBtnPrefab = self:GetChild("SubScrollView/Viewport/Content/SubClassBtn")
    self.subClassBtnPrefab.gameObject:SetActive(false)
    self:InitGMFunc()
end

function GMPanel:OnClickCloseBtn(go)
    self:SetIsPop(false)
end

function GMPanel:OnClickSendBtn(go)
    local paramStr = self.inputField.text
    if(paramStr == "") then
        return
    end
    if(string.startwith(paramStr, "$")) then
        local function MyPrint(...)
            self.tipText.text = G_ConcartStr("执行结果：", ...)
        end
        local code = string.format( "local function Zfunc(print)\n%s\nend\nreturn Zfunc",string.sub(paramStr, 2))
        local function doHotCode()
            local f = loadstring(code)
            f()(MyPrint)
        end
    
        local function doError(errorMsg)
            errorMsg = debug.traceback(errorMsg, 2)
            self.tipText.text = "执行出错:".. errorMsg
        end
        xpcall(doHotCode, doError)
        return
    end
    local param = string.split(paramStr, " ")
    local func = GMFunc[param[1]]
    if(not func) then
        printerror("方法还未写")
        return
    end
    func(unpack(param, 2))
end

function GMPanel:ShowSelf()
    LMessage:Dispatch(LuaEvent.SmallGame.IncreaseCover, "GMPanel")
end

function GMPanel:HideSelf()
    --需要延迟一下，不然还是会触发到GameView
    Globals.timerMgr:AddTimer(function()
        LMessage:Dispatch(LuaEvent.SmallGame.DecreaseCover, "GMPanel")
    end,0,0.1)
end

function GMPanel:InitGMFunc()
    self.classBtnList = {}
    self.subClassBtnList = {}
    for i, data in ipairs(GMFunc.ClickRunGM) do
        local go = GameObject.Instantiate(self.classBtnPrefab)
        go.transform:SetParent(self.classContent.transform, false)
        go.transform.localScale = Vector3.one
        self.classBtnList[i] = ButtonItem.New(go, self.mBaseView, self)
        self.classBtnList[i]:SetIsPop(true)
        self.classBtnList[i]:SetData(data, ButtonType.Class)
    end
    if(table.getn(self.classBtnList) <= 0) then
        return
    end
    self.classBtnList[1]:OnClickBtnItem()
end

function GMPanel:InitSubBtnList(funcDataList)
    ComUtils.SimpleReuse(self.subClassBtnList, self.subClassBtnPrefab, #funcDataList - 1, 
    function(i,go)
        return ButtonItem.New(go, self.mBaseView, self)
    end,
    function(i, item)
        item:SetData(funcDataList[i + 1], ButtonType.SubClass)
    end)
end

return GMPanel