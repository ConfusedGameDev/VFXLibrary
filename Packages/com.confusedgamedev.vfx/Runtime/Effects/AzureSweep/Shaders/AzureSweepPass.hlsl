#ifndef CONFUSEDGAMEDEV_AZURE_SWEEP_PASS_INCLUDED
#define CONFUSEDGAMEDEV_AZURE_SWEEP_PASS_INCLUDED

// One pass of the sweep. Every layer shares this head and tail clock and this arc. Define SWEEP_LAYER first.

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
    float seed : TEXCOORD1;
    UNITY_VERTEX_OUTPUT_STEREO
};

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
    float taper = pow(max(0.0, sin(x * VFX_PI)), 0.45);
    float angle = -2.35 + along * 5.235987756;
    float radius = 3.0;

#if SWEEP_LAYER == 0
    radius -= (1.0 - input.uv.y) * 0.9 * taper;
#elif SWEEP_LAYER == 1
    radius += (input.uv.y - 0.5) * 0.48 * taper;
#elif SWEEP_LAYER == 2
    radius += (input.uv.y - 0.5) * 0.056 * taper;
#else
    float4 seed = input.seed;
    output.seed = seed.x;
    radius -= (0.09 + seed.x * 0.68) * taper;
    radius += (input.uv.y - 0.5) * (0.012 + seed.y * 0.018) * taper;
    radius += sin(along * 19.0 + seed.z * 6.283 - t * 4.0) * 0.012 * taper;
#endif

    float3 p = float3(cos(angle) * radius, 1.0, sin(angle) * radius);
#if SWEEP_LAYER == 0
    p.y += sin(x * VFX_PI) * (1.0 - input.uv.y) * 0.045;
#elif SWEEP_LAYER == 3
    p.y += 0.025;
#endif

    output.sweep = input.uv;
    output.positionCS = TransformObjectToHClip(ToUnity(p * _EffectSize));
    return output;
}

float4 Frag(Varyings input) : SV_Target
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    float x = input.sweep.x;
    float y = input.sweep.y;
    float t = _EffectTime;
    float fade = smoothstep(0.0, 0.04, t) * (1.0 - smoothstep(0.58, 0.85, t));
    float ends = smoothstep(0.0, 0.035, x) * (1.0 - smoothstep(0.985, 1.0, x));
    float alpha = 0.0;
    float3 tint = _EffectColor.rgb;
    float3 color = tint;

#if SWEEP_LAYER == 0
    float flow = y * 49.0 + x * 8.0 - t * 5.0 + sin(x * 14.0) * 0.45;
    float grain = pow(0.5 + 0.5 * sin(flow), 10.0) * (1.0 - smoothstep(0.6, 2.0, fwidth(flow)));
    float edge = smoothstep(0.0, 0.9, y);
    alpha = (0.08 + 0.35 * edge + grain * 0.12 * _EffectDetail) * smoothstep(0.0, 0.22, y);
    color = lerp(tint * 0.68, tint * 1.1, edge);
#elif SWEEP_LAYER == 1
    float d = abs(y - 0.5) * 2.0;
    alpha = exp(-d * d * 6.0) * (1.0 - smoothstep(0.72, 1.0, d)) * 0.34 * _EffectDetail;
    color = lerp(tint, float3(0.28, 0.85, 1.0), 0.18);
#elif SWEEP_LAYER == 2
    float d = abs(y - 0.5) * 2.0;
    alpha = (1.0 - smoothstep(0.12, 1.0, d)) * 0.98;
    color = lerp(tint, float3(0.85, 1.0, 1.0), 0.80);
#else
    float ribbon = 1.0 - smoothstep(0.1, 1.0, abs(y - 0.5) * 2.0);
    float stream = smoothstep(0.02 + input.seed * 0.12, 0.25 + input.seed * 0.12, x) * (1.0 - smoothstep(0.72 + input.seed * 0.15, 1.0, x));
    alpha = ribbon * stream * (0.26 + 0.16 * _EffectDetail);
    color = lerp(tint, float3(0.3, 0.8, 1.0), 0.28);
#endif

    alpha *= fade * ends;
    clip(alpha - 0.002);
    return float4(color, saturate(alpha));
}

#endif
