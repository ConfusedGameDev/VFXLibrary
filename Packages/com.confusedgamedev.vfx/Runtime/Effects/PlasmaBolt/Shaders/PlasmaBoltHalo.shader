Shader "ConfusedGameDev/Vfx/PlasmaBolt Halo"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+1" }

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
                float2 corner = input.positionOS.xy * float2(2.2, 1.6);
                float3 positionVS = SourceToView(float3(corner.x * _EffectSize + 0.85, 0.0, 0.0));
                float2 axis = TransformWorldToViewDir(TransformObjectToWorldDir(float3(0.0, 0.0, 1.0), false), false).xy;
                float2 side = length(axis) < 0.00001 ? float2(0.0, 1.0) : normalize(float2(-axis.y, axis.x));
                positionVS.xy += side * corner.y * _EffectSize * RootScale();
                output.positionCS = StageViewToClip(positionVS, output.stagePosition);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 q = input.uv * 2.0 - 1.0;
                float a = exp(-q.y * q.y * 5.0) * pow(max(0.0, 1.0 - q.x * q.x), 1.8) * 0.32;
                return float4(_EffectColor.rgb * float3(0.06, 0.25, 1.8), saturate(a * _EffectDetail) * StageAlpha(input.stagePosition));
            }
            ENDHLSL
        }
    }
}
