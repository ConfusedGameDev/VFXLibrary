Shader "ConfusedGameDev/Vfx/DarkchainDetonation AfterSmoke"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+3" }

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

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 smoke : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 offset : TEXCOORD1;
                float seed : TEXCOORD2;
                float age : TEXCOORD3;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float t = _EffectTime;
                if (t < 3.710000 || t >= 5.150000)
                {
                    return output;
                }

                float4 smoke = input.smoke;
                float age = t - DC_burst;
                output.age = age;
                output.seed = smoke.z;
                output.uv = input.uv;
                float q = saturate(age / (DC_duration - DC_burst));
                float travel = 1.0 - pow(abs(1.0 - q), 3.0);
                float angle = smoke.x * TAU;
                float latitude = (smoke.y * 2.0 - 1.0) * 0.85;
                float ring = sqrt(1.0 - latitude * latitude);
                float3 direction = float3(cos(angle) * ring, latitude, sin(angle) * ring);
                float3 p = float3(0.0, DC_centerY, 0.0) + direction * lerp(1.9, 4.1, travel);
                p.y += q * (0.25 + smoke.w * 0.5);
                float3 positionVS = DcView(p);
                float3 center = CoreView();
                float span = lerp(1.6, 2.8, travel) * (0.75 + smoke.w * 0.45);
                float scale = ViewScale();
                float2 card = Spin(input.positionOS.xy, smoke.z * TAU + age * (smoke.w - 0.5) * 0.45);
                positionVS.xy += card * span * scale;
                output.offset = (positionVS.xy - center.xy * (positionVS.z / center.z)) / max(scale, 0.0001);
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float age = input.age;
                clip(age - 0.06);
                float2 p = input.uv * 2.0 - 1.0;
                float radial = length(p);
                float cloud = Fbm(p * 2.4 + float2(input.seed * 31.0 - age * 0.38, age * 0.28));
                float billow = 1.0 - smoothstep(0.28 + cloud * 0.24, 0.86 + cloud * 0.10, radial);
                float grain = 0.35 + 0.65 * smoothstep(0.20, 0.75, cloud);
                float life = smoothstep(0.06, 0.32, age) * pow(abs(1.0 - smoothstep(0.62, DC_duration - DC_burst, age)), 0.65);
                float centerGap = 0.10 + 0.90 * smoothstep(0.8, 2.3, length(input.offset));
                float alpha = billow * grain * life * centerGap * 0.34;
                clip(alpha - 0.003);
                float3 black = float3(0.00025, 0.00012, 0.00035);
                float3 red = float3(0.075, 0.0007, 0.004);
                float3 purple = float3(0.027, 0.0007, 0.065);
                float3 pigment = input.seed < 0.34 ? black : (input.seed < 0.67 ? red : purple);
                float3 color = lerp(black, pigment, smoothstep(0.18, 0.72, cloud));
                return float4(color, saturate(alpha));
            }
            ENDHLSL
        }
    }
}
