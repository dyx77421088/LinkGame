using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
public delegate void TriggerEvent();
public delegate void ChanSenseEvent(bool x);
public class GameController : MonoBehaviour {
	public static TriggerEvent BigWin;
	public static TriggerEvent SuperWin;
	public static TriggerEvent MegaWin;
	public static TriggerEvent YouWin;
	public static TriggerEvent mini;
	public static TriggerEvent ZAXIA;
	public static ChanSenseEvent NorFchange;
	public static ChanSenseEvent init;
	public static bool CurrentStage;
	bool ChangeStage;
	public float TransitionTime;
	public GameObject NormalPanel;
	public GameObject FreePanel;
	public RoleController SmallDevil;
	public ParticleSystem trans;
	public ParticleSystem transToN;
	public Animation trnsToN;
	void Init()
	{
		if(NormalPanel.activeSelf==true&&FreePanel.activeSelf==false)
		{
			CurrentStage =true;
			ChangeStage=true;
		}
		if(FreePanel.activeSelf==true&&NormalPanel.activeSelf==false)
		{
			CurrentStage=false;
			ChangeStage=false;
		}
	
		init.Invoke(CurrentStage);
	}
	void Start () {
		Init();		
	}

	public void StartBigWinIn()
	{
		if(BigWin!=null)
		{
			BigWin.Invoke();
		}
	}
	public void StartSuperWinIn()
	{
		if (SuperWin != null)
		{
			SuperWin.Invoke();
		}
	}
	public void StartMegaWinIn()
	{
		if (MegaWin != null)
		{
			MegaWin.Invoke();
		}
	}
	public void StartYouWinIn()
	{
		if(YouWin!=null)
		{
			YouWin.Invoke();
		}
	}
	public void StartMiniIn()
	{
		if (mini != null)
		{
			mini.Invoke();
		}
	}

	public void ZaXia()
    {
		if(ZAXIA!=null)
        {
			ZAXIA.Invoke();
        }
    }
	public void SenseChangeIn()
	{
		 SenseChange();
	}
	public void SenseChange()
	{
		if(CurrentStage)
        {
			TransitionTime = 1.2f;
			trans.Play();
			trnsToN.Rewind("transforToNor");
			trnsToN["transforToNor"].speed = -1f;
			trnsToN.Play("transforToNor");
		}
		if(!CurrentStage)
        {
			TransitionTime = 1.3f;
			transToN.Play();
			trnsToN.Rewind("transforToNor");
			trnsToN["transforToNor"].speed = 1f;
			trnsToN.Play("transforToNor");
		}
		
		FireBallController.swh=!CurrentStage;
		ChangeStage=!ChangeStage;
		if(CurrentStage!=ChangeStage)
		{
			
			
			StartCoroutine(StartDelay(TransitionTime, () => {
				NormalPanel.SetActive(!NormalPanel.activeSelf);
				FreePanel.SetActive(!FreePanel.activeSelf);
			}));

			CurrentStage=ChangeStage;
			if(NorFchange!=null)
			{
				NorFchange.Invoke(CurrentStage);
			}
		}
	}

IEnumerator StartDelay(float t,Action fuc)
{
	yield return new  WaitForSeconds(t);
	if(fuc!=null)
	{
		fuc();
	}
}

	void Update () {
	}
}
