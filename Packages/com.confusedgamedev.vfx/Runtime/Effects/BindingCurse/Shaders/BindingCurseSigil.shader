Shader "ConfusedGameDev/Vfx/BindingCurse Sigil"
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

            #define VFX_VARIANT 5
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
                float t = VFX_GROUND_TIME;
                float m = 0.0;
                float inner = 0.0;


                for (int i = 0; i < 3; i++)
                {
                    float2 q = Rotate(p, i * 2.094);
                    m += LineMask(q, float2(0.18, -0.08), float2(1.2, 0.28), 0.055) + LineMask(q, float2(1.2, 0.28), float2(0.93, 0.58), 0.055) + LineMask(q, float2(0.93, 0.58), float2(0.76, 0.3), 0.055);
                }

                m += Band(r - 0.6, 0.024) * (0.5 + 0.5 * cos(a * 9.0));
                m *= 1.2 + 0.5 * sin(t * 2.5 - a * 3.0);
                inner = (1.0 - smoothstep(0.0, 1.4, r)) * 0.08;


                float sweep = SigilSweep(r, a, t);
                float alpha = clamp(m * sweep + inner, 0.0, 0.92);
                clip(alpha - 0.003);
                return Staged(float4(ToonShade(_EffectColor.rgb, 0.35 + sweep * 0.5), alpha), input.stagePosition);
            }
            ENDHLSL
        }
    }
}
