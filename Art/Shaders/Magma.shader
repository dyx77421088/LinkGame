// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "XuanFu/VFX/Magma"
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
		_noisePow("noisePow", Float) = 0
		_VertexAni("VertexAni", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
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

		uniform sampler2D _VertexAni;
		uniform float4 _VertexAni_ST;
		uniform float _noisePow;
		uniform float4 MagmaObject[30];
		uniform float _Height;
		uniform float _MaskSoft;
		uniform float _Width;
		uniform sampler2D _MainTex;
		uniform sampler2D _DisturTex;
		uniform float4 _DisturTex_ST;
		uniform float _DisturPow;
		uniform float4 _MainTex_ST;
		uniform float2 _Vector0;
		uniform float4 _EdgeColor;
		uniform float4 _Color0;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float mulTime182 = _Time.y * -1.0;
			float2 uv0_VertexAni = v.texcoord.xy * _VertexAni_ST.xy + _VertexAni_ST.zw;
			float2 panner181 = ( mulTime182 * float2( 0,0.7 ) + uv0_VertexAni);
			float3 appendResult196 = (float3(0.0 , ( tex2Dlod( _VertexAni, float4( panner181, 0, 0.0) ).r * _noisePow ) , 0.0));
			v.vertex.xyz += appendResult196;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float3 ase_worldPos = i.worldPos;
			float4 break31 = MagmaObject[clamp(0,0,(30 - 1))];
			float3 appendResult33 = (float3(break31.x , 1.0 , break31.z));
			float3 appendResult36 = (float3(ase_worldPos.x , 1.0 , ase_worldPos.z));
			float4 break217 = MagmaObject[1];
			float3 appendResult213 = (float3(break217.x , 1.0 , break217.z));
			float3 appendResult216 = (float3(ase_worldPos.x , 1.0 , ase_worldPos.z));
			float4 break219 = MagmaObject[2];
			float3 appendResult220 = (float3(break219.x , 1.0 , break219.z));
			float3 appendResult223 = (float3(ase_worldPos.x , 1.0 , ase_worldPos.z));
			float temp_output_148_0 = ( max( saturate( ( ( ( ase_worldPos.y - break31.y ) - _Height ) / _MaskSoft ) ) , saturate( ( ( distance( appendResult33 , appendResult36 ) - _Width ) / _MaskSoft ) ) ) * max( saturate( ( ( ( ase_worldPos.y - break217.y ) - _Height ) / _MaskSoft ) ) , saturate( ( ( distance( appendResult213 , appendResult216 ) - _Width ) / _MaskSoft ) ) ) * max( saturate( ( ( ( ase_worldPos.y - break219.y ) - _Height ) / _MaskSoft ) ) , saturate( ( ( distance( appendResult220 , appendResult223 ) - _Width ) / _MaskSoft ) ) ) );
			float mulTime199 = _Time.y * -1.0;
			float2 uv0_DisturTex = i.uv_texcoord * _DisturTex_ST.xy + _DisturTex_ST.zw;
			float2 panner201 = ( mulTime199 * float2( 0,0.3 ) + uv0_DisturTex);
			float2 uv0_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode140 = tex2D( _MainTex, ( ( pow( tex2D( _DisturTex, panner201 ).r , _DisturPow ) + uv0_MainTex ) + ( _Vector0 * _Time.y ) ) );
			float4 lerpResult125 = lerp( _EdgeColor , ( _Color0 * tex2DNode140 ) , temp_output_148_0);
			c.rgb = lerpResult125.rgb;
			c.a = ( temp_output_148_0 * tex2DNode140.a );
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting alpha:fade keepalpha fullforwardshadows vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT( UnityGI, gi );
				o.Alpha = LightingStandardCustomLighting( o, worldViewDir, gi ).a;
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17101
2093;41;1661;984;5925.926;1595.337;1.6;True;False
Node;AmplifyShaderEditor.CommentaryNode;244;-5434.221,-1182.235;Inherit;False;3121.339;1289.883;Comment;44;212;211;209;217;219;35;31;223;216;213;220;33;36;221;214;222;215;111;40;106;34;230;234;233;229;105;110;117;235;231;232;236;120;116;241;239;240;242;107;43;238;237;124;148;mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.GlobalArrayNode;209;-5094.211,-1121.282;Inherit;False;MagmaObject;0;30;2;True;False;0;1;True;Object;209;4;0;INT;0;False;2;INT;0;False;1;INT;0;False;3;INT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GlobalArrayNode;211;-5296.095,-663.7963;Inherit;False;MagmaObjectPos;1;3;2;False;False;0;1;False;Instance;209;4;0;INT;0;False;2;INT;0;False;1;INT;0;False;3;INT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GlobalArrayNode;212;-5384.221,-441.6972;Inherit;False;MagmaObjectPos;2;3;2;False;False;0;1;False;Instance;209;4;0;INT;0;False;2;INT;0;False;1;INT;0;False;3;INT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.BreakToComponentsNode;31;-4816.576,-976.5653;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleTimeNode;199;-4909.18,288.6701;Inherit;False;1;0;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;200;-4990.031,137.7176;Inherit;False;0;128;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;35;-4872.083,-796.7444;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.BreakToComponentsNode;217;-5041.556,-557.5931;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.BreakToComponentsNode;219;-5034.556,-266.7105;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;213;-4545.43,-513.4924;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;36;-4495.424,-738.1168;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;216;-4497.818,-355.7992;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;220;-4598.273,-184.532;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;223;-4558.678,-51.26866;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PannerNode;201;-4648.227,190.7182;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0.3;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;33;-4532.716,-968.6545;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DistanceOpNode;215;-4314.83,-371.9089;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;106;-3953.491,-165.0959;Inherit;False;Property;_Width;Width;0;0;Create;True;0;0;False;0;0;3.13;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;128;-4410.401,172.4233;Inherit;True;Property;_DisturTex;DisturTex;4;0;Create;True;0;0;False;0;None;e8f905cf956fb494b894011e8ca833d1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DistanceOpNode;34;-4337.284,-717.6441;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;214;-4248.318,-558.8848;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;221;-4334.477,-196.1982;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;131;-4318.226,378.462;Inherit;False;Property;_DisturPow;DisturPow;5;0;Create;True;0;0;False;0;0;0.04;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;222;-4364.741,-25.35197;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;111;-3883.699,-759.9424;Inherit;False;Property;_Height;Height;1;0;Create;True;0;0;False;0;0;3.11;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;40;-4233.389,-812.3807;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;105;-3584.607,-289.7466;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;144;-4498.964,693.7018;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;145;-4269.231,573.1379;Inherit;False;Property;_Vector0;Vector 0;8;0;Create;True;0;0;False;0;0,0;0,-0.1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleSubtractOpNode;233;-3588.026,-168.0685;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;229;-3518.709,-721.5508;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;117;-3511.255,-493.1155;Inherit;False;Property;_MaskSoft;MaskSoft;2;0;Create;True;0;0;False;0;0;0.77;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;230;-3516.849,-627.5083;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;57;-4203.875,438.308;Inherit;False;0;140;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;110;-3542.48,-842.428;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;234;-3600.178,-55.15977;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;208;-4033.379,239.7233;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;120;-3234.898,-315.8404;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;235;-3237.335,-204.7098;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;182;-2827.805,932.7001;Inherit;False;1;0;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;236;-3242.506,-82.33855;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;231;-3241.214,-657.8012;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;180;-2908.656,781.7464;Inherit;False;0;202;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;129;-3875.062,326.767;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;232;-3251.898,-563.8503;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;146;-4022.407,624.8027;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;116;-3239.6,-745.2435;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;242;-2964.576,-124.374;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;241;-2947.342,-217.4452;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;43;-2938.896,-681.0276;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;181;-2561.677,837.8505;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0.7;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;143;-3643.185,314.1512;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;107;-2934.903,-505.6996;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;240;-2952.512,-315.6869;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;239;-2943.894,-393.2459;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;202;-2332.21,726.8513;Inherit;True;Property;_VertexAni;VertexAni;10;0;Create;True;0;0;False;0;None;9af08c23a764405409bb46d7418da05b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMaxOpNode;124;-2770.196,-593.5153;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;140;-3458.548,287.0831;Inherit;True;Property;_MainTex;MainTex;7;0;Create;True;0;0;False;0;None;0e08587213a7ed74f8f2e2df25430543;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMaxOpNode;238;-2757.017,-276.6833;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;138;-2740.923,105.2037;Inherit;False;Property;_Color0;Color 0;6;1;[HDR];Create;True;0;0;False;0;0,0,0,0;2.5,2.5,2.5,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMaxOpNode;237;-2751.848,-412.8425;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;190;-2210.691,1002.473;Inherit;False;Property;_noisePow;noisePow;9;0;Create;True;0;0;False;0;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;139;-2238.864,109.3811;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;126;-1777.078,-269.4089;Inherit;False;Property;_EdgeColor;EdgeColor;3;1;[HDR];Create;True;0;0;False;0;1,1,1,1;6.053,4.633676,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;148;-2558.459,-483.3276;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;204;-1854.981,767.9134;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;243;-1410.557,383.5988;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;196;-1298.766,777.4609;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;125;-1523.826,-98.78116;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;83;-800.5515,106.2111;Float;False;True;2;ASEMaterialInspector;0;0;CustomLighting;XuanFu/VFX/Magma;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;31;0;209;0
WireConnection;217;0;211;0
WireConnection;219;0;212;0
WireConnection;213;0;217;0
WireConnection;213;2;217;2
WireConnection;36;0;35;1
WireConnection;36;2;35;3
WireConnection;216;0;35;1
WireConnection;216;2;35;3
WireConnection;220;0;219;0
WireConnection;220;2;219;2
WireConnection;223;0;35;1
WireConnection;223;2;35;3
WireConnection;201;0;200;0
WireConnection;201;1;199;0
WireConnection;33;0;31;0
WireConnection;33;2;31;2
WireConnection;215;0;213;0
WireConnection;215;1;216;0
WireConnection;128;1;201;0
WireConnection;34;0;33;0
WireConnection;34;1;36;0
WireConnection;214;0;35;2
WireConnection;214;1;217;1
WireConnection;221;0;35;2
WireConnection;221;1;219;1
WireConnection;222;0;220;0
WireConnection;222;1;223;0
WireConnection;40;0;35;2
WireConnection;40;1;31;1
WireConnection;105;0;34;0
WireConnection;105;1;106;0
WireConnection;233;0;215;0
WireConnection;233;1;106;0
WireConnection;229;0;214;0
WireConnection;229;1;111;0
WireConnection;230;0;221;0
WireConnection;230;1;111;0
WireConnection;110;0;40;0
WireConnection;110;1;111;0
WireConnection;234;0;222;0
WireConnection;234;1;106;0
WireConnection;208;0;128;1
WireConnection;208;1;131;0
WireConnection;120;0;105;0
WireConnection;120;1;117;0
WireConnection;235;0;233;0
WireConnection;235;1;117;0
WireConnection;236;0;234;0
WireConnection;236;1;117;0
WireConnection;231;0;229;0
WireConnection;231;1;117;0
WireConnection;129;0;208;0
WireConnection;129;1;57;0
WireConnection;232;0;230;0
WireConnection;232;1;117;0
WireConnection;146;0;145;0
WireConnection;146;1;144;0
WireConnection;116;0;110;0
WireConnection;116;1;117;0
WireConnection;242;0;236;0
WireConnection;241;0;235;0
WireConnection;43;0;116;0
WireConnection;181;0;180;0
WireConnection;181;1;182;0
WireConnection;143;0;129;0
WireConnection;143;1;146;0
WireConnection;107;0;120;0
WireConnection;240;0;232;0
WireConnection;239;0;231;0
WireConnection;202;1;181;0
WireConnection;124;0;43;0
WireConnection;124;1;107;0
WireConnection;140;1;143;0
WireConnection;238;0;240;0
WireConnection;238;1;242;0
WireConnection;237;0;239;0
WireConnection;237;1;241;0
WireConnection;139;0;138;0
WireConnection;139;1;140;0
WireConnection;148;0;124;0
WireConnection;148;1;237;0
WireConnection;148;2;238;0
WireConnection;204;0;202;1
WireConnection;204;1;190;0
WireConnection;243;0;148;0
WireConnection;243;1;140;4
WireConnection;196;1;204;0
WireConnection;125;0;126;0
WireConnection;125;1;139;0
WireConnection;125;2;148;0
WireConnection;83;9;243;0
WireConnection;83;13;125;0
WireConnection;83;11;196;0
ASEEND*/
//CHKSM=67F2AE31A8722872AC0D4D93E9364ADDB6727B0E