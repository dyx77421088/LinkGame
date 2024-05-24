--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:Loading加载模块Model，用来记录加载过程中的数据
--     创建时间:2022/04/23 
--------------------------------------------------------------------------------
local LoadingModel = Singleton("LoadingModel")

function LoadingModel:__ctor()
    self.needLoad = 0--需要加载的总的资源数目
    self.loaded = 0 --已经加载完的资源数目
end

function LoadingModel:InitComplete()
    
end

return LoadingModel