Shader "ConfusedGameDev/Vfx/GoldenChainRain CrackGlow"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent-1" }

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

            #define VFX_VARIANT 15
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "GoldenChainRainCommon.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 b : TEXCOORD0;
                float4 a : TEXCOORD1;
                float2 reveal : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 glow : TEXCOORD0;
                float2 reveal : TEXCOORD1;
                float age : TEXCOORD2;
                float span : TEXCOORD3;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                GcChain chain;
                if (!GcLoad(input.a.w, chain))
                {
                    return output;
                }

                output.age = _EffectTime - chain.birth;
                if (output.age < 0.35 || output.age >= 1.85)
                {
                    return output;
                }

                float2 a = GcCrackPoint(input.a.xy, chain.seed);
                float2 b = GcCrackPoint(input.b, chain.seed);
                float2 delta = b - a;
                float span = length(delta);
                float2 direction = delta / max(span, 0.0001);
                float2 across = float2(-direction.y, direction.x);
                float reach = 0.20 * _CrackBloomSpread;
                output.glow = input.positionOS.xy * float2(span * 0.5 + reach, reach);
                output.span = span;
                output.reveal = float2(input.a.z, input.reveal.x);
                float2 q = (a + b) * 0.5 + direction * output.glow.x + across * output.glow.y;
                float3 p = chain.end + float3(q.x, 0.014, q.y);
                output.positionCS = TransformWViewToHClip(SourceToView(p * _EffectSize));
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float along = saturate((input.glow.x + input.span * 0.5) / max(input.span, 0.0001));
                float progress = lerp(input.reveal.x, input.reveal.y, along);
                float reveal = smoothstep(progress * 0.15, progress * 0.15 + 0.03, input.age - 0.35);
                float fade = 1.0 - smoothstep(1.10, 1.85, input.age);
                float gap = length(float2(max(abs(input.glow.x) - input.span * 0.5, 0.0), input.glow.y)) / _CrackBloomSpread;
                float value = exp(-gap * gap / 0.0036) * 0.46 + exp(-gap * gap / 0.0144) * 0.24;
                float alpha = value * (1.0 - smoothstep(0.13, 0.20, gap)) * reveal * fade * _CrackBloom;
                clip(alpha - 0.001);
                return float4(_EffectColor.rgb * float3(2.3, 1.8, 0.65), saturate(alpha));
            }
            ENDHLSL
        }
    }
}
