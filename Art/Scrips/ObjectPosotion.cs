using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
public class ObjectPosotion : MonoBehaviour {

    // Use this for initialization
    public GameObject[] obj;
	void Start () {

	}
	
	// Update is called once per frame
	void Update () {
        return;
        //Shader.SetGlobalVector("MagmaObjectPos", new Vector4(this.transform.position.x, this.transform.position.y, this.transform.position.z, this.transform.localScale.x));

        Vector4[] objPos = new Vector4[obj.Length];
        for(int i=0; i < obj.Length; i++)
        {

            objPos[i] = new Vector4(obj[i].transform.position.x,obj[i].transform.position.y,obj[i].transform.position.z,1);
        }

        Shader.SetGlobalVectorArray("MagmaObject01", objPos);

    }
}
