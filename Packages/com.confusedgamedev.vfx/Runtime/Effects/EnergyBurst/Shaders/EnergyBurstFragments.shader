Shader "ConfusedGameDev/Vfx/EnergyBurst Fragments"
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
                float fade : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                output.fade = 0.0;
                if (input.id.x >= _LayerCounts.z)
                {
                    output.positionCS = float4(0.0, 0.0, 0.0, 0.0);
                    return output;
                }

                float4 seed = input.seed;
                float a = seed.x * VFX_PI * 2.0;
                float dt = max(0.0, _EffectTime - 0.09 - seed.w * 0.09);
                float3 dir = normalize(float3(cos(a), 0.4 + seed.y * 1.8, sin(a)));
                float3 p = dir * (0.35 + (1.0 - exp(-dt * 3.0)) * (1.2 + seed.z * 1.8));
                p *= _EffectSize;
                p.y -= 1.2;

                float3 mv = SourceToView(p);
                float2 along = normalize(TransformWorldToViewDir(TransformObjectToWorldDir(ToUnity(dir)), false).xy + 0.0001);
                float2 side = float2(-along.y, along.x);
                float jag = (Hash(float2(seed.w * 71.0, floor(input.uv.x * 4.0 + 0.01))) - 0.5) * sin(input.uv.x * VFX_PI);
                mv.xy += (along * input.positionOS.x * (0.22 + seed.z * 0.45) + side * (jag * 0.05 + input.positionOS.y * 0.16)) * _EffectSize * RootScale();

                output.fade = smoothstep(0.0, 0.07, dt) * (1.0 - smoothstep(0.28 + seed.z * 0.15, 0.65 + seed.z * 0.3, dt));
                output.positionCS = TransformWViewToHClip(mv);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 q = input.uv * 2.0 - 1.0;
                float core = exp(-q.y * q.y * 90.0);
                float halo = exp(-q.y * q.y * 8.0);
                float tip = 1.0 - smoothstep(0.2, 1.0, abs(q.x));
                return float4(_EffectColor.rgb * 1.3 + core * 1.8, saturate((core + halo * 0.25) * tip * input.fade * _EffectDetail));
            }
            ENDHLSL
        }
    }
}
