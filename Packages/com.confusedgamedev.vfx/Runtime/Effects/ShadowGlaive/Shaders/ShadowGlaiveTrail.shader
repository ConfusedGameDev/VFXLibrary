Shader "ConfusedGameDev/Vfx/ShadowGlaive Trail"
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

            #define VFX_VARIANT 5
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxProjectile.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 data : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float phase : TEXCOORD1;
                float3 stagePosition : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                float phase = input.data.x;
                output.phase = phase;
                float t = _EffectTime;
                float3 p = input.positionOS;
                p.x -= 0.38 * _EffectSize;
                p.yz = Rotate(p.yz, t * 1.4 + phase);
                p.yz += sin(input.uv.x * 12.0 - t * 4.0 + phase) * input.uv.x * 0.06;
                output.positionCS = StageClip(p, output.stagePosition);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 uv = input.uv;
                float broken = smoothstep(0.1, 0.3, 0.5 + 0.5 * sin(uv.x * 29.0 + _EffectTime * 5.0 + input.phase));
                float a = pow(abs(1.0 - uv.x), 1.6) * sin(uv.y * VFX_PI) * broken * _EffectDetail;
                return float4(ToonShade(_EffectColor.rgb, 0.62), saturate(a * 0.75) * StageAlpha(input.stagePosition));
            }
            ENDHLSL
        }
    }
}
