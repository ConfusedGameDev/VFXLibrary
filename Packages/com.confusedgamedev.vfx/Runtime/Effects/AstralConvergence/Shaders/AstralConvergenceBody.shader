Shader "ConfusedGameDev/Vfx/AstralConvergence Body"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+2" }

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

            #define VFX_VARIANT 7
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
                float4 extra : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float fade : TEXCOORD1;
                float phase : TEXCOORD2;
                float part : TEXCOORD3;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                float part = input.extra.x;
                float phase = input.extra.y;
                output.part = part;
                output.phase = phase;
                if (input.extra.z >= _Quantity)
                {
                    return output;
                }

                float2 uv = input.uv;
                float3 p = input.positionOS;
                float3 n = input.normalOS;
                float life = saturate(_EffectTime / 3.4);
                float alive = smoothstep(0.0, 0.025, life) * (1.0 - smoothstep(0.70, 1.0, life));
                output.fade = alive;

                float t = _EffectTime;
                if (part < 1.5)
                {
                    // Orbits and the constellation gather, spinning faster as they close.
                    float gather = 1.0 - smoothstep(0.0, 0.36, life) * 0.82;
                    p *= gather;
                    p.xz = Spin(p.xz, t * (1.0 + life * 3.0));
                    output.fade *= 1.0 - smoothstep(0.35, 0.50, life);
                }
                else
                {
                    // One beam of the burst.
                    float start = 0.31 + frac(phase * 0.37) * 0.065;
                    float age = max(0.0, life - start);
                    float release = smoothstep(0.0, 0.08, age);
                    float a = phase * 4.8;
                    float3 direction = normalize(float3(cos(a), sin(phase * 4.0) * 0.8, sin(a)));
                    if (abs(_Quantity - 10.0) > 0.1)
                    {
                        float unit = input.extra.z;
                        float y = _Quantity < 1.5 ? 0.0 : ((unit + 0.5) / _Quantity * 2.0 - 1.0) * 0.8;
                        float azimuth = unit * 2.399963;
                        float radial = sqrt(1.0 - y * y);
                        direction = float3(cos(azimuth) * radial, y, sin(azimuth) * radial);
                    }

                    float3 side = normalize(cross(direction, float3(0, 1, 0)));
                    float3 up = cross(direction, side);
                    float head = exp(-pow(abs((uv.x - 0.86) * 13.0), 2.0));
                    float radius = (head * 0.052 + uv.x * 0.006) * (1.0 - smoothstep(0.12, 0.30, age));
                    p = direction * (age * 8.0 + uv.x * (1.30 - age * 2.8)) + (side * cos(uv.y * VFX_PI * 2.0) + up * sin(uv.y * VFX_PI * 2.0)) * radius;
                    output.fade *= release * (1.0 - smoothstep(0.15, 0.34, age));
                }

                p.y = -1.3 + (p.y + 1.3) * _EffectSize;
                p.xz *= _EffectSize;
                output.positionCS = TransformObjectToHClip(ToUnity(p));
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                bool beam = input.part > 1.5;
                float shade = beam ? lerp(0.44, 0.98, smoothstep(0.72, 0.84, input.uv.x)) : 0.75;
                float alpha = input.fade * (beam ? pow(abs(input.uv.x), 1.4) * 0.95 : 1.0);
                clip(alpha - 0.003);
                return float4(ToonShade(_EffectColor.rgb, shade), alpha);
            }
            ENDHLSL
        }
    }
}
