
--[[
    拆分Utils, Path相关的工具函数都放在这里
    author:xym
    time:2021-02-04 15:44:23
]]
local Application = UnityEngine.Application
local PathUtils = {}

function PathUtils.SpritePath(atlasName, sprName, suffix)
	suffix = suffix or "png"
	return string.format("Atlas/%s/Images/%s.%s", atlasName, sprName, suffix)
end

--获取UITextures下文件路径
function PathUtils.UITexturePath(atlasName, sprName, suffix)
	suffix = suffix or "png"
	return string.format("UITextures/%s/%s.%s", atlasName, sprName, suffix)
end

function PathUtils:GetExtension(path)
	return string.gsub(path, "^.-%.", "", 1)
end

function PathUtils:GetUrlPhotoSavePath()
	return Application.persistentDataPath .. "/Photo/"

end

return PathUtils