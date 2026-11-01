Shader "ConfusedGameDev/Vfx/AstralGate Membrane"
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

            #define VFX_VARIANT 0
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBeamUtility.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
                float4 data : TEXCOORD1;
                float2 id : TEXCOORD2;
                float3 center : TEXCOORD3;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS : TEXCOORD0;
                float3 p : TEXCOORD1;
                float alpha : TEXCOORD2;
                float tone : TEXCOORD3;
                float part : TEXCOORD4;
                float2 uv : TEXCOORD5;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float3 p = input.positionOS;
                float3 n = input.normalOS;
                float3 c = input.center;
                float3 q = p - c;
                float4 data = input.data;
                float unit = input.id.x;
                float t = _EffectTime;
                output.alpha = 1.0;
                output.tone = data.w;
                output.part = data.x;
                output.uv = input.uv;

                float s = Grow();
                float close = 1.0 - smoothstep(0.0, 0.82, _LifeEnd);
                p.y -= 1.45;
                p.z *= max(0.012, s * close);
                p.y *= 0.7 + 0.3 * s * close;
                p.y += 1.45;
                p *= _EffectSize;
                output.alpha = s * close * FadeEnd();

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
                float2 m = (input.uv - 0.5) * 2.0;
                float r = length(m);
                float a = atan2(m.y, m.x);
                float swirl = 0.5 + 0.5 * sin(r * (10.0 + _EffectDetail * 5.0) - a * 3.0 - t * 3.25);
                float2 starUv = (m + float2(sin(t * 0.08) * 0.1, t * 0.009)) * (12.0 + _EffectDetail * 2.0);
                float2 grid = floor(starUv);
                float2 cell = frac(starUv) - 0.5;
                float cross_ = max(pow(max(0.0, 1.0 - abs(cell.x) * 13.0), 3.0) * max(0.0, 1.0 - abs(cell.y) * 3.2),
                    pow(max(0.0, 1.0 - abs(cell.y) * 13.0), 3.0) * max(0.0, 1.0 - abs(cell.x) * 3.2));
                float star = step(0.963, Rand(dot(grid, float2(1.0, 71.0)))) * cross_ * (0.72 + 0.28 * sin(t + grid.x));
                color = lerp(_EffectColor.rgb * 0.035, _EffectColor.rgb * 0.23, swirl * 0.17 + smoothstep(0.55, 1.0, r) * 0.55);
                color += lerp(_EffectColor.rgb, float3(1.0, 1.0, 1.0), 0.8) * star * 2.0;
                alpha *= 0.50 * (1.0 - smoothstep(0.96, 1.0, r));
                clip(alpha - 0.003);
                return float4(color, saturate(alpha));
            }
            ENDHLSL
        }
    }
}
