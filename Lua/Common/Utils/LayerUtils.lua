--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:游戏对象layer层级管理，Layer相关的工具函数请放在这里
--     创建时间:09/23/2020 
--------------------------------------------------------------------------------
local LayerMask = UnityEngine.LayerMask
local LayerUtils = {}
	
LayerUtils.Default = LayerMask.NameToLayer("Default")
LayerUtils.Water = LayerMask.NameToLayer("Water")
LayerUtils.UI = LayerMask.NameToLayer("UI")
LayerUtils.PostProcessing = LayerMask.NameToLayer("PostProcessing")
LayerUtils.RenderTexture = LayerMask.NameToLayer("RenderTexture")
LayerUtils.RenderCamera = LayerMask.NameToLayer("RenderCamera")
LayerUtils.Skin = LayerMask.NameToLayer("Skin")
LayerUtils.Character = LayerMask.NameToLayer("Character")
LayerUtils.Ground = LayerMask.NameToLayer("Ground")
LayerUtils.Occlusion = LayerMask.NameToLayer("Occlusion")
LayerUtils.Hide = LayerMask.NameToLayer("Hide")

function LayerUtils.GetSceneCameraDefaultLayer()
    --排除ui跟hideui
    return LayerUtils.GetLayerNoMask(LayerUtils.UI)
end

function LayerUtils.GetLayerMask(...) 
    local args = {...}
    local result = 0
    local mask = 0
    for _, v in ipairs(args) do
        mask = bit.lshift(1, v)
        result = bit.bor(result, mask)
    end
    return result
end

function LayerUtils.GetLayerNoMask(...)   
    local mask = LayerUtils.GetLayerMask (...)
    return bit.bnot(mask)
end


function LayerUtils:AddLayer(mask, layer)
    layer = bit.lshift(1, layer)
    layer = bit.bor(mask, layer)
	return layer
end

function LayerUtils:RemoveLayer(mask, layer)
    layer = bit.lshift(1, layer)
    layer = bit.band(mask, bit.bnot(layer))
	return layer
end


return LayerUtils