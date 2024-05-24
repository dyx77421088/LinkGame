// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "fire_Style"
{
	Properties
	{
		_MaskTex("MaskTex", 2D) = "white" {}
		[HDR]_EdgeColor("EdgeColor", Color) = (0,0,0,0)
		_firerongjie("firerongjie", Range( 0 , 1)) = 1
		[HDR]_FirstColor("FirstColor", Color) = (1,0,0,0)
		_FirstColorRange("FirstColorRange", Float) = 0
		_SecondColorRange("SecondColorRange", Float) = 0
		[HDR]_SecondColor("SecondColor", Color) = (1,0.5586207,0,0)
		_VorScalse02("VorScalse02", Float) = 3
		_VorScalse01("VorScalse01", Float) = 5
		_Vor2UV("Vor2UV", Vector) = (2,1,0,-1)
		_Vor1UV("Vor1UV", Vector) = (2,1,0,-1)
		_GradientSoft("GradientSoft", Float) = 1.65
		_Gradient("Gradient", Float) = 0.16
		_SingleOrDoubleGradient("SingleOrDoubleGradient", Range( 0 , 0.5)) = 0
		_ShiXin("ShiXin", Float) = 0
		_ShiXinSoft("ShiXinSoft", Float) = 0
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
		Cull Off
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
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_texcoord : TEXCOORD0;
			};

			uniform float4 _EdgeColor;
			uniform float4 _FirstColor;
			uniform float _FirstColorRange;
			uniform float _firerongjie;
			uniform float _VorScalse01;
			uniform float4 _Vor1UV;
			uniform float _VorScalse02;
			uniform float4 _Vor2UV;
			uniform float _ShiXin;
			uniform float _ShiXinSoft;
			uniform float _SingleOrDoubleGradient;
			uniform sampler2D _MaskTex;
			uniform float4 _MaskTex_ST;
			uniform float _Gradient;
			uniform float _GradientSoft;
			uniform float4 _SecondColor;
			uniform float _SecondColorRange;
					float2 voronoihash20( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi20( float2 v, inout float2 id )
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
						 		float2 o = voronoihash20( n + g );
								o = ( sin( ( _Time.y * 1.0 ) + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = g - f + o;
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
			
					float2 voronoihash34( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi34( float2 v, inout float2 id )
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
						 		float2 o = voronoihash34( n + g );
								o = ( sin( ( _Time.y * 0.7 ) + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = g - f + o;
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

				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
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
				float temp_output_51_0 = ( _firerongjie * 0.1 );
				float temp_output_8_0 = ( _FirstColorRange + temp_output_51_0 );
				float2 appendResult28 = (float2(_Vor1UV.z , _Vor1UV.w));
				float2 appendResult31 = (float2(_Vor1UV.x , _Vor1UV.y));
				float2 uv024 = i.ase_texcoord.xy * appendResult31 + float2( 0,0 );
				float2 panner25 = ( _Time.y * appendResult28 + uv024);
				float2 coords20 = panner25 * _VorScalse01;
				float2 id20 = 0;
				float voroi20 = voronoi20( coords20, id20 );
				float2 appendResult37 = (float2(_Vor2UV.z , _Vor2UV.w));
				float2 appendResult33 = (float2(_Vor2UV.x , _Vor2UV.y));
				float2 uv036 = i.ase_texcoord.xy * appendResult33 + float2( 0,0 );
				float2 panner38 = ( _Time.y * appendResult37 + uv036);
				float2 coords34 = panner38 * _VorScalse02;
				float2 id34 = 0;
				float voroi34 = voronoi34( coords34, id34 );
				float blendOpSrc44 = voroi20;
				float blendOpDest44 = voroi34;
				float2 uv052 = i.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_92_0 = saturate( ( 1.0 - abs( ( uv052.y - _SingleOrDoubleGradient ) ) ) );
				float smoothstepResult88 = smoothstep( _ShiXin , ( _ShiXin + _ShiXinSoft ) , temp_output_92_0);
				float2 uv_MaskTex = i.ase_texcoord.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float smoothstepResult64 = smoothstep( _Gradient , ( _Gradient + _GradientSoft ) , temp_output_92_0);
				float fire48 = ( ( ( saturate( ( saturate( (( blendOpSrc44 > 0.5 ) ? max( blendOpDest44, 2.0 * ( blendOpSrc44 - 0.5 ) ) : min( blendOpDest44, 2.0 * blendOpSrc44 ) ) )) ) + smoothstepResult88 ) * tex2D( _MaskTex, uv_MaskTex ).r ) * smoothstepResult64 );
				float4 lerpResult12 = lerp( _EdgeColor , _FirstColor , step( temp_output_8_0 , fire48 ));
				float4 lerpResult17 = lerp( lerpResult12 , _SecondColor , step( ( _SecondColorRange + temp_output_8_0 ) , fire48 ));
				float4 appendResult7 = (float4(lerpResult17.rgb , step( temp_output_51_0 , fire48 )));
				
				
				finalColor = appendResult7;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=17101
2116;152;1804;758;2779.441;1444.349;2.487886;True;False
Node;AmplifyShaderEditor.Vector4Node;32;-3956.944,-426.0389;Inherit;False;Property;_Vor2UV;Vor2UV;9;0;Create;True;0;0;False;0;2,1,0,-1;3,1,0,-0.55;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;30;-3926.749,-866.8677;Inherit;False;Property;_Vor1UV;Vor1UV;10;0;Create;True;0;0;False;0;2,1,0,-1;2,1,0,-0.86;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;53;-3623.885,63.0513;Inherit;False;1144.549;609.6924;Comment;14;64;65;66;62;92;81;80;78;79;52;88;86;90;89;Gradient;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;79;-3613.637,219.4065;Inherit;False;Property;_SingleOrDoubleGradient;SingleOrDoubleGradient;13;0;Create;True;0;0;False;0;0;0;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;31;-3720.05,-879.8677;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;33;-3750.243,-439.0389;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;52;-3615.999,97.89005;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;43;-3397.011,-86.1945;Inherit;False;Constant;_Float2;Float 2;9;0;Create;True;0;0;False;0;0.7;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;78;-3365.005,98.43253;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;24;-3570,-951.884;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;37;-3446.044,-374.0389;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;28;-3369.842,-908.6558;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;35;-3471.195,-198.055;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;36;-3600.195,-511.0551;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;41;-3378.792,-671.1111;Inherit;False;Constant;_Float1;Float 1;9;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;23;-3550.465,-782.5982;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;80;-3171.279,100.1172;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;-3219.324,-159.4003;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-3137.792,-692.1111;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-3293.938,-511.1943;Inherit;False;Property;_VorScalse01;VorScalse01;8;0;Create;True;0;0;False;0;5;6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;25;-3143.512,-900.6719;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;38;-3217.195,-363.055;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-3398.117,-7.852545;Inherit;False;Property;_VorScalse02;VorScalse02;7;0;Create;True;0;0;False;0;3;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;86;-3370.844,449.9988;Inherit;False;Property;_ShiXin;ShiXin;14;0;Create;True;0;0;False;0;0;0.74;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;81;-3012.832,98.28843;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;90;-3390.319,548.9723;Inherit;False;Property;_ShiXinSoft;ShiXinSoft;15;0;Create;True;0;0;False;0;0;0.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;34;-2986.469,-228.0955;Inherit;True;0;0;1;0;1;False;1;False;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;2;FLOAT;0;FLOAT;1
Node;AmplifyShaderEditor.VoronoiNode;20;-2910.265,-762.7126;Inherit;True;0;0;1;0;1;False;1;False;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;2;FLOAT;0;FLOAT;1
Node;AmplifyShaderEditor.BlendOpsNode;44;-2522.227,-478.465;Inherit;True;PinLight;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;92;-2856.161,104.8534;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;89;-3069.848,566.271;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;88;-2736.446,415.3025;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-3043.394,389.5641;Inherit;False;Property;_GradientSoft;GradientSoft;11;0;Create;True;0;0;False;0;1.65;1.37;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-3137.993,310.4732;Inherit;False;Property;_Gradient;Gradient;12;0;Create;True;0;0;False;0;0.16;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;45;-2264.455,-420.741;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;82;-3616.183,749.9016;Inherit;False;1209.996;540.9931;Comment;1;1;Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;65;-2843.014,302.459;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-2820.608,813.1733;Inherit;True;Property;_MaskTex;MaskTex;0;0;Create;True;0;0;False;0;add21a9cd16923a43859080e3cdff5f2;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;69;-2251.849,-259.6208;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;94;-2055.13,-225.7747;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;19;-1435.609,-1024.443;Inherit;False;1659.601;1329.703;Comment;16;4;9;14;8;10;11;13;5;16;18;12;3;17;7;49;51;FireColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.SmoothstepOpNode;64;-2691.102,90.58844;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-1403.429,-95.07661;Inherit;False;Property;_firerongjie;firerongjie;2;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-1855.93,-92.29053;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-1288.007,-273.3567;Inherit;False;Property;_FirstColorRange;FirstColorRange;4;0;Create;True;0;0;False;0;0;0.03;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-1128.572,-93.70356;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;48;-1677.594,-116.9728;Inherit;False;fire;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;49;-1100.808,38.93999;Inherit;False;48;fire;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-1262.512,-439.9939;Inherit;False;Property;_SecondColorRange;SecondColorRange;5;0;Create;True;0;0;False;0;0;0.06;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;8;-987.6899,-200.0714;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;13;-893.4227,-388.8063;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;11;-587.7212,-785.3206;Inherit;False;Property;_FirstColor;FirstColor;3;1;[HDR];Create;True;0;0;False;0;1,0,0,0;3.369,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;5;-423.5688,-974.443;Inherit;False;Property;_EdgeColor;EdgeColor;1;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;10;-604.4191,-194.0591;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;12;-234.5411,-670.0134;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;18;-668.277,-581.0842;Inherit;False;Property;_SecondColor;SecondColor;6;1;[HDR];Create;True;0;0;False;0;1,0.5586207,0,0;1.044,0.9288002,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;16;-668.5283,-361.2714;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;17;-99.78718,-395.3634;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;3;-701.526,100.0733;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;7;50.99215,-95.81311;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;570.8994,-103.4927;Float;False;True;2;ASEMaterialInspector;0;1;fire_Style;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;True;False;True;2;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;2;RenderType=Opaque=RenderType;Queue=Transparent=Queue=0;True;2;0;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;0
WireConnection;31;0;30;1
WireConnection;31;1;30;2
WireConnection;33;0;32;1
WireConnection;33;1;32;2
WireConnection;78;0;52;2
WireConnection;78;1;79;0
WireConnection;24;0;31;0
WireConnection;37;0;32;3
WireConnection;37;1;32;4
WireConnection;28;0;30;3
WireConnection;28;1;30;4
WireConnection;36;0;33;0
WireConnection;80;0;78;0
WireConnection;42;0;35;0
WireConnection;42;1;43;0
WireConnection;40;0;23;0
WireConnection;40;1;41;0
WireConnection;25;0;24;0
WireConnection;25;2;28;0
WireConnection;25;1;23;0
WireConnection;38;0;36;0
WireConnection;38;2;37;0
WireConnection;38;1;35;0
WireConnection;81;0;80;0
WireConnection;34;0;38;0
WireConnection;34;1;42;0
WireConnection;34;2;39;0
WireConnection;20;0;25;0
WireConnection;20;1;40;0
WireConnection;20;2;21;0
WireConnection;44;0;20;0
WireConnection;44;1;34;0
WireConnection;92;0;81;0
WireConnection;89;0;86;0
WireConnection;89;1;90;0
WireConnection;88;0;92;0
WireConnection;88;1;86;0
WireConnection;88;2;89;0
WireConnection;45;0;44;0
WireConnection;65;0;62;0
WireConnection;65;1;66;0
WireConnection;69;0;45;0
WireConnection;69;1;88;0
WireConnection;94;0;69;0
WireConnection;94;1;1;1
WireConnection;64;0;92;0
WireConnection;64;1;62;0
WireConnection;64;2;65;0
WireConnection;67;0;94;0
WireConnection;67;1;64;0
WireConnection;51;0;4;0
WireConnection;48;0;67;0
WireConnection;8;0;9;0
WireConnection;8;1;51;0
WireConnection;13;0;14;0
WireConnection;13;1;8;0
WireConnection;10;0;8;0
WireConnection;10;1;49;0
WireConnection;12;0;5;0
WireConnection;12;1;11;0
WireConnection;12;2;10;0
WireConnection;16;0;13;0
WireConnection;16;1;49;0
WireConnection;17;0;12;0
WireConnection;17;1;18;0
WireConnection;17;2;16;0
WireConnection;3;0;51;0
WireConnection;3;1;49;0
WireConnection;7;0;17;0
WireConnection;7;3;3;0
WireConnection;0;0;7;0
ASEEND*/
//CHKSM=B1D20EE595B9B360B7E8CE3E2FEE39C77C9C3D48