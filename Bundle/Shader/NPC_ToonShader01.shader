//TODO:高光 
Shader "MyShader/MyToonShader" {
    Properties {
        _Color("Color", Color) = (1,1,1,1)
		_MainTex("Main Texture", 2D) = "white" {}
		_NormalTex("法线贴图",2D) = "bump"{}

        [Header(Emit)]
        //眼睛用
        _EmitTex("自发光贴图",2D) = "white"{}
        _EmitInt("自发光强度",Range(0.0,1.0)) = 0.0
        
		[Header(Light)]
        //2017没有HDR
		[HDR]_AmbientCol("环境色",Color) = (0.4,0.4,0.4,1.0)
        
    	[Header(DirectionalLight)]
        _DirectionalLight01("平行光01",Vector)=(0.0,1.0,0.0,0.0)
        _DirectionalLight02("平行光02",Vector)=(1.0,0.0,0.0,0.0)
    	_AmibentLight("环境光",Float) = 0.0
        
    	
		[Header(CullSelect)]
		[Enum(UnityEngine.Rendering.CullMode)] _Cull ("剔除模式", Int) = 0.0  //声明外部控制开关

        [HideInInspector]
        _Cutoff("透明度剔除", Range(0,1)) = 0.5
    	
    	//_Pow("normalpow",Range(0.0,10.0))=0.0
    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
        }
        Pass {
            Name "ToonShader"
            Tags {
                "LightMode"="ForwardBase"
            }

            //可以控制披风是否剔除
			Cull [_Cull]


            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

            #pragma multi_compile_fwdbase_fullshadows
            #pragma shader_feature _ISHEAD_ON
            #pragma target 3.0

            uniform float4 _Color;
            uniform sampler2D _MainTex;
            uniform sampler2D _NormalTex;
            uniform sampler2D _EmitTex;
            uniform float _EmitInt;
			uniform float4 _AmbientCol;
            uniform float _Cutoff;
            uniform float4 _DirectionalLight01;
            uniform float4 _DirectionalLight02;
            float _AmibentLight;
            float _Pow;


            
            // 输入结构
            struct VertexInput {
                float4 vertex  : POSITION;   // 将模型的顶点信息输入进来
                float3 normal  : NORMAL;
                float4 tangent : TANGENT;
                float2 uv0     : TEXCOORD0;
            };
            // 输出结构
            struct VertexOutput {
                float4 pos    : SV_POSITION;   // 由模型顶点信息换算而来的顶点屏幕位置
                float2 uv0    : TEXCOORD0;
                float3 nDirWS : TEXCOORD1;
                float4 posWS  : TEXCOORD2;
                float3 tDirWS : TEXCOORD3;
                float3 bDirWS : TEXCOORD4;
				SHADOW_COORDS(5)
            };
            // 输入结构>>>顶点Shader>>>输出结构
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;           // 新建一个输出结构
                o.pos    = UnityObjectToClipPos( v.vertex );   // 变换顶点信息 并将其塞给输出结构
                o.nDirWS = UnityObjectToWorldNormal(v.normal);
                o.posWS  = mul(unity_ObjectToWorld,v.vertex);
                o.tDirWS = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz); // 切线方向 OS>WS
                o.bDirWS = normalize(cross(o.nDirWS, o.tDirWS) * v.tangent.w);  // 副切线方向
                o.uv0    = v.uv0;
				TRANSFER_SHADOW(o)
                return o;                                   // 将输出结构 输出
            }
            // 输出结构>>>像素
            float4 frag(VertexOutput i) : COLOR {
				//采样纹理
                float4 var_MainTex	 = tex2D(_MainTex,i.uv0);
                float4 var_NormalTex = tex2D(_NormalTex,i.uv0);
                float4 var_EmitTex   = tex2D(_EmitTex,i.uv0);

				//向量准备
                float3 nDirTS = UnpackNormal(tex2D(_NormalTex, i.uv0)).rgb;
                float3x3 TBN  = float3x3(i.tDirWS, i.bDirWS, i.nDirWS);
                float3 nDirWS = normalize(mul(nDirTS, TBN));
                float3 lDirWS = _WorldSpaceLightPos0.xyz;//Unity自带的Light  自动选最强的光当定向光
                float3 vDirWS = normalize(_WorldSpaceCameraPos.xyz - i.posWS.xyz);
                float3 hDirWS = normalize(lDirWS+vDirWS);
				float3 lDir01 = normalize(_DirectionalLight01.xyz);
            	float3 lDir02 = normalize(_DirectionalLight02.xyz);
            	
				//中间向量
				float ndotl01 = dot(nDirWS,lDir01);
				float ndotl02 = dot(nDirWS,lDir02);
				float ndotl	  = dot(nDirWS,lDirWS);
            	
				//提取信息
				float3 baseCol = var_MainTex.rgb;
                float opacity  = var_MainTex.a;
				
				//光照模型
				float lambert01  = max(0.0,ndotl01);
            	float lambert02  = max(0.0,ndotl02);
				float lambert	 = lambert01 + lambert02;
				float shadow = SHADOW_ATTENUATION(i);	//阴影			
            	
				//环境光
				float lightIntensity = smoothstep(0.0,0.01,lambert);//*shadow
				float light          = lightIntensity * _LightColor0;

                //自发光
                float3 emission		= var_EmitTex.rgb * _EmitInt;
                float3 lightingCol  = light+_AmbientCol+emission;//+specular+rim

				//返回值
            	float3 finalCol		= baseCol * _Color *lightingCol;// + _AmibentLight * baseCol;

            	

				clip(opacity-_Cutoff);//剔除
                return float4(finalCol, 1.0);//pow(1-(nDirWS.y*0.5+0.5),_Pow);//
            }
            ENDCG
        }
    }
    FallBack "Transparent/Cutout/VertexLit"
}