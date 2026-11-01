Shader "ConfusedGameDev/Vfx/ArcaneMatrix Body"
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
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxGround.hlsl"

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

            // Slots the source lays out for extra crystals, past the first nine.
            float2 ExtraSlot(float e)
            {
                return e < 0.5 ? float2(0.425, 0.425) : e < 1.5 ? float2(-0.425, 0.425) : e < 2.5 ? float2(0.425, -0.425)
                    : e < 3.5 ? float2(-0.425, -0.425) : e < 4.5 ? float2(0.0, 0.425) : e < 5.5 ? float2(0.0, -0.425)
                    : e < 6.5 ? float2(0.425, 0.0) : e < 7.5 ? float2(-0.425, 0.0) : float2(0.425, 0.85);
            }

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float t = VFX_GROUND_TIME;
                float phase = input.data.x;
                float unit = input.data.y;
                if (unit >= _Quantity)
                {
                    return output;
                }

                float3 p = input.positionOS;
                float3 n = input.normalOS;
                if (input.id.x > 0.5)
                {
                    bool custom = abs(_Quantity - 9.0) > 0.1;
                    if (custom)
                    {
                        float2 from = float2(Mod(unit, 3.0) - 1.0, floor(unit / 3.0) - 1.0) * 0.85;
                        if (unit > 8.5)
                        {
                            from = ExtraSlot(unit - 9.0);
                        }

                        float columns = ceil(sqrt(_Quantity));
                        float rows = ceil(_Quantity / columns);
                        float row = floor(unit / columns);
                        float inRow = min(columns, _Quantity - row * columns);
                        float2 to = float2(
                            inRow < 1.5 ? 0.0 : (Mod(unit, columns) / (inRow - 1.0) * 2.0 - 1.0) * 0.85,
                            rows < 1.5 ? 0.0 : (row / (rows - 1.0) * 2.0 - 1.0) * 0.85);
                        p.xz += to - from;
                    }

                    p.y += 0.18 * sin(t * 1.4 + phase);
                    float turn = t * 0.18;
                    float angle = (floor(turn) + smoothstep(0.25, 0.75, frac(turn))) * VFX_PI * 0.5;
                    p.xz = Rotate(p.xz, angle);
                    if (custom)
                    {
                        n.xz = Rotate(n.xz, angle);
                    }
                }

                output.normalVS = TransformWorldToViewDir(TransformObjectToWorldDir(ToUnity(n), false), false);
                output.positionCS = GroundClip(p * _EffectSize, phase, output.stagePosition);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float shade = 0.25 + 0.65 * abs(dot(normalize(input.normalVS), normalize(float3(-0.4, 0.8, 0.5))));
                float edge = abs(dot(normalize(input.normalVS), float3(0.0, 0.0, 1.0)));
                float ink = 1.0 - smoothstep(0.04, 0.13 + fwidth(edge), edge);
                float3 c = lerp(ToonShade(_EffectColor.rgb, shade), _EffectColor.rgb * 0.09, ink * 0.8);
                return Staged(float4(c, 1.0), input.stagePosition);
            }
            ENDHLSL
        }
    }
}
