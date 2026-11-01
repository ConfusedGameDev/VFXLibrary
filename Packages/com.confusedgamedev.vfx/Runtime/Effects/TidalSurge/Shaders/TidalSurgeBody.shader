Shader "ConfusedGameDev/Vfx/TidalSurge Body"
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
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
                float4 extra : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalVS : TEXCOORD1;
                float fade : TEXCOORD2;
                float phase : TEXCOORD3;
                float part : TEXCOORD4;
                float mass : TEXCOORD5;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                float part = input.extra.x;
                float phase = input.extra.y;
                output.part = part;
                output.phase = phase;
                if (input.extra.z >= _Quantity)
                {
                    return output;
                }

                float2 uv = input.uv;
                float3 p = input.positionOS;
                float3 n = input.normalOS;
                float life = saturate(_EffectTime / 3.2);
                float alive = smoothstep(0.0, 0.025, life) * (1.0 - smoothstep(0.70, 1.0, life));
                output.fade = alive;

                if (part > 1.5)
                {
                    // A spray puff thrown off the crest.
                    float side = (phase / 11.0) * 2.0 - 1.0;
                    float born = 0.27 + abs(side) * 0.12 + sin(phase * 2.4) * 0.025;
                    float local = max(0.0, life - born);
                    float on = smoothstep(0.0, 0.055, local);
                    float angle = side * 1.6;
                    float travel = 0.85 + life * 2.2 + local * 0.75;
                    p = float3(sin(angle) * travel, -1.3 + max(0.035, 0.82 + local * 0.6 - local * local * 8.0), cos(angle) * travel - 0.5);
                    p.y = -1.3 + (p.y + 1.3) * _EffectSize;
                    p.xz *= _EffectSize;

                    float3 positionVS = SourceToView(p);
                    float size = (0.42 + local * 0.90) * on;
                    positionVS.xy += (uv - 0.5) * size * _EffectSize * RootScale();
                    output.fade = on * (1.0 - smoothstep(0.32, 0.60, local));
                    output.positionCS = TransformWViewToHClip(positionVS);
                    return output;
                }

                float across = uv.x * 2.0 - 1.0;
                float a = across * 1.6;
                float age = max(0.0, life - abs(across) * 0.12);
                float grow = smoothstep(0.0, 0.15, age);
                float crash = smoothstep(0.27, 0.58, age);
                float height = (0.5 + pow(max(0.0, 1.0 - across * across), 0.6) * 0.8) * grow;
                height *= 1.0 + sin(across * 12.0 - age * 7.0) * 0.14 + sin(across * 23.0 + age * 4.0) * 0.07;

                float theta = input.positionOS.y * VFX_PI * 2.0;
                float radial = 0.85 + life * 2.2;
                float roll = crash * 1.35;
                float yy = (1.0 - cos(theta)) * height * 0.5;
                float rr = sin(theta) * (0.25 + height * 0.22);
                float y = yy * cos(roll) - rr * sin(roll);
                float r = radial + yy * sin(roll) + rr * cos(roll);

                float breaking = smoothstep(0.27 + 0.04 * sin(across * 9.0), 0.61 + 0.035 * sin(across * 13.0), age);
                float crown = pow(max(0.0, sin(input.positionOS.y * VFX_PI)), 2.0);
                y -= breaking * height * 0.95 * crown;
                r += breaking * crown * 0.35;
                output.mass = max(0.0, y) / max(0.01, height);

                p = float3(sin(a) * r, -1.3 + max(0.025, y), cos(a) * r - 0.5);
                if (part > 0.5)
                {
                    p.y += 0.016;
                }

                n = normalize(float3(sin(a) * sin(theta + roll), -cos(theta + roll), cos(a) * sin(theta + roll)));
                output.fade *= 1.0 - smoothstep(0.42, 0.67, age);

                p.y = -1.3 + (p.y + 1.3) * _EffectSize;
                p.xz *= _EffectSize;
                output.normalVS = SourceDirToView(n);
                output.positionCS = TransformObjectToHClip(ToUnity(p));
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 uv = input.uv;
                float t = _EffectTime;
                float3 tint = _EffectColor.rgb;
                float3 foamColor = float3(0.83, 0.96, 1.0);

                if (input.part > 1.5)
                {
                    float2 q = uv * 2.0 - 1.0;
                    float3 spray = NoiseGradient(q * 2.7 + float2(input.phase * 6.0, -t * 0.8));
                    float d = length(q) + (spray.x - 0.5) * 0.32;
                    float cover = (1.0 - smoothstep(0.62, 0.98, d)) * smoothstep(0.05, 0.23, spray.x + (1.0 - d) * 0.25) * input.fade;
                    float lit = SmokeOptics(q, spray.yz * 2.7, spray.x, KeyLight()).x;
                    clip(cover - 0.004);
                    return float4(lerp(tint * 0.7, foamColor, ToonStep(0.42, lit * 0.5 + spray.x * 0.3 + 0.2)), cover);
                }

                float3 n = normalize(input.normalVS);
                float alpha = input.fade;
                float foam = Noise2(float2(uv.x * 23.0, uv.y * 5.0 - t * 1.8));
                float age = max(0.0, t / 3.2 - abs(uv.x * 2.0 - 1.0) * 0.17);
                float breakup = smoothstep(0.29, 0.62, age);
                alpha *= smoothstep(0.0, 0.08, sin(uv.x * VFX_PI)) * smoothstep(0.015, 0.10, input.mass);
                float shade = 0.16 + 0.42 * max(0.0, dot(n, normalize(float3(-0.4, 0.8, 0.5)))) + foam * 0.17;
                if (input.part > 0.5)
                {
                    shade = 0.94;
                    alpha *= smoothstep(0.35, 0.64, foam) * 0.88;
                }
                else
                {
                    float torn = foam + (1.0 - uv.y) * 0.20;
                    alpha *= smoothstep(breakup * 0.52 - 0.08, breakup * 0.52 + 0.08, torn);
                }

                float3 c = input.part > 0.5 ? foamColor : ToonShade(tint, shade);
                clip(alpha - 0.003);
                return float4(c, alpha);
            }
            ENDHLSL
        }
    }
}
