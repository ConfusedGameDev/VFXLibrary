Shader "ConfusedGameDev/Vfx/AstralConvergence Particles"
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

            #define VFX_VARIANT 7
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
                float life = saturate(_EffectTime / 3.4);
                float alive = smoothstep(0.0, 0.025, life) * (1.0 - smoothstep(0.70, 1.0, life));
                float f = frac(seed.x + _EffectTime * (0.25 + seed.w * 0.3));
                float a = seed.y * 6.283;
                float scale = 0.035 + seed.w * 0.055;
                output.fade = sin(f * VFX_PI) * alive * 0.7;
                output.light = 0.45 + seed.w * 0.4;
                float3 p = float3(0.0, 0.0, 0.0);

                float outAge = max(0.0, life - 0.36);
                float r = life < 0.36 ? (1.0 - life / 0.36) * 1.6 : outAge * (2.8 + seed.w * 2.1);
                float sy = seed.z * 2.0 - 1.0;
                float radial = sqrt(max(0.0, 1.0 - sy * sy));
                a += outAge * (0.6 + seed.w);
                p = float3(cos(a) * radial * r, sy * r, sin(a) * radial * r);
                output.light = 0.72 + seed.w * 0.25;
                output.fade *= 1.0 - smoothstep(0.64 + seed.x * 0.13, 0.83 + seed.x * 0.15, life);

                p.y = -1.3 + (p.y + 1.3) * _EffectSize;
                p.xz *= _EffectSize;
                float3 positionVS = SourceToView(p);
                float2 card = input.positionOS.xy * scale;
                positionVS.xy += card * RootScale();
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 q = input.uv * 2.0 - 1.0;
                float a = 1.0 - smoothstep(0.5, 0.9, abs(q.x) + abs(q.y));
                clip(a * input.fade - 0.003);
                float3 color = ToonShade(_EffectColor.rgb, input.light);
                return float4(color, saturate(a * input.fade * _EffectDetail));
            }
            ENDHLSL
        }
    }
}
