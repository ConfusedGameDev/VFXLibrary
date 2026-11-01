Shader "ConfusedGameDev/Vfx/ArcaneMissile Gems"
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

            #define VFX_VARIANT 3
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxProjectile.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 id : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 normalVS : TEXCOORD0;
                float quantityFade : TEXCOORD1;
                float3 stagePosition : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float orbit = input.id.x;
                output.quantityFade = step(orbit, _Quantity - 0.5);
                float a = orbit * (_Quantity == 3.0 ? 2.094395 : 6.283185307 / _Quantity) - _EffectTime * 3.0;
                float3 p = input.positionOS * float3(1.4, 0.6, 0.6);
                p += float3(sin(a * 2.0) * 0.09, cos(a) * 0.26 * _Spread, sin(a) * 0.26 * _Spread);
                output.normalVS = TransformWorldToViewDir(TransformObjectToWorldDir(ToUnity(input.normalOS), false), false);
                output.positionCS = StageClip(p * _EffectSize + float3(0.85, 0.0, 0.0), output.stagePosition);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                clip(input.quantityFade - 0.5);
                float l = abs(dot(normalize(input.normalVS), normalize(float3(-0.5, 0.8, 0.4))));
                return float4(ToonShade(_EffectColor.rgb, 0.2 + l * 0.75), StageAlpha(input.stagePosition));
            }
            ENDHLSL
        }
    }
}
