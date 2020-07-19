
#include "UnityCG.cginc"
#include "UnityGBuffer.cginc"
#include "UnityStandardUtils.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

#define PCT_GBUF

// vertex to graphics (v2g)
struct v2g
{
    float4  pos : SV_POSITION;
    float3  norm : NORMAL;
    float4 tangent : TANGENT;
    float2  uv : TEXCOORD0;
    float3 color : TEXCOORD1;
};

//graphics to fragments (g2f)
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
    float3 diffuseColor : COLOR;
    float4 tspace0 : TEXCOORD1;
    float4 tspace1 : TEXCOORD2;
    float4 tspace2 : TEXCOORD3;
    float3 ambient : TEXCOORD4;
    SHADOW_COORDS(5)
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
    TRANSFER_SHADOW(o);
    o.norm = wnrm;
    o.uv = uv;
    o.diffuseColor = float3(1,1,1);
    o.tspace0 = float4(wtan.x, bi.x, wnrm.x, wpos.x);
    o.tspace1 = float4(wtan.y, bi.y, wnrm.y, wpos.y);
    o.tspace2 = float4(wtan.z, bi.z, wnrm.z, wpos.z);
    o.ambient = ShadeSHPerVertex(wnrm, 0);
    

#endif
    return o;
}

// geom-Funktion
[maxvertexcount(24)]
void geom(point v2g IN[1], inout TriangleStream<g2f> triStream)
{
    float3 lightPosition = _WorldSpaceLightPos0;

    float3 perpendicularAngle = float3(0, 0, 1);
    float3 faceNormal = cross(perpendicularAngle, IN[0].norm); // normal of gras
    
    half4 wtan = IN[0].tangent;

    float3 v0 = IN[0].pos.xyz; // Tip of the gras
    float3 v1 = IN[0].pos.xyz + IN[0].norm * _GrassHeight; // base of the gras
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

    // Quad 1 - the following code could fit in one function (BUT!) it did not work on MacOSX, that's why it's still calculated the long way
    triStream.Append(VertexOutput(UnityObjectToClipPos(v0 + perpendicularAngle * 0.5 * _GrassHeight), faceNormal, wtan, float2(1, 0)));

    triStream.Append(VertexOutput(UnityObjectToClipPos(v1 + perpendicularAngle * 0.5 * _GrassHeight), faceNormal, wtan, float2(1, 1)));

    triStream.Append(VertexOutput(UnityObjectToClipPos(v0 + perpendicularAngle * -0.5), faceNormal, wtan, float2(0, 0)));

    triStream.Append(VertexOutput(UnityObjectToClipPos(v1 + perpendicularAngle * -0.5), faceNormal, wtan, float2(0, 1)));

    //triStream.Append(VertexOutput(UnityObjectToClipPos(v1 - perpendicularAngle * 0.5 * _GrassHeight), faceNormal, wtan, float2(0, 1)));
    
    //triStream.Append(VertexOutput(UnityObjectToClipPos(v0 - perpendicularAngle * 0.5 * _GrassHeight), faceNormal, wtan, float2(0, 0)));

    //triStream.Append(VertexOutput(UnityObjectToClipPos(v0), faceNormal, wtan, float2(0.5, 0)));

    //triStream.Append(VertexOutput(UnityObjectToClipPos(v1), faceNormal, wtan, float2(0.5, 1)));


    // Quad 2

    //triStream.Append(VertexOutput(UnityObjectToClipPos(v0 + float3(sin60, 0, -cos60) * 0.5 * _GrassHeight), faceNormal, wtan, float2(1, 0)));

    //triStream.Append(VertexOutput(UnityObjectToClipPos(v1 + float3(sin60, 0, -cos60) * _GrassHeight), faceNormal, wtan, float2(1, 1)));

    //triStream.Append(VertexOutput(UnityObjectToClipPos(v0), faceNormal, wtan, float2(0.5, 0)));

    //triStream.Append(VertexOutput(UnityObjectToClipPos(v1), faceNormal, wtan, float2(0.5, 1)));

    //triStream.Append(VertexOutput(UnityObjectToClipPos(v1 - float3(sin60, 0, -cos60) * 0.5 * _GrassHeight), faceNormal, wtan, float2(0, 1)));
    
    //triStream.Append(VertexOutput(UnityObjectToClipPos(v0 - float3(sin60, 0, -cos60) * 0.5 * _GrassHeight), faceNormal, wtan, float2(0, 0)));

    //triStream.Append(VertexOutput(UnityObjectToClipPos(v0), faceNormal, wtan, float2(0.5, 0)));

    //triStream.Append(VertexOutput(UnityObjectToClipPos(v1), faceNormal, wtan, float2(0.5, 1)));
    
    ////Quad 3
    //triStream.Append(VertexOutput(UnityObjectToClipPos(v0 + float3(sin60, 0, cos60) * 0.5 * _GrassHeight), faceNormal, wtan, float2(1, 0)));

    //triStream.Append(VertexOutput(UnityObjectToClipPos(v1 + float3(sin60, 0, cos60) * _GrassHeight), faceNormal, wtan, float2(1, 1)));

    //triStream.Append(VertexOutput(UnityObjectToClipPos(v0), faceNormal, wtan, float2(0.5, 0)));

    //triStream.Append(VertexOutput(UnityObjectToClipPos(v1), faceNormal, wtan, float2(0.5, 1)));

    //triStream.Append(VertexOutput(UnityObjectToClipPos(v1 - float3(sin60, 0, cos60) * 0.5 * _GrassHeight), faceNormal, wtan, float2(0, 1)));
    
    //triStream.Append(VertexOutput(UnityObjectToClipPos(v0 - float3(sin60, 0, cos60) * 0.5 * _GrassHeight), faceNormal, wtan, float2(0, 0)));

    //triStream.Append(VertexOutput(UnityObjectToClipPos(v0), faceNormal, wtan, float2(0.5, 0)));

    //triStream.Append(VertexOutput(UnityObjectToClipPos(v1), faceNormal, wtan, float2(0.5, 1)));
    
    //OUT.pos = UnityObjectToClipPos(v0 + float3(sin60, 0, -cos60) * 0.5 * _GrassHeight);
    ////TRANSFER_SHADOW(OUT)
    //    OUT.norm = faceNormal;
    //OUT.diffuseColor = color;
    //OUT.uv = float2(1, 0);
    //OUT.ambient = ShadeSHPerVertex(faceNormal, 0);
    //triStream.Append(OUT);

    //OUT.pos = UnityObjectToClipPos(v1 + float3(sin60, 0, -cos60) * 0.5 * _GrassHeight);
    ////TRANSFER_SHADOW(OUT)
    //    OUT.norm = faceNormal;
    //OUT.diffuseColor = color;
    //OUT.uv = float2(1, 1);
    //OUT.ambient = ShadeSHPerVertex(faceNormal, 0);
    //triStream.Append(OUT);

    //OUT.pos = UnityObjectToClipPos(v0);
    ////TRANSFER_SHADOW(OUT)
    //    OUT.norm = faceNormal;
    //OUT.diffuseColor = color;
    //OUT.uv = float2(0.5, 0);
    //OUT.ambient = ShadeSHPerVertex(faceNormal, 0);
    //triStream.Append(OUT);

    //OUT.pos = UnityObjectToClipPos(v1);
    ////TRANSFER_SHADOW(OUT)
    //    OUT.norm = faceNormal;
    //OUT.diffuseColor = color;
    //OUT.uv = float2(0.5, 1);
    //OUT.ambient = ShadeSHPerVertex(faceNormal, 0);
    //triStream.Append(OUT);

    //OUT.pos = UnityObjectToClipPos(v0 - float3(sin60, 0, -cos60) * 0.5 * _GrassHeight);
    ////TRANSFER_SHADOW(OUT)
    //    OUT.norm = faceNormal;
    //OUT.diffuseColor = color;
    //OUT.uv = float2(0, 0);
    //OUT.ambient = ShadeSHPerVertex(faceNormal, 0);
    //triStream.Append(OUT);

    //OUT.pos = UnityObjectToClipPos(v1 - float3(sin60, 0, -cos60) * 0.5 * _GrassHeight);
    ////TRANSFER_SHADOW(OUT)
    //    OUT.norm = faceNormal;
    //OUT.diffuseColor = color;
    //OUT.uv = float2(0, 1);
    //OUT.ambient = ShadeSHPerVertex(faceNormal, 0);
    //triStream.Append(OUT);

    //OUT.pos = UnityObjectToClipPos(v0);
    ////TRANSFER_SHADOW(OUT)
    //    OUT.norm = faceNormal;
    //OUT.diffuseColor = color;
    //OUT.uv = float2(0.5, 0);
    //OUT.ambient = ShadeSHPerVertex(faceNormal, 0);
    //triStream.Append(OUT);

    //OUT.pos = UnityObjectToClipPos(v1);
    ////TRANSFER_SHADOW(OUT)
    //    OUT.norm = faceNormal;
    //OUT.diffuseColor = color;
    //OUT.uv = float2(0.5, 1);
    //OUT.ambient = ShadeSHPerVertex(faceNormal, 0);
    //triStream.Append(OUT);

    //// Quad 3 - Positive
    
    //OUT.pos = UnityObjectToClipPos(v0 + float3(sin60, 0, cos60) * 0.5 * _GrassHeight);
    ////TRANSFER_SHADOW(OUT)
    //OUT.norm =
    //faceNormal;
    //OUT.diffuseColor = color;
    //OUT.uv = float2(1, 0);
    //OUT.ambient = ShadeSHPerVertex(faceNormal, 0);
    //triStream.Append(OUT);

    //OUT.pos = UnityObjectToClipPos(v1 + float3(sin60, 0, cos60) * 0.5 * _GrassHeight);
    ////TRANSFER_SHADOW(OUT)
    //OUT.norm = faceNormal;
    //OUT.diffuseColor = color;
    //OUT.uv = float2(1, 1);
    //OUT.ambient = ShadeSHPerVertex(faceNormal, 0);
    //triStream.Append(OUT);

    //OUT.pos = UnityObjectToClipPos(v0);
    ////TRANSFER_SHADOW(OUT)
    //OUT.norm = faceNormal;
    //OUT.diffuseColor = color;
    //OUT.uv = float2(0.5, 0);
    //OUT.ambient = ShadeSHPerVertex(faceNormal, 0);
    //triStream.Append(OUT);

    //OUT.pos = UnityObjectToClipPos(v1);
    ////TRANSFER_SHADOW(OUT)
    //OUT.norm = faceNormal;
    //OUT.diffuseColor = color;
    //OUT.uv = float2(0.5, 1);
    //OUT.ambient = ShadeSHPerVertex(faceNormal, 0);
    //triStream.Append(OUT);

    //OUT.pos = UnityObjectToClipPos(v0 - float3(sin60, 0, cos60) * 0.5 * _GrassHeight);
    ////TRANSFER_SHADOW(OUT)
    //OUT.norm = faceNormal;
    //OUT.diffuseColor = color;
    //OUT.uv = float2(0, 0);
    //OUT.ambient = ShadeSHPerVertex(faceNormal, 0);
    //triStream.Append(OUT);

    //OUT.pos = UnityObjectToClipPos(v1 - float3(sin60, 0, cos60) * 0.5 * _GrassHeight);
    ////TRANSFER_SHADOW(OUT)
    //OUT.norm = faceNormal;
    //OUT.diffuseColor = color;
    //OUT.uv = float2(0, 1);
    //OUT.ambient = ShadeSHPerVertex(faceNormal, 0);
    //triStream.Append(OUT);

    //OUT.pos = UnityObjectToClipPos(v0);
    ////TRANSFER_SHADOW(OUT)
    //OUT.norm = faceNormal;
    //OUT.diffuseColor = color;
    //OUT.uv = float2(0.5, 0);
    //OUT.ambient = ShadeSHPerVertex(faceNormal, 0);
    //triStream.Append(OUT);

    //OUT.pos = UnityObjectToClipPos(v1);
    ////TRANSFER_SHADOW(OUT)
    //OUT.norm = faceNormal;
    //OUT.diffuseColor = color;
    //OUT.uv = float2(0.5, 1);
    //OUT.ambient = ShadeSHPerVertex(faceNormal, 0);
    //triStream.Append(OUT);

    
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
void Fragment(
    g2f input,
    out half4 outGBuffer0 : SV_Target0,
    out half4 outGBuffer1 : SV_Target1,
    out half4 outGBuffer2 : SV_Target2,
    out half4 outEmission : SV_Target3
)
{
    // Sample textures
    fixed4 c = tex2D(_MainTex, input.uv);
    clip(c.a - _Cutoff);

    half4 normal = tex2D(_BumpMap, input.uv);
    normal.xyz = UnpackScaleNormal(normal, _BumpScale);

    half occ = tex2D(_OcclusionMap, input.uv).g;
    occ = LerpOneTo(occ, _OcclusionStrength);

    // PBS workflow conversion (metallic -> specular)
    half3 c_diff, c_spec;
    half refl10;
    c_diff = DiffuseAndSpecularFromMetallic(
        c, _Metallic, // input
        c_spec, refl10     // output
    );

    // Tangent space conversion (tangent space normal -> world space normal)
   float3 wn = normalize(float3(
        dot(input.tspace0.xyz, normal),
        dot(input.tspace1.xyz, normal),
        dot(input.tspace2.xyz, normal)
        ));
    fixed4 shadow = SHADOW_ATTENUATION(input);
    // Update the GBuffer.
    UnityStandardData data;
    data.diffuseColor = c_diff;
    data.occlusion = occ;
    data.specularColor = c_spec;
    data.smoothness = _Glossiness;
    data.normalWorld = wn;
    //data.normalWorld = normal;
    UnityStandardDataToGbuffer(data, outGBuffer0, outGBuffer1, outGBuffer2);

    // Calculate ambient lighting and output to the emission buffer.
    //float3 wp = float3(input.tspace0.w, input.tspace1.w, input.tspace2.w);
    float3 wp = input.pos;
    half3 sh = ShadeSHPerPixel(data.normalWorld, input.ambient, wp);
    //half3 sh = ShadeSHPerPixel(data.normalWorld, 1, input.pos);
    outEmission = half4(sh * c_diff, 1) * occ * shadow;
    //outEmission = half4(sh * c_diff, 1);
    //outEmission = shadow;

}
#else
fixed4 Fragment(g2f input) : SV_Target
{
    fixed4 c = tex2D(_MainTex, input.uv);
    return c;
}
#endif


