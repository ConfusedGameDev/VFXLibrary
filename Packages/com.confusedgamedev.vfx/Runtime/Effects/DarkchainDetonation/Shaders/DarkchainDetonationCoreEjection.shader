Shader "ConfusedGameDev/Vfx/DarkchainDetonation CoreEjection"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+6" }

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
                float4 direction : TEXCOORD1;
                float4 seed : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 seed : TEXCOORD1;
                float age : TEXCOORD2;
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

                float age = (t - DC_burst) / DC_ejectionLife - input.seed.z;
                float q = max(age, 0.0);
                float u = input.uv.x;
                float3 axis = input.direction.xyz;
                float tip = 1.0 + input.direction.w * (1.0 - exp(-q * 34.0));
                float root = tip * smoothstep(0.15, 1.0, q);
                float r = lerp(root, tip, u);
                float3 positionVS = DcView(axis * r + float3(0.0, DC_centerY, 0.0));
                float3 velocity = SourceDirToView(axis);
                float projectedLength = length(velocity.xy);
                float2 across = projectedLength > 0.001 ? float2(-velocity.y, velocity.x) / projectedLength : float2(1.0, 0.0);
                float envelope = 0.28 + 0.72 * pow(max(0.0, sin(u * 3.14159265)), 0.65);
                float width = input.seed.y * envelope * (1.0 - 0.55 * smoothstep(0.04, 1.0, q));
                positionVS.xy += across * (input.uv.y - 0.5) * width * 4.0 * ViewScale();
                output.uv = input.uv;
                output.seed = input.seed;
                output.age = age;
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float age = (_EffectTime - DC_burst) / DC_ejectionLife;
                float t = input.age;
                clip(t);
                clip(1.0 - age);
                float u = input.uv.x;
                float v = (input.uv.y - 0.5) * 2.0;
                float grain = Noise3(float3(u * 6.0 - t * 18.0, v * 2.0, input.seed.x * 17.0));
                float width = 0.14 + 0.12 * grain;
                float filament = 1.0 - smoothstep(width * 0.3, width, abs(v));
                float glow = exp(-v * v * 9.0) * 0.35 + exp(-v * v * 4.0) * 0.35 * (1.0 - smoothstep(0.15, 0.65, u));
                float ends = smoothstep(0.0, 0.05, u) * (1.0 - smoothstep(0.80, 1.0, u));
                float cut = smoothstep(0.45, 1.0, age) * 0.65;
                float breaks = smoothstep(0.13 + cut, 0.36 + cut, grain);
                float fade = pow(abs(1.0 - saturate(age)), 2.0);
                float heat = 1.0 - smoothstep(0.025, 0.095, age);
                float3 energy = lerp(_EffectColor.rgb, float3(1.0, 0.001, 0.055), input.seed.x);
                float3 color = lerp(energy * 2.4, float3(1.0, 0.55, 0.76) * 3.0, filament * heat * (1.0 - u) * (1.0 - u));

                // Only the trailing third sheds sparks. Fixed seeds, so they never jitter.
                float separate = smoothstep(0.18, 0.45, age);
                float sparks = 0.0;
                for (int j = 0; j < 4; j++)
                {
                    float seed = Hash(float2(input.seed.x * 53.0, j + 11.0));
                    float scatter = Hash(float2(input.seed.x * 71.0, j + 29.0));
                    float sizeSeed = Hash(float2(input.seed.x * 97.0, j + 47.0));
                    float released = max(0.0, age - (0.18 + sizeSeed * 0.09));
                    float drift = 1.0 - exp(-released * (3.0 + scatter * 3.0));
                    float center = 0.045 + seed * 0.19 + drift * (scatter - 0.4) * 0.09;
                    float lateral = (scatter * 2.0 - 1.0) * 0.66 * drift;
                    float halfLength = lerp(0.038, 0.008 + 0.017 * sizeSeed, separate);
                    float halfWidth = 0.075 + sizeSeed * 0.13;
                    float2 spark = float2((u - center) / halfLength, (v - lateral) / halfWidth);
                    float solid = 1.0 - smoothstep(0.15, 1.0, length(spark));
                    float halo = exp(-dot(spark, spark) * 0.85) * 0.55;
                    sparks += (solid + halo) * (0.65 + sizeSeed * 0.55) * smoothstep(0.0, 0.055, released);
                }

                float lineMask = (filament + glow) * breaks;
                float tailOnly = 1.0 - smoothstep(0.27, 0.42, u);
                float alpha = lerp(lineMask, sparks, separate * tailOnly) * ends * fade * input.seed.w;
                clip(alpha - 0.003);
                return float4(color, saturate(alpha));
            }
            ENDHLSL
        }
    }
}
