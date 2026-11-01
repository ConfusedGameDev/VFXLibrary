Shader "ConfusedGameDev/Vfx/DarkchainDetonation OrbBody"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" "Queue" = "Geometry" }

        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
            Blend One Zero
            ZWrite On
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
                if (t < 1.150000 || t >= 3.650000)
                {
                    return output;
                }

                float3 position = input.positionOS;
                output.local = position;
                float warp = 1.0 + DC_orbWarp * sin(position.y * 7.0 + _Flow * 2.0) * sin(position.x * 5.0 - position.z * 4.0);
                float3 p = position * _OrbRadius * warp + float3(0.0, DC_centerY, 0.0);
                float3 positionVS = DcView(p);
                output.normalVS = SourceDirToView(input.normalOS);
                output.viewDir = -positionVS;
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                clip(_OrbAlive - 0.003);
                float3 p = normalize(input.local);
                float energyTime = max(0.0, _EffectTime - DC_orbStart);
                p.xz = Spin(p.xz, -energyTime * 0.90);
                p.yz = Spin(p.yz, sin(energyTime * 1.4) * 0.28);
                float3 churn = float3(sin(p.y * 3.1 + energyTime * 2.1), sin(p.z * 2.7 - energyTime * 1.7), cos(p.x * 3.4 + energyTime * 1.9)) * 0.24;
                float field = Noise3(p * 2.35 + churn + float3(0.4 + energyTime * 0.16, energyTime * 0.32, 1.7 - energyTime * 0.21));
                float fine = Noise3(p * 4.3 - churn * 0.7 + float3(6.2, 1.3 + energyTime * 0.23, -energyTime * 0.28));
                field += (fine - 0.5) * 0.07;
                float aa = max(fwidth(field), 0.0015);
                float boundary = abs(field - 0.515);
                float membrane = smoothstep(0.36, 0.405, field) * (1.0 - smoothstep(0.505, 0.52, field));
                float edge = 1.0 - smoothstep(0.003, 0.009 + aa, boundary);
                float diffusion = exp(-boundary * 38.0);
                float pulse = 0.72 + _Beat * 0.38;
                float hue = smoothstep(-0.7, 0.7, p.x * 0.7 + p.y * 0.4 + sin(_Flow * 0.3) * 0.25);
                float3 energy = lerp(float3(1.0, 0.002, 0.035), _EffectColor.rgb, hue);
                float3 color = float3(0.0008, 0.0003, 0.002) + _EffectColor.rgb * 0.006;
                color += energy * (membrane * 0.19 + diffusion * 0.34) * pulse;
                color += energy * 1.35 * edge * (1.05 + _Beat * 0.55);
                float folded = dot(p, float3(0.7, 0.45, 0.4)) + 0.21 * abs(p.y * 3.0 - 0.4) - 0.19 * abs(p.z * 4.0 + 0.7) - 0.12;
                float fissure = (1.0 - smoothstep(0.002, 0.006 + fwidth(folded), abs(folded))) * smoothstep(0.56, 0.68, fine);
                color += lerp(energy, float3(1.0, 0.30, 0.38), 0.15) * fissure * (0.10 + _Beat * 0.4) * min(_EffectDetail, 1.25);

                // The travelling outline stays on the opaque core.
                float3 surface = normalize(input.local);
                float facing = abs(dot(normalize(input.normalVS), normalize(input.viewDir)));
                float outlineWave = sin(dot(surface, float3(5.0, 7.0, -4.0)) - energyTime * 6.0) + 0.35 * sin(dot(surface, float3(-8.0, 3.0, 6.0)) + energyTime * 9.0);
                float width = clamp(0.52 + outlineWave * 0.475, 0.20, 0.78);
                float band = 1.0 - smoothstep(width - 0.09, width + 0.035, facing);
                color = lerp(color, float3(0.00010, 0.00006, 0.00016), band);
                clip(_OrbAlive - Hash(input.positionCS.xy));
                return float4(color, 1.0);
            }

            float4 FragDepth(Varyings input) : SV_Target
            {
                Frag(input);
                return input.positionCS.z;
            }
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }
            ColorMask R
            ZWrite On
            Cull Front

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment FragDepth

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
                if (t < 1.150000 || t >= 3.650000)
                {
                    return output;
                }

                float3 position = input.positionOS;
                output.local = position;
                float warp = 1.0 + DC_orbWarp * sin(position.y * 7.0 + _Flow * 2.0) * sin(position.x * 5.0 - position.z * 4.0);
                float3 p = position * _OrbRadius * warp + float3(0.0, DC_centerY, 0.0);
                float3 positionVS = DcView(p);
                output.normalVS = SourceDirToView(input.normalOS);
                output.viewDir = -positionVS;
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                clip(_OrbAlive - 0.003);
                float3 p = normalize(input.local);
                float energyTime = max(0.0, _EffectTime - DC_orbStart);
                p.xz = Spin(p.xz, -energyTime * 0.90);
                p.yz = Spin(p.yz, sin(energyTime * 1.4) * 0.28);
                float3 churn = float3(sin(p.y * 3.1 + energyTime * 2.1), sin(p.z * 2.7 - energyTime * 1.7), cos(p.x * 3.4 + energyTime * 1.9)) * 0.24;
                float field = Noise3(p * 2.35 + churn + float3(0.4 + energyTime * 0.16, energyTime * 0.32, 1.7 - energyTime * 0.21));
                float fine = Noise3(p * 4.3 - churn * 0.7 + float3(6.2, 1.3 + energyTime * 0.23, -energyTime * 0.28));
                field += (fine - 0.5) * 0.07;
                float aa = max(fwidth(field), 0.0015);
                float boundary = abs(field - 0.515);
                float membrane = smoothstep(0.36, 0.405, field) * (1.0 - smoothstep(0.505, 0.52, field));
                float edge = 1.0 - smoothstep(0.003, 0.009 + aa, boundary);
                float diffusion = exp(-boundary * 38.0);
                float pulse = 0.72 + _Beat * 0.38;
                float hue = smoothstep(-0.7, 0.7, p.x * 0.7 + p.y * 0.4 + sin(_Flow * 0.3) * 0.25);
                float3 energy = lerp(float3(1.0, 0.002, 0.035), _EffectColor.rgb, hue);
                float3 color = float3(0.0008, 0.0003, 0.002) + _EffectColor.rgb * 0.006;
                color += energy * (membrane * 0.19 + diffusion * 0.34) * pulse;
                color += energy * 1.35 * edge * (1.05 + _Beat * 0.55);
                float folded = dot(p, float3(0.7, 0.45, 0.4)) + 0.21 * abs(p.y * 3.0 - 0.4) - 0.19 * abs(p.z * 4.0 + 0.7) - 0.12;
                float fissure = (1.0 - smoothstep(0.002, 0.006 + fwidth(folded), abs(folded))) * smoothstep(0.56, 0.68, fine);
                color += lerp(energy, float3(1.0, 0.30, 0.38), 0.15) * fissure * (0.10 + _Beat * 0.4) * min(_EffectDetail, 1.25);

                // The travelling outline stays on the opaque core.
                float3 surface = normalize(input.local);
                float facing = abs(dot(normalize(input.normalVS), normalize(input.viewDir)));
                float outlineWave = sin(dot(surface, float3(5.0, 7.0, -4.0)) - energyTime * 6.0) + 0.35 * sin(dot(surface, float3(-8.0, 3.0, 6.0)) + energyTime * 9.0);
                float width = clamp(0.52 + outlineWave * 0.475, 0.20, 0.78);
                float band = 1.0 - smoothstep(width - 0.09, width + 0.035, facing);
                color = lerp(color, float3(0.00010, 0.00006, 0.00016), band);
                clip(_OrbAlive - Hash(input.positionCS.xy));
                return float4(color, 1.0);
            }

            float4 FragDepth(Varyings input) : SV_Target
            {
                Frag(input);
                return input.positionCS.z;
            }
            ENDHLSL
        }
    }
}
