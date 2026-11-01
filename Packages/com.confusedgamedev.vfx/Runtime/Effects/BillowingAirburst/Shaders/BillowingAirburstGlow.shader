Shader "ConfusedGameDev/Vfx/BillowingAirburst Glow"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" "Queue" = "Geometry" }

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
                float2 uv : TEXCOORD0;
                float4 lobe : TEXCOORD1;
                float4 data : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float heat : TEXCOORD1;
                float jet : TEXCOORD2;
                float hot : TEXCOORD3;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float t = _EffectTime;
                float4 data = input.data;
                if (t <= 0.0 || t >= 1.30 || data.y >= round(_Quantity))
                {
                    return output;
                }

                output.uv = input.uv;
                output.jet = data.y;
                float3 center;
                float swell, age;
                LobeMotion(t, input.lobe, data, center, swell, age);
                float heatAge = t - (data.y >= 0.0 ? data.z * 0.22 : 0.0);
                float pattern = Billow(center * 1.65 + _BurstOffset + float3(0.0, -t * 0.36, t * 0.12));
                output.hot = FlameHeat(heatAge, pattern);
                float cooling = 1.0 - smoothstep(0.40, 1.08, heatAge);
                output.heat = (1.0 - exp(-age * 30.0)) * (output.hot + cooling * (1.0 - output.hot) * 0.30);
                if (age <= 0.0 || output.heat * (data.y >= 0.0 ? 0.085 : 0.065) * 1.5 < 0.00199)
                {
                    return output;
                }

                float bodyRadius = input.lobe.w * swell * 1.2;
                float radius = bodyRadius + (data.y >= 0.0 ? 1.05 : 1.8) * min(1.0, swell);
                float3 positionVS = SourceToView(center * _EffectSize);
                positionVS.xy += input.positionOS.xy * radius * RootScale() * _EffectSize;
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float r = length((input.uv - 0.5) * 2.0);
                clip(1.0 - r);
                float softHalo = exp(-r * r * 5.0) * 0.6 + exp(-r * r * 2.0) * 0.4;
                float alpha = softHalo * (1.0 - smoothstep(0.65, 1.0, r));
                alpha *= input.heat * (input.jet >= 0.0 ? 0.085 : 0.065) * 1.5;
                clip(alpha - 0.002);
                float3 tint = lerp(_EffectColor.rgb, float3(1.0, 0.92, 0.68), input.hot * exp(-r * r * 8.0) * 0.30);
                return float4(tint, saturate(alpha));
            }
            ENDHLSL
        }
    }
}
