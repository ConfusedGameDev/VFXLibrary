#ifndef CONFUSEDGAMEDEV_VFX_VORTEX_INCLUDED
#define CONFUSEDGAMEDEV_VFX_VORTEX_INCLUDED

// Every layer of the toon vortices. Define VFX_VARIANT, the source's, and one of VFX_LAYER_COLUMN, VFX_LAYER_PARTICLES,
// VFX_LAYER_DUST, VFX_LAYER_DEBRIS or VFX_LAYER_GROUND first. Fire and energy reuse the wind's column shape,
// as in the source, so VFX_FLOW is 1 only for the sand's.

#define VFX_KIND 4
#include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxFlow.hlsl"

#if VFX_VARIANT == 1
    #define VFX_FLOW 1
#else
    #define VFX_FLOW 0
#endif

#if defined(VFX_LAYER_COLUMN)

struct Attributes
{
    float3 positionOS : POSITION;
    float2 uv : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float2 uv : TEXCOORD0;
    float light : TEXCOORD1;
    float seed : TEXCOORD2;
    float fade : TEXCOORD3;
    float height : TEXCOORD4;
    float volume : TEXCOORD5;
    UNITY_VERTEX_OUTPUT_STEREO
};

#if VFX_FLOW == 1
// A rolling sand billow in the column, a billboard that density never removes.
void PlaceBillow(Attributes input, float id, float emitter, inout Varyings output)
{
    float t = _EffectTime;
    float retire = _LifeEnd;
    float opening = _LifeStart;
    float r2 = Hash(float2(id, 3.0));
    float r3 = Hash(float2(id, 7.0));

    float h = frac(Hash(float2(id, 23.7)) + emitter * (0.14 + r2 * 0.035));
    float spin = id * 2.399963 - t * (2.0 + r2 * 0.3) + h * 3.0;
    float radius = 0.30 + pow(max(h, 0.0), 1.3) * 1.45 + 0.22 * (1.0 - smoothstep(0.05, 0.55, h));
    float3 p = float3(cos(spin) * radius, h * 3.5, sin(spin) * radius);

    float release = smoothstep(r2 * 0.16, 0.95, retire);
    p.y -= release * release * (1.7 + h * 2.4);
    p.xz *= 1.0 + release * 0.22;

    // Sand curls in along the outside tangent, a little ahead of the column.
    float gather = (1.0 - smoothstep(0.02, 0.78, opening)) * (1.0 - smoothstep(0.0, 0.6, retire));
    p.xz += float2(-sin(spin), cos(spin)) * gather * (1.2 + h * 1.5);
    p.xz *= 1.0 + gather * 0.38;
    p.y += gather * h * 0.35;
    p *= _EffectSize;
    p.y -= 1.4;

    float width = (0.65 + h * 0.75) * (0.88 + r3 * 0.24) * (1.0 + gather * 0.15);
    float3 positionVS = SourceToView(p);
    float2 tangent = normalize(SourceDirToView(float3(-sin(spin), 0.48, cos(spin))).xy + float2(0.0001, 0.0001));
    float2 corner = (input.uv - 0.5) * width * _EffectSize * float2(1.55, 0.56) * RootScale();
    positionVS.xy += tangent * corner.x + float2(-tangent.y, tangent.x) * corner.y;

    output.height = h;
    output.fade = smoothstep(0.0, 0.12, opening) * smoothstep(0.0, 0.09, h) * (1.0 - smoothstep(0.88, 1.0, h)) * (1.0 - smoothstep(0.72, 1.0, retire));
    output.fade *= smoothstep(-1.5, -1.12, p.y);
    output.positionCS = TransformWViewToHClip(positionVS);
}
#endif

Varyings Vert(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    output.uv = input.uv;
    float s = input.positionOS.x;
    float across0 = input.positionOS.y;
    float id = input.positionOS.z;
    float retire = _LifeEnd;
    float opening = _LifeStart;
    float emitter = _EmitterTime;

#if VFX_FLOW == 1
    output.volume = id < 22.0 ? 1.0 : 0.0;
    id = Mod(id, 22.0);
#endif
    output.seed = id;

#if VFX_FLOW == 1
    if (output.volume > 0.5)
    {
        PlaceBillow(input, id, emitter, output);
        return output;
    }
#endif

    float t = emitter + 1.4 * (retire - 0.35 * retire * retire);
    float r1 = Hash(float2(id, 1.0));
    float r2 = Hash(float2(id, 3.0));
    float r3 = Hash(float2(id, 7.0));

#if VFX_FLOW == 1
    float exitAge = smoothstep(0.02 + r2 * 0.34, 0.92, retire);
    s = lerp(s, 0.24 + r3 * 0.45, exitAge * 0.24);
    float phase = Hash(float2(id, 23.7));
    float life = frac(phase + emitter * (0.10 + r2 * 0.025));
    float h = 0.02 + life * 0.52 + s * (0.27 + r3 * 0.21);
    if (Mod(id, 5.0) < 0.5)
    {
        h = 0.025 + s * 0.40;
    }
#else
    // Adjacent sheets share a large eddy; unequal lengths keep their ends from lining up.
    float phase = frac(id * 0.6180339);
    float life = frac(phase + emitter * (0.072 + Hash(float2(id, 8.0)) * 0.025));
    life = min(1.0, life + retire * 0.27);
    float h = 0.025 + life * 0.68 + s * (0.18 + r3 * 0.13);
#endif

    float bend = sin(s * VFX_PI);
    float lean = sin(h * 3.0 + t * 0.45) * h * 0.22;

    // Azimuth stays apart from the lifetime phase: adding both golden angles collapses every start onto one side.
    float a = id * 2.39996323 + s * (3.5 + r2 * 1.2) - t * (2.05 + phase * 0.2);
    a += sin(h * 5.0 - t * 0.65) * 0.28 + bend * sin(s * 4.0 - t * 0.8 + phase * 6.28) * 0.22;
#if VFX_FLOW == 1
    a -= exitAge * (0.2 + r3 * 1.3);
#endif

    float taper = pow(max(0.0, bend), 0.55 + r2 * 0.8);
    float width = (0.045 + h * (0.10 + r1 * 0.17)) * taper;
    if (Mod(id, 6.0) < 0.5)
    {
        width *= 1.8;
    }
    width *= 1.8 + (0.5 + 0.5 * sin(id * 2.3)) * 0.25;
#if VFX_VARIANT == 0
    width *= 0.75;
#elif VFX_VARIANT == 1
    width += 0.08 * taper * (1.0 - h * 0.6);
    width *= 1.2;
#elif VFX_VARIANT == 2
    width *= 1.10;
#else
    width *= 1.23;
#endif

    float curl = bend * sin(s * 6.0 + t * 0.8 + id) * 0.15;
    float radius = (0.08 + pow(max(h, 0.0), 1.35) * 1.2 + pow(max(h, 0.0), 4.0) * 0.65) * (0.72 + r3 * 0.40);
    radius += sin(s * 9.0 - t * 0.9 + id) * 0.07 * h + across0 * width * 0.4;
    radius += 0.22 * (1.0 - smoothstep(0.08, 0.55, h));
#if VFX_FLOW == 1
    radius -= pow(max(h, 0.0), 4.0) * 0.25;
    radius += sin(h * 5.0 - t * 0.9 + id * 0.6) * 0.10 * bend;
#endif

    // Each cross-section rolls into an open crescent, instead of a flat strip.
    float roll = sin(h * 4.5 - t * 0.9 + phase * 2.0) * 0.65 + bend * 0.5;
#if VFX_FLOW == 1
    roll += exitAge * (1.8 + r3) * bend;
#endif
    float across = across0 * 1.9 + roll;
    float center = cos(roll);
    float edge = cos(across);
    radius += (edge - center) * width * 0.95 + sin(h * 7.0 - t * 0.8) * 0.08 * bend;
    float y = h * 3.55 + curl + (sin(across) - sin(roll)) * width * 1.3;
#if VFX_FLOW == 1
    float roundExit = smoothstep(0.04, 0.55, retire);
    radius = lerp(radius, radius - (edge - center) * width * 0.95 + cos(across0 * VFX_PI + roll) * width * 0.7, roundExit);
    y = lerp(y, h * 3.55 + curl + sin(across0 * VFX_PI + roll) * width * 0.7, roundExit);
#endif
    y += sin(h * 4.0 - t * 0.9 + phase * 2.0) * 0.10 * bend;

    float3 p = float3(cos(a) * radius + lean, y, sin(a) * radius);
    p.z += sin(h * 4.0 + t * 0.31) * h * 0.10;
    float3 eddy = CurlFlow(p * 1.1, t);
    p += eddy * (0.07 + h * 0.12);

    float3 surfaceNormal = float3(cos(a) * cos(across), -sin(across), sin(a) * cos(across));
    output.light = saturate(0.45 + dot(surfaceNormal, float3(-0.38, 0.58, 0.72)) * 0.52 + eddy.y * 0.08);

    float2 tangent = float2(-sin(a), cos(a));
#if VFX_FLOW == 1
    p.xz += tangent * exitAge * (0.12 + r2 * 0.32);
    float sag = smoothstep(0.0, 0.7, exitAge) * (0.35 + 0.65 * pow(max(s, 0.0), 1.5));
    p.y -= exitAge * exitAge * (2.4 + r3 * 2.4) + sag * width;
    p.xz *= 1.0 + exitAge * 0.12;
    p.y -= across0 * width * exitAge * 0.5;
#else
    float peel = smoothstep(phase * 0.09, 0.85, retire);
    p.xz += tangent * peel * (0.8 + h * 1.15);
    p.xz *= 1.0 + peel * 0.38;
    p.y += peel * h * 0.35;
#endif
#if VFX_VARIANT >= 2
    p.xz *= 1.20;
    p.y *= 1.08;
#endif

    output.height = h;
    // The ending's loose tangential form, wound back in; the spin keeps running forward.
    float gather = (1.0 - smoothstep(0.04, 1.0, opening)) * (1.0 - smoothstep(0.0, 0.6, retire));
    p.xz += tangent * gather * (0.8 + h * 1.15);
    p.xz *= 1.0 + gather * 0.38;
    p.y += gather * h * 0.35;
    p *= _EffectSize;
    p.y -= 1.4;

    output.fade = smoothstep(0.0, 0.12, opening) * smoothstep(0.0, 0.10, life) * (1.0 - smoothstep(0.85, 1.0, life));
    output.fade *= 1.0 - smoothstep(0.48 + phase * 0.18, 0.88 + phase * 0.1, retire);
#if VFX_FLOW == 1
    output.fade *= smoothstep(-1.4, -1.1, p.y);
#endif

    output.positionCS = TransformObjectToHClip(ToUnity(p));
    return output;
}

#if VFX_FLOW == 1
float4 ShadeBillow(Varyings input)
{
    float t = _EffectTime;
    float2 q = Spin(input.uv * 2.0 - 1.0, -t * 0.8 + input.seed * 0.7);
    float3 n = NoiseGradient(q * 2.4 + float2(input.seed * 9.0, -t * 0.45));
    float d = length(q) + (n.x - 0.5) * 0.35;
    float2 optics = SmokeOptics(q, n.yz * 2.4, n.x, float3(-0.45, 0.8, 0.55));
    float a = (1.0 - smoothstep(0.73, 0.98, d)) * smoothstep(0.02, 0.18, n.x + (1.0 - d) * 0.3) * input.fade * 0.42;
    clip(a - 0.004);
    return float4(StyleColor(_EffectColor.rgb * 0.8, 0.20 + optics.x * 0.44 + n.x * 0.10), saturate(a));
}
#endif

float4 Frag(Varyings input, bool isFront : SV_IsFrontFace) : SV_Target
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

#if VFX_FLOW == 1
    if (input.volume > 0.5)
    {
        return ShadeBillow(input);
    }
#endif

    float3 tint = _EffectColor.rgb;
    float t = _EffectTime;
    float retire = _LifeEnd;
    float seed = input.seed;
    float light = input.light;
    float s = input.uv.x;
    float w = input.uv.y;

    float2 skew = float2(s + w * 0.28, w + s * 0.16);
    float warp = Noise2(skew * float2(8.0, 3.0) + float2(-t * 0.55, seed * 2.3));
    float n = Noise2(float2(s * 7.0 - t * 0.95, w * 2.1 + seed * 3.7 + warp * 0.6));
    float rim = abs(w * 2.0 - 1.0);
    float silhouette = 1.0 - smoothstep(0.56 + n * 0.3, 0.72 + n * 0.28, rim);
#if VFX_VARIANT == 1
    float split = smoothstep(0.28, 0.47, n);
#else
    float split = smoothstep(0.18, 0.36, n);
#endif
    float tip = smoothstep(0.0, 0.04, s) * (1.0 - smoothstep(0.80, 1.0, s));
    float departure = smoothstep(retire * 0.85 - 0.15, retire * 0.85 + 0.08, n * 0.55 + (1.0 - s) * 0.45);
    float alpha = silhouette * split * tip * input.fade * departure;

    float crestOffset = (w - 0.68 - (n - 0.5) * 0.32) * 18.0;
    float crest = exp(-crestOffset * crestOffset);
    float3 c;

#if VFX_VARIANT == 0
    alpha *= 0.6;
    c = StyleColor(tint, 0.15 + light * 0.6 + n * 0.18 + crest * 0.16);
#elif VFX_VARIANT == 1
    float grain = Noise2(float2(s * 21.0, w * 34.0 - t * 2.0 + seed));
    alpha *= lerp(1.0, smoothstep(0.18, 0.40, grain), smoothstep(0.10, 0.55, retire));
    alpha *= smoothstep(retire * 0.55 - 0.08, retire * 0.55 + 0.12, n);
    alpha *= 0.85;
    c = StyleColor(tint * 0.82, 0.20 + light * 0.37 + n * 0.12 + crest * 0.08);
#elif VFX_VARIANT == 2
    float delay = frac(seed * 0.381966) * 0.24 + input.height * 0.16;
    float exitBurn = smoothstep(0.04 + delay, 0.80 + delay * 0.25, retire);
    alpha *= smoothstep(-0.03, 0.10, n * 0.60 + sin(s * VFX_PI) * 0.4 - exitBurn * 0.82);
    alpha *= 1.0 - smoothstep(0.60, 0.95, retire + frac(seed * 0.23) * 0.15);
    float fireNoise = Noise2(float2(w * 4.0 + seed, s * 11.0 - t * 2.4));
    alpha *= smoothstep(0.20, 0.40, fireNoise);
    crest = max(crest * 0.45, StyleStep(0.68, fireNoise) * 0.5 * 0.7);
    c = StyleHeat(tint, 0.19 + light * 0.32 + n * 0.33 + crest * 0.11);
    // Unity's front faces wind the opposite way on screen from the source's.
    if (isFront)
    {
        c *= 0.70;
    }
#endif

    // Contour ink in the material: screen-space width, with no outline mesh or full-screen pass.
    float contour = min(0.65 + n * 0.28 - rim, min(s * 5.0, (1.0 - s) * 2.0));
    float pixel = max(fwidth(contour), 0.002);
    alpha *= smoothstep(-pixel, pixel, contour);
    float ink = 1.0 - smoothstep(pixel * 0.5, pixel * 1.9, contour);
    float3 inkColor = lerp(float3(0.012, 0.016, 0.022), tint * 0.055, 0.65);
#if VFX_VARIANT == 0
    c = lerp(c, inkColor, ink * 0.55 * (1.0 - retire * 0.7));
#elif VFX_VARIANT == 1
    c = lerp(c, inkColor, ink * 0.25 * (1.0 - retire * 0.7));
    alpha *= 0.62;
#elif VFX_VARIANT == 2
    c = lerp(c, inkColor, ink * 0.25 * (1.0 - retire * 0.7));
    c = lerp(c, tint * float3(0.22, 0.045, 0.012), smoothstep(0.35, 0.9, retire) * 0.82);
    alpha *= 0.90;
#else
    // Bright bands travel along the curled surface, so interpolated light never makes large lit facets.
    float track = 0.49 + 0.15 * sin(s * 5.0 - t * 0.6 + seed * 1.3);
    float stripe = 1.0 - smoothstep(0.035, 0.15, abs(w - track));
    float chargePhase = frac(s * 2.4 - t * 0.8 + seed * 0.23);
    float pulse = smoothstep(0.05, 0.24, chargePhase) * (1.0 - smoothstep(0.68, 0.94, chargePhase));
    c = StyleColor(tint, 0.29 + light * 0.13 + stripe * (0.24 + pulse * 0.33));
    float cut = smoothstep(0.08, 0.8, retire);
    float islands = smoothstep(0.15 + cut * 0.40, 0.27 + cut * 0.42, Noise2(float2(s * 9.0 - t * 0.6, seed * 2.7)));
    alpha = silhouette * split * tip * input.fade * departure * (0.84 + stripe * 0.10) * islands;
#endif

    return float4(c, saturate(alpha));
}

#elif defined(VFX_LAYER_PARTICLES)

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
    if (input.id.x >= _LayerCounts.x)
    {
        return output;
    }

    float4 seed = input.seed;
    float t = _EffectTime;
    float a = seed.x * VFX_PI * 2.0;
    float h = min(1.0, frac(seed.y + _EmitterTime * 0.3) + (t - _EmitterTime) * 0.55);
    float spin = h * 9.6 - t * 5.28 + a;
    float radius = 0.09 + pow(max(h, 0.0), 1.45) * 1.05 + pow(max(h, 0.0), 4.0) * 0.65;
    radius += 0.22 * (1.0 - smoothstep(0.08, 0.55, h));

    float3 p = float3(cos(spin) * radius, h * 3.6 - 1.4, sin(spin) * radius);
    p.x += sin(h * 2.6 + t * 0.5) * h * 0.35;
    float size = 0.025 + seed.w * 0.04;
    float2 shape = float2(4.0, 0.45);
    float alpha = sin(h * VFX_PI) * 0.5;

#if VFX_VARIANT == 0
    shape = float2(7.0, 0.23);
    size *= 0.8;
    alpha *= 0.65;
#elif VFX_VARIANT == 1
    radius += seed.z * 0.4;
    p.xz = float2(cos(spin), sin(spin)) * radius;
    size = 0.012 + seed.w * 0.035;
    shape = float2(1.0, 0.8);
    alpha *= 0.75;
#elif VFX_VARIANT == 2
    spin = a - t * 2.4;
    float drift = pow(max(h, 0.0), 3.0) * (0.3 + seed.z * 0.8);
    p = float3(cos(spin) * (radius + drift), h * 3.8 - 1.4, sin(spin) * (radius + drift));
    size = 0.016 + seed.w * 0.04;
    shape = float2(0.8, 2.7);
    alpha = sin(h * VFX_PI) * (0.45 + 0.45 * sin(t * 13.0 + seed.z * 19.0));
#else
    h = floor(seed.y * 6.0) / 6.0 + 0.08;
    spin = a - t * 2.4;
    radius = 0.15 + pow(h, 1.2) * 1.8;
    p = float3(cos(spin) * radius, h * 3.5 - 1.4 + sin(spin * 3.0) * 0.07, sin(spin) * radius);
    size = 0.018 + seed.w * 0.03;
    shape = float2(1.0, 1.0);
    alpha = 0.25 + pow(max(0.0, sin(seed.z * 20.0 + t * 3.0)), 4.0) * 0.6;
#endif

    p += CurlFlow(float3(p.x, p.y + 1.4, p.z) * 1.1, t) * 0.12 * smoothstep(0.0, 0.25, p.y + 1.4);
    p.xz *= _EffectSize;
    p.y = (p.y + 1.4) * _EffectSize - 1.4;

    float3 positionVS = SourceToView(p);
    float2 tangent = normalize(SourceDirToView(float3(-sin(spin), 0.1, cos(spin))).xy);
    float2 corner = input.positionOS.xy * shape * size * RootScale();
    positionVS.xy += tangent * corner.x + float2(-tangent.y, tangent.x) * corner.y;

    output.alpha = alpha;
    output.positionCS = FlowViewToClip(positionVS);
    return output;
}

float4 Frag(Varyings input) : SV_Target
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    float2 q = input.uv * 2.0 - 1.0;
    float d = length(q);
    clip(1.0 - d);

#if VFX_VARIANT == 3
    float alpha = 1.0 - smoothstep(0.7, 1.0, abs(q.x) + abs(q.y));
#else
    float alpha = exp(-d * d * 5.0) * (1.0 - smoothstep(0.65, 1.0, d));
#endif

#if VFX_VARIANT == 1
    float3 color = StyleColor(_EffectColor.rgb * 0.55, 0.3 + input.seed * 0.5);
#elif VFX_VARIANT == 2
    float3 color = StyleHeat(_EffectColor.rgb, 0.50 + (1.0 - d) * 0.35);
#else
    float3 color = StyleColor(_EffectColor.rgb, 0.38 + (1.0 - d) * 0.5);
#endif

    return FlowStaged(float4(color, saturate(alpha * input.alpha * _EffectDetail)));
}

#elif defined(VFX_LAYER_DUST)

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
    float seed : TEXCOORD1;
    float fade : TEXCOORD2;
    float inner : TEXCOORD3;
    UNITY_VERTEX_OUTPUT_STEREO
};

// Low dust drawn in from the rim and rolled upward. Its range does not follow the size control.
Varyings Vert(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    output.uv = input.uv;
    output.seed = input.seed.w;
    if (input.id.x >= _LayerCounts.y)
    {
        return output;
    }

    float4 seed = input.seed;
    float t = _EffectTime;
    float rate = 0.15 + seed.w * 0.08;
    float life = min(1.0, frac(seed.y + _EmitterTime * rate) + (t - _EmitterTime) * 0.55);
    float a = seed.x * 6.28318 - t * 1.2 - life * 3.0;
    float roll = life * 6.28318 + seed.z * VFX_PI;
    float arc = sin(life * VFX_PI);
    float r = (2.2 - life * 1.7) * (0.7 + seed.z * 0.5) + cos(roll) * (0.16 + seed.w * 0.18);
    r *= 1.25;
    float lift = (0.22 + sin(roll) * 0.20) * arc + life * life * (0.7 + seed.z * 0.9);

    float3 p = float3(cos(a) * r, lift, sin(a) * r);
    p += CurlFlow(p * 1.1, t) * 0.17 * arc;
    p.y -= 1.36;

    output.inner = exp(-r * r * 0.7) * (1.0 - life * 0.4);
    float size = (0.60 + arc * 0.65) * (0.8 + seed.w * 0.4);
    float3 positionVS = SourceToView(p);
    positionVS.xy += input.positionOS.xy * size * float2(1.25, 1.05) * RootScale();
    output.fade = arc * 0.85;
#if VFX_VARIANT == 0
    output.fade *= 0.55;
#endif
    output.positionCS = FlowViewToClip(positionVS);
    return output;
}

float4 Frag(Varyings input) : SV_Target
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    float3 tint = _EffectColor.rgb;
    float t = _EffectTime;
    float seed = input.seed;
    float2 original = input.uv * 2.0 - 1.0;
    float spin = seed * 6.28 - t * (0.4 + seed * 0.3);
    float2 q = Spin(original, spin);
    float3 broad = NoiseGradient(q * 2.8 + float2(seed * 27.0, -t * 0.25));
    float n = broad.x;
    float2 gradient = Spin(broad.yz * (2.8 * 0.72 + 6.1 * 0.28), -spin);
    float d = length(q) + (n - 0.5) * 0.45;
    float light = SmokeOptics(original, gradient, n, KeyLight()).x;

#if VFX_VARIANT == 0
    float a = (1.0 - smoothstep(0.62, 0.94, d)) * smoothstep(0.20, 0.40, n) * input.fade * 0.80;
#else
    float a = (1.0 - smoothstep(0.70, 0.98, d)) * smoothstep(0.05, 0.22, n + (1.0 - d) * 0.25) * input.fade * 0.73;
#endif

#if VFX_VARIANT == 2
    float3 c = lerp(StyleColor(float3(0.12, 0.09, 0.065), light), StyleHeat(tint, 0.35 + input.inner * 0.4) * 0.48, input.inner * 0.7);
#elif VFX_VARIANT == 3
    float3 c = StyleColor(tint * 0.55, 0.18 + light * 0.6 + input.inner * 0.2);
    a *= 0.45;
#else
    float3 c = StyleColor(tint * 0.48, 0.16 + light * 0.60 + n * 0.2);
#endif

    return FlowStaged(float4(c, saturate(a * _EffectDetail)));
}

#elif defined(VFX_LAYER_DEBRIS)

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
    float fade : TEXCOORD1;
    UNITY_VERTEX_OUTPUT_STEREO
};

// Leaves, grit, embers or runes, flung up around the column.
Varyings Vert(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    output.uv = input.uv;
    if (input.id.x >= _LayerCounts.z)
    {
        return output;
    }

    float4 seed = input.seed;
    float t = _EffectTime;
    float life = min(1.0, frac(seed.y + _EmitterTime * 0.16) + (t - _EmitterTime) * 0.6);
    float a = seed.x * 6.28318 - t * 2.4;
    float r = 0.25 + life * 1.9 + 0.22 * (1.0 - smoothstep(0.08, 0.55, life));

    float3 positionVS = SourceToView(float3(cos(a) * r, -1.25 + life * 3.1, sin(a) * r));
    float2 card = input.positionOS.xy;
#if VFX_VARIANT == 0
    card *= float2(1.0, 0.45);
#elif VFX_VARIANT == 1
    card *= 0.5;
#elif VFX_VARIANT == 2
    card *= float2(0.4, 1.4);
#endif

#if VFX_VARIANT == 3
    float scale = 0.14 + seed.w * 0.15;
#else
    float scale = 0.08 + seed.w * 0.13;
#endif
    positionVS.xy += Spin(card, a + t) * scale * RootScale();
    output.fade = sin(life * VFX_PI);
    output.positionCS = FlowViewToClip(positionVS);
    return output;
}

float4 Frag(Varyings input) : SV_Target
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    float3 tint = _EffectColor.rgb;
    float2 uv = input.uv;
    float2 q = uv * 2.0 - 1.0;

#if VFX_VARIANT == 0
    float a = (1.0 - smoothstep(0.65, 0.95, abs(q.y) + q.x * q.x)) * step(abs(q.y), 0.7 * (1.0 - q.x * q.x));
    float3 c = StyleColor(lerp(float3(0.2, 0.3, 0.08), tint, 0.4), 0.22 + uv.y * 0.6);
#elif VFX_VARIANT == 1
    float a = step(abs(q.x) + abs(q.y) * 0.7, 0.9);
    float3 c = StyleColor(tint * 0.65, 0.2 + uv.y * 0.65);
#elif VFX_VARIANT == 2
    float a = 1.0 - smoothstep(0.65, 0.95, abs(q.y) + q.x * q.x);
    float3 c = StyleHeat(tint, 0.16 + uv.y * 0.75);
#else
    float a = Band(abs(q.x) + abs(q.y) - 0.65, 0.09);
    float3 c = StyleColor(tint, 0.8);
#endif

    return FlowStaged(float4(c, saturate(a * input.fade * _EffectDetail)));
}

#elif defined(VFX_LAYER_GROUND)

struct Attributes
{
    float3 positionOS : POSITION;
    float2 uv : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float2 uv : TEXCOORD0;
    UNITY_VERTEX_OUTPUT_STEREO
};

// The dust shadow swirling on the ground, a fixed disc that size does not scale.
Varyings Vert(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    output.uv = input.uv;
    output.positionCS = FlowClip(float3(input.positionOS.x, -1.38, -input.positionOS.y));
    return output;
}

float4 Frag(Varyings input) : SV_Target
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    float t = _EffectTime;
    float2 p = input.uv * 2.0 - 1.0;
    float r = length(p);
    float a = atan2(p.y, p.x);
    float turn = a - t * 1.7 + r * 4.0;
    float broad = Noise2(float2(cos(turn), sin(turn)) * (2.0 + r * 3.0) + float2(r * 4.0, t * 0.2));
    float fine = Noise2(float2(cos(a - t * 2.4 + r * 7.0), sin(a - t * 2.4 + r * 7.0)) * (5.0 + r * 7.0));
    float ring = (r - 0.42) * 4.0;
    float mask = exp(-ring * ring) * smoothstep(0.18, 0.50, broad * fine);
    return FlowStaged(float4(StyleColor(_EffectColor.rgb * 0.12, 0.18 + broad * 0.65), mask * 0.30));
}

#endif

#endif
