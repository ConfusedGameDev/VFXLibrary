Shader "ConfusedGameDev/Vfx/PulseBeam Body"
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
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBeam.hlsl"

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
                float3 p = input.positionOS;
                float packet = pow(max(0.0, cos(input.uv.y * VFX_PI * 2.0 * _Quantity - _EffectTime * 2.0 * _Quantity)), 6.0);
                p.yz *= (0.35 + packet * 0.9) * _EffectSize;
                output.positionCS = StageClip(p, output.stagePosition);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float packet = pow(max(0.0, cos(input.uv.y * VFX_PI * 2.0 * _Quantity - _EffectTime * 2.0 * _Quantity)), 12.0);
                float fins = pow(abs(cos(input.uv.x * VFX_PI * 4.0)), 6.0);
                float alpha = 0.035 + packet * (0.55 + fins * 0.45);
                return float4(_EffectColor.rgb * 1.2 + packet * 0.8, alpha * StageAlpha(input.stagePosition));
            }
            ENDHLSL
        }
    }
}
