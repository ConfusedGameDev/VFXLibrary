Shader "ConfusedGameDev/Vfx/DarkchainDetonation OrbHalo"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+2" }

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

            #define VFX_VARIANT 14
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "DarkchainDetonationCommon.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 halo : TEXCOORD0;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float t = _EffectTime;
                if (t < 1.150000 || t >= 3.710000)
                {
                    return output;
                }

                output.halo = input.uv * 2.0 - 1.0;
                float3 center = CoreView();
                center.xy += input.positionOS.xy * (t >= DC_burst ? DC_releaseRadius : _OrbRadius) * 2.9 * ViewScale();
                output.positionCS = TransformWViewToHClip(center);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float t = _EffectTime;
                float r = length(input.halo) * 1.45;
                if (t >= DC_burst)
                {
                    float age = t - DC_burst;
                    float fade = 1.0 - smoothstep(0.008, DC_coreFlashLife, age);
                    float light = exp(-r * r * 5.5) * (1.0 - smoothstep(0.65, 1.2, r));
                    clip(light * fade - 0.003);
                    float3 corona = lerp(float3(0.8, 0.001, 0.06), _EffectColor.rgb, smoothstep(0.12, 0.85, r));
                    float3 hot = lerp(corona, float3(1.0, 0.42, 0.68), 1.0 - smoothstep(0.08, 0.36, r));
                    return float4(hot * 8.0, saturate(light * fade * 0.95));
                }

                clip(_OrbAlive - 0.003);
                clip(1.45 - r);
                float glow = exp(-Sq((r - 0.98) / 0.20)) * (1.0 - smoothstep(1.18, 1.45, r));
                float alpha = glow * (0.52 + _Beat * 0.18) * _OrbAlive * (0.8 + 0.2 * min(_EffectDetail, 1.5));
                clip(alpha - 0.003);
                return float4(_EffectColor.rgb, saturate(alpha));
            }
            ENDHLSL
        }
    }
}
