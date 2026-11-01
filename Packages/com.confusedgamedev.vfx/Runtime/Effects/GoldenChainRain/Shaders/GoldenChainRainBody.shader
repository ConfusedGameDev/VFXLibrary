Shader "ConfusedGameDev/Vfx/GoldenChainRain Body"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" "Queue" = "Geometry+1" }

        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
            Blend One Zero
            ZWrite On
            Cull Off

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #define VFX_VARIANT 15
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "GoldenChainRainCommon.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 data : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 ringUv : TEXCOORD0;
                float3 viewVector : TEXCOORD1;
                float3 local : TEXCOORD2;
                float2 chainClip : TEXCOORD3;
                float4 state : TEXCOORD4;
                float2 plane : TEXCOORD5;
                float3 headingWidth : TEXCOORD6;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                GcChain chain;
                if (!GcLoad(input.data.x, chain) || input.data.y >= chain.count)
                {
                    return output;
                }

                float link = input.data.y;
                float age = _EffectTime - chain.birth;
                if (age < 0.0 || age >= 1.85)
                {
                    return output;
                }

                float span = chain.span;
                float travel = pow(saturate(age / 0.35), 1.5);
                float3 forward = (chain.end - chain.start) / span;
                float3 right, side;
                GcBasis(forward, right, side);
                float tipDistance = GcTipDistance(age, span);
                float along = tipDistance - 0.83 - link * 0.265;
                float route = saturate(along / span);
                float impact = max(0.0, age - 0.35);
                float bend = 0.085 * (1.0 - travel) + 0.72 * exp(-impact * 17.0) * sin(impact * 52.0) * step(0.35, age);
                bend *= min(link * 0.5, 1.0);
                float3 tangent = normalize(forward + right * (bend * VFX_PI / span * cos(route * VFX_PI)));
                float3 center = chain.start + forward * along + right * sin(route * VFX_PI) * bend;

                float3 positionVS = SourceToView(center * _EffectSize);
                float3 direction = SourceDirToView(tangent);
                float2 projected = direction.xy - positionVS.xy * (direction.z / min(positionVS.z, -0.00001));
                float projectedLength = length(projected) / max(length(direction), 0.00001);
                float2 heading = projected / max(length(projected), 0.00001);
                if (heading.y < 0.0)
                {
                    heading = -heading;
                }

                heading = normalize(lerp(float2(0.0, 1.0), heading, smoothstep(0.005, 0.08, projectedLength)));
                if (dot(projected, heading) < 0.0)
                {
                    heading = -heading;
                }

                float2 lateral = float2(heading.y, -heading.x);
                float odd = fmod(link, 2.0);
                float width = lerp(1.0, 0.48, odd);
                float3 lateralLocal = GcViewToSource(float3(lateral, 0.0));
                float3 headingLocal = GcViewToSource(float3(heading, 0.0));
                float3 lengthAxis = normalize(tangent + headingLocal * 0.08 * (1.0 - smoothstep(0.0, 0.08, projectedLength)));
                float3 local = center + lengthAxis * input.positionOS.y + lateralLocal * input.positionOS.x * width;
                local += normalize(cross(lateralLocal, lengthAxis)) * (odd - 0.5) * 0.0015;

                positionVS = SourceToView(local * _EffectSize);
                output.plane = input.positionOS.xy;
                output.headingWidth = float3(heading, width);
                output.local = local;
                output.viewVector = -positionVS;
                float axial = dot(local - chain.start, forward);
                output.chainClip = float2(axial, tipDistance - 0.64 - axial);
                output.state = float4(age, route, saturate((age - 1.10) / 0.75), chain.seed + link * 0.173);
                output.ringUv = input.uv;
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                if (input.local.y < 0.0 || min(input.chainClip.x, input.chainClip.y) < 0.0)
                {
                    discard;
                }

                float age = input.state.x;
                float route = input.state.y;
                float dissolve = input.state.z;
                float seed = input.state.w;
                float2 ellipse = input.plane / float2(0.095, 0.17);
                float ellipseRadius = length(ellipse);
                float2 radial = ellipse / max(ellipseRadius, 0.00001);
                float tubeDistance = (ellipseRadius - 1.0) / max(length(radial / float2(0.095, 0.17)), 0.00001);
                float tube = clamp(tubeDistance / 0.031, -1.0, 1.0);
                #ifdef GC_HALO
                    if (abs(tubeDistance) < 0.031 || abs(tubeDistance) > 0.054)
                    {
                        discard;
                    }

                    float spriteHalo = 1.0 - smoothstep(0.031, 0.054, abs(tubeDistance));
                #else
                    if (abs(tubeDistance) > 0.031)
                    {
                        discard;
                    }
                #endif

                float2 ringUv = float2(frac(atan2(ellipse.y, ellipse.x) / 6.283185), acos(tube) / 6.283185);
                float grain = GcHash(floor(ringUv * float2(24.0, 6.0)) + seed * 83.0);
                float threshold = route * 0.78 + grain * 0.22;
                if (dissolve > threshold)
                {
                    discard;
                }

                float edge = step(0.001, dissolve) * (1.0 - smoothstep(0.0, 0.045, threshold - dissolve));
                #ifdef GC_HALO
                    return float4(_EffectColor.rgb * 1.10, saturate((0.035 + edge * 0.18) * _EffectDetail * spriteHalo));
                #else
                    float2 heading = input.headingWidth.xy;
                    float2 radialNormal = normalize(radial / float2(0.095 * input.headingWidth.z, 0.17));
                    float2 lateral = float2(heading.y, -heading.x);
                    float3 surface = float3((lateral * radialNormal.x + heading * radialNormal.y) * tube, sqrt(max(0.0, 1.0 - tube * tube)));
                    float2 angle = ringUv * 6.283185;
                    float radius = 2.2 + 0.45 * cos(angle.y);
                    float3 liquid = float3(cos(angle.x) * radius, sin(angle.x) * radius, 0.45 * sin(angle.y)) * 0.65 * _TextureDensity;
                    return float4(GcGold(normalize(surface), normalize(input.viewVector), liquid, age, seed, edge), 1.0);
                #endif
            }

            float4 FragDepth(Varyings input) : SV_Target
            {
                Frag(input);
                return input.positionCS.z;
            }
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }
            ColorMask R
            ZWrite On
            Cull Off

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment FragDepth

            #define VFX_VARIANT 15
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "GoldenChainRainCommon.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 data : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 ringUv : TEXCOORD0;
                float3 viewVector : TEXCOORD1;
                float3 local : TEXCOORD2;
                float2 chainClip : TEXCOORD3;
                float4 state : TEXCOORD4;
                float2 plane : TEXCOORD5;
                float3 headingWidth : TEXCOORD6;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                GcChain chain;
                if (!GcLoad(input.data.x, chain) || input.data.y >= chain.count)
                {
                    return output;
                }

                float link = input.data.y;
                float age = _EffectTime - chain.birth;
                if (age < 0.0 || age >= 1.85)
                {
                    return output;
                }

                float span = chain.span;
                float travel = pow(saturate(age / 0.35), 1.5);
                float3 forward = (chain.end - chain.start) / span;
                float3 right, side;
                GcBasis(forward, right, side);
                float tipDistance = GcTipDistance(age, span);
                float along = tipDistance - 0.83 - link * 0.265;
                float route = saturate(along / span);
                float impact = max(0.0, age - 0.35);
                float bend = 0.085 * (1.0 - travel) + 0.72 * exp(-impact * 17.0) * sin(impact * 52.0) * step(0.35, age);
                bend *= min(link * 0.5, 1.0);
                float3 tangent = normalize(forward + right * (bend * VFX_PI / span * cos(route * VFX_PI)));
                float3 center = chain.start + forward * along + right * sin(route * VFX_PI) * bend;

                float3 positionVS = SourceToView(center * _EffectSize);
                float3 direction = SourceDirToView(tangent);
                float2 projected = direction.xy - positionVS.xy * (direction.z / min(positionVS.z, -0.00001));
                float projectedLength = length(projected) / max(length(direction), 0.00001);
                float2 heading = projected / max(length(projected), 0.00001);
                if (heading.y < 0.0)
                {
                    heading = -heading;
                }

                heading = normalize(lerp(float2(0.0, 1.0), heading, smoothstep(0.005, 0.08, projectedLength)));
                if (dot(projected, heading) < 0.0)
                {
                    heading = -heading;
                }

                float2 lateral = float2(heading.y, -heading.x);
                float odd = fmod(link, 2.0);
                float width = lerp(1.0, 0.48, odd);
                float3 lateralLocal = GcViewToSource(float3(lateral, 0.0));
                float3 headingLocal = GcViewToSource(float3(heading, 0.0));
                float3 lengthAxis = normalize(tangent + headingLocal * 0.08 * (1.0 - smoothstep(0.0, 0.08, projectedLength)));
                float3 local = center + lengthAxis * input.positionOS.y + lateralLocal * input.positionOS.x * width;
                local += normalize(cross(lateralLocal, lengthAxis)) * (odd - 0.5) * 0.0015;

                positionVS = SourceToView(local * _EffectSize);
                output.plane = input.positionOS.xy;
                output.headingWidth = float3(heading, width);
                output.local = local;
                output.viewVector = -positionVS;
                float axial = dot(local - chain.start, forward);
                output.chainClip = float2(axial, tipDistance - 0.64 - axial);
                output.state = float4(age, route, saturate((age - 1.10) / 0.75), chain.seed + link * 0.173);
                output.ringUv = input.uv;
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                if (input.local.y < 0.0 || min(input.chainClip.x, input.chainClip.y) < 0.0)
                {
                    discard;
                }

                float age = input.state.x;
                float route = input.state.y;
                float dissolve = input.state.z;
                float seed = input.state.w;
                float2 ellipse = input.plane / float2(0.095, 0.17);
                float ellipseRadius = length(ellipse);
                float2 radial = ellipse / max(ellipseRadius, 0.00001);
                float tubeDistance = (ellipseRadius - 1.0) / max(length(radial / float2(0.095, 0.17)), 0.00001);
                float tube = clamp(tubeDistance / 0.031, -1.0, 1.0);
                #ifdef GC_HALO
                    if (abs(tubeDistance) < 0.031 || abs(tubeDistance) > 0.054)
                    {
                        discard;
                    }

                    float spriteHalo = 1.0 - smoothstep(0.031, 0.054, abs(tubeDistance));
                #else
                    if (abs(tubeDistance) > 0.031)
                    {
                        discard;
                    }
                #endif

                float2 ringUv = float2(frac(atan2(ellipse.y, ellipse.x) / 6.283185), acos(tube) / 6.283185);
                float grain = GcHash(floor(ringUv * float2(24.0, 6.0)) + seed * 83.0);
                float threshold = route * 0.78 + grain * 0.22;
                if (dissolve > threshold)
                {
                    discard;
                }

                float edge = step(0.001, dissolve) * (1.0 - smoothstep(0.0, 0.045, threshold - dissolve));
                #ifdef GC_HALO
                    return float4(_EffectColor.rgb * 1.10, saturate((0.035 + edge * 0.18) * _EffectDetail * spriteHalo));
                #else
                    float2 heading = input.headingWidth.xy;
                    float2 radialNormal = normalize(radial / float2(0.095 * input.headingWidth.z, 0.17));
                    float2 lateral = float2(heading.y, -heading.x);
                    float3 surface = float3((lateral * radialNormal.x + heading * radialNormal.y) * tube, sqrt(max(0.0, 1.0 - tube * tube)));
                    float2 angle = ringUv * 6.283185;
                    float radius = 2.2 + 0.45 * cos(angle.y);
                    float3 liquid = float3(cos(angle.x) * radius, sin(angle.x) * radius, 0.45 * sin(angle.y)) * 0.65 * _TextureDensity;
                    return float4(GcGold(normalize(surface), normalize(input.viewVector), liquid, age, seed, edge), 1.0);
                #endif
            }

            float4 FragDepth(Varyings input) : SV_Target
            {
                Frag(input);
                return input.positionCS.z;
            }
            ENDHLSL
        }
    }
}
