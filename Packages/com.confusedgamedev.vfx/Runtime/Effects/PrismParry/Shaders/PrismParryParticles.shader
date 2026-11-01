Shader "ConfusedGameDev/Vfx/PrismParry Particles"
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

            #define VFX_VARIANT 1
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBeamUtility.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 seed : TEXCOORD1;
                float2 id : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 normalVS : TEXCOORD0;
                float alpha : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                if (input.id.x >= _LayerCounts.x)
                {
                    return output;
                }

                float4 seed = input.seed;
                float t = _EffectTime;
                float size = 0.009 + seed.w * 0.016;
                float a = seed.x * 6.283185;
                float3 p = float3(0.0, 0.0, 0.0);
                float age = 0.0;

                float f = saturate(t / 0.55);
                float r = 0.15 + Ease(f) * (0.45 + seed.y * 0.9);
                p = float3(0.6 + f * seed.z, 0.9 + cos(a) * r, sin(a) * r) * _EffectSize;
                output.alpha = smoothstep(0.0, 0.07, f) * (1.0 - smoothstep(0.25 + seed.z * 0.25, 1.0, f));

                output.alpha *= smoothstep(0.42, 0.90, seed.w);
                float3 q = input.positionOS * size * _EffectSize;
                q.y *= 2.0;
                p += q;
                output.normalVS = TransformWorldToViewDir(TransformObjectToWorldNormal(ToUnity(input.normalOS)), false);
                output.positionCS = TransformObjectToHClip(ToUnity(p));
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                clip(input.alpha - 0.003);
                float light = dot(normalize(input.normalVS), normalize(float3(-0.4, 0.8, 0.55))) * 0.5 + 0.5;
                float3 color = lerp(_EffectColor.rgb * 0.65, lerp(_EffectColor.rgb, float3(1.0, 1.0, 1.0), 0.65), step(0.48, light));
                return float4(color, saturate(input.alpha * 0.82));
            }
            ENDHLSL
        }
    }
}
