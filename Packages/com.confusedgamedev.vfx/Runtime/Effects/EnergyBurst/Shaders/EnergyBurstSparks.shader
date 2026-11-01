Shader "ConfusedGameDev/Vfx/EnergyBurst Sparks"
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

            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxCommon.hlsl"

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
                float alpha : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                output.alpha = 0.0;
                if (input.id.x >= _LayerCounts.x)
                {
                    output.positionCS = float4(0.0, 0.0, 0.0, 0.0);
                    return output;
                }

                float4 seed = input.seed;
                float t = _EffectTime;
                float a = seed.x * VFX_PI * 2.0;
                float age = saturate(t / 2.8);
                float dt = max(0.0, t - seed.w * 0.1);

                float3 dir = normalize(float3(cos(a), 0.6 + seed.y * 1.8, sin(a)));
                float3 p = dir * (0.15 + (1.0 - exp(-dt * 4.0)) * (0.8 + seed.z * 2.4)) * _EffectSize;
                p.y -= 1.2;

                float size = (0.018 + seed.w * 0.045) * _EffectSize * RootScale();
                float2 shape = float2(3.2, 0.3);
                output.alpha = pow(abs(1.0 - age), 1.7) * 0.65 * (1.0 - smoothstep(0.35, 1.25, t))
                    * (1.0 - step(0.16, seed.w)) * smoothstep(0.06, 0.13, t);

                float3 mv = SourceToView(p);
                float2 along = normalize(TransformWorldToViewDir(TransformObjectToWorldDir(ToUnity(dir)), false).xy + 0.0001);
                mv.xy += (along * input.positionOS.x * shape.x + float2(-along.y, along.x) * input.positionOS.y * shape.y) * size;

                output.positionCS = TransformWViewToHClip(mv);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 q = input.uv * 2.0 - 1.0;
                float d = length(q);
                clip(1.0 - d);

                float alpha = exp(-q.y * q.y * 35.0) * (1.0 - smoothstep(0.6, 1.0, abs(q.x)));
                float3 color = _EffectColor.rgb * 1.3 + pow(abs(1.0 - d), 3.0) * 1.4;
                return float4(color, saturate(alpha * input.alpha * _EffectDetail));
            }
            ENDHLSL
        }
    }
}
