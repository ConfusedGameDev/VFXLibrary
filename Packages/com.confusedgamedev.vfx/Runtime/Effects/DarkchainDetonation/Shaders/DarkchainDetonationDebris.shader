Shader "ConfusedGameDev/Vfx/DarkchainDetonation Debris"
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
                if (t < 3.650000 || t >= 5.000000)
                {
                    return output;
                }

                if (input.id.x >= _LayerCounts.y)
                {
                    return output;
                }

                float4 seed = input.seed;
                output.uv = input.uv;
                output.seed = seed.z;
                float b = max(0.0, t - DC_burst);
                float radius = DC_releaseRadius + (2.6 + seed.x * 0.4) * (1.0 - exp(-b * 3.2));
                float3 direction = normalize(float3(cos(seed.y * TAU), seed.w * 1.7 - 0.85, sin(seed.y * TAU)));
                float3 p = float3(0.0, DC_centerY, 0.0) + direction * radius;
                p.y -= b * b * 0.45;
                output.alpha = smoothstep(0.0, 0.035, b) * (1.0 - smoothstep(0.35, 1.15, b));
                output.hot = (1.0 - smoothstep(0.05, 0.65, b)) * 0.85;
                float3 positionVS = DcView(p);
                float3 velocity = direction * (2.6 + seed.x * 0.4) * 3.2 * exp(-b * 3.2) + float3(0.0, -b * 0.9, 0.0);
                float2 heading = Heading(SourceDirToView(velocity * _EffectSize), positionVS);
                float2 side = float2(-heading.y, heading.x);
                positionVS.xy += (side * input.positionOS.x * 0.7 + heading * input.positionOS.y * 1.8 * (0.9 + 0.3 * seed.x)) * (0.06 + seed.z * 0.15) * ViewScale();
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 p = input.uv * 2.0 - 1.0;
                float shape = abs(p.x) + abs(p.y);
                float core = 1.0 - smoothstep(0.68, 0.76, shape);
                float halo = exp(-shape * shape * 2.1) * (1.0 - smoothstep(1.55, 1.9, shape));
                float alpha = max(core, halo * 0.90) * input.alpha;
                clip(alpha - 0.003);
                float3 corona = lerp(_EffectColor.rgb, float3(1.0, 0.002, 0.035), step(0.5, input.seed));
                float3 color = lerp(corona * (1.35 + input.hot * 0.30), float3(0.00010, 0.00006, 0.00016), core);
                return float4(color, saturate(alpha));
            }
            ENDHLSL
        }
    }
}
