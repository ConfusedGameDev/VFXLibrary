Shader "ConfusedGameDev/Vfx/IceShatter Clouds"
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

            #define VFX_VARIANT 3
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"

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
                float3 stagePosition : TEXCOORD3;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                output.seed = input.seed.w;
                if (input.id.x >= _LayerCounts.y)
                {
                    return output;
                }

                float4 seed = input.seed;
                float t = _EffectTime;
                float a = seed.x * VFX_PI * 2.0;
                float age = saturate(t / 2.8);
                float rise = 1.0 - exp(-t * 4.0);
                float crown = step(0.35, seed.y);
                float expansion = (0.25 + rise * 1.2) * (0.25 + seed.z * 0.75);

                float3 p = float3(cos(a) * expansion * crown, -1.36 + rise * (0.5 + seed.y * 2.45) + age * 0.3, sin(a) * expansion * crown);
                p.xz += float2(sin(t * 1.5 + a), cos(t * 1.7 + a)) * age * 0.25;
                float size = (0.3 + rise * 0.85) * (0.6 + seed.w * 0.7);
                float2 shape = float2(1.0, 1.0);
                float alpha = smoothstep(0.02, 0.18, t) * pow(abs(1.0 - age), 1.2) * 0.72;
                p.xz *= 1.5;
                p.y = -1.3 + age * 0.6 + seed.y * 0.35;
                size *= 0.75;
                alpha *= 0.55;

                size *= _EffectSize;

                output.alpha = alpha;
                float3 positionVS = SourceToView(p);
                positionVS.xy += input.positionOS.xy * size * shape * RootScale();
                output.positionCS = BurstViewToClip(positionVS, output.stagePosition);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 original = input.uv * 2.0 - 1.0;
                float d = length(original);
                clip(1.0 - d);

                float angle = input.seed * 6.28 + _EffectTime * 0.18;
                float2 q = Spin(original, angle);
                float3 coarse = NoiseGradient(q * 2.8 + float2(input.seed * 17.0, -_EffectTime * 0.18));
                float n = coarse.x;
                float2 gradient = Spin(coarse.yz * (2.8 * 0.72 + 5.7 * 0.28), -angle);
                float light = SmokeOptics(original, gradient, n, KeyLight()).x;

                float3 color = StyleColor(_EffectColor.rgb, 0.20 + light * 0.65 + n * 0.18);
                float alpha = (1.0 - smoothstep(0.68, 0.98, d + (n - 0.5) * 0.35)) * smoothstep(0.18, 0.42, n + (1.0 - d) * 0.35) * 0.82;

                return BurstStaged(float4(color, saturate(alpha * input.alpha * _EffectDetail)), input.stagePosition);
            }
            ENDHLSL
        }
    }
}
