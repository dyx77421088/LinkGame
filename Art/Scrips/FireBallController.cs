using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using Spine.Unity;
public class FireBallController : MonoBehaviour {
	public  static bool swh;
	public GameObject fireBall;
	public Transform[] TargetPool; 
	public Transform StartPos;
	public FireBallTargets fbt;
	public Transform FireBallPool;
	public float rdTrigger=0.005f;
	public RoleController SmallDevil;
	public Transform EffPool;
	public float minInterval=0.5f;
	float t;
	public SkeletonDataAsset s;
	public Transform[] fork;
	void Start () {
		swh = GameController.CurrentStage;
		t = 0;
	}
	void TriggerFireBall()
	{
		fbt = new FireBallTargets(3);
		fbt.TargetPool=TargetPool;
		fbt.InitTargets(3);
		for(int i=0;i<3;i++)
		{
		GameObject go=Instantiate(fireBall,StartPos.position,Quaternion.Euler(Random.Range(-180,0),0,0),FireBallPool);
		FireBallMove g=go.GetComponent<FireBallMove>();
		SkeletonGraphic ss = fbt.TargetPos[i].gameObject.GetComponent<SkeletonGraphic>();
		g.target = fbt.TargetPos[i];
			if(ss.skeletonDataAsset.name!= "ng_sym11_fork_SkeletonData")
            {
				ss.skeletonDataAsset = s;
				ss.Initialize(true);
				ss.AnimationState.SetAnimation(0, "win", true);
			}
			if(ss.skeletonDataAsset.name == "ng_sym11_fork_SkeletonData")
            {
				for(int j=0;j<fork.Length;j++)
                {
					fork[j].GetComponent<SkeletonGraphic>().skeletonDataAsset = s;
					fork[j].GetComponent<SkeletonGraphic>().Initialize(true);
					fork[j].GetComponent<SkeletonGraphic>().AnimationState.SetAnimation(0, "win", true);
				}
            }
			g.DestoryEffPool = EffPool;
		}
	}

	void Update () {
		
		if(swh)
		{
			t += Time.deltaTime;
			if (t > minInterval)
			{
				t = 0;
				if (Random.value < rdTrigger)
				{
					AnimatorStateInfo curA = SmallDevil.ani.GetCurrentAnimatorStateInfo(0);
					if (curA.IsName("Idle") || curA.IsName("PaoHuoQiu"))
					{
						//this.GetComponent<RoleController>().aniCtr("PaoHuoQiuOver", "Trigger");
						SmallDevil.aniCtr("PaoHuoQiu", "Trigger");
						StartCoroutine(StartDelay(0.5f, () =>
						{
							TriggerFireBall();
						}));
					}

				}
			}
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
