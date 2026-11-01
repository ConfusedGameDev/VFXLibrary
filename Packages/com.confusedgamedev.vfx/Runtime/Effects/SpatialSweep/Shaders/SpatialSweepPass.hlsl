#ifndef CONFUSEDGAMEDEV_SPATIAL_SWEEP_PASS_INCLUDED
#define CONFUSEDGAMEDEV_SPATIAL_SWEEP_PASS_INCLUDED

// One pass of the sweep. Layer 0 bends the scene, the others are its light. Define SWEEP_LAYER first.

#if SWEEP_LAYER == 0
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl"
#endif

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
    float2 sweep : TEXCOORD0;
    float4 screen : TEXCOORD1;
    float2 tangent : TEXCOORD2;
    float2 radial : TEXCOORD3;
    float seed : TEXCOORD4;
    UNITY_VERTEX_OUTPUT_STEREO
};

// A source-axis point's y-up screen position, as ComputeScreenPos gives it.
float2 ScreenPoint(float3 p)
{
    float4 clip = ComputeScreenPos(TransformObjectToHClip(ToUnity(p)));
    return clip.xy / clip.w;
}

Varyings Vert(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

#if SWEEP_LAYER == 3
    if (input.id.x >= _LayerCounts.x)
    {
        return output;
    }
#endif

    float t = _EffectTime;
    float head = lerp(0.012, 1.0, smoothstep(0.08, 0.32, t));
    float tail = smoothstep(0.42, 0.85, t);
    float x = input.uv.x;
    float along = lerp(tail, head, x);

    // A broad leading edge. Only the trailing end stays pointed.
    float taper = max(pow(max(0.0, sin(x * VFX_PI)), 0.45), smoothstep(0.72, 0.96, x));
    float angle = -2.35 + along * 5.235987756;
    float radius = 3.0;

#if SWEEP_LAYER == 0
    radius -= (1.0 - input.uv.y) * 1.6 * taper;
#elif SWEEP_LAYER == 1
    radius += (input.uv.y - 0.5) * 0.32 * taper;
#elif SWEEP_LAYER == 2
    radius += (input.uv.y - 0.5) * 0.040 * taper;
#else
    float4 seed = input.seed;
    output.seed = seed.x;
    radius -= (0.12 + seed.x * 1.22) * taper;
    radius += (input.uv.y - 0.5) * (0.010 + seed.y * 0.012) * taper;
    radius += sin(along * 22.0 + seed.z * 6.283 - t * 12.0) * 0.009 * taper;
#endif

    float3 radial = float3(cos(angle), 0.0, sin(angle));
    float3 p = radial * radius + float3(0.0, 1.0, 0.0);
    output.sweep = input.uv;
    output.positionCS = TransformObjectToHClip(ToUnity(p * _EffectSize));
    output.screen = ComputeScreenPos(output.positionCS);

#if SWEEP_LAYER == 0
    float3 tangent = float3(-sin(angle), 0.0, cos(angle));
    float2 here = output.screen.xy / output.screen.w;
    output.tangent = ScreenPoint((p + tangent * 0.65) * _EffectSize) - here;
    output.radial = ScreenPoint((p + radial * 0.24) * _EffectSize) - here;
#endif
    return output;
}

float SweepFade()
{
    return smoothstep(0.0, 0.04, _EffectTime) * (1.0 - smoothstep(0.58, 0.85, _EffectTime));
}

float SweepEnds(float x)
{
    return smoothstep(0.0, 0.035, x) * (1.0 - smoothstep(0.985, 1.0, x));
}

float4 Frag(Varyings input) : SV_Target
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    float x = input.sweep.x;
    float y = input.sweep.y;
    float t = _EffectTime;

#if SWEEP_LAYER == 0
    float feather = smoothstep(0.0, 0.13, y) * (1.0 - smoothstep(0.90, 1.0, y));
    float coverage = SweepFade() * SweepEnds(x) * feather;
    clip(coverage - 0.002);

    float2 uv = input.screen.xy / input.screen.w;
    float band = sin(y * 66.0 + sin(x * 13.0 - t * 8.0) * 1.25 - t * 19.0);
    float fine = sin(y * 157.0 + x * 17.0 - t * 33.0) * 0.12;
    float shear = (0.20 + 0.80 * smoothstep(0.0, 0.95, x)) * (0.50 + 0.50 * band + fine);

    // The tangential shift stretches the backdrop along the swing; the radial ripple breaks it into pressure bands.
    float2 delta = (input.tangent * (0.20 + shear * 0.95) + input.radial * (band * 0.32 + fine)) * _EffectDetail * coverage;
    float2 inset = 0.5 / max(_ScreenParams.xy, float2(1.0, 1.0));
    float edge = max(0.0, min(min(uv.x - inset.x, 1.0 - inset.x - uv.x), min(uv.y - inset.y, 1.0 - inset.y - uv.y)));
    delta *= smoothstep(0.0, max(0.04, length(delta) * 1.35), edge);
    return float4(SampleSceneColor(clamp(uv + delta, inset, 1.0 - inset)), coverage);
#else
    float d = abs(y - 0.5) * 2.0;
    float intensity = lerp(0.08, 1.0, smoothstep(0.05, 0.92, x));
    float alpha;
    float3 color = _EffectColor.rgb;
#if SWEEP_LAYER == 1
    alpha = exp(-d * d * 7.0) * (1.0 - smoothstep(0.7, 1.0, d)) * 0.18 * _EffectDetail * intensity;
#elif SWEEP_LAYER == 2
    alpha = (1.0 - smoothstep(0.05, 1.0, d)) * 0.98 * intensity;
    color = lerp(_EffectColor.rgb, float3(1.0, 1.0, 1.0), 0.72);
#else
    float stream = smoothstep(0.04 + input.seed * 0.2, 0.35 + input.seed * 0.2, x) * (1.0 - smoothstep(0.78, 1.0, x));
    alpha = (1.0 - smoothstep(0.0, 1.0, d)) * stream * 0.09 * _EffectDetail;
#endif
    alpha *= SweepFade() * SweepEnds(x);
    clip(alpha - 0.002);
    return float4(color, saturate(alpha));
#endif
}

#endif
