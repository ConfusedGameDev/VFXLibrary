#ifndef CONFUSEDGAMEDEV_DARKCHAIN_COMMON_INCLUDED
#define CONFUSEDGAMEDEV_DARKCHAIN_COMMON_INCLUDED

#define DC_plasmaLife 0.140000
#define DC_ejectionLife 0.500000
#define DC_glintLife 0.500000
#define DC_flareLife 0.075000
#define DC_pressureLife 1.000000
#define DC_compressionStart 3.470000
#define DC_compressionScale 0.216667
#define DC_coreFlashLife 0.060000
#define DC_duration 5.150000
#define DC_lowerRadius 2.300000
#define DC_upperRadius 6.210000
#define DC_baseY 0.040000
#define DC_height 4.400000
#define DC_centerY 2.240000
#define DC_chains 12.000000
#define DC_maxLinks 48.000000
#define DC_chainStart 0.450000
#define DC_chainEnd 0.850000
#define DC_chainBend 1.050000
#define DC_chainSettle 0.400000
#define DC_orbStart 1.150000
#define DC_burst 3.650000
#define DC_settle 0.036000
#define DC_attack 0.012000
#define DC_overshoot 1.100000
#define DC_restRadius 0.200000
#define DC_blastRadius 4.200000
#define DC_blastExpand 0.080000
#define DC_breakTravel 0.120000
#define DC_orbWarp 0.125000
#define DC_blastPieces 252.000000
#define DC_blastLife 1.300000
#define DC_warpLife 1.500000
#define DC_warpCycles 10.000000
#define DC_warpPower 0.495000
#define DC_warpRadius 4.200000
#define DC_waveRadius 10.600000
#define DC_waveWidth 4.300000
#define DC_waveExpand 0.800000
#define DC_waveLife 0.800000
#define DC_waveHeight 0.180000
#define DC_arcGroups 6.000000
#define DC_arcLife 0.160000
#define DC_fragmentScale 0.500000
#define DC_fragmentImpulse 6.400000
#define DC_fragmentSpread 0.600000
#define DC_auraTrail 0.560000
#define DC_inkTrail 0.840000
#define DC_auraCount 16.000000
#define DC_inkCount 12.000000
#define DC_inkMinRadius 7.800000
#define DC_inkRadius 10.100000
#define DC_inkCoreRadius 0.720000
#define DC_inkTurnsMin 1.000000
#define DC_inkTurnsMax 2.000000
#define DC_inkLead 0.180000
#define DC_inkPullLead 0.280000
#define DC_fieldArcs 36.000000
#define DC_fieldLife 1.300000
#define DC_coreReleaseRadius 0.286867
#define DC_releaseRadius 1.450000
#define DC_SEED 2859.0
#define TAU 6.28318530718

// Set each frame by DarkchainDetonationEffect, from the same clock.
#define _JetTravel _Motion0.x
#define _JetFade _Motion0.y
#define _WarpKick _Motion0.z
#define _WarpFade _Motion0.w
#define _ChainTension _Motion1.x
#define _Flow _Motion1.y
#define _OrbRadius _Motion1.z
#define _Beat _Motion1.w
#define _OrbAlive _Motion2.x
#define _BlastRadius _Motion2.y
#define _WaveRadius _Motion2.z

float Charge()
{
    return smoothstep(DC_orbStart, DC_burst, _EffectTime);
}

float Hash31(float3 p)
{
    return frac(sin(dot(p, float3(127.1, 311.7, 74.7))) * 43758.5453);
}

float Noise3(float3 p)
{
    float3 i = floor(p);
    float3 f = frac(p);
    f = f * f * (3.0 - 2.0 * f);
    return lerp(
        lerp(lerp(Hash31(i), Hash31(i + float3(1, 0, 0)), f.x), lerp(Hash31(i + float3(0, 1, 0)), Hash31(i + float3(1, 1, 0)), f.x), f.y),
        lerp(lerp(Hash31(i + float3(0, 0, 1)), Hash31(i + float3(1, 0, 1)), f.x), lerp(Hash31(i + float3(0, 1, 1)), Hash31(i + float3(1, 1, 1)), f.x), f.y),
        f.z);
}

// Size and the root's scale, which billboards multiply into their width.
float ViewScale()
{
    return _EffectSize * RootScale();
}

float3 DcView(float3 p)
{
    return SourceToView(p * _EffectSize);
}

float3 CoreView()
{
    return DcView(float3(0.0, DC_centerY, 0.0));
}

// The screen direction of a view-space velocity, with the perspective derivative.
float2 Heading(float3 velocity, float3 positionVS)
{
    float perspective = 1.0 - step(0.5, UNITY_MATRIX_P[3][3]);
    return normalize(velocity.xy - positionVS.xy * (velocity.z / positionVS.z) * perspective + float2(0.00001, 0.0));
}

// alpha, event, flash, age of a discharge around the orb. Fixed path for each event.
float4 ArcState(float slot)
{
    float time = _EffectTime;
    float period = 0.19 + slot * 0.013;
    float offset = DC_orbStart + slot * 0.027;
    float stamp = min(time, DC_burst);
    float event = floor((stamp - offset) / period);
    float age = stamp - offset - event * period;
    float duration = (50.0 + Mod(event * 7.0 + slot * 3.0, 5.0) * 10.0) / 1000.0;
    float released = step(DC_burst, time);
    float alpha = lerp(event >= 0.0 && age < duration ? 1.0 : 0.0, 1.0 - smoothstep(0.04, DC_arcLife, time - DC_burst), released);
    float flash = released * (1.0 - smoothstep(0.012, 0.04, time - DC_burst));
    return float4(alpha, max(0.0, event), flash, age);
}

// alpha, event of a fine field discharge. Staggered, with no group gate.
float2 FieldState(float slot)
{
    float time = _EffectTime;
    if (time >= DC_burst)
    {
        float us = time - DC_burst;
        float period = 0.11 + Mod(slot, 5.0) * 0.011;
        float phase = us + slot * 0.019;
        float age = phase - floor(phase / period) * period;
        float duration = 0.045 + Mod(slot, 3.0) * 0.01;
        float on = us < 0.025 || age < duration ? 1.0 : 0.0;
        return float2(on * (1.0 - smoothstep(0.9, DC_fieldLife, us)), 1000.0 + floor(phase / period));
    }

    float slow = 0.143 + Mod(slot, 7.0) * 0.009;
    float offset = 0.65 + slot * 0.017;
    float event = floor((time - offset) / slow);
    float age2 = time - offset - event * slow;
    float length2 = 0.07 + Mod(slot + max(0.0, event) * 3.0, 5.0) * 0.01;
    return float2(event >= 0.0 && age2 < length2 ? 1.0 : 0.0, max(0.0, event));
}

#endif
