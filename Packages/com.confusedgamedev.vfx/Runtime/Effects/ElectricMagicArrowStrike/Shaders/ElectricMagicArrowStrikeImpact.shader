Shader "ConfusedGameDev/Vfx/ElectricMagicArrowStrike Impact"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+4" }

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
            #define CLOCK _ImpactClock

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 tangent : TEXCOORD1;
                float4 event : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float f : TEXCOORD0;
                float across : TEXCOORD1;
                float energy : TEXCOORD2;
                float ring : TEXCOORD3;
                float age : TEXCOORD4;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float4 event = input.event;
                output.f = input.uv.x;
                output.across = input.uv.y;
                output.ring = step(1.5, event.w);
                float3 p = input.positionOS;
                float age = CLOCK - event.x;
                float life = max(0.001, event.y);
                output.age = age;
                float growth = smoothstep(0.0, 0.012, age);
                float live = smoothstep(0.0, 0.005, age) * pow(max(0.0, 1.0 - max(0.0, age) / life), 0.48);
                float ember = 0.10 * exp(-max(0.0, age - life) * 70.0) * step(life, age) * step(age, life + 0.04);
                output.energy = (live + ember) * event.z * smoothstep(output.f - 0.07, output.f + 0.015, growth);

                if (output.ring > 0.5)
                {
                    float q = max(0.0, age);
                    p *= 1.0 - exp(-q * 11.0);
                    output.energy = smoothstep(0.0, 0.025, age) * (1.0 - smoothstep(0.22, 1.15, age)) * event.z;
                }

                float3 positionVS = SourceToView(p * _EffectSize);
                float2 tangent = SourceDirToView(input.tangent.xyz).xy;
                float2 n = normalize(float2(-tangent.y, tangent.x) + float2(0.00001, 0.0));
                positionVS.xy += n * input.uv.y * input.tangent.w * _EffectSize;
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float across = abs(input.across);
                float core = exp(-across * lerp(7.0, 20.0, input.ring));
                float halo = pow(max(0.0, 1.0 - across), 3.0);
                float energy = input.energy * lerp(ContactPunch(CLOCK), 1.0, input.ring);
                float band = 1.0;
                if (input.ring > 0.5)
                {
                    float f = input.f;
                    float sector = floor(f * 23.0);
                    float edge = frac(f * 23.0);
                    float breakTime = 0.19 + ArrowHash(sector + 7.0) * 0.48;
                    band = (0.46 + 0.20 * sin(f * VFX_PI * 18.0 - _EffectTime * 5.0)) * (1.0 - smoothstep(breakTime, breakTime + 0.20, input.age));
                    band *= lerp(1.0, smoothstep(0.02, 0.12, edge) * (1.0 - smoothstep(0.82, 0.98, edge)), smoothstep(0.12, 0.42, input.age));
                }

                float a = (core * 0.95 + halo * 0.32) * energy * band * min(1.35, 0.65 + _EffectDetail * 0.35);
                clip(a - 0.002);
                float3 color = lerp(_EffectColor.rgb, float3(1.0, 0.99, 0.87), core * (input.ring > 0.5 ? 0.20 : 0.82));
                return float4(color, saturate(a));
            }
            ENDHLSL
        }
    }
}
