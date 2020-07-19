// Standard geometry shader example
// https://github.com/keijiro/StandardGeometryShader

Shader "Grass/Grass Geometry Shader"
{
    Properties
    {
        _MainTex("Albedo (RGB)", 2D) = "white" {}
        _Glossiness("Smoothness", Range(0,1)) = 0.5

        [Space]
        _BumpMap("Normal Map", 2D) = "bump" {}
        _BumpScale("Scale", Float) = 1

        [Space]
        _OcclusionMap("Occlusion Map", 2D) = "white" {}
        _OcclusionStrength("Strength", Range(0, 1)) = 1

        _Metallic("Metallic", Range(0,1)) = 0.0
        _Cutoff("Alpha Cuttoff", Range(0,1)) = 0.15 // Wieviel abgeschnitten sien soll
        _GrassHeight("GrasHeight", Float) = 0.25
        _GrassWidth("GrasWidth", Float) = 0.25
        _WindSpeed("WindSpeed", Float) = 100
        _WindStrength("WindStrength", Float) = 0.05
        _DiffuseTint("Diffuse Tint", Color) = (1, 1, 1, 1)

    }
        SubShader
        {
            Tags {"RenderType" = "Opaque" }

            // This shader only implements the deferred rendering pass (GBuffer
            // construction) and the shadow caster pass, so that it doesn't
            // support forward rendering.


            Pass
            {
                Tags { "LightMode" = "ForwardBase" }
                Cull OFF
                CGPROGRAM

                // Vertex-Shader with vert-function
                #pragma vertex vert
                // Fragment-Shader with frag-function
                #pragma fragment Fragment
                // Geometry-Shader with geom-function 
                #pragma geometry geom

                // Use shader model 3.0 target, to get nicer looking lighting
                #pragma target 4.0 // needs to be 4.0 !
                //#pragma multi_compile_prepassfinal noshadowmask nodynlightmap nodirlightmap nolightmap
                #pragma multi_compile_fwdbase
                
                #include "GrassGeometry.cginc"

                ENDCG

            }

            //Pass
            //{
            //    Tags { "LightMode" = "ForwardAdd" }
            //    Cull OFF
            //    Blend One One
            //    ZWrite Off
            //    CGPROGRAM

            //    // Vertex-Shader with vert-function
            //    #pragma vertex vert
            //    // Fragment-Shader with frag-function
            //    #pragma fragment Fragment
            //    // Geometry-Shader with geom-function 
            //    #pragma geometry geom

            //    // Use shader model 3.0 target, to get nicer looking lighting
            //    #pragma target 4.0 // needs to be 4.0 !
            //    //#pragma multi_compile_prepassfinal noshadowmask nodynlightmap nodirlightmap nolightmap
            //    #pragma multi_compile_fwdadd

            //    #include "GrassGeometry.cginc"

            //    ENDCG

            //}

            Pass
            {
                Tags { "LightMode" = "ShadowCaster" }
                Cull OFF
                CGPROGRAM
                #pragma target 4.0 
                // Vertex-Shader with vert-function
                #pragma vertex vert
                // Fragment-Shader with frag-function
                #pragma fragment Fragment
                // Geometry-Shader with geom-function 
                #pragma geometry geom
                #pragma multi_compile_shadowcaster noshadowmask nodynlightmap nodirlightmap nolightmap
                #define UNITY_PASS_SHADOWCASTER
                #include "GrassGeometry.cginc"
                ENDCG
            }
        }
}
