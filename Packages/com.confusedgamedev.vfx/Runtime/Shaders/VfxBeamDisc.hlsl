#ifndef CONFUSEDGAMEDEV_VFX_BEAM_DISC_INCLUDED
#define CONFUSEDGAMEDEV_VFX_BEAM_DISC_INCLUDED

// Ring discs facing along the beam at both ends, chosen by VFX_VARIANT. Their vertices are in source
// axes and UV1.x holds the end, -1 or 1. Include after VfxBeam.hlsl.

struct Attributes
{
    float3 positionOS : POSITION;
    float2 uv : TEXCOORD0;
    float4 data : TEXCOORD1;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float2 uv : TEXCOORD0;
    float end : TEXCOORD1;
    float3 stagePosition : TEXCOORD2;
    UNITY_VERTEX_OUTPUT_STEREO
};

Varyings Vert(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    output.uv = input.uv;
    output.end = input.data.x;
    output.positionCS = StageClip(input.positionOS, output.stagePosition);
    return output;
}

float4 Frag(Varyings input) : SV_Target
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    float t = _EffectTime;
    float2 p = input.uv * 2.0 - 1.0;
    float r = length(p);
    float a = atan2(p.y, p.x);
    float alpha;

#if VFX_VARIANT == 0
    alpha = Band(r - 0.58, 0.018) + Band(r - 0.76, 0.008) * step(0.65, sin(a * 8.0 - t));
#elif VFX_VARIANT == 1
    float wave = frac(t * 1.2);
    alpha = Band(r - wave * 0.92, 0.024) * (1.0 - wave) + Band(r - 0.3, 0.018);
#else
    float charge = min(t / 1.52, 1.0);
    float release = smoothstep(1.61, 1.65, t);
    if (input.end < 0.0)
    {
        float iris = pow(max(0.0, cos(a * 5.0 - r * 6.0 - t * 2.5)), 10.0);
        alpha = (Band(r - 0.48, 0.016) + iris * Band(r - 0.64, 0.09)) * charge + exp(-r * r * 18.0) * (0.1 + charge * 0.6);
    }
    else
    {
        float pulse = frac(max(0.0, t - 1.62) * 1.7);
        alpha = (Band(r - 0.48, 0.02) * 0.65 + Band(r - pulse * 0.94, 0.035) * (1.0 - pulse) + pow(max(0.0, cos(a * 9.0 + t * 5.0)), 12.0) * exp(-r * 4.0)) * release;
    }
#endif

    return float4(_EffectColor.rgb * 1.4, saturate(alpha * 0.8 * _EffectDetail) * StageAlpha(input.stagePosition));
}

#endif
