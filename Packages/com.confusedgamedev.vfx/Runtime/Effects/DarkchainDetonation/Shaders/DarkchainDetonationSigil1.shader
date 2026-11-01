Shader "ConfusedGameDev/Vfx/DarkchainDetonation Sigil1"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+1" }

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
            #include "DarkchainDetonationGlyphs.hlsl"

            // The source's line(): core and glow of a distance. aa comes in, so it can run under any branch.
            float2 Stroke(float d, float width, float aa)
            {
                float reach = abs(d);
                return float2(1.0 - smoothstep(width, width + aa, reach), exp(-pow(abs(reach / (width * 3.4 + aa * 1.5)), 1.5)));
            }

            float2 SegmentInk(float2 p, float2 a, float2 b, float width, float aa)
            {
                float2 v = b - a;
                return Stroke(length(p - a - v * saturate(dot(p - a, v) / max(dot(v, v), 0.000001))), width, aa);
            }

            float2 MagicLetter(float2 p, float glyph, float aa)
            {
                float2 ink = float2(0.0, 0.0);
                int first = (int)glyph * 8;
                for (int i = 0; i < 8; i++)
                {
                    float4 stroke = Glyphs[first + i];
                    ink = max(ink, SegmentInk(p, stroke.xy, stroke.zw, 0.065, aa));
                }
                return ink;
            }

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 disk : TEXCOORD0;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float t = _EffectTime;
                if (t < 0.000000 || t >= 4.250000)
                {
                    return output;
                }

                #define TIER 1.0
                output.disk = input.positionOS.xy;
                float q = saturate(t / DC_chainStart);
                float pop = 1.0 - pow(abs(1.0 - q), 3.0) + sin(q * 3.14159265) * 0.18;
                float radius = lerp(DC_lowerRadius, DC_upperRadius, TIER) * pop;
                float3 p = float3(input.positionOS.x * radius, DC_baseY + TIER * DC_height, input.positionOS.y * radius);
                output.positionCS = TransformWViewToHClip(DcView(p));
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                #define TIER 1.0
                float2 disk = input.disk;
                float r = length(disk);
                float t = _EffectTime;
                float a = atan2(disk.y, disk.x);
                float turn = t * 0.44 * (TIER * 2.0 - 1.0);
                float aa = max(fwidth(r), 0.001);
                float2 edge = Stroke(r - 0.965, 0.0035, aa) + Stroke(r - 0.935, 0.0025, aa) * 0.8;
                float2 frame = Stroke(r - 0.84, 0.0025, aa);
                float2 hub = Stroke(r - 0.23, 0.0025, aa) + Stroke(r - 0.205, 0.0018, aa) * 0.7;
                float2 glyphs = float2(0.0, 0.0);
                float2 ornament = Stroke(r - 0.30, 0.0015, aa) + Stroke(r - 0.545, 0.0015, aa) + Stroke(r - 0.615, 0.0015, aa);
                for (int i = 0; i < 3; i++)
                {
                    float angle = 1.57079633 + i * TAU / 3.0;
                    float next = angle + TAU / 3.0;
                    float2 axis = float2(cos(angle), sin(angle));
                    float2 other = float2(cos(next), sin(next));
                    float2 corner = axis * 0.84;
                    float2 node = axis * 0.42;
                    frame = max(frame, SegmentInk(disk, corner, other * 0.84, 0.0025, aa));
                    frame = max(frame, SegmentInk(disk, axis * 0.23, corner, 0.002, aa));
                    float around = length(disk - corner);
                    frame = max(frame, (Stroke(around - 0.34, 0.002, aa) + Stroke(around - 0.395, 0.002, aa)) * (1.0 - smoothstep(0.838, 0.845, r)));
                    float small = length(disk - node);
                    hub = max(hub, Stroke(small - 0.115, 0.003, aa));
                    ornament = max(ornament, Stroke(small - 0.095, 0.0015, aa));
                    float ticksAround = atan2(disk.y - corner.y, disk.x - corner.x);
                    ornament = max(ornament, Stroke(sin(ticksAround * 24.0), 0.07, aa * 24.0) * smoothstep(0.348, 0.353, around) * (1.0 - smoothstep(0.381, 0.387, around)) * (1.0 - smoothstep(0.838, 0.845, r)));
                    float2 q = Spin(disk - node, angle + turn);
                    float2 symbol = Stroke(length(q - float2(0.012, 0.0)) - 0.035, 0.004, aa) * (1.0 - smoothstep(0.05, 0.055, q.x));
                    symbol = max(symbol, SegmentInk(q, float2(-0.018, -0.025), float2(-0.05, -0.065), 0.004, aa));
                    symbol = max(symbol, SegmentInk(q, float2(-0.01, 0.03), float2(-0.045, 0.065), 0.004, aa));
                    symbol = max(symbol, SegmentInk(q, float2(0.04, 0.0), float2(0.073, 0.0), 0.004, aa));
                    glyphs = max(glyphs, symbol);
                    hub = max(hub, SegmentInk(disk, -axis * 0.195, axis * 0.195, 0.0018, aa));
                }

                // Wrapped before the lookup, so rotation cannot give a negative glyph.
                float letterPosition = frac((a + turn * 0.35) / TAU + 0.5) * 60.0;
                float letterIndex = floor(letterPosition);
                float glyph = Mod(letterIndex * 7.0 + floor(letterIndex / 24.0) * 5.0 + TIER * 11.0, 24.0);
                float2 runes = MagicLetter(float2((frac(letterPosition) - 0.5) * 2.0, (r - 0.885) / 0.035), glyph, aa * 28.0) * step(abs(r - 0.885), 0.045);
                float2 ticks = Stroke(sin(a * 48.0), 0.08, aa * 48.0) * smoothstep(0.242, 0.245, r) * (1.0 - smoothstep(0.258, 0.261, r));
                for (int j = 0; j < 6; j++)
                {
                    float angle6 = (j + 0.5) * TAU / 6.0;
                    float2 axis6 = float2(cos(angle6), sin(angle6));
                    float2 side6 = float2(-axis6.y, axis6.x);
                    float2 local = float2(dot(disk, axis6) - 0.63, dot(disk, side6));
                    ornament = max(ornament, Stroke(abs(local.x) + abs(local.y) - 0.032, 0.0018, aa));
                    ornament = max(ornament, SegmentInk(disk, axis6 * 0.667, axis6 * 0.79, 0.0014, aa));
                    ornament = max(ornament, Stroke(length(disk - axis6 * 0.79) - 0.012, 0.0017, aa));
                }

                float innerPosition = ((a - turn * 0.35) / TAU + 0.5) * 48.0;
                float innerIndex = floor(innerPosition);
                float2 script = MagicLetter(float2((frac(innerPosition) - 0.5) * 2.0, (r - 0.579) / 0.019), Mod(innerIndex * 11.0 + floor(innerIndex / 24.0) * 7.0 + TIER * 5.0 + 240.0, 24.0), aa * 52.0) * step(abs(r - 0.579), 0.027);
                ornament = max(ornament, script * 0.8);
                float2 ink = edge * 0.8 + frame * 0.60 + hub * 0.65 + glyphs * 0.80 + runes * 0.42 + (ticks * 0.35 + ornament * 0.45) * min(_EffectDetail, 1.25);
                float life = smoothstep(0.0, 0.18, t) * (1.0 - smoothstep(DC_burst + 0.08, DC_burst + 0.60, t)) * smoothstep(-0.04, 0.12, t / 0.35 - frac(a / TAU + 0.5) * 0.35);
                float dim = 1.0 - smoothstep(DC_orbStart, DC_orbStart + 0.35, t) * 0.35;
                float core = smoothstep(0.08, 0.30, ink.x);
                float halo = saturate(ink.y * 0.8 - ink.x * 0.45) * dim;
                float alpha = max(core, halo * 0.85) * life;
                clip(1.0 - r);
                clip(alpha - 0.002);
                float hue = smoothstep(-0.75, 0.75, dot(disk, float2(0.8, 0.6)));
                float3 black = float3(0.00012, 0.00008, 0.0002);
                float3 corona = lerp(float3(1.0, 0.002, 0.035), _EffectColor.rgb, hue) * (0.90 + _Beat * 0.14);
                return float4(lerp(corona, black, core), alpha);
            }
            ENDHLSL
        }
    }
}
