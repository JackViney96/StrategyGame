// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Ground Detail"
{
	Properties
	{
		_Satellite("Satellite", 2D) = "white" {}
		_DetailTransitionDistance("Detail Transition Distance", Float) = 5
		_DetailTransitionFalloff("Detail Transition Falloff", Float) = -0.5
		_ColorMap("Color Map", 2D) = "black" {}
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
		uniform sampler2D _ColorMap;
		uniform float4 _ColorMap_ST;
		uniform sampler2D _DetailG;
		uniform float4 _DetailG_ST;
		uniform sampler2D _DetailB;
		uniform float4 _DetailB_ST;
		uniform sampler2D _DetailA;
		uniform float4 _DetailA_ST;
		uniform float _DetailTransitionDistance;
		uniform float _DetailTransitionFalloff;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Satellite = i.uv_texcoord * _Satellite_ST.xy + _Satellite_ST.zw;
			float2 uv_DetailR = i.uv_texcoord * _DetailR_ST.xy + _DetailR_ST.zw;
			float2 uv_ColorMap = i.uv_texcoord * _ColorMap_ST.xy + _ColorMap_ST.zw;
			float4 lerpResult83_g1 = lerp( float4( 0,0,0,0 ) , tex2D( _DetailR, uv_DetailR ) , tex2D( _ColorMap, uv_ColorMap ).r);
			float2 uv_DetailG = i.uv_texcoord * _DetailG_ST.xy + _DetailG_ST.zw;
			float4 lerpResult82_g1 = lerp( float4( 0,0,0,0 ) , tex2D( _DetailG, uv_DetailG ) , tex2D( _ColorMap, uv_ColorMap ).g);
			float2 uv_DetailB = i.uv_texcoord * _DetailB_ST.xy + _DetailB_ST.zw;
			float4 lerpResult81_g1 = lerp( float4( 0,0,0,0 ) , tex2D( _DetailB, uv_DetailB ) , tex2D( _ColorMap, uv_ColorMap ).b);
			float2 uv_DetailA = i.uv_texcoord * _DetailA_ST.xy + _DetailA_ST.zw;
			float4 lerpResult91_g1 = lerp( tex2D( _DetailA, uv_DetailA ) , float4( 0,0,0,0 ) , tex2D( _ColorMap, uv_ColorMap ).a);
			float4 weightedBlendVar86_g1 = float4(0.5,0.5,0.5,0.5);
			float4 weightedAvg86_g1 = ( ( weightedBlendVar86_g1.x*lerpResult83_g1 + weightedBlendVar86_g1.y*lerpResult82_g1 + weightedBlendVar86_g1.z*lerpResult81_g1 + weightedBlendVar86_g1.w*lerpResult91_g1 )/( weightedBlendVar86_g1.x + weightedBlendVar86_g1.y + weightedBlendVar86_g1.z + weightedBlendVar86_g1.w ) );
			float3 ase_worldPos = i.worldPos;
			float clampResult9_g9 = clamp( pow( ( distance( ase_worldPos , _WorldSpaceCameraPos ) / _DetailTransitionDistance ) , _DetailTransitionFalloff ) , 0.0 , 1.0 );
			float4 lerpResult178 = lerp( tex2D( _Satellite, uv_Satellite ) , ( weightedAvg86_g1 + tex2D( _Satellite, uv_Satellite ) ) , clampResult9_g9);
			o.Albedo = lerpResult178.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18100
-1748;151;1630;765;-834.4881;-128.1143;1.303804;True;True
Node;AmplifyShaderEditor.TexturePropertyNode;95;334.2095,974.3718;Inherit;True;Property;_ColorMap;Color Map;3;0;Create;True;0;0;False;0;False;None;2eb4adaad09058447831d3142fb67b5e;False;black;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;111;334.7339,560.4562;Inherit;True;Property;_DetailB;Detail B;7;0;Create;True;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;96;334.7403,151.0397;Inherit;True;Property;_DetailR;Detail R;5;0;Create;True;0;0;False;0;False;None;8f7c611c0e5e87a4d92eed37bde7dc8e;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;110;334.7337,361.2783;Inherit;True;Property;_DetailG;Detail G;6;0;Create;True;0;0;False;0;False;None;080054e6814f07f468235394fbfb6aa6;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.WireNode;122;898.5214,638.6954;Inherit;False;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;180;1335.074,662.9655;Inherit;False;Property;_DetailTransitionFalloff;Detail Transition Falloff;2;0;Create;True;0;0;False;0;False;-0.5;-1.92;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;120;901.5214,574.6954;Inherit;False;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.WireNode;119;898.5214,544.6954;Inherit;False;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;94;955.8022,22.26625;Inherit;True;Property;_Satellite;Satellite;0;0;Create;True;0;0;False;0;False;None;63a851a7b3951074391fd450f2157ec6;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;112;335.0006,778.5341;Inherit;True;Property;_DetailA;Detail A;8;0;Create;True;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.WireNode;118;900.5214,516.6954;Inherit;False;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;179;1317.851,574.1217;Inherit;False;Property;_DetailTransitionDistance;Detail Transition Distance;1;0;Create;True;0;0;False;0;False;5;15.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;175;1583.177,608.5054;Inherit;False;DistanceBlend;-1;;9;fad0c824881b88448b77d691ac7e3ca0;0;2;7;FLOAT;5;False;8;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;174;1268.403,92.91866;Inherit;True;Property;_TextureSample0;Texture Sample 0;7;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;225;952.218,452.7955;Inherit;True;ColorMapBlendFunction;-1;;1;85c4d4cd6251d76429b2958273adbf34;0;7;78;FLOAT;0.5;False;79;SAMPLER2D;0;False;59;SAMPLER2D;0;False;60;SAMPLER2D;0;False;61;SAMPLER2D;0;False;62;SAMPLER2D;;False;63;SAMPLER2D;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;178;1960.778,431.1314;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendOpsNode;184;1928.489,166.6189;Inherit;True;ColorDodge;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;114;958.2184,341.3094;Inherit;False;Property;_BlendAlpha;Blend Alpha;4;0;Create;True;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2327.686,432.0956;Float;False;True;-1;6;ASEMaterialInspector;0;0;Standard;Ground Detail;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;True;0.5;True;0;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;122;0;95;0
WireConnection;120;0;111;0
WireConnection;119;0;110;0
WireConnection;118;0;96;0
WireConnection;175;7;179;0
WireConnection;175;8;180;0
WireConnection;174;0;94;0
WireConnection;225;79;94;0
WireConnection;225;59;118;0
WireConnection;225;60;119;0
WireConnection;225;61;120;0
WireConnection;225;62;112;0
WireConnection;225;63;122;0
WireConnection;178;0;174;0
WireConnection;178;1;225;0
WireConnection;178;2;175;0
WireConnection;0;0;178;0
ASEEND*/
//CHKSM=262BCA1C9CF7048B55C2A52CABAA99E521FC5279