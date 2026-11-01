Shader "ConfusedGameDev/Vfx/BindingCurse Body"
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

            #define VFX_VARIANT 5
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

                float cycle = frac(_EffectTime * 0.52 + phase * 0.15915);
                float tight = smoothstep(0.05, 0.15, cycle) * (1.0 - smoothstep(0.38, 0.83, cycle));
                float release = smoothstep(0.0, 0.66, _LifeEnd);
                float h = input.uv.x;
                float a = phase / 2.1 * 2.094395;
                if (abs(_Quantity - 3.0) > 0.1)
                {
                    a = unit * VFX_PI * 2.0 / _Quantity;
                }

                float hook = smoothstep(0.70, 1.0, h);
                float b = a + h * 1.1 + hook * (2.7 - release * 2.1);
                float r = (0.28 + sin(h * VFX_PI) * 1.04) * (1.0 - tight * 0.63) + release * h * 0.85;
                float width = (0.062 + 0.045 * sin(h * VFX_PI)) * (1.0 - smoothstep(0.86, 1.0, h) * 0.7);
                float side = input.uv.y * VFX_PI * 2.0;

                float3 p = float3(cos(b) * (r + cos(side) * width), 0.06 + sin(h * VFX_PI) * 1.55 + hook * 0.25 + sin(side) * width * 0.35, sin(b) * (r + cos(side) * width));
                p.y *= smoothstep(0.0, 0.85, _LifeStart);
                p.y -= release * release * h * 0.45;
                output.fade = 1.0 - smoothstep(0.62, 0.98, _LifeEnd);

                float3 n = input.normalOS;
                output.normalVS = TransformWorldToViewDir(TransformObjectToWorldDir(ToUnity(n), false), false);
                output.positionCS = TransformObjectToHClip(ToUnity(p * _EffectSize));
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 uv = input.uv;
                float t = _EffectTime;
                float alpha = input.fade * (1.0 - smoothstep(0.87, 1.0, _LifeEnd));
                float curse = frac(uv.x * 8.0 - t * 0.9 + input.phase * 0.17);
                float etch = 1.0 - smoothstep(0.04, 0.13, abs(curse - 0.5));
                float stain = Noise2(float2(uv.x * 5.0 - t * 1.1, uv.y * 2.0 + input.phase));
                float shade = lerp(0.14, 0.47, smoothstep(0.51, 0.67, stain));
                shade = max(shade, etch * 0.77 * pow(abs(sin(uv.y * VFX_PI * 2.0)), 7.0));
                alpha *= smoothstep(_LifeEnd * 0.8 - 0.12, _LifeEnd * 0.8 + 0.08, stain + uv.x * 0.18);
                alpha *= smoothstep(0.0, 0.06, uv.x);
                float edge = abs(dot(normalize(input.normalVS), float3(0.0, 0.0, 1.0)));
                float ink = 1.0 - smoothstep(0.04, 0.13 + fwidth(edge), edge);
                float3 c = lerp(ToonShade(_EffectColor.rgb, shade), _EffectColor.rgb * 0.09, ink * 0.8);
                clip(alpha - 0.003);
                return float4(c, alpha);
            }
            ENDHLSL
        }
    }
}
