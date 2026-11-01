Shader "ConfusedGameDev/Vfx/BillowingAirburst Embers"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+4" }

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

            #define VFX_VARIANT 11
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "BillowingAirburstCommon.hlsl"

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
                float fade : TEXCOORD1;
                float part : TEXCOORD2;
                float isLong : TEXCOORD3;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            float3 EmberPath(float age, float isLong, float4 seed)
            {
                float launchAngle = seed.x * 6.283185 + _BurstOffset.x * 0.17;
                float launchY = seed.y * 1.82 - 0.91;
                float horizontal = sqrt(max(0.0, 1.0 - launchY * launchY));
                float3 launchDirection = float3(cos(launchAngle) * horizontal, launchY, sin(launchAngle) * horizontal);
                float outwardDistance = (1.0 - exp(-age * lerp(3.8, 2.5, isLong))) * lerp(2.7 + seed.z * 2.0, 5.15 + seed.w * 0.15, isLong);
                float gravityDrop = age * age * (1.1 + seed.w * 0.2);
                return launchDirection * (0.12 + outwardDistance) - float3(0.0, gravityDrop, 0.0);
            }

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float part = input.positionOS.z;
                float4 seed = input.seed;
                float isLong = step(0.90, seed.z);
                if (input.id.x >= _LayerCounts.x || _EffectTime <= 0.015 || _EffectTime >= 1.80 || (part < 0.5 && isLong < 0.5))
                {
                    return output;
                }

                float2 uv = input.uv;
                output.uv = uv;
                output.part = part;
                output.isLong = isLong;
                float age = max(0.0, _EffectTime - 0.015 - seed.w * 0.11);
                float life = lerp(0.55 + seed.w * 0.5, 1.38 + seed.w * 0.28, isLong);
                output.fade = smoothstep(0.0, 0.025, age) * (1.0 - smoothstep(life * 0.54, life, age));
                output.fade *= 0.88 + 0.12 * sin(age * (18.0 + seed.y * 15.0) + seed.x * 11.0);
                float sampleAge = age;
                if (part < 0.5)
                {
                    sampleAge = max(0.0, age - (1.0 - uv.x) * (0.48 + seed.w * 0.28));
                    output.fade *= smoothstep(0.0, 0.055, sampleAge) * isLong;
                }

                float3 positionVS = SourceToView(EmberPath(sampleAge, isLong, seed) * _EffectSize);
                float3 following = SourceToView(EmberPath(sampleAge + 0.008, isLong, seed) * _EffectSize);
                float scale = _EffectSize * RootScale();
                float2 projectedDelta = following.xy / max(-following.z, 0.0001) - positionVS.xy / max(-positionVS.z, 0.0001);
                float projectedSpeed = length(projectedDelta) * max(-positionVS.z, 0.0001) / max(0.008 * scale, 0.0001);
                float directionWeight = smoothstep(0.02, 0.20, projectedSpeed);
                float2 tangent = length(projectedDelta) > 0.000001 ? normalize(projectedDelta) : float2(1.0, 0.0);
                float2 side = float2(-tangent.y, tangent.x);
                if (part > 0.5)
                {
                    float diameter = 1.5 * lerp(0.105 + seed.w * 0.075, 0.36 + seed.w * 0.12, isLong);
                    float streak = 1.0 + (1.0 - isLong) * (1.0 - smoothstep(0.025, 0.22, age)) * 1.7 * directionWeight;
                    positionVS.xy += (tangent * input.positionOS.x * diameter * streak + side * input.positionOS.y * diameter) * scale;
                }
                else
                {
                    float width = 1.5 * (0.045 + seed.w * 0.035) * (0.25 + 0.75 * uv.x);
                    positionVS.xy += side * (uv.y - 0.5) * width * scale * directionWeight;
                }

                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float alpha;
                float3 color;
                if (input.part > 0.5)
                {
                    float r = length((input.uv - 0.5) * 2.0);
                    float core = exp(-r * r * 28.0);
                    float halo = exp(-r * r * 4.0) * (1.0 - smoothstep(0.65, 1.0, r));
                    alpha = (core * 0.98 + halo * 0.48) * input.fade;
                    color = _EffectColor.rgb * 1.5;
                }
                else
                {
                    if (input.isLong < 0.5)
                    {
                        discard;
                    }

                    float edge = abs(input.uv.y - 0.5) * 2.0;
                    alpha = exp(-edge * edge * 3.5) * smoothstep(0.0, 0.16, input.uv.x) * (0.35 + 0.50 * input.uv.x) * input.fade;
                    color = lerp(float3(0.30, 0.24, 0.18), _EffectColor.rgb, pow(abs(input.uv.x), 10.0));
                }

                clip(alpha - 0.003);
                return float4(color, saturate(alpha));
            }
            ENDHLSL
        }
    }
}
