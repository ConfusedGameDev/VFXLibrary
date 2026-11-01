Shader "ConfusedGameDev/Vfx/DarkchainDetonation ChainGlow"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+3" }

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

            float3 ChainPath(float u, float angle, float3 start, float3 finish)
            {
                float tension = _ChainTension;
                float3 straight = lerp(start, finish, u);
                if (abs(tension) < 0.00001)
                {
                    return straight;
                }

                float3 radial = float3(cos(angle), 0.0, sin(angle));
                float3 side = float3(-sin(angle), 0.0, cos(angle));
                return straight + (radial * sin(u * 3.14159265) * DC_chainBend + side * sin(u * TAU) * 0.16) * tension;
            }

            float3 SpinFragment(float3 v, float3 axis, float angle)
            {
                return v * cos(angle) + cross(axis, v) * sin(angle) + axis * dot(axis, v) * (1.0 - cos(angle));
            }

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 link : TEXCOORD1;
                float4 brk : TEXCOORD2;
                float4 start : TEXCOORD3;
                float4 finish : TEXCOORD4;
                float4 shock : TEXCOORD5;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float alive : TEXCOORD0;
                float along : TEXCOORD1;
                float flight : TEXCOORD2;
                float2 link : TEXCOORD3;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float t = _EffectTime;
                if (t < 0.450000 || t >= 5.000000)
                {
                    return output;
                }

                float4 link = input.link;
                float4 brk = input.brk;
                float3 start = input.start.xyz;
                float3 finish = input.finish.xyz;
                float3 shock = input.shock.xyz;
                float u = link.x;
                output.along = u;
                output.link = input.positionOS.xy * float2(0.29, 0.41);
                float reach = lerp(-0.025, 1.025, smoothstep(DC_chainStart, DC_chainEnd, t));
                float grow = smoothstep(u - 0.02, u + 0.02, reach) * step(DC_chainStart, t);
                float3 center = ChainPath(u, link.w, start, finish);
                float3 delta = ChainPath(min(1.0, u + 0.002), link.w, start, finish) - ChainPath(max(0.0, u - 0.002), link.w, start, finish);
                float3 up = normalize(delta);
                float stretch = length(delta) / ((min(1.0, u + 0.002) - max(0.0, u - 0.002)) * length(finish - start));
                float3 chunk = ChainPath(brk.x, link.w, start, finish);
                float3 radial = chunk - float3(0.0, DC_centerY, 0.0);
                float hitTime = shock.y + abs(brk.x - shock.x) / shock.z * DC_breakTravel;
                output.flight = t - hitTime;
                float flight = max(0.0, output.flight);
                float seed = frac(sin(brk.y * 17.1 + brk.z * 31.7) * 437.31);
                float spin = flight * (4.0 + seed * 5.0);
                float fragmentScale = lerp(1.0, brk.w * DC_fragmentScale, smoothstep(0.0, 0.08, flight));
                float3 axis = normalize(float3(cos(seed * TAU), 0.35, sin(seed * TAU)));
                float3 p = chunk + SpinFragment((center - chunk) * fragmentScale, axis, spin) + normalize(radial) * ((DC_fragmentImpulse + seed * DC_fragmentSpread) / sqrt(brk.w)) * (1.0 - exp(-flight * 2.2)) / 2.2 + float3(0.0, -1.4 * flight * flight, 0.0);
                float3 positionVS = DcView(p);
                float3 direction = SourceDirToView(SpinFragment(up, axis, spin));
                float perspective = 1.0 - step(0.5, UNITY_MATRIX_P[3][3]);
                float2 projected = direction.xy - positionVS.xy * (direction.z / positionVS.z) * perspective;
                float2 heading = normalize(projected + float2(0.000001, 0.0));
                float2 across = float2(heading.y, -heading.x);
                float foreshorten = clamp(length(projected) / max(length(direction), 0.000001), 0.22, 1.0);
                float narrow = lerp(1.0, 0.58, Mod(link.y, 2.0));
                float scale = ViewScale() * link.z * fragmentScale * grow;
                positionVS.xy += (across * output.link.x * narrow + heading * output.link.y * stretch * foreshorten) * scale;
                output.alive = grow * (1.0 - smoothstep(4.35, 4.98, t));
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                clip(input.alive - 0.005);
                float t = _EffectTime;
                float2 radii = float2(0.078, 0.1209);
                float2 q = input.link / radii;
                float r = length(q);
                clip(r - 0.001);
                float d = (r - 1.0) * r / max(length(input.link / (radii * radii)), 0.00001);
                float aa = max(fwidth(d), 0.0005);
                float body = 1.0 - smoothstep(0.017, 0.019 + aa, abs(d));
                float hit = step(0.0, input.flight) * (1.0 - smoothstep(0.008, 0.046, input.flight));

                float running = 1.0 - step(DC_burst, t);
                float head = frac(_Flow * 0.8);
                float band = exp(-Sq((input.along - head) * 22.0));
                float hot = band * (0.02 + _Beat * 0.02) * running + hit * 0.12;
                float cardFade = (1.0 - smoothstep(0.125, 0.145, abs(input.link.x))) * (1.0 - smoothstep(0.180, 0.205, abs(input.link.y)));
                float halo = exp(-Sq(abs(d) / 0.040)) * (1.0 - body) * cardFade;
                float alpha = halo * (0.72 + hot * 0.35) * input.alive * (0.75 + 0.25 * min(_EffectDetail, 1.5));
                clip(alpha - 0.003);
                return float4(_EffectColor.rgb, saturate(alpha));
            }
            ENDHLSL
        }
    }
}
