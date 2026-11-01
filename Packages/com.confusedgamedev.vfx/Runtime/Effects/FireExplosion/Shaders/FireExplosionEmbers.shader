Shader "ConfusedGameDev/Vfx/FireExplosion Embers"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+3" }

        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
            Blend SrcAlpha One
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
                if (input.id.x >= _LayerCounts.x || _EffectTime <= 0.0 || _EffectTime >= 2.1)
                {
                    return output;
                }

                float4 seed = input.seed;
                float t = max(0.0, _EffectTime - seed.y * 0.08);
                float angle = seed.x * 6.283185;
                float travel = (1.0 - exp(-t * 12.0)) * (1.2 + seed.z * 2.3);
                float3 p = float3(cos(angle) * travel, max(0.04, (1.0 - exp(-t * 8.0)) * (0.25 + seed.w * 1.7) - t * t * 1.4), sin(angle) * travel);
                float3 velocity = float3(cos(angle) * exp(-t * 5.0), 0.4 + seed.w - t * 2.0, sin(angle) * exp(-t * 5.0));
                float2 axis = SourceDirToView(velocity).xy;
                float len = length(axis);
                axis = len > 0.0001 ? axis / len : float2(1, 0);
                float2 side = float2(-axis.y, axis.x);

                p *= _EffectSize;
                p.y -= 1.35;
                float3 positionVS = SourceToView(p);
                float streakLength = (0.18 + seed.z * 0.38) * (1.0 - smoothstep(0.12, 0.55, t)) + 0.09;
                float width = 0.08 + seed.w * 0.07;
                positionVS.xy += (axis * input.positionOS.x * streakLength + side * input.positionOS.y * width) * _EffectSize * RootScale();
                output.fade = smoothstep(0.0, 0.015, t) * (1.0 - smoothstep(0.40, 1.4 + seed.w * 0.6, t));
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 p = (input.uv - 0.5) * 2.0;
                float d = abs(p.x) + abs(p.y);
                float core = 1.0 - smoothstep(0.08, 0.48, d);
                float halo = exp(-d * d * 4.0) * (1.0 - smoothstep(0.7, 1.0, d));
                float alpha = (core + halo * 0.45) * input.fade;
                clip(alpha - 0.005);
                return float4(lerp(HotColor(_EffectColor.rgb, 0.65), float3(1.0, 0.98, 0.87), core), alpha);
            }
            ENDHLSL
        }
    }
}
