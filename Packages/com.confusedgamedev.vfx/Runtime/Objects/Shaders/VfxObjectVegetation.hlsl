#ifndef CONFUSEDGAMEDEV_VFX_OBJECT_VEGETATION_INCLUDED
#define CONFUSEDGAMEDEV_VFX_OBJECT_VEGETATION_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

// The source's painted plants. Positions work in its axes, as in the effects, and every brush shape
// is an opaque cutout, so the colour, depth and shadow passes share VegetationShape.
CBUFFER_START(UnityPerMaterial)
    float4 _Primary;
    float4 _Secondary;
    float4 _Accent;
    float _Paint;
CBUFFER_END

float3 _LightDirection;
float3 _LightPosition;

struct VegetationAttributes
{
    float3 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float2 uv : TEXCOORD0;
    float4 brush : TEXCOORD1;
    float2 root : TEXCOORD2;
    float4 leaf : TEXCOORD3;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct VegetationVaryings
{
    float4 positionCS : SV_POSITION;
    float2 uv : TEXCOORD0;
    float4 brush : TEXCOORD1;
    float3 local : TEXCOORD2;
    float3 normalWS : TEXCOORD3;
    float leafVisibility : TEXCOORD4;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

float2 WindAt(float2 root, float phase, float time)
{
    float wave = sin(dot(root, float2(1.1, 0.7)) - time * 1.45);
    float gust = 0.5 + 0.5 * sin(dot(root, float2(0.48, -0.31)) - time * 0.63);
    float flutter = sin(time * 2.6 + phase + root.x * 3.0) * 0.025;
    return float2(0.12 + wave * 0.11 + gust * 0.13, 0.035 + wave * 0.045 + flutter);
}

float3 LeafTurn(float3 p, float roll, float pitch, float yaw)
{
    p = float3(cos(roll) * p.x - sin(roll) * p.y, sin(roll) * p.x + cos(roll) * p.y, p.z);
    p = float3(p.x, cos(pitch) * p.y - sin(pitch) * p.z, sin(pitch) * p.y + cos(pitch) * p.z);
    return float3(cos(yaw) * p.x + sin(yaw) * p.z, p.y, -sin(yaw) * p.x + cos(yaw) * p.z);
}

float3 AnimatePlant(VegetationAttributes input, out float3 normal, out float leafVisibility)
{
    float time = _Time.y;
    float3 position = input.positionOS.zyx;
    float4 brush = input.brush;
    float4 leaf = input.leaf;
    float3 p = position;
    normal = input.normalOS.zyx;
    leafVisibility = 1.0;

    if (brush.x > 8.5)
    {
        float seed = brush.y;
        float duration = 8.0 + 4.0 * frac(seed * 13.37);
        float cycle = frac(time / duration + leaf.w);
        float landing = saturate((cycle - 0.58) / 0.20);
        float settle = smoothstep(0.0, 1.0, landing);
        float angle = seed * 6.283185;
        // Integral of 1-smoothstep: arrival speed eases to zero without reversing.
        float flight = saturate((min(cycle, 0.58) + 0.20 * (landing - pow(landing, 3.0) + 0.5 * pow(landing, 4.0))) / 0.68);
        float landingPitch = 1.5707963 + 3.14159265 * floor((angle + 9.0 - 1.5707963) / 3.14159265 + 0.5);
        float roll = sin(flight * 10.0 + angle) * 0.65 * (1.0 - settle);
        float pitch = lerp(angle, landingPitch, flight);
        float yaw = angle + flight * (2.0 + seed * 3.0);
        float3 corner = position - leaf.xyz;
        float3 center = leaf.xyz;
        float reach = 0.25 + 0.4 * frac(seed * 17.7);
        float sway = 0.14 * sin(flight * 12.56637 + angle) * sin(flight * 3.141593);
        center.xz += float2(cos(angle), sin(angle)) * reach * flight + float2(-sin(angle), cos(angle)) * sway;
        float verticalExtent = abs(cos(pitch)) * (abs(sin(roll) * corner.x) + abs(cos(roll) * corner.y));
        center.y = 0.012 + leaf.y * (1.0 - flight) + verticalExtent + 0.035 * sin(flight * 12.56637 + angle) * sin(flight * 3.141593);
        p = center + LeafTurn(corner, roll, pitch, yaw);
        normal = LeafTurn(normal, roll, pitch, yaw);
        leafVisibility = smoothstep(0.0, 0.045, cycle) * (1.0 - smoothstep(0.86, 0.98, cycle));
    }
    else
    {
        p.xz += WindAt(input.root, input.root.x * 3.0 + input.root.y, time) * brush.w * 0.38;
    }

    return p;
}

// Discards everything outside the brush shape and returns its base colour.
float3 VegetationShape(VegetationVaryings input, out float vein, out float leafEdge)
{
    float kind = input.brush.x;
    float seed = input.brush.y;
    float shade = input.brush.z;
    float x = input.uv.x * 2.0 - 1.0;
    float h = input.uv.y;
    float stroke = sin(h * 23.0 + sin(h * 9.0 + seed * 11.0) * 2.2 + seed * 31.0);
    float3 base;
    vein = 0.0;
    leafEdge = 0.0;

    if (kind > 8.5)
    {
        // Surface-anchored brush grains remove pixels, never introducing transparent sorting.
        float2 grainCell = floor(input.uv * float2(22.0, 28.0));
        float dissolve = frac(sin(dot(grainCell, float2(127.1, 311.7)) + seed * 17.0) * 43758.5453) * 0.7 + h * 0.3;
        clip(input.leafVisibility - dissolve - 1e-5);
    }

    if (kind > 8.5 && kind < 9.5)
    {
        float y = (h - 0.5) * 2.0;
        float width = max(0.035, 1.0 - y * y);
        float edge = abs(x) / width;
        float rim = 0.91 + 0.065 * sin(y * 33.0 + seed * 19.0);
        clip(abs(y) > 0.99 || edge > rim ? -1.0 : 1.0);
        vein = (1.0 - smoothstep(0.025, 0.075, abs(x))) * 0.6 + step(0.94, cos((y - abs(x) * 0.6) * 24.0)) * 0.25;
        leafEdge = smoothstep(0.72, 0.98, edge);
        base = lerp(_Primary.rgb, _Accent.rgb, smoothstep(0.48, 0.92, shade) * 0.84);
    }
    else if (kind > 7.5)
    {
        // A comb of tapered needles, with an unbroken central twig.
        float reach = 0.88 * pow(1.0 - h, 0.65) + 0.055;
        float side = abs(x);
        float row = frac((h - side * 0.26) * 6.0 + seed * 0.7);
        float needle = abs(row - 0.5);
        float needleWidth = 0.34 * (1.0 - side * 0.48);
        clip(side > reach || (side > 0.065 && needle > needleWidth) ? -1.0 : 1.0);
        vein = (1.0 - smoothstep(0.02, 0.12, needle)) * 0.45;
        leafEdge = smoothstep(0.6, 0.95, side / reach);
        base = lerp(_Primary.rgb, _Accent.rgb, smoothstep(0.63, 0.90, shade) * 0.6 + h * 0.12);
    }
    else if (kind > 6.5)
    {
        // Three pointed, finely notched leaves per spatial brush stroke.
        float2 q = float2(x, (h - 0.5) * 2.0);
        float closest = 10.0;
        float2 leaf = float2(0.0, 0.0);
        for (int i = 0; i < 3; i++)
        {
            float side = float(i) - 1.0;
            float2 p = q - float2(side * 0.39, i == 1 ? 0.27 : -0.26);
            float angle = side * 0.56;
            float c = cos(angle);
            float s = sin(angle);
            p = float2(c * p.x + s * p.y, -s * p.x + c * p.y);
            p /= float2(i == 1 ? 0.40 : 0.33, i == 1 ? 0.67 : 0.51);
            float d = abs(p.x) / max(0.04, 1.0 - p.y * p.y);
            if (d < closest && abs(p.y) < 1.0)
            {
                closest = d;
                leaf = p;
            }
        }
        float rim = 0.93 + 0.065 * sin(leaf.y * 36.0 + seed * 19.0);
        clip(rim - closest);
        vein = (1.0 - smoothstep(0.025, 0.075, abs(leaf.x))) * 0.6;
        vein += step(0.94, cos((leaf.y - abs(leaf.x) * 0.6) * 24.0)) * 0.25;
        leafEdge = smoothstep(0.72, 0.98, closest);
        base = lerp(_Primary.rgb, _Accent.rgb, smoothstep(0.48, 0.92, shade) * 0.84);
    }
    else if (kind > 0.5 && kind < 1.5)
    {
        float2 q = float2(x, (h - 0.5) * 2.0);
        float edge = 0.80 + sin(q.y * 13.0 + seed * 41.0) * 0.09 + sin(q.x * 19.0 + seed * 23.0) * 0.055;
        float shape = pow(abs(q.x), 1.6) + pow(abs(q.y), 1.7);
        clip(shape > edge || (shape > 0.45 && sin(q.y * 25.0 + q.x * 17.0 + seed * 50.0) > 0.94) ? -1.0 : 1.0);
        base = lerp(_Primary.rgb, _Accent.rgb, smoothstep(0.58, 0.86, shade) * 0.80);
    }
    else if ((kind > 1.5 && kind < 2.5) || kind > 5.5)
    {
        float tip = 1.0 - smoothstep(0.70, 1.03, h);
        float rim = 0.89 + stroke * 0.028;
        clip(rim * tip - abs(x + 0.12 * sin(h * 5.0 + seed * 9.0)));
        clip(abs(x) > rim * tip - step(0.94, sin(h * 21.0 + seed * 47.0)) * 0.065 && h > 0.2 ? -1.0 : 1.0);
        base = kind > 5.5 ? _Secondary.rgb * lerp(0.75, 1.15, h) : lerp(_Secondary.rgb, _Primary.rgb, smoothstep(0.1, 0.75, h));
        base = lerp(base, _Accent.rgb, step(0.78, shade) * h * 0.55);
    }
    else if (kind > 2.5 && kind < 3.5)
    {
        clip(0.74 + 0.09 * sin(h * 19.0 + seed * 17.0) - (x * x + pow(abs((h - 0.46) / 0.57), 4.0)));
        base = lerp(_Primary.rgb, _Accent.rgb, smoothstep(0.58, 1.0, h) * 0.18);
    }
    else if (kind > 3.5 && kind < 4.5)
    {
        clip(0.86 - length(float2(x, (h - 0.5) * 2.0)));
        base = _Accent.rgb;
    }
    else
    {
        base = _Secondary.rgb;
    }

    return base;
}

VegetationVaryings VegetationVertex(VegetationAttributes input)
{
    VegetationVaryings output;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    float3 normal;
    float3 p = AnimatePlant(input, normal, output.leafVisibility);
    output.positionCS = TransformObjectToHClip(p.zyx);
    output.normalWS = TransformObjectToWorldNormal(normal.zyx);
    output.uv = input.uv;
    output.brush = input.brush;
    output.local = input.positionOS.zyx;
    return output;
}

float4 VegetationFragment(VegetationVaryings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    float vein;
    float leafEdge;
    float3 base = VegetationShape(input, vein, leafEdge);

    float kind = input.brush.x;
    float seed = input.brush.y;
    float x = input.uv.x * 2.0 - 1.0;
    float h = input.uv.y;
    float3 local = input.local;

    // The source lights plants from a fixed direction, not from the scene.
    float light = 0.58 + 0.42 * max(0.0, dot(normalize(input.normalWS).zyx, normalize(float3(-0.5, 1.0, 0.6))));
    float tone = lerp(0.63, 1.12, smoothstep(0.1, 0.9, input.brush.z));
    float bands = lerp(0.73, 1.12, step(0.53, light + input.brush.z * 0.15));
    float brush = step(0.64, sin(h * 10.0 + seed * 37.0 + x * 2.3));
    float grain = sin(local.x * 173.0 + sin(local.z * 109.0)) * sin(local.y * 149.0 + seed * 7.0);
    float3 paint = base * tone * bands * (1.0 + (brush - 0.5) * 0.12 * _Paint + grain * 0.035 * _Paint);
    if (kind > 6.5)
    {
        paint *= 1.0 + (vein * 0.18 + leafEdge * 0.12) * _Paint;
    }

    if (kind < 0.5)
    {
        float around = input.uv.x * 6.28318;
        float grooves = sin(around * 9.0 + sin(local.y * 5.0 + around * 2.0) * 0.6);
        float cracks = smoothstep(0.77, 0.96, grooves);
        float plates = step(0.88, sin(local.y * 21.0 + around * 2.0));
        float knot = length(float2(sin(around * 1.5) * 2.8, (local.y - 1.05) * 6.0));
        float rings = (1.0 - smoothstep(0.5, 1.8, knot)) * sin(knot * 19.0);
        paint = base * (0.64 + 0.36 * light) * (1.0 + (-cracks * 0.30 - plates * 0.10 + rings * 0.12 + grain * 0.055) * _Paint);
    }

    return float4(lerp(base * light, paint, _Paint), 1.0);
}

VegetationVaryings VegetationShadowVertex(VegetationAttributes input)
{
    VegetationVaryings output = VegetationVertex(input);
    float3 normal;
    float visibility;
    float3 p = AnimatePlant(input, normal, visibility);
    float3 positionWS = TransformObjectToWorld(p.zyx);
#if _CASTING_PUNCTUAL_LIGHT_SHADOW
    float3 lightDirection = normalize(_LightPosition - positionWS);
#else
    float3 lightDirection = _LightDirection;
#endif
    output.positionCS = ApplyShadowClamping(TransformWorldToHClip(ApplyShadowBias(positionWS, output.normalWS, lightDirection)));
    return output;
}

float4 VegetationCutoutFragment(VegetationVaryings input) : SV_Target
{
    float vein;
    float leafEdge;
    VegetationShape(input, vein, leafEdge);
    return input.positionCS.z;
}

float4 VegetationNormalsFragment(VegetationVaryings input) : SV_Target
{
    float vein;
    float leafEdge;
    VegetationShape(input, vein, leafEdge);
    return float4(NormalizeNormalPerPixel(input.normalWS), 0.0);
}

#endif
