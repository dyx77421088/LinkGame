//==========================
// - 文件: 	Number.cs         
// - 作者: 	#AuthorName#	
// - 时间: 	#CreateTime#	
// - 邮箱: 	#AuthorEmail#			
// - 功能:   
//==========================

using NUnit.Framework.Constraints;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;
using UnityEngine.Analytics;
using UnityEngine.Events;
using UnityEngine.iOS;
using UnityEngine.UI;


namespace Demo
{
	public class Number : MonoBehaviour
	{
        public Action onStart;
        public Action onUpdate;
		public Action onIntervalComplete;
        public Action onCompleted;
		
		Transform parent;
		Sprite[] sprites;

        //float numFrom = 0;
		float numTo = 0;
		float numEnd = 0;
		float duration=1;
		bool isInt = false;

		bool isComplete = true;
        float curNum = 0.0f;

		float[] numArray;
		int changeIndex = 0;
		float interval = 1;

        Dictionary<int,Num> nums = new Dictionary<int,Num>();

        //获取子物体sprite
		public void Init(Transform p){
			parent = p;
			sprites = new Sprite[transform.childCount];


            for (int i = 0; i < transform.childCount; i++)
			{
				Image img = transform.GetChild(i).GetComponent<Image>();
				if (img)
				{
					sprites[i] = transform.GetChild(i).GetComponent<Image>().sprite;
				}
				else
				{
					sprites[i] = transform.GetChild(i).GetChild(0).GetComponent<Image>().sprite;
				}
				
			}
		}

		void Update()
		{
			if (!isComplete)
			{
				if (onUpdate != null) onUpdate.Invoke();
				ChangeNumber();
                DisplayNumber(curNum);
                if (curNum == numEnd)
                {
                    if (onCompleted != null) onCompleted();
                }
            }
        }



        //func  
		void ChangeNumber()
        {
            if (curNum >= numTo)
            {
                curNum = numTo;
                isComplete = true;
                if (onIntervalComplete != null) onIntervalComplete();
                if (numArray!=null && changeIndex < numArray.Length - 1)
                    StartCoroutine("CompleteArray");
            }
            else
            {
                curNum += numEnd / duration * Time.deltaTime;
            }
            if (curNum >= numEnd)
            {
                curNum = numEnd;
                isComplete = true;
            }
        }

        void DisplayNumber(float number){
			string str;
			if (isInt)
				str = number.ToString("N0");
			else
				str = String.Format("{0:N}",number);
			for (int i = 0; i < str.Length; i++)
			{
				if (nums.ContainsKey(i))
				{
					nums[i].Number = str[i];
				}else
				{
					GameObject go = Instantiate(transform.GetChild(0).gameObject,parent);
					nums[i] = new Num(sprites,go);
                    nums[i].Number = str[i];
                }
				nums[i].SetActive(true);
			}
		}
		
		public void ShowNumber(float num)
		{
            NumberHide();
            DisplayNumber(num);
        }
		public void ShowNumberAdd(float from,float to,float t)
		{
			if(from>to||t < 0 ) return;
            curNum = 0;
            if (onStart!=null) onStart();
            NumberHide();

            duration = t;
            //numFrom = from;
            numEnd = numTo= to;
            string[] array = numEnd.ToString().Split('.');
            if (array.Length > 1)
			{
				isInt = false;
			}
			else
			{
				isInt = true;
			}
            isComplete = false;
        }
		public void ShowNumberArray(float[] numArray, float t, float interval = 1)
		{
            if (numArray.Length <= 0)
			{
                return;
			}
			else 
			{
                this.numArray = numArray;
				this.interval = interval;
				curNum = 0;
                changeIndex = 0;
                numTo = this.numArray[changeIndex];
				numEnd = this.numArray[numArray.Length-1];
            }
			if (onStart != null) onStart();
			NumberHide();

            duration = t;
            //numFrom = 0;
            for (int i = 0; i < numArray.Length; i++)
			{
                string[] array = numArray[i].ToString().Split('.');
                if (array.Length > 1)
                {
                    isInt = false;
					break;
                }
                else
                {
                    isInt = true;
                }
            }
            isComplete = false;
        }

		IEnumerator CompleteArray()
		{
			yield return new WaitForSeconds(interval);
            if (changeIndex < numArray.Length - 1)
            {
                changeIndex++;
                //numFrom =curNum;
                numTo = numArray[changeIndex];
                isComplete = false;
            }
        }
		public void NumberHide()
		{
            for (int i = 0; i < nums.Count; i++)
            {
                nums[i].SetActive(false);
            }
        }
    }
}
   
