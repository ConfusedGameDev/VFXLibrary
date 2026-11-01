Shader "ConfusedGameDev/Vfx/ContinuousBeam Body"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+2" }

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

            #define VFX_VARIANT 0
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBeam.hlsl"

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
                float3 normalWS : TEXCOORD1;
                float3 viewWS : TEXCOORD2;
                float3 stagePosition : TEXCOORD3;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                float3 p = input.positionOS;
                float3 positionWS = TransformObjectToWorld(ToUnity(p * float3(1.0, _EffectSize, _EffectSize)));
                output.normalWS = TransformObjectToWorldNormal(ToUnity(float3(0.0, p.y, p.z)));
                output.viewWS = _WorldSpaceCameraPos - positionWS;
                p.yz *= _EffectSize;
                output.positionCS = StageClip(p, output.stagePosition);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float v = input.uv.y;
                float t = _EffectTime;
                float filament = pow(max(0.0, cos(input.uv.x * VFX_PI * 8.0 - v * 31.0 + t * 8.0)), 20.0);
                float facing = abs(dot(normalize(input.normalWS), normalize(input.viewWS)));
                float alpha = 0.48 + filament * 0.35;
                float3 c = _EffectColor.rgb * 1.2 + 0.35 + _EffectColor.rgb * filament * 0.6 + pow(facing, 6.0) * 0.3;
                return float4(c, alpha * StageAlpha(input.stagePosition));
            }
            ENDHLSL
        }
    }
}
