#ifndef CONFUSEDGAMEDEV_VFX_BEAM_INCLUDED
#define CONFUSEDGAMEDEV_VFX_BEAM_INCLUDED

#include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxCommon.hlsl"

// Lifecycle shared by beams. The beam runs from x = -2.4 to 2.4 in source axes and the root's scale
// stretches it to its length. Billboards and end details divide by _Stretch to keep their proportions.

// Only the cross-section changes, so the end points never move. The range is revealed in fragments.
float3 StageShape(float3 p, float s, float e)
{
    float grow = s * s * (3.0 - 2.0 * s);
    p.yz *= lerp(0.35, 1.0, grow) * (1.0 - e * 0.7);
    return p;
}

float PhaseCoverage(float3 p)
{
    float x = saturate((p.x + 2.4) / 4.8);
    float start = smoothstep(-0.08, 0.08, _LifeStart * 1.16 - 0.08 - x);
    float end = smoothstep(-0.14, 0.05, x - _LifeEnd * 1.22 + 0.12) * (1.0 - smoothstep(0.78, 1.0, _LifeEnd));
    return start * end;
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
    stagePosition = ToUnity(TransformWorldToObject(positionWS));
    if (_LifeStage != 1.0)
    {
        positionWS = TransformObjectToWorld(ToUnity(StageShape(stagePosition, _LifeStart, _LifeEnd)));
    }
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

// The stop moment in effect time, or -1 while the beam is still playing.
float StopTime()
{
    return _LifeStage > 1.5 ? _EmitterTime : -1.0;
}

#endif
