Shader "ConfusedGameDev/Vfx/ThunderStrike Particles"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+3" }

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

            #define VFX_VARIANT 5
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"

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
                float light : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                if (input.id.x >= _LayerCounts.x)
                {
                    return output;
                }

                float4 seed = input.seed;
                float life = saturate(_EffectTime / 2.6);
                float alive = smoothstep(0.0, 0.025, life) * (1.0 - smoothstep(0.70, 1.0, life));
                float f = frac(seed.x + _EffectTime * (0.25 + seed.w * 0.3));
                float a = seed.y * 6.283;
                float scale = 0.035 + seed.w * 0.055;
                output.fade = sin(f * VFX_PI) * alive * 0.7;
                output.light = 0.45 + seed.w * 0.4;
                float3 p = float3(0.0, 0.0, 0.0);

                float t = max(0.0, _EffectTime - 0.23 - seed.x * 0.1);
                float r = (1.0 - exp(-t * 4.0)) * (0.8 + seed.z * 2.8);
                p = float3(cos(a) * r, -1.3 + sin(min(t, 1.0) * VFX_PI) * seed.z * 1.35, sin(a) * r);
                output.fade *= smoothstep(0.0, 0.04, t) * (1.0 - smoothstep(0.35, 0.95, t)) * (1.0 - step(0.13, seed.w));
                scale *= _EffectSize * 1.4;

                p.y = -1.3 + (p.y + 1.3) * _EffectSize;
                p.xz *= _EffectSize;
                float3 positionVS = SourceToView(p);
                float2 along = SourceDirToView(float3(cos(a), 0.5, sin(a))).xy;
                along = length(along) < 0.0001 ? float2(1, 0) : normalize(along);
                float2 card = input.positionOS.xy * scale;
                card = along * card.x * 4.0 + float2(-along.y, along.x) * card.y * 0.8;
                positionVS.xy += card * RootScale();
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 q = input.uv * 2.0 - 1.0;
                float a = exp(-q.y * q.y * 35.0) * (1.0 - smoothstep(0.4, 1.0, abs(q.x)));
                clip(a * input.fade - 0.003);
                float3 color = _EffectColor.rgb * 1.3 + exp(-dot(q, q) * 14.0) * 1.8;
                return float4(color, saturate(a * input.fade * _EffectDetail));
            }
            ENDHLSL
        }
    }
}
