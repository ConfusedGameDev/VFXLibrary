Shader "ConfusedGameDev/Vfx/GoldenChainRain Arrowheads"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" "Queue" = "Geometry+1" }

        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
            Blend One Zero
            ZWrite On
            Cull Front

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #define VFX_VARIANT 15
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "GoldenChainRainCommon.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
                float4 data : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 ringUv : TEXCOORD0;
                float3 viewVector : TEXCOORD1;
                float3 local : TEXCOORD2;
                float3 surface : TEXCOORD3;
                float3 normalVS : TEXCOORD4;
                float4 state : TEXCOORD5;
                float sourceDistance : TEXCOORD6;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                GcChain chain;
                if (!GcLoad(input.data.x, chain))
                {
                    return output;
                }

                float age = _EffectTime - chain.birth;
                if (age < 0.0 || age >= 1.85)
                {
                    return output;
                }

                float3 forward = (chain.end - chain.start) / chain.span;
                float3 right, side;
                GcBasis(forward, right, side);
                float3 p = input.positionOS;
                float3 n = input.normalOS;
                float reach = GcTipDistance(age, chain.span) - 0.32 + p.y;
                float3 local = chain.start + forward * reach + right * p.x + side * p.z;
                float3 positionVS = SourceToView(local * _EffectSize);
                output.local = local;
                output.normalVS = SourceDirToView(forward * n.y + right * n.x + side * n.z);
                output.viewVector = -positionVS;
                output.surface = p;
                output.ringUv = input.uv;
                output.state = float4(age, saturate(dot(local - chain.start, forward) / chain.span), saturate((age - 1.10) / 0.75), chain.seed);
                output.sourceDistance = reach;
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                if (input.local.y < 0.0 || input.sourceDistance < 0.0)
                {
                    discard;
                }

                float grain = GcHash(floor(input.ringUv * float2(24.0, 6.0)) + input.state.w * 83.0);
                float threshold = input.state.y * 0.78 + grain * 0.22;
                if (input.state.z > threshold)
                {
                    discard;
                }

                float edge = step(0.001, input.state.z) * (1.0 - smoothstep(0.0, 0.045, threshold - input.state.z));
                float3 liquid = input.surface * 13.5 * 0.65 * _TextureDensity;
                return float4(GcGold(normalize(input.normalVS), normalize(input.viewVector), liquid, input.state.x, input.state.w, edge), 1.0);
            }

            float4 FragDepth(Varyings input) : SV_Target
            {
                Frag(input);
                return input.positionCS.z;
            }
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }
            ColorMask R
            ZWrite On
            Cull Front

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment FragDepth

            #define VFX_VARIANT 15
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "GoldenChainRainCommon.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
                float4 data : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 ringUv : TEXCOORD0;
                float3 viewVector : TEXCOORD1;
                float3 local : TEXCOORD2;
                float3 surface : TEXCOORD3;
                float3 normalVS : TEXCOORD4;
                float4 state : TEXCOORD5;
                float sourceDistance : TEXCOORD6;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                GcChain chain;
                if (!GcLoad(input.data.x, chain))
                {
                    return output;
                }

                float age = _EffectTime - chain.birth;
                if (age < 0.0 || age >= 1.85)
                {
                    return output;
                }

                float3 forward = (chain.end - chain.start) / chain.span;
                float3 right, side;
                GcBasis(forward, right, side);
                float3 p = input.positionOS;
                float3 n = input.normalOS;
                float reach = GcTipDistance(age, chain.span) - 0.32 + p.y;
                float3 local = chain.start + forward * reach + right * p.x + side * p.z;
                float3 positionVS = SourceToView(local * _EffectSize);
                output.local = local;
                output.normalVS = SourceDirToView(forward * n.y + right * n.x + side * n.z);
                output.viewVector = -positionVS;
                output.surface = p;
                output.ringUv = input.uv;
                output.state = float4(age, saturate(dot(local - chain.start, forward) / chain.span), saturate((age - 1.10) / 0.75), chain.seed);
                output.sourceDistance = reach;
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                if (input.local.y < 0.0 || input.sourceDistance < 0.0)
                {
                    discard;
                }

                float grain = GcHash(floor(input.ringUv * float2(24.0, 6.0)) + input.state.w * 83.0);
                float threshold = input.state.y * 0.78 + grain * 0.22;
                if (input.state.z > threshold)
                {
                    discard;
                }

                float edge = step(0.001, input.state.z) * (1.0 - smoothstep(0.0, 0.045, threshold - input.state.z));
                float3 liquid = input.surface * 13.5 * 0.65 * _TextureDensity;
                return float4(GcGold(normalize(input.normalVS), normalize(input.viewVector), liquid, input.state.x, input.state.w, edge), 1.0);
            }

            float4 FragDepth(Varyings input) : SV_Target
            {
                Frag(input);
                return input.positionCS.z;
            }
            ENDHLSL
        }
    }
}
