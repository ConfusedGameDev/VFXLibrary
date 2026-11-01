Shader "ConfusedGameDev/Vfx/Fireball Glow"
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
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+4" }

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
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                float3 positionVS = TransformWorldToView(TransformObjectToWorld(float3(0.0, 0.0, 0.0)));
                positionVS.xy += input.positionOS.xy * _EffectSize * (0.5 + _LifeEnd * 2.0);
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 q = input.uv * 2.0 - 1.0;
                float t = _LifeEnd;
                float a = exp(-dot(q, q) * 5.5) * (1.0 - smoothstep(0.0, 0.28, t)) * smoothstep(0.0, 0.025, t) * 0.24;
                return float4(_EffectColor.rgb, a);
            }
            ENDHLSL
        }
    }
}
