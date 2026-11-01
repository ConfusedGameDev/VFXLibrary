Shader "ConfusedGameDev/Vfx/ElectricMagicArrowStrike Core"
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

            #define VFX_VARIANT 7
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "ElectricMagicArrowStrikeCommon.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 data : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float blade : TEXCOORD0;
                float3 normalVS : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
                float3 local : TEXCOORD3;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float3 p = input.positionOS * _EffectSize;
                p.yz *= lerp(0.06, 1.0, smoothstep(0.05, 0.78, _Charge));
                output.blade = input.data.x;
                output.local = input.positionOS;
                float3 positionVS = SourceToView(p);
                output.normalVS = SourceDirToView(input.normalOS);
                output.viewDir = -positionVS;
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float3 local = input.local;
                float3 normal = normalize(input.normalVS);
                float rim = pow(abs(1.0 - abs(dot(normal, normalize(input.viewDir)))), 1.4);
                float reveal = smoothstep(-0.2, 0.15, _Charge * 3.8 - (local.x + 1.7));
                float stripe = pow(abs(0.5 + 0.5 * sin(local.x * 24.0 - _EffectTime * 15.0)), 14.0);
                float a = reveal * Charged() * ArrowFade();

                // Contact erodes the arrow from tip to tail instead of fading a solid card.
                if (_Impact > 0.5)
                {
                    float age = max(0.0, End()) * 1.4;
                    float cell = ArrowHash(floor(local.x * 23.0) + floor(atan2(local.z, local.y) * 5.0) * 37.0);
                    a *= 1.0 - smoothstep(0.03, 0.10, age + (local.x + 1.7) * 0.010 + cell * 0.015);
                }

                clip(a - 0.003);
                float center = exp(-length(local.yz) * 26.0);
                float tip = smoothstep(1.08, 1.7, local.x);
                float ridge = rim * rim;
                float tension = smoothstep(0.86, 1.0, _Charge) * 0.14;
                float3 gold = _EffectColor.rgb * (0.48 + 0.30 * abs(normal.y));
                float hot = clamp((1.0 - input.blade) * 0.90 + center * 0.45 + tip * 0.65 + ridge * 0.22 + stripe * 0.04 + tension * tip, 0.0, 0.95);
                return float4(lerp(gold, float3(1.0, 0.99, 0.88), hot), saturate(a * 0.94));
            }
            ENDHLSL
        }
    }
}
