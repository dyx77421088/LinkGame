EEvent.Platform = {
    -----------------1到30属于平台的, 小游戏的不要改这里--------------------------
    NetMsg = 1,                 --网络消息 
    SwitchProgress = 16,        --设置加载进度(如小游戏切回平台，有个释放小游戏资源，加载平台资源过程)
    P2G = 23,                   --通用平台通知游戏 (platform 2 small game) 
    G2P = 24,                   --通用游戏通知平台 (small game 2 platform)
    Exception = 25,             --异常
}

EEvent.Common = {
    StartGame = 101,            --开始小游戏
    EndGame = 102,              --小游戏结束
}