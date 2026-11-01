Shader "ConfusedGameDev/Vfx/EnergyBurst Clouds"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent" }

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

            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxCommon.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 seed : TEXCOORD1;
                float2 id : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float alpha : TEXCOORD1;
                float seed : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                output.alpha = 0.0;
                output.seed = input.seed.w;
                if (input.id.x >= _LayerCounts.y)
                {
                    output.positionCS = float4(0.0, 0.0, 0.0, 0.0);
                    return output;
                }

                float4 seed = input.seed;
                float t = _EffectTime;
                float a = seed.x * VFX_PI * 2.0;
                float r = sqrt(seed.z);
                float expand = smoothstep(0.02, 0.34, t);

                float3 p = float3(cos(a) * r * expand * 2.2, -1.24 + seed.y * 0.35 * expand, sin(a) * r * expand * 2.2);
                p.y = -1.2 + (p.y + 1.2) * _EffectSize;
                p.xz *= _EffectSize;

                float size = (0.6 + seed.w * 0.8) * _EffectSize * RootScale();
                float2 shape = float2(1.4, 0.65);
                output.alpha = smoothstep(0.01, 0.13, t) * (1.0 - smoothstep(0.3, 0.85, t)) * 0.12;

                float3 mv = SourceToView(p);
                mv.xy += input.positionOS.xy * size * shape;
                output.positionCS = TransformWViewToHClip(mv);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 q = input.uv * 2.0 - 1.0;
                float d = length(q);
                clip(1.0 - d);

                float angle = input.seed * 6.28 + _EffectTime * 0.18;
                float cosAngle = cos(angle);
                float sinAngle = sin(angle);
                float2 turned = float2(cosAngle * q.x + sinAngle * q.y, -sinAngle * q.x + cosAngle * q.y);
                float n = NoiseGradient(turned * 2.8 + float2(input.seed * 17.0, -_EffectTime * 0.18)).x;
                float body = smoothstep(0.14, 0.76, n + (1.0 - d) * 0.55);

                float alpha = exp(-d * d * 5.0) * (1.0 - smoothstep(0.7, 1.0, d));
                return float4(_EffectColor.rgb * (0.6 + body * 0.4), saturate(alpha * input.alpha * _EffectDetail));
            }
            ENDHLSL
        }
    }
}
