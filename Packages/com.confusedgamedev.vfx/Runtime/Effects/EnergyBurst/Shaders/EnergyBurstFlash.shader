Shader "ConfusedGameDev/Vfx/EnergyBurst Flash"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+4" }

        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
            Blend One OneMinusSrcAlpha
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
                float3 mv = SourceToView(float3(0.0, -1.20 + _EffectSize * 0.12, 0.0));
                mv.xy += input.positionOS.xy * _EffectSize * (1.1 + min(_EffectTime, 0.25) * 3.6) * RootScale();
                output.positionCS = TransformWViewToHClip(mv);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 p = input.uv * 2.0 - 1.0;
                float r = length(p);
                float a = atan2(p.y, p.x);
                float t = _EffectTime;
                float hot = exp(-r * r * 160.0);
                float inner = exp(-r * r * 40.0);
                float halo = exp(-r * r * 5.0);
                float spokes = pow(abs(cos(a * 3.0)), 35.0) * exp(-r * 6.0) + exp(-p.y * p.y * 1500.0 - abs(p.x) * 4.0);
                float fade = smoothstep(0.0, 0.035, t) * (1.0 - smoothstep(0.18, 0.52, t));
                float3 tint = _EffectColor.rgb;
                float3 c = lerp(tint, pow(abs(tint), 0.55) * float3(0.65, 1.4, 1.0), inner) + hot * 2.0;
                float covered = min(1.0, (hot + inner * 0.6 + halo * 0.22 + spokes * 0.32) * fade);
                return float4(c * covered, covered * 0.6);
            }
            ENDHLSL
        }
    }
}
