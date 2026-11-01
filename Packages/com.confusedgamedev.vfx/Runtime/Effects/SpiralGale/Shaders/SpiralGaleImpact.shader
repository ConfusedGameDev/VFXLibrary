Shader "ConfusedGameDev/Vfx/SpiralGale Impact"
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

            #define VFX_VARIANT 6
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


                float age = max(0.0, t - part * 0.025);
                float h = input.uv.x;
                float kind = Mod(part, 3.0);
                float spin = part * 2.399963 - age * (4.0 + kind) + h * 2.7;
                float pulse = sin(h * 3.14159265);
                float head = age * (3.4 + kind * 0.35);
                float radius = (0.05 + age * 0.95) * (0.5 + pulse * 0.5) * (0.7 + kind * 0.17);
                float width = (0.015 + pulse * 0.07) * (1.0 - smoothstep(0.45, 0.95, age));
                float tube = input.uv.y * 6.2831853;
                p = float3(0.04 + head + h * (0.35 + age * 0.7) + cos(tube) * width, cos(spin) * (radius + sin(tube) * width), sin(spin) * (radius + sin(tube) * width));


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

                float flow = Noise2(float2(input.uv.x * 8.0 - t * 5.0, part * 2.3));
                mask = smoothstep(t * 0.6 - 0.15, t * 0.6 + 0.10, flow) * sin(input.uv.x * VFX_PI);
                fade *= 1.0 - smoothstep(0.45, 0.96, t + part * 0.018);
                light = 0.35 + 0.35 * abs(dot(n, normalize(float3(0.4, 0.8, 0.5)))) + 0.16 * pow(abs(input.uv.x), 0.6);

                clip(mask * fade - 0.006);
                return float4(ToonShade(_EffectColor.rgb, light), mask * fade);
            }
            ENDHLSL
        }
    }
}
