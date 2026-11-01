Shader "ConfusedGameDev/Vfx/SacredRelicDescent Debris"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+4" }

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

            #define VFX_VARIANT 18
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "SacredRelicDescentCommon.hlsl"

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
                float fade : TEXCOORD1;
                float shade : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                if (input.id.x >= _LayerCounts.x || _ImpactAge < 0.0 || _ImpactAge >= 1.5)
                {
                    return output;
                }

                float4 seed = input.seed;
                output.uv = input.uv * 2.0 - 1.0;
                float age = max(0.0, _ImpactAge);
                float delay = seed.w * 0.045;
                float t = max(0.0, age - delay);
                float a = seed.x * 6.283185;
                float lifetime = 0.65 + seed.y * 0.75;
                float speed = 2.0 + seed.z * 3.3;
                float vy = 2.3 + seed.y * 2.3;
                float3 p = float3(cos(a) * (0.15 + speed * t), 0.06 + vy * t - 4.9 * t * t, sin(a) * (0.15 + speed * t));
                output.fade = step(delay, age) * (1.0 - smoothstep(lifetime * 0.65, lifetime, t)) * smoothstep(-0.12, 0.04, p.y);
                p.y = max(0.025, p.y);
                output.shade = 0.4 + seed.z * 0.5;
                float3 positionVS = RelicToView(p);
                float rotation = seed.z * 6.283 + t * (3.0 + seed.y * 5.0);
                float2 q = Spin(input.positionOS.xy, rotation);
                positionVS.xy += q * float2(0.11 + seed.w * 0.18, 0.07 + seed.z * 0.14) * _EffectSize;
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 uv = input.uv;
                float d = max(abs(uv.x) * 0.80 + abs(uv.y) * 0.39, max(abs(uv.y) * 0.86, abs(uv.x + uv.y * 0.38) * 0.77));
                float mask = 1.0 - smoothstep(0.65, 0.70, d);
                float top = step(uv.x * 0.38 - 0.12, uv.y);
                float side = step(-0.12, uv.x + uv.y * 0.25);
                float grain = 0.94 + 0.06 * sin(uv.x * 37.0 + uv.y * 51.0);
                float3 color = lerp(float3(0.08, 0.065, 0.05), float3(0.48, 0.41, 0.31), 0.18 + top * 0.44 + side * 0.12 + input.shade * 0.13) * grain;
                float alpha = mask * input.fade * _Cancel;
                clip(alpha - 0.003);
                return float4(color, saturate(alpha));
            }
            ENDHLSL
        }
    }
}
