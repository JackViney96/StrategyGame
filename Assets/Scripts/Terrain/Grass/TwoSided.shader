/// Created by @cortvi
Shader "Custom/Two sided"
{
	Properties
	{
		// You can learn everything about properties here:
		// https://docs.unity3d.com/Manual/SL-Properties.html
		_Color("Main Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Cutoff("Cutout threshold", Range(0.0,1.0)) = 0.1
		[NoScaleOffset] _SmoothnessMap("Roughness map (A)", 2D) = "black" {}
		_Smoothness("Flat roughness", Range(0.0, 1.0)) = 0.0
		[NoScaleOffset][Normal] _BumpMap("Normal map (RGB)", 2D) = "bump" {}
		_BumpScale("Normal scale", Float) = 1.0
	}

		SubShader
		{
			Tags { "Queue" = "AlphaTest" "RenderType" = "TransparentCutout" }

			CGINCLUDE
			// Whatever you write inside here
			// will be included in every pass
			struct Input
			{
	 float2 uv_MainTex;
};

fixed4 _Color;
sampler2D _MainTex;
sampler2D _BumpMap;
float _BumpScale;
sampler2D _SmoothnessMap;
float _Smoothness;

void surf(Input IN, inout SurfaceOutputStandard o)
{
	fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
	fixed3 normal = UnpackScaleNormal(tex2D(_BumpMap, IN.uv_MainTex), _BumpScale).xyz;
	fixed smooth = tex2D(_SmoothnessMap, IN.uv_MainTex).a;

	// Feed surface output
	o.Albedo = c.rgb;
	o.Normal = normal;
	o.Metallic = 0.0;
	o.Smoothness = lerp(smooth, 1.0, _Smoothness);
	o.Alpha = c.a;
}
ENDCG

Cull Front
CGPROGRAM
#pragma surface surf Standard fullforwardshadows vertex:vert alphatest:_Cutoff
#pragma target 3.0

void vert(inout appdata_full v)
{
	v.normal = -v.normal;
}
ENDCG

Cull Back
CGPROGRAM
#pragma surface surf Standard fullforwardshadows alphatest:_Cutoff
#pragma target 3.0
ENDCG
		}

			Fallback "Standard"
}