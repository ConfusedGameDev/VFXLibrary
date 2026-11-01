#ifndef CONFUSEDGAMEDEV_VFX_BEAM_FLARE_INCLUDED
#define CONFUSEDGAMEDEV_VFX_BEAM_FLARE_INCLUDED

// Billboard flares at both ends, chosen by VFX_VARIANT. UV1 holds the end's x and its role, 0 at the
// source and 1 at the target. Include after VfxBeam.hlsl.

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
    float role : TEXCOORD1;
    float3 stagePosition : TEXCOORD2;
    UNITY_VERTEX_OUTPUT_STEREO
};

Varyings Vert(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    output.uv = input.uv;
    output.role = input.data.y;

    float3 positionVS = SourceToView(float3(input.data.x, 0.0, 0.0));
    positionVS.xy += input.positionOS.xy * RootScale();
    output.positionCS = StageViewToClip(positionVS, output.stagePosition);
    return output;
}

float4 Frag(Varyings input) : SV_Target
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    float t = _EffectTime;
    float role = input.role;
    float2 p = input.uv * 2.0 - 1.0;
    float r = length(p);
    float a = atan2(p.y, p.x);
    float halo = exp(-r * r * 7.5) * 0.5;
    float core = exp(-r * r * 75.0);
    float alpha;

#if VFX_VARIANT == 0
    float aperture = Band(r - 0.34, 0.022) * (0.45 + 0.55 * pow(abs(cos(a * 3.0 - t * 1.4)), 8.0));
    float splash = pow(max(0.0, cos(a * 7.0 + sin(a * 11.0 + t * 6.0))), 14.0) * exp(-r * 4.2);
    alpha = core + halo * 0.65 + (role < 0.5 ? aperture : splash) * 0.7;
#elif VFX_VARIANT == 1
    float cycle = frac(t * 1.2 - role * 0.38);
    alpha = core * 0.6 + halo * 0.35 + Band(r - cycle * 0.85, 0.026) * (1.0 - cycle) * 0.85;
    alpha += pow(max(0.0, cos(a * 4.0 - t)), 18.0) * exp(-r * 5.0) * 0.35;
#elif VFX_VARIANT == 2
    float impact = smoothstep(1.61, 1.65, t);
    if (role < 0.5)
    {
        float intake = frac(r * 2.5 + t * 1.1);
        float iris = pow(max(0.0, cos(a * 5.0 - r * 9.0 + t * 2.5)), 12.0);
        alpha = (core * 1.2 + halo * 0.65 + iris * exp(-r * 3.5) * 0.65 + Band(intake - 0.5, 0.055) * (1.0 - r) * 0.25) * (0.1 + min(t / 1.52, 1.0));
    }
    else
    {
        float turbulence = Noise2(p * 7.0 + float2(t * 2.0, -t * 3.0));
        float ringDistance = (r - 0.28 - (turbulence - 0.5) * 0.14) * 12.0;
        float corona = exp(-ringDistance * ringDistance);
        float shock = frac(max(0.0, t - 1.62) * 1.7);
        alpha = (core * 1.5 + halo * 0.5 + corona * 0.5 + Band(r - shock * 0.88, 0.026) * sin(shock * VFX_PI) * 0.65) * impact;
    }
#else
    float jitter = Noise2(float2(cos(a), sin(a)) * 7.0 + floor(t * 18.0));
    float forks = pow(max(0.0, cos(a * (role < 0.5 ? 5.0 : 11.0) + jitter * 4.0)), 24.0);
    core = exp(-r * r * 100.0);
    halo = exp(-r * r * 5.5);
    float streak = exp(-p.y * p.y * 1100.0) * exp(-abs(p.x) * 5.0);
    alpha = core + halo * 0.42 + forks * exp(-r * 9.0) * 0.55 + streak * 0.18;
#endif

    alpha *= 1.0 - smoothstep(0.85, 1.0, r);
    alpha *= (0.88 + sin(t * 17.0) * 0.12) * _EffectDetail;

#if VFX_VARIANT == 3
    float3 color = _EffectColor.rgb * (0.9 + core) + core * 1.7;
#else
    float3 color = _EffectColor.rgb * (1.1 + core) + core * 0.45;
#endif

    return float4(color, saturate(alpha) * StageAlpha(input.stagePosition));
}

#endif
