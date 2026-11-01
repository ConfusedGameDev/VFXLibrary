Shader "ConfusedGameDev/Vfx/SpellIndicatorSector Surface"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent" }

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

            #define VFX_VARIANT 17
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 surface : TEXCOORD0;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.surface = input.positionOS.xy;
                float3 p = float3(input.positionOS.x * _Motion2.y, 0.01, input.positionOS.y * _Motion2.y);
                output.positionCS = TransformObjectToHClip(ToUnity(p));
                return output;
            }

            float RayDistance(float2 p, float2 direction)
            {
                return length(p - direction * saturate(dot(p, direction)));
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float progress = _Motion0.x;
                float halfAngle = _Motion0.y;
                float opacity = _Motion0.z;
                float flash = _Motion0.w;
                float3 edgeColor = _Motion1.rgb;
                float2 p = input.surface;
                float radius = length(p);
                float aa = max(length(fwidth(p)) * 0.65, 0.00015);
                float angle = atan2(p.y, abs(p.x) + abs(p.y) < 0.000001 ? 0.000001 : p.x);
                float boundary = 1.0 - radius;
                if (halfAngle < VFX_PI - 0.00001)
                {
                    float2 ray = float2(cos(halfAngle), sin(halfAngle));
                    float side = min(RayDistance(p, ray), RayDistance(p, float2(ray.x, -ray.y)));
                    boundary = min(boundary, abs(angle) <= halfAngle ? side : -side);
                }

                float coverage = smoothstep(-aa, aa, boundary);
                float edge = 1.0 - smoothstep(0.007, 0.014 + aa, boundary);
                float halo = 1.0 - smoothstep(0.014, 0.075, boundary);
                float filled = (1.0 - smoothstep(progress - aa, progress + aa, radius)) * step(0.000001, progress);
                float front = (1.0 - smoothstep(0.006, 0.020 + aa, abs(radius - progress))) * step(0.000001, progress) * (1.0 - step(0.99999, progress));
                float wave = pow(abs(0.5 + 0.5 * sin(radius * 28.0 - angle * 2.0 - _Motion2.x * 2.6)), 8.0);
                float flow = wave * (0.35 + 0.65 * filled) * (0.018 * _EffectDetail);
                float alpha = (0.115 + 0.19 * filled + 0.12 * halo + flow + 0.20 * front + 0.54 * edge) * coverage * opacity;
                float3 color = _EffectColor.rgb * (0.65 + 0.20 * filled);
                color = lerp(color, edgeColor, saturate(0.30 * halo + 0.75 * edge + 0.44 * front));
                color = lerp(color, float3(0.055, 0.018, 0.023), 0.22 * (1.0 - edge) * halo);
                color = lerp(color, lerp(edgeColor, float3(1.0, 1.0, 1.0), 0.35), flash * edge);
                alpha = min(1.0, alpha + flash * edge * 0.18 * coverage * opacity);
                clip(alpha - 0.001);
                return float4(color, alpha);
            }
            ENDHLSL
        }
    }
}
