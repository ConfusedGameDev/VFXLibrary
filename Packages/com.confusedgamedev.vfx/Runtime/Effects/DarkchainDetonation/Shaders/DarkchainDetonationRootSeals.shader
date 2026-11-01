Shader "ConfusedGameDev/Vfx/DarkchainDetonation RootSeals"
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

            #define VFX_VARIANT 14
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "DarkchainDetonationCommon.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 anchor : TEXCOORD1;
                float4 release : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float arrival : TEXCOORD1;
                float release : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float t = _EffectTime;
                if (t < 0.450000 || t >= 3.930000)
                {
                    return output;
                }

                output.uv = input.uv;
                output.release = input.release.x;
                output.arrival = lerp(DC_chainStart, DC_chainEnd - 0.02, input.anchor.w);
                float3 p = input.anchor.xyz + float3(input.positionOS.x * 0.4, 0.007, input.positionOS.y * 0.4);
                output.positionCS = TransformWViewToHClip(DcView(p));
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float t = _EffectTime;
                float2 p = (input.uv - 0.5) * 2.0;
                float r = length(p);
                float a = atan2(p.y, p.x);
                float ring = exp(-Sq((r - 0.62) * 18.0));
                float rays = pow(abs(0.5 + 0.5 * cos(a * 6.0)), 12.0) * exp(-Sq((r - 0.76) * 10.0));
                float alpha = (ring * 0.7 + rays * 0.4 + exp(-r * r * 9.0) * 0.25) * smoothstep(input.arrival, input.arrival + 0.12, t) * (1.0 - smoothstep(input.release, input.release + 0.08, t)) * (0.55 + step(input.release, t) * 0.45);
                clip(alpha - 0.003);
                return float4(lerp(_EffectColor.rgb, float3(0.8, 0.62, 1.0), ring * 0.25), saturate(alpha));
            }
            ENDHLSL
        }
    }
}
