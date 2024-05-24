using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Spine.Unity;
using System;

public class ValuePanelController : MonoBehaviour {
	//public action D;
	public GameObject Bg;
	float BgTime;
	public GameObject BigWin;
	public GameObject YouWin;
	public SkeletonGraphic BigWinSK;
	public SkeletonGraphic YouWinSK;
	public SkeletonGraphic mini;
	public ParticleSystem pati;
	bool NormalStage;
	float BigWintimer;
	float YouWintimer;
	string CurWin;
	string MniiCurWin;
	float minitimer;

	public ParticleSystem jinbi;
	public ParticleSystem jinbi01;
	public ParticleSystem jinbi02;
	public ParticleSystem huoyan;
	ParticleSystem jb;
	void Init(bool x)
	{
		NormalStage = x;
	}
	void StartMini()
    {
		string[] name = new string[] { "COLLECT", "GRAND", "JACKPOT", "MAJOR", "MEGA", "MINOR" };
		int i = UnityEngine.Random.Range(0, 5);
		jb = jinbi;
		jb.Play();
		huoyan.Play();
		BgTime = 5f;
		if (mini.gameObject.activeSelf == false)
		{
			MniiCurWin = name[i];

			minitimer = 0;
			mini.gameObject.SetActive(true);
			mini.AnimationState.SetAnimation(0, name[i]+" Win", false);
		}
	}
	void StartBigWin()
	{
		jb = jinbi;
		jb.Play();
		huoyan.Play();
		BgTime = 5f;
		CurWin = "BIGWIN";
		if (BigWin.gameObject.activeSelf==false)
		{
			BigWintimer=0;
			BigWin.gameObject.SetActive(true);
			BigWinSK.AnimationState.SetAnimation(0,"BIGWIN Win",false);
		}
		else
		{	
			BigWinSK.AnimationState.SetAnimation(0,"BIGWIN Leave",false);
			StartCoroutine(Dely(1f,()=>BigWinSK.gameObject.SetActive(false)));
		}
	}
	void StartMegaWin()
	{
		
		StartBigWin();
		StartCoroutine(Dely(4f, () =>
		{
			jb.Stop();
			jb = jinbi01;
			jb.Play();
			BgTime = 5f;
			CurWin = "MEGAWIN";

				BigWintimer = 0;
				BigWin.gameObject.SetActive(true);
				BigWinSK.AnimationState.SetAnimation(0, "MEGAWIN Win", false);
		}));

	}
	void StartSuperWin()
	{
		StartMegaWin();
		StartCoroutine(Dely(8f, () =>
		{
			jb.Stop();
			jb = jinbi02;
			jb.Play();
			BgTime = 5f;
			CurWin = "SUPERWIN";
			BigWintimer = 0;
			BigWin.gameObject.SetActive(true);
			BigWinSK.AnimationState.SetAnimation(0, "SUPERWIN Win", false);
		}));
	}
	void StartYouWin()
	{
		BgTime = 5f;
		YouWintimer=0;
		if(NormalStage ==true)
		{
			if(YouWin.gameObject. activeSelf==false)
			{
				YouWin.gameObject.SetActive(true);
				YouWinSK.AnimationState.SetAnimation(0,"WIN2",false);
			}
			else
			{
				YouWinSK.AnimationState.SetAnimation(0,"WIN3",false);

				pati.Stop();
				StartCoroutine(Dely(0.6f,()=>YouWin.gameObject.SetActive(false)));
			}
		}
		else
		{
			if(YouWin.gameObject.activeSelf==false)
			{
				YouWin.gameObject.SetActive(true);
				YouWinSK.AnimationState.SetAnimation(0,"WON2",false);
			}
			else
			{
				YouWinSK.AnimationState.SetAnimation(0,"WON3",false);
				pati.Stop();
				StartCoroutine(Dely(0.6f,()=>YouWin.gameObject.SetActive(false)));
			}
		}
	}




	void SenseChange(bool x)
	{
		NormalStage=x;
	}
	IEnumerator  Dely(float t,Action action)
	{
		yield return new WaitForSeconds(t);
		if(action!=null)
		action();

	}
 void Awake() {
		GameController.init+=Init;
		GameController.BigWin+=StartBigWin;
		GameController.SuperWin += StartSuperWin;
		GameController.MegaWin += StartMegaWin;
		GameController.YouWin+=StartYouWin;
		GameController.NorFchange+=SenseChange;
		GameController.mini += StartMini;
		
	}
	
	void UPD(String x)
    {
		if (BigWinSK.gameObject.activeSelf == true)
		{
			BigWintimer += Time.deltaTime;
			if (BigWinSK.AnimationState.GetCurrent(0).Animation.Name == x+" Win" && BigWinSK.AnimationState.GetCurrent(0).IsComplete)
			{
				BigWinSK.AnimationState.SetAnimation(0, x+" Idle", true);
			}
			if (BigWinSK.AnimationState.GetCurrent(0).Animation.Name == x+" Idle" && BigWintimer >= 5f)
			{
				jb.Stop();
				huoyan.Stop();
				BigWinSK.AnimationState.SetAnimation(0, x+" Leave", false);
				StartCoroutine(Dely(1f, () => BigWinSK.gameObject.SetActive(false)));

			}
		}
	}
	void UPDmini(String x)
	{
		if (mini.gameObject.activeSelf == true)
		{
			minitimer += Time.deltaTime;
			if (mini.AnimationState.GetCurrent(0).Animation.Name == x + " Win" && mini.AnimationState.GetCurrent(0).IsComplete)
			{
				mini.AnimationState.SetAnimation(0, x + " Idle", true);
			}
			if (mini.AnimationState.GetCurrent(0).Animation.Name == x + " Idle" && minitimer >= 5f)
			{
				jb.Stop();
				huoyan.Stop();
				mini.AnimationState.SetAnimation(0, x + " Leave", false);
				StartCoroutine(Dely(1f, () => mini.gameObject.SetActive(false)));

			}
		}
	}
	void BgTiemCtr()
    {
		if (BgTime > 0)
		{
			BgTime -= Time.deltaTime;
			Bg.SetActive(true);
		}
		else
		{
			Bg.SetActive(false);
		}
	}
	// Update is called once per frame
	void Update () {
		UPD(CurWin);
		UPDmini(MniiCurWin);
		BgTiemCtr();

		if(YouWinSK.gameObject.activeSelf==true)
		{
			YouWintimer+=Time.deltaTime;
			if(NormalStage ==true&&YouWinSK.AnimationState.GetCurrent(0).Animation.Name=="WIN2"&&YouWinSK.AnimationState.GetCurrent(0).IsComplete)
			{
					YouWinSK.AnimationState.SetAnimation(0,"WIN1",true);
			}
			if (YouWinSK.AnimationState.GetCurrent(0).Animation.Name == "WIN1" && YouWintimer >= 5f)
			{
				YouWinSK.AnimationState.SetAnimation(0, "WIN3", false);
				StartCoroutine(Dely(0.5f, () => YouWin.SetActive(false)));

			}
			if (NormalStage==false&&YouWinSK.AnimationState.GetCurrent(0).Animation.Name=="WON2"&&YouWinSK.AnimationState.GetCurrent(0).IsComplete)
			{
					YouWinSK.AnimationState.SetAnimation(0,"WON1",true);
			}
			if (YouWinSK.AnimationState.GetCurrent(0).Animation.Name == "WON1" && YouWintimer >= 5f)
			{
				YouWinSK.AnimationState.SetAnimation(0, "WON3", false);
				StartCoroutine(Dely(0.5f, () => YouWin.SetActive(false)));

			}

		}
	}
}
