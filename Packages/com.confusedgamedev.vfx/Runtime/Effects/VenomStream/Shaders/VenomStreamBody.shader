Shader "ConfusedGameDev/Vfx/VenomStream Body"
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

            #define VFX_VARIANT 6
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
                float3 q = p;
                float3 n = input.normalOS;
                float4 data = input.data;
                float t = _EffectTime;
                float stopTime = StopTime();
                float alpha;

                if (data.z < 0.5)
                {
                    float index = floor(data.y / 2.37 + 0.5);
                    float offset = _Quantity == 8.0 ? data.x : frac(data.x + index * (1.0 / _Quantity - 1.0 / 8.0));
                    float travel = 0.25;
                    float cycle = t / travel + offset;
                    float phase = frac(cycle);
                    float birth = (floor(cycle) - offset) * travel;
                    float live = step(0.0, birth) * (stopTime < 0.0 ? 1.0 : 1.0 - step(stopTime + 0.00001, birth));
                    float bulb = smoothstep(-1.0, 0.35, q.x);
                    float envelope = pow(max(0.0, sin(phase * 3.14159)), 0.28);
                    float radius = (0.075 + phase * 0.24) * (0.87 + 0.13 * sin(data.y)) * envelope;
                    float neck = 0.25 + 0.75 * bulb;
                    float irregular = 1.0 + 0.095 * sin(q.x * 5.0 + data.y + phase * 3.0);
                    float reach = min(0.43 + 0.07 * Rand(data.y), min(phase, 1.0 - phase) * 4.55);
                    p.x = -2.4 + phase * 4.8 + q.x * reach;
                    p.y = q.y * radius * neck * irregular + sin(phase * 5.0 + data.y) * 0.045 * envelope;
                    p.z = q.z * radius * neck * irregular + cos(phase * 6.0 + data.y) * 0.035 * envelope;
                    alpha = live * smoothstep(0.0, 0.045, phase) * (1.0 - smoothstep(0.95, 1.0, phase)) * FadeEnd() * step(index + 0.5, _Quantity);
                }
                else if (data.z > 1.5 && data.z < 2.5)
                {
                    float travel = 0.25;
                    float cycle = t / travel + data.x;
                    float phase = frac(cycle);
                    float birth = (floor(cycle) - data.x) * travel;
                    float live = step(0.0, birth) * (stopTime < 0.0 ? 1.0 : 1.0 - step(stopTime + 0.00001, birth));
                    p.x = -2.4 + phase * 4.8 + q.x * min(1.0, phase * 12.0) * min(1.0, (1.0 - phase) * 12.0);
                    float radial = (0.12 + phase * 0.38) * sin(phase * 3.14159);
                    p.y = q.y + cos(data.y) * radial - 0.10 * phase * phase;
                    p.z = q.z + sin(data.y) * radial;
                    alpha = live * smoothstep(0.02, 0.10, phase) * (1.0 - smoothstep(0.84, 1.0, phase)) * FadeEnd();
                }
                else if (data.z < 1.5)
                {
                    float period = 0.38;
                    float cycle = (t - 0.25) / period + data.x;
                    float phase = frac(cycle);
                    float source = (floor(cycle) - data.x) * period;
                    float live = step(0.0, source) * (stopTime < 0.0 ? 1.0 : 1.0 - step(stopTime + 0.00001, source));
                    float h = q.x;
                    float extend = Ease(phase / 0.40);
                    float retreat = smoothstep(0.43, 0.82, phase);
                    float reach = 0.59 + 0.16 * Rand(data.y);
                    float radial = 0.13 + reach * h * extend;
                    float width = 1.0 - retreat * 0.68;
                    float bow = 0.13 * sin(h * 3.14159) - 0.23 * h * h;
                    p.x = 2.30 + (bow + q.z) * _EffectSize / _Stretch;
                    p.y = cos(data.y) * radial - q.y * width * sin(data.y);
                    p.z = sin(data.y) * radial + q.y * width * cos(data.y);
                    n = normalize(float3(input.normalOS.z, input.normalOS.y * cos(data.y) - input.normalOS.x * sin(data.y), input.normalOS.y * sin(data.y) + input.normalOS.x * cos(data.y)));
                    float rootRetreat = smoothstep(-0.06, 0.06, h - retreat * 1.16);
                    alpha = live * smoothstep(0.0, 0.08, phase) * (1.0 - smoothstep(0.67, 0.83, phase)) * rootRetreat * (1.0 - smoothstep(0.78, 1.0, _LifeEnd));
                }
                else
                {
                    // A drop is born at the tongue tip, then moves on its own under gravity.
                    float period = 0.38;
                    float cycle = (t - 0.36) / period + data.x;
                    float phase = frac(cycle);
                    float age = phase * period;
                    float source = (floor(cycle) - data.x) * period;
                    float live = step(0.0, source) * (stopTime < 0.0 ? 1.0 : 1.0 - step(stopTime + 0.00001, source));
                    float reach = 0.59 + 0.16 * Rand(data.y);
                    float radial = 0.13 + reach + age * (0.90 + 0.20 * Rand(data.y + 1.0));
                    p.x = 2.07 + (q.x + age * 0.22) * _EffectSize / _Stretch;
                    p.y = q.y + cos(data.y) * radial + 0.20 * age - 6.0 * age * age;
                    p.z = q.z + sin(data.y) * radial;
                    alpha = live * smoothstep(0.0, 0.018, age) * (1.0 - smoothstep(0.20, 0.30, age)) * (1.0 - smoothstep(0.94, 1.0, _LifeEnd));
                }

                p.yz *= _EffectSize;
                output.alpha = alpha;
                output.tone = data.w;
                output.local = p;
                output.normalWS = TransformObjectToWorldNormal(ToUnity(n));
                output.positionCS = TransformObjectToHClip(ToUnity(p));
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                clip(input.alpha - 0.003);
                float3 color = LitColor(input.normalWS, input.tone);
                float streak = 0.5 + 0.5 * sin(input.local.x * (7.0 + _EffectDetail * 5.0) + input.local.y * 8.0 - _EffectTime * 8.0);
                color = lerp(color, lerp(_EffectColor.rgb, float3(0.93, 1.0, 0.35), 0.52), smoothstep(0.67, 0.86, streak) * 0.26);
                return float4(color, saturate(input.alpha));
            }
            ENDHLSL
        }
    }
}
