Shader "ConfusedGameDev/Vfx/BlackHole Lens"
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
            Cull Front

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #define VFX_VARIANT 9
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "BlackHoleCommon.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float4 screen : TEXCOORD0;
                float4 centerScreen : TEXCOORD1;
                float2 radius : TEXCOORD2;
                float inclination : TEXCOORD3;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float radius = 2.15 * _EffectSize * max(0.0001, BhGrowth());
                float3 centerVS = SourceToView(BhCenter());
                output.inclination = abs(dot(normalize(-centerVS), normalize(SourceDirToView(float3(0.0, 1.0, 0.0)))));
                output.positionCS = TransformWViewToHClip(SourceToView(BhCenter() + input.positionOS * radius));
                output.screen = ComputeScreenPos(output.positionCS);
                output.centerScreen = ComputeScreenPos(TransformWViewToHClip(centerVS));
                output.radius = BhScreenRadius(centerVS, _EffectSize * max(0.0001, BhGrowth()));
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float t = _EffectTime;
                float fade = BhFade();
                if (fade < 0.001 || input.centerScreen.w <= 0.0)
                {
                    discard;
                }

                float2 uv = input.screen.xy / input.screen.w;
                float2 center = input.centerScreen.xy / input.centerScreen.w;
                float2 radius = max(abs(input.radius), float2(0.00001, 0.00001));
                float2 q = (uv - center) / radius;
                float r = length(q);
                clip(1.0 - r);

                float angle = atan2(q.y, q.x);
                float spin = t * 0.8;
                float2 direction = q / max(r, 0.0001);
                float spiral = angle + 2.6 * log(r + 0.13) + spin;
                float2 flow = float2(cos(spiral), sin(spiral));
                float n = BhFbm(flow * 4.0 + float2(r * 8.0 + t * 0.9, r * 3.0));
                float large = BhFbm(float2(cos(angle - spin * 0.4), sin(angle - spin * 0.4)) * 3.0);

                // One angular deformation shared by both annuli. Radius stays monotonic, so neither can fold.
                float ringShape = BhHaloShape(angle);
                float warped = r / (1.0 + ringShape);
                float2 inset = 0.5 / max(_ScreenParams.xy, float2(1.0, 1.0));
                float2 delta = BhBackgroundOffset(uv, direction, r, spiral, n, radius, inset);
                float2 bent = clamp(uv + delta, inset, 1.0 - inset);
                float3 background = SampleSceneColor(bent);
                float4 rear = BhRearDiskThroughLens(bent);
                background = background * (1.0 - rear.a) + rear.rgb;

                float aa = max(fwidth(r), 0.0005);
                float horizon = 1.0 - smoothstep(0.275 - aa, 0.275 + aa, r);
                float3 color = lerp(background, float3(0.0, 0.0, 0.0), horizon);
                float stream = pow(0.5 + 0.5 * sin(spiral * 3.0 + (n - 0.5) * 2.6), 3.0);
                float corona = exp(-Sq((warped - 0.50) / (0.065 + large * 0.02)));
                float filaments = 0.65 + 0.35 * stream;
                float continuity = 0.55 + 0.45 * stream;
                float inner = exp(-Sq((warped - 0.35) / 0.016)) * continuity;
                float fringe = exp(-Sq((warped - 0.58) / 0.055)) * continuity;
                float3 cool = float3(0.018, 0.075, 1.0);
                float3 spectrum = BhSpectrum(warped * 9.0 + large * 0.8 + n * 0.4);
                float3 energy = float3(1.0, 0.98, 0.96) * corona * filaments * continuity * (1.4 + large);
                energy += spectrum * fringe * 1.9;
                energy += cool * (exp(-abs(warped - 0.51) * 8.0) * 0.38 + exp(-abs(warped - 0.30) * 38.0) * 0.24) * (0.4 + 0.6 * stream);
                energy += lerp(_EffectColor.rgb, float3(1.0, 1.0, 1.0), 0.8) * inner * 1.6;
                float stableRim = exp(-Sq((r - 0.284) / max(0.0018, aa * 0.65)));
                float junction = BhJunction(q, smoothstep(0.40, 0.92, input.inclination));
                float3 joiningLight = lerp(spectrum, _EffectColor.rgb, 0.08) * junction * 1.1;
                float3 glow = (energy + joiningLight) * _EffectDetail;
                glow /= 1.0 + max(glow.r, max(glow.g, glow.b)) * 1.2;
                color += glow * smoothstep(0.287, 0.32, r);
                color += lerp(_EffectColor.rgb, float3(1.0, 1.0, 1.0), 0.8) * stableRim * 1.3 * _EffectDetail * (1.0 - horizon);

                // Pigment stays on circular flow coordinates, so silhouette turbulence cannot bend strokes into hooks.
                float brushZone = smoothstep(0.30, 0.34, r) * (1.0 - smoothstep(0.60, 0.68, warped));
                float3 haloBrush = BhBrushPaint(r, angle, 1.0, brushZone);
                float3 pigment = lerp(float3(0.008, 0.018, 0.055), lerp(spectrum * 0.32, float3(0.08, 0.25, 0.40), 0.55), haloBrush.y);
                color = lerp(color, pigment * (0.75 + 0.25 * _EffectDetail), haloBrush.x * brushZone);
                color = lerp(color, float3(0.002, 0.004, 0.012), haloBrush.z * brushZone * 0.98);
                return float4(color, fade * (1.0 - smoothstep(0.91, 1.0, r)));
            }
            ENDHLSL
        }
    }
}
