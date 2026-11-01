Shader "ConfusedGameDev/Vfx/ImpactFrame"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            Name "Impact Frame"
            ZTest Always
            ZWrite Off
            Cull Off
            Blend Off

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

            TEXTURE2D_X(_SubjectMask);

            float _HasSubject;
            float _Threshold;
            float _Softness;
            float _Intensity;
            float _Inverted;
            float _StrokeLength;
            float _InkDensity;
            float _Frame;
            float _BackgroundSuppression;
            float _StarSize;
            float _StarStrength;
            float2 _Center;
            float2 _Resolution;
            float2 _AttackDirection;
            float4 _Stars[4];
            float4 _ReverseStars;

            float ImpactHash(float n)
            {
                return frac(sin(n * 127.1 + 311.7) * 43758.5453);
            }

            float Luma(float2 uv)
            {
                float3 c = SAMPLE_TEXTURE2D_X_LOD(_BlitTexture, sampler_LinearClamp, saturate(uv), 0).rgb;
                return dot(max(c, 0.0), float3(0.2126, 0.7152, 0.0722));
            }

            float Classify(float l)
            {
                return _Softness <= 0.0 ? step(_Threshold, l) : smoothstep(_Threshold - _Softness * 0.5, _Threshold + _Softness * 0.5, l);
            }

            float Subject(float2 uv)
            {
                if (_HasSubject < 0.5 || any(uv < 0.0) || any(uv > 1.0))
                {
                    return 0.0;
                }

                return SAMPLE_TEXTURE2D_X_LOD(_SubjectMask, sampler_LinearClamp, uv, 0).r;
            }

            float Mark(float2 uv, float2 scale)
            {
                if (any(uv < 0.0) || any(uv > 1.0))
                {
                    return 0.0;
                }

                float l = Luma(uv);
                float focus = 1.0 - smoothstep(0.06, 0.34, length((uv - _Center) * scale));
                float light = Classify(l) * lerp(1.0, saturate(smoothstep(1.1, 2.8, l) + focus * 0.85), _BackgroundSuppression);
                return max(Subject(uv), light);
            }

            // Footprint-filtered fibers. footprint is the width of x across a pixel.
            float FiberNoise(float x, float footprint, float phase)
            {
                float cell = floor(x);
                float f = frac(x);
                f = f * f * (3.0 - 2.0 * f);
                float n = lerp(ImpactHash(cell + phase * 113.0), ImpactHash(cell + 1.0 + phase * 113.0), f);
                return lerp(n, 0.5, smoothstep(0.35, 1.0, footprint));
            }

            float BrushArm(float2 p, float2 pixel, float halfSpan, float phase, float inkWeight, float compact)
            {
                float u = abs(p.x) / max(halfSpan, 0.0001);
                float grain = FiberNoise(p.x * 240.0, pixel.x * 240.0, phase);
                float bundle = FiberNoise(p.x * 47.0, pixel.x * 47.0, phase + 7.0);
                float taper = pow(max(0.0, 1.0 - u * u), 1.7);
                float armThickness = lerp(0.03, 0.14, inkWeight) * compact;
                float heartThickness = lerp(0.035, 0.09, inkWeight) * compact;
                float halfWidth = halfSpan * (armThickness + heartThickness * exp(-u * 9.0)) * taper;
                float fringeWidth = halfSpan * lerp(0.07, 0.14, inkWeight) * compact * taper * (0.3 + 0.7 * grain) * (0.8 + 0.2 * bundle);
                float aa = max(pixel.y, 0.5 / max(1.0, min(_Resolution.x, _Resolution.y)));
                float across = abs(p.y);
                float solid = 1.0 - smoothstep(halfWidth * 0.55, halfWidth + aa, across);
                float fibers = (1.0 - smoothstep(halfWidth * 0.5, halfWidth + fringeWidth + aa, across)) * (0.65 + 0.35 * grain);
                float tip = 1.0 - smoothstep(0.82, 1.0, u);
                return max(solid, fibers) * tip;
            }

            float FourPoint(float2 p, float2 pixel, float span, float phase, float inkWeight, float compact)
            {
                float h = BrushArm(p, pixel, span * 0.5, phase, inkWeight, compact);
                float v = BrushArm(p.yx, pixel.yx, span * 0.5, phase + 17.0, inkWeight, compact);
                return 1.0 - (1.0 - h) * (1.0 - v);
            }

            float StarInkPatch(float2 p, float pixel, float span, float phase)
            {
                float r = length(p);
                float angle = r > 0.00001 ? atan2(p.y, p.x) : 0.0;
                float waves = 0.5 + 0.25 * sin(angle * 7.0 + phase) + 0.25 * sin(angle * 13.0 - phase);
                float fibers = 0.5 + 0.5 * sin(angle * 45.0 + sin(angle * 19.0) * 2.0 + phase);
                fibers = lerp(fibers, 0.5, smoothstep(0.35, 1.0, pixel / max(r, 0.00001) * 45.0));
                float reach = span * (0.44 + 0.36 * waves);
                float wash = 1.0 - smoothstep(span * 0.22, reach, r);
                float brush = 1.0 - smoothstep(span * 0.3, reach * (0.7 + 0.3 * fibers), r);
                float density = wash * 0.55 + brush * (0.45 + 0.65 * fibers);
                return 1.0 - exp(-density * 3.8);
            }

            // Authored terminal poses, in viewport-short-side units.
            float TerminalBlast(float2 p, float2 scale, bool shock)
            {
                float r = length(p);
                float a = r > 0.00001 ? atan2(p.y, p.x) : 0.0;
                float coreRadius = shock ? 0.4 : 0.275;
                float edge = coreRadius * (1.0 + 0.025 * sin(a * 3.0 + 0.7) + 0.018 * sin(a * 7.0 - 1.2));
                float aa = 1.2 / max(1.0, min(_Resolution.x, _Resolution.y));
                float core = 1.0 - smoothstep(edge - aa, edge + aa, r);
                float rays = 0.0;
                float expansion = shock ? 1.45 : 1.0;
                for (int i = 0; i < 8; i++)
                {
                    float seed = float(i);
                    float angle = seed * 0.785398 + 0.11 + (ImpactHash(seed + 37.0) - 0.5) * 0.55;
                    float2 axis = float2(cos(angle), sin(angle));
                    float along = dot(p, axis);
                    float across = abs(dot(p, float2(-axis.y, axis.x)));
                    float reach = (0.85 + 0.8 * ImpactHash(seed + 9.0)) * max(scale.x, scale.y) * expansion;
                    float width = (0.035 + 0.085 * ImpactHash(seed + 18.0)) * expansion;
                    float opening = lerp(0.2, 1.0, saturate(along / 0.8));
                    float halfWidth = width * opening * pow(saturate(1.0 - along / reach), 0.22);
                    float beam = (1.0 - smoothstep(halfWidth - aa, halfWidth + aa, across)) * step(0.0, along) * (1.0 - smoothstep(reach - aa, reach + aa, along));
                    rays = max(rays, beam);
                }

                for (int i = 0; i < 12; i++)
                {
                    float seed = float(i);
                    float angle = seed * 0.523599 + (ImpactHash(seed + 82.0) - 0.5) * 0.45;
                    float2 axis = float2(cos(angle), sin(angle));
                    float along = dot(p, axis);
                    float across = abs(dot(p, float2(-axis.y, axis.x)));
                    float start = coreRadius * (0.72 + 0.25 * ImpactHash(seed + 24.0));
                    float reach = (0.16 + 0.25 * ImpactHash(seed + 61.0)) * expansion;
                    float t = saturate((along - start) / reach);
                    float width = (0.009 + 0.02 * ImpactHash(seed + 53.0)) * expansion * (1.0 - t);
                    float chip = (1.0 - smoothstep(width - aa, width + aa, across)) * step(start, along) * (1.0 - step(start + reach, along));
                    rays = max(rays, chip);
                }

                // The second pose opens a larger white core inside the black strokes.
                return shock ? rays * (1.0 - core) : max(core, rays);
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                float2 uv = input.texcoord;
                float4 source = SAMPLE_TEXTURE2D_X_LOD(_BlitTexture, sampler_LinearClamp, uv, 0);
                float2 scale = _Resolution / max(1.0, min(_Resolution.x, _Resolution.y));
                float2 pixel = fwidth(uv * scale);
                if (_Intensity <= 0.0)
                {
                    return source;
                }

                if (_Frame > 6.5)
                {
                    float graphic = TerminalBlast((uv - _Center) * scale, scale, _Frame > 7.5);
                    float subjectMask = Subject(uv);
                    float terminalInk = lerp(graphic, 1.0 - graphic, subjectMask);
                    float terminalBw = lerp(1.0 - terminalInk, terminalInk, _Inverted);
                    return float4(lerp(source.rgb, terminalBw.xxx, _Intensity), source.a);
                }

                float2 delta = (uv - _Center) * scale;
                float radius = length(delta);
                float2 direction = length(_AttackDirection) > 0.001 ? normalize(_AttackDirection * scale) : delta / max(radius, 0.00001);

                // One target per pose keeps the subject's stroke field coherent.
                bool hasPullStar = _StarStrength > 0.0 && _Stars[0].z > 0.0;
                float2 pullAnchor = clamp(_Center * scale + _Stars[0].xy, 0.08, scale - 0.08);
                float2 toward = pullAnchor - uv * scale;
                float starDistance = length(toward);
                if (hasPullStar)
                {
                    direction = toward / max(starDistance, 0.00001);
                }

                float2 tangent = float2(-direction.y, direction.x);
                float shape = _Frame < 0.5 ? 0.16 : _Frame < 1.5 ? 0.85 : _Frame < 2.5 ? 1.0 : _Frame < 3.5 ? 0.1 : _Frame < 4.5 ? 0.32 : 0.0;
                float angle = hasPullStar ? (starDistance > 0.00001 ? atan2(toward.y, toward.x) : 0.0) : radius > 0.00001 ? atan2(delta.y, delta.x) : 0.0;
                float lane = hasPullStar || length(_AttackDirection) < 0.001 ? floor(angle * 38.0) : floor(dot(delta, tangent) * 240.0);
                float bundle = ImpactHash(lane + _Frame * 19.0);
                float fine = ImpactHash(floor(angle * 190.0) + _Frame * 71.0);
                float reach = _StrokeLength * 0.21 * shape * (0.2 + 0.8 * bundle) * (0.78 + 0.22 * fine);
                float body = Subject(uv);
                float ink = Mark(uv, scale);
                if (reach > 0.00001)
                {
                    for (int i = 1; i <= 16; i++)
                    {
                        float t = float(i) / 16.0;
                        float2 along = uv - direction / scale * (reach * t);
                        float taper = 1.0 - t * (0.35 + 0.4 * fine);
                        float cut = step(0.3 * (1.0 - _InkDensity), bundle);
                        ink = max(ink, Mark(along, scale) * taper * cut);
                    }
                }

                // A solid subject is never eroded by the brush pattern.
                ink = max(body, smoothstep(0.18, 0.66, ink));
                bool hitStar = _Frame > 5.5 && _Frame < 6.5;
                if (hitStar)
                {
                    float2 px = 1.2 / max(_Resolution, 1.0);
                    float gx = Mark(uv + float2(px.x, 0.0), scale) - Mark(uv - float2(px.x, 0.0), scale);
                    float gy = Mark(uv + float2(0.0, px.y), scale) - Mark(uv - float2(0.0, px.y), scale);
                    ink = smoothstep(0.12, 0.7, length(float2(gx, gy))) * 0.32;
                }

                if (_StarStrength > 0.0)
                {
                    for (int i = 0; i < 4; i++)
                    {
                        float4 entry = _Stars[i];
                        if (entry.z > 0.0)
                        {
                            float2 anchor = hitStar ? _Center * scale : clamp(_Center * scale + entry.xy, 0.08, scale - 0.08);
                            float2 p = uv * scale - anchor;
                            float span = entry.z * _StarSize;
                            float phase = float(i) + _Frame * 3.0;
                            float inkWeight = _Frame > 0.5 && _Frame < 1.5 && i == 0 ? 1.0 : 0.0;
                            bool reverse = _ReverseStars[i] > 0.5;
                            float bodyWeight = hitStar ? 0.8 : reverse ? 2.2 : lerp(1.7, 1.0, smoothstep(0.45, 1.25, entry.z));
                            float2 squeeze = float2(max(entry.w, 0.1), 1.0);
                            float star = FourPoint(p / squeeze, pixel / squeeze, span, phase, inkWeight, bodyWeight);

                            // An opposite-color star needs its own ink surround to read on paper.
                            float composed = reverse ? lerp(max(ink, StarInkPatch(p, length(pixel), span, phase)), 0.0, star) : max(ink, star);
                            ink = lerp(ink, composed, _StarStrength * (hitStar ? 1.0 : 1.0 - body));
                        }
                    }
                }

                float paper = 1.0 - saturate(ink);
                float bw = lerp(paper, 1.0 - paper, _Inverted);
                return float4(lerp(source.rgb, bw.xxx, _Intensity), source.a);
            }
            ENDHLSL
        }

        Pass
        {
            Name "Subject Mask"
            ZTest LEqual
            ZWrite Off
            Cull Back
            Offset -1, -1

            HLSLPROGRAM
            #pragma vertex MaskVert
            #pragma fragment MaskFrag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct MaskAttributes
            {
                float3 positionOS : POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct MaskVaryings
            {
                float4 positionCS : SV_POSITION;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            MaskVaryings MaskVert(MaskAttributes input)
            {
                MaskVaryings output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
                output.positionCS = TransformObjectToHClip(input.positionOS);
                return output;
            }

            float4 MaskFrag(MaskVaryings input) : SV_Target
            {
                return 1.0;
            }
            ENDHLSL
        }
    }
}
