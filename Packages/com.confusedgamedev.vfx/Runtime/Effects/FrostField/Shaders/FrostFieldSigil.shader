Shader "ConfusedGameDev/Vfx/FrostField Sigil"
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

            #define VFX_VARIANT 2
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


                inkSum += Ink(Polygon(p, 6.0, 0.64, 0.0), 0.004) + Ink(Polygon(p, 6.0, 0.53, VFX_PI / 6.0), 0.002);
                float sector = VFX_PI / 3.0;
                float local = Mod(a + sector * 0.5, sector) - sector * 0.5;
                float2 f = float2(cos(local), sin(local)) * r;
                inkSum += Ink(Segment(f, float2(0.08, 0.0), float2(0.63, 0.0)), 0.005);
                inkSum += Ink(Segment(f, float2(0.30, 0.0), float2(0.42, 0.13)), 0.004) + Ink(Segment(f, float2(0.30, 0.0), float2(0.42, -0.13)), 0.004);
                inkSum += Ink(Segment(f, float2(0.46, 0.0), float2(0.55, 0.09)), 0.003) + Ink(Segment(f, float2(0.46, 0.0), float2(0.55, -0.09)), 0.003);
                inkSum += Ink(Polygon(p, 6.0, 0.10, 0.0), 0.008);



                float freeze = frac(t * 0.14);
                accent = exp(-pow((r - freeze) * 30.0, 2.0)) * sin(freeze * VFX_PI);
                pulse = 0.82;


                float alpha = min(inkSum * (0.72 + accent * 0.65), 1.0) * pulse;
                return Staged(float4(_EffectColor.rgb * 1.4 + 0.04, alpha * _EffectDetail), input.stagePosition);
            }
            ENDHLSL
        }
    }
}
