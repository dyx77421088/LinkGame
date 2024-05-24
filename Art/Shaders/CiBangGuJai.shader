Shader "XuanFu/Particles/CiBnagGuJia"
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
		//Blend [_BlendMode01] [_BlendMode02]

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
			float _FrenilPow;
			
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
				half2 uv_DissloveTex = TRANSFORM_TEX(i.uv.xy, _DissloveTex)+float2(_DissloveSpeed_x,_DissloveSpeed_y)*_Time.y;
				float2 uv_dist = i.uv.xy*_DisturbanceTex_ST.xy + _DisturbanceTex_ST.zw + float2(_DistSpeed_x*_Time.y, _DistSpeed_y*_Time.y);
				uv = uv + tex2D(_DisturbanceTex, uv_dist).r*_Disturbance_Pow + float2(_MainTexSpeed_x*_Time.y, _MainTexSpeed_y*_Time.y)+float2 (i.uv1.x, i.uv1.y);
				half4 col = tex2D(_MainTex,uv);
				col=col*col.a;

				half4 disslove = tex2D(_DissloveTex, uv_DissloveTex);
				half diss=smoothstep(i.uv.z, (i.uv.z + _Disslove_Soft), disslove.r);
				half dissEdge = smoothstep(_DissEdgeRange, _DissEdgeRange+_DissEdgeRangeSoft,diss);;
				half4 final = col*diss*i.color*_MainColor;
				return final;
			}
			ENDCG
		}


			//uv.z控制溶解，uv.w未连接   ，uv1.xy控制一次性流动，
	}
}
