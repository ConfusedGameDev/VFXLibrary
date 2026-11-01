Shader "ConfusedGameDev/Vfx/BillowingAirburst Wave"
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

            #define VFX_VARIANT 11
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "BillowingAirburstCommon.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 waveLocal : TEXCOORD0;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                if (_EffectTime <= 0.035 || _EffectTime >= 0.250)
                {
                    return output;
                }

                float t = max(0.0, _EffectTime - 0.035);
                float radius = 1.5 * min(5.8, 0.58 + t * 28.0);
                output.waveLocal = input.positionOS.xy * 2.0;
                float3 positionVS = TransformWorldToView(TransformObjectToWorld(float3(0.0, 0.0, 0.0)));
                positionVS.xy += output.waveLocal * radius * _EffectSize * RootScale();
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float r = length(input.waveLocal);
                if (r < 0.70 || r > 1.02)
                {
                    discard;
                }

                float a = atan2(input.waveLocal.y, input.waveLocal.x);
                float contour = 0.88 + sin(a * 11.0 + _BurstOffset.x) * 0.042 + sin(a * 19.0 + _BurstOffset.y) * 0.021 + sin(a * 5.0 + _BurstOffset.z) * 0.027;
                float width = (0.027 + 0.008 * sin(a * 7.0 + _BurstOffset.y)) / 1.5;
                float band = 1.0 - smoothstep(width * 0.4, width, abs(r - contour));
                float life = smoothstep(0.035, 0.055, _EffectTime) * (1.0 - smoothstep(0.045, 0.250, _EffectTime));
                float alpha = band * life * 0.50;
                clip(alpha - 0.003);
                return float4(0.36, 0.33, 0.28, alpha);
            }
            ENDHLSL
        }
    }
}
