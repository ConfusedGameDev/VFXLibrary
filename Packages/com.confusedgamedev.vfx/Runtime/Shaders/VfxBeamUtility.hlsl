#ifndef CONFUSEDGAMEDEV_VFX_BEAM_UTILITY_INCLUDED
#define CONFUSEDGAMEDEV_VFX_BEAM_UTILITY_INCLUDED

// Helpers of the beams that run their own lifecycle in the vertex shader. Include after VfxBeam.hlsl.

float Ease(float a)
{
    a = 1.0 - saturate(a);
    return 1.0 - a * a * a;
}

float FadeEnd()
{
    return 1.0 - smoothstep(0.58, 1.0, _LifeEnd);
}

float Grow()
{
    return smoothstep(0.0, 1.0, _LifeStart);
}

float Rand(float n)
{
    return frac(sin(n * 127.1 + 311.7) * 43758.5453);
}

// Three-tone lighting from a fixed world light, then lifted toward white by tone.
float3 LitColor(float3 normalWS, float tone)
{
    float light = dot(normalize(normalWS), normalize(ToUnity(float3(-0.4, 0.8, 0.55)))) * 0.5 + 0.5;
    float shade = lerp(0.28, 0.82, smoothstep(0.38, 0.41, light));
    shade = lerp(shade, 1.16, smoothstep(0.7, 0.73, light));
    return lerp(_EffectColor.rgb * shade, lerp(_EffectColor.rgb, float3(1.0, 1.0, 1.0), 0.7), saturate(tone));
}

#endif
