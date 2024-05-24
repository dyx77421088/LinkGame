// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "XuanFu/Toon/CharacterFlowMap"
{
	Properties
	{
		_FlowMap("FlowMap", 2D) = "white" {}
		[HDR]_Color0("Color 0", Color) = (0,0,0,0)
		_FlowSpeed("FlowSpeed", Float) = 1
		_Float1("Float 1", Float) = 1
		_MainTex("MainTex", 2D) = "white" {}
		_Albedo("Albedo", 2D) = "white" {}
		_NormalMap("NormalMap", 2D) = "bump" {}
		_NormaScale("NormaScale", Float) = 1
		_Smothness("Smothness", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform float _NormaScale;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform sampler2D _MainTex;
		uniform float _Float1;
		uniform sampler2D _FlowMap;
		uniform float _FlowSpeed;
		uniform float4 _Color0;
		uniform float _Smothness;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			o.Normal = UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap ), _NormaScale );
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			o.Albedo = tex2D( _Albedo, uv_Albedo ).rgb;
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float2 temp_output_58_0 = (( ( ase_vertex3Pos + 1.0 ) * 0.5 )).xz;
			float2 MainUV55 = ( temp_output_58_0 * _Float1 );
			float2 blendOpSrc21 = MainUV55;
			float2 blendOpDest21 = (tex2D( _FlowMap, MainUV55 )).rg;
			float2 temp_output_21_0 = ( saturate( (( blendOpDest21 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest21 ) * ( 1.0 - blendOpSrc21 ) ) : ( 2.0 * blendOpDest21 * blendOpSrc21 ) ) ));
			float temp_output_11_0 = ( _Time.y * _FlowSpeed );
			float temp_output_13_0 = frac( temp_output_11_0 );
			float Time25 = -temp_output_13_0;
			float2 lerpResult22 = lerp( MainUV55 , temp_output_21_0 , Time25);
			float2 FlowA30 = lerpResult22;
			float TimeB38 = -frac( (temp_output_11_0*1.0 + 0.5) );
			float2 lerpResult39 = lerp( MainUV55 , temp_output_21_0 , TimeB38);
			float2 FlowB41 = lerpResult39;
			float FlowBled50 = abs( ( 1.0 - ( temp_output_13_0 * 2.0 ) ) );
			float4 lerpResult44 = lerp( tex2D( _MainTex, FlowA30 ) , tex2D( _MainTex, FlowB41 ) , FlowBled50);
			float4 Color105 = ( lerpResult44 * _Color0 );
			o.Emission = Color105.rgb;
			o.Smoothness = _Smothness;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17101
2719;533;1906;930;5849.794;2256.162;1.3;True;False
Node;AmplifyShaderEditor.CommentaryNode;52;-5299.777,-1822.629;Inherit;False;1535.501;752.3771;Comment;12;55;76;75;58;62;122;123;129;130;132;131;133;;1,1,1,1;0;0
Node;AmplifyShaderEditor.PosVertexDataNode;62;-5285.537,-1795.818;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;132;-5265.229,-1655.998;Inherit;False;Constant;_Float0;Float 0;9;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;131;-5083.229,-1753.998;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;134;-5282.229,-1540.998;Inherit;False;Constant;_Float2;Float 2;9;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;23;-3081.803,-214.9494;Inherit;False;1655.543;924.9701;Time;14;25;13;11;12;10;32;33;38;47;48;49;50;79;80;Time;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;133;-5016.229,-1685.998;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-3031.803,-98.14223;Inherit;False;Property;_FlowSpeed;FlowSpeed;2;0;Create;True;0;0;False;0;1;0.04;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;58;-4824.376,-1776.832;Inherit;True;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;75;-4361.357,-1395.637;Inherit;False;Property;_Float1;Float 1;3;0;Create;True;0;0;False;0;1;0.15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;10;-3026.235,-164.9494;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;-4276.545,-1704.635;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-2849.475,-152.4231;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;32;-2683.75,127.524;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;55;-4053.285,-1717.349;Inherit;False;MainUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;29;-3088.467,-1256.134;Inherit;False;2023.718;882.6276;Comment;10;30;22;26;21;5;1;39;40;56;41;Flow;1,1,1,1;0;0
Node;AmplifyShaderEditor.FractNode;33;-2435.156,130.9133;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;13;-2586.118,-153.653;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;56;-3029.338,-1195.288;Inherit;False;55;MainUV;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NegateNode;80;-2355.018,333.1593;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;79;-2396.467,-163.1176;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-2963.46,-1030.654;Inherit;True;Property;_FlowMap;FlowMap;0;0;Create;True;0;0;False;0;e3256e3c7b582f74fb7be748f3bcf9a3;e3256e3c7b582f74fb7be748f3bcf9a3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;-2228.061,-163.1478;Inherit;False;Time;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;5;-2657.671,-994.8301;Inherit;True;FLOAT2;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;38;-2093.23,142.852;Inherit;False;TimeB;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-2241.604,-17.69315;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;40;-2487.806,-667.2812;Inherit;False;38;TimeB;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;26;-2457.774,-903.8851;Inherit;False;25;Time;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;21;-2487.284,-1032.179;Inherit;False;Overlay;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;22;-2213.078,-1032.275;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;39;-2211.24,-735.5921;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;48;-2088.635,-4.945854;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;41;-1921.89,-747.7715;Inherit;True;FlowB;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;30;-1909.146,-1033.882;Inherit;True;FlowA;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.AbsOpNode;49;-1931.42,-9.194965;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;31;-963.489,-546.0087;Inherit;False;30;FlowA;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;43;-983.8255,-263.557;Inherit;False;41;FlowB;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;50;-1778.452,-3.529489;Inherit;False;FlowBled;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;110;-717.7056,-538.3929;Inherit;True;Property;_MainTex;MainTex;4;0;Create;True;0;0;False;0;None;b7ada79f9f629b94c80ebd8af89d0156;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;111;-748.8174,-299.637;Inherit;True;Property;_TextureSample0;Texture Sample 0;4;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Instance;110;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;51;-574.3457,-111.7592;Inherit;False;50;FlowBled;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;3;-302.766,-109.5843;Inherit;False;Property;_Color0;Color 0;1;1;[HDR];Create;True;0;0;False;0;0,0,0,0;1,0.5172414,0,0.355;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;44;-279.4948,-267.6664;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;2;-34.70929,-241.1924;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;115;369.9352,-173.9919;Inherit;False;Property;_NormaScale;NormaScale;7;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;105;130.2226,-238.9079;Inherit;False;Color;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;106;578.7883,-38.76168;Inherit;False;105;Color;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;113;545.0947,-425.1153;Inherit;True;Property;_Albedo;Albedo;5;0;Create;True;0;0;False;0;None;b48a5e2db41f04c488d1e2cd77ecc694;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;122;-5181.088,-1366.64;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;130;-4439.214,-1718.64;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;2,2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;114;557.5883,-241.9442;Inherit;True;Property;_NormalMap;NormalMap;6;0;Create;True;0;0;False;0;None;4f050173c720fc24c9d51e185d418405;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;123;-4822.542,-1558.202;Inherit;True;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;121;931.6376,3.267757;Inherit;False;Property;_Smothness;Smothness;8;0;Create;True;0;0;False;0;0;1.11;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;129;-4573.115,-1626.24;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;112;1296.361,-383.9683;Float;False;True;2;ASEMaterialInspector;0;0;Standard;XuanFu/Toon/CharacterFlowMap;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;131;0;62;0
WireConnection;131;1;132;0
WireConnection;133;0;131;0
WireConnection;133;1;134;0
WireConnection;58;0;133;0
WireConnection;76;0;58;0
WireConnection;76;1;75;0
WireConnection;11;0;10;0
WireConnection;11;1;12;0
WireConnection;32;0;11;0
WireConnection;55;0;76;0
WireConnection;33;0;32;0
WireConnection;13;0;11;0
WireConnection;80;0;33;0
WireConnection;79;0;13;0
WireConnection;1;1;56;0
WireConnection;25;0;79;0
WireConnection;5;0;1;0
WireConnection;38;0;80;0
WireConnection;47;0;13;0
WireConnection;21;0;56;0
WireConnection;21;1;5;0
WireConnection;22;0;56;0
WireConnection;22;1;21;0
WireConnection;22;2;26;0
WireConnection;39;0;56;0
WireConnection;39;1;21;0
WireConnection;39;2;40;0
WireConnection;48;0;47;0
WireConnection;41;0;39;0
WireConnection;30;0;22;0
WireConnection;49;0;48;0
WireConnection;50;0;49;0
WireConnection;110;1;31;0
WireConnection;111;1;43;0
WireConnection;44;0;110;0
WireConnection;44;1;111;0
WireConnection;44;2;51;0
WireConnection;2;0;44;0
WireConnection;2;1;3;0
WireConnection;105;0;2;0
WireConnection;130;0;129;0
WireConnection;114;5;115;0
WireConnection;129;0;58;0
WireConnection;129;1;123;0
WireConnection;112;0;113;0
WireConnection;112;1;114;0
WireConnection;112;2;106;0
WireConnection;112;4;121;0
ASEEND*/
//CHKSM=BA64321169D8DADBB4D0EC084F6CACCC91F019C0