Shader "ConfusedGameDev/Vfx/ThunderStrike Body"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+2" }

        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
            Blend One OneMinusSrcAlpha
            ZWrite Off
            Cull Off

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #define VFX_VARIANT 5
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
                float4 extra : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float fade : TEXCOORD1;
                float phase : TEXCOORD2;
                float part : TEXCOORD3;
                float2 stroke : TEXCOORD4;
                float halfLength : TEXCOORD5;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            float LightningNoise(float h, float cells, float seed)
            {
                float f = h * cells;
                float i = floor(f);
                return lerp(Hash(float2(i, seed)), Hash(float2(i + 1.0, seed)), frac(f)) * 2.0 - 1.0;
            }

            float3 ThunderMain(float h)
            {
                float f = floor(_EffectTime * 18.0);
                float2 bend = float2(LightningNoise(h, 7.0, f), LightningNoise(h, 6.0, f + 17.0)) * 0.42
                    + float2(LightningNoise(h, 83.0, f + 31.0), LightningNoise(h, 79.0, f + 49.0)) * 0.045;
                return float3(bend.x * sin(h * VFX_PI), 4.05 - h * 5.4, bend.y * sin(h * VFX_PI));
            }

            float3 ThunderGround(float h, float id)
            {
                float a = id * 2.39996;
                float f = floor(_EffectTime * (13.0 + Mod(id, 3.0))) + id * 17.0;
                float j = LightningNoise(h, 27.0, f) * sin(h * VFX_PI);
                float reach = 2.15 + Hash(float2(id, 7.0)) * 1.2;
                return float3(cos(a) * h * reach, -1.30 + sin(h * VFX_PI) * (0.16 + Hash(float2(id, 11.0)) * 0.8), sin(a) * h * reach)
                    + float3(-sin(a), 0.3, cos(a)) * j * 0.14;
            }

            float3 ThunderPoint(float h, float id)
            {
                if (id < 0.5)
                {
                    return ThunderMain(h);
                }

                float a = id * 2.39996;
                float f = floor(_EffectTime * 16.0) + id * 17.0;
                float j = LightningNoise(h, 31.0, f) * sin(h * VFX_PI);
                if (id < 2.5)
                {
                    return ThunderMain(h) + float3(cos(a), 0.12, sin(a)) * sin(h * VFX_PI) * (0.22 + 0.25 * sin(h * 8.0 + id)) + float3(j * 0.10, 0.0, -j * 0.08);
                }

                if (id < 10.5)
                {
                    float root = (18.0 + (id - 3.0) * 7.0) / 96.0;
                    float reach = 1.2 + Hash(float2(id, 2.0)) * 1.5;
                    return ThunderMain(root) + float3(cos(a) * h * reach, -h * (0.7 + reach * 0.4), sin(a) * h * reach) + float3(-sin(a), 0.3, cos(a)) * j * 0.18;
                }

                if (id < 22.5)
                {
                    return ThunderGround(h, id);
                }

                return ThunderGround(0.5, id - 12.0) + float3(cos(a + 0.8) * h * 0.8, sin(h * VFX_PI) * 0.25, sin(a + 0.8) * h * 0.8) + float3(-sin(a), 0.4, cos(a)) * j * 0.11;
            }

            float LightningPulse(float t, float start, float end)
            {
                return smoothstep(start, start + 0.025, t) * (1.0 - smoothstep(end - 0.065, end, t));
            }

            float4 Premultiplied(float3 color, float alpha)
            {
                float covered = min(1.0, alpha);
                return float4(color * covered, covered * 0.6);
            }

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                float part = input.extra.x;
                float phase = input.extra.y;
                output.part = part;
                output.phase = phase;
                if (input.extra.z >= _Quantity)
                {
                    return output;
                }

                float2 uv = input.uv;
                float3 p = input.positionOS;
                float3 n = input.normalOS;
                float life = saturate(_EffectTime / 2.6);
                float alive = smoothstep(0.0, 0.025, life) * (1.0 - smoothstep(0.70, 1.0, life));
                output.fade = alive;

                float t = _EffectTime;
                float S = _EffectSize;
                float id = phase;
                float h = lerp(p.x, p.y, uv.x);
                float head = saturate((t - 0.08) / 0.16);
                float primary = 1.0 - smoothstep(0.64, 0.86, t);

                if (part > 3.5)
                {
                    // The storm eye above and the ripple below.
                    bool sky = part < 4.5;
                    float growth = smoothstep(0.0, 0.17, t);
                    p *= (sky ? 6.2 : 7.0) * (sky ? 0.35 + growth * 0.65 : 0.6 + smoothstep(0.22, 0.55, t) * 0.4);
                    p.y = sky ? 4.05 + p.z * 0.42 : -1.32;
                    p.y = -1.35 + (p.y + 1.35) * S;
                    p.xz *= S;
                    output.fade = sky ? smoothstep(0.0, 0.06, t) * (1.0 - smoothstep(0.46, 0.88, t)) : LightningPulse(t, 0.22, 0.85);
                    output.positionCS = TransformObjectToHClip(ToUnity(p));
                    return output;
                }

                if (part > 2.5)
                {
                    // The impact flash, then the flash at the cloud.
                    output.fade = id < 0.5 ? LightningPulse(t, 0.22, 0.72) + LightningPulse(t, 1.02, 1.22) * 0.3 + LightningPulse(t, 1.65, 1.83) * 0.18 : LightningPulse(t, 0.015, 0.65);
                    float3 flash = SourceToView(float3(0.0, -1.35 + (id < 0.5 ? 0.13 : 5.4) * S, 0.0));
                    flash.xy += p.xy * (id < 0.5 ? 4.4 : 4.8) * S * RootScale();
                    output.positionCS = TransformWViewToHClip(flash);
                    return output;
                }

                float root = (18.0 + (id - 3.0) * 7.0) / 96.0;
                float reveal = step(part < 0.5 ? h : root, head) * step(0.081, t);
                output.fade = primary * reveal * (id < 0.5 ? 1.0 : id < 2.5 ? 0.7 : 0.48 + 0.3 * Hash(float2(id, floor(t * 17.0))));
                if (part > 1.5)
                {
                    float delay = Hash(float2(id, 3.0));
                    float growth = saturate((t - 0.17 - delay * 0.025) * 8.0);
                    output.fade = LightningPulse(t, 0.23 + delay * 0.035, 0.72 + delay * 0.15);
                    output.fade += LightningPulse(t, 0.96 + delay * 0.18, 1.16 + delay * 0.18) * 0.67 + LightningPulse(t, 1.58 + delay * 0.2, 1.78 + delay * 0.2) * 0.45;
                    output.fade *= step(h, growth) * (1.0 - smoothstep(0.7, 1.0, h));
                }

                float3 p0 = ThunderPoint(p.x, id);
                float3 p1 = ThunderPoint(p.y, id);
                p0.y = -1.35 + (p0.y + 1.35) * S;
                p1.y = -1.35 + (p1.y + 1.35) * S;
                p0.xz *= S;
                p1.xz *= S;

                float3 m0 = SourceToView(p0);
                float3 m1 = SourceToView(p1);
                float2 delta = m1.xy - m0.xy;
                float len = length(delta);
                float2 along = len < 0.0001 ? float2(1, 0) : delta / len;

                float mid = (p.x + p.y) * 0.5;
                float width = id < 0.5 ? 0.40 : id < 2.5 ? 0.16 : id < 10.5 ? 0.12 : id < 22.5 ? 0.19 : 0.065;
                width *= part < 0.5 ? 0.5 + 0.5 * sin(mid * VFX_PI) : 1.0 - mid * 0.82;
                width *= S * RootScale();

                float3 mv = lerp(m0, m1, uv.x);
                mv.xy += (along * (uv.x * 2.0 - 1.0) + float2(-along.y, along.x) * (uv.y * 2.0 - 1.0)) * width;
                output.halfLength = len / max(width, 0.00001) * 0.5;
                output.stroke = float2((uv.x * 2.0 - 1.0) * (output.halfLength + 1.0), uv.y * 2.0 - 1.0);
                output.positionCS = TransformWViewToHClip(mv);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float3 tint = _EffectColor.rgb;
                float3 cyan = pow(abs(tint), 0.55) * float3(0.65, 1.4, 1.0);
                float fade = input.fade;

                if (input.part > 3.5)
                {
                    float2 q = input.uv * 2.0 - 1.0;
                    float r = length(q);
                    float a = atan2(q.y, q.x);
                    float t = _EffectTime;
                    float2 ring = float2(cos(a), sin(a));
                    float n = Noise2(ring * 5.0 + t * 0.8);
                    float energy = 0.0;
                    if (input.part < 4.5)
                    {
                        float warped = r + (n - 0.5) * 0.10 + (Noise2(ring * 17.0 - t * 2.0) - 0.5) * 0.025;
                        float flicker = 0.25 + 0.75 * smoothstep(0.24, 0.72, Noise2(ring * 4.0 + floor(t * 16.0)));
                        float rim = (exp(-pow(abs((warped - 0.68) * 80.0), 2.0)) + exp(-pow(abs((warped - 0.59) * 110.0), 2.0)) * 0.65) * flicker;
                        float swirl = pow(max(0.0, sin(a * 3.0 + log(max(0.08, r)) * 13.0 - t * 11.0)), 30.0) * (1.0 - smoothstep(0.12, 0.7, r));
                        energy = rim * 0.8 + swirl * 0.4 + exp(-pow(abs((warped - 0.63) * 8.0), 2.0)) * (0.08 + n * 0.19) + exp(-r * r * 12.0) * 0.16;
                    }
                    else
                    {
                        float front = 0.2 + min(t, 0.75) * 0.75;
                        float ripple = exp(-pow(abs((r - front - (n - 0.5) * 0.04) * 70.0), 2.0));
                        energy = exp(-r * r * 9.0) * 0.25 + ripple * 0.16 + exp(-pow(abs((r - front) * 12.0), 2.0)) * 0.08;
                    }

                    return Premultiplied(cyan + pow(energy, 3.0), energy * fade * (1.0 - smoothstep(0.82, 1.0, r)));
                }

                if (input.part > 2.5)
                {
                    float2 q = input.uv * 2.0 - 1.0;
                    float r = length(q);
                    float hot = exp(-r * r * 145.0);
                    float inner = exp(-r * r * 35.0);
                    float glow = exp(-r * r * 4.5);
                    float streak = exp(-q.y * q.y * 1400.0 - abs(q.x) * 4.0);
                    return Premultiplied(lerp(tint, cyan, inner) + hot * 2.0, (hot + inner * 0.6 + glow * 0.22 + streak * 0.42) * fade * (1.0 - smoothstep(0.8, 1.0, r)));
                }

                float edge = length(float2(max(0.0, abs(input.stroke.x) - input.halfLength), input.stroke.y));
                float core = exp(-edge * edge * 180.0);
                float sheath = exp(-edge * edge * 40.0);
                float halo = exp(-edge * edge * 6.0);
                return Premultiplied(lerp(tint, cyan, sheath) + core * 1.5, (core + sheath * 0.65 + halo * 0.18) * (1.0 - smoothstep(0.8, 1.0, edge)) * fade);
            }
            ENDHLSL
        }
    }
}
