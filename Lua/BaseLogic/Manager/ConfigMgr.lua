--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:加载配置的管理器，所有获取配置都从这里获取，不要独立require，
--		        否则会被绑死配置，不能根据情况去加载GameLogic/Config下的或者GameExtend/Config目录下的配置
--     创建时间:2022/05/13 
--------------------------------------------------------------------------------
local _config_data_dic = {}
local _config_scene_dic = {}
local _config_weapon_trans = false
local ConfigMgr = Singleton("ConfigMgr")


local module_pre = "GameLogic.Config." --普通配置表
local scene_pre = "GameLogic.SceneConfig." --场景表

local extend_module_pre = "GameExtend.Config."
local extend_mudule_pre = "GameExtend.SceneConfig."
local extend_muduleinit_path = UnityEngine.Application.dataPath .. "/SmallGame/Lua/GameExtend/Config/ConfigInit.lua"
local extend_muduleinit_lua = "GameExtend.Config.ConfigInit"
local extend_mudule_path = UnityEngine.Application.dataPath .. "/SmallGame/Lua/GameExtend/Config/"
local ConfigInit  --用来配置所有需要替换的GameLogic目录下的配置
local nowClock = os.clock()
local checkTime = 120

local function SetClock()
	nowClock = os.clock()
end

local function BaseGetConfig(configName, module_pre, zpath)
	local data = _config_data_dic[configName]	
	if data == nil then
		zpath = zpath or (module_pre .. configName)
		data = {value = require (zpath), time = nowClock, path =  zpath}
		_config_data_dic[configName] = data
	else
		data.time = nowClock
	end
	return data.value
end

function ConfigMgr:__ctor()
	self:LoadConfigInit()
end

function ConfigMgr:Initialize()
	
end

function ConfigMgr:LoadConfigInit()
	if _IsEditor then
		if(ComUtils.FileExists(extend_muduleinit_path)) then
			ConfigInit = require (extend_muduleinit_lua)
		else
			ConfigInit = {}
		end
		local hasChange = false
		local files = ComUtils.GetFiles(extend_mudule_path, "*.lua")
		for i = 0, files.Length - 1 do
			local file = files[i]
			if(not string.contains(file, "ConfigInit")) then
				local fileName = string.replace(file, extend_mudule_path, "")
				fileName = string.gsub(fileName, "%.lua", "")
				local value = extend_module_pre .. fileName
				if(not ConfigInit[fileName]) then
					hasChange = true
				end
				ConfigInit[fileName] = value
			end
		end
		if(hasChange) then
			self:SaveConfigInit()
		end
	else
		ConfigInit = require (extend_muduleinit_lua)
	end
end

local viewData --viewData会常驻内存
function ConfigMgr:GetViewData()
	if(viewData) then
		return viewData
	end
	local gameViewData = require "GameLogic.Config.ViewData"
	local extendViewData = require "GameExtend.Config.ViewData"
	for k, v in pairs(extendViewData) do
		gameViewData[k] = extendViewData[k]
	end
	viewData = gameViewData
	return viewData
end

function ConfigMgr:GetConfig(configName)
	local extend_module = ConfigInit[configName]
	if(extend_module) then
		return BaseGetConfig(configName, extend_module_pre, extend_module)
	else
		return BaseGetConfig(configName, module_pre)
	end
end

function ConfigMgr:GetSceneConfig(configName)
	local data = _config_scene_dic[configName]
	if data == nil then
		local zpath = scene_pre .. configName	
		data = {value = require (zpath), time = nowClock, path =  zpath}
		_config_scene_dic[configName] = data
	else
		data.time = nowClock		
	end
	return data.value
end

function ConfigMgr:ReLoadSceneConfig(configName)
	local data = _config_scene_dic[configName]	
	if data == nil then
		_config_scene_dic[configName] = nil
		package.loaded[data.path] = nil
	end
end

function ConfigMgr:ReLoadConfig(configName)
	local data = _config_data_dic[configName]	
	if data then
		_config_data_dic[configName] = nil
		package.loaded[data.path] = nil
	end
end

function ConfigMgr:ReLoadAll()
	for k, v in pairs( _config_data_dic ) do
		if(v~=nil) then			
			print("================================delete config", k)
			_config_data_dic[k] = nil
			package.loaded[v.path] = nil
		end
	end

	-----------场景配置清除------------
	for k, v in pairs( _config_scene_dic ) do
		if(v~=nil) then			
			print("================================delete Scene config", k)
			_config_scene_dic[k] = nil
			package.loaded[v.path] = nil
		end
	end
end

function ConfigMgr:Update()
	local deltatime = Time.deltaTime
	checkTime = checkTime - deltatime
	SetClock()
	if checkTime > 0 then
		return
	end
	local ztime = nowClock
	local zde = 0
	for k, v in pairs( _config_data_dic ) do
		if(v~=nil) then			
			zde = ztime - v.time
			if zde>=120 then
				-- print("================================delete config:", k)
				_config_data_dic[k] = nil
				package.loaded[v.path] = nil
			end
		end
	end
	
	-----------场景配置清除------------
	for k, v in pairs( _config_scene_dic ) do
		if(v~=nil) then			
			zde = ztime - v.time
			if zde>=120 then
				-- print("================================delete Scene config:", k)
				_config_scene_dic[k] = nil
				package.loaded[v.path] = nil
			end
		end
	end
end

--保存配置
function ConfigMgr:SaveConfigInit()
	local out = {}
	local TimeUtils = require "Common.Utils.TimeUtils"
	table.insert(out, "--------------------------------------------------------------------------------")
	table.insert(out, "--     作者: 运行过程生成，不要自己改！不需要自己改！不需要自己改！")
	table.insert(out, "--     文件描述: 收集GameExtend/Config目录下的所有配置文件,运行过程中加载这里收集的配置去覆盖原有配置")
	table.insert(out, "--     创建时间: "..TimeUtils.GetNormalDateString())
	table.insert(out, "--------------------------------------------------------------------------------")
	table.insert(out, "local data = {")
	for k, v in pairs(ConfigInit) do
		table.insert(out, string.format('\t["%s"] = "%s",',k,v))
	end
	table.insert(out, "}")
	table.insert(out, "return data")
	local dataStr = table.concat(out, '\n')
	Util.WriteAllText(extend_muduleinit_path, dataStr)
end

return ConfigMgr