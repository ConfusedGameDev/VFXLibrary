Shader "ConfusedGameDev/Vfx/RadiantBeam Body"
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

            #define VFX_VARIANT 4
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBeam.hlsl"
            #include "Packages/com.confusedgamedev.vfx/Runtime/Effects/RadiantBeam/Shaders/RadiantBeamCommon.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float2 id : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float part : TEXCOORD1;
                float3 local : TEXCOORD2;
                float fade : TEXCOORD3;
                float3 stagePosition : TEXCOORD4;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                output.part = input.id.x;
                float t = _EffectTime;
                float3 p = input.positionOS;
                if (input.id.x < 0.5 || input.id.x > 1.5)
                {
                    p.yz *= (0.92 + 0.08 * sin(t * 3.0 + input.positionOS.x * 4.0)) * _EffectSize;
                }
                else
                {
                    p.yz = Rotate(p.yz, t * 0.35) * _EffectSize;
                    float end = sign(p.x) * 2.4;
                    p.x = end + (p.x - end) * _EffectSize / _Stretch;
                }

                output.fade = smoothstep(0.0, 0.25, t);
                output.local = p;
                output.positionCS = StageClip(p, output.stagePosition);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float part = input.part;
                float axial = pow(max(0.0, cos(input.local.x * 7.0 - _EffectTime * 8.0)), 10.0);
                float shade = part < 0.5 ? 0.93 : 0.6 + axial * 0.3;
                float alpha = input.fade * (part > 1.5 ? 0.16 + 0.12 * axial : part > 0.5 ? sin(input.uv.x * 3.14159) * (0.55 + 0.3 * axial) : 0.94);
                clip(alpha - 0.003);
                return StageLook(ToonShade(_EffectColor.rgb, shade), alpha, input.stagePosition);
            }
            ENDHLSL
        }
    }
}
