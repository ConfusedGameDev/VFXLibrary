Shader "ConfusedGameDev/Vfx/PlasmaBolt Core"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+2" }

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
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxProjectile.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 stagePosition : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                output.positionCS = StageClip(input.positionOS * _EffectSize + float3(0.85, 0.0, 0.0), output.stagePosition);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 uv = input.uv;
                float t = _EffectTime;
                float charge = 0.5 + 0.5 * sin(uv.x * 17.0 + t * 12.0);
                float streak = pow(abs(0.5 + 0.5 * cos(uv.y * 18.8496 + sin(uv.x * 17.0 - t * 9.0) * 1.7)), 5.0);
                float3 c = _EffectColor.rgb * float3(0.25, 0.85, 1.7) + streak * 1.8;
                return float4(c, saturate((0.04 + streak * 0.36) * (0.6 + charge * 0.4)) * StageAlpha(input.stagePosition));
            }
            ENDHLSL
        }
    }
}
