Shader "ConfusedGameDev/Vfx/Fireball Impact"
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

            #include "FireballCommon.hlsl"

            struct Attributes
            {
                float2 uv : TEXCOORD0;
                float2 id : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 lightVS : TEXCOORD1;
                float part : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                float part = input.id.x;
                output.part = part;

                float t = _LifeEnd;
                float seed = frac(sin(part * 17.13 + 2.8) * 4375.3);
                float level = frac(part * 0.381966);
                float age = max(0.0, t - part * 0.006);
                float grow = 1.0 - exp(-age * 12.0);
                float spin = part * 2.399963 + age * (1.7 + seed);

                float3 up = normalize(_ImpactUp.xyz);
                float3 depth = float3(1, 0, 0) - up * up.x;
                if (dot(depth, depth) < 0.01)
                {
                    depth = float3(0, 0, 1) - up * up.z;
                }
                depth = normalize(depth);
                float3 across = cross(depth, up);

                float vertical = 1.0 - 2.0 * (part + 0.5) / 12.0;
                float ring = sqrt(max(0.0, 1.0 - vertical * vertical));
                float3 direction = up * vertical + depth * cos(spin) * ring + across * sin(spin) * ring;
                float radial = grow * (0.67 + seed * 0.26) + age * 0.12;
                float3 center = direction * radial + up * smoothstep(0.30, 0.95, age) * 0.32;

                float sizeScale = _EffectSize * (0.35 + 0.65 * _LifeStart);
                center *= sizeScale;

                float3 positionVS = TransformWorldToView(TransformObjectToWorld(ToUnity(center)));
                float width = (0.20 + grow * 0.95) * (0.85 + seed * 0.25) * (1.0 - smoothstep(0.65, 1.0, age) * 0.22);
                float scale = length(float3(UNITY_MATRIX_M[0].y, UNITY_MATRIX_M[1].y, UNITY_MATRIX_M[2].y));
                positionVS.xy += (input.uv - 0.5) * float2(width, width * (1.05 + level * 0.2)) * sizeScale * scale;

                output.lightVS = normalize(TransformWorldToViewDir(float3(0.55, 0.8, -0.45)));
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float t = _LifeEnd;
                float part = input.part;
                float3 tint = _EffectColor.rgb;

                float2 q = input.uv * 2.0 - 1.0;
                float age = max(0.0, t - part * 0.006);
                float seed = frac(part * 0.618034);
                float turn = age * (1.7 + seed) + part * 2.4;
                float cosTurn = cos(turn);
                float sinTurn = sin(turn);
                q = float2(cosTurn * q.x + sinTurn * q.y, -sinTurn * q.x + cosTurn * q.y);

                float3 density = NoiseGradient(q * 3.2 + float2(seed * 17.0, -age * 2.3));
                float fine = Noise2(q * 7.0 + density.x * 1.4 + seed * 13.0);
                float n0 = density.x * 0.76 + fine * 0.24;
                float d = length(q) + (n0 - 0.5) * 0.35;
                float2 optics = SmokeOptics(q, density.yz * 3.2, n0, input.lightVS);
                float burnout = smoothstep(0.40 + seed * 0.12, 0.96, age);

                float mask = (1.0 - smoothstep(0.79, 0.94, d))
                    * smoothstep(0.18 + burnout * 0.55, 0.40 + burnout * 0.5, n0 + (1.0 - d) * 0.50);
                float light = 0.20 + n0 * 0.55 + (1.0 - d) * 0.15 + optics.x * 0.16 - age * 0.13;
                float fade = smoothstep(0.0, 0.055, age) * (1.0 - smoothstep(0.65 + seed * 0.08, 0.97, age)) * 0.82;

                clip(mask * fade - 0.006);

                float3 c = lerp(tint * float3(0.50, 0.18, 0.07), tint * 1.08, ToonStep(0.46, light));
                c = lerp(c, float3(1.0, 0.92, 0.58), ToonStep(0.68, light));
                return float4(c, mask * fade);
            }
            ENDHLSL
        }
    }
}
