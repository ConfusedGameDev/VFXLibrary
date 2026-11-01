Shader "ConfusedGameDev/Vfx/ElectricMagicArrowStrike Halo"
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

            #define VFX_VARIANT 7
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "ElectricMagicArrowStrikeCommon.hlsl"

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

                output.uv = input.uv;
                output.positionCS = TransformObjectToHClip(ToUnity(input.positionOS * _EffectSize));
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float x = input.uv.x;
                float y = abs(input.uv.y * 2.0 - 1.0);
                float head = exp(-Sq((x - 0.76) * 7.0));
                float w = 0.08 + head * 0.25;
                float core = exp(-Sq(y / w) * 3.0);
                float halo = exp(-Sq(y / (w + 0.25)) * 4.0);
                float taper = pow(max(0.0, sin(x * VFX_PI)), 0.6);
                float pulse = 0.94 + 0.06 * sin(_EffectTime * 13.0 + x * 8.0);
                float a = (core * 0.20 + halo * 0.11) * taper * Charged() * ArrowFade() * pulse * min(_EffectDetail, 1.5);
                clip(a - 0.002);
                return float4(_EffectColor.rgb, saturate(a));
            }
            ENDHLSL
        }
    }
}
