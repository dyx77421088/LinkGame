--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:专门用来处理多语言的工具
--     创建时间:2022/04/23 
--------------------------------------------------------------------------------
local LanguageUtils = {}
local LanguageData = require "GameLogic.Config.LanguageData"
Const.LanguageType = {
    Chinese = "ch",
    English = "en",
}
local languageOrder = {"en", "ch"}  --语言排序(游戏中涉及到筛选语言时按照此排序排列节点)
local defaultLang = "en"            --缺省语言
local languageItem = {}				--文字集合
local currentLang = string.lower(Util.GetPrefs("Plat_Lang", defaultLang))

--test
--currentLang = "ch"

--获取语言适配配置
function LanguageUtils.GetLangConfig()
    if UpdateConfig and UpdateConfig.langAdapt then
        local langConfig = UpdateConfig.langAdapt
        --获取语言排序
        if langConfig.languageOrder then
			languageOrder = {}
            for i = 1, #langConfig.languageOrder do
                table.insert( languageOrder, langConfig.languageOrder[i])
            end
        end
        --获取默认语言
        if langConfig.defaultLang then
            defaultLang = langConfig.defaultLang
        end
		--获取文字集合(按照语言排序排列)
        if langConfig.languageItem then
            for i, v in pairs(langConfig.languageItem) do
                if v and type(v) == "table" then
                    table.insert(languageItem, v)
                end
            end
		else
			for i, v in pairs(MessageText) do
				if v and type(v) == "table" then
					table.insert(languageItem, v)
				end
			end
        end
        --更新当前语言
        LanguageUtils.UpdateCurrentLang()
    end
end

--判断当前语言是否有配置(游戏端语言节点都是按照languageOrder配置的,若当前语言没有在配置列表,则使用缺省语言)
function LanguageUtils.UpdateCurrentLang()
    if languageOrder then
        for i = 1, #languageOrder do
            if languageOrder[i] == currentLang then
                return
            end
        end
    end
    currentLang = defaultLang
end

--判断当前语言
function LanguageUtils.AdaptLanguage(language)
	return currentLang == language
end

--显示当前语言组件,隐藏非当前语言组件(参数:父节点,transform或者gameObject)
function LanguageUtils.AdaptLangObjectRoot(adaptRoot)
    if not adaptRoot then return end
    if not languageOrder then return end
	local childRoot = nil
	local isAdapted = false
    for i = 1, #languageOrder do
        if i <= adaptRoot.transform.childCount then
            local child = adaptRoot.transform:GetChild(i - 1)
            --显示当前语言组件
            if child.name == currentLang then
                child.gameObject:SetActive(true)
				childRoot = child
				isAdapted = true
            --隐藏非当前语言组件
            else
                child.gameObject:SetActive(false)
            end
        end
    end
	--节点没有当前语言时显示默认语言节点
	if not isAdapted then
		for i = 1, #languageOrder do
			if i <= adaptRoot.transform.childCount then
                local child = adaptRoot.transform:GetChild(i - 1)
                if child.name == defaultLang then
                    child.gameObject:SetActive(true)
                    return child
                end
            end
		end
	end
	
	return childRoot
end

--显示当前语言文本
function LanguageUtils.GetAdaptLanguage(index)
	if not languageItem then return "" end
	if not languageOrder then return "" end
	
	local msgItem = nil
	--显示当前语言文本
	for i = 1, #languageOrder do
		if languageOrder[i] == currentLang and i <= #languageItem then
			msgItem = languageItem[i]
		end
	end
	--没有当前语言文本,显示默认语言文本
	for i = 1, #languageItem do
		if languageItem[i] == defaultLang and i <= #languageItem then
			msgItem = languageItem[i]
		end
	end
	
	if msgItem and index <= #msgItem then
		return msgItem[index]
	else
		return ""
	end
end

function LanguageUtils.Translate(str, ...)
    if(currentLang == Const.LanguageType.Chinese) then
        return string.format(str, ...)
    elseif LanguageData[currentLang] and LanguageData[currentLang][str] then
        return string.format(LanguageData[currentLang][str], ...)
	else
		return string.format(LanguageData[Const.LanguageType.English][str], ...)
    end
end

function LanguageUtils.AdaptChild(parent)
    if(not parent or parent.transform.childCount <= 0) then
        return
    end
    for i = 0, parent.transform.childCount - 1 do
        local child = parent.transform:GetChild(i)
        child.gameObject:SetActive(child.name == currentLang)
    end

end

return LanguageUtils