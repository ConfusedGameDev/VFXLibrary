Shader "ConfusedGameDev/Vfx/ArcaneMissile Impact"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+5" }

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
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxProjectile.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 center : TEXCOORD1;
                float2 id : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 p : TEXCOORD1;
                float part : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                output.part = input.id.x;

                float t = _LifeEnd;
                float open = 1.0 - exp(-t * 7.0);
                float3 p = input.positionOS;
                float3 center = input.center.xyz;
                float part = input.id.x;


                p -= center;
                p *= 0.25 + sin(t * 3.14159) * 0.8;
                p += center * (0.2 + open * 2.0);
                p.x += t * 0.5;


                p *= _EffectSize * (0.35 + 0.65 * _LifeStart);
                output.p = p;
                output.positionCS = TransformObjectToHClip(ToUnity(p));
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float t = _LifeEnd;
                float part = input.part;
                float fade = smoothstep(0.0, 0.07, t) * (1.0 - smoothstep(0.52, 1.0, t));
                float3 n = normalize(cross(ddx(input.p), ddy(input.p)));
                float light = 0.35 + abs(dot(n, normalize(float3(0.7, 1.0, 0.5)))) * 0.45;
                float mask = 1.0;

                mask = 1.0 - smoothstep(0.5, 0.9, t + part * 0.025);
                light = 0.65;

                clip(mask * fade - 0.006);
                return float4(ToonShade(_EffectColor.rgb, light), mask * fade);
            }
            ENDHLSL
        }
    }
}
