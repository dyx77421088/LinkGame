using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Spine.Unity;

public class FireBallMove : MonoBehaviour {
	public Transform target;
	public float speed=1f;
	public float lerpSpeed=0.2f;
	public GameObject DestroyEff;
	public Transform DestoryEffPool;
	void Start () {
	}
	void Update () {
		if(Vector3.Distance(this.transform.position,target.position)>1)
		{
		this.transform.position+=this.transform.forward*speed;
		Vector3 dir= Vector3.Normalize(target.position-this.transform.position);
		this.transform.forward= Vector3.Lerp(this.transform.forward,dir,lerpSpeed);
		}
		if(Vector3.Distance(this.transform.position,target.position)<=speed)
		{			

			if(this.GetComponent<ParticleSystem>().isEmitting)
            {
				GameObject DestroyE = Instantiate(DestroyEff, this.transform.position, Quaternion.identity, DestoryEffPool);
				Destroy(DestroyE, 1f);

			}
			this.GetComponent<ParticleSystem>().Stop();
			Destroy(this.gameObject,1f);			

		}
	}
	void OnDestroy()
    {

	}
}
