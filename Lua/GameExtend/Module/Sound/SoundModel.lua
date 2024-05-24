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
	Button_Slot = {id = "Sound/Effect/Button/Button_Slot"},
	Button_Bet = {id = "Sound/Effect/Button/Button_Bet"},
	Button_MaxBet = {id = "Sound/Effect/Button/Button_MaxBet"},
	Button_Preview = {id = "Sound/Effect/Button/Button_Preview"},
	Button_Info = {id = "Sound/Effect/Button/Button_Info"},
	Button_Voice = {id = "Sound/Effect/Button/Button_Voice"},
	Button_Introduce = {id = "Sound/Effect/Button/Button_Introduce"},
	Button_Back = {id = "Sound/Effect/Button/Button_Back"},
	
	--Scroll 滚动音效
	Scroll_BGM = {id = "Sound/Effect/Scroll/Scroll_BGM", musicVol = 0.85},
	Scroll_Down = {id = "Sound/Effect/Scroll/Scroll_Down"},
	Scroll_Down_12 = {id = "Sound/Effect/Scroll/Scroll_Down_12"},
	Scroll_Win = {id = "Sound/Effect/Scroll/Scroll_Win", musicVol = 0.5},
	Scroll_Win_12 = {id = "Sound/Effect/Scroll/Scroll_Win_12", musicVol = 0.5},
	Scroll_Focus_On = {id = "Sound/Effect/Scroll/Scroll_Focus_On", musicVol = 0.5},
	Scroll_Focus_Move = {id = "Sound/Effect/Scroll/Scroll_Focus_On", musicVol = 0.5},
	
	--BigWin BIGWIN音效
	BigWin_On = {id = "Sound/Effect/BigWin/BigWin_On"},
	BigWin_Number_On = {id = "Sound/Effect/BigWin/BigWin_Number_On"},
	BigWin_Number_Off = {id = "Sound/Effect/BigWin/BigWin_Number_Off"},
	
	--Transition 过渡音效
	Transition_Free_On = {id = "Sound/Effect/Transition/Transition_Free_On"},
	Transition_Free_Tip_On = {id = "Sound/Effect/Transition/Transition_Free_Tip_On"},
	Transition_Free_Tip_Number = {id = "Sound/Effect/Transition/Transition_Free_Tip_Number"},
	Transition_Free_Tip_Off = {id = "Sound/Effect/Transition/Transition_Free_Tip_Off"},
	
	--Effect 特效音效
	Effect_Win_1 = {id = "Sound/Effect/Effect/Effect_Win_1", musicVol = 0.3},
	Effect_Win_2 = {id = "Sound/Effect/Effect/Effect_Win_2", musicVol = 0.3},
	Effect_Coin_On = {id = "Sound/Effect/Effect/Effect_Coin_On", musicVol = 0.5},
	Effect_Coin_Rotate = {id = "Sound/Effect/Effect/Effect_Coin_Rotate"},
	Effect_Coin_Off = {id = "Sound/Effect/Effect/Effect_Coin_Off"},
	Effect_Wheel_On = {id = "Sound/Effect/Effect/Effect_Wheel_On", musicVol = 0.3},
	Effect_Wheel_Rotate = {id = "Sound/Effect/Effect/Effect_Wheel_Rotate"},
	Effect_Wheel_Win = {id = "Sound/Effect/Effect/Effect_Wheel_Win"},
	Effect_Wheel_Off = {id = "Sound/Effect/Effect/Effect_Wheel_Off"},
	
	--Music 背景音乐
	Music_Normal = {id = "Sound/Music/Music_Normal", volume = 1},
	Music_Free = {id = "Sound/Music/Music_Free"},
	Music_BigWin = {id = "Sound/Music/Music_BigWin"},
}

function SoundModel:__ctor()
	
end


return SoundModel