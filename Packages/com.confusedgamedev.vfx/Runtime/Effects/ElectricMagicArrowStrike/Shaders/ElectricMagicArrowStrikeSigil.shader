Shader "ConfusedGameDev/Vfx/ElectricMagicArrowStrike Sigil"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+1" }

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

            #define VFX_VARIANT 7
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "ElectricMagicArrowStrikeCommon.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                if (_EffectTime >= 1.62)
                {
                    return output;
                }

                output.uv = input.uv * 2.0 - 1.0;
                output.positionCS = TransformObjectToHClip(float3(-input.positionOS.x, input.positionOS.y, 0.0) * _EffectSize);
                return output;
            }

            float SigilLine(float d, float w)
            {
                return 1.0 - smoothstep(w, w + max(fwidth(d), 0.001), abs(d));
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 uv = input.uv;
                float r = length(uv);
                float a = atan2(uv.y, uv.x) + _EffectTime * 0.23;
                float rings = SigilLine(r - 0.89, 0.004) + SigilLine(r - 0.82, 0.002) + SigilLine(r - 0.57, 0.003);
                float sector = frac(a / (2.0 * VFX_PI) * 20.0);
                float x = (sector - 0.5) * 2.0;
                float y = (r - 0.7) / 0.08;
                float rune = max(SigilLine(x, 0.085) * step(abs(y), 0.8), SigilLine(y - x * 0.65, 0.10) * step(abs(x), 0.65)) * step(abs(y), 1.0);
                float ticks = SigilLine(sin(a * 32.0), 0.12) * step(0.91, r) * step(r, 0.95);
                float t = max(0.0, _EffectTime - 1.2);
                float alive = Charged() * (1.0 - smoothstep(0.0, 0.42, t)) * ArrowFade();
                float spokes = SigilLine(sin(a * 6.0), 0.03) * step(0.3, r) * step(r, 0.52);
                float bloom = exp(-Sq((r - 0.87) * 25.0)) * 0.21 + exp(-r * r * 5.0) * 0.10;
                float focus = lerp(1.0, 0.43, smoothstep(0.25, 0.9, _Charge));
                float alpha = (rings * 0.9 + rune * 0.8 + ticks * 0.7 + spokes * 0.4 + bloom) * alive * focus;
                clip(1.0 - r);
                clip(alpha - 0.003);
                return float4(_EffectColor.rgb, saturate(alpha * min(_EffectDetail, 1.4)));
            }
            ENDHLSL
        }
    }
}
