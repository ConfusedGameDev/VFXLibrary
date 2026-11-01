#ifndef CONFUSEDGAMEDEV_BILLOWING_AIRBURST_COMMON_INCLUDED
#define CONFUSEDGAMEDEV_BILLOWING_AIRBURST_COMMON_INCLUDED

#define _BurstOffset _Motion0.xyz

// Per cast. Set by the effect through its property block.
float4 _JetPaths[6];
float4 _JetBends[6];

float Hash3(float3 p)
{
    p = frac(p * 0.3183099 + float3(0.11, 0.17, 0.23));
    p *= 17.0;
    return frac(p.x * p.y * p.z * (p.x + p.y + p.z));
}

float Noise3(float3 p)
{
    float3 i = floor(p);
    float3 f = frac(p);
    f = f * f * (3.0 - 2.0 * f);
    return lerp(lerp(lerp(Hash3(i), Hash3(i + float3(1, 0, 0)), f.x), lerp(Hash3(i + float3(0, 1, 0)), Hash3(i + float3(1, 1, 0)), f.x), f.y),
        lerp(lerp(Hash3(i + float3(0, 0, 1)), Hash3(i + float3(1, 0, 1)), f.x), lerp(Hash3(i + float3(0, 1, 1)), Hash3(i + float3(1, 1, 1)), f.x), f.y), f.z);
}

float Billow(float3 p)
{
    return Noise3(p) * 0.65 + Noise3(p * 2.07 + 7.3) * 0.25 + Noise3(p * 4.11 - 3.1) * 0.10;
}

float FlameHeat(float age, float pattern)
{
    return 1.0 - smoothstep(0.26, 0.59, age + (0.5 - pattern) * 0.24);
}

float3 HeatColor(float3 base, float heat)
{
    float3 flame = lerp(base * float3(1.25, 0.75, 0.45), float3(1.0, 0.34, 0.025), 0.45);
    return lerp(flame, float3(1.0, 0.96, 0.79), smoothstep(0.72, 1.12, heat));
}

// Shared centers keep the glow attached to its lobe.
void LobeMotion(float t, float4 lobe, float4 data, out float3 center, out float swell, out float age)
{
    age = t;
    if (data.y >= 0.0)
    {
        float4 path = _JetPaths[(int)data.y];
        float4 bend = _JetBends[(int)data.y];
        float u = data.z;
        age = max(0.0, t - 0.025 - bend.z - u * 0.11);
        float travel = (1.0 - exp(-max(0.0, t - 0.045) * 6.5)) * path.w;
        float3 d = path.xyz;
        float3 side = normalize(cross(d, float3(0.13, 1.0, 0.07)));
        float3 up = normalize(cross(side, d));
        center = d * (0.65 + travel * u);
        center += side * (sin(u * 3.141593) * bend.x + lobe.y) + up * (sin(u * 3.7) * bend.y + lobe.z);
        float drift = max(0.0, t - 0.65);
        center += side * (data.x - 0.5) * drift * 0.32 + up * (data.w - 0.5) * drift * 0.22;
        center.y += drift * (0.12 + 0.14 * u);
        swell = (1.0 - exp(-age * 30.0)) * (1.0 + min(t, 0.8) * 0.36) * bend.w;
    }
    else
    {
        float launch = 1.0 - exp(-t * 19.0);
        float c = cos(t * 0.23);
        float s = sin(t * 0.23);
        center = float3(c * lobe.x + s * lobe.z, lobe.y, -s * lobe.x + c * lobe.z) * launch;
        center *= 1.0 + min(t, 0.65) * 0.27;
        center.y += max(0.0, t - 0.55) * (0.14 + data.w * 0.16);
        center += normalize(lobe.xyz + 0.001) * smoothstep(0.8, 2.0, t) * 0.23;
        swell = launch * (1.0 + min(t, 0.6) * 0.22);
    }
}

#endif
