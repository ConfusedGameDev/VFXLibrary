#ifndef CONFUSEDGAMEDEV_VFX_FLOW_INCLUDED
#define CONFUSEDGAMEDEV_VFX_FLOW_INCLUDED

// The curl field and lifecycle of the vortices and smokes. Define VFX_KIND and VFX_VARIANT, the source's, first.

#include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"

// Analytic curl of A = (N(y,z), N(z,x), N(x,y)), every component sampling the same space.
float3 CurlFlow(float3 p, float t)
{
    float3 ax = NoiseGradient(p.yz + float2(7.3 - t * 0.22, 1.7 + t * 0.11));
    float3 ay = NoiseGradient(p.zx + float2(13.1 + t * 0.13, 5.4 - t * 0.19));
    float3 az = NoiseGradient(p.xy + float2(2.9 - t * 0.16, 17.2 + t * 0.14));
    return float3(az.z - ay.y, ax.z - az.y, ay.z - ax.y) * 0.65;
}

float3 StageShape(float3 p, float s, float e)
{
    float grow = s * s * (3.0 - 2.0 * s);
#if VFX_KIND == 4
    float curl = 1.0 - grow;
    float h = saturate((p.y + 1.4) / 3.4);
    float gather = curl * (1.0 - smoothstep(0.0, 0.6, e));
    p.y = -1.4 + (p.y + 1.4) * (1.0 + gather * 0.10);
    p.xz = Spin(p.xz, gather * (1.0 - h) * 0.55 - e * 0.45);
    p.xz *= 1.0 + gather * 0.45 + e * 0.18;
    #if VFX_VARIANT == 1
    p.y = max(-1.38, p.y - e * e * h * 0.7);
    #endif
#elif VFX_VARIANT == 1
    p.xz *= lerp(0.18, 1.0, grow) * (1.0 + e * 0.18);
#else
    p.y = -1.4 + (p.y + 1.4) * lerp(0.2, 1.0, grow);
#endif
    return p;
}

float PhaseCoverage()
{
#if VFX_KIND == 4
    return smoothstep(0.0, 0.13, _LifeStart) * (1.0 - smoothstep(0.45, 1.0, _LifeEnd));
#else
    return smoothstep(0.0, 0.25, _LifeStart) * (1.0 - smoothstep(0.35, 1.0, _LifeEnd));
#endif
}

// Position in source axes to clip space, with the lifecycle applied.
float4 FlowClip(float3 p)
{
    if (_LifeStage != 1.0)
    {
        p = StageShape(p, _LifeStart, _LifeEnd);
    }
    return TransformObjectToHClip(ToUnity(p));
}

// The same for a position already in view space, such as a billboard corner.
float4 FlowViewToClip(float3 positionVS)
{
    if (_LifeStage == 1.0)
    {
        return TransformWViewToHClip(positionVS);
    }

    float3 positionWS = mul(UNITY_MATRIX_I_V, float4(positionVS, 1.0)).xyz;
    float3 p = ToUnity(TransformWorldToObject(positionWS));
    return TransformWorldToHClip(TransformObjectToWorld(ToUnity(StageShape(p, _LifeStart, _LifeEnd))));
}

// Applies the lifecycle's fade to a finished colour, discarding what has gone.
float4 FlowStaged(float4 color)
{
    if (_LifeStage != 1.0)
    {
        float coverage = PhaseCoverage();
        clip(coverage - 0.004);
        color.a *= coverage;
#if VFX_KIND == 4 && VFX_VARIANT == 2
        color.rgb *= 1.0 - _LifeEnd * 0.6;
#endif
    }
    return color;
}

#endif
