Shader "ConfusedGameDev/Vfx/SpiralGale Particles"
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

            #define VFX_VARIANT 6
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxProjectile.hlsl"

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
                float f = frac(seed.x + _EffectTime * (0.25 + seed.w * 0.3));
                float a = seed.y * 6.283;
                float scale = (0.035 + seed.w * 0.055) * (1.0 - f * 0.5);
                output.fade = sin(f * VFX_PI) * 0.7;
                output.light = 0.45 + seed.w * 0.4;

                float3 p = float3(-0.38 * _EffectSize - f * 2.8, cos(a) * (f * 0.4 + 0.1), sin(a) * (f * 0.4 + 0.1));
                p.yz *= _EffectSize;
                scale *= 0.23 * _EffectSize;
                float3 positionVS = SourceToView(p);
                float2 corner = input.positionOS.xy * scale;
                corner.x *= 2.5;
                positionVS.xy += corner * RootScale();
                output.positionCS = StageViewToClip(positionVS, output.stagePosition);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 q = input.uv * 2.0 - 1.0;
                float a = (1.0 - smoothstep(0.1, 0.7, abs(q.y))) * (1.0 - smoothstep(0.65, 1.0, abs(q.x)));
                clip(a * input.fade - 0.003);
                return float4(ToonShade(_EffectColor.rgb, input.light), saturate(a * input.fade * _EffectDetail) * StageAlpha(input.stagePosition));
            }
            ENDHLSL
        }
    }
}
