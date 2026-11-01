Shader "ConfusedGameDev/Vfx/ChargedBeam Lance"
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

            #define VFX_VARIANT 2
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBeam.hlsl"

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
                float blade : TEXCOORD1;
                float3 stagePosition : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                float t = _EffectTime;
                float h = input.positionOS.x;
                float id = input.positionOS.z;
                output.blade = id;
                float release = smoothstep(1.52, 1.60, t);
                float a = id * 1.256637 + t * 0.25;
                float profile = pow(max(0.0, sin(h * 3.14159)), 0.55);
                float diamonds = pow(abs(sin(h * 12.56637 - t * 3.0)), 3.0);
                float width = (id < 0.5 ? 0.035 : 0.05 + profile * (0.12 + diamonds * 0.14)) * _EffectSize;
                if (id > 0.5)
                {
                    width *= release;
                }

                float bend = sin(h * 15.0 - id + t * 9.0) * 0.035 * profile * release * _EffectSize;
                float3 p = float3(h * 4.8 - 2.4, cos(a) * (input.positionOS.y * width + bend), sin(a) * (input.positionOS.y * width + bend));
                output.positionCS = StageClip(p, output.stagePosition);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float t = _EffectTime;
                float h = input.uv.x;
                float edge = abs(input.uv.y * 2.0 - 1.0);
                float release = smoothstep(1.52, 1.60, t);
                float head = clamp((t - 1.52) * 10.0, 0.0, 1.08);
                float gate = 1.0 - smoothstep(head - 0.035, head, h);
                float fiber = 0.6 + 0.4 * Noise2(float2(h * 24.0 - t * 25.0, edge * 5.0 + input.blade));
                float core = exp(-edge * edge * 24.0);
                float a = (1.0 - smoothstep(0.55, 1.0, edge)) * fiber * release * gate;
                if (input.blade < 0.5)
                {
                    a = max(a, exp(-edge * edge * 90.0) * 0.09);
                }

                float3 c = _EffectColor.rgb * (1.5 + core * 0.5) + core * 0.65;
                return float4(c, a * (input.blade < 0.5 ? 0.95 : 0.5) * StageAlpha(input.stagePosition));
            }
            ENDHLSL
        }
    }
}
