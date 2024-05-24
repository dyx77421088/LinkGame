Shader "XuanFu/Postprocessing/ScreenDistortion"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
		_NoiseTex("Noise Texture", 2D) = "Black" {}//默认给黑色，也就是不会偏移
		_XDensity("NoiseXDensity", Float) = 1.0
		_YDensity("NoiseYDensity", Float) = 1.0
		_MaskTex("Mask Texture",2D) = "white"{}
		_MaskTex_ST("Mask_ST",Vector)=(1,1,0,0)
		_DistortStrength("DistortStrength", Float) = 0.8
		_DistortVelocity("DistortVelocity", Float) = 0.5
	}
		SubShader
	{
		Zwrite Off
		Cull Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#include "UnityCG.cginc"
			

			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform sampler2D _NoiseTex;
			uniform sampler2D _MaskTex;
			uniform float4 _MaskTex_ST;
			uniform float _DistortStrength;
			uniform float _DistortVelocity;
			uniform float _XDensity;
			uniform float _YDensity;
			



			fixed4 frag(v2f_img i) : SV_Target
			{
				
				//通过缩放纹理控制噪声纹理密度，改变扰动密集感
				fixed2 uv = i.uv;
				float2  _NoiseUV = i.uv*float2(_XDensity,_YDensity);
				//根据时间因素从而获得不断变化的噪点值，增加热扰动流动感
				float2 offset = tex2D(_NoiseTex, _NoiseUV -_Time.y * _DistortVelocity).xy;
				//原取得的值在0到1，重映射到-1到1，增加扰动方向的随机感，并用_DistortStrength更改采样偏移距离，控制扰动强度
				offset = (offset - 0.5) * 2 * _DistortStrength;
				//采样偏移量乘上采样遮罩的值，该值为0到1，既遮罩白色部分正常扰动，黑色部分无扰动，中间灰色则为过度
				float4 mask =tex2D(_MaskTex, i.uv*_MaskTex_ST.xy+_MaskTex_ST.zw);
				i.uv += offset*mask.r;
				return tex2D(_MainTex, i.uv);
				
			}
			ENDCG
		}
	}
}