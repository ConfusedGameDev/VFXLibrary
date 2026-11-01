Shader "ConfusedGameDev/Vfx/ElectricMagicArrowStrike Glow"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+5" }

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

                output.uv = input.uv * 2.0 - 1.0;
                float3 center = TransformWorldToView(TransformObjectToWorld(float3(0.0, 0.0, 0.0)));
                center.xy += input.positionOS.xy * _EffectSize * (0.65 + (1.0 - exp(-max(End(), 0.0) * 14.0)) * 1.9);
                output.positionCS = TransformWViewToHClip(center);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float t = End() * 1.4;
                float2 uv = input.uv;
                float r = length(uv);
                float hot = exp(-r * r * 55.0) * exp(-t * 27.0);
                float horizontal = exp(-abs(uv.y) * 90.0) * exp(-abs(uv.x) * 5.0);
                float vertical = exp(-abs(uv.x) * 120.0) * exp(-abs(uv.y) * 9.0);
                float rays = (horizontal + vertical * 0.45) * exp(-t * 24.0);
                float cloud = exp(-r * r * 12.0) * exp(-t * 7.0);

                // The brief contact peak yields to the lightning web and the two shock rings.
                float alpha = ((hot * 1.15 + rays * 0.85) * ContactPunch(t) + cloud * 0.24) * (1.0 - smoothstep(0.72, 1.0, r));
                clip(alpha - 0.003);
                return float4(lerp(_EffectColor.rgb, float3(1.0, 0.99, 0.86), saturate(hot * 1.3 + rays) * 0.95), saturate(alpha));
            }
            ENDHLSL
        }
    }
}
