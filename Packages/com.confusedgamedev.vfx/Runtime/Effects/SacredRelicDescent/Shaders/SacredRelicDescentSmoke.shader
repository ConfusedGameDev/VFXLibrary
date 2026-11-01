Shader "ConfusedGameDev/Vfx/SacredRelicDescent Smoke"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+8" }

        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
            Blend One One
            ZWrite Off
            Cull Off

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #define VFX_VARIANT 18
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "SacredRelicDescentCommon.hlsl"

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
                float2 ring : TEXCOORD1;
                float seedValue : TEXCOORD2;
                float roll : TEXCOORD3;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                if (_PulseAge < 0.0)
                {
                    return output;
                }

                float4 seed = input.seed;
                output.uv = input.uv * 2.0 - 1.0;
                float t = max(0.0, _PulseAge);
                float p = saturate(t / 1.6);
                float a = seed.x * 6.283185;
                float r = _WaveRadius * 0.85;
                float radialRoll = sin(t * 7.0 + seed.z * 6.283) * 0.16 * sin(p * 3.14159);
                float3 center = float3(cos(a) * (r + radialRoll), sin(a * 5.0 + t * 5.0) * 0.13 + sin(t * 6.0 + seed.y * 6.283) * 0.12, sin(a) * (r + radialRoll));
                float width = min(r * 0.58, 1.8 + seed.z * 0.65) * (1.0 - p * 0.25);
                float height = (0.45 + seed.w * 0.55) * smoothstep(0.0, 0.16, t) * (1.0 - p * 0.28);
                float3 right = normalize(RelicViewToSource(float3(1.0, 0.0, 0.0)));
                float3 up = normalize(RelicViewToSource(float3(0.0, 1.0, 0.0)));
                height *= sqrt(Sq(5.0 * up.y) + max(0.0, 1.0 - up.y * up.y));
                float3 q = center + right * input.positionOS.x * width + up * input.positionOS.y * height;
                output.ring = q.xz;
                output.seedValue = seed.y * 27.0;
                output.roll = seed.z * 6.283 + t * (1.2 + seed.w);
                output.positionCS = TransformWViewToHClip(RelicToView(q + float3(0.0, 1.5, 0.0)));
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float t = max(0.0, _PulseAge);
                float2 p = input.uv;
                float angle = input.roll + length(p) * 1.2;
                float2 q = Spin(p, angle);
                float n = RelicNoise(q * 2.7 + float2(input.seedValue, -t * 1.4)) * 0.6 + RelicNoise(q * 6.3 + float2(-t * 0.8, input.seedValue)) * 0.28 + RelicNoise(q * 11.0 + input.seedValue) * 0.12;
                float envelope = pow(abs(1.0 - smoothstep(0.12, 1.08, length(p) + (0.5 - n) * 0.22)), 1.5);
                float cloud = smoothstep(0.22, 0.66, n);
                float curl = exp(-Sq((n - 0.52) / 0.07)) * (0.55 + 0.45 * _EffectDetail);
                float radius = length(input.ring);
                float inner = max(0.72, _WaveRadius * 0.85 - 0.88);
                float hole = smoothstep(inner, inner + 0.32, radius) * (1.0 - smoothstep(_MaxRadius - 0.3, _MaxRadius, radius));
                float fade = smoothstep(0.04, 0.18, t) * (1.0 - smoothstep(0.95, 1.6, t));
                float alpha = envelope * (cloud * 0.10 + curl * 0.065) * hole * fade * _Cancel;
                clip(alpha - 0.0005);
                float3 color = lerp(_EffectColor.rgb, float3(1.0, 0.98, 0.9), clamp(curl * 0.45 + cloud * 0.25, 0.0, 0.65));

                // The source premultiplies after display conversion, so feathered overlaps stay soft.
                return float4(saturate(color * 5.0) * alpha, 0.0);
            }
            ENDHLSL
        }
    }
}
