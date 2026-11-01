Shader "ConfusedGameDev/Vfx/FrostLanceRain Body"
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

            #define VFX_VARIANT 10
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBeamUtility.hlsl"

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
                float3 normalWS : TEXCOORD0;
                float3 p : TEXCOORD1;
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
                float3 n = input.normalOS;
                float4 data = input.data;
                float unit = input.id.x;
                float t = _EffectTime;
                output.alpha = 1.0;
                output.tone = data.w;

                float index = floor(data.x * 9.0 + 0.5);
                float offset = abs(_Quantity - 9.0) < 0.1 ? data.x : index / _Quantity;
                float impact = 0.43 + offset * 1.05;
                float age = t - impact;

                // uv holds the landing center; only the frost patch sits off the ground.
                float3 c = float3(input.uv.x, data.z > 1.5 ? 0.025 : 0.0, input.uv.y);
                float3 q = p - c;
                if (data.z < 0.5)
                {
                    float fall = saturate((age + 0.34) / 0.34);
                    p = c + q * _EffectSize;
                    p.y += (1.0 - fall * fall) * 2.55;
                    output.alpha = smoothstep(-0.37, -0.30, age) * (1.0 - smoothstep(0.015, 0.12, age));
                }
                else if (data.z < 1.5)
                {
                    float a = saturate(age / 0.48);
                    p = c + q * _EffectSize * (1.0 - a * 0.55);
                    p.x += cos(data.y) * a * 0.43 * _EffectSize;
                    p.z += sin(data.y) * a * 0.43 * _EffectSize;
                    p.y += sin(a * VFX_PI) * 0.40 * _EffectSize;
                    output.alpha = smoothstep(0.0, 0.025, age) * (1.0 - smoothstep(0.20, 0.48, age));
                }
                else
                {
                    p = c + q * _EffectSize;
                    p.xz = c.xz + (p.xz - c.xz) * Ease(age / 0.15);
                    output.alpha = smoothstep(0.0, 0.04, age) * (1.0 - smoothstep(0.35, 0.85, age));
                }

                p.xz += (_Spread - 1.0) * c.xz;
                output.alpha *= (1.0 - smoothstep(2.12, 2.4, t)) * step(index + 0.5, _Quantity);

                output.p = p;
                output.normalWS = TransformObjectToWorldNormal(ToUnity(n));
                output.positionCS = TransformObjectToHClip(ToUnity(p));
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float3 p = input.p;
                float t = _EffectTime;
                float3 color = LitColor(input.normalWS, input.tone);
                float alpha = input.alpha;
                color = lerp(color, float3(0.86, 0.97, 1.0), 0.19);
                color += _EffectColor.rgb * 0.08 * pow(0.5 + 0.5 * sin(p.y * (12.0 + _EffectDetail * 13.0) + p.x * 19.0), 16.0);

                clip(alpha - 0.003);
                return float4(color, saturate(alpha));
            }
            ENDHLSL
        }
    }
}
