Shader "ConfusedGameDev/Vfx/MagicBarrier Sigil"
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

            #include "MagicBarrierCommon.hlsl"

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
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                float3 p = float3(input.positionOS.x, 0.025, -input.positionOS.y) * _EffectSize;
                output.stagePosition = p;
                output.positionCS = SourceToClip(p);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 p = (input.uv - 0.5) * 2.0;
                float r = length(p);
                clip(0.99 - r);

                float a = atan2(p.y, p.x);
                float t = _EmitterTime;
                float inkSum = Ink(r - 0.94, 0.003) + Ink(r - 0.9, 0.0018) + Ink(r - 0.74, 0.003);

                float spin = a - t * 0.09;
                float cells = (spin + VFX_PI) / 6.28318 * 36.0;
                float2 q = float2((frac(cells) - 0.5) * 1.8, (r - 0.821) * 16.0);
                float id = floor(cells);
                float rune = Segment(q, float2(-0.22, -0.42), float2(-0.22, 0.42));
                rune = min(rune, Segment(q, float2(-0.22, 0.31), float2(0.27, 0.10 + Mod(id, 3.0) * 0.10)));
                rune = min(rune, Segment(q, float2(-0.22, -0.15), float2(0.28, -0.35)));
                if (Mod(id, 2.0) < 1.0)
                {
                    rune = min(rune, Segment(q, float2(0.25, -0.35), float2(0.25, 0.34)));
                }
                inkSum += Ink(rune, 0.035) * step(0.77, r) * (1.0 - step(0.875, r));
                inkSum += pow(abs(sin(a * 48.0 + t * 0.12)), 32.0) * Band(r - 0.968, 0.012) * 0.7;

                inkSum += Ink(Polygon(p, 4.0, 0.40, t * 0.08), 0.004) + Ink(Polygon(p, 4.0, 0.40, VFX_PI / 4.0 + t * 0.08), 0.004);
                inkSum += Ink(Polygon(p, 8.0, 0.65, 0.0), 0.004) + Ink(Polygon(p, 4.0, 0.13, -t * 0.15), 0.01);
                inkSum += Band(r - 0.69, 0.012) * step(0.1, sin(a * 16.0 - t * 0.3));

                float accent = pow(max(0.0, cos(a * 4.0 - t * 1.2 - r * 5.0)), 16.0);
                float alpha = min(inkSum * (0.72 + accent * 0.65), 1.0) * 0.76;
                return float4(_EffectColor.rgb * 1.4 + 0.04, saturate(alpha * _EffectDetail * PhaseCoverage(input.stagePosition)));
            }
            ENDHLSL
        }
    }
}
