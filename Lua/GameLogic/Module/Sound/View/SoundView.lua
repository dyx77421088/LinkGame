--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:处理打包后测试调整音效的界面，可以进行音效的替换，调整等
--     创建时间:2022/07/26 
--------------------------------------------------------------------------------
local SoundItem = require "GameLogic.Module.Sound.View.SoundItem"
local SoundView = BaseClass("SoundView", UIViewBase)
local Directory = System.IO.Directory
local File = System.IO.File
local Path = System.IO.Path

function SoundView:__ctor(cb)
    local soundParam = ComUtils.GetTestSoundParm()
    self.platName = soundParam.platName
    self.gameName = soundParam.gameName
    self.size = soundParam.size
    self.vertical = soundParam.vertical
    self.importPath = soundParam.importPath
    self.exportPath = soundParam.exportPath
    self.downLoadPath = soundParam.downLoadPath
end

function SoundView:__delete()

end

function SoundView:Initialize()
    self.importInputField = self:GetChild("root/folder/sourcePath", ClassType.InputField)
    self.openBtn = self:GetChild("root/folder/btnOpen")
    self:AddOnClick(self.openBtn.gameObject, callback(self, "OnClickOpenBtn"))
    self.importBtn = self:GetChild("root/folder/btnImport")
    self:AddOnClick(self.importBtn.gameObject, callback(self, "OnClickImportBtn"))
    self.usedItemList = {}
    self.soundItemPrefab = self:GetChild("root/list/used/Viewport/Content/SoundItem") 
    self.soundItemPrefab.gameObject:SetActive(false)
    self.usedContent = self:GetChild("root/list/used/Viewport/Content")
    self.usedScroll = self:GetChild("root/list/used", ClassType.ScrollRect)

    self.importItemList = {}
    self.importScroll = self:GetChild("root/list/import", ClassType.ScrollRect)
    self.importContent = self:GetChild("root/list/import/Viewport/Content")
    self.importItemPrefab = GameObject.Instantiate(self.soundItemPrefab)
    self.importItemPrefab.transform:SetParent(self.importContent)
    self.importItemPrefab.transform.localPosition = Vector3.zero
    self.importItemPrefab.transform.localScale = Vector3.one
    self.importItemPrefab.gameObject:SetActive(false)

    self.outBtn = self:GetChild("root/console/btnClose")
    self:AddOnClick(self.outBtn, callback(self, "OnClickOutBtn"))

    self.saveBtn = self:GetChild("root/console/btnSave")
    self:AddOnClick(self.saveBtn, callback(self, "OnClickSaveBtn"))

    self.exportBtn = self:GetChild("root/console/btnExport")
    self:AddOnClick(self.exportBtn, callback(self, "OnClickExportBtn"))

    self.clearBtn = self:GetChild("root/console/btnClear")
    self:AddOnClick(self.clearBtn, callback(self, "OnClickClearBtn"))
end

function SoundView:OnClickOpenBtn(go)
    local sourcePath = AudioResMgr.AudioRes.OpenDialog();
    self.importInputField.text = sourcePath
end

function SoundView:OnClickImportBtn(go)
    local sourcePath = self.importInputField.text
    if sourcePath == "" then return end
	if(not Directory.Exists(sourcePath)) then
        return
    end
    if(not self.importPath) then
        printerror("导入路径为空:", self.importPath)
        return
    end
    AudioResMgr.AudioRes.CopyFolder(sourcePath, self.importPath);
    self:ShowImport()
end

function SoundView:OnClickOutBtn(go)
    self:SetIsPop(false)
end

function SoundView:OnClickSaveBtn(go)
    if(not self.soundData ) then
        Globals.uiMgr:FloatMsg("还未更改音效")
        return
    end
    local out = {}
	local TimeUtils = require "Common.Utils.TimeUtils"
	table.insert(out, "--------------------------------------------------------------------------------")
	table.insert(out, "--     作者: GM指令调整音效功能生成")
	table.insert(out, "--     文件描述: 该文件根据测试替换的音效情况自动生成")
	table.insert(out, "--     创建时间: "..TimeUtils.GetNormalDateString())
	table.insert(out, "--------------------------------------------------------------------------------")
	table.insert(out, "local data = {")
	for k, v in pairs(self.soundData) do
		table.insert(out, string.format('\t["%s"] = {originalRes = "%s", replaceRes = "%s", delay = %d},',k,v.originalRes, v.replaceRes, v.delay))
	end
	table.insert(out, "}")
	table.insert(out, "return data")
	local dataStr = table.concat(out, '\n')
    Util.MakeSureDir(self.importPath .. "/Lua")
    local savePath = self.importPath .. "/Lua/SoundData.lua"
	Util.WriteAllText(savePath, dataStr)
    local loadPath = Globals.soundMgr:GetExtraDataPath()
    local dirPath = Path.GetDirectoryName(loadPath)
    local needRestart = true
    if(File.Exists(loadPath)) then--目录已经存在就不需要再重启了，否则需要退出游戏，让LuaManage加载环境目录
        needRestart = false
    end
    Util.MakeSureDir(dirPath)
    File.Copy(savePath, loadPath, true)
    if(needRestart) then
        Globals.uiMgr:FloatMsg("保存成功，先返回大厅")
        Globals.timerMgr:AddTimer(function()
            Globals.gameModel.quitGame = true
            Globals.netMgr:QuitConnect()
        end, 0, 3)
    else
        Globals.uiMgr:FloatMsg("保存成功！！！")
        Globals.soundMgr:LoadExtraSoundConfig()
    end
end

function SoundView:OnClickExportBtn()
    if(not self.soundData or not next(self.soundData)) then
        return
    end
    for _, data in pairs(self.soundData) do
        local srcPath = data.replaceRes
        local assetData = Globals.resMgr:GetAssetData(data.originalRes)
        local dstPath = self.exportPath .. string.replace(assetData.assetPath, "Assets/SmallGame/Bundle", "")
        local dstDir = Path.GetDirectoryName(dstPath)
        Util.MakeSureDir(dstDir)
        File.Copy(srcPath, dstPath, true)
    end
    Util.MakeSureDir(self.exportPath .. "/Lua")
    local soundPath = self.importPath .. "/Lua/SoundData.lua"
    File.Copy(soundPath, self.exportPath .. "/Lua/SoundData.lua", true)
    Globals.uiMgr:FloatMsg("导出成功！！！")
end

function SoundView:OnClickClearBtn(go)
    if(File.Exists(Globals.soundMgr:GetExtraDataPath())) then
        File.Delete(Globals.soundMgr:GetExtraDataPath())
        Globals.uiMgr:FloatMsg("清理成功！！！")
        self.soundData = {}
        Globals.soundMgr:LoadExtraSoundConfig()
        self:ShowImport()
    else
        Globals.uiMgr:FloatMsg("游戏中还未有替换配置")
    end
end

function SoundView:ShowSelf()
    if(File.Exists(Globals.soundMgr:GetExtraDataPath())) then
        self.soundData = require("SoundData")
    else
        self.soundData = {}
    end
    self:ShowUsed()
    self:ShowImport()
    LMessage:Dispatch(LuaEvent.SmallGame.IncreaseCover, self.uiName)
    Globals.soundMgr:PauseMusic()
end

function SoundView:HideSelf()
    LMessage:Dispatch(LuaEvent.SmallGame.DecreaseCover, self.uiName)
    Globals.soundMgr:ResumeMusic()
end

function SoundView:ShowUsed()
    local assetData = Globals.configMgr:GetConfig("AssetData")
    local list = {}
    for path, data in pairs(assetData) do
        if(data.assetType == "AudioClip") then
            table.insert(list, data)
        end
    end
    table.sort(list, function(itemA, itemB)
        return itemA.assetId < itemB.assetId
    end)
    local OnInstantiate = function(i, go)
        return SoundItem.New(go,1, self)
    end
    local OnSetData = function(i, item)
        item:SetType(1)
        item:SetData(list[i])
    end
    ComUtils.SimpleReuse(self.usedItemList, self.soundItemPrefab, #list, OnInstantiate, OnSetData)
end

function SoundView:ShowImport()
    if(not self.importPath) then
        return
    end
    local list = {}
    if(Directory.Exists(self.importPath)) then
        local files = Directory.GetFiles(self.importPath)
        for i = 0, files.Length - 1 do
            local fileName = Path.GetFileName(files[i])
            if(string.contains(fileName, ".mp3") or string.contains(fileName, ".wav") or string.contains(fileName, ".ogg")) then
                local file = string.replace(files[i], "\\", "/");
                table.insert(list, file)
            end
        end
    end
    if(table.getn(list) <= 0) then
        return
    end
    table.sort(list, function(itemA, itemB)
        return itemA < itemB
    end)
    local OnInstantiate = function(i, go)
        return SoundItem.New(go,2, self)
    end
    local OnSetData = function(i, item)
        item:SetType(2)
        item:SetResName(list[i])
        if(not next(self.soundData)) then
            return
        end
        for _, data in pairs(self.soundData) do
            if(data.replaceRes == list[i]) then
                item:SetData(data)
                break
            end
        end
    end
    ComUtils.SimpleReuse(self.importItemList, self.importItemPrefab, #list, OnInstantiate, OnSetData)
end

function SoundView:ShowHighLightItem()
    self.curHighLightItem = nil
    for i, item in ipairs(self.usedItemList) do
        if(item:ShowHighLightItem()) then
            self.curHighLightItem = item
            break
        end
    end
end

function SoundView:EndDragImportItem(importItem)
    for i, item in ipairs(self.usedItemList) do
        item:HideHighLight()
    end
    if(not self.curHighLightItem) then
        return
    end
    local data = self.curHighLightItem:GetData()
    local relativePath = string.replace(data.assetPath, "Assets/SmallGame/Bundle/", "")
    local arr = string.split(relativePath, ".")
    self.soundData[arr[1]] = {originalRes = arr[1], replaceRes = importItem:GetResName(), delay = 0}
    importItem:SetData(self.soundData[arr[1]])
    self.curHighLightItem = nil
end

function SoundView:OnImportRevert(importItem)
    local data = importItem:GetData()
    self.soundData[data.originalRes] = nil
end

return SoundView