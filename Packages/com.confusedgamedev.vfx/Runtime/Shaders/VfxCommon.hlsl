#ifndef CONFUSEDGAMEDEV_VFX_COMMON_INCLUDED
#define CONFUSEDGAMEDEV_VFX_COMMON_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

// Shaders work in the source's right-handed axes, where +X is forward. Swapping X and Z converts
// to Unity's left-handed axes and makes +Z forward, so ToUnity is its own inverse.
#define ToUnity(p) ((p).zyx)

#define VFX_PI 3.14159265359

CBUFFER_START(UnityPerMaterial)
    float _EffectTime;
    float _EffectSize;
    float _EffectDetail;
    float4 _EffectColor;
    float _LifeStage;
    float _LifeStart;
    float _LifeEnd;
    float _Impact;
    float _ParticleCount;
    float4 _ImpactUp;
    float _Quantity;
    float _EmitterTime;
    float4 _LayerCounts;
    float _Spread;
CBUFFER_END

float Hash(float2 p)
{
    return frac(sin(dot(p, float2(127.1, 311.7))) * 43758.5453);
}

float Noise2(float2 p)
{
    float2 i = floor(p);
    float2 f = frac(p);
    f = f * f * (3.0 - 2.0 * f);
    return lerp(
        lerp(Hash(i), Hash(i + float2(1, 0)), f.x),
        lerp(Hash(i + float2(0, 1)), Hash(i + float2(1, 1)), f.x),
        f.y);
}

// Value, then d/dx and d/dy.
float3 NoiseGradient(float2 p)
{
    float2 i = floor(p);
    float2 f = frac(p);
    float2 u = f * f * (3.0 - 2.0 * f);
    float2 du = 6.0 * f * (1.0 - f);
    float a = Hash(i);
    float b = Hash(i + float2(1, 0));
    float c = Hash(i + float2(0, 1));
    float d = Hash(i + float2(1, 1));
    return float3(
        lerp(lerp(a, b, u.x), lerp(c, d, u.x), u.y),
        du.x * lerp(b - a, d - c, u.y),
        du.y * lerp(c - a, d - b, u.x));
}

float2 SmokeOptics(float2 q, float2 densityGradient, float density, float3 lightDir)
{
    float dome = sqrt(max(0.015, 1.0 - dot(q, q)));
    float3 n = normalize(float3(q - densityGradient * 0.13, dome));
    float wrap = saturate(dot(n, lightDir) * 0.7 + 0.3);
    float thickness = dome * (0.3 + density * 1.1);
    float transmission = exp(-thickness * 1.7);
    float rim = pow(1.0 - dome, 2.0) * wrap * 0.20;
    return float2((0.16 + wrap * 0.70) * lerp(0.55, 1.0, transmission) + rim, 1.0 - exp(-thickness * 1.8));
}

float ToonStep(float edge, float x)
{
    float aa = max(fwidth(x), 0.008);
    return smoothstep(edge - aa, edge + aa, x);
}

float3 ToonShade(float3 tint, float light)
{
    float3 c = lerp(tint * 0.28, tint * 1.08, ToonStep(0.40, light));
    return lerp(c, lerp(tint, float3(1.0, 1.0, 1.0), 0.53) * 1.15, ToonStep(0.69, light));
}

float Fbm(float2 p)
{
    return Noise2(p) * 0.57 + Noise2(p * 2.07 + 3.1) * 0.29 + Noise2(p * 4.13 - 1.7) * 0.14;
}

// Toon palette used by the site's burst and vortex effects.
float StyleStep(float edge, float value)
{
    float aa = max(fwidth(value), 0.012);
    return smoothstep(edge - aa, edge + aa, value);
}

float3 StyleColor(float3 tint, float light)
{
    float3 c = lerp(tint * 0.22, tint * 0.72, StyleStep(0.38, light));
    return lerp(c, lerp(tint, float3(1.0, 1.0, 1.0), 0.38) * 1.04, StyleStep(0.70, light));
}

// GLSL's mod, which differs from fmod for negative values.
float Mod(float x, float y)
{
    return x - y * floor(x / y);
}

float Band(float x, float width)
{
    return 1.0 - smoothstep(width, width + 0.004, abs(x));
}

float Ink(float d, float width)
{
    return Band(d, width) + exp(-abs(d) * 120.0) * 0.12;
}

float Segment(float2 p, float2 a, float2 b)
{
    float2 d = b - a;
    return length(p - a - d * saturate(dot(p - a, d) / dot(d, d)));
}

float Polygon(float2 p, float sides, float radius, float rotation)
{
    float a = atan2(p.y, p.x) + rotation;
    float sector = 2.0 * VFX_PI / sides;
    return cos(floor(0.5 + a / sector) * sector - a) * length(p) - radius;
}

// Uniform scale of the effect root, which billboards multiply into their size.
float RootScale()
{
    return length(float3(UNITY_MATRIX_M[0].y, UNITY_MATRIX_M[1].y, UNITY_MATRIX_M[2].y));
}

// Position in source axes to view space.
float3 SourceToView(float3 p)
{
    return TransformWorldToView(TransformObjectToWorld(ToUnity(p)));
}

#endif
