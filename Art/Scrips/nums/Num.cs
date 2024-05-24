using System.Net.Mime;
//==========================
// - 文件: 	Num.cs         
// - 作者: 	#AuthorName#	
// - 时间: 	#CreateTime#	
// - 邮箱: 	#AuthorEmail#			
// - 功能:   
//==========================

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace Demo
{
	public class Num 
	{
		char num;
		Image image;
		Sprite[] numSprites;
		GameObject numObj;

		public char Number{
			get{return num;}
			set{
				SetSprite(value);
				//SetActive(true);
			}
		}



		public Num(Sprite[] sprites,GameObject obj)
		{
			numSprites = sprites;
			numObj = obj;
			image = numObj.GetComponent<Image>();
		}
		public void SetActive(bool b){
			numObj.SetActive(b);
		}

		void SetSprite(char num)
		{
            this.num = num;

            if (num == '.')
			{
				image.sprite = numSprites[10];
			}
			else if(num == ','){
				image.sprite = numSprites[11];
			}
			else{
				int i = int.Parse(num.ToString());
				image.sprite = numSprites[i];
			}
		}
	}
}
   
