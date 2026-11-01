Shader "ConfusedGameDev/Vfx/ThornCrown Body"
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

            #define VFX_VARIANT 6
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
                float2 uv : TEXCOORD0;
                float3 normalVS : TEXCOORD1;
                float3 local : TEXCOORD2;
                float fade : TEXCOORD3;
                float part : TEXCOORD4;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                float phase = input.data.x;
                float unit = input.data.y;
                float part = input.id.x;
                output.part = part;
                if (unit >= _Quantity)
                {
                    return output;
                }

                float3 p = input.positionOS;
                float3 n = input.normalOS;
                float delay = frac(phase * 0.37) * 0.18;
                float retract = smoothstep(delay, 0.95, _LifeEnd);
                float h = max(0.0, p.y);
                float root = phase * VFX_PI * 0.5;
                if (unit >= 0.0 && abs(_Quantity - 4.0) > 0.1)
                {
                    float original = unit * VFX_PI * 2.0 / (unit < 3.5 ? 4.0 : 8.0);
                    root = unit * VFX_PI * 2.0 / _Quantity;
                    p.xz = Rotate(p.xz, original - root);
                    n.xz = Rotate(n.xz, original - root);
                }

                float2 leafRadial = normalize(p.xz + float2(0.0001, 0.0001));
                float2 toward = float2(cos(root), sin(root));
                float2 base = toward * 0.8;
                float bend = retract * (1.3 + h * 1.3);
                float arc = h * max(0.12, 1.0 - retract * 0.65);
                p.xz = base + (p.xz - base) * (1.0 - retract * 0.55);
                p.xz += toward * (1.0 - cos(bend)) * arc * 0.45;
                p.y = max(0.025, arc * sin(bend + 0.001) / (bend + 0.001));
                if (part > 1.5)
                {
                    float fold = smoothstep(0.0, 0.7, retract);
                    float blade = input.uv.x * 0.55;
                    p.xz -= leafRadial * blade * fold;
                    p.y += blade * sin(fold * VFX_PI * 0.8) * 0.35;
                }

                p.y *= smoothstep(0.0, 0.85, _LifeStart);
                output.fade = 1.0 - smoothstep(0.78, 1.0, _LifeEnd);
                output.normalVS = TransformWorldToViewDir(TransformObjectToWorldDir(ToUnity(n), false), false);
                p *= _EffectSize;
                output.local = p;
                output.positionCS = TransformObjectToHClip(ToUnity(p));
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float shade = 0.25 + 0.65 * abs(dot(normalize(cross(ddx(input.local), ddy(input.local))), normalize(float3(-0.4, 0.8, 0.5))));
                float alpha = input.fade;
                if (input.part > 1.5)
                {
                    alpha *= 1.0 - smoothstep(0.48 - _LifeEnd * 0.42, 0.52 - _LifeEnd * 0.42, abs(input.uv.y - 0.5));
                }

                float edge = abs(dot(normalize(input.normalVS), float3(0.0, 0.0, 1.0)));
                float ink = 1.0 - smoothstep(0.04, 0.13 + fwidth(edge), edge);
                float3 c = lerp(ToonShade(_EffectColor.rgb, shade), _EffectColor.rgb * 0.09, ink * 0.8);
                clip(alpha - 0.003);
                return float4(c, alpha);
            }
            ENDHLSL
        }
    }
}
