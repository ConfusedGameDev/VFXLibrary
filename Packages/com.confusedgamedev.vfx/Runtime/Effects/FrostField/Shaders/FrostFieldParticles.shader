Shader "ConfusedGameDev/Vfx/FrostField Particles"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+3" }

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

            #define VFX_VARIANT 2
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxGround.hlsl"

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
                float seed : TEXCOORD2;
                float3 stagePosition : TEXCOORD3;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                output.seed = input.seed.w;
                if (input.id.x >= _ParticleCount)
                {
                    return output;
                }

                float4 seed = input.seed;
                float t = VFX_GROUND_TIME;
                float a = seed.x * VFX_PI * 2.0;
                float r = sqrt(seed.z);
                float life = frac(seed.y + t * 0.35);
                float spin = a + t * 0.15;

                float3 p = float3(cos(spin) * r * 1.85, life * 1.4, sin(spin) * r * 1.85);
                float alpha = sin(life * VFX_PI) * 0.55;
                float size = 0.04 + seed.w * 0.055;
                float2 shape = float2(1.0, 1.0);

                p.y = 0.08 + life * 0.4;
                p.xz *= 0.88 + 0.12 * sin(life * VFX_PI);
                alpha *= 0.5 + 0.5 * pow(max(0.0, sin(t * 2.0 + seed.z * 29.0)), 4.0);


                output.alpha = alpha;
                float3 positionVS = SourceToView(p);
                positionVS.xy += input.positionOS.xy * size * shape * RootScale();
                output.positionCS = GroundViewToClip(positionVS, seed.x * 37.0, output.stagePosition);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 uv = input.uv;
                float2 q = uv * 2.0 - 1.0;
                float d = length(q);
                clip(1.0 - d);

                float alpha;
                float3 color = lerp(_EffectColor.rgb, float3(1.0, 1.0, 1.0), pow(abs(1.0 - d), 8.0) * 0.35);

                float spoke = pow(abs(cos(atan2(q.y, q.x) * 3.0)), 28.0);
                alpha = (spoke * (1.0 - smoothstep(0.4, 0.85, d)) + exp(-d * d * 45.0)) * 0.85;


                return Staged(float4(color, alpha * input.alpha * _EffectDetail), input.stagePosition);
            }
            ENDHLSL
        }
    }
}
