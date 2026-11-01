Shader "ConfusedGameDev/Vfx/VenomPool Mist"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+4" }

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

            #define VFX_VARIANT 8
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxGround.hlsl"

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

                float4 seed = input.seed;
                float f = _LifeStage != 2.0 ? frac(seed.x + _EffectTime * 0.16) : min(1.0, frac(seed.x + _EmitterTime * 0.16) + _LifeEnd * 0.65);
                float a = seed.y * 6.283 + _EffectTime * 0.25;
                float3 positionVS = SourceToView(float3(cos(a) * (0.3 + seed.z), 0.12 + f * 0.35, sin(a) * (0.3 + seed.z)));
                positionVS.xy += input.positionOS.xy * float2(0.65, 0.28) * RootScale();
                output.fade = sin(f * VFX_PI) * smoothstep(0.0, 0.5, _LifeStart) * (1.0 - smoothstep(0.65, 1.0, _LifeEnd));
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 q = input.uv * 2.0 - 1.0;
                float cloud = (1.0 - smoothstep(0.35, 1.0, length(q))) * smoothstep(0.2, 0.7, Noise2(q * 2.0 + _EffectTime * 0.3));
                return float4(ToonShade(_EffectColor.rgb, 0.28), saturate(cloud * input.fade * 0.65 * _EffectDetail));
            }
            ENDHLSL
        }
    }
}
