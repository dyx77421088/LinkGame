--------------------------------------------------------------------------------
--     作者:yhj
--     文件描述:音效控制模块Model，用来记录音效播放的数据
--     创建时间:2024/01/20 
--------------------------------------------------------------------------------
local SoundModel = Singleton("SoundModel")

Const.SoundType = {
	--Button 按键音效
	Button_Normal = {id = "Sound/Effect/Button/Button_Normal"},
	Button_Spin = {id = "Sound/Effect/Button/Button_Spin"},
	Button_Stop = {id = "Sound/Effect/Button/Button_Stop"},
	Button_Start = {id = "Sound/Effect/Button/Button_Start"},
	Button_Take = {id = "Sound/Effect/Button/Button_Take"},
	Button_Auto = {id = "Sound/Effect/Button/Button_Auto"},
	Button_StopAuto = {id = "Sound/Effect/Button/Button_StopAuto"},
	Button_Slot = {id = "Sound/Effect/Button/Button_Slot"},
	Button_Bet = {id = "Sound/Effect/Button/Button_Bet"},
	Button_MaxBet = {id = "Sound/Effect/Button/Button_MaxBet"},
	Button_Preview = {id = "Sound/Effect/Button/Button_Preview"},
	Button_Info = {id = "Sound/Effect/Button/Button_Info"},
	Button_Voice = {id = "Sound/Effect/Button/Button_Voice"},
	Button_Introduce = {id = "Sound/Effect/Button/Button_Introduce"},
	Button_SwitchPage = {id = "Sound/Effect/Button/Button_SwitchPage"},
	Button_Back = {id = "Sound/Effect/Button/Button_Back"},
	
	--Scroll 滚动音效
	Scroll_BGM = {id = "Sound/Effect/Scroll/Scroll_BGM", musicVol = 0.85},
	Scroll_Down = {id = "Sound/Effect/Scroll/Scroll_Down"},
	Scroll_Win = {id = "Sound/Effect/Scroll/Scroll_Win", musicVol = 0.5},
	Scroll_Focus_On = {id = "Sound/Effect/Scroll/Scroll_Focus_On", musicVol = 0.5},
	Scroll_Focus_Move = {id = "Sound/Effect/Scroll/Scroll_Focus_Move"},
	Scroll_Focus_Off = {id = "Sound/Effect/Scroll/Scroll_Focus_Off"},
	
	--BigWin BIGWIN音效
	BigWin_On = {id = "Sound/Effect/BigWin/BigWin_On"},
	BigWin_Number_On = {id = "Sound/Effect/BigWin/BigWin_Number_On"},
	BigWin_Number_Off = {id = "Sound/Effect/BigWin/BigWin_Number_Off"},
	BigWin_Off = {id = "Sound/Effect/BigWin/BigWin_Off"},
	
	--Transition 过渡音效
	Transition_Normal_On = {id = "Sound/Effect/Transition/Transition_Normal_On"},
	Transition_Normal_Off = {id = "Sound/Effect/Transition/Transition_Normal_Off"},
	Transition_Free_On = {id = "Sound/Effect/Transition/Transition_Free_On"},
	Transition_Free_Off = {id = "Sound/Effect/Transition/Transition_Free_Off"},
	Transition_Bonus_On = {id = "Sound/Effect/Transition/Transition_Bonus_On"},
	Transition_Bonus_Off = {id = "Sound/Effect/Transition/Transition_Bonus_Off"},
	Transition_Link_On = {id = "Sound/Effect/Transition/Transition_Link_On"},
	Transition_Link_Off = {id = "Sound/Effect/Transition/Transition_Link_Off"},
	
	--Effect 特效音效
	Effect_Win = {id = "Sound/Effect/Effect/Effect_Win", musicVol = 0.3},
	
	--Music 背景音乐
	Music_Normal = {id = "Sound/Music/Music_Normal"},
	Music_Free = {id = "Sound/Music/Music_Free"},
	Music_Bonus = {id = "Sound/Music/Music_Bonus"},
	Music_Link = {id = "Sound/Music/Music_Link"},
	Music_BigWin = {id = "Sound/Music/Music_BigWin"},
}

function SoundModel:__ctor()
	
end


return SoundModel