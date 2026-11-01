Shader "ConfusedGameDev/Vfx/FireExplosion Volume"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" "Queue" = "Geometry" }

        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
            Blend One Zero
            ZWrite On
            Cull Front

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #define VFX_VARIANT 0
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 lobe : TEXCOORD1;
                float4 lobeSeed : TEXCOORD3;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 local : TEXCOORD0;
                float3 normalVS : TEXCOORD1;
                float3 view : TEXCOORD2;
                float height : TEXCOORD3;
                float seed : TEXCOORD4;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            float Hash3(float3 p)
            {
                p = frac(p * 0.3183099 + float3(0.11, 0.17, 0.23));
                p *= 17.0;
                return frac(p.x * p.y * p.z * (p.x + p.y + p.z));
            }

            float Field3(float3 p)
            {
                float3 i = floor(p);
                float3 f = frac(p);
                f = f * f * (3.0 - 2.0 * f);
                return lerp(
                    lerp(lerp(Hash3(i), Hash3(i + float3(1, 0, 0)), f.x), lerp(Hash3(i + float3(0, 1, 0)), Hash3(i + float3(1, 1, 0)), f.x), f.y),
                    lerp(lerp(Hash3(i + float3(0, 0, 1)), Hash3(i + float3(1, 0, 1)), f.x), lerp(Hash3(i + float3(0, 1, 1)), Hash3(i + float3(1, 1, 1)), f.x), f.y),
                    f.z);
            }

            float Turbulence(float3 p)
            {
                return Field3(p) * 0.64 + Field3(p * 2.03 + 5.1) * 0.26 + Field3(p * 4.01 - 2.7) * 0.10;
            }

            float3 HotColor(float3 base, float heat)
            {
                float3 flame = min(base * (1.2 + max(0.0, heat) * 3.0), float3(1.0, 1.0, 1.0));
                return lerp(flame, float3(1.0, 0.97, 0.85), smoothstep(0.75, 1.10, heat));
            }

            float3 LobeSurface(float3 position, float t, float4 seed, float c, float s)
            {
                float wrinkle = Turbulence(position * 2.5 + seed.x * 19.0 + float3(0.0, -t * 0.95, 0.0));
                float3 local = float3(c * position.x - s * position.y, s * position.x + c * position.y, position.z);
                float3 shape = local * float3(1.05, 0.88, 1.0);
                shape.x += local.y * local.y * (seed.y - 0.5) * 0.35;
                return shape * (0.60 + wrinkle * 0.88);
            }

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float t = _EffectTime;
                if (t <= 0.0 || t >= 1.95)
                {
                    return output;
                }

                float launch = 1.0 - exp(-t * 56.0);
                float spread = 1.0 - exp(-t * 32.0);
                float4 seed = input.lobeSeed;
                float turn = t * (0.65 + seed.x * 0.55) * (seed.z > 0.5 ? 1.0 : -1.0);
                float c = cos(turn);
                float s = sin(turn);
                output.local = input.positionOS;
                output.seed = seed.x;

                float swell = (0.78 + launch * 0.22) * (1.0 + min(t, 0.9) * 0.19);
                float3 center = input.lobe.xyz * float3(spread, launch, spread);
                center.xz *= 1.0 + min(t, 0.9) * 0.12;
                center.y += max(0.0, t - 0.3) * (0.48 + seed.y * 0.4);

                float3 position = input.positionOS;
                float3 normal = input.normalOS;
                float3 surface = LobeSurface(position, t, seed, c, s);
                float3 tangent = normalize(cross(normal, abs(normal.y) > 0.99 ? float3(1, 0, 0) : float3(0, 1, 0)));
                float3 bitangent = cross(normal, tangent);
                float3 dx = LobeSurface(normalize(position + tangent * 0.012), t, seed, c, s) - surface;
                float3 dy = LobeSurface(normalize(position + bitangent * 0.012), t, seed, c, s) - surface;

                float3 p = center + surface * input.lobe.w * swell;
                p.y = max(0.025, p.y);
                output.height = p.y;
                p *= _EffectSize;
                p.y -= 1.35;

                float3 positionVS = SourceToView(p);
                output.view = positionVS;
                output.normalVS = SourceDirToView(normalize(cross(dx, dy)));
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float t = _EffectTime;
                clip(t - 0.0001);
                clip(1.95 - t);

                float3 flow = input.local * 2.5 + float3(input.seed * 19.0, -t * 0.95, 0.0);
                float broad = Turbulence(flow);
                float grain = Field3(flow * 3.4);

                // Holes open from below, then through the lifted crown.
                float burn = smoothstep(0.45, 2.10, t) * 0.95 + (1.0 - smoothstep(0.0, 3.2, input.height)) * 0.40;
                clip(broad + 0.19 - burn);

                float3 n = normalize(input.normalVS);
                float3 view = normalize(-input.view);
                float rim = pow(abs(1.0 - max(0.0, dot(n, view))), 2.4);
                float heat = 1.20 - t * 1.9 + (input.height - 1.2) * 0.30 + rim * 0.65 + (broad - 0.5) * 0.25 + input.seed * 0.05;
                heat -= sin(saturate((t - 0.15) / 0.80) * 3.141593) * 0.12;
                float flame = smoothstep(0.32, 0.68, heat);
                float light = 0.45 + 0.55 * max(0.0, dot(n, normalize(float3(-0.35, 0.8, 0.5))));

                float3 soot = lerp(float3(0.003, 0.0035, 0.005), float3(0.022, 0.023, 0.028), light * (0.65 + broad * 0.35));
                soot *= 0.86 + grain * 0.16 * _EffectDetail;
                float3 color = lerp(soot, HotColor(_EffectColor.rgb, heat), flame);
                color = lerp(color, float3(1.0, 0.98, 0.88), smoothstep(0.96, 1.23, heat));
                float edge = (1.0 - smoothstep(0.0, 0.045, broad + 0.19 - burn)) * step(0.60, t) * (1.0 - smoothstep(0.65, 1.05, t));
                color = lerp(color, HotColor(_EffectColor.rgb, 0.55), edge * 0.6);
                return float4(color, 1.0);
            }
            ENDHLSL
        }
    }
}
