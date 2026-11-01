Shader "ConfusedGameDev/Vfx/GoldenChainRain Bloom"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+3" }

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

            #define VFX_VARIANT 15
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "GoldenChainRainCommon.hlsl"
            #define GC_RIPPLE_GLOW

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
                float2 ripple : TEXCOORD0;
                float age : TEXCOORD1;
                float fade : TEXCOORD2;
                float seed : TEXCOORD3;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                GcChain chain;
                if (!GcLoad(input.id.x, chain))
                {
                    return output;
                }

                float age = _EffectTime - chain.birth;
                output.fade = smoothstep(0.0, 0.085, age) * (1.0 - smoothstep(1.10, 1.55, age));
                if (output.fade <= 0.0)
                {
                    return output;
                }

                float open = 1.0 - pow(abs(1.0 - saturate(age / 0.16)), 3.0);
                float radius = 0.82 * (0.45 + 0.55 * open);
                float3 forward = (chain.end - chain.start) / chain.span;
                float3 across, up;
                GcBasis(forward, across, up);
                float3 center = chain.start;
                float extent = 1.0;
                #ifdef GC_RIPPLE_GLOW
                    extent = 1.9;
                    float3 planeNormal = normalize(cross(across, up));
                    float3 viewNormal = SourceDirToView(planeNormal);
                    float3 viewCenter = SourceToView(center * _EffectSize);
                    center += planeNormal * 0.004 * sign(dot(viewNormal, -viewCenter));
                #endif
                #ifdef GC_RIPPLE_FEATHER
                    extent = 1.2;
                #endif
                radius *= lerp(0.48, 1.0, sqrt(output.fade));
                float3 p = center + (across * input.positionOS.x + up * input.positionOS.y) * radius * extent;
                output.ripple = input.positionOS.xy * extent;
                output.age = age;
                output.seed = chain.seed;
                output.positionCS = TransformWViewToHClip(SourceToView(p * _EffectSize));
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float r = length(input.ripple);
                if (input.fade <= 0.0 || r >= 1.9)
                {
                    discard;
                }

                float mist = GrNoise(input.ripple * 4.2 + float2(input.age * 0.17, -input.age * 0.13) + input.seed * 11.0);
                float haze = 0.7 + 0.3 * mist;
                float bloom = exp(-r * r * 1.05) * 0.54 + exp(-r * r * 5.0) * 0.18;
                float bloomSpread = 0.22 + 0.78 * smoothstep(0.28, 1.10, r);
                float alpha = bloom * haze * bloomSpread * (1.0 - smoothstep(1.35, 1.9, r)) * input.fade * (0.8 + 0.2 * min(_EffectDetail, 1.5));
                clip(alpha - 0.002);
                return float4(lerp(_EffectColor.rgb, float3(1.0, 0.88, 0.55), 0.25) * 1.8, saturate(alpha));
            }
            ENDHLSL
        }
    }
}
