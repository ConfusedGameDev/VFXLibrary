Shader "ConfusedGameDev/Vfx/MagmaFissure Body"
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

            #define VFX_VARIANT 8
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

                float path = data.x;
                if (unit >= 0.0 && abs(_Quantity - 13.0) > 0.1)
                {
                    path = unit / max(1.0, _Quantity - 1.0);
                }

                float arrival = 0.1 + path * 0.62;
                float age = t - arrival;
                float hit = Ease(age / 0.11);
                float settle = smoothstep(0.12, 0.75, age);
                if (data.z > 0.5 && data.z < 1.5)
                {
                    // A rock heaved aside as the crack passes. uv holds its center.
                    float3 c = float3(input.uv.x, 0.09, input.uv.y);
                    float3 q = p - c;
                    q.xz = Spin(q.xz, data.y * hit * (1.0 - settle) * 0.27);
                    p = c + q;
                    p.y += sin(saturate(age / 0.72) * VFX_PI) * (0.36 + Rand(path) * 0.2);
                    p.z += data.y * hit * (1.0 - settle) * 0.15;
                    if (abs(_Quantity - 13.0) > 0.1)
                    {
                        float index = path * 12.0;
                        p.x += (index - unit) * 0.36;
                        p.z += sin(index * 2.2) * 0.19 + sin(index * 0.79) * 0.14 - sin(unit * 2.2) * 0.19 - sin(unit * 0.79) * 0.14;
                    }
                }

                p.zy *= _EffectSize;
                output.alpha = smoothstep(-0.02, 0.055, age) * (1.0 - smoothstep(1.28, 1.8, t));
                if (unit >= 0.0)
                {
                    output.alpha *= step(unit + 0.5, _Quantity);
                }

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
                if (input.tone >= 0.0)
                {
                    color = lerp(_EffectColor.rgb, float3(1.0, 0.89, 0.4), 0.45 + 0.35 * sin(p.x * (5.0 + 3.0 * _EffectDetail) - t * 9.0));
                    alpha *= 0.8 + 0.2 * sin(p.x * 13.0 + t * 3.0);
                }

                clip(alpha - 0.003);
                return float4(color, saturate(alpha));
            }
            ENDHLSL
        }
    }
}
