Shader "ConfusedGameDev/Vfx/BlackHole FrontDisk"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+3" }

        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
            Blend One OneMinusSrcAlpha
            ZWrite Off
            Cull Front

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #define VFX_VARIANT 9
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "BlackHoleCommon.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 disk : TEXCOORD0;
                float3 pointVS : TEXCOORD1;
                float3 centerVS : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float3 position = input.positionOS;
                float t = _EffectTime;
                output.disk = position.xy;
                float scale = _EffectSize * max(0.0001, BhGrowth());
                float r = length(position.xy);
                float a = atan2(position.y, position.x);
                float spin = t * 0.72;
                float2 flow = float2(cos(a - spin / (r + 0.25)), sin(a - spin / (r + 0.25))) * r;
                float n = BhFbm(flow * 2.7);

                // A closed annulus: bounded radial scaling cannot fold it across its centre.
                float ringShape = 0.045 * sin(a * 3.0 - t * 0.32) + 0.025 * sin(a * 5.0 + t * 0.23) + 0.015 * (n - 0.5);
                float radius = r * (1.0 + ringShape);
                float twist = 0.10 * sin(a * 3.0 + r * 1.8 - t * 0.35) / (r + 0.3);
                float2 disk = float2(cos(a + twist), sin(a + twist)) * radius;
                float thickness = position.z * (0.34 + 0.08 * n);
                float lift = 0.06 * sin(a * 3.0 - r * 2.0 + t * 0.32) * smoothstep(0.7, 1.7, r);
                float height = (thickness + lift) * 0.125;
                float3 q = float3(disk.x, height, disk.y) * scale;

                output.pointVS = SourceToView(BhCenter() + q);
                output.centerVS = SourceToView(BhCenter());
                output.positionCS = TransformWViewToHClip(output.pointVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float layerWeight = BhFrontWeight(input.pointVS, input.centerVS);
                clip(layerWeight - 0.0001);
                float4 light = BhDiskLight(input.disk, layerWeight);
                clip(light.a + dot(light.rgb, float3(1.0, 1.0, 1.0)) - 0.00001);
                return light;
            }
            ENDHLSL
        }
    }
}
