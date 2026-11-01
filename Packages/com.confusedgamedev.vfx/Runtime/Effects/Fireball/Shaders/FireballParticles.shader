Shader "ConfusedGameDev/Vfx/Fireball Particles"
{
    Properties
    {
        [HideInInspector] _EffectTime("Time", Float) = 0
        [HideInInspector] _EffectSize("Size", Float) = 1
        [HideInInspector] _EffectDetail("Detail", Float) = 1
        [HideInInspector] _EffectColor("Color", Color) = (1, 0.22, 0.05, 1)
        [HideInInspector] _LifeStage("Life Stage", Float) = 1
        [HideInInspector] _LifeStart("Life Start", Float) = 1
        [HideInInspector] _LifeEnd("Life End", Float) = 0
        [HideInInspector] _Impact("Impact", Float) = 0
        [HideInInspector] _ParticleCount("Particle Count", Float) = 384
        [HideInInspector] _ImpactUp("Impact Up", Vector) = (0, 1, 0, 0)
    }

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

            #include "FireballCommon.hlsl"

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
                float t = _EffectTime;
                float a = seed.x * VFX_PI * 2.0;
                float r = sqrt(seed.z);
                float life = frac(seed.y + t * 0.65);

                float spread = 0.16 + life * 0.50;
                float3 p = float3(0.65 - life * (2.8 + seed.z * 0.7), sin(a) * r * spread, cos(a) * r * spread);
                p.y += sin(life * 9.0 - t * 5.0 + a) * life * 0.24;
                float size = 0.018 + seed.w * 0.052;
                float2 shape = float2(2.3, 0.45);
                output.alpha = sin(life * VFX_PI) * pow(abs(1.0 - life), 1.2) * 0.65;

                float3 positionVS = TransformWorldToView(TransformObjectToWorld(ToUnity(p)));
                float scale = length(float3(UNITY_MATRIX_M[0].y, UNITY_MATRIX_M[1].y, UNITY_MATRIX_M[2].y));
                positionVS.xy += input.positionOS.xy * size * shape * scale;

                float3 positionWS = mul(UNITY_MATRIX_I_V, float4(positionVS, 1.0)).xyz;
                output.stagePosition = ApplyStage(positionWS);
                output.positionCS = TransformWorldToHClip(positionWS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 q = input.uv * 2.0 - 1.0;
                float d = length(q);
                clip(1.0 - d);

                float alpha = exp(-d * d * 5.0) * (1.0 - smoothstep(0.65, 1.0, d));
                float3 color = ToonShade(_EffectColor.rgb, 0.46 + (1.0 - d) * 0.4);
                alpha = saturate(alpha * input.alpha * _EffectDetail);

                if (_LifeStage != 1.0)
                {
                    float coverage = PhaseCoverage(input.stagePosition);
                    clip(coverage - 0.004);
                    alpha *= coverage;
                }
                return float4(color, alpha);
            }
            ENDHLSL
        }
    }
}
