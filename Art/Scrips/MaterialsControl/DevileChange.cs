using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DevileChange : MonoBehaviour {

	public GameObject[] magma;
	// Use this for initialization
	public Material mat;
	public Material mat1;
	public Material Matyanjiang;
	public AnimationCurve curve;
	public AnimationCurve YanJiangcurve;
	public float currentTime=10;
	public float YanJcurrentTime = 10;
	public float YanJduration = 0.5f;
	public float duration=0.5f;
	
	public Transform[] Pos;
	[Header("下砸点")]
	public Transform[] XiaZaPos;
	public ParticleSystem XiaZaEff;
	public GameObject magmaPen;
	float Distance;
	public static int XiaZaIndex;



	void Awake () {
		GameController.NorFchange += change;
		GameController.NorFchange += changeToNormal;
		GameController.ZAXIA += zaixaYanjiang;
	}
	void Start()
    {
		//currentTime = 10;
		Distance = 10;
		mat.SetFloat("_Disturbance_Pow", 1);

		mat1.SetFloat("_Dissolve", 1);
		Matyanjiang.SetFloat("_MaskPercentage", -0.5f);
		XiaZaIndex = 1;
	}
	void change(bool x)
    {

		if (!x)
		{
			StartCoroutine(StartDelay(2.5f, () => {
				
				currentTime = 0; }));
			
		}
		if(x)
        {
			StartCoroutine(StartDelay(2.5f, () => {
				mat.SetFloat("_Disturbance_Pow", 1);

				mat1.SetFloat("_Dissolve", 1);

			}));
		}
	}
	void changeToNormal (bool x)
    {
		if(x)
        {
			StartCoroutine(StartDelay(1f, () => {

				XiaZaEff.gameObject.transform.position = XiaZaPos[2].position;
				XiaZaEff.Play();
			}));
		}
    }
	public void zaixaYanjiang()
    {
		Matyanjiang.SetFloat("_MaskPercentage", 0);
		magmaPen.SetActive(false);
		foreach (Transform p in Pos)
		{

			p.localPosition=new Vector3(p.localPosition.x, p.localPosition.y,0);
		}
		foreach (GameObject g in magma)
            {
			if(g.activeSelf)
			g.SetActive(false);
        }
		
		StartCoroutine(StartDelay(2.2f, () => {
			magma[1].SetActive(true);
			YanJcurrentTime = 0;
			XiaZaEff.gameObject.transform.position = XiaZaPos[0].position;
			XiaZaEff.Play();

		}));
		StartCoroutine(StartDelay(4.2f, () => {
			if(XiaZaIndex==1)
			{ 
					Distance = 1; }
			
			XiaZaIndex = 1;
		}));

	}
	IEnumerator StartDelay(float t, System.Action fuc)
	{
		yield return new WaitForSeconds(t);
		if (fuc != null)
		{
			fuc();
		}
	}

	// Update is called once per frame


	void Update()
	{
		if (currentTime < duration)
		{
			float curveValue = curve.Evaluate(currentTime / duration);

			mat.SetFloat("_Disturbance_Pow", curveValue);
			mat1.SetFloat("_Dissolve", curveValue);


			currentTime += Time.deltaTime;
		}
		if (YanJcurrentTime < YanJduration)
		{
			float yanjiangValue = YanJiangcurve.Evaluate(YanJcurrentTime / YanJduration);
			Matyanjiang.SetFloat("_MaskPercentage", yanjiangValue);
			//Matyanjiang.SetFloat("_DisturPow", yanjiangValue);
			YanJcurrentTime += Time.deltaTime;

		}
		if (Distance < 2.3)
		{
			Distance += Time.deltaTime;
			foreach (Transform p in Pos)
			{

				p.localPosition += new Vector3(0, 0, -Distance);
			}
		}
		if (Distance < 10 && Distance >= 2.3 && magmaPen.activeSelf == false)
		{
			Distance = 10;
			magmaPen.SetActive(true);
		}
	}
}
