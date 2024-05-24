using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using DG.Tweening;
public class RoleController : MonoBehaviour,IPointerClickHandler {

	// Use this for initialization
	public Animator ani;
	public GameObject fireBall;
	int idleRandomX;
	float t;

	//public Animation a;
	void Start () {
		
	}
	void Awake()
    {
		GameController.NorFchange += ChangeToFree;
		GameController.NorFchange += ChangeToNormal;
		GameController.ZAXIA += zaxia;
		GameController.MegaWin += MegaWinDisAp;
		GameController.SuperWin += SuperWinDisAp;
		GameController.BigWin += BigWinDisAp;
		GameController.mini += miniDisAp;
		//GameController.NorFchange += ChangeToNormal;
	}
	// Update is called once per frame
	void Update()
	{
		if(ani.gameObject.name== "skin01")
        {

			if (t <= 5)
			{
				t += Time.deltaTime;
				if (t > 2)
				{
					this.ani.SetInteger("attackPlane", 0);
				}

			}
			return;
		}
		if (this.gameObject.name != "SmallDevil")
		{
			return;
		}
		if (t <= 5)
		{
			t += Time.deltaTime;
			if (t > 2)
			{
				
				this.ani.SetInteger("Click", 0);
			}
		
	}
	}
	public void miniDisAp()
	{
		if (this.gameObject.name == "SmallDevil")
		{
			if(fireBall!=null)
            {
				fireBall.SetActive(false);
			}
				
			this.ani.gameObject.SetActive(false);
			StartCoroutine(StartDelay(5.5f, () => { this.ani.gameObject.SetActive(true);
				if (fireBall != null)
				{
					fireBall.SetActive(false);
				}
			}));
		}

	}
	public void MegaWinDisAp()
    {
		if(this.gameObject.name == "SmallDevil")
		{
			if (fireBall != null)
			{
				fireBall.SetActive(false);
			}
			this.ani.gameObject.SetActive(false);
			StartCoroutine(StartDelay(10f, () => { this.ani.gameObject.SetActive(true);
				if (fireBall != null)
				{
					fireBall.SetActive(false);
				}
			}));
		}

	}
	public void SuperWinDisAp()
	{
		if (this.gameObject.name == "SmallDevil")
		{
			if (fireBall != null)
			{
				fireBall.SetActive(false);
			}
			this.ani.gameObject.SetActive(false);
			StartCoroutine(StartDelay(14f, () => { this.ani.gameObject.SetActive(true);
				if (fireBall != null)
				{
					fireBall.SetActive(false);
				}
			}));
		}
	}
	public void BigWinDisAp()
	{
		if (this.gameObject.name == "SmallDevil")
		{
			if (fireBall != null)
			{
				fireBall.SetActive(false);
			}
			this.ani.gameObject.SetActive(false);
			StartCoroutine(StartDelay(5.5f, () => { this.ani.gameObject.SetActive(true);
				if (fireBall != null)
				{
					fireBall.SetActive(false);
				}
			}));
		}
	}
	public void zaxia()
    {
		t = 0;
		this.ani.SetInteger("attackPlane", 1);
    }


	public void ChangeToFree(bool x)
	{
		

		if (x == false)
		{

            if (this.gameObject.name == "SmallDevil")
            {
                this.ani.SetTrigger("BianShen");
            }
            if (ani.gameObject.name == "skin01")
            {
				
            	StartCoroutine(StartDelay(1.3f, () => {
					//a.Play();
					this.ani.SetTrigger("bianshen"); }));
            }

        }
	}
	public void ChangeToNormal(bool x)
    {
		if (x == true)
        {
			this.ani.SetTrigger("attack");
		}

	}
    
	public  void aniCtr(string animStage,string Type,float index=0,bool bol=false)
	{
		if(Type == "Float")
		{
			this.ani.SetFloat(animStage,index);

		}
		if(Type =="Int")
		{
			this.ani.SetInteger(animStage,(int)index);

		}
		if(Type =="Bool")
		{
			this.ani.SetBool(animStage,bol);

		}
		if(Type =="Trigger")
		{
			this.ani.SetTrigger(animStage);
		}

	}

	public void OnPointerClick(PointerEventData eventData)
	{	
		if (this.ani.gameObject.name== "skin01")
		{
			return;
		}
		else
        {
			idleRandomX = Random.Range(1, 4);
			this.ani.SetInteger("Click", idleRandomX);
			t = 0;
		}

		
	}
	void OnEnable()
    {
		if(ani.name=="skin")
        {
			ani.gameObject.transform.localScale = new Vector3(0,0,0);
			ani.gameObject.transform.DOScale(1f, 0.3f);
			ani.gameObject.transform.DOMoveY(6, 0.2F).SetEase(Ease.OutQuart).OnComplete(() => { ani.gameObject.transform.DOMoveY(0, 0.2F).SetEase(Ease.InQuart); });

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
