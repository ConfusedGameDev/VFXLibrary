#ifndef CONFUSEDGAMEDEV_GOLDEN_CHAIN_RAIN_COMMON_INCLUDED
#define CONFUSEDGAMEDEV_GOLDEN_CHAIN_RAIN_COMMON_INCLUDED

#define _CrackBloom _Motion0.x
#define _CrackBloomSpread _Motion0.y
#define _TextureDensity _Motion0.z

// Four seeded values per chain, for three waves of up to twelve.
static const float4 GcRandom[36] = {
    float4(0.7677765, 0.3852233, 0.9835556, 0.1847950),
    float4(0.1154356, 0.6995531, 0.9244445, 0.1963216),
    float4(0.4920709, 0.5521255, 0.9196983, 0.0997662),
    float4(0.6091704, 0.5202874, 0.5513668, 0.0192688),
    float4(0.6404908, 0.2045524, 0.8804003, 0.6152281),
    float4(0.7682616, 0.7979981, 0.9425611, 0.7498899),
    float4(0.6795832, 0.5082012, 0.8273411, 0.2320370),
    float4(0.5911471, 0.3473386, 0.0430138, 0.7814057),
    float4(0.6303996, 0.0560760, 0.1209428, 0.6034541),
    float4(0.6512771, 0.1768711, 0.6622742, 0.2151062),
    float4(0.8126362, 0.5423163, 0.2801359, 0.4120985),
    float4(0.4975044, 0.6941445, 0.1404703, 0.5185528),
    float4(0.4012753, 0.9985250, 0.0546246, 0.3094004),
    float4(0.8669754, 0.4732726, 0.3268242, 0.2462826),
    float4(0.7957251, 0.5925964, 0.8096530, 0.9175539),
    float4(0.7105206, 0.5850123, 0.8706680, 0.8230105),
    float4(0.8014609, 0.9900446, 0.2232701, 0.8939708),
    float4(0.0305452, 0.4893418, 0.8249592, 0.3893329),
    float4(0.6241655, 0.2778312, 0.2960958, 0.0582330),
    float4(0.5314196, 0.4905383, 0.5622964, 0.7099307),
    float4(0.6763697, 0.4506940, 0.6735864, 0.5815460),
    float4(0.0823704, 0.7547569, 0.0034352, 0.1442724),
    float4(0.1965932, 0.4599745, 0.2808002, 0.2386920),
    float4(0.9928704, 0.8901079, 0.1583031, 0.6798170),
    float4(0.6809850, 0.8249465, 0.2696634, 0.7224829),
    float4(0.1005301, 0.0892355, 0.9795160, 0.0277178),
    float4(0.1274643, 0.8066440, 0.2787352, 0.0207137),
    float4(0.6714874, 0.8343956, 0.5283931, 0.7810245),
    float4(0.0923608, 0.1441893, 0.0054740, 0.8556152),
    float4(0.1132989, 0.1650340, 0.4534732, 0.6353875),
    float4(0.5595555, 0.3536215, 0.0910025, 0.1858075),
    float4(0.5003303, 0.5078647, 0.7815295, 0.6722599),
    float4(0.6221212, 0.5892240, 0.3173737, 0.7707530),
    float4(0.9116468, 0.0694479, 0.0210862, 0.7046015),
    float4(0.9764635, 0.0673531, 0.1173365, 0.7977095),
    float4(0.5814040, 0.7912680, 0.5784332, 0.6850813)
};

struct GcChain
{
    float3 start;
    float3 end;
    float birth;
    float seed;
    float span;
    float count;
};

float GcQuantity()
{
    return clamp(round(_Quantity), 1.0, 12.0);
}

bool GcLoadSlot(float wave, float slot, out GcChain chain)
{
    float q = GcQuantity();
    float spread = clamp(_Spread, 0.5, 2.0);
    float4 r = GcRandom[(int)(wave * 12.0 + slot)];
    float angle = (slot + 0.5) * VFX_PI * 2.0 / q + wave * 0.59 + (r.x - 0.5) * 0.18;
    float endRadius = 3.0 * (0.52 + 0.48 * r.y) * spread;
    float sourceAngle = angle + VFX_PI * (0.60 + 0.36 * r.z);
    float sourceRadius = (2.4 + 0.7 * r.w) * spread;
    chain.birth = wave * 1.1 + (q > 1.0 ? slot / (q - 1.0) : 0.5) * 0.4;
    chain.start = float3(cos(sourceAngle) * sourceRadius, 5.7 + 0.6 * r.z, sin(sourceAngle) * sourceRadius);
    chain.end = float3(cos(angle) * endRadius, 0.0, sin(angle) * endRadius);
    chain.span = length(chain.end - chain.start);
    chain.count = min(72.0, ceil(chain.span / 0.265) + 1.0);
    chain.seed = r.x;
    return slot < q;
}

// A baked index: every slot of every wave has its own instance.
bool GcLoad(float index, out GcChain chain)
{
    float wave = floor((index + 0.5) / 12.0);
    return GcLoadSlot(wave, index - wave * 12.0, chain);
}

// A decorative index, cycling through the active chains.
GcChain GcCycle(float index)
{
    float q = GcQuantity();
    float n = fmod(index, q * 3.0);
    float wave = floor((n + 0.5) / q);
    GcChain chain;
    GcLoadSlot(wave, n - wave * q, chain);
    return chain;
}

void GcBasis(float3 forward, out float3 right, out float3 side)
{
    right = normalize(cross(forward, float3(0.0, 1.0, 0.0)));
    side = normalize(cross(right, forward));
}

float GcPenetration(float age)
{
    float t = saturate((age - 0.35) / 0.08);
    return 0.32 * (1.0 - pow(abs(1.0 - t), 3.0));
}

float GcTipDistance(float age, float span)
{
    return pow(saturate(age / 0.35), 1.5) * span + GcPenetration(age);
}

float3 GcViewToSource(float3 v)
{
    return ToUnity(TransformWorldToObjectDir(mul((float3x3)UNITY_MATRIX_I_V, v)));
}

float2 GcCrackPoint(float2 q, float seed)
{
    float radius = length(q);
    float angle = seed * 6.283185;
    q *= 0.88 + 0.12 * sin((radius > 0.0 ? atan2(q.y, q.x) : 0.0) * 3.0 + seed * 37.0 + radius * 4.0);
    return Spin(q, angle);
}

float GcHash(float2 p)
{
    return frac(sin(dot(p, float2(127.1, 311.7))) * 43758.5453);
}

float GcLiquidHash(float3 p)
{
    p = frac(p * 0.1031);
    p += dot(p, p.yzx + 33.33);
    return frac((p.x + p.y) * p.z);
}

float GcLiquidNoise(float3 p)
{
    float3 i = floor(p);
    float3 f = frac(p);
    f = f * f * (3.0 - 2.0 * f);
    return lerp(lerp(lerp(GcLiquidHash(i), GcLiquidHash(i + float3(1, 0, 0)), f.x), lerp(GcLiquidHash(i + float3(0, 1, 0)), GcLiquidHash(i + float3(1, 1, 0)), f.x), f.y),
        lerp(lerp(GcLiquidHash(i + float3(0, 0, 1)), GcLiquidHash(i + float3(1, 0, 1)), f.x), lerp(GcLiquidHash(i + float3(0, 1, 1)), GcLiquidHash(i + float3(1, 1, 1)), f.x), f.y), f.z);
}

// Warped noise advected over the metal; its contours form liquid caustics.
float3 GcGold(float3 n, float3 toViewer, float3 liquid, float age, float seed, float edge)
{
    float3 light = normalize(float3(-0.35, 0.8, 0.65));
    float diffuse = saturate(dot(n, light) * 0.65 + 0.35);
    float shine = pow(max(0.0, dot(n, normalize(light + toViewer))), 38.0);
    float3 color = _EffectColor.rgb;
    float3 gold = lerp(color * float3(0.075, 0.065, 0.025), color * float3(0.32, 0.28, 0.12), smoothstep(0.13, 0.82, diffuse));
    gold += color * shine * 0.22;
    liquid += float3(-age * 0.58 * _TextureDensity, seed * 3.7, age * 0.26 * _TextureDensity);
    float3 warp = float3(GcLiquidNoise(liquid * 0.73 + float3(0.0, 0.0, age * 0.16)),
        GcLiquidNoise(liquid * 0.73 + float3(13.7, 5.2, -age * 0.19)), GcLiquidNoise(liquid * 0.73 + float3(2.4, 19.1, 8.3)));
    float field = GcLiquidNoise(liquid + warp * 2.1) * 0.88 + GcLiquidNoise(liquid * 2.07 + warp) * 0.12;
    float stream = pow(abs(0.5 + 0.5 * sin(field * 36.0)), 5.0);
    float filament = pow(abs(0.5 + 0.5 * sin(field * 72.0 + warp.x * 2.0)), 12.0);
    gold += color * float3(0.90, 0.80, 0.40) * (stream * 1.38 + filament * 0.34) * (0.6 + 0.4 * diffuse) * min(_EffectDetail, 1.4);
    float impact = exp(-max(0.0, age - 0.35) * 18.0) * step(0.35, age);
    gold += color * impact * 0.08;
    gold += lerp(color, float3(1.0, 0.97, 0.85), 0.4) * edge * 0.85 * min(_EffectDetail, 1.3);
    return gold;
}

float GrHash(float2 p)
{
    p = frac(p * float2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return frac(p.x * p.y);
}

float GrNoise(float2 p)
{
    float2 i = floor(p);
    float2 f = frac(p);
    f = f * f * (3.0 - 2.0 * f);
    return lerp(lerp(GrHash(i), GrHash(i + float2(1, 0)), f.x), lerp(GrHash(i + float2(0, 1)), GrHash(i + float2(1, 1)), f.x), f.y);
}

#endif
