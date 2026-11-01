Shader "ConfusedGameDev/Vfx/EnergyBurst Arcs"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+2" }

        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
            Blend One OneMinusSrcAlpha
            ZWrite Off
            Cull Off

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxCommon.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float2 unit : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 stroke : TEXCOORD0;
                float halfLength : TEXCOORD1;
                float fade : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            float3 Direction(float id)
            {
                float a = id * 2.39996;
                return normalize(float3(cos(a), 0.12 + pow(Hash(float2(id, 3.0)), 2.0) * 1.5, sin(a)));
            }

            float3 PointOnArc(float id, float h)
            {
                float3 dir = Direction(id);
                float3 side = normalize(cross(dir, float3(0, 1, 0)));
                float3 up = cross(side, dir);
                float cell = h * 8.0;
                float i = floor(cell);
                float f = frac(cell);
                float frame = floor(_EffectTime * 18.0);
                float j = lerp(Hash(float2(id * 3.0 + frame, i)), Hash(float2(id * 3.0 + frame, i + 1.0)), f) - 0.5;
                float k = lerp(Hash(float2(id * 7.0 + frame, i + 13.0)), Hash(float2(id * 7.0 + frame, i + 14.0)), f) - 0.5;
                float fine = h * 64.0;
                float fi = floor(fine);
                float micro = (lerp(Hash(float2(id + frame, fi)), Hash(float2(id + frame, fi + 1.0)), frac(fine)) - 0.5) * 0.04;
                return dir * h * (2.4 + Hash(float2(id, 9.0)) * 1.25)
                    + (side * (j * 0.65 + micro) + up * k * 0.40) * sin(h * VFX_PI * 0.9)
                    + float3(0, sin(h * VFX_PI) * (0.25 + Hash(float2(id, 12.0)) * 0.55), 0);
            }

            float Pulse(float t, float start, float end)
            {
                return smoothstep(start, start + 0.035, t) * (1.0 - smoothstep(end - 0.06, end, t));
            }

            float3 BranchPoint(float id, float branch, float role, float h, float growth)
            {
                if (role < 0.5)
                {
                    return PointOnArc(id, h * growth);
                }

                float fork = role < 1.5 ? 0.3125 : 0.625;
                float offset = role < 1.5 ? 1.0 : -1.0;
                float3 dir = Direction(id);
                float3 side = normalize(cross(dir, float3(0, 1, 0)));
                float3 split = normalize(dir * 0.5 + side * offset * 0.85 + float3(0, 0.28, 0));
                float child = saturate((growth - fork) / (1.0 - fork));
                float lengthBranch = 0.5 + Hash(float2(branch, 7.0)) * 0.85;
                float cell = h * 13.0;
                float i = floor(cell);
                float frame = floor(_EffectTime * 15.0) + branch;
                float jag = lerp(Hash(float2(frame, i)), Hash(float2(frame, i + 1.0)), frac(cell)) - 0.5;
                return PointOnArc(id, fork * growth) + split * h * lengthBranch * child + side * jag * 0.22 * sin(h * VFX_PI) * child;
            }

            Varyings Vert(Attributes input)
            {
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float branch = input.positionOS.z;
                float id = input.unit.x;
                float role = input.unit.y;
                float h = (input.positionOS.x + input.positionOS.y) * 0.5;
                float t = _EffectTime;

                float delay = 0.035 + Hash(float2(id, 5.0)) * 0.085;
                float growth = saturate((t - delay) * 6.5);
                float3 p0 = BranchPoint(id, branch, role, input.positionOS.x, growth);
                float3 p1 = BranchPoint(id, branch, role, input.positionOS.y, growth);
                float width = 0.17 + Hash(float2(id, 2.0)) * 0.08;
                if (role > 0.5)
                {
                    width *= 0.48 * (1.0 - h * 0.75);
                }

                float mainPulse = Pulse(t, delay, 0.58 + Hash(float2(id, 4.0)) * 0.22);
                float echo = Pulse(t, 0.78 + Hash(float2(id, 8.0)) * 0.27, 0.93 + Hash(float2(id, 8.0)) * 0.27) * 0.8;
                echo += Pulse(t, 1.28 + Hash(float2(id, 6.0)) * 0.34, 1.41 + Hash(float2(id, 6.0)) * 0.34) * 0.6;
                echo += Pulse(t, 1.85 + Hash(float2(id, 11.0)) * 0.12, 1.97 + Hash(float2(id, 11.0)) * 0.12) * step(0.72, Hash(float2(id, 12.0))) * 0.4;
                float flicker = role < 0.5 ? 1.0 : 0.45 + 0.45 * Hash(float2(branch, floor(t * (14.0 + role * 3.0))));
                output.fade = max(mainPulse, echo) * growth * step(id, _Quantity - 0.5) * flicker * min(1.0, sqrt(12.0 / _Quantity));
                width *= 1.0 - smoothstep(0.88, 1.0, h) * 0.78;

                p0 *= _EffectSize;
                p0.y -= 1.20;
                p1 *= _EffectSize;
                p1.y -= 1.20;
                float3 m0 = SourceToView(p0);
                float3 m1 = SourceToView(p1);
                float2 delta = m1.xy - m0.xy;
                float len = length(delta);
                float2 along = len < 0.0001 ? float2(1, 0) : delta / len;

                width *= _EffectSize * RootScale();
                float3 mv = lerp(m0, m1, input.uv.x);
                mv.xy += (along * (input.uv.x * 2.0 - 1.0) + float2(-along.y, along.x) * (input.uv.y * 2.0 - 1.0)) * width;

                output.halfLength = len / max(width, 0.00001) * 0.5;
                output.stroke = float2((input.uv.x * 2.0 - 1.0) * (output.halfLength + 1.0), input.uv.y * 2.0 - 1.0);
                output.positionCS = TransformWViewToHClip(mv);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float edge = length(float2(max(0.0, abs(input.stroke.x) - input.halfLength), input.stroke.y));
                float core = exp(-edge * edge * 180.0);
                float sheath = exp(-edge * edge * 40.0);
                float halo = exp(-edge * edge * 6.0);
                float3 tint = _EffectColor.rgb;
                float3 cyan = pow(abs(tint), 0.55) * float3(0.65, 1.4, 1.0);
                float3 c = lerp(tint, cyan, sheath) + core * 1.5;
                float alpha = (core + sheath * 0.65 + halo * 0.18) * (1.0 - smoothstep(0.8, 1.0, edge)) * input.fade;
                float covered = min(1.0, alpha);
                return float4(c * covered, covered * 0.6);
            }
            ENDHLSL
        }
    }
}
