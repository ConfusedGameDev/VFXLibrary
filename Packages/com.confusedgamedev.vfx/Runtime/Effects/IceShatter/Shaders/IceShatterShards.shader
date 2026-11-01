Shader "ConfusedGameDev/Vfx/IceShatter Shards"
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

            #define VFX_VARIANT 3
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"

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
                float fade : TEXCOORD0;
                float3 normalVS : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                if (input.id.x >= _LayerCounts.z)
                {
                    return output;
                }

                float4 seed = input.seed;
                float t = _EffectTime;
                float a = seed.x * 6.28318;
                float dt = max(0.0, t - seed.w * 0.1);
                float speed = 0.5 + seed.z * 1.4;
                float3 c = float3(cos(a) * dt * speed, max(-1.32, -1.32 + (2.0 + seed.y * 3.8) * dt - 2.4 * dt * dt), sin(a) * dt * speed);
                float3 p = input.positionOS;
                p.y *= 2.2;
                p.xy = Spin(p.xy, a + t * 2.0);
                p *= 0.6 + seed.z;
                output.normalVS = SourceDirToView(input.normalOS);
                output.fade = pow(max(0.0, 1.0 - t / 2.8), 1.3);
                output.positionCS = TransformObjectToHClip(ToUnity(c + p));
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float light = 0.35 + max(dot(normalize(input.normalVS), normalize(float3(-0.6, 0.8, 0.4))), 0.0);
                return float4(StyleColor(_EffectColor.rgb, light * 0.7), saturate(input.fade * _EffectDetail));
            }
            ENDHLSL
        }
    }
}
