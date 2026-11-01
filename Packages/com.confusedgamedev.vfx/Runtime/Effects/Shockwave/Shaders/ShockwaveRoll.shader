Shader "ConfusedGameDev/Vfx/Shockwave Roll"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+1" }

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

            #define VFX_VARIANT 2
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float2 id : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float fade : TEXCOORD1;
                float id : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                float id = input.id.x;
                output.id = id;
                float seed = frac(id * 0.618034);
                float t = max(0.0, _EffectTime - seed * 0.14);
                float a = id * 2.39996 - t * 0.25;
                float grow = 1.0 - exp(-t * 6.0);
                float roll = t * (1.5 + seed * 0.4);
                float r = 0.16 + grow * (1.05 + seed * 0.45) + t * 0.28;

                float3 p = float3(cos(a) * r, -1.35 + (sin(min(roll, 3.14159)) * 0.58 + 0.08) * grow, sin(a) * r);
                p.y = -1.35 + (p.y + 1.35) * _EffectSize;
                p.xz *= _EffectSize;

                float3 positionVS = SourceToView(p);
                positionVS.xy += input.positionOS.xy * float2(1.15 + seed * 0.5, 0.85 + seed * 0.3) * grow * (1.0 + t * 0.25) * _EffectSize * RootScale();
                output.fade = smoothstep(0.0, 0.08, t) * (1.0 - smoothstep(0.80 + seed * 0.25, 1.65 + seed * 0.2, t));
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float t = _EffectTime;
                float id = input.id;
                float2 q = Spin(input.uv * 2.0 - 1.0, t * (0.9 + frac(id * 0.37)) + id * 2.4);
                float3 n = NoiseGradient(q * 2.6 + float2(id * 17.0, -t * 0.65));
                float d = length(q) + (n.x - 0.5) * 0.30;
                float light = SmokeOptics(q, n.yz * 2.6, n.x, KeyLight()).x;
                float a = (1.0 - smoothstep(0.68, 0.96, d)) * smoothstep(0.13, 0.40, n.x) * input.fade;
                float3 c = StyleColor(_EffectColor.rgb * 0.52, 0.16 + light * 0.55 + n.x * 0.18);
                return float4(c, saturate(a * 0.86));
            }
            ENDHLSL
        }
    }
}
