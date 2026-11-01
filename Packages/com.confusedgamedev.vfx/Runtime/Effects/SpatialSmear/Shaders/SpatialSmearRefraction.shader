Shader "ConfusedGameDev/Vfx/SpatialSmear Refraction"
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
            Cull Off

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBladeTrail.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl"

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float age = saturate(input.age);
                float y = input.uv.y;
                float fade = pow(abs(1.0 - age), 1.35);
                float coverage = fade * smoothstep(0.0, 0.08, y) * (1.0 - smoothstep(0.96, 1.0, y));
                clip(coverage - 0.002);
                float2 screen = input.screen.xy / input.screen.w;

                // Screen derivatives follow the real ribbon, through any weapon rotation.
                float2 dx = ddx(input.uv);
                float2 dy = ddy(input.uv);
                float2 pixel = float2(ddx(screen.x), ddy(screen.y));
                float det = dx.x * dy.y - dx.y * dy.x;
                clip(abs(det) - 1e-10);
                float2 across = float2(-dy.x, dx.x) / det * pixel;
                float2 flow = float2(dy.y, -dx.y) / det * pixel;
                flow = flow / max(length(flow), 1e-6) * min(length(across) * 0.28, 0.09);
                float band = sin(y * 66.0 + sin(age * 13.0) * 1.25 - age * 19.0);
                float fine = sin(y * 157.0 + age * 33.0) * 0.12;
                float2 delta = (flow * (0.35 + 0.65 * band + fine) + across * (band * 0.065 + fine * 0.04)) * _EffectDetail * coverage;
                float2 inset = 0.5 / max(_ScreenParams.xy, float2(1.0, 1.0));
                float edge = max(0.0, min(min(screen.x - inset.x, 1.0 - inset.x - screen.x), min(screen.y - inset.y, 1.0 - inset.y - screen.y)));
                delta *= smoothstep(0.0, max(0.04, length(delta) * 1.35), edge);
                return float4(SampleSceneColor(clamp(screen + delta, inset, 1.0 - inset)), coverage);
            }
            ENDHLSL
        }
    }
}
