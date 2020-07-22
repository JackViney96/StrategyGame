
#include "UnityCG.cginc"
#include "UnityGBuffer.cginc"
#include "UnityStandardUtils.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

#define PCT_GBUF
struct Varyings
{
    float4 position : SV_POSITION;
    
    #if defined(UNITY_PASS_SHADOWCASTER)
    // Default shadow caster pass
    float2 texcoord : TEXCOORD0;

    #else
    
    float3 normal : NORMAL;
    float2 texcoord : TEXCOORD0;
    float4 tspace0 : TEXCOORD1;
    float4 tspace1 : TEXCOORD2;
    float4 tspace2 : TEXCOORD3;
    half3 ambient : TEXCOORD4;
    #endif
};

// vertex to geo (v2g)
struct v2g
{
    float4 pos : SV_POSITION;
    float3 norm : NORMAL;
    float4 tangent : TANGENT;
    float2 uv : TEXCOORD0;
    float3 color : TEXCOORD1;
};

//geo to fragments (g2f)
struct g2f
{
    
    
    float4 pos : SV_POSITION;
    
#if defined(PASS_CUBE_SHADOWCASTER)
    // Cube map shadow caster pass
    float3 shadow : TEXCOORD0;


#elif defined(UNITY_PASS_SHADOWCASTER)
    // Default shadow caster pass
    float2 uv : TEXCOORD0;
#else
    float3 norm : NORMAL;
    float2 uv : TEXCOORD0;
    float4 tspace0 : TEXCOORD1;
    float4 tspace1 : TEXCOORD2;
    float4 tspace2 : TEXCOORD3;
    float3 ambient : TEXCOORD4;
    #ifndef PCT_GBUF
    SHADOW_COORDS(5)
    #endif
    
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

#include "utility.cginc"

// Vertex-Shader from Battlemaze.com
v2g vert(appdata_full v)
{
    float3 v0 = mul(unity_ObjectToWorld, v.vertex).xyz;
    
    v2g OUT;
    OUT.pos = v.vertex; //mul(unity_ObjectToWorld, v.vertex);
    OUT.norm = v.normal;
    OUT.tangent = v.tangent;
    OUT.uv = v.texcoord;
    OUT.color = tex2Dlod(_MainTex, v.texcoord).rgb;

    return OUT;
}

Varyings VertexOutput(float4 wpos, half3 nrm, half4 wtan, float2 uv, float swap)
{
    Varyings o;
    
    #if defined(UNITY_PASS_SHADOWCASTER)
    // Default shadow caster pass: Apply the shadow bias.
    float scos = dot(nrm, normalize(UnityWorldSpaceLightDir(wpos)));
    //wpos -= wnrm * unity_LightShadowBias.z * sqrt(1 - scos * scos);
    o.position = UnityApplyLinearShadowBias(wpos);
    o.texcoord = uv;

    #else
    half3 bi = cross(nrm, wtan) * wtan.w * unity_WorldTransformParams.w;
    //o.position = UnityObjectToClipPos(wpos);
    o.position = wpos;
    o.normal = nrm;
    o.texcoord = uv;

        
    o.tspace0 = float4(wtan.x, bi.x, nrm.x, wpos.x);
    o.tspace1 = float4(wtan.y, bi.y, nrm.y, wpos.y);
    o.tspace2 = float4(wtan.z, bi.z, nrm.z, wpos.z);

    o.ambient = ShadeSHPerVertex(nrm, 0);
    
    #endif
    return o;
}

//float3 ConstructNormal(float3 v1, float3 v2, float3 v3)
//{
//    return normalize(cross(v2 - v1, v3 - v1));
//}

// geom-Funktion
[maxvertexcount(24)]
void geom(point v2g IN[1], inout TriangleStream<Varyings> triStream)
{
    //float3 lightPosition = _WorldSpaceLightPos0;

    float3 perpendicularAngle = float3(0, 0, 1);
    perpendicularAngle = rotateVector(perpendicularAngle, ((noise(IN[0].pos.xz).x/* + noise(IN[0].pos.xz).z*/) * 360) * (3.14159 / 180));
    //perpendicularAngle = -perpendicularAngle;
    float3 faceNormal = cross(perpendicularAngle, UnityObjectToWorldNormal(IN[0].norm)); // normal of gras
    
    
    
    half4 wtan = IN[0].tangent;
    
    _GrassHeight = noise(IN[0].pos.xz) * _GrassHeight;
    _GrassWidth = noise(IN[0].pos.xz) * _GrassWidth;

    float3 v0 = IN[0].pos.xyz; // Tip of the gras
    float3 v1 = IN[0].pos.xyz + IN[0].norm * _GrassHeight; // base of the gras
    float3 v2 = IN[0].pos.xyz + IN[0].norm * _GrassHeight / 2; // middle part (?)

    float3 wind = float3(sin(_Time.x * _WindSpeed + v0.x) + sin(_Time.x * _WindSpeed + v0.z * 2), 0, cos(_Time.x * _WindSpeed + v0.x * 2) + cos(_Time.x * _WindSpeed + v0.z)); // Anzahl oder St�rke der Manipulation an den Eckpunkten 
    // (_Time.x + v0.x + v0.z looks "random", because it's using time + coordinates)

    v1 += wind * _WindStrength;
    v2 += (wind * _WindStrength / 2) / 2;

    float3 color = (IN[0].color); // color of the gras

    float sin30 = 0.5;
    float sin60 = 0.866f;
    float cos30 = sin60;
    float cos60 = sin30;

    //g2f OUT;

    // Quad 1

    triStream.Append(VertexOutput(UnityObjectToClipPos(v0 + perpendicularAngle * 1 * _GrassWidth), faceNormal, wtan, float2(1, 0), 0));

    triStream.Append(VertexOutput(UnityObjectToClipPos(v1 + perpendicularAngle * 1 * _GrassWidth), faceNormal, wtan, float2(1, 1), 0));

    triStream.Append(VertexOutput(UnityObjectToClipPos(v0 + perpendicularAngle * -1), faceNormal, wtan, float2(0, 0), 0));

    triStream.Append(VertexOutput(UnityObjectToClipPos(v1 + perpendicularAngle * -1), faceNormal, wtan, float2(0, 1), 0));
  
    triStream.RestartStrip();
    

    // Quad 2, back face with swapped UV
    triStream.Append(VertexOutput(UnityObjectToClipPos(v1 + perpendicularAngle * 1 * _GrassWidth), -faceNormal, wtan, float2(1, 0), 0));

    triStream.Append(VertexOutput(UnityObjectToClipPos(v0 + perpendicularAngle * 1 * _GrassWidth), -faceNormal, wtan, float2(1, -1), 0));

    triStream.Append(VertexOutput(UnityObjectToClipPos(v1 + perpendicularAngle * -1), -faceNormal, wtan, float2(0, 0), 0));

    triStream.Append(VertexOutput(UnityObjectToClipPos(v0 + perpendicularAngle * -1), -faceNormal, wtan, float2(0, -1), 0));
    triStream.RestartStrip();
    
    //// Quad 3
    //triStream.Append(VertexOutput(UnityObjectToClipPos(v0 + float3(sin60, 0, cos60) * 0.5 * _GrassHeight), faceNormal, wtan, float2(1, 0), 0));

    //triStream.Append(VertexOutput(UnityObjectToClipPos(v1 + float3(sin60, 0, cos60) * 0.5 * _GrassHeight), faceNormal, wtan, float2(1, 1), 0));

    //triStream.Append(VertexOutput(UnityObjectToClipPos(v0 + float3(sin60, 0, cos60) * -0.5), faceNormal, wtan, float2(0, 0), 0));

    //triStream.Append(VertexOutput(UnityObjectToClipPos(v1 + float3(sin60, 0, cos60) * -0.5), faceNormal, wtan, float2(0, 1), 0));
    

    
}

// Fragment-Shader by Battlemaze.com --> gets input v2g and renders it on screen
//
// Fragment phase
//
#if defined(UNITY_PASS_SHADOWCASTER)

// Default shadow caster pass
half4 frag(Varyings input) : SV_Target{
    fixed4 c = tex2D(_MainTex, input.texcoord);
    clip(c.a - _Cutoff);
    return 0;
}

#elif defined(PCT_GBUF)
void frag(
    Varyings input,
    fixed facing : VFACE,
    out half4 outGBuffer0 : SV_Target0,
    out half4 outGBuffer1 : SV_Target1,
    out half4 outGBuffer2 : SV_Target2,
    out half4 outEmission : SV_Target3
)
{
    // Sample textures
    fixed4 c = tex2D(_MainTex, input.texcoord);
    clip(c.a - _Cutoff);
    c.a = 1;
    
    //half3 _amb = input.ambient;

    half4 normal = tex2D(_BumpMap, input.texcoord);
    //input.normal;
    normal.xyz = UnpackScaleNormal(normal, _BumpScale);

    half occ = tex2D(_OcclusionMap, input.texcoord).g;
    occ = LerpOneTo(occ, _OcclusionStrength);

    // PBS workflow conversion (metallic -> specular)
    half3 c_diff, c_spec;
    half refl10;
    c_diff = DiffuseAndSpecularFromMetallic(
        c, _Metallic, // input
        c_spec, refl10 // output
    );

    // Tangent space conversion (tangent space normal -> world space normal)
    float3 wn = normalize(float3(
        dot(input.tspace0.xyz, normal),
        dot(input.tspace1.xyz, normal),
        dot(input.tspace2.xyz, normal)
    ));

    // Update the GBuffer.
    UnityStandardData data;
    data.diffuseColor = c_diff;
    data.occlusion = occ;
    data.specularColor = c_spec;
    data.smoothness = _Glossiness;
     
    if (facing > 0)
    {
        data.normalWorld = wn;
        
        
    }
    else
    {
        data.normalWorld = -wn;
    }
    
    //data.normalWorld = wn;
    // RT0: diffuse color (rgb), occlusion (a) - sRGB rendertarget
    //outGBuffer0 = half4(data.diffuseColor, data.occlusion);

    //// RT1: spec color (rgb), smoothness (a) - sRGB rendertarget
    //outGBuffer1 = half4(data.specularColor, data.smoothness);

    // RT2: normal (rgb), --unused, very low precision-- (a)
    //outGBuffer2 = half4(data.normalWorld * 0.5f + 0.5f, 1.0f);
    //outGBuffer2 = half4(data.normalWorld, 1.0f);
    UnityStandardDataToGbuffer(data, outGBuffer0, outGBuffer1, outGBuffer2);

    // Calculate ambient lighting and output to the emission buffer.
    float3 wp = float3(input.tspace0.w, input.tspace1.w, input.tspace2.w);
    //float3 wp = -input.position;
    half3 sh = ShadeSHPerPixel(data.normalWorld, input.ambient, wp);
    outEmission = half4(sh * c_diff, 0) * occ;
}

#else
fixed4 frag(
    Varyings input,
    //out half4 outGBuffer0 : SV_Target0,
    //out half4 outGBuffer1 : SV_Target1,
    //out half4 outGBuffer2 : SV_Target2,
    out half4 outEmission : SV_Target3
) : SV_Target0
{
    fixed4 c = tex2D(_MainTex, input.texcoord);
    //oken?
    //float attenuation = SHADOW_ATTENUATION(input);
    float4 ambient = UNITY_LIGHTMODEL_AMBIENT;
    clip(c.a - _Cutoff);
    c.a = 1;
    //using the UV for super cheap fake AO
    //outEmission = c;
    //outGBuffer2 = 0; //half4(1,1,1, 1);
    outEmission = c * (input.texcoord.y + 0.25f) * ambient;
    //return c * (input.uv.y + 0.25f) * ambient;
    return c * (input.texcoord.y + 0.25f) * ambient;
    //return c * (input.uv.y + 0.25f);
    //fixed4 shadow = SHADOW_ATTENUATION(input);
    //return c - shadow;
    //return c;
}
#endif


