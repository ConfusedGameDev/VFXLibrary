Shader "ConfusedGameDev/Vfx/VenomPool Particles"
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

            #define VFX_VARIANT 8
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxGround.hlsl"

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
                float light : TEXCOORD2;
                float3 stagePosition : TEXCOORD3;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                if (input.id.x >= _ParticleCount)
                {
                    return output;
                }

                float4 seed = input.seed;
                float t = _EffectTime;
                float f = frac(seed.x + t * (0.25 + seed.w * 0.3));
                float a = seed.y * 6.283;
                float scale = 0.035 + seed.w * 0.055;
                output.fade = sin(f * VFX_PI) * 0.7;
                output.light = 0.45 + seed.w * 0.4;

                float bubble = floor(seed.y * _Quantity);
                float ba = bubble * 2.4;
                float br = bubble < 0.5 ? 0.0 : 0.55 + Mod(bubble, 2.0) * 0.35;
                if (abs(_Quantity - 7.0) > 0.1)
                {
                    ba = (bubble - 1.0) * VFX_PI * 2.0 / max(1.0, _Quantity - 1.0);
                }

                float flight = _LifeStage != 2.0 ? frac(t * 0.24 + bubble * 0.238 - 0.65) : max(0.0, _LifeEnd * 1.55 - frac(bubble * 1.4 * 0.23) * 0.3 - 0.62);
                float splash = flight * 4.0;
                float angle = seed.x * VFX_PI * 2.0;
                float3 p = float3(cos(ba) * br + cos(angle) * splash * 0.3, max(0.04, 0.16 + splash * 0.5 - splash * splash * 0.7), sin(ba) * br + sin(angle) * splash * 0.3);
                scale *= 0.6;
                output.light = 0.6 + seed.w * 0.3;
                output.fade = smoothstep(0.0, 0.025, flight) * (1.0 - smoothstep(0.15, 0.28, flight)) * smoothstep(0.0, 0.3, _LifeStart) * (1.0 - smoothstep(0.85, 1.0, _LifeEnd));

                float3 positionVS = SourceToView(p);
                float2 corner = input.positionOS.xy * scale;
                positionVS.xy += corner * RootScale();
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 q = input.uv * 2.0 - 1.0;
                float a = 1.0 - smoothstep(0.45, 1.0, length(q));
                clip(a * input.fade - 0.003);
                return float4(ToonShade(_EffectColor.rgb, input.light), saturate(a * input.fade * _EffectDetail));
            }
            ENDHLSL
        }
    }
}
