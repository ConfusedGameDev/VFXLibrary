Shader "ConfusedGameDev/Vfx/QuicksandSeal Sigil"
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

            #define VFX_VARIANT 7
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxGround.hlsl"

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
                float3 p = float3(input.positionOS.x * _EffectSize, 0.018, -input.positionOS.y * _EffectSize);
                output.positionCS = GroundClip(p, 0.0, output.stagePosition);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 p = (input.uv - 0.5) * 3.5;
                float r = length(p);
                float a = atan2(p.y, p.x);
                float t = _EffectTime;
                float m = 0.0;
                float inner = 0.0;


                for (int i = 0; i < 3; i++)
                {
                    float turn = i * 2.094;
                    float2 b = float2(cos(turn), sin(turn)) * 1.68;
                    float2 c = float2(cos(turn + 2.094), sin(turn + 2.094)) * 1.68;
                    m += LineMask(p, b, c, 0.026) + LineMask(p, b * 0.74, c * 0.74, 0.012);
                }

                m += Band(r - 0.38, 0.018);
                inner = exp(-r * r * 2.0) * 0.15;


                float sweep = SigilSweep(r, a, t);
                float alpha = clamp(m * sweep + inner, 0.0, 0.92);
                alpha *= smoothstep(0.0, 0.75, _LifeStart) * (1.0 - smoothstep(0.76, 1.0, _LifeEnd));
                clip(alpha - 0.003);
                return float4(ToonShade(_EffectColor.rgb, 0.35 + sweep * 0.5), alpha);
            }
            ENDHLSL
        }
    }
}
