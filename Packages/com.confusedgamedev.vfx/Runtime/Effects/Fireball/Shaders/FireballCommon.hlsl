#ifndef CONFUSEDGAMEDEV_FIREBALL_COMMON_INCLUDED
#define CONFUSEDGAMEDEV_FIREBALL_COMMON_INCLUDED

#include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxCommon.hlsl"

// Start-up and ending deformation, in source axes relative to the effect root.
float3 StageShape(float3 p, float s, float e)
{
    float grow = s * s * (3.0 - 2.0 * s);
    float curl = 1.0 - grow;
    float tail = 1.0 - smoothstep(-1.4, 0.25, p.x);
    p.yz *= lerp(0.22, 1.0, grow);
    p.x = lerp(p.x * 0.38 - 0.16, p.x, grow);
    p.y += sin(p.x * 4.5 + s * 7.0) * curl * 0.15;
    p.x -= e * tail * 1.6;
    p.yz *= 1.0 - e * 0.75;
    return p;
}

float PhaseCoverage(float3 p)
{
    float s = _LifeStart;
    float e = _LifeEnd;
    float curl = sin(p.x * 6.0 + p.y * 5.0 + s * 9.0) * 0.06;
    float start = smoothstep(0.0, 0.18, s) * smoothstep(-0.12, 0.12, s - (0.15 + clamp(-p.x, 0.0, 3.0) * 0.2 + curl));
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

#endif
