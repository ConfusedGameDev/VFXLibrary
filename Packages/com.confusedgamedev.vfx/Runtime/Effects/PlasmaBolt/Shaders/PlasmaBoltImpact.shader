Shader "ConfusedGameDev/Vfx/PlasmaBolt Impact"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+5" }

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
                float2 id : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float fade : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            float3 Bolt(float h, float id, float age)
            {
                float a = id * 2.399963;
                float l = 0.8 + Hash(float2(id, 3.0)) * 0.8;
                float cell = h * 6.0;
                float tick = floor(age * 24.0 + id * 0.31);
                float j = lerp(Hash(float2(floor(cell) + id * 13.0, tick)), Hash(float2(floor(cell) + 1.0 + id * 13.0, tick)), frac(cell)) - 0.5;
                float r = h * l;
                float2 radial = float2(cos(a), sin(a));
                float2 side = float2(-sin(a), cos(a));
                float2 spread = radial * r + side * j * 0.48 * sin(h * VFX_PI);
                return float3(0.025 + h * (0.12 + Hash(float2(id, 5.0)) * 0.35), spread);
            }

            float3 PointAt(float h, float part, float age)
            {
                float id = Mod(part, 12.0);
                float growth = smoothstep(0.0, 0.08, age);
                if (part < 12.0)
                {
                    return Bolt(h * growth, id, age);
                }
                if (part < 24.0)
                {
                    float root = 0.42 + Mod(id, 3.0) * 0.09;
                    float a = id * 2.399963 + 0.65;
                    return Bolt(root * growth, id, age) + float3(h * 0.12, cos(a) * h * 0.58, sin(a) * h * 0.58) * growth;
                }
                float spark = (part - 24.0) * 2.399963 + 0.4;
                float r = 0.15 + age * 3.5 + h * 0.3;
                return float3(0.08 + age * 0.4, cos(spark) * r, sin(spark) * r);
            }

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                float part = input.id.x;
                float age = _LifeEnd * 0.8;
                float id = Mod(part, 12.0);
                float scale = _EffectSize * (0.35 + 0.65 * _LifeStart);
                float h = input.positionOS.x;

                float3 positionVS = SourceToView(PointAt(h, part, age) * scale);
                float3 before = SourceToView(PointAt(max(0.0, h - 0.004), part, age) * scale);
                float3 after = SourceToView(PointAt(min(1.0, h + 0.004), part, age) * scale);
                float2 delta = after.xy - before.xy;
                float2 side = length(delta) < 0.00001 ? float2(0.0, 1.0) : normalize(float2(-delta.y, delta.x));

                float width = (id < 3.0 ? 0.22 : 0.105) * (1.0 - h * 0.8);
                if (part >= 12.0)
                {
                    width *= 0.48;
                }
                if (part >= 24.0)
                {
                    width = 0.045 * sin(h * VFX_PI) + 0.008;
                }
                positionVS.xy += side * input.positionOS.y * width * scale * RootScale();

                float end = 0.42 + Hash(float2(id, 7.0)) * 0.34;
                float fade = smoothstep(0.0, 0.016, age) * (1.0 - smoothstep(0.35, end, age));
                if (part >= 12.0)
                {
                    fade *= 0.35 + 0.65 * step(0.35, Hash(float2(id, floor(age * 25.0 + id))));
                }
                if (part >= 24.0)
                {
                    fade *= 1.0 - smoothstep(0.12, 0.36, age);
                }
                output.fade = fade;
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float d = abs(input.uv.y * 2.0 - 1.0);
                float core = 1.0 - smoothstep(0.12, 0.27, d);
                float edge = exp(-d * d * 13.0);
                float halo = exp(-d * d * 4.0);
                float3 blue = pow(abs(_EffectColor.rgb), 2.2) * float3(0.12, 0.65, 2.2);
                float3 c = lerp(blue, float3(0.8, 0.96, 1.0) * 1.5, core);
                float a = max(core, edge * 0.65 + halo * 0.3) * (1.0 - smoothstep(0.75, 1.0, d)) * input.fade;
                return float4(c, saturate(a));
            }
            ENDHLSL
        }
    }
}
