Shader "ConfusedGameDev/Vfx/DarkchainDetonation ImpactGlints"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+7" }

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
                float4 glint : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 seed : TEXCOORD1;
                float alpha : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float t = _EffectTime;
                if (t < 3.650000 || t >= 4.150000)
                {
                    return output;
                }

                float b = t - DC_burst;
                float4 glint = input.glint;
                output.uv = input.uv;
                output.seed = glint;
                float3 local = float3(0.0, 0.0, 0.0);
                float span;
                float width;
                if (glint.x < 2.0)
                {
                    output.alpha = 1.0 - smoothstep(0.015, DC_flareLife, b);
                    span = lerp(4.0, 12.5, 1.0 - exp(-max(b, 0.0) * 70.0));
                    width = 1.2;
                }
                else
                {
                    float delay = 0.045 + glint.y * 0.07;
                    float age = max(0.0, b - delay);
                    float y = 1.0 - 2.0 * (glint.x - 1.5) / 18.0;
                    float angle = glint.x * 2.39996323 + glint.y;
                    float ring = sqrt(max(0.0, 1.0 - y * y));
                    float3 dir = float3(cos(angle) * ring, y, sin(angle) * ring);
                    float travel = 1.0 - exp(-age * 10.0);
                    local = dir * lerp(1.8, 3.6 + glint.z * 2.6, travel);
                    float flicker = pow(max(0.0, sin(age * (28.0 + glint.w * 30.0) + 1.0)), 4.0);
                    output.alpha = step(delay, b) * (1.0 - smoothstep(0.23, DC_glintLife, b)) * (0.18 + 0.82 * flicker);
                    span = (0.13 + glint.z * 0.21) * (1.0 - age * 0.6);
                    width = span;
                }

                float3 positionVS = DcView(local + float3(0.0, DC_centerY, 0.0));
                float2 p = input.positionOS.xy;
                if (glint.x < 2.0)
                {
                    p *= glint.x < 0.5 ? float2(span, width) : float2(width, span * 0.76);
                }
                else
                {
                    p *= span;
                }

                positionVS.xy += p * ViewScale();
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 p = abs(input.uv * 2.0 - 1.0);
                float shape;
                if (input.seed.x < 2.0)
                {
                    float along = input.seed.x < 0.5 ? p.x : p.y;
                    float across = input.seed.x < 0.5 ? p.y : p.x;
                    float taper = 0.012 + 0.48 * pow(abs(1.0 - along), 2.8);
                    shape = exp(-Sq(across / taper) * 3.0) * pow(abs(1.0 - along), 1.4);
                }
                else
                {
                    shape = exp(-p.x * 28.0 - p.y * 3.0) + exp(-p.y * 28.0 - p.x * 3.0) + exp(-dot(p, p) * 18.0) * 0.35;
                }

                float alpha = shape * input.alpha;
                clip(alpha - 0.003);
                float3 color = lerp(_EffectColor.rgb, float3(1.0, 0.005, 0.06), input.seed.y) * 2.2;
                color = lerp(color, float3(2.5, 1.2, 1.8), exp(-dot(p, p) * 16.0) * 0.85);
                if (input.seed.x < 2.0)
                {
                    color *= 5.4;
                }

                return float4(color, saturate(alpha));
            }
            ENDHLSL
        }
    }
}
