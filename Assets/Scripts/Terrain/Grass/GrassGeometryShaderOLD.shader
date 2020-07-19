Shader "Custom/Grass Geometry Shader" {

    // https://www.youtube.com/watch?v=HY6qFbmbij8 und http://www.battlemaze.com/?p=153

    Properties{
        // --> HDR allows High Dynamic Colors
            [HDR] _BackgroundColor("Background Color", Color) = (1,0,0,1) // default to red
            [HDR]_ForegroundColor("Foreground Color", Color) = (0,1,0,1) // default to green 
            _MainTex("Albedo (RGB)", 2D) = "white" {}
            _Glossiness("Smoothness", Range(0,1)) = 0.5
            _Metallic("Metallic", Range(0,1)) = 0.0
            _Cutoff("Alpha Cuttoff", Range(0,1)) = 0.15 // Wieviel abgeschnitten sien soll
            _GrassHeight("GrasHeight", Float) = 0.25
            _GrassWidt("GrasWidth", Float) = 0.25
            _WindSpeed("WindSpeed", Float) = 100
            _WindStrength("WindStrength", Float) = 0.05 
    }
        SubShader{
            Tags { "RenderType" = "Opaque" }
            LOD 200

            Pass{

            Cull OFF
            CGPROGRAM
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            
            #pragma multi_compile_fwdbase

            // Vertex-Shader with vert-function
            #pragma vertex vert
            // Fragment-Shader with frag-function
            #pragma fragment frag
            // Geometry-Shader with geom-function 
            #pragma geometry geom

            // Use shader model 3.0 target, to get nicer looking lighting
            #pragma target 4.0 // needs to be 4.0 !

            sampler2D _MainTex;

            // vertex to graphics (v2g)
            struct v2g
            {
                float4  pos : SV_POSITION;
                float3  norm : NORMAL;
                float2  uv : TEXCOORD0;
                float3 color : TEXCOORD1;
                SHADOW_COORDS(3) // (3) means we are using TEXCOORD3
            };

            //graphics to fragments (g2f)
            struct g2f
            {
                float4  pos : SV_POSITION;
                float3  norm : NORMAL;
                float2  uv : TEXCOORD0;
                float3 diffuseColor : TEXCOORD1;
                //float3 specularColor : TEXCOORD2;
            };

            half _Glossiness;
            half _Metallic;
            fixed4 _BackgroundColor;
            fixed4 _ForegroundColor;
            half _GrassHeight;
            half _GrassWidth;
            half _Cutoff;
            half _WindStrength;
            half _WindSpeed;

            // Vertex-Shader from Battlemaze.com
            v2g vert(appdata_full v)
            {
                float3 v0 = mul(unity_ObjectToWorld, v.vertex).xyz;

                v2g OUT;
                OUT.pos = v.vertex;
                OUT.norm = v.normal;
                OUT.uv = v.texcoord;
                OUT.color = tex2Dlod(_MainTex, v.texcoord).rgb;
                return OUT;
            }

            void buldQuad(inout TriangleStream<g2f> triStream, float3 points[4], float3 color) {
                g2f OUT;
                float3 faceNormal = cross(points[1] - points[0], points[2] - points[0]);
                for (int i; i < 4; ++i) {
                OUT.pos = UnityObjectToClipPos(points[i]);
                OUT.norm = faceNormal;
                OUT.diffuseColor = color;
                OUT.uv = float2(i % 2, (int)i / 2);
                triStream.Append(OUT);
                }
                triStream.RestartStrip();
            }

            // geom-Funktion
            [maxvertexcount(24)]
            void geom(point v2g IN[1], inout TriangleStream<g2f> triStream)
            {
                float3 lightPosition = _WorldSpaceLightPos0;

                float3 perpendicularAngle = float3(0,0,1);
                float3 faceNormal = cross(perpendicularAngle, IN[0].norm); // normal of gras

                float3 v0 = IN[0].pos.xyz; // Tip of the gras
                float3 v1 = IN[0].pos.xyz + IN[0].norm * _GrassHeight; // base of the gras
                float3 v2 = IN[0].pos.xyz + IN[0].norm * _GrassHeight / 2; // middle part (?)

                float3 wind = float3(sin(_Time.x * _WindSpeed + v0.x) + sin(_Time.x * _WindSpeed + v0.z * 2), 0, cos(_Time.x * _WindSpeed + v0.x * 2) + cos(_Time.x * _WindSpeed + v0.z)); // Anzahl oder Stärke der Manipulation an den Eckpunkten 
                // (_Time.x + v0.x + v0.z looks "random", because it's using time + coordinates)

                v1 += wind * _WindStrength;
                v2 += (wind * _WindStrength / 2) / 2;

                float3 color = (IN[0].color); // color of the gras

                float sin30 = 0.5;
                float sin60 = 0.866f;
                float cos30 = sin60;
                float cos60 = sin30;

                g2f OUT;

                // Quad 1 - the following code could fit in one function (BUT!) it did not work on MacOSX, that's why it's still calculated the long way

            OUT.pos = UnityObjectToClipPos(v0 + perpendicularAngle * 0.5 * _GrassHeight);
            TRANSFER_SHADOW(OUT)
            OUT.norm = faceNormal;
            OUT.diffuseColor = color;
            OUT.uv = float2(1, 0);
            triStream.Append(OUT);


            OUT.pos = UnityObjectToClipPos(v1 + perpendicularAngle * 0.5 * _GrassHeight);
            TRANSFER_SHADOW(OUT)
            OUT.norm = faceNormal;
            OUT.diffuseColor = color;
            OUT.uv = float2(1, 1);
            triStream.Append(OUT);

            OUT.pos = UnityObjectToClipPos(v0);
            TRANSFER_SHADOW(OUT)
            OUT.norm = faceNormal;
            OUT.diffuseColor = color;
            OUT.uv = float2(0.5, 0);
            triStream.Append(OUT);

            OUT.pos = UnityObjectToClipPos(v1);
            TRANSFER_SHADOW(OUT)
            OUT.norm = faceNormal;
            OUT.diffuseColor = color;
            OUT.uv = float2(0.5, 1);
            triStream.Append(OUT);

            OUT.pos = UnityObjectToClipPos(v1 - perpendicularAngle * 0.5 * _GrassHeight);
            TRANSFER_SHADOW(OUT)
            OUT.norm = faceNormal;
            OUT.diffuseColor = color;
            OUT.uv = float2(0, 1);
            triStream.Append(OUT);

            OUT.pos = UnityObjectToClipPos(v0 - perpendicularAngle * 0.5 * _GrassHeight);
            TRANSFER_SHADOW(OUT)
            OUT.norm = faceNormal;
            OUT.diffuseColor = color;
            OUT.uv = float2(0, 0);
            triStream.Append(OUT);

            OUT.pos = UnityObjectToClipPos(v0);
            TRANSFER_SHADOW(OUT)
            OUT.norm = faceNormal;
            OUT.diffuseColor = color;
            OUT.uv = float2(0.5, 0);
            triStream.Append(OUT);

            OUT.pos = UnityObjectToClipPos(v1);
            TRANSFER_SHADOW(OUT)
            OUT.norm = faceNormal;
            OUT.diffuseColor = color;
            OUT.uv = float2(0.5, 1);
            triStream.Append(OUT);

            // Quad 2

            OUT.pos = UnityObjectToClipPos(v0 + float3(sin60, 0, -cos60) * 0.5 * _GrassHeight);
            TRANSFER_SHADOW(OUT)
            OUT.norm = faceNormal;
            OUT.diffuseColor = color;
            OUT.uv = float2(1, 0);
            triStream.Append(OUT);

            OUT.pos = UnityObjectToClipPos(v1 + float3(sin60, 0, -cos60) * 0.5 * _GrassHeight);
            TRANSFER_SHADOW(OUT)
            OUT.norm = faceNormal;
            OUT.diffuseColor = color;
            OUT.uv = float2(1, 1);
            triStream.Append(OUT);

            OUT.pos = UnityObjectToClipPos(v0);
            TRANSFER_SHADOW(OUT)
            OUT.norm = faceNormal;
            OUT.diffuseColor = color;
            OUT.uv = float2(0.5, 0);
            triStream.Append(OUT);

            OUT.pos = UnityObjectToClipPos(v1);
            TRANSFER_SHADOW(OUT)
            OUT.norm = faceNormal;
            OUT.diffuseColor = color;
            OUT.uv = float2(0.5, 1);
            triStream.Append(OUT);

            OUT.pos = UnityObjectToClipPos(v0 - float3(sin60, 0, -cos60) * 0.5 * _GrassHeight);
            TRANSFER_SHADOW(OUT)
            OUT.norm = faceNormal;
            OUT.diffuseColor = color;
            OUT.uv = float2(0, 0);
            triStream.Append(OUT);

            OUT.pos = UnityObjectToClipPos(v1 - float3(sin60, 0, -cos60) * 0.5 * _GrassHeight);
            TRANSFER_SHADOW(OUT)
            OUT.norm = faceNormal;
            OUT.diffuseColor = color;
            OUT.uv = float2(0, 1);
            triStream.Append(OUT);

            OUT.pos = UnityObjectToClipPos(v0);
            TRANSFER_SHADOW(OUT)
            OUT.norm = faceNormal;
            OUT.diffuseColor = color;
            OUT.uv = float2(0.5, 0);
            triStream.Append(OUT);

            OUT.pos = UnityObjectToClipPos(v1);
            TRANSFER_SHADOW(OUT)
            OUT.norm = faceNormal;
            OUT.diffuseColor = color;
            OUT.uv = float2(0.5, 1);
            triStream.Append(OUT);

            // Quad 3 - Positive

            OUT.pos = UnityObjectToClipPos(v0 + float3(sin60, 0, cos60) * 0.5 * _GrassHeight);
            TRANSFER_SHADOW(OUT)
            OUT.norm = faceNormal;
            OUT.diffuseColor = color;
            OUT.uv = float2(1, 0);
            triStream.Append(OUT);

            OUT.pos = UnityObjectToClipPos(v1 + float3(sin60, 0, cos60) * 0.5 * _GrassHeight);
            TRANSFER_SHADOW(OUT)
            OUT.norm = faceNormal;
            OUT.diffuseColor = color;
            OUT.uv = float2(1, 1);
            triStream.Append(OUT);

            OUT.pos = UnityObjectToClipPos(v0);
            TRANSFER_SHADOW(OUT)
            OUT.norm = faceNormal;
            OUT.diffuseColor = color;
            OUT.uv = float2(0.5, 0);
            triStream.Append(OUT);

            OUT.pos = UnityObjectToClipPos(v1);
            TRANSFER_SHADOW(OUT)
            OUT.norm = faceNormal;
            OUT.diffuseColor = color;
            OUT.uv = float2(0.5, 1);
            triStream.Append(OUT);

            OUT.pos = UnityObjectToClipPos(v0 - float3(sin60, 0, cos60) * 0.5 * _GrassHeight);
            TRANSFER_SHADOW(OUT)
            OUT.norm = faceNormal;
            OUT.diffuseColor = color;
            OUT.uv = float2(0, 0);
            triStream.Append(OUT);

            OUT.pos = UnityObjectToClipPos(v1 - float3(sin60, 0, cos60) * 0.5 * _GrassHeight);
            TRANSFER_SHADOW(OUT)
            OUT.norm = faceNormal;
            OUT.diffuseColor = color;
            OUT.uv = float2(0, 1);
            triStream.Append(OUT);

            OUT.pos = UnityObjectToClipPos(v0);
            TRANSFER_SHADOW(OUT)
            OUT.norm = faceNormal;
            OUT.diffuseColor = color;
            OUT.uv = float2(0.5, 0);
            triStream.Append(OUT);

            OUT.pos = UnityObjectToClipPos(v1);
            TRANSFER_SHADOW(OUT)
            OUT.norm = faceNormal;
            OUT.diffuseColor = color;
            OUT.uv = float2(0.5, 1);
            triStream.Append(OUT);

            }

            // Fragment-Shader by Battlemaze.com --> gets input v2g and renders it on screen
            //
            // Fragment phase
            //

            #if defined(PASS_CUBE_SHADOWCASTER)

            // Cube map shadow caster pass
            half4 Fragment(Varyings input) : SV_Target
            {
                float depth = length(input.shadow) + unity_LightShadowBias.x;
                return UnityEncodeCubeShadowDepth(depth * _LightPositionRange.w);
            }

            #elif defined(UNITY_PASS_SHADOWCASTER)

            // Default shadow caster pass
            half4 Fragment(Varyings input) : SV_Target {
                fixed4 c = tex2D(_MainTex, input.texcoord);
                clip(c.a - _Cutoff);
                return 0; 
            }
            

            #else

            half4 frag(g2f IN) : COLOR
            {
                half shadow = SHADOW_ATTENUATION(IN);
                fixed4 c = tex2D(_MainTex, IN.uv);
                clip(c.a - _Cutoff);
                return c * shadow;
                //return float4 (IN.diffuseColor.rgb, 1.0);
            }

            #endif
            

            ENDCG
            }
            
        }
    
}

