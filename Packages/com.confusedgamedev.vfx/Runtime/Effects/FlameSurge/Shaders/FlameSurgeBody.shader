Shader "ConfusedGameDev/Vfx/FlameSurge Body"
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
                float3 p : TEXCOORD1;
                float fade : TEXCOORD2;
                float phase : TEXCOORD3;
                float part : TEXCOORD4;
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
                float life = saturate(_EffectTime / 3.0);
                float alive = smoothstep(0.0, 0.025, life) * (1.0 - smoothstep(0.70, 1.0, life));
                output.fade = alive;

                if (part > 1.5)
                {
                    // A smoke puff that follows the tongues.
                    float seed = frac(phase * 0.618034);
                    float age = max(0.0, life - seed * 0.10);
                    float grow = smoothstep(0.0, 0.20, age);
                    float lane = Mod(phase, 4.0) - 1.5;
                    float h = 0.25 + floor(phase / 4.0) * 0.22;
                    if (abs(_Quantity - 5.0) > 0.1)
                    {
                        lane = _Quantity < 1.5 ? 0.0 : (input.extra.z / (_Quantity - 1.0) * 2.0 - 1.0) * 1.5;
                    }

                    float turn = h * (1.5 + age) + age * 0.12;
                    p = float3(lane * (0.18 + h * 0.64) * grow, -1.25 + sin(turn) * 1.35 * grow + h * 0.3 * grow, (1.0 - cos(turn)) * 0.95 * grow + age * 0.65);
                    p.y += smoothstep(0.55, 0.98, age) * 0.48;
                    p.y = -1.3 + (p.y + 1.3) * _EffectSize;
                    p.xz *= _EffectSize;

                    float3 positionVS = SourceToView(p);
                    float width = (0.15 + grow * 0.66) * (1.0 - smoothstep(0.62, 0.99, age) * 0.55);
                    positionVS.xy += (uv - 0.5) * width * _EffectSize * float2(1.15, 1.25) * RootScale();
                    output.fade = smoothstep(0.0, 0.07, age) * (1.0 - smoothstep(0.82, 1.0, age));
                    output.p = p;
                    output.positionCS = TransformWViewToHClip(positionVS);
                    return output;
                }

                float seed = frac(phase * 0.618034);
                float lane = phase < 3.0 ? phase - 1.0 : (phase - 3.5) * 1.5;
                if (abs(_Quantity - 5.0) > 0.1)
                {
                    lane = _Quantity < 1.5 ? 0.0 : input.extra.z / (_Quantity - 1.0) * 2.0 - 1.0;
                }

                float age = max(0.0, life - seed * 0.10);
                float grow = smoothstep(0.0, 0.20, age);
                float h = uv.x;
                float curl = h * (1.5 + age) + age * 0.12;
                float bulk = (phase < 3.0 ? 1.0 : 0.66) * grow;
                float height = bulk * (1.30 + seed * 0.25);
                float width = pow(max(0.0, sin(h * VFX_PI)), 0.65) * (0.36 + seed * 0.12) * bulk;
                width *= 1.0 - smoothstep(0.55, 0.96, age) * 0.7;
                float around = uv.y * VFX_PI * 2.0;
                float wrinkle = 1.0 + sin(h * 13.0 - age * 8.0 + around * 3.0 + phase) * 0.12;
                float3 center = float3(lane * (0.38 + h * 0.78) * grow, -1.26 + sin(curl) * height + h * 0.3 * grow, (1.0 - cos(curl)) * height * 0.70 + age * 0.65);
                p = center + float3(cos(around) * width * wrinkle, -sin(around) * sin(curl) * width * 0.55, sin(around) * cos(curl) * width * 0.55);
                p.y += smoothstep(0.60, 0.95, age) * h * 0.45;
                output.fade = smoothstep(0.0, 0.04, age) * (1.0 - smoothstep(0.90, 1.0, age));

                p.y = -1.3 + (p.y + 1.3) * _EffectSize;
                p.xz *= _EffectSize;
                output.p = p;
                output.positionCS = TransformObjectToHClip(ToUnity(p));
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 uv = input.uv;
                float phase = input.phase;
                float3 tint = _EffectColor.rgb;
                float age = max(0.0, _EffectTime / 3.0 - frac(phase * 0.618034) * 0.10);

                if (input.part > 1.5)
                {
                    float2 q = Spin(uv * 2.0 - 1.0, age * 3.0 + phase);
                    float3 smoke = NoiseGradient(q * 2.5 + float2(phase * 7.0, -age * 2.0));
                    float d = length(q) + (smoke.x - 0.5) * 0.30;
                    float lit = SmokeOptics(q, smoke.yz * 2.5, smoke.x, KeyLight()).x;
                    float burnt = smoothstep(0.45, 0.96, age);
                    float cover = (1.0 - smoothstep(0.76, 0.98, d)) * smoothstep(0.05 + burnt * 0.65, 0.20 + burnt * 0.65, smoke.x + (1.0 - d) * 0.5) * input.fade;
                    float heat = 0.12 + smoke.x * 0.39 + (1.0 - d) * 0.30 + lit * 0.16;
                    float3 puff = lerp(tint * 0.23, tint * 1.08, ToonStep(0.4, heat));
                    puff = lerp(puff, float3(1.0, 0.91, 0.53), ToonStep(0.67, heat));
                    clip(cover - 0.005);
                    return float4(puff, cover);
                }

                float3 shadingNormal = normalize(cross(ddx(input.p), ddy(input.p)));
                float shade = 0.25 + 0.65 * abs(dot(shadingNormal, normalize(float3(-0.4, 0.8, 0.5))));
                float alpha = input.fade;

                float n = Noise2(float2(uv.x * 6.0 - age * 4.0, uv.y * 3.0 + phase * 1.7));
                float curl = Noise2(float2(uv.x * 12.0 - age * 6.0, uv.y * 5.0 + phase));
                float burn = smoothstep(0.43, 0.93, age) * (1.0 - uv.x * 0.4);
                float tear = n * 0.65 + curl * 0.20 + sin(uv.x * VFX_PI) * 0.25 - burn * 1.35;
                alpha *= smoothstep(0.01, 0.09, tear) * (1.0 - smoothstep(0.64, 0.86, age));
                shade = 0.13 + n * 0.27 + shade * 0.20 + pow(max(0.0, sin(uv.y * VFX_PI * 2.0 + uv.x * 4.0 - age * 3.0)), 3.0) * 0.35;

                float3 c = lerp(tint * 0.25, tint * 1.08, ToonStep(0.36, shade));
                c = lerp(c, float3(1.0, 0.92, 0.58), ToonStep(0.65, shade));
                clip(alpha - 0.003);
                return float4(c, alpha);
            }
            ENDHLSL
        }
    }
}
