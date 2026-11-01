Shader "ConfusedGameDev/Vfx/SacredRelicDescent Motes"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+9" }

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
                float fade : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                if (input.id.x >= _LayerCounts.z || _EffectTime >= 12.7)
                {
                    return output;
                }

                float4 seed = input.seed;
                output.uv = input.uv * 2.0 - 1.0;
                float a = seed.x * 6.283185;
                float3 p;
                float fade = 0.0;
                if (_EmitTime < 1.35)
                {
                    float t = saturate(_EffectTime / 1.35);
                    float r = (1.0 - t) * (0.6 + seed.y * 1.6);
                    p = float3(cos(a) * r, 0.08 + seed.z * 0.45 * (1.0 - t), sin(a) * r);
                    fade = sin(t * 3.14159) * 0.55;
                }
                else
                {
                    float birth = floor(_EmitTime * 0.6 + seed.y) / 0.6 - seed.y / 0.6;
                    float age = max(0.0, _EffectTime - birth);
                    float r = 0.2 + seed.z * 1.6;
                    p = float3(cos(a) * r, 0.15 + age * (0.45 + seed.w), sin(a) * r);
                    fade = sin(saturate(age / 1.35) * 3.14159) * 0.36;
                    if (_PulseAge >= 0.0)
                    {
                        float pt = _PulseAge;
                        float pr = _WaveRadius * (0.8 + seed.z * 0.15);
                        p = float3(cos(a) * pr, 0.08 + pt * (0.3 + seed.w * 0.6), sin(a) * pr);
                        fade = smoothstep(0.0, 0.12, pt) * (1.0 - smoothstep(0.5, 1.5, pt)) * 0.65;
                    }
                }

                output.fade = fade * (1.0 - smoothstep(11.5, 12.7, _EffectTime));
                float3 positionVS = RelicToView(p);
                positionVS.xy += input.positionOS.xy * float2(0.028 + seed.w * 0.032, 0.06 + seed.z * 0.06) * _EffectSize;
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float d = abs(input.uv.x) + abs(input.uv.y);
                float a = (1.0 - smoothstep(0.15, 1.0, d)) * input.fade * _Cancel;
                clip(a - 0.002);
                return float4(lerp(_EffectColor.rgb, float3(1.0, 1.0, 1.0), 0.6), saturate(a));
            }
            ENDHLSL
        }
    }
}
