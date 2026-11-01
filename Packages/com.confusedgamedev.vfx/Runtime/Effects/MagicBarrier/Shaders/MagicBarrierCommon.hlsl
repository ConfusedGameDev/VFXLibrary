#ifndef CONFUSEDGAMEDEV_MAGIC_BARRIER_COMMON_INCLUDED
#define CONFUSEDGAMEDEV_MAGIC_BARRIER_COMMON_INCLUDED

#include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxCommon.hlsl"

// Rises out of the ground, then bursts outward in angular shards.
float3 StageShape(float3 p, float s, float e)
{
    float grow = s * s * (3.0 - 2.0 * s);
    float a = atan2(p.z, p.x);
    float cell = floor((a + VFX_PI) * 3.0);
    p.y *= grow;
    float release = smoothstep(frac(cell * 0.37) * 0.2, 0.72, e);
    p *= 1.0 + release * 0.4;
    p.y += release * (0.12 + max(0.0, p.y) * 0.4);
    return p;
}

float PhaseCoverage(float3 p)
{
    if (_LifeStage == 1.0)
    {
        return 1.0;
    }

    float s = _LifeStart;
    float e = _LifeEnd;
    float pattern = clamp(0.12 + max(abs(p.x), abs(p.z)) * 0.27 + max(0.0, p.y) * 0.18, 0.08, 0.75);
    float start = smoothstep(-0.08, 0.08, s - pattern);
    float end = 1.0 - smoothstep(-0.12, 0.12, e - (0.18 + pattern * 0.75));
    if (e > 0.0)
    {
        float sector = frac(atan2(p.z, p.x) * 1.4324);
        float gap = smoothstep(0.03, 0.38, e) * 0.22;
        end *= smoothstep(gap, gap + 0.025, sector) * (1.0 - smoothstep(1.0 - gap - 0.025, 1.0 - gap, sector));
    }
    return start * end;
}

// Source-axis position in the effect root to clip space, with the lifecycle deformation applied.
float4 SourceToClip(float3 p)
{
    if (_LifeStage != 1.0)
    {
        p = StageShape(p, _LifeStart, _LifeEnd);
    }
    return TransformObjectToHClip(ToUnity(p));
}

#endif
