#ifndef CONFUSEDGAMEDEV_VFX_GROUND_INCLUDED
#define CONFUSEDGAMEDEV_VFX_GROUND_INCLUDED

// Lifecycle and sigil helpers of the ground effects. Define VFX_VARIANT, the source's variant, first.

#include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxCommon.hlsl"

// Most sigils stop moving when the effect stops, while burning ground and the matrix keep running.
#if VFX_VARIANT == 1 || VFX_VARIANT == 4
    #define VFX_GROUND_TIME _EffectTime
#else
    #define VFX_GROUND_TIME _EmitterTime
#endif

float2 Rotate(float2 v, float angle)
{
    float c = cos(angle);
    float s = sin(angle);
    return float2(c * v.x + s * v.y, -s * v.x + c * v.y);
}

float3 StageShape(float3 p, float s, float e, float part)
{
    float grow = s * s * (3.0 - 2.0 * s);
    float curl = 1.0 - grow;
    float a = atan2(p.z, p.x);
    float cell = floor((a + VFX_PI) * 3.0);
    float stagger = smoothstep(0.04 + frac(part * 0.37 + cell * 0.13) * 0.2, 0.9, e);

#if VFX_VARIANT == 0
    p.y += curl * (0.15 + sin(a * 5.0) * 0.08);
    float back = smoothstep(0.0, 0.72, e);
    p.xz = Rotate(p.xz, back * 0.8);
    p.xz *= 1.0 - back * 0.95;
    p.y = lerp(p.y, 0.06, back) + sin(back * VFX_PI) * 0.32;
#elif VFX_VARIANT == 1
    p.y *= grow * (1.0 - stagger * 0.8);
    p.y += sin(stagger * VFX_PI) * 0.16;
    p.xz *= 1.0 + stagger * 0.1;
#elif VFX_VARIANT == 2
    float2 center = (floor(p.xz * 2.5) + 0.5) / 2.5;
    float2 local = p.xz - center;
    float tumble = stagger * (1.0 + frac(cell * 0.71) * 2.0);
    p.xz = center * (1.0 + stagger * 0.65) + local * cos(tumble);
    p.y += local.x * sin(tumble) + sin(stagger * VFX_PI) * (0.25 + frac(cell * 0.71) * 0.45) - stagger * stagger * 0.35;
    p.xz *= lerp(0.7, 1.0, grow);
#elif VFX_VARIANT == 4
    p.y *= grow;
    p.xz *= 1.0 + stagger * 0.32;
    p.y -= stagger * stagger * max(0.0, p.y) * 0.9;
    p.x += sin(part * 3.1) * stagger * 0.18;
#elif VFX_VARIANT == 5
    p.y *= grow;
    float release = smoothstep(0.02 + frac(part * 0.31) * 0.2, 0.72, e);
    float loosen = release * (0.4 + max(0.0, p.y) * 0.7);
    p.xz += float2(cos(part * 2.4), sin(part * 2.4)) * loosen;
    p.y += sin(release * VFX_PI) * 0.28 - release * release * 0.55;
#elif VFX_VARIANT == 6
    float height = max(0.0, p.y);
    float retract = smoothstep(0.0, 0.9, e);
    float bend = retract * height * 2.1;
    p.xz = Rotate(p.xz, curl * 2.7 + retract * 0.4);
    p.xz *= 1.0 - retract * 0.3;
    p.xz += float2(cos(a), sin(a)) * (cos(bend) - 1.0) * height * 0.45;
    p.y = grow * (height * cos(bend) * (1.0 - retract * 0.5) + min(p.y, 0.0));
#elif VFX_VARIANT == 8
    float pop = smoothstep(0.08 + frac(part * 0.41) * 0.25, 0.65 + frac(part * 0.41) * 0.25, e);
    p.y *= grow * (1.0 - pop * 0.85);
    p.xz *= lerp(0.55, 1.0, grow) * (1.0 + sin(pop * VFX_PI) * 0.65);
#endif
    return p;
}

float PhaseCoverage(float3 p)
{
    float s = _LifeStart;
    float e = _LifeEnd;
    float a = atan2(p.z, p.x);
    float r = length(p.xz);
    float pattern = 0.0;

#if VFX_VARIANT == 0
    pattern = 0.1 + r * 0.25 + sin(a * 5.0) * 0.08;
#elif VFX_VARIANT == 1
    pattern = 0.12 + frac(a / 6.28318 * 5.0) * 0.22 + r * 0.2;
#elif VFX_VARIANT == 2
    pattern = 0.1 + r * 0.25 + abs(sin(a * 3.0)) * 0.1;
#elif VFX_VARIANT == 4
    pattern = 0.1 + frac(floor(p.x * 3.0) + floor(p.z * 3.0) * 0.38) * 0.35 + max(0.0, p.y) * 0.2;
#elif VFX_VARIANT == 5
    pattern = 0.14 + frac(a / 6.28318 * 3.0) * 0.3 + max(0.0, p.y) * 0.2;
#elif VFX_VARIANT == 6
    pattern = 0.08 + r * 0.18 + max(0.0, p.y) * 0.25;
#else
    pattern = 0.12 + r * 0.2 + sin(a * 3.0) * 0.1;
#endif

    pattern = clamp(pattern, 0.08, 0.75);
    float start = smoothstep(-0.08, 0.08, s - pattern);
    float end = 1.0 - smoothstep(-0.12, 0.12, e - (0.18 + pattern * 0.75));
#if VFX_VARIANT == 0
    end = 1.0 - smoothstep(0.64, 0.98, e);
#elif VFX_VARIANT == 5 || VFX_VARIANT == 6
    end = 1.0 - smoothstep(0.55, 0.98, e);
#endif

    if (e > 0.0)
    {
#if VFX_VARIANT == 1
        float ash = 0.5 + 0.5 * sin(p.x * 31.0 + p.z * 23.0 + sin(p.x * 17.0) * 3.0);
        end *= smoothstep(e * 0.7 - 0.1, e * 0.7 + 0.12, ash);
#elif VFX_VARIANT == 2 || VFX_VARIANT == 4
        float2 tile = abs(frac(p.xz * 2.5) - 0.5);
        float crack = max(tile.x, tile.y);
        end *= 1.0 - smoothstep(0.5 - e * 0.25, 0.51 - e * 0.25, crack);
#elif VFX_VARIANT == 8
        float pop = smoothstep(0.08, 0.65, e);
        end *= 1.0 - smoothstep(0.015, 0.08, max(0.0, p.y) - (0.9 - pop * 1.5));
#endif
    }
    return start * end;
}

// Source-axis position in the effect root to clip space, with the lifecycle applied.
float4 GroundClip(float3 p, float part, out float3 stagePosition)
{
    stagePosition = p;
    if (_LifeStage != 1.0)
    {
        p = StageShape(p, _LifeStart, _LifeEnd, part);
    }
    return TransformObjectToHClip(ToUnity(p));
}

// The same for a position already in view space, such as a billboard corner.
float4 GroundViewToClip(float3 positionVS, float part, out float3 stagePosition)
{
    float3 positionWS = mul(UNITY_MATRIX_I_V, float4(positionVS, 1.0)).xyz;
    stagePosition = ToUnity(TransformWorldToObject(positionWS));
    if (_LifeStage != 1.0)
    {
        positionWS = TransformObjectToWorld(ToUnity(StageShape(stagePosition, _LifeStart, _LifeEnd, part)));
    }
    return TransformWorldToHClip(positionWS);
}

// Applies the lifecycle's reveal to a finished colour, discarding what is not shown yet.
float4 Staged(float4 color, float3 stagePosition)
{
    if (_LifeStage == 1.0)
    {
        return color;
    }

    float coverage = PhaseCoverage(stagePosition);
    clip(coverage - 0.004);
    color.a *= coverage;
#if VFX_VARIANT == 1
    color.rgb *= 1.0 - _LifeEnd * 0.75;
#endif
    return color;
}

// The rings, rune band and ticks shared by the sigils of the older ground effects.
float SigilInk(float2 p, float r, float a, float t)
{
    float inkSum = Ink(r - 0.94, 0.003) + Ink(r - 0.9, 0.0018) + Ink(r - 0.74, 0.003);

    float cells = (a - t * 0.09 + VFX_PI) / 6.28318 * 36.0;
    float2 q = float2((frac(cells) - 0.5) * 1.8, (r - 0.821) * 16.0);
    float id = floor(cells);
    float rune = Segment(q, float2(-0.22, -0.42), float2(-0.22, 0.42));
    rune = min(rune, Segment(q, float2(-0.22, 0.31), float2(0.27, 0.10 + Mod(id, 3.0) * 0.10)));
    rune = min(rune, Segment(q, float2(-0.22, -0.15), float2(0.28, -0.35)));
    if (Mod(id, 2.0) < 1.0)
    {
        rune = min(rune, Segment(q, float2(0.25, -0.35), float2(0.25, 0.34)));
    }

    inkSum += Ink(rune, 0.035) * step(0.77, r) * (1.0 - step(0.875, r));
    inkSum += pow(abs(sin(a * 48.0 + t * 0.12)), 32.0) * Band(r - 0.968, 0.012) * 0.7;
    return inkSum;
}

float LineMask(float2 p, float2 a, float2 b, float width)
{
    return 1.0 - smoothstep(width, width + 0.006, Segment(p, a, b));
}

// The bright arc that sweeps around the school spells' sigils.
float SigilSweep(float r, float a, float t)
{
    return 0.45 + 0.55 * pow(abs(0.5 + 0.5 * sin(a * 2.0 - t * 1.5 + r * 3.0)), 3.0);
}

#endif
