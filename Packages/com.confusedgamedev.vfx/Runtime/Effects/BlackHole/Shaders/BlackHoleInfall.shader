Shader "ConfusedGameDev/Vfx/BlackHole Infall"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+4" }

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

            #define VFX_VARIANT 9
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "BlackHoleCommon.hlsl"

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
                float4 screen : TEXCOORD2;
                float4 centerScreen : TEXCOORD3;
                float2 radius : TEXCOORD4;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            // Keeps the lensed arch in front of the hole, and blends to the disk's rim when seen from above.
            float3 BhParticlePath(float age, float4 seed, float3 right, float3 toward, float overhead)
            {
                float a = age * 6.283185;
                float r = lerp(2.65 + seed.y * 0.30, 0.38, smoothstep(0.48, 1.0, age));
                float rear = max(0.0, sin(a));
                float hemisphere = seed.z < 0.5 ? -1.0 : 1.0;
                float lift = pow(abs(rear), 1.35) * r * 0.52 * hemisphere;
                float depth = -sin(a) * r * lerp(1.0, 0.18, smoothstep(0.0, 0.35, rear));
                float3 arch = right * (-cos(a) * r * lerp(1.0, 0.72, smoothstep(0.0, 0.75, rear))) + toward * depth + float3(0.0, lift + (seed.z - 0.5) * 0.07 * (1.0 - age), 0.0);
                float rimRadius = 2.45 + seed.y * 0.15;
                float3 rim = right * (-cos(a) * rimRadius) + toward * (-sin(a) * rimRadius) + float3(0.0, (seed.z - 0.5) * 0.025, 0.0);
                return lerp(arch, rim, overhead);
            }

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                if (input.id.x >= _ParticleCount)
                {
                    return output;
                }

                float4 seed = input.seed;
                float age = frac(seed.x + _EffectTime * (0.11 + seed.w * 0.04));
                float scale = _EffectSize * max(0.0001, BhGrowth());
                float3 localEye = ToUnity(TransformWorldToObject(_WorldSpaceCameraPos));
                float3 viewOffset = localEye - BhCenter();
                float overhead = smoothstep(0.40, 0.92, abs(viewOffset.y) / max(length(viewOffset), 0.0001));

                // The camera's right axis, flat on the disk. It stays defined directly above the centre.
                float3 right = ToUnity(TransformWorldToObjectDir(UNITY_MATRIX_I_V[0].xyz, false));
                right.y = 0.0;
                right = length(right) > 0.0001 ? normalize(right) : float3(1.0, 0.0, 0.0);
                float3 toward = float3(-right.z, 0.0, right.x);

                float3 q = BhParticlePath(age, seed, right, toward, overhead);
                float3 tangent = BhParticlePath(min(0.9999, age + 0.001), seed, right, toward, overhead) - BhParticlePath(max(0.0, age - 0.001), seed, right, toward, overhead);
                float3 positionVS = SourceToView(BhCenter() + q * scale);
                float2 along = normalize(SourceDirToView(tangent).xy + float2(0.00001, 0.0));
                float2 local = input.positionOS.xy;
                positionVS.xy += (along * local.x * (0.035 + 0.125 * seed.w) + float2(-along.y, along.x) * local.y * 0.007) * scale * RootScale();

                output.alpha = smoothstep(0.0, 0.07, age) * (1.0 - smoothstep(0.94, 1.0, age)) * BhFade();
                output.positionCS = TransformWViewToHClip(positionVS);
                output.screen = ComputeScreenPos(output.positionCS);
                float3 centerVS = SourceToView(BhCenter());
                output.centerScreen = ComputeScreenPos(TransformWViewToHClip(centerVS));
                output.radius = BhScreenRadius(centerVS, scale);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 q = input.uv * 2.0 - 1.0;
                float glow = exp(-dot(q, q) * 5.0) * (1.0 - smoothstep(0.5, 1.0, length(q)));
                float2 screen = input.screen.xy / input.screen.w;
                float2 center = input.centerScreen.xy / input.centerScreen.w;
                float coreRadius = length((screen - center) / max(abs(input.radius), float2(0.00001, 0.00001)));
                float alpha = min(1.0, glow * 2.0) * input.alpha * smoothstep(0.285, 0.31, coreRadius);
                clip(alpha - 0.002);
                return float4(float3(1.6, 1.6, 1.6) * _EffectDetail, alpha);
            }
            ENDHLSL
        }
    }
}
