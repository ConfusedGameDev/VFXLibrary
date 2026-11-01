#ifndef CONFUSEDGAMEDEV_PLASMA_BOLT_RIBBON_INCLUDED
#define CONFUSEDGAMEDEV_PLASMA_BOLT_RIBBON_INCLUDED

// Jittering electric ribbons. The envelope wraps the core and scales with it, the trails reach backward.

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
    float fade : TEXCOORD1;
    float3 stagePosition : TEXCOORD2;
    UNITY_VERTEX_OUTPUT_STEREO
};

float3 MainPoint(float h, float id)
{
    float t = _EffectTime;
#if RIBBON_ENVELOPE
    float a = id * 1.256637 + h * 1.8;
#else
    float a = id * 1.256637 + h * 0.5;
#endif
    float tick = floor(t * 12.0 + id * 0.7);
    float cell = h * 22.0;
    float j = lerp(Hash(float2(floor(cell), tick + id)), Hash(float2(floor(cell) + 1.0, tick + id)), frac(cell)) - 0.5;
    float coarse = h * 6.0;
    float bend = lerp(Hash(float2(floor(coarse) + id * 11.0, tick)), Hash(float2(floor(coarse) + 1.0 + id * 11.0, tick)), frac(coarse)) - 0.5;
#if RIBBON_ENVELOPE
    float r = sin(h * VFX_PI) * (0.42 + bend * 0.75 + j * 0.14);
    return float3(0.79 - h * 1.52, cos(a) * r, sin(a) * r);
#else
    float r = sin(h * VFX_PI) * (0.34 + id * 0.095 + bend * 0.75 + j * 0.14);
    float attach = lerp(_EffectSize, 1.0, smoothstep(0.0, 0.65, h));
    return float3(
        0.85 + 0.65 * _EffectSize - h * (3.0 + sin(id * 3.1) * 0.35) - 0.65 * (_EffectSize - 1.0) * smoothstep(0.0, 1.0, h),
        cos(a) * r * attach,
        sin(a) * r * attach);
#endif
}

float3 PointAt(float h, float id, float branch)
{
    if (branch < 0.5)
    {
        return MainPoint(h, id);
    }

    float root = 0.36 + Mod(id, 3.0) * 0.12;
    float a = id * 1.256637 + root * 1.8;
    return MainPoint(root, id)
        + float3(-0.65 * h, cos(a) * h * 0.55, sin(a) * h * 0.55)
        + float3(0.0, sin(h * 19.0 + floor(_EffectTime * 14.0) + id) * 0.08, sin(h * 23.0 + id) * 0.065) * sin(h * VFX_PI);
}

float3 RootPoint(float3 p)
{
#if RIBBON_ENVELOPE
    return p * _EffectSize + float3(0.85, 0.0, 0.0);
#else
    return p;
#endif
}

Varyings Vert(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    output.uv = input.uv;
    float h = input.positionOS.x;
    float id = input.positionOS.y;
    float branch = input.data.x;
    float t = _EffectTime;

    float3 positionVS = SourceToView(RootPoint(PointAt(h, id, branch)));
    float3 before = SourceToView(RootPoint(PointAt(max(0.0, h - 0.002), id, branch)));
    float3 after = SourceToView(RootPoint(PointAt(min(1.0, h + 0.002), id, branch)));
    float2 delta = after.xy - before.xy;
    float2 side = length(delta) < 0.00001 ? float2(0.0, 1.0) : normalize(float2(-delta.y, delta.x));

#if RIBBON_ENVELOPE
    float width = id < 2.0 ? 0.30 : 0.16;
    float reach = _EffectSize;
    float fade = (id < 2.0 ? 0.85 : 0.5) * (0.6 + 0.4 * Hash(float2(id, floor(t * 15.0 + id))));
#else
    float width = id < 0.5 ? 0.48 : 0.23;
    float reach = lerp(_EffectSize, 1.0, smoothstep(0.0, 0.65, h));
    float pulse = 0.65 + 0.35 * pow(max(0.0, cos(h * 24.0 - t * 13.0 + id)), 8.0);
    float fade = (id < 0.5 ? 1.0 : 0.55) * pulse;
#endif

    width *= lerp(1.0, 0.12, h) * (0.8 + 0.2 * sin(h * 39.0 + id));
    if (branch > 0.5)
    {
        width *= 0.38 * (1.0 - h * 0.8);
    }
    positionVS.xy += side * input.positionOS.z * width * reach * RootScale();

    fade *= 1.0 - smoothstep(0.65, 1.0, h);
    if (branch > 0.5)
    {
        fade *= 0.3 + 0.7 * step(0.4, Hash(float2(id, floor(t * 12.0 + id))));
    }
    output.fade = fade;

    output.positionCS = StageViewToClip(positionVS, output.stagePosition);
    return output;
}

float4 Frag(Varyings input) : SV_Target
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    float d = abs(input.uv.y * 2.0 - 1.0);
    float core = 1.0 - smoothstep(0.12, 0.28, d);
    float edge = exp(-d * d * 12.0);
    float halo = exp(-d * d * 3.5);
    float a = max(core, edge * 0.65 + halo * 0.38) * (1.0 - smoothstep(0.75, 1.0, d)) * input.fade;
    float3 blue = pow(abs(_EffectColor.rgb), 2.2) * float3(0.12, 0.65, 2.2);
    float3 c = lerp(blue, float3(0.75, 0.95, 1.0) * 1.5, core);
    return float4(c, saturate(a * _EffectDetail) * StageAlpha(input.stagePosition));
}

#endif
