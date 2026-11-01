#ifndef CONFUSEDGAMEDEV_VFX_PROJECTILE_INCLUDED
#define CONFUSEDGAMEDEV_VFX_PROJECTILE_INCLUDED

#include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxCommon.hlsl"

// Lifecycle shared by projectiles. Define VFX_VARIANT, the site's variant number, before including this.

// GLSL's mat2(c, -s, s, c) * v.
float2 Rotate(float2 v, float angle)
{
    float c = cos(angle);
    float s = sin(angle);
    return float2(c * v.x + s * v.y, -s * v.x + c * v.y);
}

// Start-up and ending deformation, in source axes relative to the effect root.
float3 StageShape(float3 p, float s, float e)
{
    float grow = s * s * (3.0 - 2.0 * s);
    float curl = 1.0 - grow;
    float tail = 1.0 - smoothstep(-1.4, 0.25, p.x);

#if VFX_VARIANT == 0
    p.yz *= lerp(0.22, 1.0, grow);
    p.x = lerp(p.x * 0.38 - 0.16, p.x, grow);
    p.y += sin(p.x * 4.5 + s * 7.0) * curl * 0.15;
#elif VFX_VARIANT == 1
    p.x *= lerp(1.3, 1.0, grow);
    p.yz *= lerp(0.08, 1.0, grow);
#elif VFX_VARIANT == 2 || VFX_VARIANT == 4
    float assemble = ceil((atan2(p.z, p.y) + 3.14159) * 3.0) * 0.028;
    p.yz *= 1.0 + curl * (0.8 + assemble);
    p.x -= curl * (0.2 + assemble);
#elif VFX_VARIANT == 3
    p.yz *= 1.0 + curl * 0.8;
    p.x += sin(p.y * 7.0) * curl * 0.4;
#elif VFX_VARIANT == 5
    p.z += sin(p.x * 4.0) * curl * 0.75;
    p.x -= curl * 0.5;
#else
    p.yz *= 1.0 + curl * 0.85;
    float turn = curl * 2.4;
    p.yz = float2(cos(turn) * p.y + sin(turn) * p.z, -sin(turn) * p.y + cos(turn) * p.z);
#endif

    p.x -= e * tail * 1.6;
    p.yz *= 1.0 - e * 0.75;
    return p;
}

float PhaseCoverage(float3 p)
{
    float s = _LifeStart;
    float e = _LifeEnd;

#if VFX_VARIANT == 0
    float curl = sin(p.x * 6.0 + p.y * 5.0 + s * 9.0) * 0.06;
    float start = smoothstep(0.0, 0.18, s) * smoothstep(-0.12, 0.12, s - (0.15 + clamp(-p.x, 0.0, 3.0) * 0.2 + curl));
#elif VFX_VARIANT == 1
    float start = smoothstep(0.0, 0.12, s) * smoothstep(-0.1, 0.1, s - abs(p.x) * 0.24);
#elif VFX_VARIANT == 2 || VFX_VARIANT == 4
    float start = smoothstep(-0.08, 0.08, s - (0.12 + frac(atan2(p.z, p.y) * 1.7) * 0.56));
#elif VFX_VARIANT == 3
    float start = smoothstep(-0.12, 0.12, s - (0.1 + frac(p.x * 0.8 + p.y) * 0.55));
#elif VFX_VARIANT == 5
    float start = smoothstep(-0.13, 0.13, s - (0.15 + clamp(-p.x, 0.0, 2.0) * 0.25));
#else
    float start = smoothstep(-0.13, 0.13, s - (0.1 + frac(atan2(p.z, p.y) * 0.5 - p.x * 0.3) * 0.6));
#endif

    float end = 1.0 - smoothstep(0.0, _Impact > 0.5 ? 0.28 : 0.9, e);
    return start * end;
}

// Applies StageShape to a finished world position. Returns the undeformed position for PhaseCoverage.
float3 ApplyStage(inout float3 positionWS)
{
    float3 stagePosition = ToUnity(TransformWorldToObject(positionWS));
    if (_LifeStage != 1.0)
    {
        float3 shaped = StageShape(stagePosition, _LifeStart, _LifeEnd);
        positionWS = TransformObjectToWorld(ToUnity(shaped));
    }
    return stagePosition;
}

// Source-axis position in the effect root to clip space, with the lifecycle applied.
float4 StageClip(float3 p, out float3 stagePosition)
{
    stagePosition = p;
    if (_LifeStage != 1.0)
    {
        p = StageShape(p, _LifeStart, _LifeEnd);
    }
    return TransformObjectToHClip(ToUnity(p));
}

// The same for a position already in view space, such as a billboard corner.
float4 StageViewToClip(float3 positionVS, out float3 stagePosition)
{
    float3 positionWS = mul(UNITY_MATRIX_I_V, float4(positionVS, 1.0)).xyz;
    stagePosition = ApplyStage(positionWS);
    return TransformWorldToHClip(positionWS);
}

// Alpha multiplier for a fragment, discarding what the lifecycle has not revealed.
float StageAlpha(float3 stagePosition)
{
    if (_LifeStage == 1.0)
    {
        return 1.0;
    }

    float coverage = PhaseCoverage(stagePosition);
    clip(coverage - 0.004);
    return coverage;
}

#endif
