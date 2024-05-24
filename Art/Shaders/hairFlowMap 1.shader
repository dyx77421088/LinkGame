// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "XuanFu/Toon/HairFlowMap01"
{
	Properties
	{
		_EdgeLength ( "Edge length", Range( 2, 50 ) ) = 19.1
		[HDR]_FireColor("FireColor", Color) = (0,0,0,0)
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		[HDR]_SmokeColor("SmokeColor", Color) = (0,0,0,0)
		_Vor1UV("Vor1UV", Vector) = (2,1,0,-1)
		_VorScalse01("VorScalse01", Float) = 5
		_Vor2UV("Vor2UV", Vector) = (2,1,0,-1)
		_VorScalse02("VorScalse02", Float) = 3
		_OffsetIntensity("OffsetIntensity", Float) = 0
		_MainTex("MainTex", 2D) = "white" {}
		_fireShixinRange("fireShixinRange", Float) = 0
		_fireShixinSoft("fireShixinSoft", Float) = 0
		_SmokeRange("SmokeRange", Float) = 0
		_SmokeSoft("SmokeSoft", Float) = 0
		_FireDissRange("FireDissRange", Float) = 0
		_FireDissSOft("FireDissSOft", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Tessellation.cginc"
		#pragma target 4.6
		#pragma surface surf StandardCustomLighting keepalpha noshadow noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog nometa vertex:vertexDataFunc tessellate:tessFunction 
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float _VorScalse01;
		uniform float4 _Vor1UV;
		uniform float _VorScalse02;
		uniform float4 _Vor2UV;
		uniform float _OffsetIntensity;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float4 _SmokeColor;
		uniform float4 _FireColor;
		uniform float _SmokeRange;
		uniform float _SmokeSoft;
		uniform float _FireDissRange;
		uniform float _FireDissSOft;
		uniform float _fireShixinRange;
		uniform float _fireShixinSoft;
		uniform float _Cutoff = 0.5;
		uniform float _EdgeLength;


		float2 voronoihash270( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi270( float2 v, inout float2 id )
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
			 		float2 o = voronoihash270( n + g );
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


		float2 voronoihash269( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi269( float2 v, inout float2 id )
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
			 		float2 o = voronoihash269( n + g );
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


		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityEdgeLengthBasedTess (v0.vertex, v1.vertex, v2.vertex, _EdgeLength);
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float3 ase_vertexNormal = v.normal.xyz;
			float3 normalizeResult115 = normalize( ase_vertexNormal );
			float2 appendResult258 = (float2(_Vor1UV.z , _Vor1UV.w));
			float2 appendResult253 = (float2(_Vor1UV.x , _Vor1UV.y));
			float2 uv_TexCoord256 = v.texcoord.xy * appendResult253;
			float2 panner266 = ( _Time.y * appendResult258 + uv_TexCoord256);
			float2 coords270 = panner266 * _VorScalse01;
			float2 id270 = 0;
			float voroi270 = voronoi270( coords270, id270 );
			float2 appendResult257 = (float2(_Vor2UV.z , _Vor2UV.w));
			float2 appendResult254 = (float2(_Vor2UV.x , _Vor2UV.y));
			float2 uv_TexCoord260 = v.texcoord.xy * appendResult254;
			float2 panner267 = ( _Time.y * appendResult257 + uv_TexCoord260);
			float2 coords269 = panner267 * _VorScalse02;
			float2 id269 = 0;
			float voroi269 = voronoi269( coords269, id269 );
			float blendOpSrc271 = voroi270;
			float blendOpDest271 = voroi269;
			float Noies146 = ( saturate( (( blendOpSrc271 > 0.5 ) ? max( blendOpDest271, 2.0 * ( blendOpSrc271 - 0.5 ) ) : min( blendOpDest271, 2.0 * blendOpSrc271 ) ) ));
			float3 VertexOffset172 = ( normalizeResult115 * ( Noies146 * _OffsetIntensity ) );
			v.vertex.xyz += VertexOffset172;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float2 appendResult258 = (float2(_Vor1UV.z , _Vor1UV.w));
			float2 appendResult253 = (float2(_Vor1UV.x , _Vor1UV.y));
			float2 uv_TexCoord256 = i.uv_texcoord * appendResult253;
			float2 panner266 = ( _Time.y * appendResult258 + uv_TexCoord256);
			float2 coords270 = panner266 * _VorScalse01;
			float2 id270 = 0;
			float voroi270 = voronoi270( coords270, id270 );
			float2 appendResult257 = (float2(_Vor2UV.z , _Vor2UV.w));
			float2 appendResult254 = (float2(_Vor2UV.x , _Vor2UV.y));
			float2 uv_TexCoord260 = i.uv_texcoord * appendResult254;
			float2 panner267 = ( _Time.y * appendResult257 + uv_TexCoord260);
			float2 coords269 = panner267 * _VorScalse02;
			float2 id269 = 0;
			float voroi269 = voronoi269( coords269, id269 );
			float blendOpSrc271 = voroi270;
			float blendOpDest271 = voroi269;
			float Noies146 = ( saturate( (( blendOpSrc271 > 0.5 ) ? max( blendOpDest271, 2.0 * ( blendOpSrc271 - 0.5 ) ) : min( blendOpDest271, 2.0 * blendOpSrc271 ) ) ));
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float Gradient162 = ( 1.0 - ase_vertex3Pos.x );
			float smoothstepResult237 = smoothstep( _FireDissRange , ( _FireDissRange + _FireDissSOft ) , Gradient162);
			float2 uv0_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode4 = tex2D( _MainTex, ( uv0_MainTex + ( float2( 0,-1 ) * _Time.y ) ) );
			float smoothstepResult220 = smoothstep( _fireShixinRange , ( _fireShixinRange + _fireShixinSoft ) , Gradient162);
			float temp_output_202_0 = saturate( ( ( Noies146 * smoothstepResult237 * tex2DNode4.r ) + smoothstepResult220 ) );
			c.rgb = 0;
			c.a = temp_output_202_0;
			clip( temp_output_202_0 - _Cutoff );
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			float2 uv0_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode4 = tex2D( _MainTex, ( uv0_MainTex + ( float2( 0,-1 ) * _Time.y ) ) );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float Gradient162 = ( 1.0 - ase_vertex3Pos.x );
			float smoothstepResult216 = smoothstep( _SmokeRange , ( _SmokeRange + _SmokeSoft ) , Gradient162);
			float4 lerpResult195 = lerp( _SmokeColor , _FireColor , ( smoothstepResult216 / 2.0 ));
			float4 Color166 = ( tex2DNode4 * lerpResult195 );
			o.Emission = Color166.rgb;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17101
-49;114;2546;1356;7777.824;1306.944;4.016349;True;False
Node;AmplifyShaderEditor.CommentaryNode;144;-3230.541,-304.532;Inherit;False;2001.25;1294.775;Comment;22;146;268;255;261;254;259;257;262;260;264;265;266;271;267;263;269;270;251;252;253;256;258;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector4Node;252;-3148.448,-112.4349;Inherit;False;Property;_Vor1UV;Vor1UV;8;0;Create;True;0;0;False;0;2,1,0,-1;2,1,0,-0.5;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;251;-3178.644,328.3942;Inherit;False;Property;_Vor2UV;Vor2UV;10;0;Create;True;0;0;False;0;2,1,0,-1;2,1,0,-0.35;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;163;-2908.694,2009.916;Inherit;False;765.5179;506.0435;Comment;3;120;162;272;Gradient;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;253;-2941.749,-125.4349;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;254;-2971.942,315.3942;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PosVertexDataNode;272;-2894.045,2049.921;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;257;-2667.743,380.3942;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;256;-2806.258,-226.5686;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;258;-2616.639,-127.9511;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;259;-2692.895,556.378;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;261;-2600.491,83.32181;Inherit;False;Constant;_Float5;Float 5;9;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;255;-2618.71,668.2383;Inherit;False;Constant;_Float4;Float 4;9;0;Create;True;0;0;False;0;0.7;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;262;-2772.164,-28.16548;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;260;-2821.895,243.3779;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;120;-2620.818,2071.806;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;264;-2359.491,62.32169;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;265;-2515.637,243.2388;Inherit;False;Property;_VorScalse01;VorScalse01;9;0;Create;True;0;0;False;0;5;7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;263;-2441.022,595.0326;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;268;-2619.816,746.5804;Inherit;False;Property;_VorScalse02;VorScalse02;11;0;Create;True;0;0;False;0;3;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;165;-1057.943,-874.5318;Inherit;False;1766.082;1595.098;Comment;28;216;217;195;3;197;166;201;4;202;137;179;147;212;180;211;215;214;213;218;220;221;224;235;236;237;238;239;240;Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.PannerNode;267;-2438.894,391.3781;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;266;-2365.21,-146.2391;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;218;-1070.843,-246.931;Inherit;False;Property;_SmokeSoft;SmokeSoft;17;0;Create;True;0;0;False;0;0;-5.56;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;269;-2208.167,526.3375;Inherit;True;0;0;1;0;1;False;1;False;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;2;FLOAT;0;FLOAT;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;162;-2331.58,2136.257;Inherit;False;Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;199;-1073.831,-341.9043;Inherit;False;Property;_SmokeRange;SmokeRange;16;0;Create;True;0;0;False;0;0;3.89;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;270;-2131.964,-8.279871;Inherit;True;0;0;1;0;1;False;1;False;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;2;FLOAT;0;FLOAT;1
Node;AmplifyShaderEditor.BlendOpsNode;271;-1743.927,275.9681;Inherit;True;PinLight;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;164;-1069.339,-425.3454;Inherit;False;162;Gradient;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;217;-900.446,-305.3338;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;214;-1042.259,-567.2251;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;213;-1037.657,-690.3252;Inherit;False;Constant;_Vector2;Vector 2;13;0;Create;True;0;0;False;0;0,-1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;215;-859.3347,-656.9616;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;160;-2923.72,1054.081;Inherit;False;1510.108;926.112;Comment;7;172;114;115;177;178;113;171;VertexOffset;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;239;-1065.855,3.683433;Inherit;False;Property;_FireDissSOft;FireDissSOft;19;0;Create;True;0;0;False;0;0;0.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;146;-1430.422,290.4619;Inherit;False;Noies;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;216;-774.9005,-381.069;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;211;-1027.407,-805.3311;Inherit;False;0;4;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;238;-1066.18,-138.0134;Inherit;False;Property;_FireDissRange;FireDissRange;18;0;Create;True;0;0;False;0;0;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;224;-385.4288,-444.618;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;180;-1054.845,118.9134;Inherit;False;Property;_fireShixinRange;fireShixinRange;14;0;Create;True;0;0;False;0;0;15.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;197;-653.5201,-682.4443;Inherit;False;Property;_SmokeColor;SmokeColor;7;1;[HDR];Create;True;0;0;False;0;0,0,0,0;2.352941,1.119675,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;240;-863.6148,13.5149;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;3;-655.3391,-573.0975;Inherit;False;Property;_FireColor;FireColor;5;1;[HDR];Create;True;0;0;False;0;0,0,0,0;7.713001,4.152973,1.417831,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;178;-2779.742,1434.141;Inherit;False;Property;_OffsetIntensity;OffsetIntensity;12;0;Create;True;0;0;False;0;0;0.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;221;-1043.735,214.5858;Inherit;False;Property;_fireShixinSoft;fireShixinSoft;15;0;Create;True;0;0;False;0;0;-27.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;171;-2745.268,1347.764;Inherit;False;146;Noies;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;113;-2907.72,1091.081;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;212;-755.8967,-781.1714;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;195;-331.2383,-577.9491;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;147;-754.9063,-236.3122;Inherit;True;146;Noies;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;237;-732.8585,-56.64354;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;115;-2378.899,1147.56;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;4;-594.6256,-804.8353;Inherit;True;Property;_MainTex;MainTex;13;0;Create;True;0;0;False;0;None;ead5f24036747474893542de2427434e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;177;-2408.686,1416.231;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;179;-863.4568,203.2209;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;220;-726.0231,157.5654;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;235;-451.0332,-95.41151;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;201;-132.465,-624.1536;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;-2143.635,1429.134;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;236;-203.3899,9.203117;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;172;-1908.448,1365.15;Inherit;False;VertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;166;203.0481,-496.2845;Inherit;False;Color;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;167;571.3054,-150.3345;Inherit;False;166;Color;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;137;-231.5023,-307.0462;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;202;16.63214,71.209;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;170;531.2054,159.1212;Inherit;False;172;VertexOffset;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;207;851.36,-179.9842;Float;False;True;6;ASEMaterialInspector;0;0;CustomLighting;XuanFu/Toon/HairFlowMap01;False;False;False;False;True;True;True;True;True;True;True;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Transparent;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;2;19.1;10;25;False;0.5;False;1;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;6;-1;-1;0;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;253;0;252;1
WireConnection;253;1;252;2
WireConnection;254;0;251;1
WireConnection;254;1;251;2
WireConnection;257;0;251;3
WireConnection;257;1;251;4
WireConnection;256;0;253;0
WireConnection;258;0;252;3
WireConnection;258;1;252;4
WireConnection;260;0;254;0
WireConnection;120;0;272;1
WireConnection;264;0;262;0
WireConnection;264;1;261;0
WireConnection;263;0;259;0
WireConnection;263;1;255;0
WireConnection;267;0;260;0
WireConnection;267;2;257;0
WireConnection;267;1;259;0
WireConnection;266;0;256;0
WireConnection;266;2;258;0
WireConnection;266;1;262;0
WireConnection;269;0;267;0
WireConnection;269;1;263;0
WireConnection;269;2;268;0
WireConnection;162;0;120;0
WireConnection;270;0;266;0
WireConnection;270;1;264;0
WireConnection;270;2;265;0
WireConnection;271;0;270;0
WireConnection;271;1;269;0
WireConnection;217;0;199;0
WireConnection;217;1;218;0
WireConnection;215;0;213;0
WireConnection;215;1;214;0
WireConnection;146;0;271;0
WireConnection;216;0;164;0
WireConnection;216;1;199;0
WireConnection;216;2;217;0
WireConnection;224;0;216;0
WireConnection;240;0;238;0
WireConnection;240;1;239;0
WireConnection;212;0;211;0
WireConnection;212;1;215;0
WireConnection;195;0;197;0
WireConnection;195;1;3;0
WireConnection;195;2;224;0
WireConnection;237;0;164;0
WireConnection;237;1;238;0
WireConnection;237;2;240;0
WireConnection;115;0;113;0
WireConnection;4;1;212;0
WireConnection;177;0;171;0
WireConnection;177;1;178;0
WireConnection;179;0;180;0
WireConnection;179;1;221;0
WireConnection;220;0;164;0
WireConnection;220;1;180;0
WireConnection;220;2;179;0
WireConnection;235;0;147;0
WireConnection;235;1;237;0
WireConnection;235;2;4;1
WireConnection;201;0;4;0
WireConnection;201;1;195;0
WireConnection;114;0;115;0
WireConnection;114;1;177;0
WireConnection;236;0;235;0
WireConnection;236;1;220;0
WireConnection;172;0;114;0
WireConnection;166;0;201;0
WireConnection;137;0;147;0
WireConnection;137;1;220;0
WireConnection;202;0;236;0
WireConnection;207;2;167;0
WireConnection;207;9;202;0
WireConnection;207;10;202;0
WireConnection;207;11;170;0
ASEEND*/
//CHKSM=38F3AB439F877BC61980FF3A8403B57FA3147EFE