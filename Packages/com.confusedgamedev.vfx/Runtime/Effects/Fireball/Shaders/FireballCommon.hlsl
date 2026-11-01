#ifndef CONFUSEDGAMEDEV_FIREBALL_COMMON_INCLUDED
#define CONFUSEDGAMEDEV_FIREBALL_COMMON_INCLUDED

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
