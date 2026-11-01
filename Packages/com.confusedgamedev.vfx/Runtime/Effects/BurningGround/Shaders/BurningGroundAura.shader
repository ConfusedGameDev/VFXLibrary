Shader "ConfusedGameDev/Vfx/BurningGround Aura"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent" }

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

            #define VFX_VARIANT 1
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxGround.hlsl"

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
                float3 p = float3(input.positionOS.x * 1.0, 0.015, -input.positionOS.y * 1.0);
                output.positionCS = GroundClip(p, 0.0, output.stagePosition);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 p = input.uv * 2.0 - 1.0;
                float r = length(p);
                float t = VFX_GROUND_TIME;
                float a = 0.0;
                float3 c = _EffectColor.rgb;


                float n = Noise2(p * 7.0 + float2(t * 0.3, -t * 0.4));
                float vein = pow(abs(1.0 - abs(sin(p.x * 19.0 + p.y * 11.0 + n * 7.0))), 7.0);
                a = (0.025 + vein * 0.15) * (1.0 - smoothstep(0.2, 0.87, r));
                c = _EffectColor.rgb * (0.6 + n * 0.8);


                return Staged(float4(c, a * _EffectDetail), input.stagePosition);
            }
            ENDHLSL
        }
    }
}
