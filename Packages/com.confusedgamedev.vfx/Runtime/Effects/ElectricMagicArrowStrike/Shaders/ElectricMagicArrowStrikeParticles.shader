Shader "ConfusedGameDev/Vfx/ElectricMagicArrowStrike Particles"
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

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 seed : TEXCOORD1;
                float2 id : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float fade : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                if (input.id.x >= _ParticleCount)
                {
                    return output;
                }

                float4 seed = input.seed;
                output.uv = input.uv * 2.0 - 1.0;
                float a = seed.x * VFX_PI * 2.0;
                float z = seed.y * 2.0 - 1.0;
                float ring = sqrt(1.0 - z * z);
                float3 dir = float3(z, ring * cos(a), ring * sin(a));
                float3 p;
                if (_Impact > 0.5)
                {
                    float age = max(0.0, End()) * 1.4;
                    float t = max(0.0, age - seed.w * 0.14);
                    p = float3(1.7 * _EffectSize, 0.0, 0.0) + dir * (0.1 + (1.0 - exp(-t * 3.0)) * (2.2 + seed.z * 0.8)) * _EffectSize;
                    p.y -= t * t * 0.16 * _EffectSize;
                    output.fade = smoothstep(0.0, 0.04, t) * (1.0 - smoothstep(0.30 + seed.z * 0.3, 1.35, t));
                }
                else
                {
                    float f = frac(seed.z + _EffectTime * 0.5);
                    p = float3(-2.2 + f * 3.6, dir.y, dir.z) * (1.0 - f * 0.65) * _EffectSize;
                    output.fade = sin(f * VFX_PI) * Charged() * ArrowFade() * 0.6;
                }

                float3 positionVS = SourceToView(p);
                positionVS.xy += input.positionOS.xy * (0.017 + seed.w * 0.027) * _EffectSize;
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float d = abs(input.uv.x) + abs(input.uv.y);
                float a = (1.0 - smoothstep(0.4, 1.0, d)) * input.fade;
                clip(a - 0.003);
                return float4(lerp(_EffectColor.rgb, float3(1.0, 1.0, 1.0), 0.35), saturate(a));
            }
            ENDHLSL
        }
    }
}
