Shader "Instanced/InstancedSurfaceShader" {
    Properties{
        _MainTex("Albedo (RGB)", 2D) = "white" {}
        _Glossiness("Smoothness", Range(0,1)) = 0.5
        _Metallic("Metallic", Range(0,1)) = 0.0
    }
        SubShader{
            Tags { "RenderType" = "Opaque" }
            LOD 200

            CGPROGRAM
            // Physically based Standard lighting model
            #pragma surface surf Standard addshadow fullforwardshadows
            #pragma multi_compile_instancing
            #pragma instancing_options procedural:setup

            sampler2D _MainTex;

            struct appdata_t {
                float4 vertex   : POSITION;
                float2 texcoord : TEXCOORD0;
                float4 color    : COLOR;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 vertex   : SV_POSITION;
                float2 uv : TEXCOORD0;
                half3 worldNormal : TEXCOORD1;
            };

            struct MeshProperties {
                float4x4 mat;
                float4 color;
            };

            #ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
                StructuredBuffer<MeshProperties> _Properties;
            #endif

            void setup(inout appdata_t i, uint instanceID: SV_InstanceID)
            {
            #ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
                float4 pos = mul(_Properties[instanceID].mat, i.vertex);
                i.vertex = UnityObjectToClipPos(pos);
                i.uv = i.texcoord
                i.worldNormal = UnityObjectToWorldNormal(i.normal);
            #endif
            }

            half _Glossiness;
            half _Metallic;

            void surf(v2f IN, inout SurfaceOutputStandard o) {
                fixed4 c = tex2D(_MainTex, IN.uv);
                /*o.Albedo = c.rgb;
                o.Metallic = _Metallic;
                o.Smoothness = _Glossiness;
                o.Alpha = c.a;*/
            }
            ENDCG
        }
            FallBack "Diffuse"
}