#ifndef CONFUSEDGAMEDEV_VFX_RADIANT_BEAM_INCLUDED
#define CONFUSEDGAMEDEV_VFX_RADIANT_BEAM_INCLUDED

// Outside the steady state the core whitens, the shaft thins and the end seals drop away petal by petal.
float4 StageLook(float3 color, float alpha, float3 stagePosition)
{
    alpha *= StageAlpha(stagePosition);
    if (_LifeStage == 1.0)
    {
        return float4(color, alpha);
    }

    float radius = length(stagePosition.yz);
    float core = 1.0 - smoothstep(0.04, 0.22, radius);
    float atEnd = smoothstep(1.65, 2.05, abs(stagePosition.x));
    float petal = floor((atan2(stagePosition.z, stagePosition.y) + 3.14159) * 0.955);
    float release = smoothstep(0.15 + frac(petal * 0.381) * 0.3, 0.85, _LifeEnd);

    color = lerp(color, float3(1.0, 0.97, 0.81), core * 0.75);
    alpha *= lerp(0.55 + 0.45 * core, 1.0 - release, atEnd);
    alpha *= 1.0 - atEnd * smoothstep(0.35, 0.9, _LifeEnd) * smoothstep(0.05, 0.55, radius);
    return float4(color, alpha);
}

#endif
