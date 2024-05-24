using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class EffcController : MonoBehaviour {

	// Use this for initialization
	public ParticleSystem TransforToN;
	public Transform bige;
	void Start () {
		
	}
	
	// Update is called once per frame
	void tranToN()
    {
		TransforToN.Play();

	}

	void bigTosmall()
    {
		bige.DOScale(0, 0.5f);
    }

	void smallTobig()
    {
		bige.DOScale(1, Time.deltaTime);
	}
	void Update () {
		
	}
}
