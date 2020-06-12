// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/HeightBlendLayertest"
{
	Properties
	{
		_Grass("Grass", 2D) = "white" {}
		_GrassNormal("Grass Normal", 2D) = "bump" {}
		_GrassMetalRSmoothGHeightB("Grass Metal(R) Smooth(G) Height(B)", 2D) = "white" {}
		_GrassMetallic("Grass  Metallic", Range( 0 , 1)) = 0
		_GrassSmoothness("Grass Smoothness", Range( 0 , 1)) = 0.5
		_Dirt("Dirt", 2D) = "white" {}
		_DirtNormal("Dirt Normal", 2D) = "bump" {}
		_DirtMetalRSmoothGHeightB("Dirt Metal(R) Smooth(G) Height(B)", 2D) = "white" {}
		_DirtMetallic("Dirt Metallic", Range( 0 , 1)) = 0
		_DirtSmoothness("Dirt Smoothness", Range( 0 , 1)) = 0.5
		_DirtHeightScale("Dirt Height Scale", Range( 0 , 10)) = 1
		_DirtHeightOffset("Dirt Height Offset", Range( -10 , 10)) = 1
		_DirtColorScale("Dirt Color Scale", Range( 0 , 20)) = 1
		_DirtColorOffset("Dirt Color Offset", Range( -20 , 20)) = 1
		_Rock("Rock", 2D) = "white" {}
		_RockNormal("Rock Normal", 2D) = "bump" {}
		_RockMetalRSmoothGHeightB("Rock Metal(R) Smooth(G) Height(B)", 2D) = "white" {}
		_RockMetallic("Rock Metallic", Range( 0 , 1)) = 0
		_RockSmoothness("Rock Smoothness", Range( 0 , 1)) = 0.5
		_RockHeightScale("Rock Height Scale", Range( 0 , 10)) = 1
		_RockHeightOffset("Rock Height Offset", Range( -10 , 10)) = 1
		_RockColorScale("Rock Color Scale", Range( 0 , 20)) = 1
		_RockColorOffset("Rock Color Offset", Range( -20 , 20)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
		};

		uniform sampler2D _GrassNormal;
		uniform sampler2D _Grass;
		uniform float4 _Grass_ST;
		uniform sampler2D _DirtNormal;
		uniform sampler2D _GrassMetalRSmoothGHeightB;
		uniform sampler2D _DirtMetalRSmoothGHeightB;
		uniform sampler2D _RockMetalRSmoothGHeightB;
		uniform float _DirtHeightScale;
		uniform float _RockHeightScale;
		uniform float _DirtHeightOffset;
		uniform float _RockHeightOffset;
		uniform float _DirtColorScale;
		uniform float _RockColorScale;
		uniform float _DirtColorOffset;
		uniform float _RockColorOffset;
		uniform sampler2D _RockNormal;
		uniform sampler2D _Dirt;
		uniform sampler2D _Rock;
		uniform float _GrassMetallic;
		uniform float _DirtMetallic;
		uniform float _RockMetallic;
		uniform float _GrassSmoothness;
		uniform float _DirtSmoothness;
		uniform float _RockSmoothness;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv0_Grass = i.uv_texcoord * _Grass_ST.xy + _Grass_ST.zw;
			float4 tex2DNode140 = tex2D( _GrassMetalRSmoothGHeightB, uv0_Grass );
			float4 tex2DNode141 = tex2D( _DirtMetalRSmoothGHeightB, uv0_Grass );
			float4 tex2DNode149 = tex2D( _RockMetalRSmoothGHeightB, uv0_Grass );
			float4 appendResult135 = (float4(tex2DNode140.b , tex2DNode141.b , tex2DNode149.b , 0.0));
			float4 appendResult111 = (float4(0.0 , _DirtHeightScale , _RockHeightScale , 0.0));
			float4 appendResult114 = (float4(0.0 , _DirtHeightOffset , _RockHeightOffset , 0.0));
			float4 temp_output_101_0 = (( 1.0 - appendResult135 )*appendResult111 + appendResult114);
			float4 appendResult120 = (float4(0.0 , _DirtColorScale , _RockColorScale , 0.0));
			float4 appendResult121 = (float4(0.0 , _DirtColorOffset , _RockColorOffset , 0.0));
			float4 temp_output_97_0 = (i.vertexColor*appendResult120 + appendResult121);
			float4 Blender124 = ( 1.0 - saturate( ( temp_output_101_0 + temp_output_97_0 ) ) );
			float3 lerpResult72 = lerp( UnpackNormal( tex2D( _GrassNormal, uv0_Grass ) ) , UnpackNormal( tex2D( _DirtNormal, uv0_Grass ) ) , (Blender124).y);
			float3 lerpResult71 = lerp( lerpResult72 , UnpackNormal( tex2D( _RockNormal, uv0_Grass ) ) , (Blender124).z);
			o.Normal = lerpResult71;
			float4 lerpResult29 = lerp( tex2D( _Grass, uv0_Grass ) , tex2D( _Dirt, uv0_Grass ) , (Blender124).y);
			float4 lerpResult3 = lerp( lerpResult29 , tex2D( _Rock, uv0_Grass ) , (Blender124).z);
			o.Albedo = lerpResult3.rgb;
			float temp_output_156_0 = (Blender124).y;
			float lerpResult143 = lerp( ( _GrassMetallic * tex2DNode140.r ) , ( _DirtMetallic * tex2DNode141.r ) , temp_output_156_0);
			float temp_output_157_0 = (Blender124).z;
			float lerpResult158 = lerp( lerpResult143 , ( _RockMetallic * tex2DNode149.r ) , temp_output_157_0);
			o.Metallic = lerpResult158;
			float lerpResult144 = lerp( ( tex2DNode140.g * _GrassSmoothness ) , ( tex2DNode141.g * _DirtSmoothness ) , temp_output_156_0);
			float lerpResult159 = lerp( lerpResult144 , ( tex2DNode149.g * _RockSmoothness ) , temp_output_157_0);
			o.Smoothness = lerpResult159;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18000
575;72;1314;557;2150.933;610.0306;3.49981;True;True
Node;AmplifyShaderEditor.TextureCoordinatesNode;160;-1952,1376;Inherit;False;0;28;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;141;-1536,1456;Inherit;True;Property;_DirtMetalRSmoothGHeightB;Dirt Metal(R) Smooth(G) Height(B);7;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;149;-1536,1920;Inherit;True;Property;_RockMetalRSmoothGHeightB;Rock Metal(R) Smooth(G) Height(B);16;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;140;-1536,1104;Inherit;True;Property;_GrassMetalRSmoothGHeightB;Grass Metal(R) Smooth(G) Height(B);2;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;171;-1176.547,1643.269;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;169;-1202.148,2123.269;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;166;-1211.148,1306.269;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;168;-779.5472,1296.169;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;172;-662.7482,1793.169;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;170;-1030.948,2108.87;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;174;37.05188,1723.669;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;173;37.05188,1771.169;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;165;42.75266,1672.169;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;135;320,1680;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;113;34.99989,1842.8;Float;False;Property;_DirtHeightScale;Dirt Height Scale;10;0;Create;True;0;0;False;0;1;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;112;34.99989,1922.8;Float;False;Property;_RockHeightScale;Rock Height Scale;19;0;Create;True;0;0;False;0;1;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;122;34.99989,2354.801;Float;False;Property;_DirtColorOffset;Dirt Color Offset;13;0;Create;True;0;0;False;0;1;0;-20;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;116;34.99989,2002.8;Float;False;Property;_DirtHeightOffset;Dirt Height Offset;11;0;Create;True;0;0;False;0;1;0;-10;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;117;34.99989,2434.801;Float;False;Property;_RockColorOffset;Rock Color Offset;22;0;Create;True;0;0;False;0;1;0;-20;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;115;34.99989,2082.801;Float;False;Property;_RockHeightOffset;Rock Height Offset;20;0;Create;True;0;0;False;0;1;0;-10;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;118;34.99989,2194.801;Float;False;Property;_DirtColorScale;Dirt Color Scale;12;0;Create;True;0;0;False;0;1;0;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;119;34.99989,2274.801;Float;False;Property;_RockColorScale;Rock Color Scale;21;0;Create;True;0;0;False;0;1;0;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;111;323.0016,1858.8;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;120;323.0016,2210.801;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;114;323.0016,2002.8;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;121;323.0016,2354.801;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.OneMinusNode;102;483.0016,1714.8;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.VertexColorNode;94;-93.00203,2130.801;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;97;515.0016,2130.801;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0.5,0,0,0;False;2;COLOR;-0.5,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;101;515.0016,1842.8;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0.5,0,0,0;False;2;FLOAT4;-0.5,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;107;867.0016,1986.8;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SaturateNode;108;1010.601,1982.8;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.OneMinusNode;109;1154.601,1982.8;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;124;1298.601,1982.8;Float;False;Blender;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;145;-1536,1728;Inherit;False;124;Blender;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;126;-1536,624;Inherit;False;124;Blender;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;133;-1860.601,120.9001;Inherit;False;0;28;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;147;-1536,1280;Float;False;Property;_GrassSmoothness;Grass Smoothness;4;0;Create;True;0;0;False;0;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;154;-1536,1632;Float;False;Property;_DirtSmoothness;Dirt Smoothness;9;0;Create;True;0;0;False;0;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;130;-768,336;Inherit;False;124;Blender;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;146;-1536,1376;Float;False;Property;_DirtMetallic;Dirt Metallic;8;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;137;-1536,1024;Float;False;Property;_GrassMetallic;Grass  Metallic;3;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;155;-1536,2096;Float;False;Property;_RockSmoothness;Rock Smoothness;18;0;Create;True;0;0;False;0;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;151;-1536,2192;Inherit;False;124;Blender;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;142;-1152,1408;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;152;-1152,1520;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;28;-768,-32;Inherit;True;Property;_Grass;Grass;0;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;125;-1344,624;Inherit;False;False;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;131;-768,608;Inherit;False;124;Blender;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;129;-576,336;Inherit;False;False;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;150;-1536,1840;Float;False;Property;_RockMetallic;Rock Metallic;17;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-768,144;Inherit;True;Property;_Dirt;Dirt;5;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;139;-1196.5,1180.9;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;156;-1360,1728;Inherit;False;False;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;68;-1536,304;Inherit;True;Property;_GrassNormal;Grass Normal;1;0;Create;True;0;0;False;0;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;128;-1536,880;Inherit;False;124;Blender;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;134;-1195.001,282.3002;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;138;-1216,1088;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;69;-1536,464;Inherit;True;Property;_DirtNormal;Dirt Normal;6;0;Create;True;0;0;False;0;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;143;-896,1360;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;127;-1344,880;Inherit;False;False;False;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;157;-1360,2192;Inherit;False;False;False;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;70;-1536,720;Inherit;True;Property;_RockNormal;Rock Normal;15;0;Create;True;0;0;False;0;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-768,432;Inherit;True;Property;_Rock;Rock;14;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;144;-896,1488;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;153;-1152,1984;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;132;-576,608;Inherit;False;False;False;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;29;-384,272;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;72;-1136,496;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;148;-1152,1872;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;71;-944,704;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;3;-192,416;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;159;-640,1664;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;105;707.0016,2050.801;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;106;707.0016,1970.8;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;158;-640,1536;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,672;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Custom/HeightBlendLayertest;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;141;1;160;0
WireConnection;149;1;160;0
WireConnection;140;1;160;0
WireConnection;171;0;141;3
WireConnection;169;0;149;3
WireConnection;166;0;140;3
WireConnection;168;0;166;0
WireConnection;172;0;171;0
WireConnection;170;0;169;0
WireConnection;174;0;172;0
WireConnection;173;0;170;0
WireConnection;165;0;168;0
WireConnection;135;0;165;0
WireConnection;135;1;174;0
WireConnection;135;2;173;0
WireConnection;111;1;113;0
WireConnection;111;2;112;0
WireConnection;120;1;118;0
WireConnection;120;2;119;0
WireConnection;114;1;116;0
WireConnection;114;2;115;0
WireConnection;121;1;122;0
WireConnection;121;2;117;0
WireConnection;102;0;135;0
WireConnection;97;0;94;0
WireConnection;97;1;120;0
WireConnection;97;2;121;0
WireConnection;101;0;102;0
WireConnection;101;1;111;0
WireConnection;101;2;114;0
WireConnection;107;0;101;0
WireConnection;107;1;97;0
WireConnection;108;0;107;0
WireConnection;109;0;108;0
WireConnection;124;0;109;0
WireConnection;142;0;146;0
WireConnection;142;1;141;1
WireConnection;152;0;141;2
WireConnection;152;1;154;0
WireConnection;28;1;133;0
WireConnection;125;0;126;0
WireConnection;129;0;130;0
WireConnection;2;1;133;0
WireConnection;139;0;140;2
WireConnection;139;1;147;0
WireConnection;156;0;145;0
WireConnection;68;1;133;0
WireConnection;134;0;133;0
WireConnection;138;0;137;0
WireConnection;138;1;140;1
WireConnection;69;1;133;0
WireConnection;143;0;138;0
WireConnection;143;1;142;0
WireConnection;143;2;156;0
WireConnection;127;0;128;0
WireConnection;157;0;151;0
WireConnection;70;1;133;0
WireConnection;1;1;134;0
WireConnection;144;0;139;0
WireConnection;144;1;152;0
WireConnection;144;2;156;0
WireConnection;153;0;149;2
WireConnection;153;1;155;0
WireConnection;132;0;131;0
WireConnection;29;0;28;0
WireConnection;29;1;2;0
WireConnection;29;2;129;0
WireConnection;72;0;68;0
WireConnection;72;1;69;0
WireConnection;72;2;125;0
WireConnection;148;0;150;0
WireConnection;148;1;149;1
WireConnection;71;0;72;0
WireConnection;71;1;70;0
WireConnection;71;2;127;0
WireConnection;3;0;29;0
WireConnection;3;1;1;0
WireConnection;3;2;132;0
WireConnection;159;0;144;0
WireConnection;159;1;153;0
WireConnection;159;2;157;0
WireConnection;105;0;97;0
WireConnection;106;0;101;0
WireConnection;158;0;143;0
WireConnection;158;1;148;0
WireConnection;158;2;157;0
WireConnection;0;0;3;0
WireConnection;0;1;71;0
WireConnection;0;3;158;0
WireConnection;0;4;159;0
ASEEND*/
//CHKSM=E632A2C460010768BA072B3C01BD3682BA458B74