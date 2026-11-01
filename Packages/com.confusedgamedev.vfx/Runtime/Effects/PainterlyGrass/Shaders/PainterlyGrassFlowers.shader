Shader "ConfusedGameDev/Vfx/PainterlyGrass Flowers"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" "Queue" = "Geometry" }

        HLSLINCLUDE
            #define LAYER_COUNT _LayerCounts.y
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxCommon.hlsl"

            float GrassHash(float n)
            {
                return frac(sin(n * 127.1 + 311.7) * 43758.5453);
            }

            float2 WindAt(float2 root, float phase)
            {
                float wave = sin(dot(root, float2(1.1, 0.7)) - _EffectTime * 1.45);
                float gust = 0.5 + 0.5 * sin(dot(root, float2(0.48, -0.31)) - _EffectTime * 0.63);
                float flutter = sin(_EffectTime * 2.6 + phase + root.x * 3.0) * 0.025;
                return float2(0.12 + wave * 0.11 + gust * 0.13, 0.035 + wave * 0.045 + flutter);
            }

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
                float shade : TEXCOORD1;
                float seed : TEXCOORD2;
                float petal : TEXCOORD3;
                float growth : TEXCOORD4;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                output.seed = input.seed.w;
                if (input.id.x >= LAYER_COUNT)
                {
                    return output;
                }

                float4 seed = input.seed;
                float2 uv = input.uv;
                float x = input.positionOS.x;
                float h = input.positionOS.y;
                float id = input.positionOS.z;
                output.growth = smoothstep(0.0, 1.0, _LifeStart) * (1.0 - smoothstep(0.0, 1.0, _LifeEnd));
                float2 root = (seed.xy * 2.0 - 1.0) * 1.85;
                root *= sqrt(1.0 - 0.27 * root.yx * root.yx / 3.4225);
                float angle = seed.w * 6.283185 + id * 2.39996;
                float2 along = float2(cos(angle), sin(angle));
                float2 across = float2(-along.y, along.x);
                float patchTone = 0.5 + 0.5 * sin(root.x * 2.3 + sin(root.y * 1.8) * 1.4);
                float3 p;

                float height = 0.48 + seed.z * 0.45;
                float2 wind = WindAt(root, seed.w * 6.283185);
                if (id < 0.5)
                {
                    p = float3(across.x * x * 0.009, h * height, across.y * x * 0.009);
                    p.xz += wind * h * h;
                }
                else
                {
                    output.petal = 1.0;
                    float a = (id - 1.0) * 1.256637 + seed.w * 6.283185;
                    float2 radial = float2(cos(a), sin(a));
                    float2 tangent = float2(-radial.y, radial.x);
                    float lengthPetal = 0.12 + GrassHash(id + seed.z * 91.0) * 0.085;
                    float2 petal = radial * (0.012 + h * lengthPetal) + tangent * x * (0.045 + seed.z * 0.025);
                    p = float3(petal.x, height + 0.018 + h * 0.035 + dot(petal, across) * 0.65, petal.y);
                    p.xz += wind;
                }
                output.shade = 0.4 + seed.z * 0.3;

                p *= _EffectSize * output.growth;
                p.xz += root;
                output.positionCS = TransformObjectToHClip(ToUnity(p));
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                clip(input.growth - 0.002);
                float x = input.uv.x * 2.0 - 1.0;
                float h = input.uv.y;
                float3 color;

                if (input.petal > 0.5)
                {
                    float edge = 0.74 + 0.09 * sin(h * 19.0 + input.seed * 17.0);
                    float cap = pow(abs((h - 0.46) / 0.57), 4.0);
                    clip(edge - (x * x + cap));
                    color = lerp(float3(0.69, 0.74, 0.70), float3(0.86, 0.89, 0.82), step(0.43, input.shade + x * 0.09));
                }
                else
                {
                    float light = input.shade + h * 0.16;
                    color = lerp(_EffectColor.rgb * 0.37, _EffectColor.rgb * 0.77, step(0.36, light));
                    color = lerp(color, _EffectColor.rgb * 1.13, step(0.57, light));
                    color = lerp(color, lerp(_EffectColor.rgb, float3(0.70, 0.70, 0.22), 0.55), step(0.76, light));
                    float stroke = step(0.64, sin(h * 10.0 + input.seed * 37.0 + x * 2.3));
                    color *= 1.0 + (stroke - 0.5) * 0.10 * _EffectDetail;
                }

                return float4(color, 1.0);
            }

            float4 FragDepth(Varyings input) : SV_Target
            {
                Frag(input);
                return input.positionCS.z;
            }
        ENDHLSL

        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
            ZWrite On
            Cull Off

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            ENDHLSL
        }

        // Depth priming and the depth texture need the same cut-out silhouette.
        Pass
        {
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }
            ZWrite On
            ColorMask R
            Cull Off

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment FragDepth
            ENDHLSL
        }
    }
}
