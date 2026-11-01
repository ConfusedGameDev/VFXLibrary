Shader "ConfusedGameDev/Vfx/IceShatter Crystals"
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
            Cull Off

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #define VFX_VARIANT 3
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 center : TEXCOORD1;
                float2 id : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 crystal : TEXCOORD0;
                float3 normalVS : TEXCOORD1;
                float fade : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.crystal = input.positionOS;
                float t = _EffectTime;
                float seed = input.center.w;
                float growth = smoothstep(0.0, 0.16, t);
                float flight = max(0.0, t - 0.24);
                float3 p = input.positionOS * growth * _EffectSize;
                float a = seed * 6.28318;
                float spin = flight * (seed - 0.5) * 2.0;
                p.xy = Spin(p.xy, spin);
                float3 n = input.normalOS;
                n.xy = Spin(n.xy, spin);
                output.normalVS = SourceDirToView(n);

                p += input.center.xyz + float3(cos(a) * flight * 1.5, -1.35 + flight * (1.3 + seed) - flight * flight * 2.0, sin(a) * flight * 1.5);
                output.fade = (1.0 - smoothstep(0.8, 1.7, t)) * step(input.id.x, _Quantity - 0.5);
                output.positionCS = TransformObjectToHClip(ToUnity(p));
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float t = _EffectTime;
                float3 crystal = input.crystal;
                float light = 0.3 + max(dot(normalize(input.normalVS), normalize(float3(-0.6, 0.8, 0.3))), 0.0);
                float n = Noise2(crystal.xy * 8.0 + crystal.z * 5.0);
                float crack = 1.0 - smoothstep(0.04, 0.13, abs(sin(crystal.y * 7.0 + crystal.x * 9.0 + n)));
                float fracture = smoothstep(0.10, 0.35, t) * crack;
                float dissolve = smoothstep(0.0, 0.14, n - (t - 0.8) * 0.65);
                float3 c = StyleColor(_EffectColor.rgb, 0.14 + light * 0.55 + fracture * 0.22);
                return float4(c, input.fade * dissolve);
            }
            ENDHLSL
        }
    }
}
