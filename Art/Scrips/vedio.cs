using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class vedio : MonoBehaviour {

	public ParticleSystem l;
	public ParticleSystem f;
	// Use this for initialization
	void Start () {
		
	}
	public void playL()
    {
		l.Play();
		StartCoroutine(StartDelay(5f, () => { l.Stop(); }));
    }
	public void playF()
	{
		f.Play();
		StartCoroutine(StartDelay(5f, () => { f.Stop(); }));
	}
	// Update is called once per frame
	void Update () {
		
	}
	IEnumerator StartDelay(float t, Action fuc)
	{
		yield return new WaitForSeconds(t);
		if (fuc != null)
		{
			fuc();
		}
	}
}
