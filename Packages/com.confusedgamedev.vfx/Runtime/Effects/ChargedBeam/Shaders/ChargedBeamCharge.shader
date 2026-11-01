Shader "ConfusedGameDev/Vfx/ChargedBeam Charge"
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
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBeam.hlsl"

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
                float3 stagePosition : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                if (input.id.x >= _LayerCounts.x)
                {
                    return output;
                }

                float t = _EffectTime;
                float h = input.uv.x;
                float charge = min(t / 1.52, 1.0);
                float a = input.seed.x * 6.28318 - h * 2.6 - t * 2.1;
                float r = (1.0 - h) * (0.35 + charge * 0.65);
                float3 p = float3(-2.4 - (1.0 - h) * (0.3 + input.seed.y * 0.55) / _Stretch, cos(a) * r * _EffectSize, sin(a) * r * _EffectSize);
                p.yz += float2(cos(a), sin(a)) * input.positionOS.y * 0.028 * _EffectSize;
                output.fade = sin(h * 3.14159) * (0.15 + charge * 0.8) * (1.0 - smoothstep(1.55, 1.75, t) * 0.40);
                output.positionCS = StageClip(p, output.stagePosition);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float edge = abs(input.uv.y * 2.0 - 1.0);
                float core = exp(-edge * edge * 16.0);
                return float4(_EffectColor.rgb * 1.8 + core * 0.35, saturate(core * input.fade * _EffectDetail) * StageAlpha(input.stagePosition));
            }
            ENDHLSL
        }
    }
}
