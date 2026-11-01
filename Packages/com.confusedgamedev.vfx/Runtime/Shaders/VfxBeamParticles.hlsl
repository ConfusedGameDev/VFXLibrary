#ifndef CONFUSEDGAMEDEV_VFX_BEAM_PARTICLES_INCLUDED
#define CONFUSEDGAMEDEV_VFX_BEAM_PARTICLES_INCLUDED

// Quad particles of the four original beams, chosen by VFX_VARIANT. Include after VfxBeam.hlsl.

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
    float3 stagePosition : TEXCOORD2;
    UNITY_VERTEX_OUTPUT_STEREO
};

Varyings Vert(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    output.uv = input.uv;
    if (input.id.x >= _ParticleCount)
    {
        return output;
    }

    float4 seed = input.seed;
    float t = _EffectTime;
    float a = seed.x * VFX_PI * 2.0;
    float r = sqrt(seed.z);
    float phase = frac(seed.y + t * 1.7);

    float3 p;
    float2 shape;
    float size = 0.05 + seed.w * 0.06;
    float alpha;

    if (seed.x < 0.26)
    {
        p = float3(-2.4 + phase * 0.45 / _Stretch, cos(a) * phase * 0.4, sin(a) * phase * 0.4);
        alpha = 1.0 - phase;
        size = 0.04;
        shape = float2(2.0, 0.65);
    }
    else if (seed.x > 0.58)
    {
        float spread = phase * (0.3 + seed.z * 0.8);
        p = float3(2.4 - phase * (0.2 + seed.w * 0.65) / _Stretch, cos(a) * spread, sin(a) * spread);
        alpha = pow(abs(1.0 - phase), 1.3);
        shape = float2(1.0, 3.0);
        size = 0.025 + seed.w * 0.045;
    }
    else
    {
        p = float3((phase - 0.5) * 4.8, cos(a + t * 4.0) * 0.12 * r, sin(a + t * 4.0) * 0.12 * r);
        alpha = 0.6;
        shape = float2(2.7, 0.5);
    }

#if VFX_VARIANT == 2
    float charge = min(t / 1.52, 1.0);
    float release = smoothstep(1.52, 1.60, t);
    if (seed.x < 0.58)
    {
        float incoming = frac(seed.y + t * (0.45 + charge * 0.6));
        float radius = (1.0 - incoming) * (0.35 + seed.z * 0.75);
        float angle = a - t * 2.0;
        p = float3(-2.4 - (1.0 - incoming) * 0.7 / _Stretch, cos(angle) * radius * _EffectSize, sin(angle) * radius * _EffectSize);
        alpha = sin(incoming * VFX_PI) * (0.25 + charge * 0.75) * (1.0 - release * 0.4);
        shape = float2(2.2, 0.5);
    }
    else
    {
        alpha *= release;
        size *= 0.7 + release * 0.6;
        p.yz *= 1.0 + release * 0.35;
    }
#elif VFX_VARIANT == 3
    // Short, staggered needles leave the electrodes.
    float end = seed.x < 0.32 ? -1.0 : 1.0;
    phase = frac(seed.y + t * (1.1 + seed.w * 0.8));
    float travel = phase * (0.45 + seed.z * 0.75) * _EffectSize;
    p = float3(end * 2.4 - end * travel * 0.28 / _Stretch, cos(a) * travel, sin(a) * travel);
    size = (0.025 + seed.z * 0.045) * _EffectSize;
    shape = float2(0.38, 4.2);
    alpha = pow(abs(1.0 - phase), 2.0) * smoothstep(0.0, 0.055, phase) * (1.0 - step(0.10, seed.w));
#endif

    output.alpha = alpha;
    float3 positionVS = SourceToView(p);
    positionVS.xy += input.positionOS.xy * size * shape * RootScale();
    output.positionCS = StageViewToClip(positionVS, output.stagePosition);
    return output;
}

float4 Frag(Varyings input) : SV_Target
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    float2 q = input.uv * 2.0 - 1.0;
    float d = length(q);
    clip(1.0 - d);

    float alpha = exp(-d * d * 5.0) * (1.0 - smoothstep(0.65, 1.0, d));
    float3 color = lerp(_EffectColor.rgb, float3(1.0, 1.0, 1.0), pow(abs(1.0 - d), 8.0) * 0.35);
    return float4(color, saturate(alpha * input.alpha * _EffectDetail) * StageAlpha(input.stagePosition));
}

#endif
