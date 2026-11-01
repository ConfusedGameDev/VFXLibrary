Shader "ConfusedGameDev/Vfx/FireExplosion Trails"
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
                float4 seed : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
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

            float3 Path(float age, float4 seed)
            {
                float angle = seed.x * 2.399963 + seed.y * 0.8;
                float travel = (1.0 - exp(-age * 8.0)) * (2.5 + seed.z * 0.8);
                float lift = (1.0 - exp(-age * 10.0)) * (1.4 + seed.w * 2.6) - age * age * 2.8;
                float3 p = float3(cos(angle) * travel, max(0.055, lift + 0.35), sin(angle) * travel);
                float curl = sin(age * 15.0 + seed.y * 13.0) * age * 0.12;
                p += float3(-sin(angle) * curl, cos(age * 11.0 + seed.z * 9.0) * age * 0.06, cos(angle) * curl);
                return p;
            }

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                float2 uv = input.uv;
                float4 seed = input.seed;
                if (_EffectTime <= 0.0 || _EffectTime >= 1.70)
                {
                    return output;
                }

                float t = max(0.0, _EffectTime - seed.y * 0.025);
                float tail = max(0.0, t - 0.5);
                float age = lerp(tail, t, uv.x);
                float3 p = Path(age, seed);
                float3 direction = normalize(Path(age + 0.002, seed) - p);
                float3 side = normalize(cross(direction, float3(0.0, 1.0, 0.01)));
                float3 up = cross(side, direction);
                float width = lerp(0.020, 0.055, smoothstep(0.95, 1.0, uv.x)) * (0.5 + sin(uv.x * 3.141593) * 0.5);
                p += (side * cos(uv.y * 6.283185) + up * sin(uv.y * 6.283185)) * width;
                p *= _EffectSize;
                p.y -= 1.35;
                output.positionCS = TransformObjectToHClip(ToUnity(p));
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float t = _EffectTime;
                float2 uv = input.uv;
                float alpha = smoothstep(0.0, 0.025, t) * (1.0 - smoothstep(0.55, 1.70, t));
                float head = smoothstep(0.94, 0.98, uv.x);
                float heat = max(head, 1.0 - smoothstep(0.08, 0.27, t));
                alpha *= lerp(0.28, 0.95, heat) * smoothstep(0.0, 0.20, uv.x);
                clip(alpha - 0.005);
                return float4(lerp(float3(0.19, 0.19, 0.20), HotColor(_EffectColor.rgb, 0.70), heat), alpha);
            }
            ENDHLSL
        }
    }
}
