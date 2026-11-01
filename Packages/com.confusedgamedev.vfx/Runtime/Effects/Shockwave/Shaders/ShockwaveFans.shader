Shader "ConfusedGameDev/Vfx/Shockwave Fans"
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
                float fade : TEXCOORD1;
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
                if (input.id.x >= _LayerCounts.z)
                {
                    return output;
                }

                float4 seed = input.seed;
                float t = _EffectTime;
                float dt = max(0.0, t - seed.w * 0.10);
                float a = seed.x * 6.28318;
                float rise = 1.0 - exp(-dt * 8.0);
                float h = input.uv.y;
                float r = h * rise * (0.35 + seed.z) + dt * 0.2;

                float3 p = float3(cos(a) * r, h * rise * (0.7 + seed.y) - h * dt * dt * 0.75, sin(a) * r);
                p *= _EffectSize;
                p.y -= 1.34;

                float3 positionVS = SourceToView(p);
                positionVS.x += input.positionOS.x * (0.16 + h * 0.75) * rise * _EffectSize * RootScale();
                output.fade = smoothstep(0.01, 0.10, dt) * (1.0 - smoothstep(0.25 + seed.y * 0.15, 1.2, dt));
                output.positionCS = BurstViewToClip(positionVS, output.stagePosition);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 uv = input.uv;
                float2 q = uv * 2.0 - 1.0;
                float n = Fbm(float2(q.x * 3.0 + input.seed * 15.0, q.y * 4.0 - _EffectTime));
                float width = (0.3 + uv.y * 0.5) * (0.55 + n * 0.6);
                float a = (1.0 - smoothstep(width * 0.75, width, abs(q.x))) * sin(uv.y * VFX_PI) * smoothstep(0.22, 0.42, n);
                float3 c = StyleColor(_EffectColor.rgb * 0.7, 0.20 + n * 0.70);
                return BurstStaged(float4(c, saturate(a * input.fade * 0.42)), input.stagePosition);
            }
            ENDHLSL
        }
    }
}
