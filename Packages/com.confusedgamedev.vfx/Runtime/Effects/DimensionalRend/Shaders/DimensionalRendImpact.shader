Shader "ConfusedGameDev/Vfx/DimensionalRend Impact"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+3" }

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

            #define VFX_VARIANT 1
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "DimensionalRendCommon.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 local : TEXCOORD0;
                float alpha : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.local = input.positionOS.xy;
                output.alpha = smoothstep(REND_RELEASE, REND_RELEASE + 0.025, _EffectTime) * (1.0 - smoothstep(REND_RELEASE + 0.08, REND_RELEASE + 0.18, _EffectTime));
                if (output.alpha <= 0.0)
                {
                    return output;
                }

                float3 mv = SourceToView(RendCenter());
                mv.xy += input.positionOS.xy * 0.8 * _EffectSize * RootScale();
                output.positionCS = TransformWViewToHClip(mv);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                clip(input.alpha - 0.003);
                float diamond = abs(input.local.x) + abs(input.local.y) * 1.15;
                float core = 1.0 - smoothstep(0.03, 0.28, diamond);
                float halo = pow(max(0.0, 1.0 - diamond), 2.0);
                float alpha = input.alpha * (core * 0.75 + halo * 0.65) * (0.75 + 0.25 * _EffectDetail);
                float3 color = lerp(_EffectColor.rgb, float3(1.0, 1.0, 1.0), core * 0.86);
                clip(alpha - 0.003);
                return float4(color, saturate(alpha));
            }
            ENDHLSL
        }
    }
}
