local SoundMgr = Singleton("SoundMgr")

local musicVolume = 1
local effectVolume = 1

function SoundMgr:__ctor()
	self.loadedMgr = false
	self.cur_musicId = 0
	self.freqMusics = {}
	self.stopEffectCache = {}
end

function SoundMgr:__delete()
	GameObject.Destroy(self.mgrGo)
	for id, clip in pairs(self.freqMusics) do
		Globals.resMgr:UnloadAssetBundle(id, true)
	end
	self.freqMusics = nil
end

function SoundMgr:Initialize()
    self.onLoadedLoading = LMessage:Register(LuaEvent.Loading.LoadedLoading, "OnLoadedLoading", self)
	self:LoadExtraSoundConfig()
end

function SoundMgr:LoadExtraSoundConfig()
	if(not ComUtils.IsTestSound()) then
		return
	end
	local soundParam = ComUtils.GetTestSoundParm()
	if(ComUtils.FileExists(self:GetExtraDataPath())) then
		self.soundData = require("SoundData")
	else
		self.soundData = nil
	end
end

function SoundMgr:GetExtraDataPath()
	return UnityEngine.Application.dataPath .. "/../game/heima/import/lua/SoundData.lua"
end

function SoundMgr:Enable(bFlag)
	self.enableMusic = bFlag
	if self.mgrGo then
		self.mgrGo:SetActive(bFlag)
	end
end

function SoundMgr:OnLoadedLoading()
	if(self.onLoadedLoading) then
		LMessage:UnRegister(LuaEvent.Loading.LoadedLoading, self.onLoadedLoading)
	end
	self:StartLoad()
end

function SoundMgr:StartLoad(onLoad)
	LMessage:Dispatch(LuaEvent.Loading.AddNeedLoad, 1)
	Globals.resMgr:LoadResource("Prefab/SoundMgr/SoundMgr", function(obj)
		if self.mgrGo == nil then
			self.mgrGo = GameObject.Instantiate(obj)
			self.mgrGo:SetActive(self.enableMusic)
		end
		self.audioSource = self.mgrGo.transform:Find("Music"):GetComponent("AudioSource")
		self.audioSource.loop = true
		self.audioVolume = 1
		self.effectSource = {}
		self.effectVolume = {}
		self.effectTrans = self.mgrGo.transform:Find("Effect") 
		for i = 1, self.effectTrans.childCount do
			self.effectSource[i] = self.effectTrans:GetChild(i-1):GetComponent("AudioSource")
			self.effectVolume[i] = 1
		end
		self:UpdateVolume()
		if(self.loadComplete) then
			self.loadComplete()
		end
		--下一帧再执行,防止本地加载时其他还没开始加载
		Globals.timerMgr:AddTimer(function()
			LMessage:Dispatch(LuaEvent.Loading.AddLoaded, 1)
		end, 0, 0)
	end)
end


function SoundMgr:GetVolume()
	local soundParam = Globals.gameModel:GetSoundParam()
	local platMusic = soundParam.platMusic or 0.3
	local platEffect = soundParam.platEffect or 0.3
	local gameMusic = soundParam.gameMusic or 1
	local gameEffect = soundParam.gameEffect or 1
	local demoSound = soundParam.demoSound or 0
	musicVolume = platMusic * gameMusic
	effectVolume = platEffect * gameEffect
	
	return gameMusic, gameEffect, platMusic, platEffect, demoSound
end

function SoundMgr:SetVolume(music, effect)
	Globals.gameModel:SetSoundParam(music, effect)
	self:UpdateVolume()
end

function SoundMgr:UpdateVolume()
	self:GetVolume()
	if self.audioSource then
		self.audioSource:DOKill()
		self.audioSource.volume = musicVolume * self.audioVolume
	end

	if self.effectSource then
		for key, source in pairs(self.effectSource) do
			source:DOKill()
			source.volume = effectVolume * self.effectVolume[key]
		end
	end
end

function SoundMgr:PlayMusic(soundAsset, forceOriginal)
	if type(soundAsset) == "string" then
		soundAsset = {id = soundAsset}
	end
	if not soundAsset then
		return
	end
	
	if not self.audioSource then
		self.loadComplete = function()
			self:PlayMusic(soundAsset.id, soundAsset.volume)
		end
		return
	end
	self.cur_musicId = soundAsset.id
	local zfunc = function(clip, path)
		self.freqMusics[soundAsset.id] = clip
		--遇到还没加载完该音乐就被切换为其他音乐的情况
		if(self.cur_musicId ~= path) then
			return
		end
		if self.audioSource.isPlaying and self.audioSource.clip ~= clip then
			self.audioSource:DOKill()
			self.audioSource:DOFade(0, 0.5):OnComplete(function()
				self.audioSource.clip = clip
				self.audioVolume = soundAsset.volume or 1
				self.audioSource:Play()
				self.audioSource:DOFade(musicVolume * self.audioVolume, 0.5)
			end):OnKill(function()
				self.audioSource.clip = clip
				self.audioSource:Play()
			end)
		elseif not self.audioSource.isPlaying then
			self.audioSource:DOKill()
			self.audioSource.clip = clip
			self.audioSource.volume = 0
			self.audioVolume = soundAsset.volume or 1
			self.audioSource:Play()
			self.audioSource:DOFade(musicVolume * self.audioVolume, 0.5)
		end
	end
	if not self.freqMusics[soundAsset.id] then
		if(not forceOriginal and self.soundData and self.soundData[soundAsset.id]) then
			soundAsset.id = self.soundData[soundAsset.id].replaceRes
			Globals.resMgr:LoadExtraAudio(soundAsset.id, zfunc)
		else
			Globals.resMgr:LoadResource(soundAsset.id, zfunc)
		end
	else
		zfunc(self.freqMusics[soundAsset.id], soundAsset.id)
	end
end

function SoundMgr:StopMusic()
	if self.audioSource then
		self.audioSource:DOKill()
		self.audioSource:DOFade(0, 0.5):OnComplete(function()
			self.audioSource:Stop()
		end):OnKill(function()
			self.audioSource.volume = 0
			self.audioSource:Stop()
		end)
	end
end

function SoundMgr:PauseMusic()
	if self.audioSource then
		self.audioSource:DOKill()
		self.audioSource:DOFade(0, 0.5):OnComplete(function()
			self.audioSource:Pause()
		end):OnKill(function()
			self.audioSource.volume = 0
			self.audioSource:Pause()
		end)
	end
end

function SoundMgr:ResumeMusic()
	if self.audioSource then
		self.audioSource:DOKill()
		self.audioSource.volume = 0
		self.audioSource:Play()
		self.audioSource:DOFade(musicVolume * self.audioVolume, 0.5)
	end
end

function SoundMgr:FadeMusic(volume, duration)
	if self.audioSource then
		self.audioSource:DOKill()
		self.audioVolume = volume or 1
		duration = duration or 0.5
		self.audioSource:DOFade(musicVolume * self.audioVolume, duration)
	end
end

--isExtra是否是外部音效，专门用来测试替换音效用
function SoundMgr:PlayEffectBase(id, loop, volume, isExtra)
	local function play(id, clip, loop, volume)
		if not self.effectSource then
			return
		end	
		for key, source in ipairs(self.effectSource) do
			if not source.isPlaying then
				source.loop = loop or false
                source.clip = clip
				self.effectVolume[key] = volume or 1
				source.volume = effectVolume * self.effectVolume[key]
				source:Play()
				return
			end
		end
		--如果全部都在播放 则实例化一个
		local len = #self.effectSource
		self.effectSource[len + 1] = GameObject.Instantiate(self.effectSource[1].gameObject, self.effectTrans).transform:GetComponent("AudioSource")
		self.effectVolume[len + 1] = volume or 1
		self.effectSource[len + 1].loop = loop or false
		self.effectSource[len + 1].clip = clip
		self.effectSource[len + 1].volume = effectVolume * self.effectVolume[len + 1]
		self.effectSource[len + 1]:Play()
		return
	end
	if(isExtra) then
		Globals.resMgr:LoadExtraAudio(id, function(clip, path)
			-- self.freqMusics[id] = clip 外部音效先不缓存了，每次都重新加载
			if(self.stopEffectCache[id]) then
				self.stopEffectCache[id] = false
				return
			end
			play(id, clip, loop, volume)
		end)
	elseif self.freqMusics[id] then
		play(id, self.freqMusics[id], loop, volume)
	else
		Globals.resMgr:LoadResource(id, function(clip, path)
			if(not self.freqMusics) then --SoundMgr已经被销毁
				Globals.resMgr:UnloadAssetBundle(id, true)
				return
			end
			self.freqMusics[id] = clip
			if(self.stopEffectCache[id]) then
				self.stopEffectCache[id] = false
				return
			end
			play(id, clip, loop, volume)
		end)
	end
end

function SoundMgr:PlayEffect(soundAsset, forceOriginal)
	if type(soundAsset) == "string" then
		soundAsset = {id = soundAsset}
	end
	if not soundAsset then
		return
	end
	
	if self.stopEffectCache[soundAsset.id] then
		self.stopEffectCache[soundAsset.id] = false
	end
	local extra = false
	if(not forceOriginal and self.soundData and self.soundData[soundAsset.id]) then
		soundAsset.id = self.soundData[soundAsset.id].replaceRes
		extra = true
	end
	if not soundAsset.delay or soundAsset.delay <= 0 then
		if soundAsset.musicVol then
			self:FadeMusic(soundAsset.musicVol, soundAsset.duration)
		end
		self:PlayEffectBase(soundAsset.id, soundAsset.loop, soundAsset.volume, extra)
	else
		Globals.timerMgr:AddTimer(function()
			if soundAsset.musicVol then
				self:FadeMusic(soundAsset.musicVol, soundAsset.duration)
			end
			self:PlayEffectBase(soundAsset.id, soundAsset.loop, soundAsset.volume, extra)
		end, 0, soundAsset.delay)
	end
end

--停止某个音效(这个方法可能会有问题，把名字为id的所有音效都停了，不过目前应该暂时满足需求，停的都是长音效，而且同时只会单个播放的)
function SoundMgr:StopEffect(soundAsset)
	if type(soundAsset) == "string" then
		soundAsset = {id = soundAsset}
	end
	if not self.effectSource or not soundAsset then
		return
	end
	
	local clip = self.freqMusics[soundAsset.id]
	--还没加载出来音效就被停了，需要缓存一下
	if not clip then
		self.stopEffectCache[soundAsset.id] = true
		return 
	end
	for _, source in ipairs(self.effectSource) do
		if source.clip == clip then
			source.loop = false
			source:Stop()
		end
	end
end

function SoundMgr:PlayExtraEffect(id, loop, volume, delay)
	if not id then
		return
	end
	
	if(self.stopEffectCache[id]) then
		self.stopEffectCache[id] = false
	end
	if(not delay or delay <= 0) then
		self:PlayEffectBase(id, loop, volume, true)
	else
		Globals.timerMgr:AddTimer(callback(self, "PlayEffectBase", id, loop, volume), 0, delay)
	end
end

function SoundMgr:StopExtraEffect(id)
	if not id then
		return
	end
	
	for _, source in ipairs(self.effectSource) do
		if source.isPlaying then
			source.loop = false
			source:Stop()
		end
	end
end

return SoundMgr