Shader "ConfusedGameDev/Vfx/SoulSiphon Body"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+1" }

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

            #define VFX_VARIANT 5
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBeam.hlsl"
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBeamUtility.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 data : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS : TEXCOORD0;
                float3 local : TEXCOORD1;
                float alpha : TEXCOORD2;
                float tone : TEXCOORD3;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float3 p = input.positionOS;
                float4 data = input.data;
                float t = _EffectTime;
                float stopTime = StopTime();
                float travel = 0.60;
                float a = data.y;
                float alpha;

                if (data.z < 0.5)
                {
                    float f = (p.x + 2.4) / 4.8;
                    float envelope = sin(f * 3.14159);
                    p.y += sin(f * 3.0 + a) * 0.34 * envelope;
                    p.z += cos(f * 3.0 + a) * 0.34 * envelope;
                    float front = smoothstep(-0.04, 0.06, t / 0.35 - (1.0 - f));
                    float stoppedFor = max(0.0, t - stopTime);
                    float drain = smoothstep(-0.05, 0.08, 1.0 - f - stoppedFor / travel);
                    float end = stopTime < 0.0 ? 1.0 : lerp(1.0, drain, smoothstep(0.0, 0.08, stoppedFor));
                    alpha = front * end * Grow() * FadeEnd() * 0.28;
                }
                else if (data.z > 2.5)
                {
                    float center = data.z > 3.5 ? 2.4 : -2.4;
                    p.x = center + (p.x - center) * _EffectSize / _Stretch;
                    p.yz /= _EffectSize;
                    alpha = Grow() * FadeEnd() * (1.0 - smoothstep(0.35, 1.0, _LifeEnd)) * 0.65;
                }
                else
                {
                    float index = floor(data.x * 9.0 + 0.5);
                    float offset = _Quantity == 9.0 ? data.x : index / _Quantity;
                    float cycle = t / travel + offset;
                    float phase = frac(cycle);
                    float birth = (floor(cycle) - offset) * travel;
                    float f = 1.0 - phase;
                    float envelope = sin(phase * 3.14159);
                    float live = step(0.0, birth) * (stopTime < 0.0 ? 1.0 : 1.0 - step(stopTime + 0.00001, birth));
                    p.x = p.x * _EffectSize / _Stretch + (f - 0.5) * 4.8;
                    p.y += sin(f * 3.0 + a) * 0.34 * envelope;
                    p.z += cos(f * 3.0 + a) * 0.34 * envelope;
                    alpha = live * smoothstep(0.0, 0.08, phase) * (1.0 - smoothstep(0.82, 1.0, phase)) * FadeEnd() * step(index + 0.5, _Quantity);
                }

                p.yz *= _EffectSize;
                output.alpha = alpha;
                output.tone = data.w;
                output.local = p;
                output.normalWS = TransformObjectToWorldNormal(ToUnity(input.normalOS));
                output.positionCS = TransformObjectToHClip(ToUnity(p));
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                clip(input.alpha - 0.003);
                float3 color = LitColor(input.normalWS, input.tone);
                if (input.tone > 0.5)
                {
                    color = lerp(_EffectColor.rgb * 0.7, float3(0.86, 1.0, 0.93), 0.62) * (0.92 + 0.08 * sin((input.local.x * 28.0 + input.local.y * 19.0) * _EffectDetail));
                }

                return float4(color, saturate(input.alpha));
            }
            ENDHLSL
        }
    }
}
