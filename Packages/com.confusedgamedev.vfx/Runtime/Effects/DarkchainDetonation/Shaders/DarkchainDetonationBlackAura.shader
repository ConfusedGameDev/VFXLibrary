Shader "ConfusedGameDev/Vfx/DarkchainDetonation BlackAura"
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

            #define VFX_VARIANT 14
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "DarkchainDetonationCommon.hlsl"

            float3 InkBrush(float2 uv, float seed, float travel)
            {
                float u = uv.x;
                float q = uv.y * 2.0 - 1.0;
                float grain = Noise2(float2(u * 17.0 - travel, seed * 27.0));
                float profile = pow(max(0.0, sin(u * 3.14159265)), 0.82) * (0.84 - u * 0.18);
                float edge = profile * (0.91 + grain * 0.07);
                float aa = max(fwidth(q) * 1.2, 0.012);
                float body = 1.0 - smoothstep(edge - aa, edge + aa, abs(q));
                float hairs = Noise2(float2(u * 2.0 - travel * 0.15, q * 31.0 + seed * 39.0));
                float dry = smoothstep(0.42, 0.72, hairs) * smoothstep(0.04, 0.28, u) * smoothstep(0.02, 0.20, abs(q));
                body *= 1.0 - dry * 0.08 * min(_EffectDetail, 1.0);
                float rim = (1.0 - smoothstep(0.012, 0.065, abs(q - edge * 0.88))) * smoothstep(0.36, 0.68, grain);
                return float3(body, dry, rim);
            }

            float InkProgress(float time, float start)
            {
                float q = (min(time, DC_burst) - start) / (DC_burst - start);
                return DC_inkPullLead * q + (1.0 - DC_inkPullLead) * pow(max(0.0, q), 2.0);
            }

            float InkTime(float progress, float start)
            {
                float a = 1.0 - DC_inkPullLead;
                float q = progress < 0.0 ? progress / DC_inkPullLead : (-DC_inkPullLead + sqrt(DC_inkPullLead * DC_inkPullLead + 4.0 * a * progress)) / (2.0 * a);
                return start + q * (DC_burst - start);
            }

            float3 InkPoint(float sampleTime, float4 seed, float start)
            {
                float q = saturate((sampleTime - start) / (DC_burst - start));
                float pull = saturate(InkProgress(sampleTime, start));
                float budget = lerp(DC_inkTurnsMin, DC_inkTurnsMax, seed.z);
                float turns = DC_inkLead * q + (budget - DC_inkLead) * q * q;
                float angle = seed.x * TAU + TAU * turns;
                float r = lerp(lerp(DC_inkMinRadius, DC_inkRadius, seed.w), DC_inkCoreRadius, pull);
                float baseLatitude = (seed.y * 2.0 - 1.0) * 0.96;
                float tilt = 0.2 + seed.w * 0.25;
                float latitude = baseLatitude * cos(tilt) + sqrt(1.0 - baseLatitude * baseLatitude) * sin(tilt) * sin(angle + seed.z * TAU);
                float side = sqrt(max(0.0, 1.0 - latitude * latitude));
                float3 direction = float3(cos(angle) * side, latitude, sin(angle) * side);
                float3 center = float3(0.0, DC_centerY, 0.0);
                float3 p = center + direction * r;
                return p + normalize(p - center) * (1.0 - exp(-max(0.0, sampleTime - DC_burst) * 18.0)) * 0.85;
            }

            // An open streak is a motion history: its tail is an earlier point of the same path.
            float3 InkTrail(float4 seed, float u, float y, float start, float span, float width, out float2 coreOffset)
            {
                float t = _EffectTime;
                float turnBudget = lerp(DC_inkTurnsMin, DC_inkTurnsMax, seed.z);
                float headQ = saturate((t - start) / (DC_burst - start));
                float headTurn = DC_inkLead * headQ + (turnBudget - DC_inkLead) * headQ * headQ;
                float tailTurn = max(0.0, headTurn - 0.30);
                float a = turnBudget - DC_inkLead;
                float tailQ = (-DC_inkLead + sqrt(DC_inkLead * DC_inkLead + 4.0 * a * tailTurn)) / (2.0 * a);
                float headProgress = InkProgress(t, start);
                float minimumProgress = DC_inkPullLead * tailQ + (1.0 - DC_inkPullLead) * tailQ * tailQ;
                float tailProgress = max(minimumProgress, headProgress - span * 0.75 * min(1.0, 0.85 / turnBudget));
                float progress = lerp(tailProgress, headProgress, u);
                float sampleTime = InkTime(progress, start) + max(0.0, t - DC_burst);
                float3 positionVS = DcView(InkPoint(sampleTime, seed, start));
                float3 next = DcView(InkPoint(sampleTime + 0.002, seed, start));
                float3 prior = DcView(InkPoint(sampleTime - 0.002, seed, start));
                float2 tangent = Heading(next - prior, positionVS);
                positionVS.xy += float2(-tangent.y, tangent.x) * y * width * ViewScale();
                float3 core = CoreView();
                coreOffset = (positionVS.xy - core.xy * (positionVS.z / core.z)) / (lerp(0.3, 1.45, Charge()) * ViewScale());
                return positionVS;
            }

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 stream : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 coreOffset : TEXCOORD1;
                float seed : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float t = _EffectTime;
                if (t < 0.320000 || t >= 3.890000)
                {
                    return output;
                }

                output.uv = input.uv;
                output.seed = input.stream.z;
                float2 coreOffset;
                float3 positionVS = InkTrail(input.stream, input.uv.x, input.positionOS.y, 0.32, DC_auraTrail, 0.065 + input.stream.w * 0.025, coreOffset);
                output.coreOffset = coreOffset;
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float t = _EffectTime;
                float3 brush = InkBrush(input.uv, input.seed, t * 0.6);
                float b = max(0.0, t - DC_burst);
                float life = smoothstep(0.32, 0.65, t) * (1.0 - smoothstep(0.04, 0.24, b)) * (0.60 + 0.40 * Charge());
                float alpha = brush.x * 0.98 * life * smoothstep(0.85, 1.1, length(input.coreOffset));
                clip(alpha - 0.003);
                float flash = step(DC_burst, t) * (1.0 - smoothstep(0.008, 0.065, b));
                float3 tint = lerp(float3(1.0, 0.003, 0.012), _EffectColor.rgb, smoothstep(0.25, 0.75, frac(input.seed * 3.17)));
                float pigment = smoothstep(0.16, 0.48, input.seed) * smoothstep(0.06, 0.78, input.uv.x);
                float3 ink = lerp(float3(0.00015, 0.0001, 0.0003), tint * 0.045, pigment);
                float3 edge = tint * brush.z * (0.035 + flash * 0.1) * min(_EffectDetail, 1.5);
                return float4(ink + edge, saturate(alpha));
            }
            ENDHLSL
        }
    }
}
