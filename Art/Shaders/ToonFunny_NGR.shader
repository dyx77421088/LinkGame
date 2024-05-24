Shader "XuanFu/Toon/Funny6in1_NGR"
{
	Properties
	{
		_Color("贴图颜色",Color) = (1,1,1,1)
		_TexEmi("环境颜色",Color) = (0,0,0,1)
		_Specular("高光颜色",Color) = (1,1,1,1)
		_Gloss("高光系数",Range(4.0,256)) = 20
		_MainTex ("贴图", 2D) = "white" {}
		_SpeMaskTex("高光遮罩", 2D) = "white" {}
		_EmissiveScale("自发光强度",Range(0,1.0)) = 1
		_EmissiveTex("自发光贴图", 2D) = "black" {}
		_BumpScale("法线强度",float) = 1
		_Bump("法线", 2D) = "bump"{}

		_BackColor("BackColor",Color) = (1,1,1,1)

		_ReflectColor("反射颜色",Color) = (1,1,1,1)
		_ReflectAmount("反射强度",Range(0,1)) = 1
		_ReflectMask("反射遮罩",2D) = "white"{}
		_Cubemap("Cubemap",Cube) = "_Skybox"{}
	}
	SubShader
	{
		//Tags{"Queue"="Geometry+50""RanderType" = "Transparent"}

		

		Pass
		{
			Tags { "LightMode"="ForwardBase" }
			Cull Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#include "Lighting.cginc"
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"

			fixed4 _Color;
			fixed4 _TexEmi;
			sampler2D _MainTex;
			sampler2D _EmissiveTex;
			float _EmissiveScale;
			float4 _MainTex_ST;
			sampler2D _Bump;
			float4  _Bump_ST;
			float _BumpScale;
			fixed4 _Specular;
			sampler2D _SpeMaskTex;
			float _Gloss;


			fixed3 _BackColor;

			sampler2D _ReflectMask;
			half4 _ReflectColor;
			fixed _ReflectAmount;
			samplerCUBE _Cubemap;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal :NORMAL;
				fixed4 tangent : TANGENT;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 pos : SV_POSITION;

				float4 TtoW0 :TEXCOORD1;
				float4 TtoW1 :TEXCOORD2;
				float4 TtoW2 :TEXCOORD3;
				SHADOW_COORDS(4)

			};

			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				
				float3 worldPos = mul(unity_ObjectToWorld,v.vertex);
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				float3 worldBinormal = cross(worldNormal,worldTangent) * v.tangent.w ;
				o.TtoW0 = float4(worldTangent.x, worldBinormal.x ,worldNormal.x,worldPos.x);
				o.TtoW1 = float4(worldTangent.y, worldBinormal.y ,worldNormal.y,worldPos.y);
				o.TtoW2 = float4(worldTangent.z, worldBinormal.z ,worldNormal.z,worldPos.z);
				TRANSFER_SHADOW(o);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 worldPos = float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);
				
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				
				fixed3 worldView = normalize(UnityWorldSpaceViewDir(worldPos));
				fixed3 halfDir = normalize(worldLightDir + worldView);

				
				fixed3 bump = UnpackNormal(tex2D(_Bump,i.uv));
				bump.xy *= _BumpScale;
				bump.z = sqrt(1 - saturate(dot(bump.xy,bump.xy)));
				bump = normalize(half3(dot(i.TtoW0.xyz,bump),dot(i.TtoW1.xyz,bump),dot(i.TtoW2.xyz,bump)));
 				fixed4 texCol = tex2D(_MainTex, i.uv) *_Color;
				fixed3 refMask = tex2D(_ReflectMask, i.uv);//ref
				fixed3 ambient = texCol *_TexEmi;
				fixed3 emissiveTex = tex2D(_EmissiveTex,i.uv) * _EmissiveScale;
				fixed speMaskTex = tex2D(_SpeMaskTex, i.uv).r;
				fixed n = dot(bump,worldLightDir);
				fixed s = dot(bump,halfDir);
				fixed3 worldRefl = reflect(-worldView,bump);//ref
				fixed3 reflection = texCUBE(_Cubemap, worldRefl) * _ReflectColor * refMask;//ref
				fixed shadow = SHADOW_ATTENUATION(i);
				UNITY_LIGHT_ATTENUATION(atten, i, worldPos);
				fixed3 diffuse = _LightColor0 * texCol *saturate(dot(bump,worldLightDir)) ;
				fixed3 specular = _LightColor0 * _Specular * pow(max(0,dot(bump,halfDir)),_Gloss ) * speMaskTex;
				

				fixed3 refColor = lerp(0,reflection,_ReflectAmount);//ref
				//fixed3 backColor = (1-smoothstep(0.3,0.4,dot(bump,worldView)))*(1-saturate(smoothstep(_SmoothA,_SmoothB,n))) * _BackColor;

				return half4((diffuse + refColor + ambient + specular ) *atten + emissiveTex,texCol.a);
			}
			ENDCG
		}
		Pass
		{
			Tags { "LightMode"="ForwardAdd" }
			Blend One One
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			//#pragma multi_compile_fwdadd
			#pragma multi_compile_fwdadd_fullshadows
			#include "Lighting.cginc"
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"

			fixed4 _Color;
			fixed4 _TexEmi;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _Bump;
			float4  _Bump_ST;
			float _BumpScale;
			fixed4 _Specular;
			sampler2D _SpeMaskTex;
			float _Gloss;

			fixed3 _BackColor;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal :NORMAL;
				fixed4 tangent : TANGENT;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 pos : SV_POSITION;

				float4 TtoW0 :TEXCOORD1;
				float4 TtoW1 :TEXCOORD2;
				float4 TtoW2 :TEXCOORD3;
				SHADOW_COORDS(4)
			};

			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				
				float3 worldPos = mul(unity_ObjectToWorld,v.vertex);
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				float3 worldBinormal = cross(worldNormal,worldTangent) * v.tangent.w ;
				o.TtoW0 = float4(worldTangent.x, worldBinormal.x ,worldNormal.x,worldPos.x);
				o.TtoW1 = float4(worldTangent.y, worldBinormal.y ,worldNormal.y,worldPos.y);
				o.TtoW2 = float4(worldTangent.z, worldBinormal.z ,worldNormal.z,worldPos.z);
				TRANSFER_SHADOW(o);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 worldPos =  float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);
				float3 pointPos = float3(unity_4LightPosX0.x, unity_4LightPosY0.x, unity_4LightPosZ0.x);
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0 - worldPos);

				// #if defined(POINT)
				// float3 lightCoord = mul(unity_WorldToLight,worldPos);
				// float c = dot(lightCoord,lightCoord);
				// fixed atten = tex2D(_LightTexture0,float2(c,c)).UNITY_ATTEN_CHANNEL;

				// #else
				// fixed atten = 1.0;
				// #endif

				//fixed shadow = SHADOW_ATTENUATION(i);
				UNITY_LIGHT_ATTENUATION(atten, i, worldPos);
				fixed3 worldView = normalize(UnityWorldSpaceViewDir(worldPos));
				fixed3 halfDir = normalize(worldLightDir + worldView);

				fixed3 bump = UnpackNormal(tex2D(_Bump,i.uv));
				bump.xy *= _BumpScale;
				bump.z = sqrt(1 - saturate(dot(bump.xy,bump.xy)));
				bump = normalize(half3(dot(i.TtoW0.xyz,bump),dot(i.TtoW1.xyz,bump),dot(i.TtoW2.xyz,bump)));
 				fixed4 texCol = tex2D(_MainTex, i.uv) *_Color;
				fixed speMaskTex = tex2D(_SpeMaskTex, i.uv).r;

				fixed3 diffuse = _LightColor0 * texCol *saturate(dot(bump,worldLightDir)) ;
				fixed3 specular = _LightColor0 * _Specular * pow(max(0,dot(bump,halfDir)),_Gloss ) * speMaskTex ;
				
				return half4((diffuse +specular) *atten,1);
			}
			ENDCG
		}
	}
	Fallback "Specular"
}
