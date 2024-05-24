// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "XuanFu/VFX/Magma1"
{
	Properties
	{
		_Width("Width", Float) = 0
		_Height("Height", Float) = 0
		_MaskSoft("MaskSoft", Float) = 0
		[HDR]_EdgeColor("EdgeColor", Color) = (1,1,1,1)
		_DisturTex("DisturTex", 2D) = "white" {}
		_DisturPow("DisturPow", Float) = 0
		[HDR]_Color0("Color 0", Color) = (0,0,0,0)
		_MainTex("MainTex", 2D) = "white" {}
		_Vector0("Vector 0", Vector) = (0,0,0,0)
		_HorizontalPow("HorizontalPow", Float) = 0
		_HorixontalTex("HorixontalTex", 2D) = "white" {}
		_VerticalPow("VerticalPow", Float) = 0.5
		_VertexAni("VertexAni", 2D) = "white" {}
		_MaskTex("MaskTex", 2D) = "white" {}
		_MaskPercentage("MaskPercentage", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" "Queue"="Transparent" }
		LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Back
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float4 ase_texcoord : TEXCOORD0;
				float3 ase_normal : NORMAL;
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
			};

			uniform sampler2D _HorixontalTex;
			uniform float4 _HorixontalTex_ST;
			uniform float _HorizontalPow;
			uniform sampler2D _VertexAni;
			uniform float4 _VertexAni_ST;
			uniform float _VerticalPow;
			uniform float4 _EdgeColor;
			uniform float4 _Color0;
			uniform sampler2D _MainTex;
			uniform sampler2D _DisturTex;
			uniform float4 _DisturTex_ST;
			uniform float _DisturPow;
			uniform float4 _MainTex_ST;
			uniform float2 _Vector0;
			uniform float4 MagmaObject01[5];
			uniform float _Height;
			uniform float _MaskSoft;
			uniform float _Width;
			uniform sampler2D _MaskTex;
			uniform float4 _MaskTex_ST;
			uniform float _MaskPercentage;
			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float mulTime405 = _Time.y * -2.0;
				float2 uv0_HorixontalTex = v.ase_texcoord * _HorixontalTex_ST.xy + _HorixontalTex_ST.zw;
				float2 panner403 = ( mulTime405 * float2( 0,0.7 ) + uv0_HorixontalTex);
				float temp_output_204_0 = ( tex2Dlod( _HorixontalTex, float4( panner403, 0, 0.0) ).r * _HorizontalPow );
				float mulTime182 = _Time.y * -0.25;
				float2 uv0_VertexAni = v.ase_texcoord.xy * _VertexAni_ST.xy + _VertexAni_ST.zw;
				float2 panner181 = ( mulTime182 * float2( 0,0.7 ) + uv0_VertexAni);
				float3 appendResult397 = (float3(temp_output_204_0 , 1.0 , ( tex2Dlod( _VertexAni, float4( panner181, 0, 0.0) ).r * saturate( v.ase_normal.z ) * _VerticalPow )));
				
				float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.ase_texcoord1.xyz = ase_worldPos;
				
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				o.ase_texcoord1.w = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = appendResult397;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				float mulTime199 = _Time.y * -1.0;
				float2 uv0_DisturTex = i.ase_texcoord.xy * _DisturTex_ST.xy + _DisturTex_ST.zw;
				float2 panner201 = ( mulTime199 * float2( 0,0.3 ) + uv0_DisturTex);
				float2 uv0_MainTex = i.ase_texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode140 = tex2D( _MainTex, ( ( pow( tex2D( _DisturTex, panner201 ).r , _DisturPow ) + uv0_MainTex ) + ( _Vector0 * _Time.y ) ) );
				float3 ase_worldPos = i.ase_texcoord1.xyz;
				float4 break282 = MagmaObject01[clamp(0,0,(5 - 1))];
				float temp_output_314_0 = saturate( ( ( ( ase_worldPos.y - break282.y ) - _Height ) / _MaskSoft ) );
				float3 appendResult287 = (float3(break282.x , 1.0 , break282.z));
				float3 appendResult288 = (float3(ase_worldPos.x , 1.0 , ase_worldPos.z));
				float4 break285 = MagmaObject01[1];
				float temp_output_318_0 = saturate( ( ( ( ase_worldPos.y - break285.y ) - _Height ) / _MaskSoft ) );
				float3 appendResult291 = (float3(break285.x , 1.0 , break285.z));
				float3 appendResult290 = (float3(ase_worldPos.x , 1.0 , ase_worldPos.z));
				float4 break284 = MagmaObject01[2];
				float temp_output_317_0 = saturate( ( ( ( ase_worldPos.y - break284.y ) - _Height ) / _MaskSoft ) );
				float3 appendResult286 = (float3(break284.x , 1.0 , break284.z));
				float3 appendResult289 = (float3(ase_worldPos.x , 1.0 , ase_worldPos.z));
				float temp_output_322_0 = ( max( temp_output_314_0 , saturate( ( ( distance( appendResult287 , appendResult288 ) - _Width ) / _MaskSoft ) ) ) * max( temp_output_318_0 , saturate( ( ( distance( appendResult291 , appendResult290 ) - _Width ) / _MaskSoft ) ) ) * max( temp_output_317_0 , saturate( ( ( distance( appendResult286 , appendResult289 ) - _Width ) / _MaskSoft ) ) ) );
				float4 lerpResult125 = lerp( _EdgeColor , ( _Color0 * tex2DNode140 ) , temp_output_322_0);
				float2 uv_MaskTex = i.ase_texcoord.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float Mask380 = saturate( step( tex2D( _MaskTex, uv_MaskTex ).r , _MaskPercentage ) );
				float4 appendResult268 = (float4(lerpResult125.rgb , ( ( temp_output_322_0 * tex2DNode140.a ) * Mask380 )));
				
				finalColor = appendResult268;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=17101
2935;250;1906;930;6567.767;11.59622;3.138173;True;False
Node;AmplifyShaderEditor.CommentaryNode;278;-5165.745,-785.4025;Inherit;False;3121.339;1289.883;Comment;47;322;321;320;319;318;317;316;315;314;313;312;311;310;309;308;307;306;305;304;303;302;301;300;299;298;297;296;295;294;293;292;291;290;289;288;287;286;285;284;283;282;281;280;279;370;371;327;mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.GlobalArrayNode;279;-5027.619,-266.9637;Inherit;False;MagmaObjectPos;1;3;2;False;False;0;1;False;Instance;280;4;0;INT;0;False;2;INT;0;False;1;INT;0;False;3;INT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GlobalArrayNode;281;-5114.303,-44.86479;Inherit;False;MagmaObjectPos;2;3;2;False;False;0;1;False;Instance;280;4;0;INT;0;False;2;INT;0;False;1;INT;0;False;3;INT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GlobalArrayNode;280;-4943.331,-635.9836;Inherit;False;MagmaObject01;0;5;2;True;False;0;1;True;Object;280;4;0;INT;0;False;2;INT;0;False;1;INT;0;False;3;INT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.BreakToComponentsNode;282;-4548.1,-579.7328;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.BreakToComponentsNode;285;-4773.08,-160.7605;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.WorldPosInputsNode;283;-4603.606,-399.912;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.BreakToComponentsNode;284;-4766.08,130.1219;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;290;-4229.342,41.03329;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;287;-4264.24,-571.822;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;289;-4290.202,345.5638;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleTimeNode;199;-3895.287,1031.386;Inherit;False;1;0;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;200;-3976.138,880.4335;Inherit;False;0;128;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;286;-4311.948,173.033;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;288;-4226.948,-341.2843;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;291;-4279.334,-158.3074;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PannerNode;201;-3634.332,933.4343;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0.3;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DistanceOpNode;293;-4096.265,371.4805;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;295;-4068.808,-320.8115;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;299;-3685.015,231.7366;Inherit;False;Property;_Width;Width;0;0;Create;True;0;0;False;0;0;2.94;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;297;-4046.354,24.92358;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;294;-4066,200.6343;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;298;-3615.223,-363.1099;Inherit;False;Property;_Height;Height;1;0;Create;True;0;0;False;0;0;2.08;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;292;-3979.842,-162.0523;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;296;-3972.162,-445.7536;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;301;-3319.55,228.764;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;300;-3331.702,341.6727;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;304;-3242.779,-96.2831;Inherit;False;Property;_MaskSoft;MaskSoft;2;0;Create;True;0;0;False;0;0;0.38;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;306;-3316.131,107.0859;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;379;-4466.285,1561.2;Inherit;False;2370.165;1387.36;mask;6;378;380;382;384;387;393;mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;305;-3250.233,-324.7183;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;303;-3274.004,-445.5956;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;128;-3396.506,915.1392;Inherit;True;Property;_DisturTex;DisturTex;4;0;Create;True;0;0;False;0;None;e8f905cf956fb494b894011e8ca833d1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;131;-3316.428,1101.017;Inherit;False;Property;_DisturPow;DisturPow;5;0;Create;True;0;0;False;0;0;0.06;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;302;-3248.373,-230.6756;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;378;-3828.908,1624.062;Inherit;True;Property;_MaskTex;MaskTex;13;0;Create;True;0;0;False;0;None;c94ed89d2d3e8204b95ea486a006346e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;144;-3485.069,1436.418;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;311;-2971.124,-348.4109;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;307;-2983.422,-167.0177;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;57;-3189.979,1181.024;Inherit;False;0;140;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;309;-2972.738,-260.9686;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;145;-3255.336,1315.854;Inherit;False;Property;_Vector0;Vector 0;8;0;Create;True;0;0;False;0;0,0;0,-0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleDivideOpNode;312;-2966.422,80.99213;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;308;-2968.859,192.1227;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;208;-3019.484,982.4393;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;387;-3651.489,1868.283;Inherit;False;Property;_MaskPercentage;MaskPercentage;14;0;Create;True;0;0;False;0;0;1.190242;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;310;-2974.03,314.4939;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;146;-3008.512,1367.518;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;316;-2672.594,290.5406;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;315;-2666.427,-108.8672;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;317;-2684.036,81.14563;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;314;-2670.42,-284.195;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;129;-2861.165,1069.483;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;313;-2696.948,172.1544;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;318;-2675.418,3.586583;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;393;-3284.312,1704.263;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;406;-2494.069,981.8058;Inherit;False;0;402;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;180;-2497.085,1194.493;Inherit;False;0;202;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;143;-2687.913,739.1262;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;405;-2312.069,1128.705;Inherit;False;1;0;FLOAT;-2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;321;-2477.948,-1.544357;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;384;-3059.987,1686.162;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;182;-2486.252,1314.721;Inherit;False;1;0;FLOAT;-0.25;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;320;-2488.541,120.1492;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;319;-2501.72,-196.6827;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;138;-2053.545,227.9861;Inherit;False;Property;_Color0;Color 0;6;1;[HDR];Create;True;0;0;False;0;0,0,0,0;2.5,2.5,2.5,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;403;-2139.168,1018.206;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0.7;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NormalVertexDataNode;394;-1865.132,1545.052;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;140;-2489.292,698.4009;Inherit;True;Property;_MainTex;MainTex;7;0;Create;True;0;0;False;0;None;0e08587213a7ed74f8f2e2df25430543;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;380;-2726.792,1692.912;Inherit;False;Mask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;322;-2289.983,-86.49519;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;181;-2224.584,1225.052;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0.7;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;190;-1879.809,1099.58;Inherit;False;Property;_HorizontalPow;HorizontalPow;9;0;Create;True;0;0;False;0;0;-0.14;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;400;-1632.169,1360.105;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;377;-1514.381,494.1096;Inherit;False;380;Mask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;126;-1956.947,-88.12038;Inherit;False;Property;_EdgeColor;EdgeColor;3;1;[HDR];Create;True;0;0;False;0;1,1,1,1;4.778,3.657642,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;139;-1830.148,229.8779;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;401;-1623.069,1479.705;Inherit;False;Property;_VerticalPow;VerticalPow;11;0;Create;True;0;0;False;0;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;243;-1369.12,331.8727;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;202;-2026.468,1181.648;Inherit;True;Property;_VertexAni;VertexAni;12;0;Create;True;0;0;False;0;None;b28c9763c36a92b40bfb12ae3b88106d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;402;-1877.87,870.0054;Inherit;True;Property;_HorixontalTex;HorixontalTex;10;0;Create;True;0;0;False;0;None;9af08c23a764405409bb46d7418da05b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;398;-1444.021,1280.841;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;204;-1605.497,1049.038;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;125;-1531.577,127.4327;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;392;-1172.964,461.2466;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;130;-3033.972,1075.042;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;196;-1385.224,1015.176;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMinOpNode;370;-2399.678,-599.5156;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;397;-1241.223,1192.441;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;382;-2982.497,1949.071;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;371;-2268.595,-616.9879;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;327;-2113.859,-625.8663;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;381;-1175.761,184.9218;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;268;-1012.685,389.3637;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SaturateNode;277;-1915.697,-627.6187;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;267;-755.9084,632.1141;Float;False;True;2;ASEMaterialInspector;0;1;XuanFu/VFX/Magma1;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;True;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;0;False;-1;True;0;False;-1;True;True;0;False;-1;0;False;-1;True;2;RenderType=Opaque=RenderType;Queue=Transparent=Queue=0;True;2;0;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;0
WireConnection;282;0;280;0
WireConnection;285;0;279;0
WireConnection;284;0;281;0
WireConnection;290;0;283;1
WireConnection;290;2;283;3
WireConnection;287;0;282;0
WireConnection;287;2;282;2
WireConnection;289;0;283;1
WireConnection;289;2;283;3
WireConnection;286;0;284;0
WireConnection;286;2;284;2
WireConnection;288;0;283;1
WireConnection;288;2;283;3
WireConnection;291;0;285;0
WireConnection;291;2;285;2
WireConnection;201;0;200;0
WireConnection;201;1;199;0
WireConnection;293;0;286;0
WireConnection;293;1;289;0
WireConnection;295;0;287;0
WireConnection;295;1;288;0
WireConnection;297;0;291;0
WireConnection;297;1;290;0
WireConnection;294;0;283;2
WireConnection;294;1;284;1
WireConnection;292;0;283;2
WireConnection;292;1;285;1
WireConnection;296;0;283;2
WireConnection;296;1;282;1
WireConnection;301;0;297;0
WireConnection;301;1;299;0
WireConnection;300;0;293;0
WireConnection;300;1;299;0
WireConnection;306;0;295;0
WireConnection;306;1;299;0
WireConnection;305;0;292;0
WireConnection;305;1;298;0
WireConnection;303;0;296;0
WireConnection;303;1;298;0
WireConnection;128;1;201;0
WireConnection;302;0;294;0
WireConnection;302;1;298;0
WireConnection;311;0;303;0
WireConnection;311;1;304;0
WireConnection;307;0;302;0
WireConnection;307;1;304;0
WireConnection;309;0;305;0
WireConnection;309;1;304;0
WireConnection;312;0;306;0
WireConnection;312;1;304;0
WireConnection;308;0;301;0
WireConnection;308;1;304;0
WireConnection;208;0;128;1
WireConnection;208;1;131;0
WireConnection;310;0;300;0
WireConnection;310;1;304;0
WireConnection;146;0;145;0
WireConnection;146;1;144;0
WireConnection;316;0;310;0
WireConnection;315;0;312;0
WireConnection;317;0;307;0
WireConnection;314;0;311;0
WireConnection;129;0;208;0
WireConnection;129;1;57;0
WireConnection;313;0;308;0
WireConnection;318;0;309;0
WireConnection;393;0;378;1
WireConnection;393;1;387;0
WireConnection;143;0;129;0
WireConnection;143;1;146;0
WireConnection;321;0;318;0
WireConnection;321;1;313;0
WireConnection;384;0;393;0
WireConnection;320;0;317;0
WireConnection;320;1;316;0
WireConnection;319;0;314;0
WireConnection;319;1;315;0
WireConnection;403;0;406;0
WireConnection;403;1;405;0
WireConnection;140;1;143;0
WireConnection;380;0;384;0
WireConnection;322;0;319;0
WireConnection;322;1;321;0
WireConnection;322;2;320;0
WireConnection;181;0;180;0
WireConnection;181;1;182;0
WireConnection;400;0;394;3
WireConnection;139;0;138;0
WireConnection;139;1;140;0
WireConnection;243;0;322;0
WireConnection;243;1;140;4
WireConnection;202;1;181;0
WireConnection;402;1;403;0
WireConnection;398;0;202;1
WireConnection;398;1;400;0
WireConnection;398;2;401;0
WireConnection;204;0;402;1
WireConnection;204;1;190;0
WireConnection;125;0;126;0
WireConnection;125;1;139;0
WireConnection;125;2;322;0
WireConnection;392;0;243;0
WireConnection;392;1;377;0
WireConnection;196;0;204;0
WireConnection;370;0;314;0
WireConnection;370;1;318;0
WireConnection;397;0;204;0
WireConnection;397;2;398;0
WireConnection;371;0;370;0
WireConnection;371;1;317;0
WireConnection;327;0;371;0
WireConnection;268;0;125;0
WireConnection;268;3;392;0
WireConnection;277;0;327;0
WireConnection;267;0;268;0
WireConnection;267;1;397;0
ASEEND*/
//CHKSM=21A762894D935A6FA4453C467BB6E92E99C783F2