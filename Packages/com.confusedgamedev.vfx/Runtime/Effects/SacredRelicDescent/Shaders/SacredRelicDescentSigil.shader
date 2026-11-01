Shader "ConfusedGameDev/Vfx/SacredRelicDescent Sigil"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+1" }

        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
            Blend One One
            ZWrite Off
            Cull Off

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #define VFX_VARIANT 18
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "SacredRelicDescentCommon.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                if (_EffectTime >= 12.2)
                {
                    return output;
                }

                output.uv = input.uv;
                output.positionCS = TransformWViewToHClip(SourceToView(RelicFloor(input.positionOS, 0.02)));
                return output;
            }

            #define SIGIL_TAU 6.283185307
            #define SIGIL_PI 3.141592654

            float2 SigilTurn(float2 p, float a)
            {
                float c = cos(a);
                float s = sin(a);
                return float2(c * p.x - s * p.y, s * p.x + c * p.y);
            }

            float SigilSegment(float2 p, float2 a, float2 b)
            {
                float2 v = b - a;
                return length(p - a - v * saturate(dot(p - a, v) / max(dot(v, v), 0.000001)));
            }

            float SigilTrace(float2 p, float2 a, float2 b, float progress)
            {
                return SigilSegment(p, a, lerp(a, b, saturate(progress)));
            }

            float SigilInk(float d, float w, float pixel)
            {
                return 1.0 - smoothstep(w, w + pixel, d);
            }

            float SigilStroke(float d, float w, float pixel)
            {
                return SigilInk(d, w, pixel) + 0.09 * exp(-d * d / 0.00005);
            }

            float2 SigilPolar(float a, float r)
            {
                return float2(cos(a), sin(a)) * r;
            }

            float SigilGlyph(float2 q, float id)
            {
                float k = Mod(id, 8.0);
                float d = SigilSegment(q, float2(-0.15, -0.72), float2(-0.15, 0.72));
                if (k < 1.0)
                {
                    d = min(d, SigilSegment(q, float2(-0.15, 0.65), float2(0.60, 0.26)));
                    d = min(d, SigilSegment(q, float2(0.60, 0.26), float2(-0.15, -0.05)));
                    d = min(d, SigilSegment(q, float2(-0.52, -0.25), float2(0.4, -0.25)));
                }
                else if (k < 2.0)
                {
                    d = min(d, SigilSegment(q, float2(-0.6, 0.35), float2(0.55, 0.35)));
                    d = min(d, SigilSegment(q, float2(0.55, 0.35), float2(0.2, -0.55)));
                    d = min(d, SigilSegment(q, float2(-0.6, -0.4), float2(0.2, -0.55)));
                }
                else if (k < 3.0)
                {
                    d = min(d, SigilSegment(q, float2(-0.65, 0.5), float2(0.5, -0.45)));
                    d = min(d, SigilSegment(q, float2(-0.65, -0.45), float2(0.5, 0.5)));
                }
                else if (k < 4.0)
                {
                    d = min(d, abs(length(q - float2(0.13, 0.25)) - 0.43));
                    d = min(d, SigilSegment(q, float2(-0.55, -0.6), float2(0.50, -0.6)));
                }
                else if (k < 5.0)
                {
                    d = min(d, SigilSegment(q, float2(-0.6, 0.6), float2(0.5, 0.6)));
                    d = min(d, SigilSegment(q, float2(0.5, 0.6), float2(0.5, -0.1)));
                    d = min(d, SigilSegment(q, float2(-0.15, -0.1), float2(0.5, -0.1)));
                }
                else if (k < 6.0)
                {
                    d = min(d, SigilSegment(q, float2(-0.62, 0.15), float2(0.52, -0.3)));
                    d = min(d, SigilSegment(q, float2(0.52, -0.3), float2(0.52, 0.65)));
                    d = min(d, length(q - float2(-0.52, -0.6)) - 0.08);
                }
                else if (k < 7.0)
                {
                    d = min(d, SigilSegment(q, float2(-0.62, 0.25), float2(0.10, 0.7)));
                    d = min(d, SigilSegment(q, float2(0.10, 0.7), float2(0.62, 0.25)));
                    d = min(d, SigilSegment(q, float2(-0.55, -0.35), float2(0.5, -0.35)));
                }
                else
                {
                    d = min(d, abs(length(q - float2(0.0, -0.15)) - 0.48));
                    d = min(d, SigilSegment(q, float2(-0.5, 0.65), float2(0.5, 0.65)));
                }
                return max(0.0, d);
            }

            float SigilEmblem(float2 q, float id)
            {
                float r = length(q);
                float a = atan2(q.y, q.x);
                float d = 10.0;
                if (id < 0.5)
                {
                    d = abs(r - 0.38);
                    float t = Mod(a + SIGIL_PI / 12.0, SIGIL_TAU / 12.0) - SIGIL_PI / 12.0;
                    float2 v = float2(cos(t), sin(t)) * r;
                    d = min(d, SigilSegment(v, float2(0.53, 0.0), float2(0.87, 0.0)));
                }
                else if (id < 1.5)
                {
                    float t = Mod(a + SIGIL_PI / 8.0, SIGIL_TAU / 8.0) - SIGIL_PI / 8.0;
                    float2 v = SigilPolar(abs(t), r);
                    d = SigilSegment(v, float2(0.96, 0.0), SigilPolar(SIGIL_PI / 8.0, 0.34));
                    d = min(d, abs(r - 0.18));
                }
                else if (id < 2.5)
                {
                    d = min(SigilSegment(q, float2(0.0, 0.95), float2(-0.46, -0.08)), SigilSegment(q, float2(0.0, 0.95), float2(0.46, -0.08)));
                    if (q.y < -0.08)
                    {
                        d = min(d, abs(length(q - float2(0.0, -0.08)) - 0.46));
                    }

                    d = min(d, SigilSegment(q, float2(-0.14, -0.05), float2(-0.14, -0.31)));
                }
                else
                {
                    d = SigilSegment(q, float2(0.0, -0.85), float2(0.0, 0.38));
                    d = min(d, SigilSegment(q, float2(0.0, -0.02), float2(-0.65, 0.18)));
                    d = min(d, SigilSegment(q, float2(-0.65, 0.18), float2(-0.72, 0.68)));
                    d = min(d, SigilSegment(q, float2(-0.72, 0.68), float2(-0.16, 0.5)));
                    d = min(d, SigilSegment(q, float2(-0.16, 0.5), float2(0.0, -0.02)));
                    d = min(d, SigilSegment(q, float2(0.0, 0.22), float2(0.66, 0.38)));
                    d = min(d, SigilSegment(q, float2(0.66, 0.38), float2(0.72, 0.86)));
                    d = min(d, SigilSegment(q, float2(0.72, 0.86), float2(0.16, 0.7)));
                    d = min(d, SigilSegment(q, float2(0.16, 0.7), float2(0.0, 0.22)));
                }
                return d;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 p = input.uv * 2.0 - 1.0;
                float r = length(p);
                float a = atan2(p.y, p.x);
                float pixel = max(length(fwidth(p)) * 0.65, 0.00035);
                float time = _EffectTime;
                float fine = (1.0 - smoothstep(0.006, 0.025, pixel)) * min(_EffectDetail, 1.0);
                float extra = saturate(_EffectDetail - 1.0);
                float form = smoothstep(0.0, 0.3, time);
                float sweep = smoothstep(-0.025, 0.025, form * SIGIL_TAU - Mod(a + SIGIL_PI * 0.5 + SIGIL_TAU, SIGIL_TAU)) * step(0.0001, form);
                float frameD = min(abs(r - 0.94), abs(r - 0.905));
                float frameInk = SigilStroke(frameD, 0.0022, pixel) * sweep;
                float tickAngle = Mod(a + SIGIL_PI / 72.0, SIGIL_TAU / 72.0) - SIGIL_PI / 72.0;
                float2 tick = SigilPolar(tickAngle, r);
                frameInk = max(frameInk, SigilInk(SigilSegment(tick, float2(0.915, 0.0), float2(0.929, 0.0)), 0.0012, pixel) * fine * sweep * 0.60);

                // Coordinates rotate opposite the pattern.
                float2 op = SigilTurn(p, time * SIGIL_PI / 45.0);
                float oa = Mod(atan2(op.y, op.x) + SIGIL_TAU, SIGIL_TAU);
                float slot = floor(oa / (SIGIL_TAU / 48.0) + 0.5);
                float localAngle = Mod(oa + SIGIL_PI / 48.0, SIGIL_TAU / 48.0) - SIGIL_PI / 48.0;
                float2 oq = float2(sin(localAngle) * r, cos(localAngle) * r - 0.846);
                float outerD;
                if (Mod(slot, 4.0) < 0.5)
                {
                    outerD = min(abs(length(oq) - 0.026), SigilEmblem(oq / 0.019, Mod(floor(slot / 4.0), 4.0)) * 0.019);
                }
                else
                {
                    outerD = SigilGlyph(oq / float2(0.023, 0.035), slot + floor(slot / 4.0)) * 0.023;
                }

                float outerReveal = smoothstep(0.15 + slot / 48.0 * 0.42, 0.30 + slot / 48.0 * 0.45, time);
                float outerInk = SigilStroke(outerD, 0.00125, pixel) * outerReveal * fine;
                outerInk = max(outerInk, SigilInk(min(abs(r - 0.793), abs(r - 0.891)), 0.0014, pixel) * smoothstep(0.15, 0.65, time) * 0.55);

                float2 ip = SigilTurn(p, -time * SIGIL_PI / 30.0);
                float ia = Mod(atan2(ip.y, ip.x) + SIGIL_TAU, SIGIL_TAU);
                float islot = floor(ia / (SIGIL_TAU / 32.0) + 0.5);
                float ilocal = Mod(ia + SIGIL_PI / 32.0, SIGIL_TAU / 32.0) - SIGIL_PI / 32.0;
                float2 iq = float2(sin(ilocal) * r, cos(ilocal) * r - 0.508);
                float innerReveal = smoothstep(0.20 + islot / 32.0 * 0.35, 0.35 + islot / 32.0 * 0.40, time);
                float innerInk = SigilStroke(SigilGlyph(iq / float2(0.021, 0.028), islot * 3.0 + 2.0) * 0.021, 0.0012, pixel) * fine * innerReveal;
                innerInk = max(innerInk, SigilInk(min(abs(r - 0.464), abs(r - 0.552)), 0.0015, pixel) * smoothstep(0.15, 0.70, time) * 0.65);

                float2 bp = SigilTurn(p, -time * SIGIL_PI / 60.0);
                float ba = atan2(bp.y, bp.x);
                float bid = Mod(floor((ba + SIGIL_PI * 0.25) / (SIGIL_PI * 0.5)) + 4.0, 4.0);
                float2 bq = SigilTurn(bp, -bid * SIGIL_PI * 0.5) - float2(0.637, 0.0);
                float br = length(bq);
                float badgeReveal = smoothstep(0.55 + bid * 0.055, 0.82 + bid * 0.06, time);
                float badgeD = min(abs(br - 0.106), abs(br - 0.088));
                float badge = SigilStroke(badgeD, 0.0022, pixel);
                badge = max(badge, SigilStroke(SigilEmblem(float2(-bq.y, bq.x) / 0.071, bid) * 0.071, 0.0017, pixel));
                badge *= badgeReveal;
                float clearance = smoothstep(0.108, 0.118, br);

                float2 gp = SigilTurn(p, time * SIGIL_PI / 90.0);
                float webD = 10.0;
                for (int i = 0; i < 12; i++)
                {
                    float fi = float(i);
                    float theta = fi * SIGIL_TAU / 12.0;
                    float2 v = SigilPolar(theta, 0.774);
                    float grow = saturate((time - (0.15 + fi * 0.018)) / 0.36);
                    webD = min(webD, SigilTrace(gp, v, SigilPolar(theta + SIGIL_TAU / 12.0, 0.774), grow));
                    webD = min(webD, SigilTrace(gp, v, SigilPolar(theta + SIGIL_TAU * 4.0 / 12.0, 0.774), grow));
                    webD = min(webD, SigilTrace(gp, v, SigilPolar(theta + SIGIL_TAU * 5.0 / 12.0, 0.774), grow));
                }

                float web = SigilStroke(webD, 0.00095, pixel) * smoothstep(0.15, 0.22, time) * smoothstep(0.39, 0.41, r) * fine * (1.0 - smoothstep(0.451, 0.464, r) * (1.0 - smoothstep(0.552, 0.565, r)));

                // Central diamonds and concentric sun stay anchored to the contact point.
                float coreD = min(abs(r - 0.397), min(abs(r - 0.34), abs(r - 0.178)));
                float diamond = abs(abs(p.x) + abs(p.y) - 0.31) * 0.7071;
                float2 cp = SigilTurn(p, SIGIL_PI * 0.25);
                diamond = min(diamond, abs(abs(cp.x) + abs(cp.y) - 0.31) * 0.7071);
                coreD = min(coreD, diamond);
                coreD = min(coreD, SigilEmblem(p / 0.115, 0.0) * 0.115);
                float core = SigilStroke(coreD, 0.0018, pixel) * sweep;
                float pulse = 1.0 + 0.25 * smoothstep(0.0, 0.08, _PulseAge) * (1.0 - smoothstep(0.08, 0.35, _PulseAge));
                float fade = (1.0 - smoothstep(11.35, 12.2, time)) * _Cancel;
                float sustain = lerp(1.0, 0.44, smoothstep(1.4, 2.9, time));
                float major = max(frameInk * 0.34, max(core * 0.32 * pulse, badge * 0.40 * pulse));
                float minor = max(outerInk * 0.30, innerInk * 0.27) * pulse;
                float alpha = max(major, max(minor, web * (0.115 + extra * 0.04)) * clearance) * fade * sustain;
                float3 color = lerp(_EffectColor.rgb, float3(1.0, 0.985, 0.92), clamp(max(core, badge) * 0.55, 0.0, 0.55));
                clip(alpha - 0.0005);
                return Magic(color, alpha);
            }
            ENDHLSL
        }
    }
}
