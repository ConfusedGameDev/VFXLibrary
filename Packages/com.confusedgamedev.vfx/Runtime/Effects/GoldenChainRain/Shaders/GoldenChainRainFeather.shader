Shader "ConfusedGameDev/Vfx/GoldenChainRain Feather"
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

            #define VFX_VARIANT 15
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "GoldenChainRainCommon.hlsl"
            #define GC_RIPPLE_FEATHER

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

                if (input.fade <= 0.0)
                {
                    discard;
                }

                float age = input.age;
                float2 q = input.ripple;
                float2 drift = float2(age * 0.23, -age * 0.17) + input.seed * 17.0;
                float r = length(q);
                float flow = GrNoise(q * 7.0 + drift);
                float fine = GrNoise(q * 23.0 - drift * 0.8);
                float warped = r + (flow - 0.5) * 0.045 + (fine - 0.5) * 0.012;
                float phase = warped * 52.0 - age * 8.5 + sin(atan2(q.y, q.x) * 2.0 + r * 13.0 - age * 1.7) * 0.3;
                float crest = pow(abs(0.5 + 0.5 * cos(phase)), 5.5);
                float softCrest = pow(abs(0.5 + 0.5 * cos(phase)), 1.6);
                float threads = pow(abs(0.5 + 0.5 * cos(warped * 91.0 - age * 6.4 + flow * 3.0)), 14.0);
                float broken = smoothstep(0.18, 0.80, GrNoise(q * float2(11.0, 16.0) + drift * 0.45));
                float edge = 0.64 + (flow - 0.5) * 0.025;
                float alpha = 1.0;
                #ifdef GC_RIPPLE_FEATHER
                    if (r < edge - 0.005 || r > 1.16)
                    {
                        discard;
                    }

                    alpha = 1.0 - smoothstep(edge, 1.16, r);
                #else
                    if (r > edge)
                    {
                        discard;
                    }
                #endif

                float2 hot = (q + float2(0.075, -0.02)) * float2(1.7, 1.0);
                float core = exp(-dot(hot, hot) * 26.0);
                float reflection = exp(-Sq((q.x + 0.10) * 8.0) - Sq(q.y * 2.4)) * 0.35;
                float3 trough = _EffectColor.rgb * float3(0.40, 0.43, 0.48) * (0.75 + flow * 0.5);
                float3 waveColor = lerp(_EffectColor.rgb, float3(1.0, 0.94, 0.73), 0.72);
                float waves = (crest * 1.02 + softCrest * 0.22 + threads * 0.14 * min(_EffectDetail, 1.4)) * (0.18 + broken * 0.82);
                float3 gold = trough + waveColor * waves;
                gold += float3(1.0, 0.96, 0.79) * (core * 4.0 + reflection * 1.4);
                return float4(gold * (0.8 + 0.2 * input.fade), alpha);
            }
            ENDHLSL
        }
    }
}
