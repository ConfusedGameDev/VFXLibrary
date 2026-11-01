Shader "ConfusedGameDev/Vfx/PulseBeam Rings"
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

            #define VFX_VARIANT 1
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBeam.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float4 seed : TEXCOORD1;
                float2 id : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float fade : TEXCOORD0;
                float3 stagePosition : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                if (input.id.x >= _LayerCounts.x)
                {
                    return output;
                }

                float life = frac(input.seed.x + _EffectTime * 0.38);
                float3 p = input.positionOS;
                p.yz *= _EffectSize * (0.7 + sin(life * VFX_PI) * 0.6);
                output.fade = sin(life * VFX_PI) * 0.85;
                p.x = p.x / _Stretch - 2.4 + life * 4.8;
                output.positionCS = StageClip(p, output.stagePosition);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                return float4(_EffectColor.rgb * 1.7, saturate(input.fade * _EffectDetail) * StageAlpha(input.stagePosition));
            }
            ENDHLSL
        }
    }
}
