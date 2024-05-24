using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using DG.Tweening;
public class RoleControllerVal : MonoBehaviour {

	// Use this for initialization
	public Animator ani;
	int idleRandomX;
	float t=0;
	void Start () {
		
	}
	void Awake()
    {
		GameController.MegaWin += MegaWin;
		GameController.SuperWin += SuperWin;
		GameController.BigWin += BigWin;
		GameController.mini += miniWin;
	}
	// Update is called once per frame
	void Update()
	{

		if (t > 0)
		{
			t -= Time.deltaTime;
		}
		else
		{
			if (this.gameObject.activeSelf == true)
			{ 
			this.gameObject.transform.DOScale(0, 0.1f).SetEase(Ease.OutQuad).OnComplete(() =>
			{
				this.gameObject.SetActive(false);
			});
		}
			
		}

	}
	public void miniWin()
	{

		t = 5.5f; this.gameObject.SetActive(true);
		this.gameObject.transform.DOScale(1, 0.3f).SetEase(Ease.OutQuad);
		aniCtr("Win01", "Trigger");
	}
	public void BigWin()
    {
		
		t = 5.5f; this.gameObject.SetActive(true);
		this.gameObject.transform.DOScale(1, 0.3f).SetEase(Ease.OutQuad);
		aniCtr("Win01", "Trigger");
    }
	public void MegaWin()
	{
		BigWin();
		StartCoroutine(StartDelay(4.2f,() => {
			t = 5.5f;
			aniCtr("Win02", "Trigger");
		}));

	}
	public void SuperWin()
	{
		MegaWin();
		StartCoroutine(StartDelay(8.2f, () => {
			t = 5.5f;
			aniCtr("Win03", "Trigger");
		}));
	}


	public void ChangeToFree(bool x)
	{
		

		if (x == false)
		{

            if (this.ani.name != "fg_BigEmo")
            {
                this.ani.SetTrigger("BianShen");
            }
            if (ani.name != "Role_XiaoEMo")
            {
            	StartCoroutine(StartDelay(5f, () => { ani.SetTrigger("bianshen"); }));
            }

        }
	}
    
	public void ChangeToNormal(bool x)
	{

	}
	public  void aniCtr(string animStage,string Type,float index=0,bool bol=false)
	{
		if(Type == "Float")
		{
			ani.SetFloat(animStage,index);

		}
		if(Type =="Int")
		{
			ani.SetInteger(animStage,(int)index);

		}
		if(Type =="Bool")
		{
			ani.SetBool(animStage,bol);

		}
		if(Type =="Trigger")
		{
			ani.SetTrigger(animStage);
		}

	}

	IEnumerator StartDelay(float t, System.Action fuc)
	{
		yield return new WaitForSeconds(t);
		if (fuc != null)
		{
			fuc();
		}
	}
}
