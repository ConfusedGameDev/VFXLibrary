Shader "ConfusedGameDev/Vfx/DarkchainDetonation ShockRing"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+7" }

        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Front

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #define VFX_VARIANT 14
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "DarkchainDetonationCommon.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float across : TEXCOORD0;
                float2 ring : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float t = _EffectTime;
                if (t < 3.650000 || t >= 4.450000)
                {
                    return output;
                }

                float b = max(0.0, t - DC_burst);
                float shrink = 1.0 - smoothstep(0.32, DC_waveLife, b);
                output.across = input.uv.x;
                float width = min(_WaveRadius * 0.8, DC_waveWidth) * shrink;
                float r = _WaveRadius - width * (1.0 - input.uv.x);
                float2 direction = normalize(input.positionOS.xz);
                output.ring = direction;
                float3 p = float3(direction.x * r, DC_centerY + input.uv.y * DC_waveHeight * shrink, direction.y * r);
                output.positionCS = TransformWViewToHClip(DcView(p));
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float t = max(0.0, _EffectTime - DC_burst);
                float life = 1.0 - smoothstep(0.08, DC_waveLife, t);
                float across = saturate(input.across);
                float2 direction = normalize(input.ring);
                float grain = Noise3(float3(direction * 18.0, across * 4.0 - t * 0.5));
                float bristles = Noise3(float3(direction * 110.0, across * 0.85));
                float brush = 0.68 + 0.32 * smoothstep(0.20, 0.72, grain);
                float dry = smoothstep(0.42, 0.70, bristles);
                float tears = Noise3(float3(direction * 6.0, 1.7));
                float edge = 0.57 + 0.27 * Noise3(float3(direction * 16.0, 2.3)) + 0.16 * bristles;
                float broken = smoothstep(0.31, 0.49, tears) * (1.0 - smoothstep(edge - 0.025, edge, across));
                float pressure = pow(abs(smoothstep(0.0, 0.82, across)), 0.75);
                float trailingFade = smoothstep(0.0, 0.24, across);
                float inkOpacity = (0.65 + pressure * 0.33) * brush * (1.0 - dry * 0.32) * trailingFade * broken;
                clip(life * inkOpacity - 0.003);
                return float4(0.0002, 0.0001, 0.0004, saturate(life * inkOpacity));
            }
            ENDHLSL
        }
    }
}
