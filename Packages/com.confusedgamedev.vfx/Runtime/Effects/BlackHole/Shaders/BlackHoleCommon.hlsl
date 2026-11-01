#ifndef CONFUSEDGAMEDEV_BLACK_HOLE_COMMON_INCLUDED
#define CONFUSEDGAMEDEV_BLACK_HOLE_COMMON_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl"

float BhGrowth()
{
    return smoothstep(0.0, 1.0, _LifeStart) * (1.0 - smoothstep(0.05, 1.0, _LifeEnd));
}

float BhFade()
{
    return smoothstep(0.0, 0.28, _LifeStart) * (1.0 - smoothstep(0.6, 1.0, _LifeEnd));
}

float3 BhCenter()
{
    return float3(0.0, 1.5, 0.0) * _EffectSize;
}

float BhNoise(float2 p)
{
    return Noise2(p);
}

float BhFbm(float2 p)
{
    return BhNoise(p) * 0.57 + BhNoise(p * 2.03 + 17.0) * 0.28 + BhNoise(p * 4.11 - 9.0) * 0.15;
}

float3 BhSpectrum(float t)
{
    return 0.5 + 0.5 * cos(6.283185 * t + float3(0.0, 2.1, 4.2));
}

// Both lenses share this displacement law; the outer one applies half of it.
float2 BhBackgroundOffset(float2 uv, float2 direction, float r, float spiral, float noise, float2 radius, float2 inset)
{
    float2 tangent = float2(-direction.y, direction.x);
    float bend = 0.48 * pow(abs(1.0 - r), 2.0) / max(r, 0.24);
    float shear = 0.045 * sin(spiral * 2.0 + (noise - 0.5) * 2.0) * pow(abs(1.0 - r), 1.5);
    float2 delta = (-direction * min(bend, 0.70) + tangent * shear) * 5.0 * radius * _EffectDetail;
    float edge = max(0.0, min(min(uv.x - inset.x, 1.0 - inset.x - uv.x), min(uv.y - inset.y, 1.0 - inset.y - uv.y)));
    return delta * smoothstep(0.0, max(0.015, length(delta) * 1.25), edge);
}

float BhHaloShape(float angle)
{
    float t = _EffectTime;
    float shapeNoise = BhFbm(float2(cos(angle - t * 0.16), sin(angle - t * 0.16)) * 3.0);
    return 0.045 * sin(angle * 3.0 - t * 0.32) + 0.008 * sin(angle * 5.0 + t * 0.23) + 0.005 * (shapeNoise - 0.5);
}

float2 BhJoinPoint(float t, float2 end)
{
    float2 a = float2(0.97, 0.0);
    float2 b = float2(0.77, 0.0);
    float2 c = end + float2(0.16, -0.18);
    float u = 1.0 - t;
    return u * u * u * a + 3.0 * u * u * t * b + 3.0 * u * t * t * c + t * t * t * end;
}

// The tapered streams that reach the two upper junctions of the halo.
float BhJunction(float2 q, float overhead)
{
    float aa = max(fwidth(q.x), fwidth(q.y));
    if (q.y < -0.04 || abs(q.x) < 0.30 || overhead >= 0.999)
    {
        return 0.0;
    }

    float angle = q.x > 0.0 ? 0.82 : 3.141593 - 0.82;
    float2 end = float2(abs(cos(angle)), sin(angle)) * 0.58 * (1.0 + BhHaloShape(angle));
    float2 p = float2(abs(q.x), q.y);
    float2 last = BhJoinPoint(0.0, end);
    float distanceToStream = 10.0;
    float along = 0.0;
    for (int i = 1; i <= 12; i++)
    {
        float t = i / 12.0;
        float2 next = BhJoinPoint(t, end);
        float2 d = next - last;
        float h = saturate(dot(p - last, d) / max(dot(d, d), 0.000001));
        float candidate = length(p - last - d * h);
        if (candidate < distanceToStream)
        {
            distanceToStream = candidate;
            along = (i - 1.0 + h) / 12.0;
        }
        last = next;
    }

    float width = lerp(0.018, 0.012, along);
    float mask = 1.0 - smoothstep(width * 0.35, width + aa, distanceToStream);
    mask *= smoothstep(0.0, 0.12, along) * (1.0 - smoothstep(0.80, 1.0, along));
    return mask * (0.55 + 0.45 * pow(0.5 + 0.5 * sin(along * 24.0 - _EffectTime * 1.2), 2.0)) * (1.0 - overhead);
}

float3 BhStrokeSeed(float2 p)
{
    float3 h = frac(float3(p.xyx) * float3(0.1031, 0.1030, 0.0973));
    h += dot(h, h.yxz + 33.33);
    return frac((h.xxy + h.yzz) * h.zyx);
}

// Advected brush marks. Neighbour cells contribute whole strokes, so cell edges never cut them.
float3 BhBrushPaint(float r, float angle, float inner, float mask)
{
    const float radialDensity = 13.0;
    float t = _EffectTime * 1.5;
    float flowRadius = r + t * 0.032;
    float2 p = float2((angle + log(flowRadius + 0.14) * 1.6 + t * lerp(0.8, -0.8, inner)) * 16.0 / 6.283185, flowRadius * radialDensity);
    float pixel = max(length(float2(ddx(p.y), ddy(p.y))) / radialDensity, 0.0003);
    if (mask <= 0.0 && pixel < 0.005)
    {
        return float3(0.0, 0.0, 0.0);
    }

    float wash = 0.0;
    float shade = 0.0;
    float scratch = 0.0;
    for (int layer = 0; layer < 5; layer++)
    {
        float field = layer;
        float2 fieldPosition = p + float2(field * 1.37, field * 0.417);
        float2 cell = floor(fieldPosition);
        float2 local = frac(fieldPosition);
        for (int y = -1; y <= 1; y++)
        {
            for (int x = -1; x <= 1; x++)
            {
                float2 offset = float2(x, y);
                float2 id = cell + offset;
                id.x = Mod(id.x, 16.0);
                id += float2(field * 19.0, field * 43.0);
                float3 seed = BhStrokeSeed(id);
                float3 shape = BhStrokeSeed(id + float2(37.0, 71.0));
                if (shape.z < 0.28)
                {
                    continue;
                }

                float2 d = local - offset - seed.xy;
                float halfLength = lerp(0.07, 0.94, shape.x * shape.x);
                float u = d.x / halfLength;
                if (abs(u) > 1.0)
                {
                    continue;
                }

                float direction = lerp(-1.0, 1.0, inner);
                float pitch = -direction * lerp(0.009, 0.015, shape.y);
                float crossing = d.y / radialDensity - d.x * pitch;
                if (abs(crossing) > 0.006 + pixel * 0.5)
                {
                    continue;
                }

                float alongFlow = u * direction;
                float taper = pow(abs(1.0 - abs(u)), 0.65) * (1.0 - 0.35 * max(0.0, alongFlow));
                float width = lerp(0.0022, 0.006, seed.z * seed.z) * taper;
                float grain = 0.82 + 0.18 * sin(u * 16.0 + shape.y * 23.0) * sin(u * 7.0 + seed.z * 31.0);
                float edge = abs(crossing) - width * grain;
                float coverage = 1.0 - smoothstep(-pixel * 0.5, pixel * 0.5, edge);
                float split = abs(crossing - width * 0.34) - width * 0.11;
                coverage *= lerp(1.0, smoothstep(-pixel * 0.22, pixel * 0.22, split), step(0.68, seed.x));
                float pigment = 0.15 + 0.55 * seed.z + 0.12 * sin(u * 4.0 + seed.x * 9.0);
                if (coverage > wash)
                {
                    wash = coverage;
                    shade = pigment;
                }
                scratch = max(scratch, coverage * step(0.78, seed.y));
            }
        }
    }
    return float3(wash, shade, scratch);
}

// Premultiplied light and coverage of the disk at a point of its surface, in units of its scale.
float4 BhDiskLight(float2 disk, float layerWeight)
{
    float t = _EffectTime;
    float r = length(disk);
    float a = atan2(disk.y, disk.x);
    float spin = t * 0.9;

    // Positive time in log-radius coordinates carries the pattern inward.
    float advected = a + log(r + 0.12) * 2.4 + spin;
    float2 flow = float2(cos(advected), sin(advected)) * 3.0;
    float n = BhFbm(flow + float2(r * 4.0 + t * 1.15, r * 1.5));
    float large = BhFbm(flow * 0.55 + r);
    float warped = r + 5.0 * ((n - 0.5) * 0.055 + sin(a * 5.0 - r * 3.0 + spin) * 0.016);
    float phase = advected * 3.0 + (n - 0.5) * 3.0;
    float bands = pow(0.5 + 0.5 * sin(phase), 2.5);
    float fine = smoothstep(0.38, 0.64, n);
    float envelope = smoothstep(0.65, 0.88, r) * (1.0 - smoothstep(2.05 + large * 0.3, 2.65, r));
    float torn = smoothstep(0.12, 0.65, n) * (0.3 + 0.7 * large);
    float hot = bands * (0.55 + 0.45 * n);
    float3 spectrum = BhSpectrum(warped * 1.8 + large * 0.7);
    float3 color = lerp(float3(0.02, 0.10, 0.9), spectrum * 1.8, 0.7);
    color = lerp(color, _EffectColor.rgb, 0.18);
    color = lerp(color, float3(1.0, 0.97, 0.94) * 2.8, smoothstep(0.32, 0.82, hot));

    float3 brush = BhBrushPaint(r / 2.15, a, 0.0, 1.0);
    float ink = brush.z;
    float outerWeight = smoothstep(0.68, 0.88, r);
    color *= lerp(0.55, 1.0, step(0.48, hot));

    float fade = BhFade();
    float alpha = envelope * (0.24 + bands * 0.88 + fine * 0.16) * torn * fade;
    if (alpha < 0.002)
    {
        return float4(0.0, 0.0, 0.0, 0.0);
    }

    // Light stays additive; ink also darkens what is behind, so the bright lens cannot wash it out.
    float inkCoverage = ink * outerWeight * envelope * fade * 0.98;
    float3 emission = color * 2.4 * _EffectDetail * min(1.0, alpha) * (1.0 - ink * outerWeight);
    emission /= 1.0 + max(emission.r, max(emission.g, emission.b)) * 1.2;
    float wash = brush.x * outerWeight * envelope * fade;
    float3 pigment = lerp(float3(0.008, 0.018, 0.055), lerp(spectrum * 0.32, float3(0.08, 0.25, 0.40), 0.55), brush.y);
    emission = lerp(emission, pigment * (0.75 + 0.25 * _EffectDetail), wash) * (1.0 - ink * outerWeight);
    inkCoverage = max(inkCoverage, wash * 0.98);
    emission *= layerWeight;
    inkCoverage *= layerWeight;
    return float4(emission + float3(0.002, 0.004, 0.012) * inkCoverage, inkCoverage);
}

// Share of the disk that belongs to the rear layer, from a point and the centre in view space.
float BhFrontWeight(float3 pointVS, float3 centerVS)
{
    float nearSide = dot(pointVS - centerVS, normalize(-centerVS));
    return smoothstep(-0.45 * _EffectSize, 0.45 * _EffectSize, nearSide);
}

// The rear of the disk as seen through a lens. The site reads it from its transmission capture,
// which holds the disk. The camera's opaque texture cannot, so each lens traces the bent ray to
// the disk's plane instead. uv is y-up screen space, as ComputeScreenPos gives.
float4 BhRearDiskThroughLens(float2 uv)
{
    float3 viewRay = float3((uv.x * 2.0 - 1.0) / UNITY_MATRIX_P[0][0], (uv.y * 2.0 - 1.0) / abs(UNITY_MATRIX_P[1][1]), -1.0);
    float3 worldRay = mul((float3x3)UNITY_MATRIX_I_V, viewRay);
    float3 ray = ToUnity(TransformWorldToObjectDir(worldRay, false));
    float3 origin = ToUnity(TransformWorldToObject(_WorldSpaceCameraPos));
    float3 center = BhCenter();
    if (abs(ray.y) < 0.00001)
    {
        return float4(0.0, 0.0, 0.0, 0.0);
    }

    float distanceAlong = (center.y - origin.y) / ray.y;
    if (distanceAlong <= 0.0)
    {
        return float4(0.0, 0.0, 0.0, 0.0);
    }

    float3 hit = origin + ray * distanceAlong;
    float layerWeight = 1.0 - BhFrontWeight(SourceToView(hit), SourceToView(center));
    if (layerWeight < 0.0001)
    {
        return float4(0.0, 0.0, 0.0, 0.0);
    }

    // Undo the surface's slow silhouette motion, so the two views of the disk stay in step.
    float2 disk = (hit - center).xz / (_EffectSize * max(0.0001, BhGrowth()));
    float radius = length(disk);
    float angle = atan2(disk.y, disk.x);
    float t = _EffectTime;
    radius /= 1.0 + 0.045 * sin(angle * 3.0 - t * 0.32) + 0.025 * sin(angle * 5.0 + t * 0.23);
    angle -= 0.10 * sin(angle * 3.0 + radius * 1.8 - t * 0.35) / (radius + 0.3);
    return BhDiskLight(float2(cos(angle), sin(angle)) * radius, layerWeight);
}

// The projected radius of the horizon's lens, as a fraction of the screen.
float2 BhScreenRadius(float3 centerVS, float scale)
{
    float projected = 2.15 * scale * RootScale() / max(0.01, -centerVS.z);
    return float2(UNITY_MATRIX_P[0][0], UNITY_MATRIX_P[1][1]) * projected * 0.5;
}

#endif
