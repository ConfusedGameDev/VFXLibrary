Shader "ConfusedGameDev/Vfx/DimensionalRend Shards"
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
            Cull Front

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #define VFX_VARIANT 1
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "DimensionalRendCommon.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float4 seed : TEXCOORD1;
                float2 id : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float4 screen : TEXCOORD0;
                float2 shift : TEXCOORD1;
                float alpha : TEXCOORD2;
                float tone : TEXCOORD3;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                if (input.id.x >= _LayerCounts.x || _EffectTime <= 1.0 || _EffectTime >= 3.4)
                {
                    return output;
                }

                float4 seed = input.seed;
                float i = floor(seed.x * _Quantity);
                float impulseAge = max(0.0, _EffectTime - REND_RELEASE);
                float kick = 1.0 - exp(-5.0 * impulseAge);
                output.tone = seed.w;
                output.alpha = smoothstep(0.0, 0.045, impulseAge) * (1.0 - smoothstep(2.2 + seed.z * 0.15, 3.4, _EffectTime));

                float shardScale = RendShardScale(seed);
                float3 shape = RendShardShape(seed);
                float3 q = RendShardVertex(input.positionOS.xy, shape, seed) * shardScale;
                q *= 1.0 + 0.65 * smoothstep(0.0, 0.10, impulseAge);
                float a = seed.y * 6.283185 + (seed.x < 0.5 ? -1.0 : 1.0) * (0.7 + 0.5 * seed.z) * kick;
                q.xy = Spin(q.xy, a);

                float3x3 frame = Rf(i);
                float3 p = Rc(i) + mul(float3((seed.y * 2.0 - 1.0) * Rl(i), (seed.z - 0.5) * 0.15, (seed.w - 0.5) * 0.15), frame) * _EffectSize;

                // The full rotating radius is reserved at birth, so shards hang in space as their impulse slows.
                float radius = RendShardRadius(shape, seed) * shardScale * 1.65;
                p.y = max(p.y, (0.02 + radius) * _EffectSize);
                float3 direction = p - RendCenter();
                direction.y = max(0.0, direction.y);
                if (length(direction) < 0.01 * _EffectSize)
                {
                    direction = float3(cos(seed.x * 6.283185), 0.0, sin(seed.x * 6.283185));
                }
                p += normalize(direction) * 2.2 * _EffectSize * kick;

                output.positionCS = TransformObjectToHClip(ToUnity(p + mul(q, frame) * _EffectSize));
                output.screen = ComputeScreenPos(output.positionCS);
                output.shift = ScreenShift(frame[0]) * (seed.w < 0.5 ? -1.0 : 1.0);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                clip(input.alpha - 0.003);
                float3 background = DisplacedScene(input.screen, input.shift, 5.0 * (0.65 + 0.65 * input.tone) * input.alpha);
                return float4(background, input.alpha);
            }
            ENDHLSL
        }
    }
}
