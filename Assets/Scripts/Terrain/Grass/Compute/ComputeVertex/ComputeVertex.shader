Shader "ComputeVertex"
{
	Properties
	{
		_MainTex ("_MainTex (RGBA)", 2D) = "white" {}
		_Color ("_Color", Color) = (1,1,1,1)
	}
	SubShader
	{
		Pass
		{
			Tags {"LightMode" = "Deferred"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "AutoLight.cginc"

			#pragma multi_compile_fwdbase

			// Same with the one with compute shader & C# script
			struct vertexData
			{
			    uint id;
				float4 pos;
				float3 nor;
				float2 uv;
				float4 col;

				float4 opos;
				float3 velocity;
			};
			StructuredBuffer<vertexData> vertexBuffer;

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				fixed4 color : COLOR;

				LIGHTING_COORDS(1, 2)
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color;
			
			v2f vert (uint id : SV_VertexID)
			{
				v2f o;
				
				uint realid = vertexBuffer[id].id;
				
				o.pos = UnityObjectToClipPos(vertexBuffer[realid].pos);
				o.uv = TRANSFORM_TEX(vertexBuffer[realid].uv, _MainTex);
				o.color = vertexBuffer[realid].col;
				TRANSFER_VERTEX_TO_FRAGMENT(o);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{

				fixed4 col = tex2D(_MainTex, i.uv);
				float attenuation = LIGHT_ATTENUATION(i);
				col.rgb *= i.color.rgb;
				return col* _Color * attenuation;
			}
			ENDCG
		}

		Pass
		{
			Tags { "LightMode" = "ShadowCaster" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#define UNITY_PASS_SHADOWCASTER

			#include "UnityCG.cginc"

			// Same with the one with compute shader & C# script
			struct vertexData
			{
				uint id;
				float4 pos;
				float3 nor;
				float2 uv;
				float4 col;

				float4 opos;
				float3 velocity;
			};
			StructuredBuffer<vertexData> vertexBuffer;

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				fixed4 color : COLOR;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color;

			v2f vert(uint id : SV_VertexID)
			{
				v2f o;

				uint realid = vertexBuffer[id].id;

				o.vertex = UnityObjectToClipPos(vertexBuffer[realid].pos);
				o.uv = TRANSFORM_TEX(vertexBuffer[realid].uv, _MainTex);
				o.color = vertexBuffer[realid].col;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{

				fixed4 col = tex2D(_MainTex, i.uv);
				col.rgb *= i.color.rgb;
				return col * _Color;
			}

			// Default shadow caster pass
			/*half4 frag(v2f input) : SV_Target{
				fixed4 c = tex2D(_MainTex, input.uv);
				return 0;
			}*/
			ENDCG
		}
	}
}
