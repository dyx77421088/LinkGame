--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:用来存储本地数据 键值对的形式，类似于Unity PlayerRef
--     创建时间:2021/10/28 
--------------------------------------------------------------------------------
local cjson = require "cjson"
local DelayCallBase = require "Common.Base.DelayCallBase"
local IOMgr = Singleton("IOMgr", DelayCallBase)
local gameDataDir = Util.GetDataPath(1)

function IOMgr:__ctor()
	-- DelayCallBase.__ctor(self)
	self.cache = {}
	-- self.persistentDataPath = UnityEngine.Application.PersistentDataPath
	-- self.assetDataPath = UnityEngine.Application.dataPath
end

function IOMgr:Initialize()

end

function IOMgr:GetGameDataPath(gameName)
	return gameDataDir .. gameName .. ".json"
end

function IOMgr:LoadData(gameName)
	local filePath = self:GetGameDataPath(gameName)
	local data
	if Util.IsFileExist(filePath) then
		--TODO 异常 catch  
		local tmpFile = assert(io.open(filePath, 'r'));
		local content = tmpFile:read("*a");
		data = cjson.decode(content);
		tmpFile:close();
		tmpFile = nil;
	end
	print("IOMgr加载文件:", filePath)
	if(not data) then
		data = {}
	end
	return data
end

function IOMgr:GetValue(gameName, key, defaultValue)
	print("IOMgr获取数据:", gameName, key, defaultValue)
	if(not self.cache[gameName]) then
		self.cache[gameName] = self:LoadData(gameName)
	end
	return self.cache[gameName][key] or defaultValue
end

function IOMgr:SetValue(gameName, key, value)
	if(not self.cache[gameName]) then
		self.cache[gameName] = self:LoadData(gameName)
	end
	self.cache[gameName][key] = value
	local filePath = self:GetGameDataPath(gameName)
	local tmpFile = io.open(filePath, 'w');
	local data = self.cache[gameName]
	local content = cjson.encode(data);
	if(not tmpFile) then
		printext("路径不存在：", filePath)
	end
	tmpFile:write(content);
	tmpFile:flush();
	tmpFile:close();
	tmpFile = nil;
	print("IOMgr保存数据:", gameName, key, value, self:GetGameDataPath(gameName))
end

function IOMgr:__delete()

end

return IOMgr