Shader "ConfusedGameDev/Vfx/GoldenChainRain Cracks"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent" }

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

            #define VFX_VARIANT 15
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "GoldenChainRainCommon.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 data : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 crack : TEXCOORD0;
                float age : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                GcChain chain;
                if (!GcLoad(input.data.x, chain))
                {
                    return output;
                }

                output.age = _EffectTime - chain.birth;
                if (output.age < 0.35 || output.age >= 1.85)
                {
                    return output;
                }

                float2 q = GcCrackPoint(input.positionOS.xz, chain.seed);
                float3 p = chain.end + float3(q.x, input.positionOS.y, q.y);
                output.crack = input.uv;
                output.positionCS = TransformWViewToHClip(SourceToView(p * _EffectSize));
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float reveal = smoothstep(input.crack.y * 0.15, input.crack.y * 0.15 + 0.03, input.age - 0.35);
                float fade = 1.0 - smoothstep(1.10, 1.85, input.age);
                float x = abs(input.crack.x);
                float alpha = reveal * fade * (1.0 - smoothstep(0.72, 1.0, x));
                clip(alpha - 0.004);
                float core = 1.0 - smoothstep(0.08, 0.72, x);
                float3 color = lerp(_EffectColor.rgb * float3(1.0, 0.72, 0.12), lerp(_EffectColor.rgb, float3(1.0, 0.92, 0.44), 0.35) * 1.5, core);
                return float4(color, saturate(alpha));
            }
            ENDHLSL
        }
    }
}
