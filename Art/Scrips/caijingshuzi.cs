using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class caijingshuzi : MonoBehaviour {

	public Transform grand;
	public Transform mega;
	public Transform makor;
	public Transform minor;
	public Transform mini;
	public Demo.NumberManager numberManager;
	// Use this for initialization
	void Start () {
		
	}
	void Awake()
    {
		numberManager.grand.Init(grand);
		numberManager.mega.Init(mega);
		numberManager.major.Init(makor);
		numberManager.minor.Init(minor);
		numberManager.mini.Init(mini);
	}
	public void caijing()
	{
		numberManager.grand.ShowNumberAdd(0f, 466.761f, 10f);
		numberManager.mega.ShowNumberAdd(0f, 747.757f, 10f);
		numberManager.major.ShowNumberAdd(0f, 572.461f, 10f);
		numberManager.minor.ShowNumberAdd(0f, 857.214f, 10f);
		numberManager.mini.ShowNumberAdd(0f, 847.591f, 10f);
	}
	// Update is called once per frame
	void Update () {
		
	}
}
