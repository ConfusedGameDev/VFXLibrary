Shader "ConfusedGameDev/Vfx/SacredRelicDescent Echo"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+2" }

        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
            Blend One One
            ZWrite Off
            Cull Off

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #define VFX_VARIANT 18
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "SacredRelicDescentCommon.hlsl"

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
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                if (_PulseAge < 0.0)
                {
                    return output;
                }

                output.uv = input.uv;
                float a = input.uv.x * 6.283185;
                float r = max(0.0, _WaveRadius * 0.81 - (1.0 - input.uv.y) * 0.38);
                output.positionCS = TransformWViewToHClip(RelicToView(float3(cos(a) * r, 0.035, sin(a) * r)));
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float theta = input.uv.x * 6.283185;
                float y = input.uv.y;
                float water = RelicWater(float2(cos(theta), sin(theta)) * (_WaveRadius * 0.81 - (1.0 - y) * 0.38), _PulseAge);
                float a = pow(max(0.0, sin(y * 3.14159)), 3.0) * smoothstep(0.0, 0.24, y) * (1.0 - smoothstep(0.72, 1.0, y)) * smoothstep(0.1, 0.3, _PulseAge) * (1.0 - smoothstep(0.8, 1.55, _PulseAge)) * 0.23;
                float alpha = a * _Cancel * lerp(1.0, 0.18 + 0.82 * water, saturate(_EffectDetail));
                clip(alpha - 0.0005);
                return Magic(_EffectColor.rgb, alpha);
            }
            ENDHLSL
        }
    }
}
