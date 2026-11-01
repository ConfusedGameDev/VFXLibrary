Shader "ConfusedGameDev/Vfx/SacredRelicDescent Wave"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+3" }

        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
            Blend One One
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
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float fadeClip : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                if (_PulseAge < 0.0)
                {
                    return output;
                }

                float2 uv = input.uv;
                output.uv = uv;
                float age = max(0.0, _PulseAge);
                float p = saturate(age / 1.6);
                float a = uv.x * 6.283185;
                float width = lerp(1.2, 0.6, p);
                float r = _WaveRadius - (1.0 - uv.y) * width;
                output.fadeClip = smoothstep(0.0, 0.15, r);
                float ripple = (sin(a * 11.0 - age * 6.0) + sin(a * 19.0 + age * 4.0)) * 0.018;
                float crest = pow(max(0.0, sin(uv.y * 3.141593)), 1.7) * 0.36 * (1.0 - p * 0.6);
                float3 q = float3(cos(a) * (max(0.0, r) + ripple), 0.055 + crest, sin(a) * (max(0.0, r) + ripple));
                output.positionCS = TransformWViewToHClip(RelicToView(q));
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float t = max(0.0, _PulseAge);
                float p = t / 1.6;
                float x = input.uv.x * 6.283185;
                float y = input.uv.y;
                float fade = smoothstep(0.0, 0.075, t) * (1.0 - smoothstep(1.05, 1.6, t));
                float edge = exp(-Sq((y - 0.76) / 0.11));
                float bodyShape = pow(max(0.0, sin(y * 3.141593)), 0.8);
                float feather = smoothstep(0.0, 0.32, y) * (1.0 - smoothstep(0.64, 1.0, y));
                float flow = pow(abs(0.5 + 0.5 * sin(y * 32.0 - t * 10.0 + sin(x * 13.0 - t * 3.0) * 0.55)), 6.0) * 0.13 * _EffectDetail;
                float breakup = 0.88 + 0.12 * sin(x * 23.0 - t * 5.0);
                float2 wp = float2(cos(x), sin(x)) * (_WaveRadius - (1.0 - y) * lerp(1.2, 0.6, p));
                float water = RelicWater(wp, t);
                float liquid = lerp(1.0, 0.10 + 0.90 * water, saturate(_EffectDetail));
                float alpha = (bodyShape * (0.29 + flow) * liquid + edge * 0.62 * (0.28 + 0.72 * water)) * pow(feather, 1.6) * fade * input.fadeClip * breakup * _Cancel;
                float3 color = lerp(_EffectColor.rgb, float3(1.0, 0.99, 0.91), edge * 0.9);
                clip(alpha - 0.0005);
                return Magic(color, alpha);
            }
            ENDHLSL
        }
    }
}
