Shader "ConfusedGameDev/Vfx/GoldenChainRain Motes"
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

                if (input.id.x >= _LayerCounts.x || _EffectTime < 1.10)
                {
                    return output;
                }

                float4 seed = input.seed;
                GcChain chain = GcCycle(input.id.x);
                float isArrow = fmod(floor((input.id.x + 0.5) / (GcQuantity() * 3.0)), 4.0) < 0.5 ? 1.0 : 0.0;
                float span = chain.span;
                float3 axis = (chain.end - chain.start) / span;
                float3 right, side;
                GcBasis(axis, right, side);
                float settledTip = GcTipDistance(1.10, span);
                float tail = settledTip - 0.64;
                float along = lerp(tail * (0.02 + seed.y * 0.96), settledTip - 0.64 + seed.y * 0.30, isArrow);
                float route = saturate(along / span);
                float age = _EffectTime - chain.birth - 1.10 - (route * 0.78 + seed.z * 0.22) * 0.75;
                float angle = seed.w * 6.28318;
                float3 radial = right * cos(angle) + side * sin(angle);
                float3 velocity = radial * (0.7 + seed.z * 0.7) + float3(0.0, 0.45 + seed.w * 0.5, 0.0);
                float drift = max(age, 0.0);
                float3 p = chain.start + axis * along + radial * lerp(0.105, 0.22 * (1.0 - seed.y * 0.47), isArrow) + velocity * drift;
                p.y -= 1.4 * drift * drift;
                float scale = (0.085 + seed.w * 0.065) * (1.0 - smoothstep(0.12, 0.35, age));
                output.fade = step(0.0, age) * (1.0 - smoothstep(0.08, 0.35, age));
                if (output.fade <= 0.0)
                {
                    return output;
                }

                output.heat = 1.0 - saturate(age / 0.35);
                float spin = seed.x * 6.28318 + drift * (seed.z - 0.5) * 15.0;
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
