#ifndef CONFUSEDGAMEDEV_DIMENSIONAL_REND_COMMON_INCLUDED
#define CONFUSEDGAMEDEV_DIMENSIONAL_REND_COMMON_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl"

#define REND_RELEASE 1.0
#define REND_EXIT 1.2

// Shared deterministic paths keep the cuts, halos and debris aligned.
float Rh(float n)
{
    return frac(sin(n * 127.1 + 32.36308927) * 43758.5453);
}

float Rl(float i)
{
    return 1.35 + Rh(i + 71.0) * 2.05;
}

float Rw(float i)
{
    return 0.036 + Rh(i + 89.0) * 0.024;
}

float Rb(float i)
{
    return 0.2 + 0.36 * i / max(1.0, _Quantity - 1.0);
}

// Seeded per-cut height and apex skew: needles, wedges and oblique triangles.
float2 RendPanel(float i, float x, float side)
{
    float taper = (1.0 - x) * 0.5;
    float height = (Rw(i) * 18.0 + 0.18) * lerp(0.117, 0.5, Rh(i + 151.0));
    float skew = lerp(-0.65, 1.65, Rh(i + 173.0));
    return float2(x + side * taper * skew, side * taper * height);
}

// The cut's frame. Rows are the source's columns, so mul(v, frame) is its frame * v.
float3x3 Rf(float i)
{
    float a = i < 0.5 ? 0.38 : Rh(i + 109.0) * 6.283185;
    float tilt = i < 0.5 ? 0.12 : (Rh(i + 93.0) - 0.5) * 2.4;
    float twist = (Rh(i + 19.0) - 0.5) * 2.6;
    float3 d = normalize(float3(cos(a), sin(a), tilt));
    float3 s = normalize(cross(float3(0.0, 0.0, 1.0), d));
    float3 n = cross(d, s);
    s = s * cos(twist) + n * sin(twist);
    return float3x3(d, s, cross(d, s));
}

float3 Rc(float i)
{
    float3 c = float3(Rh(i + 11.0) - 0.5, 0.0, Rh(i + 57.0) - 0.5) * float3(3.6, 0.0, 2.8) * _Spread;
    if (i < 0.5)
    {
        c.xz = float2(0.0, 0.0);
    }

    // The local origin is the ground anchor: each cut's lower end stays close to it.
    c.y = abs(Rf(i)[0].y) * Rl(i) * _EffectSize + (i < 0.5 ? 0.04 * _EffectSize : 0.10 * _EffectSize + Rh(i + 31.0) * 0.45 * _Spread);
    return c;
}

float3 RendPanelCenter(float i)
{
    float3 c = float3((Rh(i + 211.0) - 0.5) * 3.6, 0.0, (Rh(i + 239.0) - 0.5) * 2.8) * _Spread;
    c.y = abs(Rf(i)[0].y) * Rl(i) * _EffectSize + (0.03 + Rh(i + 263.0) * 0.42) * _EffectSize;
    return c;
}

float RendShardScale(float4 seed)
{
    return seed.w < 0.58 ? lerp(0.9, 1.2, seed.z) : lerp(0.2, 0.4, seed.z);
}

float3 RendShardShape(float4 seed)
{
    float lengthScale = lerp(0.65, 2.4, Rh(seed.x * 997.0 + 307.0));
    float widthScale = lerp(0.2, 1.4, Rh(seed.y * 997.0 + 331.0));
    float apex = lerp(-1.4, 1.4, Rh(seed.z * 997.0 + 359.0)) * 0.577350269 * lengthScale;
    return float3(lengthScale, widthScale, apex);
}

// A positive top width gives a convex trapezoid; zero merges the top corners into a triangle.
float3 RendShardVertex(float2 corner, float3 shape, float4 seed)
{
    float top = step(0.0, corner.y);
    float topWidth = seed.x < 0.5 ? 0.0 : lerp(0.35, 1.1, Rh(seed.w * 997.0 + 383.0));
    return float3(corner.x * shape.x * lerp(1.0, topWidth, top) + top * shape.z, corner.y * shape.y, 0.0);
}

float RendShardRadius(float3 shape, float4 seed)
{
    float h = 0.577350269;
    return max(max(length(RendShardVertex(float2(-h, -h), shape, seed)), length(RendShardVertex(float2(h, -h), shape, seed))),
        max(length(RendShardVertex(float2(h, h), shape, seed)), length(RendShardVertex(float2(-h, h), shape, seed))));
}

float3 RendCenter()
{
    float3 center = float3(0.0, 0.0, 0.0);
    int count = (int)_Quantity;
    for (int j = 0; j < count; j++)
    {
        center += Rc(_Quantity - 1.0 - j);
    }
    return center / max(1.0, _Quantity);
}

// Screen direction of a source-axis direction, in the same space as ComputeScreenPos.
float2 ScreenShift(float3 direction)
{
    float2 shift = mul(UNITY_MATRIX_P, float4(SourceDirToView(direction), 0.0)).xy;
    shift.y *= _ProjectionParams.x;
    return shift;
}

// The opaque scene, shifted along the cut. It fades near the viewport's edges instead of smearing one row.
float3 DisplacedScene(float4 screen, float2 shift, float strength)
{
    float2 uv = screen.xy / screen.w;
    float2 resolution = max(_ScreenParams.xy, float2(1.0, 1.0));
    float2 direction = shift * resolution;
    direction = length(direction) > 0.0001 ? normalize(direction) : float2(1.0, 0.0);
    float2 inset = 0.5 / resolution;
    float edge = max(0.0, min(min(uv.x - inset.x, 1.0 - inset.x - uv.x), min(uv.y - inset.y, 1.0 - inset.y - uv.y)));
    float amount = 0.032 * clamp(_EffectDetail, 0.25, 2.0) * strength;
    amount *= smoothstep(0.0, max(0.08, abs(amount) * 1.25), edge);
    float2 delta = direction * min(resolution.x, resolution.y) / resolution * amount;
    return SampleSceneColor(clamp(uv + delta, inset, 1.0 - inset));
}

#endif
