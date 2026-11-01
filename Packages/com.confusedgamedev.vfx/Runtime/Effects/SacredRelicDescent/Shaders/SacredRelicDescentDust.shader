Shader "ConfusedGameDev/Vfx/SacredRelicDescent Dust"
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
                float age : TEXCOORD1;
                float seedValue : TEXCOORD2;
                float fade : TEXCOORD3;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                if (input.id.x >= _LayerCounts.y || _ImpactAge < 0.0 || _ImpactAge >= 1.5)
                {
                    return output;
                }

                float4 seed = input.seed;
                output.uv = input.uv * 2.0 - 1.0;
                float age = max(0.0, _ImpactAge);
                float delay = 0.035 + seed.z * 0.09;
                float t = max(0.0, age - delay);
                float a = seed.x * 6.283185;
                float radius = 0.35 + (1.0 - exp(-t * 3.2)) * (2.4 + seed.y * 1.2);
                float3 p = float3(cos(a) * radius, 0.15 + sin(min(t / 1.5, 1.0) * 3.14159) * (0.25 + seed.w * 0.32), sin(a) * radius);
                output.age = t;
                output.seedValue = seed.y * 31.0;
                output.fade = smoothstep(delay, delay + 0.08, age) * (1.0 - smoothstep(0.5, 1.5, age));
                float grow = 0.3 + (1.0 - exp(-t * 5.0)) * (0.85 + seed.w * 0.55);
                float3 positionVS = RelicToView(p);
                positionVS.xy += input.positionOS.xy * float2(grow, grow * 0.6) * _EffectSize;
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 p = input.uv;
                float age = input.age;
                float2 q = Spin(p, age * 0.7);
                float n = RelicNoise(q * 3.0 + float2(input.seedValue, -age * 0.9)) * 0.65 + RelicNoise(q * 7.0 + input.seedValue + age * 0.5) * 0.35;
                float shape = 1.0 - smoothstep(0.32, 0.98, length(p) + (0.5 - n) * 0.35);
                float erosion = smoothstep(0.15 + age * 0.15, 0.6, n);
                float alpha = shape * erosion * input.fade * _Cancel * 0.43;
                clip(alpha - 0.002);
                float3 color = lerp(float3(0.17, 0.15, 0.12), float3(0.46, 0.40, 0.32), n * 0.65 + (p.y + 0.5) * 0.15);
                return float4(color, saturate(alpha));
            }
            ENDHLSL
        }
    }
}
