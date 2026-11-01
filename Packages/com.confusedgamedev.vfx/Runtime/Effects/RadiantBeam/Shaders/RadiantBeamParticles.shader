Shader "ConfusedGameDev/Vfx/RadiantBeam Particles"
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

            #define VFX_VARIANT 4
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBeam.hlsl"
            #include "Packages/com.confusedgamedev.vfx/Runtime/Effects/RadiantBeam/Shaders/RadiantBeamCommon.hlsl"

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
                float3 stagePosition : TEXCOORD3;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                if (input.id.x >= _ParticleCount)
                {
                    return output;
                }

                float4 seed = input.seed;
                float t = _EffectTime;
                float f = frac(seed.x + t * (0.25 + seed.w * 0.3));
                float a = seed.y * 6.283;
                float end = seed.x < 0.5 ? -1.0 : 1.0;
                output.fade = sin(f * VFX_PI) * 0.7 * smoothstep(0.0, 0.25, t);
                output.light = 0.45 + seed.w * 0.4;

                float3 p = float3(end * 2.4 + end * f * 0.2 / _Stretch, cos(a) * (0.3 + f * 0.7) * _EffectSize, sin(a) * (0.3 + f * 0.7) * _EffectSize);
                float3 positionVS = SourceToView(p);
                positionVS.xy += input.positionOS.xy * (0.035 + seed.w * 0.055) * RootScale();
                output.positionCS = StageViewToClip(positionVS, output.stagePosition);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 q = input.uv * 2.0 - 1.0;
                float a = (1.0 - smoothstep(0.45, 1.0, length(q))) * input.fade;
                clip(a - 0.003);
                return StageLook(ToonShade(_EffectColor.rgb, input.light), saturate(a * _EffectDetail), input.stagePosition);
            }
            ENDHLSL
        }
    }
}
