/**
 * 
 * 	标题：
 * 
 *	说明：
 * 
 * 
 * 
 * 
 */




using UnityEngine;
using UnityEditor;
using System.IO;



/// <summary>
/// 注意：1、根据已切割好的图集自动生成的Custom Text要手动调整lineSpacing已达到分行效果(自测)
/// 2、图集必须放于Resouces文件夹下
/// 3、图集切割出来的小图片的名称一定是要写上对应数字的ASCII码，例如：图片"0"  名称就是48，1 就是 49  直至9 是 57，中文的话 ///没有ASCII码故无法使用这种方法来自动化生成，不过有插件
/// 使用方法：拖拽图集、写上生成的字体名字、选择保存路径，点击创建
/// 测试方法：创建Text，将生成的font拖到font属性，打0~9数字，然后调整lineSpacing，每次调整完后需清空，再次打数字
/// </summary>
public class CreateFont : EditorWindow
{
    [MenuItem("Tools/创建字体(sprite)")]
    public static void Open()
    {
        GetWindow<CreateFont>("创建字体");
    }

    private Texture2D tex;
    private string fontName;
    private string fontPath;

    private void OnGUI()
    {
        GUILayout.BeginVertical();

        GUILayout.BeginHorizontal();
        GUILayout.Label("字体图片：");
        tex = (Texture2D)EditorGUILayout.ObjectField(tex, typeof(Texture2D), true);
        GUILayout.EndHorizontal();

        GUILayout.BeginHorizontal();
        GUILayout.Label("字体名称：");
        fontName = EditorGUILayout.TextField(fontName);
        GUILayout.EndHorizontal();

        GUILayout.BeginHorizontal();
        if (GUILayout.Button(string.IsNullOrEmpty(fontPath) ? "选择路径" : fontPath))
        {
            fontPath = EditorUtility.OpenFolderPanel("字体路径", Application.dataPath, "");
            if (string.IsNullOrEmpty(fontPath))
            {
                Debug.Log("取消选择路径");
            }
            else
            {
                fontPath = fontPath.Replace(Application.dataPath, "") + "/";
            }
        }
        GUILayout.EndHorizontal();

        GUILayout.BeginHorizontal();
        if (GUILayout.Button("创建"))
        {
            Create();
        }
        GUILayout.EndHorizontal();

        GUILayout.EndVertical();
    }

    private void Create()
    {
        if (tex == null)
        {
            Debug.LogWarning("创建失败，图片为空！");
            return;
        }

        if (string.IsNullOrEmpty(fontPath))
        {
            Debug.LogWarning("字体路径为空！");
            return;
        }
        if (fontName == null)
        {
            Debug.LogWarning("创建失败，字体名称为空！");
            return;
        }
        else
        {
            if (File.Exists(Application.dataPath + fontPath + fontName + ".fontsettings"))
            {
                Debug.LogError("创建失败，已存在同名字体文件");
                return;
            }
            if (File.Exists(Application.dataPath + fontPath + fontName + ".mat"))
            {
                Debug.LogError("创建失败，已存在同名字体材质文件");
                return;
            }
        }

        string selectionPath = AssetDatabase.GetAssetPath(tex);
        if (selectionPath.Contains("/Resources/"))
        {
            string selectionExt = Path.GetExtension(selectionPath);
            if (selectionExt.Length == 0)
            {
                Debug.LogError("创建失败！");
                return;
            }

            string fontPathName = fontPath + fontName + ".fontsettings";
            string matPathName = fontPath + fontName + ".mat";
            float lineSpace = 0.1f;
            //string loadPath = selectionPath.Remove(selectionPath.Length - selectionExt.Length).Replace("Assets/Resources/", "");
            string loadPath = selectionPath.Replace(selectionExt, "").Substring(selectionPath.IndexOf("/Resources/") + "/Resources/".Length);
            Sprite[] sprites = Resources.LoadAll<Sprite>(loadPath);
            if (sprites.Length > 0)
            {
                Material mat = new Material(Shader.Find("GUI/Text Shader"));
                mat.SetTexture("_MainTex", tex);
                Font m_myFont = new Font();
                m_myFont.material = mat;
                CharacterInfo[] characterInfo = new CharacterInfo[sprites.Length];
                for (int i = 0; i < sprites.Length; i++)
                {
                    if (sprites[i].rect.height > lineSpace)
                    {
                        lineSpace = sprites[i].rect.height;
                    }
                }
                for (int i = 0; i < sprites.Length; i++)
                {
                    Sprite spr = sprites[i];
                    CharacterInfo info = new CharacterInfo();
                    try
                    {
                        info.index = System.Convert.ToInt32(spr.name);
                    }
                    catch
                    {
                        Debug.LogError("创建失败，Sprite名称错误！");
                        return;
                    }
                    Rect rect = spr.rect;
                    float pivot = spr.pivot.y / rect.height - 0.5f;
                    if (pivot > 0)
                    {
                        pivot = -lineSpace / 2 - spr.pivot.y;
                    }
                    else if (pivot < 0)
                    {
                        pivot = -lineSpace / 2 + rect.height - spr.pivot.y;
                    }
                    else
                    {
                        pivot = -lineSpace / 2;
                    }
                    int offsetY = (int)(pivot + (lineSpace - rect.height) / 2);
                    info.uvBottomLeft = new Vector2((float)rect.x / tex.width, (float)(rect.y) / tex.height);
                    info.uvBottomRight = new Vector2((float)(rect.x + rect.width) / tex.width, (float)(rect.y) / tex.height);
                    info.uvTopLeft = new Vector2((float)rect.x / tex.width, (float)(rect.y + rect.height) / tex.height);
                    info.uvTopRight = new Vector2((float)(rect.x + rect.width) / tex.width, (float)(rect.y + rect.height) / tex.height);
                    info.minX = 0;
                    info.minY = -(int)rect.height - offsetY;
                    info.maxX = (int)rect.width;
                    info.maxY = -offsetY;
                    info.advance = (int)rect.width;
                    characterInfo[i] = info;
                }
                AssetDatabase.CreateAsset(mat, "Assets" + matPathName);
                AssetDatabase.CreateAsset(m_myFont, "Assets" + fontPathName);
                m_myFont.characterInfo = characterInfo;
                EditorUtility.SetDirty(m_myFont);
                AssetDatabase.SaveAssets();
                AssetDatabase.Refresh();//刷新资源
                Debug.Log("创建字体成功");

            }
            else
            {
                Debug.LogError("图集错误！");
            }
        }
        else
        {
            Debug.LogError("创建失败,选择的图片不在Resources文件夹内！");
        }
    }
}

