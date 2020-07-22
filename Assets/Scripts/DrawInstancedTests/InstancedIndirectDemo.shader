Shader "Custom/InstancedIndirectColor" {

    Properties{
        _MainTex("Albedo (RGB)", 2D) = "white" {}
        _Glossiness("Smoothness", Range(0,1)) = 0.5

        [Space]
        _NormalMap("Normal Map", 2D) = "bump" {}
        _NormalScale("Scale", Float) = 1

        [Space]
        _OcclusionMap("Occlusion Map", 2D) = "white" {}
        _OcclusionStrength("Strength", Range(0, 1)) = 1

        _Metallic("Metallic", Range(0,1)) = 0.0
        _Cutoff("Alpha Cuttoff", Range(0,1)) = 0.15

    }

        SubShader{
            Tags { "RenderType" = "Opaque" }

            Pass {
                //Tags { "LightMode" = "ShadowCaster" }
                Tags { "LightMode" = "Deferred" }

                Cull Off
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag

                #include "InstancedGrass.cginc"

                ENDCG
            }

            /*Pass {
                Tags { "LightMode" = "ShadowCaster" }

                Cull Off
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #define UNITY_PASS_SHADOWCASTER

                #include "InstancedGrass.cginc"

                ENDCG
            }*/
    }
}