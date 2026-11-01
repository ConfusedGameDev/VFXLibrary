Shader "ConfusedGameDev/Vfx/DarkchainDetonation ReleasePlasma"
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
            Cull Front

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
                float3 normalOS : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 local : TEXCOORD0;
                float3 normalVS : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float t = _EffectTime;
                if (t < 3.650000 || t >= 3.790000)
                {
                    return output;
                }

                float b = max(0.0, t - DC_burst);
                float q = saturate(b / 0.055);
                float radius = lerp(DC_coreReleaseRadius * 0.92, 2.15, 1.0 - pow(abs(1.0 - q), 3.0));
                float3 n = normalize(input.positionOS);
                float grain = Noise3(n * 3.3 + float3(b * 9.0, 0.0, -b * 7.0));
                float lobes = sin(n.x * 8.0 + n.y * 3.0) * sin(n.z * 7.0 - n.y * 5.0);
                float3 local = n * radius * (0.88 + grain * 0.23 + lobes * 0.08);
                float3 positionVS = DcView(local * 1.14 + float3(0.0, DC_centerY, 0.0));
                output.local = local;
                output.normalVS = SourceDirToView(input.normalOS);
                output.viewDir = -positionVS;
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float t = _EffectTime - DC_burst;
                clip(t);
                clip(DC_plasmaLife - t);
                float3 flowSpace = input.local * (1.7 - t * 5.0);
                float coarse = Noise3(flowSpace);
                float grain = Noise3(flowSpace * 2.1 + float3(t * 12.0, 0.0, 0.0));
                float tear = smoothstep(0.035, DC_plasmaLife, t);
                float field = coarse * 0.75 + grain * 0.25;
                float coverage = 1.0 - smoothstep(field - 0.06, field + 0.06, tear);
                float fade = 1.0 - smoothstep(0.075, DC_plasmaLife, t);
                float facing = abs(dot(normalize(input.normalVS), normalize(input.viewDir)));
                float fissure = 1.0 - smoothstep(0.025, 0.11, abs(field - 0.52));
                float heat = 1.0 - smoothstep(0.015, 0.055, t);
                float rim = pow(abs(1.0 - facing), 0.65);
                float3 red = float3(0.95, 0.002, 0.045);
                float3 violet = _EffectColor.rgb * 1.35;
                float3 energy = lerp(float3(0.035, 0.0005, 0.085), red, smoothstep(0.04, 0.46, rim));
                energy = lerp(energy, violet, smoothstep(0.28, 0.60, rim));
                float3 color = energy * (0.65 + 0.55 * smoothstep(0.25, 0.75, field));
                color = lerp(color, float3(2.8, 1.1, 1.6), heat * pow(abs(facing), 10.0) * 0.85);
                color += energy * fissure * (1.0 - heat) * 0.45;
                float projectedRadius = sqrt(max(0.0, 1.0 - facing * facing)) * 1.14;
                float radialOpacity = smoothstep(0.55, 0.82, projectedRadius) * (1.0 - smoothstep(0.80, 1.08, projectedRadius));
                float corona = exp(-Sq((projectedRadius - 0.88) / 0.16)) * smoothstep(0.56, 0.74, projectedRadius) * (1.0 - smoothstep(0.92, 1.12, projectedRadius));
                float alpha = coverage * fade * (radialOpacity * 0.52 + corona * 0.22);
                color += lerp(red, violet, smoothstep(0.68, 0.90, projectedRadius)) * corona * 0.65;
                clip(alpha - 0.003);
                return float4(color, saturate(alpha));
            }
            ENDHLSL
        }
    }
}
