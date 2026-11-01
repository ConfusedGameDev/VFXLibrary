Shader "ConfusedGameDev/Vfx/DarkchainDetonation OrbArcs"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+4" }

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

            #define VFX_VARIANT 14
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "DarkchainDetonationCommon.hlsl"

            float3 ArcPoint(float u, float event, float slot, float fork)
            {
                float seed = DC_SEED + slot * 19.0 + event * 13.0;
                float longitude = slot * TAU / 6.0 + Hash(float2(seed, 1.0)) * 0.75;
                float latitude = (Hash(float2(seed, 2.0)) - 0.5) * 1.65;
                float3 axis = float3(cos(longitude) * cos(latitude), sin(latitude), sin(longitude) * cos(latitude));
                float3 side = normalize(cross(axis, float3(0.0, 1.0, 0.0)));
                float3 up = cross(side, axis);
                float tilt = Hash(float2(seed, 3.0)) * TAU;
                float3 along = side * cos(tilt) + up * sin(tilt);
                float3 across = cross(along, axis);
                float v = lerp(u, 0.5 + u * 0.36, fork);
                float k = v * 12.0;
                float index = floor(k);
                float jitter = lerp(Hash(float2(seed, index)), Hash(float2(seed, index + 1.0)), frac(k)) - 0.5;
                return normalize(axis + along * ((v - 0.5) * 1.40) + across * (jitter * 0.32 * sin(v * 3.14159265) + fork * u * 0.46));
            }

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 arc : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float alpha : TEXCOORD1;
                float flash : TEXCOORD2;
                float fork : TEXCOORD3;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float t = _EffectTime;
                if (t < 1.150000 || t >= 3.810000)
                {
                    return output;
                }

                output.uv = input.uv;
                float4 state = ArcState(input.arc.x);
                output.alpha = state.x;
                output.flash = state.z;
                output.fork = input.arc.y;
                if (output.alpha < 0.001)
                {
                    return output;
                }

                float b = max(0.0, t - DC_burst);
                float radius = _OrbRadius * (1.035 + smoothstep(0.0, 0.16, b) * 0.58);
                float3 center = float3(0.0, DC_centerY, 0.0);
                float u = input.uv.x;
                float3 positionVS = DcView(ArcPoint(u, state.y, input.arc.x, input.arc.y) * radius + center);
                float3 ahead = DcView(ArcPoint(min(1.0, u + 0.005), state.y, input.arc.x, input.arc.y) * radius + center);
                float3 behind = DcView(ArcPoint(max(0.0, u - 0.005), state.y, input.arc.x, input.arc.y) * radius + center);
                float2 tangent = normalize(ahead.xy - behind.xy + float2(0.00001, 0.0));
                float width = lerp(0.052, 0.024, input.arc.y) * (0.8 + state.z * 0.7);
                positionVS.xy += float2(-tangent.y, tangent.x) * input.positionOS.y * width * ViewScale();
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float q = abs(input.uv.y * 2.0 - 1.0);
                float tip = smoothstep(0.0, 0.06, input.uv.x) * (1.0 - smoothstep(0.83, 1.0, input.uv.x));
                float alpha = (1.0 - smoothstep(0.42, 1.0, q)) * tip * input.alpha * lerp(1.0, 0.7, input.fork);
                clip(alpha - 0.003);
                float3 color = lerp(_EffectColor.rgb, float3(0.94, 0.83, 1.0), (0.46 + input.flash * 0.4) * (1.0 - smoothstep(0.12, 0.65, q)));
                return float4(color * (1.0 + input.flash * 0.35), saturate(alpha));
            }
            ENDHLSL
        }
    }
}
