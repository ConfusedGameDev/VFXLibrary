Shader "ConfusedGameDev/Vfx/DarkchainDetonation GroundSmoke"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+2" }

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

            // Head and trail read the same path: ground first, central lift last.
            float3 SmokePoint(float age, float3 a, float3 b, float3 c)
            {
                float t = saturate(age);
                float ground = saturate(t / 0.60);
                float p = ground * ground * (3.0 - 2.0 * ground);
                float q = 1.0 - p;
                float3 result = q * q * q * a + 3.0 * q * q * p * b + 3.0 * q * p * p * c + p * p * p * float3(0.0, DC_centerY, 0.0);
                result.y = lerp(a.y, DC_centerY, smoothstep(0.60, 1.0, t));
                return result;
            }

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 route0 : TEXCOORD1;
                float4 route1 : TEXCOORD2;
                float4 route2 : TEXCOORD3;
                float4 timing : TEXCOORD4;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 offset : TEXCOORD1;
                float fade : TEXCOORD2;
                float seed : TEXCOORD3;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float t = _EffectTime;
                if (t < 0.000000 || t >= 4.406816)
                {
                    return output;
                }

                float4 timing = input.timing;
                float clock = t * 0.325;
                float elapsed = clock - timing.x;
                float progress = saturate(elapsed / timing.z);
                float3 center = SmokePoint(progress, input.route0.xyz, input.route1.xyz, input.route2.xyz);
                float absorb = 1.0 - smoothstep(0.86, 1.0, progress);
                float width = (2.145 + timing.w * 0.91) * (0.65 + 0.35 * sin(progress * 3.14159)) * lerp(0.2, 1.0, absorb);
                output.fade = step(0.0, elapsed) * smoothstep(0.0, 0.13, progress) * absorb * (1.0 - smoothstep(DC_burst, DC_burst + 0.6, t));
                float3 positionVS = DcView(center);
                float3 core = CoreView();
                float scale = ViewScale();
                float2 card = Spin(input.positionOS.xy * width, timing.w * 6.28318 + clock * 0.32);
                output.offset = (positionVS.xy - core.xy) / max(scale, 0.001) + card;
                positionVS.xy += card * scale;
                output.positionCS = TransformWViewToHClip(positionVS);
                output.uv = input.uv;
                output.seed = timing.w;
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 q = input.uv * 2.0 - 1.0;
                float cloudNoise = Fbm(q * 2.2 + float2(input.seed * 17.0, -_EffectTime * 0.48));
                float soft = 1.0 - smoothstep(0.30, 1.0, length(q) + 0.14 * (cloudNoise - 0.5));
                soft *= 1.0 - smoothstep(0.88, 1.0, max(abs(q.x), abs(q.y)));
                float cloud = lerp(0.68, 1.0, smoothstep(0.18, 0.72, cloudNoise) * saturate(_EffectDetail));
                float clearCore = 0.24 + 0.76 * smoothstep(0.35, 1.25, length(input.offset));
                float alpha = soft * cloud * input.fade * clearCore * 0.40;
                clip(alpha - 0.002);
                float edge = smoothstep(0.10, 0.78, 1.0 - soft);
                float redBlend = smoothstep(0.28, 0.72, 0.5 + 0.4 * sin(q.x * 1.7 + q.y * 0.7 + input.seed * 6.28318) + 0.1 * (cloudNoise - 0.5));
                float3 edgePigment = lerp(float3(0.018, 0.0005, 0.030), float3(0.030, 0.0004, 0.003), redBlend);
                return float4(edgePigment * edge, saturate(alpha));
            }
            ENDHLSL
        }
    }
}
