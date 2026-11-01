Shader "ConfusedGameDev/Vfx/FireExplosion Halo"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+3" }

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

            #define VFX_VARIANT 0
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 lobe : TEXCOORD1;
                float2 id : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float heat : TEXCOORD1;
                float wide : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                float t = _EffectTime;
                if (t <= 0.0 || t >= 0.68)
                {
                    return output;
                }

                float launch = 1.0 - exp(-t * 56.0);
                output.wide = step(17.5, input.id.x);
                float spread = 1.0 - exp(-t * 32.0);
                float3 center = input.lobe.xyz * float3(spread, launch, spread);
                center.xz *= 1.0 + min(t, 0.9) * 0.12;
                center.y += max(0.0, t - 0.3) * 0.65;
                center *= _EffectSize;
                center.y -= 1.35;

                float3 positionVS = SourceToView(center);
                float radius = input.lobe.w * (1.0 + min(t, 0.9) * 0.19) * launch;
                positionVS.z += radius * 0.62 * _EffectSize * RootScale();
                positionVS.xy += (input.uv - 0.5) * radius * 3.6 * _EffectSize * RootScale();
                output.heat = 1.0 - t * 1.8 + (input.lobe.y - 1.2) * 0.18;
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float d = length((input.uv - 0.5) * 2.0);
                float fade = smoothstep(0.0, 0.018, _EffectTime) * smoothstep(0.0, 0.7, input.heat);
                float alpha = exp(-d * d * lerp(5.5, 4.8, input.wide)) * (1.0 - smoothstep(0.72, 1.0, d)) * fade * lerp(0.22, 0.36, input.wide);
                clip(alpha - 0.001);
                return float4(min(_EffectColor.rgb * 2.8, float3(1.0, 1.0, 1.0)), alpha);
            }
            ENDHLSL
        }
    }
}
