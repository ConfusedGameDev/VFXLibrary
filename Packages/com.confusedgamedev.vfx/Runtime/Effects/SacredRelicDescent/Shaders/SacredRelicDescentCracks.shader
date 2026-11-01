Shader "ConfusedGameDev/Vfx/SacredRelicDescent Cracks"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent" }

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

            #define VFX_VARIANT 18
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "SacredRelicDescentCommon.hlsl"

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
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                if (_ImpactAge < 0.0 || _ImpactAge >= 1.5)
                {
                    return output;
                }

                output.uv = input.uv;
                output.positionCS = TransformWViewToHClip(RelicToView(input.positionOS));
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float t = _ImpactAge;
                float edge = abs(input.uv.x - 0.5) * 2.0;
                float reveal = smoothstep(input.uv.y * 0.17, input.uv.y * 0.17 + 0.035, t);
                float fade = 1.0 - smoothstep(0.65, 1.5, t);
                float center = 1.0 - smoothstep(0.55, 1.0, edge);
                float3 color = lerp(float3(0.32, 0.25, 0.17), float3(0.035, 0.025, 0.018), center);
                float alpha = reveal * fade * _Cancel * 0.86;
                clip(alpha - 0.002);
                return float4(color, saturate(alpha));
            }
            ENDHLSL
        }
    }
}
