Shader "ConfusedGameDev/Vfx/VenomPool Body"
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
            Cull Front

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #define VFX_VARIANT 8
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
                float phase : TEXCOORD3;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                float phase = input.data.x;
                float unit = input.data.y;
                output.phase = phase;
                if (unit >= _Quantity)
                {
                    return output;
                }

                float3 p = input.positionOS;
                float3 n = input.normalOS;
                if (abs(_Quantity - 7.0) > 0.1)
                {
                    float r = unit < 0.5 ? 0.0 : 0.55 + Mod(unit, 2.0) * 0.35;
                    float angle = (unit - 1.0) * VFX_PI * 2.0 / max(1.0, _Quantity - 1.0);
                    p.xz += (float2(cos(angle), sin(angle)) - float2(cos(unit * 2.4), sin(unit * 2.4))) * r;
                }

                float pop = _LifeEnd > 0.0 ? saturate(_LifeEnd * 1.55 - frac(phase * 0.23) * 0.3) : frac(_EffectTime * 0.24 + phase * 0.17);
                p.y *= 0.8 + sin(pop * VFX_PI) * 0.5;
                p.y *= smoothstep(0.0, 0.6, _LifeStart);
                output.fade = 1.0 - smoothstep(0.91, 1.0, pop);
                output.normalVS = TransformWorldToViewDir(TransformObjectToWorldDir(ToUnity(n), false), false);
                output.positionCS = TransformObjectToHClip(ToUnity(p * _EffectSize));
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 uv = input.uv;
                float phase = input.phase;
                float3 normal = normalize(input.normalVS);
                float shade = 0.25 + 0.65 * abs(dot(normal, normalize(float3(-0.4, 0.8, 0.5))));
                float alpha = input.fade;
                float pop = _LifeEnd > 0.0 ? saturate(_LifeEnd * 1.55 - frac(phase * 0.23) * 0.3) : frac(_EffectTime * 0.24 + phase * 0.17);
                float hole = smoothstep(0.62, 0.81, pop);
                float edge = 1.0 - hole - uv.y + sin(uv.x * 31.4 + phase) * hole * 0.045;
                alpha *= smoothstep(-0.015, 0.03, edge);
                float rim = 1.0 - smoothstep(0.0, 0.07, abs(edge));
                float membrane = pow(abs(1.0 - abs(dot(normal, float3(0.0, 0.0, 1.0)))), 2.0);
                shade = 0.10 + shade * 0.30 + max(rim, membrane) * 0.55;
                alpha *= 0.22 + max(rim, membrane) * 0.65;
                clip(alpha - 0.003);
                return float4(ToonShade(_EffectColor.rgb, shade), alpha);
            }
            ENDHLSL
        }
    }
}
