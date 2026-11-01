Shader "ConfusedGameDev/Vfx/SacredRelicDescent Trail"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+7" }

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

                if (_EmitTime < 1.0 || _EffectTime >= 1.48 || _Cancel < 1.0)
                {
                    return output;
                }

                output.uv = input.uv;
                float3 p = float3(input.positionOS.x, input.positionOS.y + 5.25 + _BodyHeight, -0.09);
                output.positionCS = TransformWViewToHClip(RelicToView(p));
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float t = _EffectTime;
                float x = input.uv.x * 2.0 - 1.0;
                float streak = exp(-x * x * 32.0) + 0.24 * exp(-Sq((abs(x) - 0.36) * 22.0));
                float a = streak * Sq(1.0 - input.uv.y) * smoothstep(1.0, 1.08, t) * (1.0 - smoothstep(1.35, 1.48, t)) * _Cancel;
                clip(a - 0.002);
                return float4(lerp(_EffectColor.rgb, float3(1.0, 1.0, 1.0), 0.55), saturate(a * 0.65));
            }
            ENDHLSL
        }
    }
}
