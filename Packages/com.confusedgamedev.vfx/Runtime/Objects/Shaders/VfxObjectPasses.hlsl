#ifndef CONFUSEDGAMEDEV_VFX_OBJECT_PASSES_INCLUDED
#define CONFUSEDGAMEDEV_VFX_OBJECT_PASSES_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

// Depth and shadow passes for rigid objects. Vegetation has its own, because wind moves its vertices.
float3 _LightDirection;
float3 _LightPosition;

struct ObjectAttributes
{
    float3 positionOS : POSITION;
    float3 normalOS : NORMAL;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct ObjectVaryings
{
    float4 positionCS : SV_POSITION;
    float3 normalWS : TEXCOORD0;
    UNITY_VERTEX_OUTPUT_STEREO
};

ObjectVaryings DepthVertex(ObjectAttributes input)
{
    ObjectVaryings output;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
    output.positionCS = TransformObjectToHClip(input.positionOS);
    output.normalWS = TransformObjectToWorldNormal(input.normalOS);
    return output;
}

float4 DepthFragment(ObjectVaryings input) : SV_Target
{
    return input.positionCS.z;
}

float4 DepthNormalsFragment(ObjectVaryings input) : SV_Target
{
    return float4(NormalizeNormalPerPixel(input.normalWS), 0.0);
}

ObjectVaryings ShadowVertex(ObjectAttributes input)
{
    ObjectVaryings output;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
    float3 positionWS = TransformObjectToWorld(input.positionOS);
    output.normalWS = TransformObjectToWorldNormal(input.normalOS);
#if _CASTING_PUNCTUAL_LIGHT_SHADOW
    float3 lightDirection = normalize(_LightPosition - positionWS);
#else
    float3 lightDirection = _LightDirection;
#endif
    output.positionCS = ApplyShadowClamping(TransformWorldToHClip(ApplyShadowBias(positionWS, output.normalWS, lightDirection)));
    return output;
}

float4 ShadowFragment(ObjectVaryings input) : SV_Target
{
    return 0.0;
}

#endif
