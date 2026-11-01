Shader "ConfusedGameDev/Vfx/QuicksandSeal Body"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+2" }

        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite On
            Cull Off

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #define VFX_VARIANT 7
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxGround.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
                float4 data : TEXCOORD1;
                float2 id : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalVS : TEXCOORD1;
                float fade : TEXCOORD2;
                float mass : TEXCOORD3;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                float2 uv = input.uv;
                float phase = input.data.x;
                float bank = input.data.y;
                output.mass = 1.0;
                if (bank >= _Quantity)
                {
                    return output;
                }

                float cycle = frac(_EmitterTime * 0.24 + bank * 0.31);
                if (_LifeEnd > 0.0)
                {
                    cycle = min(0.999, cycle + _LifeEnd * 0.9);
                }

                float packet = bank < 2.5 ? step(2.5, phase) : step(5.5, phase);
                float side = pow(abs(sin(uv.x * VFX_PI)), 0.65);
                float local = saturate((cycle - 0.10 - uv.x * 0.25) * 2.4);
                float slide = smoothstep(0.02, 0.88, local);
                float build = smoothstep(0.0, 0.16, cycle);
                float angle = bank * VFX_PI * 2.0 / _Quantity + 0.32 + (uv.x - 0.5) * 1.55;
                if (_Quantity > 3.5)
                {
                    angle = bank * VFX_PI * 2.0 / _Quantity + 0.32 + (uv.x - 0.5) * 1.55 * 3.0 / _Quantity;
                }

                float crest = 0.82 - slide * 0.52;
                float radial = 0.12 + uv.y * 1.25;
                float profile = max(0.0, min(uv.y / max(0.08, crest), (1.0 - uv.y) / (1.0 - crest)));
                float scar = exp(-pow((uv.y - crest) * 6.0, 2.0)) * sin(slide * VFX_PI);
                float height = profile * side * (0.17 + build * 0.25) * (1.0 - scar * 0.85) * (1.0 - slide * 0.55);
                height += sin(uv.x * 19.0 + bank) * 0.025 * profile;

                output.fade = 1.0;
                if (packet > 0.5)
                {
                    radial = 0.18 + (1.0 - slide) * 0.66 + (uv.y - 0.5) * 0.28;
                    height = sin(uv.y * VFX_PI) * side * 0.20 * sin(slide * VFX_PI);
                    output.fade = sin(slide * VFX_PI);
                }

                float3 p = float3(cos(angle) * radial, 0.025 + height * smoothstep(0.0, 0.75, _LifeStart), sin(angle) * radial);
                float sink = smoothstep(0.04 + uv.y * 0.30, 0.86, _LifeEnd);
                p.xz *= 0.72 * (1.0 - sink * (1.0 - uv.y) * 0.85);
                output.mass = height * (1.0 - sink);
                p.y = 0.025 + output.mass;

                float slope = uv.y < crest ? -1.3 : 1.0;
                float3 n = normalize(float3(cos(angle) * slope, 1.0, sin(angle) * slope));
                output.fade *= 1.0 - smoothstep(0.74, 0.99, _LifeEnd);
                output.normalVS = TransformWorldToViewDir(TransformObjectToWorldDir(ToUnity(n), false), false);
                output.positionCS = TransformObjectToHClip(ToUnity(p * _EffectSize));
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 uv = input.uv;
                float t = _EffectTime;
                float3 normal = normalize(input.normalVS);
                float shade = 0.18 + max(0.0, dot(normal, normalize(float3(-0.65, 0.65, 0.35)))) * 0.28 + Noise2(float2(uv.x * 10.0, uv.y * 14.0 + t * 4.0)) * 0.20;
                float alpha = input.fade * smoothstep(0.015, 0.065, input.mass);
                alpha *= smoothstep(0.0, 0.12, sin(uv.x * VFX_PI)) * smoothstep(0.0, 0.10, sin(uv.y * VFX_PI));
                alpha *= 1.0 - smoothstep(0.61 + uv.y * 0.15, 0.80 + uv.y * 0.15, _LifeEnd);
                clip(alpha - 0.003);
                return float4(ToonShade(_EffectColor.rgb, shade), alpha);
            }
            ENDHLSL
        }
    }
}
