local ComUtils = {clsCache = {}}

local tableType = "table"
local numberType = "number"

--检查两个表是否格式相同, tmpTab是模板表
function ComUtils.CheckFormat(srcTab, tmpTab, errMsg)
	local t = type(tmpTab)
	if srcTab == nil or t ~= type(srcTab) then
		if errMsg ~= nil then
			printwarning('----1 '..errMsg)
		end
		return false
	end

	if t ~= tableType then
		return true
	end

	local firstDstItem = tmpTab[1]
	--只能是数组或表类型
	local bArrayTable = firstDstItem ~= nil

	if bArrayTable then 
		--数组格式
		for k, v in pairs(tmpTab) do
			if type(k) ~= numberType or
				not self:CheckFormat(srcTab[k], firstDstItem) then
				if errMsg ~= nil then
					printwarning('----2 '..errMsg)
				end
				return false
			end
		end
	else
		--表格式
		for k, v in pairs(tmpTab) do
			if not self:CheckFormat(srcTab[k], v) then
				if errMsg ~= nil then
					print('--key-- '..k)
					printwarning('----3 '..errMsg)
				end
				return false
			end
		end
	end

	return true
end

--lua值转字符串
function ComUtils.ToString(tab) 
	local function toString(tab)
		local info = "";
		if type(tab) ~= "table" then
			info = info..tab
		else
			info = "{";
			for k, v in pairs(tab) do
				if type(v) == "table" then
					info = info..string.format("%s:", k);
					info = info..toString(v);
				else
					info = info..string.format("%s:%s;", k, v);
				end
			end
			info = info.."};";
		end
		return info;
	end
	--
	local curInfo = toString(tab);
	return curInfo;
end

--
function ComUtils.Handler(_self, fun)
	local selfFun = function(...)
		fun(_self, ...)
	end
	return selfFun
end

--分割字符串，来自网上
function ComUtils.Split(str, reps)
    local resultStrList = {}
    string.gsub(str,'[^'..reps..']+',function ( w )
        table.insert(resultStrList,w)
    end)
    return resultStrList
end

--------------------------------------gc-----------------------------------
local needUnload = false
local toUnloadTime = 0
function ComUtils.CheckUnload()
	if not needUnload then
		return
	end

	local dt = Time.deltaTime
	toUnloadTime = toUnloadTime - dt
	if toUnloadTime < 0 then
		if dt < 0.045 then
			--不算太卡时清
			UnityEngine.Resources.UnloadUnusedAssets()
			needUnload = false
		end
	end
end

--
function ComUtils.ToUnload()
	if not needUnload then
		--再不是unload状态下的话，再过几秒才unload，减少频繁操作
		toUnloadTime = 10
		needUnload = true
	end
end

--初始化动画
function ComUtils.ResetAnim(compOrGameObject, name)
	--Spine骨骼动画
	local components = compOrGameObject.gameObject:GetComponentsInChildren(ClassType.SkeletonAnimation)
	if components.Length > 0 then
		for i = 0, components.Length - 1 do
			components[i].AnimationState:Update(0)
		end
	end
	components = compOrGameObject.gameObject:GetComponentsInChildren(ClassType.SkeletonGraphic)
	if components.Length > 0 then
		for i = 0, components.Length - 1 do
			components[i].AnimationState:Update(0)
		end
	end
	--Animator动画
	components = compOrGameObject.gameObject:GetComponentsInChildren(ClassType.Animator)
	if components.Length > 0 then
		--可能父级动画控制子级动画,先重置子级动画
		for i = components.Length - 1, 0, -1 do
			if name then
				components[i]:Play(name, 0, 0)
			end
			components[i]:Update(0)
		end
	end
end

--新增---------------------------------------------------------------------------
local uniqueID = 0
local Camera = UnityEngine.Camera
local QualitySettings = UnityEngine.QualitySettings
local Time = UnityEngine.Time
--本次运行游戏唯一id

function ComUtils.GetUniqueID()
	uniqueID = uniqueID + 1
	return uniqueID
end

function ComUtils.FileExists(path)
	-- local file,err = io.open(path, "rb")
	-- if file then file:close() end
	-- return file ~= nil and err == nil
	return Util.IsFileExist(path)
end

function ComUtils.GetFiles(path, pattern)
	return Directory.GetFiles(path, pattern)
end

function ComUtils.ChangeGammmaValue(rgb)
	return math.max(1.055 * math.pow(rgb, 0.416666667) - 0.055, 0.0)
end

function ComUtils.SetTimeScale(v)
	Time.timeScale = v
end

function ComUtils.SetAUP(asyncUploadTimeSlice, asyncUploadBufferSize)
	print("SetAUP:", asyncUploadTimeSlice, asyncUploadBufferSize)
	QualitySettings.asyncUploadTimeSlice = asyncUploadTimeSlice
	QualitySettings.asyncUploadBufferSize = asyncUploadBufferSize
end

--统计函数调用时间
function ComUtils.DebugCallTime(f, desc, maxDelta,...)
	local t = UnityEngine.Time.realtimeSinceStartup
	local ret = {f(...)}
	local delta = UnityEngine.Time.realtimeSinceStartup - t
	maxDelta = maxDelta or 0.001
	if delta >= maxDelta or desc == "Error" then
		print("调用时间:", UnityEngine.Time.frameCount, desc, delta)
	end
	return table.unpack(ret)
end


--遍历整个目录dirPath下所有文件进行处理
function ComUtils.TravalDir(dirPath, callBack)
    local lfs = require("lfs")
    local traverpath,attr
    local filenum = 0
    for entry in lfs.dir(dirPath) do
        if entry~= '.' and entry ~= '..' then
            traverpath = dirPath.."/"..entry
            attr = lfs.attributes(traverpath)
            if(type(attr)~="table") then --如果获取不到属性表则报错
                printerror('ERROR:'..traverpath..'is not a path')
                return nil
            end
            if(attr.mode == "directory") then
                ComUtils.TravalDir(traverpath, callBack)
            elseif attr.mode=="file" then
                filenum=filenum+1
                --处理函数
                callBack(traverpath)					
            end
        end
    end
end

--[[
    @desc:

    @return 
]]
--==============================--
--addby:yjp
--desc:对item简单的复用,实例化Item
--@luaItemList:luaItem对象列表 自己在外部定义
--@count:要显示的数量
--@defaultCsGO:cs模板对象
--@OnSetData:对luaItem赋值的回调操作 OnSetData(luaIndex,luaItem)
--@OnInstantiate: 对实例化新对象后的回调操作 OnInstantiate(luaIndex,csGo) return luaItem(必须包含gameObject，transform)
--@return:
--time:2022-04-25 10:20:55
--==============================--
function ComUtils.SimpleReuse(luaItemList, defaultCsGO, count, OnInstantiate, OnSetData)
    local listCount = #luaItemList
    local parent = defaultCsGO.transform.parent
	for i = 1, count do
		if(i > listCount) then
			local newCsGO = GameObject.Instantiate(defaultCsGO, parent)
			local newLuaItem = OnInstantiate(i,newCsGO)
			table.insert(luaItemList, newLuaItem)
		end
		luaItemList[i].gameObject:SetActive(true)
		OnSetData(i, luaItemList[i])
	end
    for i = count + 1, listCount do
		luaItemList[i].gameObject:SetActive(false)
	end
end

function ComUtils.IsMobile()
	--IPhonePlayer 8, Android 11
	-- printext("Common.Utils.ComUtils.IsMobile>>>>>>>>>>>>", UnityEngine.Application.platform, type(UnityEngine.Application.platform), tostring(UnityEngine.Application.platform, type(tostring(UnityEngine.Application.platform))))
	return UnityEngine.Application.platform == 8 or UnityEngine.Application.platform == 11 or tostring(UnityEngine.Application.platform) == "Android" or tostring(UnityEngine.Application.platform) == "IPhonePlayer"
end

--获取音效参数，只有测试音效的工具平台才需要
function ComUtils.GetTestSoundParm()
	local param = {}
    param.platName = Util.ReadINI('Setting', 'PlatName', '');
    param.gameName = Util.ReadINI('Setting', 'GameName', 'ChaoJiShuangLunPan_1565');
    param.size = Util.ReadINI('Setting', 'Size', 720);
    param.vertical = Util.ReadINI('Setting', 'Vertical', 0);
    if param.platName and param.platName ~= "" then
		local gameName = Util.GetLuaParam(0, 'PlatformCtrl', 'gameName');
		if gameName and gameName ~= '' then
			param.importPath = UnityEngine.Application.dataPath .. '/../game/' .. gameName .. '/import';
			param.exportPath = UnityEngine.Application.dataPath .. '/../game/' .. gameName .. '/out';
            param.downLoadPath = UnityEngine.Application.dataPath .. '/../game/' .. gameName .. '/download';
		end
	elseif param.gameName and param.gameName ~= "" then
		param.importPath = UnityEngine.Application.dataPath .. '/../game/' .. param.gameName .. '/import';
		param.exportPath = UnityEngine.Application.dataPath .. '/../game/' .. param.gameName .. '/out';
        param.downLoadPath = UnityEngine.Application.dataPath ..'/../game/' .. param.gameName .. '/download';
	end
	return param
end

function ComUtils.IsTestSound()
	local ManagerCtrl
	--[[local zfunc = function()
        ManagerCtrl = Util.GetLuaParam and Util.GetLuaParam(2, 'ManagerCtrl', 'bInLoad') or ComUtils.Is_Dev()
    end
	if(not xpcall(zfunc, printext)) then
		return false
	end--]]
	if(ManagerCtrl) then
		return true
	else
		return false
	end
end

function ComUtils.Is_Dev()
	if _IsEditor then
		return true
	elseif(GlobalShare.smallGameStartArg and GlobalShare.smallGameStartArg == "") then
		return true
	else
		return false
	end
end

return ComUtils