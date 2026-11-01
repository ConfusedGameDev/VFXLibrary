Shader "ConfusedGameDev/Vfx/PlasmaBolt Glow"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+4" }

        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
            Blend SrcAlpha One
            ZWrite Off
            Cull Off

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #define VFX_VARIANT 1
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxProjectile.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                float3 positionVS = TransformWorldToView(TransformObjectToWorld(float3(0.0, 0.0, 0.0)));
                positionVS.xy += input.positionOS.xy * _EffectSize * (0.35 + 0.65 * _LifeStart) * (0.65 + smoothstep(0.0, 0.1, _LifeEnd) * 0.35) * RootScale();
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 q = input.uv * 2.0 - 1.0;
                float age = _LifeEnd * 0.8;
                float r = length(q);
                float a = atan2(q.y, q.x);
                float core = exp(-r * r * 100.0);
                float sheath = exp(-r * r * 24.0);
                float halo = exp(-r * r * 5.0);
                float spikes = pow(abs(cos(a * 3.0 + sin(a * 5.0) * 0.4)), 28.0) * exp(-r * 7.0);
                float fade = smoothstep(0.0, 0.012, age) * (1.0 - smoothstep(0.06, 0.22, age));
                float3 blue = pow(abs(_EffectColor.rgb), 2.2) * float3(0.1, 0.65, 2.2);
                return float4(lerp(blue, float3(0.8, 0.97, 1.0) * 1.7, saturate(core + sheath)), saturate((core + sheath * 0.6 + halo * 0.3 + spikes * 0.4) * fade));
            }
            ENDHLSL
        }
    }
}
