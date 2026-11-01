Shader "ConfusedGameDev/Vfx/DarkchainDetonation EnergySurface"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+5" }

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

            #define VFX_VARIANT 14
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "DarkchainDetonationCommon.hlsl"

            float PressureRadius(float t)
            {
                if (t < 0.08)
                {
                    float q = saturate(t / 0.08);
                    return lerp(DC_coreReleaseRadius, 4.2, 1.0 - pow(abs(1.0 - q), 3.0));
                }

                float q2 = saturate((t - 0.08) / (DC_pressureLife - 0.08));
                return 4.2 + 0.4 * (1.0 - (1.0 - q2) * (1.0 - q2));
            }

            float3 PressureRotate(float3 p, float4 q)
            {
                return p + 2.0 * cross(q.xyz, cross(q.xyz, p) + q.w * p);
            }

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 shape : TEXCOORD1;
                float4 turn : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 local : TEXCOORD1;
                float age : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float t = _EffectTime;
                if (t < 3.650000 || t >= 4.650000)
                {
                    return output;
                }

                float globalAge = t - DC_burst;
                float age = max(0.0, globalAge - input.shape.w);
                float radius = PressureRadius(age);
                float catchup = smoothstep(0.045, DC_pressureLife * 0.92, age);
                float inner = lerp(DC_coreReleaseRadius * 0.28, radius - 0.10, catchup);
                float u = input.uv.x;
                float v = input.uv.y;
                float angle = (u - 0.5) * input.shape.y + input.shape.x;
                float latitude = (v - 0.5) * input.shape.z;
                float r = lerp(inner, radius, v);
                float3 direction = float3(cos(angle) * cos(latitude), sin(latitude), sin(angle) * cos(latitude));
                float3 local = PressureRotate(direction * r, input.turn);
                output.uv = input.uv;
                output.local = local;
                output.age = globalAge - input.shape.w;

                output.positionCS = TransformWViewToHClip(DcView(local * 1.12 + float3(0.0, DC_centerY, 0.0)));
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float globalAge = _EffectTime - DC_burst;
                float t = input.age;
                clip(t);
                clip(DC_pressureLife - globalAge);
                float u = input.uv.x;
                float v = input.uv.y;
                float3 flowSpace = input.local * exp(-t * 1.3);
                float coarse = Noise3(flowSpace * 1.05);
                float grain = Noise3(flowSpace * 3.1);
                float erosion = smoothstep(0.30, DC_pressureLife, globalAge);
                float holes = smoothstep(0.31 + erosion * 0.48, 0.53 + erosion * 0.43, coarse * 0.8 + grain * 0.2);
                float sideGrain = Noise3(float3(u * 7.0, v * 0.8 - t * 3.0, 2.7));
                float sideCut = 0.08 + (1.0 - v) * 0.10 + (grain - 0.5) * 0.12;
                float ends = smoothstep(sideCut, sideCut + 0.13, u) * (1.0 - smoothstep(1.0 - sideCut - 0.16, 1.0 - sideCut, u));
                ends *= smoothstep(0.24, 0.55, sideGrain) * (1.0 - smoothstep(0.90 + (grain - 0.5) * 0.10, 1.0, v));
                float fade = pow(abs(1.0 - smoothstep(0.18, DC_pressureLife, globalAge)), 1.15);

                float surface = smoothstep(0.0, 0.16, v) * (1.0 - smoothstep(0.84, 1.0, v));
                float alpha = surface * 0.88 * ends * holes * fade;
                float3 color = float3(0.00018, 0.00008, 0.00024);

                clip(alpha - 0.003);
                return float4(color, saturate(alpha));
            }
            ENDHLSL
        }
    }
}
