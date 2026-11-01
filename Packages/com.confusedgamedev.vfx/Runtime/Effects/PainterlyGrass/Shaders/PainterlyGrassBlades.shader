Shader "ConfusedGameDev/Vfx/PainterlyGrass Blades"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" "Queue" = "Geometry" }

        HLSLINCLUDE
            #define LAYER_COUNT _LayerCounts.x
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

                float shape = GrassHash(seed.z * 103.0 + id * 7.0);
                float height = (0.30 + pow(abs(seed.z), 0.7) * 0.82) * (0.72 + shape * 0.38);
                float width = (0.065 + GrassHash(seed.w * 53.0 + id) * 0.10) * lerp(1.25, 0.72, seed.z);
                float taper = 0.22 + 0.78 * pow(max(0.0, sin(h * 2.85 + 0.23)), 0.72);
                float lean = (0.12 + shape * 0.27) * h * h;
                float2 leaf = across * x * width * taper + along * lean;
                leaf += WindAt(root, seed.w * 6.283185 + id * 0.23) * h * h;
                p = float3(leaf.x, h * height - lean * 0.16, leaf.y);
                output.shade = 0.12 + patchTone * 0.35 + shape * 0.28 + seed.z * 0.05;

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

                float streak = sin(h * 23.0 + sin(h * 9.0 + input.seed * 11.0) * 2.2 + input.seed * 31.0);
                float rim = 0.89 + streak * 0.028 * _EffectDetail;
                float tip = 1.0 - smoothstep(0.70, 1.03, h);
                clip(rim * tip - abs(x + 0.12 * sin(h * 5.0 + input.seed * 9.0)));
                float notch = step(0.94, sin(h * 21.0 + input.seed * 47.0)) * 0.065 * _EffectDetail;
                if (abs(x) > rim * tip - notch && h > 0.2)
                {
                    discard;
                }

                float light = input.shade + h * 0.16;
                color = lerp(_EffectColor.rgb * 0.37, _EffectColor.rgb * 0.77, step(0.36, light));
                color = lerp(color, _EffectColor.rgb * 1.13, step(0.57, light));
                color = lerp(color, lerp(_EffectColor.rgb, float3(0.70, 0.70, 0.22), 0.55), step(0.76, light));
                float stroke = step(0.64, sin(h * 10.0 + input.seed * 37.0 + x * 2.3));
                color *= 1.0 + (stroke - 0.5) * 0.10 * _EffectDetail;

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
