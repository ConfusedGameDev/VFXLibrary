Shader "ConfusedGameDev/Vfx/GoldenChainRain Chips"
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

            #define VFX_VARIANT 15
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "GoldenChainRainCommon.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 seed : TEXCOORD1;
                float2 id : TEXCOORD2;
                float3 crackA : TEXCOORD3;
                float3 crackB : TEXCOORD4;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float fade : TEXCOORD1;
                float heat : TEXCOORD2;
                float ground : TEXCOORD3;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                if (input.id.x >= _LayerCounts.y * 8.0)
                {
                    return output;
                }

                float4 seed = input.seed;
                GcChain chain = GcCycle(input.id.x);
                float along = 0.15 + seed.x * 0.70;
                float2 q = lerp(GcCrackPoint(input.crackA.xy, chain.seed), GcCrackPoint(input.crackB.xy, chain.seed), along);
                float reveal = lerp(input.crackA.z, input.crackB.z, along) * 0.15 + 0.03;
                float age = _EffectTime - chain.birth - 0.35 - reveal - seed.z * 0.42;
                float drift = max(age, 0.0);
                float angle = seed.w * 6.283185;
                float3 p = chain.end + float3(q.x, 0.012, q.y) + float3(cos(angle) * 0.14, (0.48 + seed.y * 0.38) * 2.0, sin(angle) * 0.14) * drift;
                p.y += 0.13 * drift * drift * 2.0;
                output.fade = step(0.0, age) * smoothstep(0.0, 0.035, age) * (1.0 - smoothstep(0.22, 0.65, age));
                if (output.fade <= 0.0)
                {
                    return output;
                }

                output.heat = 1.0 - saturate(age / 0.65);
                float scale = (0.035 + seed.y * 0.045) * (1.0 - smoothstep(0.25, 0.65, age));
                float spin = angle + drift * (seed.x - 0.5) * 5.0;
                float2 direction = float2(cos(spin), sin(spin));
                float2 offset = (direction * input.positionOS.x * 1.5 + float2(-direction.y, direction.x) * input.positionOS.y * 0.58) * scale;
                output.ground = p.y + GcViewToSource(float3(offset, 0.0)).y;
                float3 positionVS = SourceToView(p * _EffectSize);
                positionVS.xy += offset * _EffectSize * RootScale();
                output.uv = input.uv;
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                if (input.ground < 0.0)
                {
                    discard;
                }

                float2 q = input.uv * 2.0 - 1.0;
                float edge = max(max(-q.y - 0.55, q.x * 0.92 + q.y * 0.5 - 0.30), -q.x * 0.75 + q.y * 0.55 - 0.34);
                float chip = 1.0 - smoothstep(-0.045, 0.025, edge);
                float halo = exp(-Sq(max(edge, 0.0) * 9.0)) * 0.27 * (1.0 - smoothstep(0.45, 1.0, length(q)));
                float alpha = (chip * 0.85 + halo) * input.fade * min(1.0, _EffectDetail);
                clip(alpha - 0.004);
                float3 gold = _EffectColor.rgb * (0.85 + input.uv.y * 0.7) + float3(0.45, 0.34, 0.10) * exp(-abs(edge) * 60.0) * input.heat;
                return float4(gold, saturate(alpha));
            }
            ENDHLSL
        }
    }
}
