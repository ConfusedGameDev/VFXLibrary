Shader "ConfusedGameDev/Vfx/Shockwave Chips"
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

            #define VFX_VARIANT 2
            #define VFX_BURST_STAGED
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 seed : TEXCOORD1;
                float2 id : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float fade : TEXCOORD0;
                float3 normalVS : TEXCOORD1;
                float3 stagePosition : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                if (input.id.x >= _LayerCounts.w)
                {
                    return output;
                }

                float4 seed = input.seed;
                float t = _EffectTime;
                float a = seed.x * 6.28318;
                float3 p = input.positionOS * float3(1.3, 0.4, 0.8) * (0.4 + seed.w);
                float spin = a + t * 7.0;
                p.xy = Spin(p.xy, spin);
                float3 n = input.normalOS;
                n.xy = Spin(n.xy, spin);
                output.normalVS = SourceDirToView(n);

                p += float3(cos(a) * t * (0.8 + seed.z), max(0.02, (1.8 + seed.y * 1.8) * t - 3.0 * t * t), sin(a) * t * (0.8 + seed.z));
                p *= _EffectSize;
                p.y -= 1.35;
                output.fade = smoothstep(0.0, 0.05, t) * (1.0 - smoothstep(0.55, 1.5, t));
                output.positionCS = BurstClip(p, output.stagePosition);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float l = 0.3 + max(0.0, dot(normalize(input.normalVS), normalize(float3(-0.5, 0.8, 0.3))));
                float3 c = StyleColor(_EffectColor.rgb * 0.35, l * 0.65);
                return BurstStaged(float4(c, saturate(input.fade * _EffectDetail)), input.stagePosition);
            }
            ENDHLSL
        }
    }
}
