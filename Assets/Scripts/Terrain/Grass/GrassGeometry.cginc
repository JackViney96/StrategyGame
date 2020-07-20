
#include "UnityCG.cginc"
#include "UnityGBuffer.cginc"
#include "UnityStandardUtils.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

//#define PCT_GBUF

struct FragmentOutput
{
#if defined(PCT_GBUF)
        float4 gBuffer0 : SV_Target0;
        float4 gBuffer1 : SV_Target1;
        float4 gBuffer2 : SV_Target2;
        float4 gBuffer3 : SV_Target3;
#else
    float4 color : SV_Target;
#endif
};

// vertex to geo (v2g)
struct v2g
{
    
    #if defined(UNITY_PASS_SHADOWCASTER)
        float4  pos : SV_POSITION;
        float3  norm : NORMAL;
        float4 tangent : TANGENT;
        float2  uv : TEXCOORD0;
        float3 color : TEXCOORD1;
    #else
        float4 pos : SV_POSITION;
        float3 norm : NORMAL;
        float4 tangent : TANGENT;
        float2 uv : TEXCOORD0;
        float3 color : TEXCOORD1;
        //LIGHTING_COORDS(2, 3)
#endif
};

//geo to fragments (g2f)
struct g2f
{
    
    
    float4  pos : SV_POSITION;
    
    #if defined(PASS_CUBE_SHADOWCASTER)
    // Cube map shadow caster pass
    float3 shadow : TEXCOORD0;


    #elif defined(UNITY_PASS_SHADOWCASTER)
    // Default shadow caster pass
    float2 uv : TEXCOORD0;
    #else
    float3  norm : NORMAL;
    float2  uv : TEXCOORD0;
    LIGHTING_COORDS(2, 3)
    //float3 diffuseColor : COLOR;
    //float4 tspace0 : TEXCOORD1;
    //float4 tspace1 : TEXCOORD2;
    //float4 tspace2 : TEXCOORD3;
    //float3 ambient : TEXCOORD4;
    //SHADOW_COORDS(5)
    
#endif
    
};

sampler2D _MainTex;
sampler2D _BumpMap;
sampler2D _OcclusionMap;

half _BumpScale;

half _OcclusionStrength;

half _Glossiness;
half _Metallic;
fixed4 _BackgroundColor;
fixed4 _ForegroundColor;
half _GrassHeight;
half _GrassWidth;
half _Cutoff;
half _WindStrength;
half _WindSpeed;

float4 _DiffuseTint;

float3 rotateVector(float3 vec, float ang)
{
    return float3(vec.x * cos(ang) - vec.z * sin(ang), 0, vec.x * sin(ang) + vec.z * cos(ang));
}

float random(in float2 st)
{
    return frac(sin(dot(st.xy,
                         float2(12.9898, 78.233)))
                 * 43758.5453123);
}

// 2D Noise based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float noise(in float2 st)
{
    float2 i = floor(st);
    float2 f = frac(st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + float2(1.0, 0.0));
    float c = random(i + float2(0.0, 1.0));
    float d = random(i + float2(1.0, 1.0));

    // Smooth Interpolation

    // Cubic Hermine Curve.  Same as SmoothStep()
    float2 u = f * f * (3.0 - 2.0 * f);
    // u = smoothstep(0.,1.,f);

    // Mix 4 coorners percentages
    return lerp(a, b, u.x) +
            (c - a) * u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

// Vertex-Shader from Battlemaze.com
v2g vert(appdata_full v)
{
    float3 v0 = mul(unity_ObjectToWorld, v.vertex).xyz;
    
    v2g OUT;
    OUT.pos = v.vertex;
    OUT.norm = v.normal;
    OUT.tangent = v.tangent;
    OUT.uv = v.texcoord;
    OUT.color = tex2Dlod(_MainTex, v.texcoord).rgb;
    #if defined(UNITY_PASS_SHADOWCASTER)
    return OUT;
    #else
    //TRANSFER_SHADOW(OUT) 
    //TRANSFER_VERTEX_TO_FRAGMENT(OUT)
    #endif
    return OUT;
}

g2f VertexOutput(float4 wpos, half3 wnrm, half4 wtan, float2 uv)
{
    g2f o;

//#if defined(PASS_CUBE_SHADOWCASTER)
//    // Cube map shadow caster pass: Transfer the shadow vector.
//    o.position = UnityWorldToClipPos(float4(wpos, 1));
//    o.shadow = wpos - _LightPositionRange.xyz;

#if defined(UNITY_PASS_SHADOWCASTER)
    // Default shadow caster pass: Apply the shadow bias.
    float scos = dot(wnrm, normalize(UnityWorldSpaceLightDir(wpos)));
    //wpos -= wnrm * unity_LightShadowBias.z * sqrt(1 - scos * scos);
    o.pos = UnityApplyLinearShadowBias(wpos);
    o.uv = uv;

#else
    // GBuffer construction pass
    half3 bi = cross(wnrm, wtan) * wtan.w * unity_WorldTransformParams.w;
    //o.pos = UnityWorldToClipPos(float4(wpos, 1)); 
    o.pos = wpos;
    //TRANSFER_VERTEX_TO_FRAGMENT(o);
    
    o.norm = wnrm;
    o.uv = uv;
    //o.diffuseColor = _Time;
    //o.tspace0 = float4(wtan.x, bi.x, wnrm.x, wpos.x);
    //o.tspace1 = float4(wtan.y, bi.y, wnrm.y, wpos.y);
    //o.tspace2 = float4(wtan.z, bi.z, wnrm.z, wpos.z);
    //o.ambient = ShadeSHPerVertex(wnrm, 0);
    TRANSFER_VERTEX_TO_FRAGMENT(o)

#endif
    return o;
}

// geom-Funktion
[maxvertexcount(24)]
void geom(point v2g IN[1], inout TriangleStream<g2f> triStream)
{
    float3 lightPosition = _WorldSpaceLightPos0;

    float3 perpendicularAngle = float3(1, 1, 1);
    perpendicularAngle = rotateVector(perpendicularAngle, ((noise(IN[0].pos.xz).x/* + noise(IN[0].pos.xz).z*/) * 360) * (3.14159 / 180));
    float3 faceNormal = cross(perpendicularAngle, IN[0].norm); // normal of gras
    
    half4 wtan = IN[0].tangent;
    
    _GrassHeight = noise(IN[0].pos.xz) * 1.125;

    float3 v0 = IN[0].pos.xyz; // Tip of the gras
    float3 v1 = IN[0].pos.xyz + IN[0].norm * _GrassHeight ; // base of the gras
    //float3 v2 = IN[0].pos.xyz + IN[0].norm * _GrassHeight / 2; // middle part (?)

    float3 wind = float3(sin(_Time.x * _WindSpeed + v0.x) + sin(_Time.x * _WindSpeed + v0.z * 2), 0, cos(_Time.x * _WindSpeed + v0.x * 2) + cos(_Time.x * _WindSpeed + v0.z)); // Anzahl oder Stärke der Manipulation an den Eckpunkten 
    // (_Time.x + v0.x + v0.z looks "random", because it's using time + coordinates)

    v1 += wind * _WindStrength;
    //v2 += (wind * _WindStrength / 2) / 2;

    float3 color = (IN[0].color); // color of the gras

    float sin30 = 0.5;
    float sin60 = 0.866f;
    float cos30 = sin60;
    float cos60 = sin30;

    g2f OUT;

    // Quad 1
    triStream.Append(VertexOutput(UnityObjectToClipPos(v0 + perpendicularAngle * 0.5 * _GrassHeight), faceNormal, wtan, float2(1, 0)));

    triStream.Append(VertexOutput(UnityObjectToClipPos(v1 + perpendicularAngle * 0.5 * _GrassHeight), faceNormal, wtan, float2(1, 1)));

    triStream.Append(VertexOutput(UnityObjectToClipPos(v0 + perpendicularAngle * -0.5), faceNormal, wtan, float2(0, 0)));

    triStream.Append(VertexOutput(UnityObjectToClipPos(v1 + perpendicularAngle * -0.5), faceNormal, wtan, float2(0, 1)));

    // Quad 2
    triStream.Append(VertexOutput(UnityObjectToClipPos(v0 + float3(sin60, 0, -cos60) * 0.5 * _GrassHeight), faceNormal, wtan, float2(1, 0)));

    triStream.Append(VertexOutput(UnityObjectToClipPos(v1 + float3(sin60, 0, -cos60) * 0.5 * _GrassHeight), faceNormal, wtan, float2(1, 1)));

    triStream.Append(VertexOutput(UnityObjectToClipPos(v0 + float3(sin60, 0, -cos60) * -0.5), faceNormal, wtan, float2(0, 0)));

    triStream.Append(VertexOutput(UnityObjectToClipPos(v1 + float3(sin60, 0, -cos60) * -0.5), faceNormal, wtan, float2(0, 1)));
    
    //// Quad 3
    triStream.Append(VertexOutput(UnityObjectToClipPos(v0 + float3(sin60, 0, cos60) * 0.5 * _GrassHeight), faceNormal, wtan, float2(1, 0)));

    triStream.Append(VertexOutput(UnityObjectToClipPos(v1 + float3(sin60, 0, cos60) * 0.5 * _GrassHeight), faceNormal, wtan, float2(1, 1)));

    triStream.Append(VertexOutput(UnityObjectToClipPos(v0 + float3(sin60, 0, cos60) * -0.5), faceNormal, wtan, float2(0, 0)));

    triStream.Append(VertexOutput(UnityObjectToClipPos(v1 + float3(sin60, 0, cos60) * -0.5), faceNormal, wtan, float2(0, 1)));
    

    
}

// Fragment-Shader by Battlemaze.com --> gets input v2g and renders it on screen
//
// Fragment phase
//
#if defined(UNITY_PASS_SHADOWCASTER)

// Default shadow caster pass
half4 Fragment(g2f input) : SV_Target{
    fixed4 c = tex2D(_MainTex, input.uv);
    clip(c.a - _Cutoff);
    return 0;
}

#elif defined(PCT_GBUF)
FragmentOutput Fragment(g2f i)
{
    FragmentOutput output;
#if defined(PCT_GBUF)
    output.gBuffer0.rgb = i.diffuseColor;
    //output.gBuffer0.a = GetOcclusion(i);
#else
    output.color = color;
#endif
    return output;
}

#else
fixed4 Fragment(g2f input) : SV_Target
{
    fixed4 c = tex2D(_MainTex, input.uv);
    float attenuation = SHADOW_ATTENUATION(input);
    float4 ambient = UNITY_LIGHTMODEL_AMBIENT;
    clip(c.a - _Cutoff);
    //using the UV for super cheap fake AO
    return c * (input.uv.y + 0.25f) * (attenuation + ambient);
    //return c * (input.uv.y + 0.25f);
    //fixed4 shadow = SHADOW_ATTENUATION(input);
    //return c - shadow;
    //return c;
}
#endif


