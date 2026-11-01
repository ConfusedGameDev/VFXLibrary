Shader "ConfusedGameDev/Vfx/DarkchainDetonation InwardParticles"
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
                float alpha : TEXCOORD1;
                float seed : TEXCOORD2;
                float hot : TEXCOORD3;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float t = _EffectTime;
                if (t < 1.150000 || t >= 3.650000)
                {
                    return output;
                }

                if (input.id.x >= _LayerCounts.x)
                {
                    return output;
                }

                float4 seed = input.seed;
                output.uv = input.uv;
                output.seed = seed.z;
                float q = frac(max(0.0, t - DC_orbStart) * 0.55 + Charge() * Charge() * 0.35 + seed.x);
                float a = seed.y * TAU + (1.0 - q) * 2.4;
                float r = lerp(3.5, 0.08, pow(abs(q), 0.8));
                float3 p = float3(cos(a) * r, DC_centerY + (seed.w - 0.5) * 3.7 * (1.0 - q), sin(a) * r);
                output.hot = (0.2 + Charge() * 0.5) * pow(abs(q), 3.0);
                output.alpha = smoothstep(DC_orbStart, 1.4, t) * smoothstep(0.0, 0.12, q) * (1.0 - smoothstep(0.88, 1.0, q)) * 0.8;
                float3 positionVS = DcView(p);
                float size = (0.035 + seed.z * 0.065) * 2.2;
                float dr = -3.42 * 0.8 * pow(max(q, 0.001), -0.2);
                float3 velocity = float3(cos(a) * dr + sin(a) * r * 2.4, -(seed.w - 0.5) * 3.7, sin(a) * dr - cos(a) * r * 2.4);
                float2 heading = Heading(SourceDirToView(velocity * _EffectSize), positionVS);
                float2 side = float2(-heading.y, heading.x);
                positionVS.xy += (side * input.positionOS.x * 0.6 + heading * input.positionOS.y * 1.6) * size * ViewScale();
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 p = (input.uv * 2.0 - 1.0) * 2.2;
                float shape = abs(p.x) + abs(p.y);
                float core = 1.0 - smoothstep(0.82, 1.0, shape);
                float halo = exp(-shape * shape * 0.52) * (1.0 - smoothstep(1.65, 2.15, shape));
                float alpha = max(core, halo * 0.98) * input.alpha;
                clip(alpha - 0.003);
                float3 corona = lerp(_EffectColor.rgb, float3(1.0, 0.002, 0.035), step(0.65, input.seed));
                float3 color = lerp(corona * (1.65 + input.hot * 0.45), float3(0.00010, 0.00006, 0.00016), core);
                return float4(color, saturate(alpha));
            }
            ENDHLSL
        }
    }
}
