Shader "ConfusedGameDev/Vfx/QuicksandSeal Particles"
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

            #define VFX_VARIANT 7
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

                float bank = floor(seed.y * _Quantity);
                float angle = bank * VFX_PI * 2.0 / _Quantity + 0.32 + (seed.z - 0.5) * 1.55;
                if (_Quantity > 3.5)
                {
                    angle = bank * VFX_PI * 2.0 / _Quantity + 0.32 + (seed.z - 0.5) * 1.55 * 3.0 / _Quantity;
                }

                float cycle = frac(_EmitterTime * 0.24 + bank * 0.31);
                if (_LifeStage == 2.0)
                {
                    cycle = min(0.999, cycle + _LifeEnd * 0.90);
                }

                float local = saturate((cycle - 0.10 - seed.z * 0.25) * 2.4);
                float fall = smoothstep(0.02, 0.88, local);
                float crest = 0.82 - 0.52 * fall;
                float v = crest * (1.0 - f);
                float r = 0.10 + v * 1.23;
                float bankHeight = pow(abs(sin(seed.z * VFX_PI)), 0.65) * (0.17 + smoothstep(0.0, 0.16, cycle) * 0.25);
                float3 p = float3(cos(angle) * r * 0.72, 0.035 + bankHeight * (1.0 - f) * (1.0 - fall * 0.85), sin(angle) * r * 0.72);
                scale = 0.025 + seed.w * 0.025;
                output.light = 0.45 + seed.w * 0.35;
                output.fade *= smoothstep(0.27, 0.4, cycle) * (1.0 - smoothstep(0.82, 0.99, cycle)) * smoothstep(0.0, 0.7, _LifeStart) * (1.0 - smoothstep(0.7, 1.0, _LifeEnd));
                p *= _EffectSize;

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
