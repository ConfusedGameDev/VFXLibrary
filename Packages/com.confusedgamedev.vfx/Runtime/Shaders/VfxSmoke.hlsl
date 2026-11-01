#ifndef CONFUSEDGAMEDEV_VFX_SMOKE_INCLUDED
#define CONFUSEDGAMEDEV_VFX_SMOKE_INCLUDED

// The one layer of the smokes: lit cloud billboards. Define VFX_VARIANT, the source's, first.
// Variant 3 is a one-shot, which skips the lifecycle.

#define VFX_KIND 5
#include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxFlow.hlsl"

struct Attributes
{
    float3 positionOS : POSITION;
    float2 uv : TEXCOORD0;
    float4 seed : TEXCOORD1;
    float2 id : TEXCOORD2;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float2 uv : TEXCOORD0;
    float alpha : TEXCOORD1;
    float seed : TEXCOORD2;
    UNITY_VERTEX_OUTPUT_STEREO
};

Varyings Vert(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    output.uv = input.uv;
    output.seed = input.seed.w;
    if (input.id.x >= _ParticleCount)
    {
        return output;
    }

    float4 seed = input.seed;
    float t = _EffectTime;
    float a = seed.x * VFX_PI * 2.0;
    float r = sqrt(seed.z);
    float2 shape = float2(1.0, 1.0);

#if VFX_VARIANT == 0
    float h = min(1.0, frac(seed.y + _EmitterTime * 0.15) + _LifeEnd);
    float spread = 0.18 + pow(max(h, 0.0), 0.8) * 0.7;
    float3 p = float3(cos(a + h * 4.0) * r * spread + sin(h * 5.0 + t * 0.4) * 0.25, h * 3.5 - 1.4, sin(a + h * 4.0) * r * spread);
    float size = (0.48 + h * 0.95) * (0.75 + seed.w * 0.45);
    float alpha = sin(h * VFX_PI) * 0.5;
#elif VFX_VARIANT == 1
    float3 p = float3(cos(a + t * 0.08) * r * 2.0, -1.12 + seed.y * 0.45, sin(a + t * 0.08) * r * 1.6);
    float size = 0.9 + seed.w;
    shape = float2(1.5, 0.6);
    float alpha = 0.23;
#elif VFX_VARIANT == 2
    float h = min(1.0, frac(seed.y + _EmitterTime * 0.48) + _LifeEnd);
    float3 p = float3(cos(a + h * 7.0) * h * h * 0.85, h * 3.6 - 1.4, sin(a + h * 7.0) * h * h * 0.65);
    float size = 0.18 + h * 0.9;
    shape = float2(1.0, 1.25);
    float alpha = sin(h * VFX_PI) * 0.34;
#else
    float age = saturate(t / 3.5);
    float expand = 1.0 - exp(-t * 3.2);
    float3 p = float3(cos(a) * r * expand * 1.55, -0.8 + seed.y * expand * 1.6 + age * 0.6, sin(a) * r * expand * 1.55);
    float size = (0.3 + expand * 0.85) * (0.6 + seed.w * 0.6);
    float alpha = smoothstep(0.0, 0.15, t) * pow(max(1.0 - age, 0.0), 1.5) * 0.6;
#endif

    p += CurlFlow(float3(p.x, p.y + 1.4, p.z) * 1.1, t) * 0.16 * smoothstep(0.0, 0.25, p.y + 1.4);
    size *= _EffectSize;

    output.alpha = alpha;
    float3 positionVS = SourceToView(p);
    positionVS.xy += input.positionOS.xy * size * shape * RootScale();
#if VFX_VARIANT == 3
    output.positionCS = TransformWViewToHClip(positionVS);
#else
    output.positionCS = FlowViewToClip(positionVS);
#endif
    return output;
}

float4 Frag(Varyings input) : SV_Target
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    float2 original = input.uv * 2.0 - 1.0;
    float d = length(original);
    clip(1.0 - d);

    float t = _EffectTime;
    float seed = input.seed;
    float angle = seed * 6.28 + t * 0.18;
    float2 q = Spin(original, angle);
    float3 coarse = NoiseGradient(q * 2.8 + float2(seed * 17.0, -t * 0.18));
    float3 fine = NoiseGradient(q * 5.7 + float2(seed * 31.0, -t * 0.31));
    float n = coarse.x * 0.72 + fine.x * 0.28;
    float2 gradient = Spin(coarse.yz * 2.8 * 0.72 + fine.yz * 5.7 * 0.28, -angle);

    float puff = 1.0 - smoothstep(0.43, 1.0, d + (n - 0.5) * 0.43);
    float body = smoothstep(0.14, 0.76, n + (1.0 - d) * 0.55);
    float2 optics = SmokeOptics(original, gradient, n, KeyLight());

#if VFX_VARIANT == 2
    float3 color = _EffectColor.rgb * (0.40 + optics.x * 0.65);
#else
    float3 color = _EffectColor.rgb * optics.x * 1.15;
#endif

    float4 result = float4(color, saturate(puff * body * optics.y * 1.35 * input.alpha * _EffectDetail));
#if VFX_VARIANT == 3
    return result;
#else
    return FlowStaged(result);
#endif
}

#endif
