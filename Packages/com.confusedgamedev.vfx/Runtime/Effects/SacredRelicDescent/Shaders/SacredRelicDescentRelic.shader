Shader "ConfusedGameDev/Vfx/SacredRelicDescent Relic"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+6" }

        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite On
            Cull Front

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #define VFX_VARIANT 18
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "SacredRelicDescentCommon.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float4 data : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 surface : TEXCOORD0;
                float3 tint : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                if (_EmitTime < 1.0 || _EffectTime >= 12.2 || _Cancel <= 0.0)
                {
                    return output;
                }

                float3 p = input.positionOS;
                output.surface = float2(p.y, 0.0);
                float3 color = lerp(_EffectColor.rgb * 0.82, float3(1.00000, 0.93011, 0.79130), input.data.y) * input.data.x;
                output.tint = color;
                p.y += _BodyHeight;
                output.positionCS = TransformWViewToHClip(RelicToView(p));
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                // Cut at local ground, so the tip reads as buried.
                if (input.surface.x < _BurialDepth)
                {
                    discard;
                }

                return float4(input.tint, _BodyFade);
            }
            ENDHLSL
        }
    }
}
