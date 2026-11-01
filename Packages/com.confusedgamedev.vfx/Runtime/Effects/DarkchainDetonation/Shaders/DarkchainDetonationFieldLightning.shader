Shader "ConfusedGameDev/Vfx/DarkchainDetonation FieldLightning"
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

            float3 FieldPoint(float u, float event, float slot, float fork)
            {
                float seed = DC_SEED + slot * 31.7 + event * 17.3;
                float angle = (slot + 0.5) * TAU / DC_fieldArcs + (Hash(float2(seed, 1.0)) - 0.5) * 0.36;
                if (_EffectTime >= DC_burst)
                {
                    float latitude = 1.0 - 2.0 * (slot + 0.5) / DC_fieldArcs;
                    float longitude = slot * 2.39996323;
                    float ring = sqrt(1.0 - latitude * latitude);
                    float3 direction = float3(cos(longitude) * ring, latitude, sin(longitude) * ring);
                    float3 side = normalize(cross(direction, float3(0.0, 1.0, 0.0)));
                    float3 up = cross(side, direction);
                    float v = lerp(u, 0.38 + u * 0.52, fork);
                    float k = v * 6.0;
                    float j = floor(k);
                    float age = max(0.0, _EffectTime - DC_burst);
                    float jitter = lerp(Hash(float2(seed, j)), Hash(float2(seed, j + 1.0)), frac(k)) - 0.5;
                    float far = 3.1 + Hash(float2(slot, DC_SEED)) * 2.05;
                    float reach = lerp(1.6, far, 1.0 - pow(abs(1.0 - saturate(age / 0.10)), 3.0));
                    float tilt = Hash(float2(seed, 8.0)) * TAU;
                    float3 along = normalize(side * cos(tilt) + up * sin(tilt) + direction * 0.25);
                    float3 across = cross(direction, along);
                    float span = 0.48 + Hash(float2(seed, 9.0)) * 0.62;
                    return float3(0.0, DC_centerY, 0.0) + direction * reach + along * ((v - 0.5) * span) + across * (jitter * 0.24 + fork * u * 0.22);
                }

                float v2 = lerp(u, 0.35 + u * 0.38, fork);
                float k2 = v2 * 20.0;
                float j2 = floor(k2);
                float jag = lerp(Hash(float2(seed, j2)), Hash(float2(seed, j2 + 1.0)), frac(k2)) - 0.5;
                float bend = sin(v2 * 3.14159265);
                float r = DC_lowerRadius * lerp(sqrt(0.015 + Hash(float2(seed, 2.0)) * 0.88), sqrt(0.015 + Hash(float2(seed, 3.0)) * 0.88), v2);
                angle += v2 * (Hash(float2(seed, 4.0)) - 0.5) * 1.1 + jag * 0.38 * bend + fork * u * 0.38;
                return float3(cos(angle) * r, DC_baseY + v2 * DC_height, sin(angle) * r);
            }

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 field : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float alpha : TEXCOORD1;
                float red : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float t = _EffectTime;
                if (t < 0.650000 || t >= 4.950000)
                {
                    return output;
                }

                output.uv = input.uv;
                float slot = input.field.x;
                float2 state = FieldState(slot);
                output.alpha = state.x;
                output.red = step(DC_burst, t) * step(0.5, Hash(float2(slot, DC_SEED + 47.0)));
                if (output.alpha < 0.001)
                {
                    return output;
                }

                float u = input.uv.x;
                float3 positionVS = DcView(FieldPoint(u, state.y, slot, input.field.y));
                float3 ahead = DcView(FieldPoint(min(1.0, u + 0.002), state.y, slot, input.field.y));
                float3 behind = DcView(FieldPoint(max(0.0, u - 0.002), state.y, slot, input.field.y));
                float2 tangent = Heading(ahead - behind, positionVS);
                float width = lerp(0.11, 0.055, input.field.y) * (0.85 + Hash(float2(slot, state.y)) * 0.35) * (1.0 + step(DC_burst, t) * 0.25);
                positionVS.xy += float2(-tangent.y, tangent.x) * input.positionOS.y * width * ViewScale();
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float q = abs(input.uv.y * 2.0 - 1.0);
                float tip = lerp(0.7, 1.0, smoothstep(0.0, 0.08, input.uv.x) * (1.0 - smoothstep(0.92, 1.0, input.uv.x)));
                float core = 1.0 - smoothstep(0.28, 0.36, q);
                float edge = exp(-Sq((q - 0.43) * 15.0));
                float corona = exp(-q * q * 3.5);
                float alpha = max(core, max(edge, corona * 0.55)) * input.alpha * tip;
                clip(alpha - 0.005);
                float3 coronaColor = lerp(lerp(_EffectColor.rgb, float3(0.67, 0.12, 1.0), 0.25), float3(0.35, 0.0007, 0.01225), input.red);
                float3 color = lerp(coronaColor * (0.45 + edge * 0.95), float3(0.0002, 0.0001, 0.0004), core);
                return float4(color, saturate(alpha));
            }
            ENDHLSL
        }
    }
}
