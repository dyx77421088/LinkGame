using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif
using UnityEngine.Profiling;
using UnityEngine.UI;
using LuaInterface;
using LuaAPI = LuaInterface.LuaDLL;
using RealStatePtr = System.IntPtr;
using LuaCSFunction = LuaInterface.LuaCSFunction;
using LuaFramework;

/// <summary>
/// author:yjp
/// 专门用来检测是否改变了Lua文件，然后进行热重载，无需重启Unity
/// </summary>
public class LuaWatcher : MonoBehaviour
{
#if UNITY_EDITOR
    private FileSystemWatcher watcher;
    private List<string> changedList = new List<string>();
    private bool showChangeBox;

    private string luaPath = null;
    public string LuaPath
    {
        get
        {
            if (luaPath == null)
            {
                //luaPath = Application.dataPath + "/" + "Lua";
                luaPath = Application.dataPath + "/" + AppConst.GameWorkName + "/Lua";
            }
            return luaPath;
        }
        
    }

    public class ToggleContainer
    {
        public Toggle toggle;
        public Text label;
    }
    public GameObject luaWatcherView;
    private RectTransform ui;
    private Toggle tglPrefab;
    
    private Button btnOK;
    private Button btnCancel;
    private Toggle allToggle;

    [Header(@"是否启用")]
    public bool enableWatcher = true;

    public List<ToggleContainer> tglList = new List<ToggleContainer>();
    private static LuaWatcher mInstance;


    private void Awake()
    {
        //GameObject.DontDestroyOnLoad(gameObject);

        //if (mInstance != null)
        //{
        //    GameObject.Destroy(gameObject);
        //    return;
        //}
        
        mInstance = this;
        if (luaWatcherView == null)
            return;
        ui = GameObject.Instantiate(luaWatcherView).GetComponent<RectTransform>();
        ui.SetParent(GameObject.Find("UIRoot").transform);
        ui.gameObject.SetActive(false);
        //gameObject.AddComponent<CanvasRenderer>();
        //gameObject.AddComponent<GraphicRaycaster>();
        //gameObject.SetLayerDeep("UIIgnorePP");
        Vector3 pos = ui.localPosition;
        pos.z = 0;
        ui.localPosition = pos;
        ui.anchorMin = Vector2.zero;
        ui.anchorMax = Vector2.one;
        ui.offsetMax = Vector2.zero;
        ui.offsetMin = Vector2.zero;
        ui.localScale = Vector3.one;

        tglPrefab = ui.Find("ScrollView/Viewport/Content/Toggle").GetComponent<Toggle>();
        tglPrefab.gameObject.SetActive(false);

        btnOK = ui.Find("certainBtn").GetComponent<Button>();
        btnCancel = ui.Find("cancelBtn").GetComponent<Button>();

        allToggle = ui.Find("AllToggle").GetComponent<Toggle>();

        btnOK.onClick.AddListener(OnClickOK);
        btnCancel.onClick.AddListener(OnClickCancel);
        allToggle.onValueChanged.AddListener(OnAllToggleValueChanged);
        CloseUI();
    }

    public void Start()
    {
#if UNITY_STANDALONE_WIN && UNITY_EDITOR 
        enableWatcher = true;
#endif
#if UNITY_EDITOR && !UNITY_EDITOR_OSX
        // Profiler.enabled 当启动Profiler的时候不启动这个，不然的话，在[deep profiler]下，内存会暴涨
        if (enableWatcher && !Profiler.enabled)
        {
            OpenWatcher();
        }
#endif
    }

    public void Update()
    {
        lock (changedList)
        {
            if (showChangeBox && changedList.Count > 0)
            {
                showChangeBox = false;

                OpenUI();
            }
        }
    }

    private void OnAllToggleValueChanged(bool isOn)
    {
        for (int i = 0; i < tglList.Count; i++)
        {
            tglList[i].toggle.isOn = isOn;
        }
    }

    private void OnClickCancel()
    {
        CloseUI();
    }

    private void OnClickOK()
    {
        List<string> reloadList = new List<string>();

        for (int i = tglList.Count - 1; i >= 0; i--)
        {
            if (tglList[i].toggle.isOn)
            {
                reloadList.Add(changedList[i]);
                changedList.RemoveAt(i);
            }
        }

        Reload(reloadList);
        CloseUI();
    }


    public void Reload(List<string> reloadList)
    {
        if (reloadList == null || reloadList.Count == 0)
            return;

        AssetDatabase.Refresh();

        foreach (var path in reloadList)
        {
            try
            {
                Debug.Log("Lua Reload: " + path);
                ReLoadLua(path);
            }
            catch (Exception e)
            {
                Debug.LogError(e);
            }
        }
    }


    public void OpenUI()
    {
        if (ui != null)
        {
            LoadChangedList();
            ui.transform.SetAsLastSibling();
            GameObject parent = GameObject.Find("UIRoot/Top");
            if (parent)
                ui.transform.SetParent(parent.transform);
            ui.gameObject.layer = LayerMask.NameToLayer("UI");
            ui.gameObject.SetActive(true);
            ui.GetComponent<Canvas>().sortingOrder = 10000;
            ui.GetComponent<Canvas>().overrideSorting = true;
        }
    }

    public void CloseUI()
    {
        if (ui != null)
        {
            ui.gameObject.SetActive(false);
        }
    }

    private void LoadChangedList()
    {
        if (changedList.Count < tglList.Count)
        {
            for (int i = changedList.Count; i < tglList.Count; i++)
            {
                GameObject.Destroy(tglList[i].toggle.gameObject);
            }

            tglList.RemoveRange(changedList.Count, tglList.Count - changedList.Count);
        }
        else if (changedList.Count > tglList.Count)
        {
            for (int i = tglList.Count; i < changedList.Count; i++)
            {
                var go = GameObject.Instantiate(tglPrefab.gameObject, tglPrefab.transform.parent);
                go.SetActive(true);
                var tgl = go.GetComponent<Toggle>();
                var label = go.transform.Find("Label").GetComponent<Text>();
                ToggleContainer tc = new ToggleContainer()
                {
                    toggle = tgl,
                    label = label,
                };
                tglList.Add(tc);
            }
        }

        for (int i = 0; i < changedList.Count; i++)
        {
            var pos = changedList[i].IndexOf("\\Lua");
            var tc = tglList[i];
            tc.toggle.isOn = true;
            tc.label.text = changedList[i].Substring(pos+4);
        }
    }


    private void ReLoadLua(string path)
    {
        LuaManager luaMgr = GameObject.Find("AppGameManager").GetComponent<LuaManager>();
        LuaState luaState = luaMgr.GetLuaState();
        path = path.Replace('\\', '/');
        string chunkName = path.Replace(LuaPath + "/", "").Replace(".lua", "");
        string moduleName = chunkName.Replace('/', '.');

        //luaState.DoString(string.Format("reload_module '{0}'", moduleName));
        LuaFunction newObjFnc = luaState.GetFunction("reload_module");
        if (newObjFnc == null) return;

        //获取相关lua类型
        newObjFnc.Invoke<string, bool>(moduleName);
        newObjFnc.Dispose();
    }

    public void OpenWatcher()
    {
        if (watcher != null)
        {
            watcher.EnableRaisingEvents = false;
            watcher.Dispose();
            watcher = null;
        }

        if (!Directory.Exists(LuaPath))
            return;

        watcher = new FileSystemWatcher(LuaPath, "*.lua");
        watcher.IncludeSubdirectories = true;
        watcher.Created += OnChanged;
        watcher.Changed += OnChanged;
        watcher.EnableRaisingEvents = true;
    }

    private void OnChanged(object sender, FileSystemEventArgs e)
    {
        lock (changedList)
        {
            bool existed = false;
            
            for (int i = 0; i < changedList.Count; i++)
            {
                if (changedList[i] == e.FullPath)
                {
                    existed = true;
                    break;
                }
            }

            if (!existed)
            {
                changedList.Add(e.FullPath);
            }

            showChangeBox = true;
        }
    }

    private void OnDestroy()
    {
        if(ui)
            GameObject.Destroy(ui.gameObject);
        if (watcher != null)
        {
            watcher.EnableRaisingEvents = false;
            watcher.Dispose();
        }
    }
#endif
}
