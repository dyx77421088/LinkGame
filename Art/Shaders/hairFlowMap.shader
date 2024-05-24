// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "XuanFu/Cha/HairFlowMap"
{
	Properties
	{
		[HDR]_Color0("Color 0", Color) = (0,0,0,0)
		_Color1("Color 1", Color) = (0,0,0,0)
		_OffsetIntensity("OffsetIntensity", Float) = 0
		_MainTex("MainTex", 2D) = "white" {}
		_UvTilling("UvTilling", Float) = 1
		_NoiesScale("NoiesScale", Float) = 1.03
		_Frequency("Frequency", Float) = 2.34
		_Smoothrange("Smoothrange", Float) = 0.86
		_SmoothSoft("SmoothSoft", Float) = 1.48
		_fireShixinRange("fireShixinRange", Float) = 0
		_SmokeRange("SmokeRange", Float) = 0
		_FireIntensity("FireIntensity", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" "Queue"="Geometry" }
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
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
			};

			uniform float _NoiesScale;
			uniform float _Frequency;
			uniform float _UvTilling;
			uniform float _OffsetIntensity;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float4 _Color1;
			uniform float4 _Color0;
			uniform float _Smoothrange;
			uniform float _SmoothSoft;
			uniform float _SmokeRange;
			uniform float _fireShixinRange;
			uniform float _FireIntensity;
					float2 voronoihash99( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi99( float2 v, inout float2 id )
					{
						float2 n = floor( v );
						float2 f = frac( v );
						float F1 = 8.0;
						float F2 = 8.0; float2 mr = 0; float2 mg = 0;
						for ( int j = -1; j <= 1; j++ )
						{
							for ( int i = -1; i <= 1; i++ )
						 	{
						 		float2 g = float2( i, j );
						 		float2 o = voronoihash99( n + g );
								o = ( sin( ( _Time.y * _Frequency ) + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = g - f + o;
								float d = 0.5 * dot( r, r );
						 		if( d<F1 ) {
						 			F2 = F1;
						 			F1 = d; mg = g; mr = r; id = o;
						 		} else if( d<F2 ) {
						 			F2 = d;
						 		}
						 	}
						}
						return F1;
					}
			
					float2 voronoihash153( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi153( float2 v, inout float2 id )
					{
						float2 n = floor( v );
						float2 f = frac( v );
						float F1 = 8.0;
						float F2 = 8.0; float2 mr = 0; float2 mg = 0;
						for ( int j = -1; j <= 1; j++ )
						{
							for ( int i = -1; i <= 1; i++ )
						 	{
						 		float2 g = float2( i, j );
						 		float2 o = voronoihash153( n + g );
								o = ( sin( ( _Time.y * 2.0 * _Frequency ) + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = g - f + o;
								float d = 0.5 * dot( r, r );
						 		if( d<F1 ) {
						 			F2 = F1;
						 			F1 = d; mg = g; mr = r; id = o;
						 		} else if( d<F2 ) {
						 			F2 = d;
						 		}
						 	}
						}
						return F1;
					}
			
			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 normalizeResult115 = normalize( v.ase_normal );
				float2 MainUV55 = ( ((float3( 0,0,0 ) + (v.vertex.xyz - float3( -0.5,-0.5,-0.5 )) * (float3( 1,1,1 ) - float3( 0,0,0 )) / (float3( 0.5,0.5,0.5 ) - float3( -0.5,-0.5,-0.5 )))).xy * _UvTilling );
				float2 appendResult129 = (float2(_Time.y , 0.0));
				float2 temp_output_128_0 = ( ( MainUV55 * float2( 1,1.7 ) ) + appendResult129 );
				float2 coords99 = temp_output_128_0 * _NoiesScale;
				float2 id99 = 0;
				float voroi99 = voronoi99( coords99, id99 );
				float myVarName183 = voroi99;
				float3 VertexOffset172 = ( ( normalizeResult115 * myVarName183 ) * _OffsetIntensity );
				
				float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.ase_texcoord1.xyz = ase_worldPos;
				
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				o.ase_texcoord2 = v.vertex;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				o.ase_texcoord1.w = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = VertexOffset172;
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
				float2 uv_MainTex = i.ase_texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float3 ase_worldPos = i.ase_texcoord1.xyz;
				float smoothstepResult122 = smoothstep( _Smoothrange , ( _Smoothrange + _SmoothSoft ) , ( 1.0 - ase_worldPos.y ));
				float Gradient162 = smoothstepResult122;
				float4 lerpResult195 = lerp( _Color1 , _Color0 , saturate( ( Gradient162 + _SmokeRange ) ));
				float2 MainUV55 = ( ((float3( 0,0,0 ) + (i.ase_texcoord2.xyz - float3( -0.5,-0.5,-0.5 )) * (float3( 1,1,1 ) - float3( 0,0,0 )) / (float3( 0.5,0.5,0.5 ) - float3( -0.5,-0.5,-0.5 )))).xy * _UvTilling );
				float2 appendResult129 = (float2(_Time.y , 0.0));
				float2 temp_output_128_0 = ( ( MainUV55 * float2( 1,1.7 ) ) + appendResult129 );
				float2 coords99 = temp_output_128_0 * _NoiesScale;
				float2 id99 = 0;
				float voroi99 = voronoi99( coords99, id99 );
				float2 coords153 = temp_output_128_0 * ( _NoiesScale * 6.0 );
				float2 id153 = 0;
				float voroi153 = voronoi153( coords153, id153 );
				float blendOpSrc150 = voroi99;
				float blendOpDest150 = voroi153;
				float Noies146 = saturate( ( saturate( (( blendOpSrc150 > 0.5 ) ? max( blendOpDest150, 2.0 * ( blendOpSrc150 - 0.5 ) ) : min( blendOpDest150, 2.0 * blendOpSrc150 ) ) )) );
				float4 appendResult127 = (float4(( tex2D( _MainTex, uv_MainTex ) * lerpResult195 ).rgb , saturate( ( ( ( Noies146 * Gradient162 ) + saturate( ( Gradient162 + _fireShixinRange ) ) ) * _FireIntensity ) )));
				float4 Color166 = appendResult127;
				
				
				finalColor = Color166;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=17101
1927;87;1906;938;785.641;885.6904;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;52;-2837.107,-1027.285;Inherit;False;1366.965;638.5016;Comment;8;55;76;75;58;62;84;86;85;;1,1,1,1;0;0
Node;AmplifyShaderEditor.PosVertexDataNode;62;-2822.866,-1000.474;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;84;-2497.258,-992.6072;Inherit;False;5;0;FLOAT3;0,0,0;False;1;FLOAT3;-0.5,-0.5,-0.5;False;2;FLOAT3;0.5,0.5,0.5;False;3;FLOAT3;0,0,0;False;4;FLOAT3;1,1,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;58;-2299.027,-997.6732;Inherit;True;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;75;-2311.287,-754.6271;Inherit;False;Property;_UvTilling;UvTilling;4;0;Create;True;0;0;False;0;1;0.35;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;-1989.289,-903.5671;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;144;-2869.175,-316.8513;Inherit;False;1668.629;769.1516;Comment;17;146;152;150;153;99;149;128;159;102;126;129;100;98;156;183;205;206;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;55;-1697.616,-904.0054;Inherit;False;MainUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;206;-2862.207,-237.3633;Inherit;False;Constant;_Vector0;Vector 0;12;0;Create;True;0;0;False;0;1,1.7;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;126;-2852.309,-284.571;Inherit;False;55;MainUV;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;156;-2866.186,-110.6652;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;98;-2600.422,147.8214;Inherit;False;Property;_NoiesScale;NoiesScale;5;0;Create;True;0;0;False;0;1.03;0.45;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;100;-2785.166,-65.91879;Inherit;False;Property;_Frequency;Frequency;6;0;Create;True;0;0;False;0;2.34;2.13;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;205;-2645.207,-278.3633;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;163;-2840.986,1436.189;Inherit;False;897.7723;499.3208;Comment;7;138;120;122;125;123;124;162;Gradient;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;129;-2636.539,-188.3808;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;149;-2300.572,210.146;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;6;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;138;-2790.987,1486.189;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;159;-2553.101,19.57989;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;124;-2679.018,1820.51;Inherit;False;Property;_SmoothSoft;SmoothSoft;8;0;Create;True;0;0;False;0;1.48;5.16;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;123;-2673.919,1745.484;Inherit;False;Property;_Smoothrange;Smoothrange;7;0;Create;True;0;0;False;0;0.86;-28.38;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;128;-2491.816,-271.0186;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;-2552.98,-104.9561;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;153;-2096.154,107.272;Inherit;True;0;0;1;0;1;False;1;False;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;2;FLOAT;0;FLOAT;1
Node;AmplifyShaderEditor.VoronoiNode;99;-2087.533,-224.8039;Inherit;True;0;0;1;0;1;False;1;False;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;2;FLOAT;0;FLOAT;1
Node;AmplifyShaderEditor.OneMinusNode;120;-2610.533,1534.286;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;125;-2463.593,1762.07;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;122;-2367.686,1517.64;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;150;-1826.833,-3.747785;Inherit;True;PinLight;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;152;-1573.027,27.91698;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;165;-1057.943,-876.5318;Inherit;False;1541.323;1040.212;Comment;20;3;127;147;161;137;164;166;179;181;180;197;195;198;199;200;201;4;202;203;204;Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;162;-2186.214,1553.855;Inherit;False;Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;180;-981.06,-191.3866;Inherit;False;Property;_fireShixinRange;fireShixinRange;9;0;Create;True;0;0;False;0;0;-0.76;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;146;-1426.901,17.45306;Inherit;False;Noies;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;164;-1030.442,-330.0822;Inherit;False;162;Gradient;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;147;-972.9593,-499.6071;Inherit;False;146;Noies;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;179;-770.6783,-230.3909;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;199;-982.7882,-437.5194;Inherit;False;Property;_SmokeRange;SmokeRange;10;0;Create;True;0;0;False;0;0;-0.12;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;198;-615.7164,-568.7732;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;181;-636.5485,-230.4329;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;160;-2879.119,612.7561;Inherit;False;1534.746;663.3007;Comment;7;114;115;113;171;172;177;178;VertexOffset;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;161;-713.9838,-443.2528;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;200;-501.1469,-631.5196;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;3;-859.2458,-648.9846;Inherit;False;Property;_Color0;Color 0;0;1;[HDR];Create;True;0;0;False;0;0,0,0,0;4.861001,1.307441,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;137;-502.6851,-399.7154;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;204;-437.9178,-175.1688;Inherit;False;Property;_FireIntensity;FireIntensity;11;0;Create;True;0;0;False;0;0;3.82;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;183;-1783.19,-189.7145;Inherit;False;myVarName;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;197;-920.0438,-805.508;Inherit;False;Property;_Color1;Color 1;1;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalVertexDataNode;113;-2829.119,662.7562;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalizeNode;115;-2633.298,669.2353;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;203;-249.1683,-379.6471;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;4;-707.999,-847.3036;Inherit;True;Property;_MainTex;MainTex;3;0;Create;True;0;0;False;0;None;f772013b0515dd2408b18f46817c7e92;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;171;-2748.066,799.4388;Inherit;False;183;myVarName;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;195;-451.6839,-760.3348;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;201;-239.9084,-781.8666;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;202;-203.496,-528.3283;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;-2419.033,664.6085;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;178;-2457.068,835.6291;Inherit;False;Property;_OffsetIntensity;OffsetIntensity;2;0;Create;True;0;0;False;0;0;2.46;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;127;-98.84361,-788.1924;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;177;-2183.477,699.6534;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;172;-2008.04,668.7729;Inherit;False;VertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;166;223.1051,-781.7346;Inherit;False;Color;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldPosInputsNode;86;-2749.348,-688.842;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;85;-2758.086,-821.2202;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;170;593.7972,-150.31;Inherit;False;172;VertexOffset;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;167;618.118,-238.61;Inherit;False;166;Color;1;0;OBJECT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;194;867.5865,-188.9314;Float;False;True;2;ASEMaterialInspector;0;1;XuanFu/Cha/HairFlowMap;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;True;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;0;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;2;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;0
WireConnection;84;0;62;0
WireConnection;58;0;84;0
WireConnection;76;0;58;0
WireConnection;76;1;75;0
WireConnection;55;0;76;0
WireConnection;205;0;126;0
WireConnection;205;1;206;0
WireConnection;129;0;156;0
WireConnection;149;0;98;0
WireConnection;159;0;156;0
WireConnection;159;2;100;0
WireConnection;128;0;205;0
WireConnection;128;1;129;0
WireConnection;102;0;156;0
WireConnection;102;1;100;0
WireConnection;153;0;128;0
WireConnection;153;1;159;0
WireConnection;153;2;149;0
WireConnection;99;0;128;0
WireConnection;99;1;102;0
WireConnection;99;2;98;0
WireConnection;120;0;138;2
WireConnection;125;0;123;0
WireConnection;125;1;124;0
WireConnection;122;0;120;0
WireConnection;122;1;123;0
WireConnection;122;2;125;0
WireConnection;150;0;99;0
WireConnection;150;1;153;0
WireConnection;152;0;150;0
WireConnection;162;0;122;0
WireConnection;146;0;152;0
WireConnection;179;0;164;0
WireConnection;179;1;180;0
WireConnection;198;0;164;0
WireConnection;198;1;199;0
WireConnection;181;0;179;0
WireConnection;161;0;147;0
WireConnection;161;1;164;0
WireConnection;200;0;198;0
WireConnection;137;0;161;0
WireConnection;137;1;181;0
WireConnection;183;0;99;0
WireConnection;115;0;113;0
WireConnection;203;0;137;0
WireConnection;203;1;204;0
WireConnection;195;0;197;0
WireConnection;195;1;3;0
WireConnection;195;2;200;0
WireConnection;201;0;4;0
WireConnection;201;1;195;0
WireConnection;202;0;203;0
WireConnection;114;0;115;0
WireConnection;114;1;171;0
WireConnection;127;0;201;0
WireConnection;127;3;202;0
WireConnection;177;0;114;0
WireConnection;177;1;178;0
WireConnection;172;0;177;0
WireConnection;166;0;127;0
WireConnection;194;0;167;0
WireConnection;194;1;170;0
ASEEND*/
//CHKSM=328F3FD28912EAEC38BB8D3AB42214D64856B628