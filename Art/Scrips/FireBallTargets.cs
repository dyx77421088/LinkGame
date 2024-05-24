using System.Collections;
using System.Collections.Generic;
using UnityEngine;
//[System.Serializable]
public class FireBallTargets  {
	public Transform[] TargetPool; 
	public Transform[] TargetPos;
	public FireBallTargets(int x)
	{
		TargetPos=new Transform[x];
	}
	int[] rdNum(int x)
	{
		int[] RdN=new int[x];
		for (int i=0;i<x;i++)
		{
		RdN[i]= Random.Range(0,15);
		}
		return RdN;
	}
	public void InitTargets(int x)
	{
		int[] rd=rdNum(x);
		for(int i=0;i<x;i++)
		{
		this.TargetPos[i]=this.TargetPool[rd[i]];
		}
	}
	void Start () {
		TargetPos = new Transform[3];
	}

	void Update () {
		
	}
}
