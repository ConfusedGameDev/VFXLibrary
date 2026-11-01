Shader "ConfusedGameDev/Vfx/DarkchainDetonation Refraction"
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

            #define VFX_VARIANT 14
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl"
            #include "DarkchainDetonationCommon.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 lens : TEXCOORD0;
                float4 screen : TEXCOORD1;
                float4 centerScreen : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float t = _EffectTime;
                if (t < 3.650000 || t >= 5.150000)
                {
                    return output;
                }

                output.lens = input.positionOS.xy * 2.0;
                float3 center = CoreView();
                output.centerScreen = ComputeScreenPos(TransformWViewToHClip(center));
                center.xy += input.positionOS.xy * (DC_warpRadius * 2.0) * ViewScale();
                output.positionCS = TransformWViewToHClip(center);
                output.screen = ComputeScreenPos(output.positionCS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float r = length(input.lens);
                clip(1.0 - r);
                float2 uv = input.screen.xy / input.screen.w;
                float2 center = input.centerScreen.xy / input.centerScreen.w;
                float feather = 1.0 - smoothstep(0.08, 1.0, r);
                float2 delta = (uv - center) * _WarpKick * DC_warpPower * feather;
                float2 inset = 0.5 / max(_ScreenParams.xy, float2(1.0, 1.0));
                float3 sceneColor = SampleSceneColor(clamp(uv + delta, inset, 1.0 - inset));
                float coverage = feather * feather * _WarpFade * smoothstep(0.0, 0.12, abs(_WarpKick));
                return float4(sceneColor, saturate(coverage));
            }
            ENDHLSL
        }
    }
}
