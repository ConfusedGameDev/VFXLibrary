Shader "ConfusedGameDev/Vfx/EnergyBurst Wave"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+2" }

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

            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxCommon.hlsl"

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
                float2 flat = input.positionOS.xy * _EffectSize;
                output.positionCS = TransformWorldToHClip(TransformObjectToWorld(ToUnity(float3(flat.x, -1.36, -flat.y))));
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 p = input.uv * 2.0 - 1.0;
                float r = length(p);
                float t = _EffectTime;
                float radius = (1.0 - exp(-t * 3.5)) * 0.82;
                float wave = exp(-pow((r - radius) * 45.0, 2.0));
                float dust = exp(-pow((r - radius + 0.07) * 14.0, 2.0)) * Fbm(p * 8.0) * 0.45;
                float alpha = (wave * 0.22 + dust * 0.28 + exp(-r * r * 12.0) * 0.18) * smoothstep(0.0, 0.08, t) * (1.0 - smoothstep(0.32, 0.8, t));
                float3 c = pow(abs(_EffectColor.rgb), 0.55) * float3(0.65, 1.4, 1.0) + wave * 0.2;
                return float4(c, saturate(alpha));
            }
            ENDHLSL
        }
    }
}
