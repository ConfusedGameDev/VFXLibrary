Shader "ConfusedGameDev/Vfx/Shockwave Sparks"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+3" }

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

            #define VFX_VARIANT 2
            #define VFX_BURST_STAGED
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
                if (input.id.x >= _LayerCounts.x)
                {
                    return output;
                }

                float4 seed = input.seed;
                float t = _EffectTime;
                float a = seed.x * VFX_PI * 2.0;
                float age = saturate(t / 2.8);
                float dt = max(0.0, t - seed.w * 0.1);
                float speed = 0.4 + seed.z * 1.6;

                float3 p = float3(cos(a) * speed * dt, -1.35 + (2.5 + seed.y * 3.3) * dt - 2.5 * dt * dt, sin(a) * speed * dt);
                p.y = max(-1.36, p.y);
                float alpha = pow(abs(1.0 - age), 1.7) * 0.65;
                float size = 0.018 + seed.w * 0.045;
                float2 shape = float2(0.6, 2.5);
                p.xz *= 1.7;
                p.y = -1.35 + (1.2 + seed.y * 2.2) * dt - 2.5 * dt * dt;
                p.y = max(-1.36, p.y);
                size *= 0.8;
                shape = float2(1.0, 1.0);
                alpha *= 0.4;

                output.alpha = alpha;
                float3 positionVS = SourceToView(p);
                positionVS.xy += input.positionOS.xy * size * shape * RootScale();
                output.positionCS = BurstViewToClip(positionVS, output.stagePosition);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 q = input.uv * 2.0 - 1.0;
                float d = length(q);
                clip(1.0 - d);

                float alpha = exp(-d * d * 5.0) * (1.0 - smoothstep(0.65, 1.0, d));
                float3 color = StyleColor(_EffectColor.rgb, 0.28 + (1.0 - d) * 0.5 + 0.1);

                return BurstStaged(float4(color, saturate(alpha * input.alpha * _EffectDetail)), input.stagePosition);
            }
            ENDHLSL
        }
    }
}
