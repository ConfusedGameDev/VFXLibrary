Shader "ConfusedGameDev/Vfx/DarkchainDetonation BlastInk"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+4" }

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

            #define VFX_VARIANT 14
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "DarkchainDetonationCommon.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 burst : TEXCOORD1;
                float4 shape : TEXCOORD2;
                float4 strength : TEXCOORD3;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float seed : TEXCOORD1;
                float strength : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float t = _EffectTime;
                if (t < 3.650000 || t >= 4.950000)
                {
                    return output;
                }

                float b = max(0.0, t - DC_burst);
                float u = input.uv.y;
                float4 burst = input.burst;
                float4 shape = input.shape;
                output.uv = input.uv;
                output.seed = burst.w;
                output.strength = input.strength.x;
                float shrink = 0.45 + 0.55 * _JetFade;
                float stretch = 1.0 + 0.16 * smoothstep(0.0, 0.035, b);
                float head = _BlastRadius * lerp(0.84, 1.0, burst.w) + _JetTravel;
                float jetLength = min(shape.x * stretch, head - 0.12) * shrink;
                float3 axis = burst.xyz;
                float3 side = normalize(cross(axis, abs(axis.y) > 0.9 ? float3(1.0, 0.0, 0.0) : float3(0.0, 1.0, 0.0)));
                float3 up = cross(side, axis);
                float bend = sin(u * 3.14159265);
                float wave = u * 8.0 - b * 38.0 + shape.z;
                float3 p = axis * (head - (1.0 - u) * jetLength) + side * sin(wave) * bend * (0.045 + burst.w * 0.045) * shrink + up * sin(wave * 0.67 + shape.w) * bend * 0.035 * shrink + float3(0.0, DC_centerY, 0.0);
                float3 positionVS = DcView(p);
                float2 direction = SourceDirToView(axis).xy;
                float2 screenSide = normalize(float2(-direction.y, direction.x) + float2(0.00001, 0.0));
                float profile = pow(max(0.0, sin(u * 3.14159265)), 0.65) * (1.0 - u * 0.72);
                positionVS.xy += screenSide * input.positionOS.x * shape.y * profile * shrink * ViewScale();
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float t = _EffectTime - DC_burst;
                float u = input.uv.y;
                float q = (input.uv.x - 0.5) * 2.0;
                float flash = 1.0 - smoothstep(0.006, 0.035, t);
                float life = _JetFade;
                float flowNoise = Fbm(float2(u * 13.0 - t * 30.0, input.seed * 19.0));
                float edgeLimit = 0.78 + flowNoise * 0.20;
                float coverage = 1.0 - smoothstep(edgeLimit - 0.15, edgeLimit, abs(q));
                float slit = (1.0 - smoothstep(0.025, 0.10, abs(q + 0.24))) * smoothstep(0.48, 0.76, flowNoise) * smoothstep(0.025, 0.08, t);
                float alpha = coverage * (1.0 - slit * 0.82) * life * smoothstep(0.0, 0.055, u) * input.strength;
                clip(alpha - 0.003);

                float3 ink = float3(0.0003, 0.0001, 0.0007) + _EffectColor.rgb * (0.001 + flowNoise * 0.002);
                return float4(ink, saturate(alpha));
            }
            ENDHLSL
        }
    }
}
