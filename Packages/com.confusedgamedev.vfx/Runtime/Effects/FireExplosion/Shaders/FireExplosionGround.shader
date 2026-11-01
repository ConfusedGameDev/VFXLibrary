Shader "ConfusedGameDev/Vfx/FireExplosion Ground"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+2" }

        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Off

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #define VFX_VARIANT 0
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float2 id : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float kind : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            float Hash3(float3 p)
            {
                p = frac(p * 0.3183099 + float3(0.11, 0.17, 0.23));
                p *= 17.0;
                return frac(p.x * p.y * p.z * (p.x + p.y + p.z));
            }

            float Field3(float3 p)
            {
                float3 i = floor(p);
                float3 f = frac(p);
                f = f * f * (3.0 - 2.0 * f);
                return lerp(
                    lerp(lerp(Hash3(i), Hash3(i + float3(1, 0, 0)), f.x), lerp(Hash3(i + float3(0, 1, 0)), Hash3(i + float3(1, 1, 0)), f.x), f.y),
                    lerp(lerp(Hash3(i + float3(0, 0, 1)), Hash3(i + float3(1, 0, 1)), f.x), lerp(Hash3(i + float3(0, 1, 1)), Hash3(i + float3(1, 1, 1)), f.x), f.y),
                    f.z);
            }

            float Turbulence(float3 p)
            {
                return Field3(p) * 0.64 + Field3(p * 2.03 + 5.1) * 0.26 + Field3(p * 4.01 - 2.7) * 0.10;
            }

            float3 HotColor(float3 base, float heat)
            {
                float3 flame = min(base * (1.2 + max(0.0, heat) * 3.0), float3(1.0, 1.0, 1.0));
                return lerp(flame, float3(1.0, 0.97, 0.85), smoothstep(0.75, 1.10, heat));
            }

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                float kind = input.id.x;
                output.kind = kind;
                float t = _EffectTime;
                float2 uv = input.uv;
                if (t <= 0.0 || t >= 2.8 || (kind > 0.5 && kind < 2.5 && t >= 1.05) || (kind > 2.5 && t >= 0.56))
                {
                    return output;
                }

                float3 p;
                if (kind < 0.5)
                {
                    p = float3((uv.x - 0.5) * 3.35, 0.022, (uv.y - 0.5) * 3.35);
                }
                else if (kind < 2.5)
                {
                    float angle = uv.x * 6.283185;
                    float wave = sin(angle * 9.0 + t * 2.0 + kind) * 0.14 + sin(angle * 17.0 - 0.7 + kind) * 0.08 + sin(angle * 5.0) * 0.10;
                    float radius = (1.0 - exp(-t * 13.0)) * (1.70 + kind * 0.46) + min(t, 1.5) * 0.62;
                    radius += (uv.y - 0.5) * (0.32 + kind * 0.15) + wave;
                    p = float3(cos(angle) * radius, 0.04 + sin(uv.y * 3.141593) * 0.025, sin(angle) * radius);
                }
                else
                {
                    float angle = uv.x * 6.283185 + t * 2.6;
                    float r = (1.0 - exp(-t * 48.0)) * (2.12 - (kind - 3.0) * 0.42) + t * 0.28;
                    r += sin(angle * 7.0 + kind) * 0.045 + sin(angle * 13.0) * 0.035;
                    p = float3(cos(angle) * r, 0.55 + (kind - 3.0) * 0.88 + sin(angle * 3.0 + t * 3.0) * 0.08 + (uv.y - 0.5) * 0.12, sin(angle) * r);
                }

                p *= _EffectSize;
                p.y -= 1.35;
                output.positionCS = TransformObjectToHClip(ToUnity(p));
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 uv = input.uv;
                float kind = input.kind;
                float t = _EffectTime;
                float alpha;
                float3 color;
                if (kind < 0.5)
                {
                    float2 p = (uv - 0.5) * 2.0;
                    float r = length(p);
                    float dist = r + (Noise2(p * 3.5) - 0.5) * 0.24;
                    float2 cells = p * 3.0;
                    float2 cell = floor(cells);
                    float2 f = frac(cells);
                    float first = 10.0;
                    float second = 10.0;
                    for (int y = -1; y <= 1; y++)
                    {
                        for (int x = -1; x <= 1; x++)
                        {
                            float2 at = float2(x, y);
                            float2 id = cell + at;
                            float2 jitter = float2(Hash3(float3(id, 1.0)), Hash3(float3(id, 2.0))) * 0.7 + 0.15;
                            float d = length(at + jitter - f);
                            if (d < first)
                            {
                                second = first;
                                first = d;
                            }
                            else if (d < second)
                            {
                                second = d;
                            }
                        }
                    }

                    float lava = (1.0 - smoothstep(0.025, 0.11, second - first)) * (1.0 - smoothstep(0.3, 1.0, dist));
                    float heat = 1.0 - smoothstep(0.65, 2.8, t);
                    color = lerp(float3(0.012, 0.010, 0.009), HotColor(_EffectColor.rgb, 0.6), lava * heat);
                    alpha = (1.0 - smoothstep(0.7, 1.0, dist)) * (1.0 - smoothstep(2.25, 2.8, t)) * 0.85;
                }
                else if (kind < 2.5)
                {
                    float edge = sin(uv.y * 3.141593);
                    float rough = Noise2(float2(uv.x * 24.0 - kind * 9.0, uv.y * 6.0 - t * 0.4));
                    float fade = 1.0 - smoothstep(0.45, 1.05, t);
                    alpha = smoothstep(0.0, 0.22, edge) * (0.45 + rough * 0.40) * fade * smoothstep(0.0, 0.035, t);
                    clip(rough + 0.15 - smoothstep(0.30, 1.4, t) * 0.6);
                    color = lerp(float3(0.23, 0.24, 0.26), HotColor(_EffectColor.rgb, 0.65), 1.0 - smoothstep(0.30, 0.68, t));
                }
                else
                {
                    float rip = Noise2(float2(uv.x * 18.0 - kind * 7.0, uv.y * 2.0 - t * 1.8));
                    clip(rip - 0.20);
                    alpha = sin(uv.y * 3.141593) * 0.85 * smoothstep(0.0, 0.035, t) * (1.0 - smoothstep(0.22, 0.56, t));
                    color = HotColor(_EffectColor.rgb, 0.85);
                }

                clip(alpha - 0.005);
                return float4(color, alpha);
            }
            ENDHLSL
        }
    }
}
