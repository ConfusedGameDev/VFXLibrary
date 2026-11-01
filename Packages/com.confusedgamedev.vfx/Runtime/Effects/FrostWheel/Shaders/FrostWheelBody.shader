Shader "ConfusedGameDev/Vfx/FrostWheel Body"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+2" }

        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite On
            Cull Off

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #define VFX_VARIANT 4
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxProjectile.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
                float4 data : TEXCOORD1;
                float2 id : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 normalVS : TEXCOORD0;
                float3 stagePosition : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float t = _EffectTime;
                float3 p = input.positionOS;
                float3 n = input.normalOS;
                p.xy = Rotate(p.xy, t * 4.0);
                n.xy = Rotate(n.xy, t * 4.0);
                p.yz = Rotate(p.yz, 0.15 * sin(t * 2.0));
                output.normalVS = TransformWorldToViewDir(TransformObjectToWorldDir(ToUnity(n), false), false);
                output.positionCS = StageClip(p * _EffectSize, output.stagePosition);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float shade = 0.25 + 0.65 * abs(dot(normalize(input.normalVS), normalize(float3(-0.4, 0.8, 0.5))));
                float edge = abs(dot(normalize(input.normalVS), float3(0.0, 0.0, 1.0)));
                float ink = 1.0 - smoothstep(0.04, 0.13 + fwidth(edge), edge);
                float3 c = lerp(ToonShade(_EffectColor.rgb, shade), _EffectColor.rgb * 0.09, ink * 0.8);
                return float4(c, StageAlpha(input.stagePosition));
            }
            ENDHLSL
        }
    }
}
