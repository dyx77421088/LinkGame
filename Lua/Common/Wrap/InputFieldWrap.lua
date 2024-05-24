--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:输入框 包装UnityEngine.UI.InputField
--     创建时间:2022/05/18 
--------------------------------------------------------------------------------
local InputFieldWrap = BaseClass("InputFieldWrap")

function InputFieldWrap:__ctor(go)
    self.gameObject = go.gameObject
    self.transform = go.transform
    self.csInputField = go:GetComponent(ClassType.InputField)
    self.placeHolderText = nil
end

function InputFieldWrap:SetText(text)
    if(text) then
        self.csInputField.text = text
    else
        self.csInputField.text = ""
    end
end

function InputFieldWrap:GetText()
    return self.csInputField.text
end

function InputFieldWrap:SetPlaceHolderText(text)
    if(not self.placeHolderText) then
        self.placeHolderText = self.csInputField.placeholder.gameObject:GetComponent(ClassType.Text)
    end
    self.placeHolderText.text = text
end

function InputFieldWrap:OnValueChange(cb)
    self.csInputField.onValueChanged:AddListener(cb)
end

return InputFieldWrap