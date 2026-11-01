Shader "ConfusedGameDev/Vfx/BillowingAirburst Flash"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+4" }

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

            #define VFX_VARIANT 11
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "BillowingAirburstCommon.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 flashLocal : TEXCOORD0;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                if (_EffectTime <= 0.0 || _EffectTime >= 0.090)
                {
                    return output;
                }

                output.flashLocal = input.positionOS.xy * float2(6.4, 4.4);
                float scale = RootScale() * _EffectSize;
                float3 positionVS = TransformWorldToView(TransformObjectToWorld(float3(0.0, 0.0, 0.0)));
                positionVS.z += 1.35 * scale;
                positionVS.xy += output.flashLocal * scale;
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float t = _EffectTime;
                float r = length(input.flashLocal);
                float burst = smoothstep(0.0, 0.012, t) * (1.0 - smoothstep(0.028, 0.090, t));
                float disk = exp(-pow(abs(r / 1.13), 6.0));
                float halo = exp(-r * r * 0.8) * 0.16;
                float alpha = (disk + halo) * burst;
                clip(alpha - 0.002);
                float3 color = lerp(lerp(_EffectColor.rgb, float3(1.0, 0.63, 0.18), 0.7), float3(1.0, 0.98, 0.82), disk);
                return float4(color * 1.65 * 0.5, saturate(alpha));
            }
            ENDHLSL
        }
    }
}
