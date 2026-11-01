Shader "ConfusedGameDev/Vfx/BurningGround Sigil"
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

            #define VFX_VARIANT 1
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


                float sector = 2.0 * VFX_PI / 5.0;
                float angle = Mod(a - t * 0.055 + sector * 0.5, sector) - sector * 0.5;
                float2 f = float2(cos(angle), sin(angle)) * r;
                float curve = 0.12 * sin((f.x - 0.18) * 7.0);
                float blade = Ink(f.y - curve, 0.008) * smoothstep(0.14, 0.24, f.x) * (1.0 - smoothstep(0.54, 0.65, f.x));
                float echo = Ink(f.y + 0.055 - curve * 0.6, 0.003) * smoothstep(0.23, 0.32, f.x) * (1.0 - smoothstep(0.48, 0.60, f.x));
                inkSum += blade + echo;
                inkSum += Ink(r - 0.115, 0.005) + Ink(Polygon(p, 5.0, 0.075, t * 0.055), 0.007);
                inkSum += Ink(r - 0.67, 0.003) * step(0.05, cos(a * 5.0 - t * 0.275));
                inkSum += Ink(Polygon(p, 5.0, 0.60, t * 0.055), 0.0015) * 0.6;



                float sectorHeat = 0.5 + 0.5 * sin(a * 5.0 - t * 2.0);
                accent = sectorHeat * Noise2(p * 9.0 - t * 0.7);
                pulse = 0.72 + accent * 0.3;


                float alpha = min(inkSum * (0.72 + accent * 0.65), 1.0) * pulse;
                return Staged(float4(_EffectColor.rgb * 1.4 + 0.04, alpha * _EffectDetail), input.stagePosition);
            }
            ENDHLSL
        }
    }
}
