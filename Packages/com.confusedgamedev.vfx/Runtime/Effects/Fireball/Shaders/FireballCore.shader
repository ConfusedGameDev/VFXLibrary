Shader "ConfusedGameDev/Vfx/Fireball Core"
{
    Properties
    {
        [HideInInspector] _EffectTime("Time", Float) = 0
        [HideInInspector] _EffectSize("Size", Float) = 1
        [HideInInspector] _EffectDetail("Detail", Float) = 1
        [HideInInspector] _EffectColor("Color", Color) = (1, 0.22, 0.05, 1)
        [HideInInspector] _LifeStage("Life Stage", Float) = 1
        [HideInInspector] _LifeStart("Life Start", Float) = 1
        [HideInInspector] _LifeEnd("Life End", Float) = 0
        [HideInInspector] _Impact("Impact", Float) = 0
        [HideInInspector] _ParticleCount("Particle Count", Float) = 384
        [HideInInspector] _ImpactUp("Impact Up", Vector) = (0, 1, 0, 0)
    }

    SubShader
    {
        // The source is opaque while steady and blends during start-up and ending. One blended pass with
        // ZWrite covers both, because alpha stays 1 while steady. Keeping ZWrite on during the stages
        // matches the site's start-up; turning it off shows streaks from triangle order.
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

            #include "FireballCommon.hlsl"

            struct Attributes
            {
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalVS : TEXCOORD1;
                float3 viewVS : TEXCOORD2;
                float3 stagePosition : TEXCOORD3;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            float3 FlamePoint(float h, float a)
            {
                float t = _EffectTime;
                float body = smoothstep(0.28, 0.68, h);
                float scale = lerp(1.0, _EffectSize, body);
                float wave = sin(h * 12.0 + a * 3.0 + t * 6.5);
                float eddy = sin(h * 8.0 - a * 2.0 + t * 4.1);
                float capAngle = saturate((h - 0.8) / 0.2) * VFX_PI * 0.5;
                float capFade = h >= 1.0 ? 0.0 : cos(capAngle);
                float r = h > 0.8
                    ? pow(sin(0.8 * VFX_PI), 0.6) * 0.52 * capFade
                    : pow(max(0.00001, sin(h * VFX_PI)), 0.6) * (0.12 + 0.5 * h);
                r *= 1.0 + (wave * 0.28 + eddy * 0.20) * lerp(1.0, capFade, smoothstep(0.78, 0.9, h));
                float spin = a + h * 2.7 + sin(h * 6.0 + t * 3.2) * 0.30;
                float x = h > 0.8 ? 0.59 + 0.52 * sin(capAngle) : -2.65 + h * 4.05;
                x += (sin(a * 3.0 + t * 5.5) * 0.07 + eddy * 0.06) * smoothstep(0.60, 0.82, h) * capFade * capFade;
                x += sin(t * 4.1) * 0.035 * smoothstep(0.78, 1.0, h);
                x += sin(a * 3.0 + h * 8.0 + t * 5.0) * 0.35 * (1.0 - smoothstep(0.05, 0.48, h));
                x += (x - 0.65) * (_EffectSize - 1.0) * smoothstep(0.55, 0.90, h);
                float2 bend = float2(sin(h * 5.0 + t * 3.0), cos(h * 7.0 + t * 2.7)) * (0.04 + (0.9 - h) * 0.10);
                float2 crossSection = float2(cos(spin), sin(spin)) * r + bend;
                return float3(x, crossSection * scale);
            }

            Varyings Vert(Attributes input)
            {
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                float h = clamp(input.uv.x, 0.001, 1.0);
                float a = input.uv.y * VFX_PI * 2.0;
                float3 p = FlamePoint(h, a);

                float nh = min(h, 0.998);
                float3 dh = FlamePoint(min(nh + 0.001, 1.0), a) - FlamePoint(max(nh - 0.001, 0.0), a);
                float3 da = FlamePoint(nh, a + 0.003) - FlamePoint(nh, a - 0.003);
                float3 normal = normalize(cross(da, dh));

                float3 positionWS = TransformObjectToWorld(ToUnity(p));
                output.normalVS = TransformWorldToViewDir(TransformObjectToWorldDir(ToUnity(normal)));
                output.viewVS = -TransformWorldToView(positionWS);
                output.stagePosition = ApplyStage(positionWS);
                output.positionCS = TransformWorldToHClip(positionWS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float h = input.uv.x;
                float a = input.uv.y * VFX_PI * 2.0;
                float t = _EffectTime;
                float3 tint = _EffectColor.rgb;

                float2 flowUV = float2(h * 8.0 + t * 2.7, cos(a) * 1.6 + sin(a) * 2.1);
                float roll = Noise2(flowUV);
                float curl = Noise2(flowUV * 1.71 + float2(t * 0.9, 3.7));

                float tear = roll * 0.68 + curl * 0.32;
                float front = smoothstep(0.78, 1.0, h);
                float back = 1.0 - smoothstep(0.04, 0.40, h);
                clip(tear - (0.16 + front * 0.29 + back * 0.34 + sin(a * 3.0 + h * 9.0 + t * 4.0) * back * 0.10));

                float3 n = normalize(input.normalVS);
                float3 eye = normalize(input.viewVS);
                float roundness = abs(dot(n, eye));
                float turn = 0.5 + 0.5 * dot(n, normalize(float3(-0.3, 0.75, 0.6)));
                float heat = 0.10 + roundness * 0.20 + turn * 0.26 + roll * 0.34 + sin(h * 10.0 + a * 2.0 + t * 6.0) * 0.10;

                float3 c = lerp(tint * 0.38, tint * 1.12, ToonStep(0.40, heat));
                c = lerp(c, lerp(tint, float3(1.0, 0.88, 0.46), 0.6) * 1.2, ToonStep(0.64, heat));

                float alpha = 1.0;
                if (_LifeStage != 1.0)
                {
                    alpha = PhaseCoverage(input.stagePosition);
                    clip(alpha - 0.004);
                }
                return float4(c, alpha);
            }
            ENDHLSL
        }
    }
}
