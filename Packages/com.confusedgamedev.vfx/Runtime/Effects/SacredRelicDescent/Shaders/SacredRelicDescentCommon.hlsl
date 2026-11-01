#ifndef CONFUSEDGAMEDEV_SACRED_RELIC_COMMON_INCLUDED
#define CONFUSEDGAMEDEV_SACRED_RELIC_COMMON_INCLUDED

#define _EmitTime _Motion0.x
#define _ImpactAge _Motion0.y
#define _PulseAge _Motion0.z
#define _WaveRadius _Motion0.w
#define _MaxRadius _Motion1.x
#define _Cancel _Motion1.y
#define _BodyHeight _Motion1.z
#define _BurialDepth _Motion1.w
#define _BodyFade _Motion2.x

// Authored as linear light: additive premultiplication keeps the hollow centers.
float4 Magic(float3 color, float alpha)
{
    return float4(color * alpha * 5.0, 0.0);
}

float3 RelicFloor(float3 position, float y)
{
    return float3(position.x, y, -position.y) * _EffectSize;
}

float3 RelicToView(float3 p)
{
    return SourceToView(p * _EffectSize);
}

float3 RelicViewToSource(float3 v)
{
    return ToUnity(TransformWorldToObjectDir(mul((float3x3)UNITY_MATRIX_I_V, v)));
}

// Continuous world-plane caustic ribbons; advection follows radial propagation.
float RelicWater(float2 p, float t)
{
    float r = length(p);
    float2 q = p * 3.7;
    q += float2(sin(q.y * 0.8 - t * 2.4), sin(q.x * 0.7 + t * 1.8)) * 0.5;
    float w = sin(q.x + sin(q.y * 0.7 - t * 2.0)) + sin(q.y + sin(q.x * 0.8 + t * 1.4));
    float veins = 1.0 - smoothstep(0.06, 0.30 + fwidth(w), abs(w));
    float ripple = 0.5 + 0.5 * sin(r * 18.0 - t * 14.0 + sin(q.x + q.y) * 1.7);
    return saturate(veins * 0.78 + pow(ripple, 5.0) * 0.35);
}

float RelicHash(float2 p)
{
    return frac(sin(dot(p, float2(127.1, 311.7))) * 43758.5453);
}

float RelicNoise(float2 p)
{
    float2 i = floor(p);
    float2 f = frac(p);
    f = f * f * (3.0 - 2.0 * f);
    return lerp(lerp(RelicHash(i), RelicHash(i + float2(1, 0)), f.x), lerp(RelicHash(i + float2(0, 1)), RelicHash(i + float2(1, 1)), f.x), f.y);
}

#endif
