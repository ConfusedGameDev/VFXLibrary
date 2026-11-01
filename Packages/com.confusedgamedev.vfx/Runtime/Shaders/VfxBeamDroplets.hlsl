#ifndef CONFUSEDGAMEDEV_VFX_BEAM_DROPLETS_INCLUDED
#define CONFUSEDGAMEDEV_VFX_BEAM_DROPLETS_INCLUDED

// Small tetrahedra that follow a stream, flowing back on variant 5 and forward on variant 6. They use the
// _ParticleCount pool and stop being born at the stop moment. Include after VfxBeamUtility.hlsl.

struct Attributes
{
    float3 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float4 seed : TEXCOORD1;
    float2 id : TEXCOORD2;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float3 normalVS : TEXCOORD0;
    float alpha : TEXCOORD1;
    UNITY_VERTEX_OUTPUT_STEREO
};

Varyings Vert(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    if (input.id.x >= _ParticleCount)
    {
        return output;
    }

    float4 seed = input.seed;
    float t = _EffectTime;
    float size = 0.009 + seed.w * 0.016;
    float a = seed.x * 6.283185;
    float travel = 0.62;
    float cycle = t / travel + seed.y;
    float f = frac(cycle);
    float birth = (floor(cycle) - seed.y) * travel;
    float stopTime = StopTime();
    float live = step(0.0, birth) * (stopTime < 0.0 ? 1.0 : 1.0 - step(stopTime + 0.00001, birth));

    float3 p;
#if VFX_VARIANT == 5
    float path = 1.0 - f;
    float lane = floor(seed.z * 3.0) * 2.0944;
    p = float3(2.4 - f * 4.8, sin(path * 3.0 + lane) * sin(f * 3.14159) * 0.34, cos(path * 3.0 + lane) * sin(f * 3.14159) * 0.34);
    size *= 0.6;
    float strength = 0.45;
#else
    p = float3(-2.4 + f * 4.8, cos(a) * (0.08 + f * 0.46) * seed.z, sin(a) * (0.08 + f * 0.46) * seed.z);
    size *= 1.2;
    float strength = 0.55;
#endif

    p.yz *= _EffectSize;
    output.alpha = live * smoothstep(0.0, 0.08, f) * (1.0 - smoothstep(0.78, 1.0, f)) * FadeEnd() * smoothstep(0.42, 0.90, seed.w) * strength;

    float3 q = input.positionOS * size * _EffectSize;
    q.x /= _Stretch;
    p += q;

    output.normalVS = TransformWorldToViewDir(TransformObjectToWorldNormal(ToUnity(input.normalOS)), false);
    output.positionCS = TransformObjectToHClip(ToUnity(p));
    return output;
}

float4 Frag(Varyings input) : SV_Target
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    clip(input.alpha - 0.003);
    float light = dot(normalize(input.normalVS), normalize(float3(-0.4, 0.8, 0.55))) * 0.5 + 0.5;
    float3 color = lerp(_EffectColor.rgb * 0.65, lerp(_EffectColor.rgb, float3(1.0, 1.0, 1.0), 0.65), step(0.48, light));
    return float4(color, saturate(input.alpha * 0.82));
}

#endif
