using UnityEngine;
using LuaFramework;
using System.IO;

enum ScreenRotate
{
    Horizontal = 0,
    Verticle = 90,
    HorizontalFlip = 180,
    VerticleFlip = 270,
}

public class Main : MonoBehaviour
{
    [SerializeField]
    [Header("屏幕旋转方式")]
    ScreenRotate screen = ScreenRotate.Horizontal;

    [SerializeField]
    [Header("是否从AB包加载资源")]
    bool loadAssetBundle = false;


    void Start()
    {
        ReadConfig();
        int angle = (int)screen;
        Util.SetPrefs("ScreenFlip", angle.ToString());
        Util.FlipScreen(angle);
        AppFacade.GetApp(FaceType.eGame).StartUp();   //启动游戏
        AppConst.LOADLOCALRES = !loadAssetBundle;
    }

    void ReadConfig()
    {
        string[] lines = File.ReadAllLines(Application.dataPath + "/pack/config.txt");
        foreach (var line in lines)
        {
            if (string.IsNullOrEmpty(line.Trim()))
                continue;

            string[] items = line.Split(new char[] { '=' });
            if (items.Length < 2)
            {
                continue;
            }
            string key = items[0].Trim();
            string value = items[1].Substring(0, items[1].IndexOf("//")).Trim();
            if (key == "gameName")
            {
                AppConst.GameName = value;
            }
        }
    }
}