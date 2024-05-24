using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using Spine.Unity;
using DG.Tweening;

public class BigWinNum : MonoBehaviour {
    public Transform nums;
    public Transform numsYouwin;
    public Demo.NumberManager numberManager;

    public void bigwinNum()
    {
        numberManager.BigWin.ShowNumberAdd(0f,66.6f,5f) ;
        

    }
    public void megawinNum()
    {
        numberManager.BigWin.ShowNumberAdd(0f, 132.6f, 9f);


    }
    public void superwinNum()
    {
        numberManager.BigWin.ShowNumberAdd(0f, 199.9f, 13f);


    }
    public void YouWinNum()
    {
        numsYouwin.DOLocalJump(new Vector3(0,1,0),700,1,0.3f);
        numberManager.YouWin.ShowNumberAdd(0f,9,1f) ;
    }
    private void Awake  () {
        numberManager.BigWin.Init(nums);
        numberManager.YouWin.Init(numsYouwin);
        GameController.BigWin+=bigwinNum;
        GameController.MegaWin += megawinNum;
        GameController.SuperWin += superwinNum;
        GameController.YouWin+=YouWinNum;
    }
	




    void Update () {

	}
}