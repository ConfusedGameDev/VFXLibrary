#ifndef CONFUSEDGAMEDEV_VFX_BURST_INCLUDED
#define CONFUSEDGAMEDEV_VFX_BURST_INCLUDED

// Helpers of the one-shot bursts. Define VFX_VARIANT, the source's variant, first, and VFX_BURST_STAGED
// for the rare burst with a shaped ending.

#include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxCommon.hlsl"

// mat2(cos,-sin,sin,cos) * v, the source's usual rotation.
float2 Spin(float2 v, float angle)
{
    float c = cos(angle);
    float s = sin(angle);
    return float2(c * v.x + s * v.y, -s * v.x + c * v.y);
}

float3 StyleHeat(float3 tint, float heat)
{
    float3 c = lerp(tint * 0.24, tint * 1.05, StyleStep(0.38, heat));
    return lerp(c, lerp(tint, float3(1.0, 0.88, 0.51), 0.62), StyleStep(0.70, heat));
}

// UV distortion and two erosion layers, so each tongue burns away from its edges.
float3 FlameErosion(float2 uv, float t, float seed)
{
    float2 p = float2(uv.x + uv.y * 0.65, uv.y);
    float warp = Noise2(p * float2(3.1, 2.7) + float2(seed, t * -0.31));
    p.x += (warp - 0.5) * 0.6;
    float broad = Noise2(p * float2(4.0, 2.2) + float2(seed * 3.7, -t * 0.85));
    float fine = Noise2(p * float2(10.5, 5.0) + float2(seed * 7.1, -t * 1.35));
    float erosion = broad * 0.72 + fine * 0.28;
    float interior = 1.0 - abs(uv.x * 2.0 - 1.0);
    float shape = interior - (1.0 - erosion) * 0.67;
    float aa = max(fwidth(shape) * 0.8, 0.018);
    float mask = smoothstep(-aa, aa + 0.07, shape);
    float heat = saturate(shape * 0.9 + broad * 0.25);
    float edge = exp(-abs(shape) * 24.0) * smoothstep(0.28, 0.58, erosion);
    return float3(mask, heat, edge);
}

// The smoke's key light, in view space as the source computes it.
float3 KeyLight()
{
    return normalize(TransformWorldToViewDir(ToUnity(float3(-0.45, 0.8, 0.55)), false));
}

// Direction in source axes to view space.
float3 SourceDirToView(float3 d)
{
    return TransformWorldToViewDir(TransformObjectToWorldDir(ToUnity(d), false), false);
}

#ifdef VFX_BURST_STAGED

float3 StageShape(float3 p, float e)
{
#if VFX_VARIANT == 2
    float radius = length(p.xz);
    float angle = atan2(p.z, p.x);
    float crest = sin(radius * 5.0 - e * 5.0 + sin(angle * 5.0));
    p.y += crest * sin(e * VFX_PI) * 0.18;
    p.xz *= 1.0 + e * 0.12;
#endif
    return p;
}

float PhaseCoverage(float3 p)
{
    float e = _LifeEnd;
    float end = 1.0;
#if VFX_VARIANT == 2
    float a = atan2(p.z, p.x);
    float breakUp = 0.5 + 0.5 * sin(a * 7.0 + sin(a * 3.0) + p.y * 5.0);
    end = smoothstep(e * 0.6 - 0.1, e * 0.6 + 0.12, breakUp);
#endif
    return end;
}

#endif

// Position in source axes to clip space, through the ending when there is one.
float4 BurstClip(float3 p, out float3 stagePosition)
{
    stagePosition = p;
#ifdef VFX_BURST_STAGED
    if (_LifeStage != 1.0)
    {
        p = StageShape(p, _LifeEnd);
    }
#endif
    return TransformObjectToHClip(ToUnity(p));
}

// The same for a position already in view space, such as a billboard corner.
float4 BurstViewToClip(float3 positionVS, out float3 stagePosition)
{
#ifdef VFX_BURST_STAGED
    float3 positionWS = mul(UNITY_MATRIX_I_V, float4(positionVS, 1.0)).xyz;
    stagePosition = ToUnity(TransformWorldToObject(positionWS));
    if (_LifeStage != 1.0)
    {
        positionWS = TransformObjectToWorld(ToUnity(StageShape(stagePosition, _LifeEnd)));
    }
    return TransformWorldToHClip(positionWS);
#else
    stagePosition = float3(0.0, 0.0, 0.0);
    return TransformWViewToHClip(positionVS);
#endif
}

// Applies the ending's reveal to a finished colour, discarding what has gone.
float4 BurstStaged(float4 color, float3 stagePosition)
{
#ifdef VFX_BURST_STAGED
    if (_LifeStage != 1.0)
    {
        float coverage = PhaseCoverage(stagePosition);
        clip(coverage - 0.004);
        color.a *= coverage;
    }
#endif
    return color;
}

#endif
