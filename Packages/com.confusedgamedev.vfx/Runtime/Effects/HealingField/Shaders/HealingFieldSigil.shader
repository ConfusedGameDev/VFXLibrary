Shader "ConfusedGameDev/Vfx/HealingField Sigil"
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

            #define VFX_VARIANT 0
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
                float3 p = float3(input.positionOS.x * _EffectSize, 0.025, -input.positionOS.y * _EffectSize);
                output.positionCS = GroundClip(p, 0.0, output.stagePosition);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 p = (input.uv - 0.5) * 2.0;
                float r = length(p);
                clip(0.99 - r);

                float a = atan2(p.y, p.x);
                float t = VFX_GROUND_TIME;
                float inkSum = SigilInk(p, r, a, t);
                float pulse = 0.85 + sin(t * 1.2) * 0.15;
                float accent = 0.0;


                float petals = 0.35 + 0.16 * cos(a * 8.0 + t * 0.12);
                inkSum += Ink(r - petals, 0.004) + Ink(r - 0.6, 0.002);
                inkSum += Ink(r - 0.17, 0.004);
                inkSum += Ink(Segment(p, float2(-0.12, 0.0), float2(0.12, 0.0)), 0.022);
                inkSum += Ink(Segment(p, float2(0.0, -0.12), float2(0.0, 0.12)), 0.022);

                float quarter = floor((a + VFX_PI / 4.0) / (VFX_PI / 2.0)) * VFX_PI / 2.0;
                float2 d = p - float2(cos(quarter), sin(quarter)) * 0.65;
                inkSum += Ink(Segment(d, float2(-0.035, 0.0), float2(0.035, 0.0)), 0.009) + Ink(Segment(d, float2(0.0, -0.035), float2(0.0, 0.035)), 0.009);



                float growth = frac(t * 0.26);
                accent = exp(-pow((r - growth) * 22.0, 2.0)) * sin(growth * VFX_PI);
                pulse = 0.68 + 0.24 * pow(abs(0.5 + 0.5 * sin(t * 1.5)), 2.0);


                float alpha = min(inkSum * (0.72 + accent * 0.65), 1.0) * pulse;
                return Staged(float4(_EffectColor.rgb * 1.4 + 0.04, alpha * _EffectDetail), input.stagePosition);
            }
            ENDHLSL
        }
    }
}
