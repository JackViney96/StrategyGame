#include "UnityCG.cginc"
#include "UnityGBuffer.cginc"
#include "UnityStandardUtils.cginc"

sampler2D _MainTex;
sampler2D _NormalMap;
sampler2D _OcclusionMap;

half _NormalScale;

half _OcclusionStrength;

half _Glossiness;
half _Metallic;
half _Cutoff;

struct v2f {
    float4 vertex   : SV_POSITION;
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

    #endif

};

struct MeshProperties {
    float4x4 mat;
    float4 color;
};

StructuredBuffer<MeshProperties> _Properties;

v2f vert(appdata_full i, uint instanceID: SV_InstanceID) {
    v2f o;

    float4 pos = mul(_Properties[instanceID].mat, i.vertex);
         

    o.vertex = UnityObjectToClipPos(pos);
    //o.color = _Properties[instanceID].color;
    o.uv = i.texcoord;
    

    #if defined(UNITY_PASS_SHADOWCASTER)
    // Default shadow caster pass: Apply the shadow bias.
    float3 nrm = UnityObjectToWorldNormal(i.normal);
    float scos = dot(nrm, normalize(UnityWorldSpaceLightDir(pos)));
    pos -= (nrm * unity_LightShadowBias.z * sqrt(1 - scos * scos), 0);
    o.vertex = UnityApplyLinearShadowBias(pos);
    #else       
    o.norm = UnityObjectToWorldNormal(i.normal);
    half3 bi = cross(o.norm, i.tangent) * i.tangent.w * unity_WorldTransformParams.w;
    o.tspace0 = float4(i.tangent.x, bi.x, o.norm.x, o.vertex.x);
    o.tspace1 = float4(i.tangent.y, bi.y, o.norm.y, o.vertex.y);
    o.tspace2 = float4(i.tangent.z, bi.z, o.norm.z, o.vertex.z);

    o.ambient = ShadeSHPerVertex(o.norm, 0);
    
    #endif

    return o;
}

#if defined(UNITY_PASS_SHADOWCASTER)

// Default shadow caster pass
half4 frag(v2f input) : SV_Target{
    fixed4 c = tex2D(_MainTex, input.uv);
    clip(c.a - _Cutoff);
    return 0;
}

#else

void frag(
        v2f input,
        out half4 outGBuffer0 : SV_Target0,
        out half4 outGBuffer1 : SV_Target1,
        out half4 outGBuffer2 : SV_Target2,
        out half4 outEmission : SV_Target3
        )
    {
    // Sample textures
    fixed4 c = tex2D(_MainTex, input.uv);
    clip(c.a - _Cutoff);
    c.a = 1;

    //half3 _amb = input.ambient;

    half4 normal = tex2D(_NormalMap, input.uv);
    //input.normal;
    normal.xyz = UnpackScaleNormal(normal, _NormalScale);

    half occ = tex2D(_OcclusionMap, input.uv).g;
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


    UnityStandardData data;
    data.diffuseColor = c_diff;
    data.occlusion = occ;
    data.specularColor = c_spec;
    data.smoothness = _Glossiness;
    data.normalWorld = wn;

    UnityStandardDataToGbuffer(data, outGBuffer0, outGBuffer1, outGBuffer2);

    float3 wp = float3(input.tspace0.w, input.tspace1.w, input.tspace2.w);
    half3 sh = ShadeSHPerPixel(data.normalWorld, input.ambient, wp);
    outEmission = half4(sh * c_diff, 0) * occ;
            
}
#endif