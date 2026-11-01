Shader "ConfusedGameDev/Vfx/BlackHole OuterLens"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+1" }

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
                float3 lensPoint : TEXCOORD0;
                float3 lensEye : TEXCOORD1;
                float4 screen : TEXCOORD2;
                float4 centerScreen : TEXCOORD3;
                float2 radius : TEXCOORD4;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                const float3 axes = float3(3.05, 0.58, 3.05);
                float3 position = input.positionOS;
                float scale = _EffectSize * max(0.0001, BhGrowth());
                float3 localEye = ToUnity(TransformWorldToObject(_WorldSpaceCameraPos));
                output.lensPoint = position / axes;
                output.lensEye = (localEye - BhCenter()) / (axes * scale);

                float3 centerVS = SourceToView(BhCenter());
                output.positionCS = TransformWViewToHClip(SourceToView(BhCenter() + position * scale));
                output.screen = ComputeScreenPos(output.positionCS);
                output.centerScreen = ComputeScreenPos(TransformWViewToHClip(centerVS));
                output.radius = BhScreenRadius(centerVS, scale);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float fade = BhFade();
                if (fade < 0.001 || input.centerScreen.w <= 0.0)
                {
                    discard;
                }

                // Ray distance in unit-sphere space gives a continuous convex footprint.
                float3 ray = normalize(input.lensPoint - input.lensEye);
                float r = saturate(length(cross(input.lensPoint, ray)));
                float coverage = (1.0 - smoothstep(0.96, 1.0, r)) * fade;
                clip(coverage - 0.001);

                float2 uv = input.screen.xy / input.screen.w;
                float2 center = input.centerScreen.xy / input.centerScreen.w;
                float2 radius = max(abs(input.radius), float2(0.00001, 0.00001));
                float2 q = (uv - center) / radius;
                float2 direction = q / max(length(q), 0.0001);
                float angle = atan2(q.y, q.x);
                float spiral = angle + 2.6 * log(r + 0.13) + _EffectTime * 0.8;
                float noise = BhFbm(float2(cos(spiral), sin(spiral)) * 4.0 + float2(r * 8.0 + _EffectTime * 0.9, r * 3.0));
                float fieldDistance = lerp(0.25, 0.80, r * r);
                float2 inset = 0.5 / max(_ScreenParams.xy, float2(1.0, 1.0));
                float2 delta = BhBackgroundOffset(uv, direction, fieldDistance, spiral, noise, radius, inset) * 0.5 * (1.0 - smoothstep(0.85, 1.0, r));
                float2 bent = clamp(uv + delta, inset, 1.0 - inset);
                float3 background = SampleSceneColor(bent);
                float4 rear = BhRearDiskThroughLens(bent);
                return float4(background * (1.0 - rear.a) + rear.rgb, coverage);
            }
            ENDHLSL
        }
    }
}
