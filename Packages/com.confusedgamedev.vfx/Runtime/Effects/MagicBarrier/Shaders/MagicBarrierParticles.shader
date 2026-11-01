Shader "ConfusedGameDev/Vfx/MagicBarrier Particles"
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

            #include "MagicBarrierCommon.hlsl"

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
                float3 stagePosition : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                output.alpha = 0.0;
                output.stagePosition = float3(0.0, 0.0, 0.0);
                if (input.id.x >= _ParticleCount)
                {
                    output.positionCS = float4(0.0, 0.0, 0.0, 0.0);
                    return output;
                }

                float4 seed = input.seed;
                float t = _EmitterTime;
                float spin = seed.x * VFX_PI * 2.0 + t * 0.15;
                float polar = seed.y * VFX_PI * 0.5;
                float3 p = float3(cos(spin) * sin(polar), cos(polar), sin(spin) * sin(polar)) * 1.85 * _EffectSize;
                output.stagePosition = p;
                output.alpha = 0.25 + 0.2 * sin(t * 2.0 + seed.z * 6.0);

                if (_LifeStage != 1.0)
                {
                    p = StageShape(p, _LifeStart, _LifeEnd);
                }
                float3 mv = SourceToView(p);
                mv.xy += input.positionOS.xy * (0.04 + seed.w * 0.055) * _EffectSize * RootScale();
                output.positionCS = TransformWViewToHClip(mv);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 q = input.uv * 2.0 - 1.0;
                float alpha = Band(max(abs(q.x), abs(q.y)) - 0.52, 0.07);
                return float4(_EffectColor.rgb * 1.3, saturate(alpha * input.alpha * _EffectDetail * PhaseCoverage(input.stagePosition)));
            }
            ENDHLSL
        }
    }
}
