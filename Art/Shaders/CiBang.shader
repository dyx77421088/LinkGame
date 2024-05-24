Shader "XuanFu/Particles/CiBang"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		[HDR]_MainColor("MainColor",color) = (1,1,1,1)
		_MainTexSpeed_x("MainTexSpeed_x", Float) = 0
		_MainTexSpeed_y("MainTexSpeed_y", Float) = 0
		_DisturbanceTex("DisturbanceTex", 2D) = "black" {}
		_Disturbance_Pow("Disturbance_Pow", Float) = 0
		_DistSpeed_x("DistSpeed_x", Float) = 0
		_DistSpeed_y("DistSpeed_y", Float) = 0
		_MaskTex("MaskTex", 2D) = "white" {}
		_MaskSpeed_x("_MaskSpeed_x",Float) = 0.0
        _MaskSpeed_y("_MaskSpeed_y",Float) = 0.0
		_Mask_Percentage("MaskPercentage", Range(-1 , 1)) = 0
		_MaskSoft("MaskSoft",Float) = 0
		_DissloveTex("DissloveTex", 2D) = "white" {}
		_DissloveSpeed_x("DissloveSpeed_x",float)=0
		_DissloveSpeed_y("DissloveSpeed_y",float)=0
		_Disslove_Soft("Disslove_Soft", Float) = 0.0
		_DissEdgeRange("DissEdgeRange",Float) = 0.1
		_DissEdgeRangeSoft("DissEdgeRangeSoft",Float) = 0.1
		[HDR]_DissEdgeColor("DissEdgeColor",Color) = (0.5,0.5,0.5,1)
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("CullMode", Float) = 0
		[Toggle]_Zwrite("Zwrite", Float) = 0
		[Enum(UnityEngine.Rendering.BlendMode)]_BlendMode01("BlendMode", Float) = 0
		[Enum(UnityEngine.Rendering.BlendMode)]_BlendMode02("BlendMode", Float) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Transparent""Queue"="Transparent" }
		LOD 100
		Cull [_CullMode]
		ZWrite [_Zwrite]
		Lighting Off
		ZTest LEqual
		Blend [_BlendMode01] [_BlendMode02]

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float4 uv : TEXCOORD0;
				float4 uv1:TEXCOORD1;
				float4 color:COLOR;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0;
				float4 uv1:TEXCOORD1;
				float4 vertex : SV_POSITION;
				float4 color:TEXCOORD2;
			};
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _DisturbanceTex;
			float4 _DisturbanceTex_ST;
			float _DistSpeed_x;
			float _DistSpeed_y;
			float _Disturbance_Pow;
			float _MainTexSpeed_x;
			float _MainTexSpeed_y;
			sampler2D _MaskTex;
			float4 _MaskTex_ST;
			float _MaskSpeed_x;
			float _MaskSpeed_y;
			float _Mask_Percentage;
			float _MaskSoft;
			float _Disslove_Soft;
			sampler2D _DissloveTex;
			float4 _DissloveTex_ST;
			float _DissEdgeRange;
			float _DissEdgeRangeSoft;
			float4 _DissEdgeColor;
			float _DissloveSpeed_x;
			float _DissloveSpeed_y;
			float4 _MainColor;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				


				o.uv = v.uv;
				o.uv1 = v.uv1;
				o.color = v.color;
			
				return o;
			}
			
			half4 frag (v2f i) : SV_Target
			{ 
				half2 uv = TRANSFORM_TEX(i.uv.xy, _MainTex);
				half2 uv_mask = TRANSFORM_TEX(i.uv.xy, _MaskTex)+ float2(_MaskSpeed_x*_Time.y, _MaskSpeed_y*_Time.y);
				half2 uv_DissloveTex = TRANSFORM_TEX(i.uv.xy, _DissloveTex)+float2(_DissloveSpeed_x,_DissloveSpeed_y)*_Time.y;
				half2 uv_DissloveTex1 = TRANSFORM_TEX(i.uv.xy, _DissloveTex)*0.5+float2(_DissloveSpeed_x,_DissloveSpeed_y)*0.7*_Time.y+float2(0.5,0.7);
				float2 uv_dist = TRANSFORM_TEX(i.uv.xy,_DisturbanceTex)+float2(_DissloveSpeed_x,_DissloveSpeed_y)*0.6*_Time.y;
				half dist=step(tex2D(_DisturbanceTex, uv_dist).r,_Disturbance_Pow);
				uv = uv + float2(_MainTexSpeed_x*_Time.y, _MainTexSpeed_y*_Time.y)+float2 (i.uv1.x, i.uv1.y);
				half4 col = tex2D(_MainTex,uv);
				col.a=1;
				
	
				half4 mask = tex2D(_MaskTex, uv_mask);
				half4 disslove = tex2D(_DissloveTex, uv_DissloveTex);
				half4 disslove1 = tex2D(_DissloveTex, uv_DissloveTex1);
				half diss=smoothstep(i.uv.z, (i.uv.z + _Disslove_Soft), disslove.r);
				half diss1=smoothstep(i.uv.z, (i.uv.z + _Disslove_Soft), disslove1.r);

				diss=(1-i.uv.y-0.2)*min(diss,diss1)+saturate(i.uv.y-0.2);
				half dissEdge = smoothstep(_DissEdgeRange, _DissEdgeRange+_DissEdgeRangeSoft,diss)*_MainColor.a;
				half4 final = lerp(col* smoothstep(_Mask_Percentage, (_Mask_Percentage+_MaskSoft), mask.r)*diss*i.color*_DissEdgeColor*2.0,col* smoothstep(_Mask_Percentage, (_Mask_Percentage+_MaskSoft), mask.r)*diss*i.color*_MainColor*2.0 ,dissEdge);
				return final*dist*_MainColor.a;
			}
			ENDCG
		}


			//uv.z控制溶解，uv.w未连接   ，uv1.xy控制一次性流动，
	}
}
