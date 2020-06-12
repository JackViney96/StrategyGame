// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Ground Detail"
{
	Properties
	{
		_Satellite("Satellite", 2D) = "white" {}
		_DetailTransitionDistance("Detail Transition Distance", Float) = 5
		_DetailTransitionFalloff("Detail Transition Falloff", Float) = -0.5
		_ColorMap1("Color Map", 2D) = "black" {}
		_BlendAlpha("Blend Alpha", Range( 0 , 1)) = 0.5
		_DetailR("Detail R", 2D) = "white" {}
		_DetailG("Detail G", 2D) = "white" {}
		_DetailB("Detail B", 2D) = "white" {}
		_DetailA("Detail A", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 4.6
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform sampler2D _Satellite;
		uniform float4 _Satellite_ST;
		uniform sampler2D _DetailR;
		uniform float4 _DetailR_ST;
		uniform sampler2D _ColorMap1;
		uniform float4 _ColorMap1_ST;
		uniform sampler2D _DetailG;
		uniform float4 _DetailG_ST;
		uniform sampler2D _DetailB;
		uniform float4 _DetailB_ST;
		uniform sampler2D _DetailA;
		uniform float4 _DetailA_ST;
		uniform float _BlendAlpha;
		uniform float _DetailTransitionDistance;
		uniform float _DetailTransitionFalloff;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Satellite = i.uv_texcoord * _Satellite_ST.xy + _Satellite_ST.zw;
			float2 uv_DetailR = i.uv_texcoord * _DetailR_ST.xy + _DetailR_ST.zw;
			float2 uv_ColorMap1 = i.uv_texcoord * _ColorMap1_ST.xy + _ColorMap1_ST.zw;
			float4 temp_cast_0 = (tex2D( _ColorMap1, uv_ColorMap1 ).r).xxxx;
			float4 blendOpSrc36_g7 = tex2D( _DetailR, uv_DetailR );
			float4 blendOpDest36_g7 = temp_cast_0;
			float2 uv_DetailG = i.uv_texcoord * _DetailG_ST.xy + _DetailG_ST.zw;
			float4 temp_cast_1 = (tex2D( _ColorMap1, uv_ColorMap1 ).g).xxxx;
			float4 blendOpSrc40_g7 = tex2D( _DetailG, uv_DetailG );
			float4 blendOpDest40_g7 = temp_cast_1;
			float2 uv_DetailB = i.uv_texcoord * _DetailB_ST.xy + _DetailB_ST.zw;
			float4 temp_cast_2 = (tex2D( _ColorMap1, uv_ColorMap1 ).b).xxxx;
			float4 blendOpSrc44_g7 = tex2D( _DetailB, uv_DetailB );
			float4 blendOpDest44_g7 = temp_cast_2;
			float2 uv_DetailA = i.uv_texcoord * _DetailA_ST.xy + _DetailA_ST.zw;
			float4 temp_cast_3 = (tex2D( _ColorMap1, uv_ColorMap1 ).a).xxxx;
			float4 blendOpSrc48_g7 = tex2D( _DetailA, uv_DetailA );
			float4 blendOpDest48_g7 = temp_cast_3;
			float4 weightedBlendVar73_g7 = float4(0.5,0.5,0.5,0.5);
			float4 weightedBlend73_g7 = ( weightedBlendVar73_g7.x*( saturate( ( blendOpSrc36_g7 * blendOpDest36_g7 ) )) + weightedBlendVar73_g7.y*( saturate( ( blendOpSrc40_g7 * blendOpDest40_g7 ) )) + weightedBlendVar73_g7.z*( saturate( ( blendOpSrc44_g7 * blendOpDest44_g7 ) )) + weightedBlendVar73_g7.w*( saturate( ( blendOpSrc48_g7 * blendOpDest48_g7 ) )) );
			float4 blendOpSrc77_g7 = weightedBlend73_g7;
			float4 blendOpDest77_g7 = tex2D( _Satellite, uv_Satellite );
			float4 lerpBlendMode77_g7 = lerp(blendOpDest77_g7,2.0f*blendOpDest77_g7*blendOpSrc77_g7 + blendOpDest77_g7*blendOpDest77_g7*(1.0f - 2.0f*blendOpSrc77_g7),_BlendAlpha);
			float3 ase_worldPos = i.worldPos;
			float clampResult9_g9 = clamp( pow( ( distance( ase_worldPos , _WorldSpaceCameraPos ) / _DetailTransitionDistance ) , _DetailTransitionFalloff ) , 0.0 , 1.0 );
			float4 lerpResult178 = lerp( tex2D( _Satellite, uv_Satellite ) , ( saturate( lerpBlendMode77_g7 )) , clampResult9_g9);
			o.Albedo = lerpResult178.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18000
-1748;151;1630;765;1194.957;1498.24;4.104579;True;True
Node;AmplifyShaderEditor.TexturePropertyNode;94;955.8022,22.26625;Inherit;True;Property;_Satellite;Satellite;0;0;Create;True;0;0;False;0;None;63a851a7b3951074391fd450f2157ec6;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.WireNode;124;1146.521,248.6954;Inherit;False;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;114;958.2184,341.3094;Inherit;False;Property;_BlendAlpha;Blend Alpha;4;0;Create;True;0;0;False;0;0.5;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;123;887.5214,308.6954;Inherit;False;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.WireNode;115;1195.521,417.6954;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;95;334.2095,974.3718;Inherit;True;Property;_ColorMap1;Color Map;3;0;Create;True;0;0;False;0;None;2eb4adaad09058447831d3142fb67b5e;False;black;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;111;334.7339,560.4562;Inherit;True;Property;_DetailB;Detail B;7;0;Create;True;0;0;False;0;None;None;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;96;334.7403,151.0397;Inherit;True;Property;_DetailR;Detail R;5;0;Create;True;0;0;False;0;None;8f7c611c0e5e87a4d92eed37bde7dc8e;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;112;335.0006,778.5341;Inherit;True;Property;_DetailA;Detail A;8;0;Create;True;0;0;False;0;None;None;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;110;334.7337,361.2783;Inherit;True;Property;_DetailG;Detail G;6;0;Create;True;0;0;False;0;None;9fbef4b79ca3b784ba023cb1331520d5;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.WireNode;116;935.5215,423.6954;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;122;898.5214,638.6954;Inherit;False;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.WireNode;121;898.5214,603.6954;Inherit;False;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.WireNode;119;898.5214,544.6954;Inherit;False;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.WireNode;118;900.5214,516.6954;Inherit;False;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;180;1335.074,662.9655;Inherit;False;Property;_DetailTransitionFalloff;Detail Transition Falloff;2;0;Create;True;0;0;False;0;-0.5;-0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;120;901.5214,574.6954;Inherit;False;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.WireNode;117;901.5214,487.6954;Inherit;False;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;179;1317.851,574.1217;Inherit;False;Property;_DetailTransitionDistance;Detail Transition Distance;1;0;Create;True;0;0;False;0;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;172;952.218,452.7955;Inherit;True;ColorMapBlendFunction;-1;;7;85c4d4cd6251d76429b2958273adbf34;0;7;78;FLOAT;0.5;False;79;SAMPLER2D;0;False;59;SAMPLER2D;0;False;60;SAMPLER2D;0;False;61;SAMPLER2D;0;False;62;SAMPLER2D;0;False;63;SAMPLER2D;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;174;1268.403,92.91866;Inherit;True;Property;_TextureSample0;Texture Sample 0;7;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;175;1584.381,608.5054;Inherit;False;DistanceBlend;-1;;9;fad0c824881b88448b77d691ac7e3ca0;0;2;7;FLOAT;5;False;8;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;178;1892.159,438.1122;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2273.085,441.1956;Float;False;True;-1;6;ASEMaterialInspector;0;0;Standard;Ground Detail;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;124;0;94;0
WireConnection;123;0;124;0
WireConnection;115;0;114;0
WireConnection;116;0;115;0
WireConnection;122;0;95;0
WireConnection;121;0;112;0
WireConnection;119;0;110;0
WireConnection;118;0;96;0
WireConnection;120;0;111;0
WireConnection;117;0;123;0
WireConnection;172;78;116;0
WireConnection;172;79;117;0
WireConnection;172;59;118;0
WireConnection;172;60;119;0
WireConnection;172;61;120;0
WireConnection;172;62;121;0
WireConnection;172;63;122;0
WireConnection;174;0;94;0
WireConnection;175;7;179;0
WireConnection;175;8;180;0
WireConnection;178;0;174;0
WireConnection;178;1;172;0
WireConnection;178;2;175;0
WireConnection;0;0;178;0
ASEEND*/
//CHKSM=98429F2D29E7036121C8FA28FC3A49688304A954