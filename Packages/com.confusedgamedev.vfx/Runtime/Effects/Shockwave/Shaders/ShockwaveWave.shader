Shader "ConfusedGameDev/Vfx/Shockwave Wave"
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

            #define VFX_VARIANT 2
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"

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
                float3 stagePosition : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                output.positionCS = BurstClip(float3(input.positionOS.x, -1.36, -input.positionOS.y), output.stagePosition);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 p = input.uv * 2.0 - 1.0;
                float r = length(p);
                float t = _EffectTime;
                float radius = (1.0 - exp(-t * 3.5)) * 0.82;
                float wave = exp(-pow(abs((r - radius) * 45.0), 2.0));
                float dust = exp(-pow(abs((r - radius + 0.07) * 14.0), 2.0)) * Fbm(p * 8.0) * 0.45;
                float fade = pow(max(0.0, 1.0 - t / 2.4), 2.0);
                float alpha;
                float corrugation = Noise2(p * 14.0);
                float compress = pow(max(0.0, cos((r - radius) * 110.0 + corrugation * 2.0)), 12.0);
                float wake = exp(-pow(abs((r - radius + 0.055) * 20.0), 2.0));
                alpha = (wave * 0.24 + compress * wake * 0.20) * fade * (1.0 - smoothstep(0.4, 1.1, t));
                float3 c = StyleColor(_EffectColor.rgb, 0.35 + wave * 0.5);
                return BurstStaged(float4(c, saturate(alpha)), input.stagePosition);
            }
            ENDHLSL
        }
    }
}
