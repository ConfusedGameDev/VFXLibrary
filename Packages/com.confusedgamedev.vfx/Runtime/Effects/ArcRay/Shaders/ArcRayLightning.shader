Shader "ConfusedGameDev/Vfx/ArcRay Lightning"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+3" }

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

            #define VFX_VARIANT 3
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBeam.hlsl"

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
                float2 uv : TEXCOORD0;
                float fade : TEXCOORD1;
                float3 stagePosition : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            float Jag(float h, float cells, float seed)
            {
                float x = h * cells;
                float k = floor(x);
                return lerp(Hash(float2(k, seed)), Hash(float2(k + 1.0, seed)), frac(x)) * 2.0 - 1.0;
            }

            float3 Current(float h, float id)
            {
                float f = floor(_EffectTime * 18.0) + id * 31.0;
                float env = sin(h * VFX_PI);
                float2 bend = float2(Jag(h, 8.0, f), Jag(h, 7.0, f + 23.0)) * (id < 0.5 ? 0.40 : 0.48);
                bend += float2(Jag(h, 72.0, f + 71.0), Jag(h, 68.0, f + 121.0)) * 0.075;
                return float3(h * 4.8 - 2.4, bend * env * _EffectSize);
            }

            float3 ArcPoint(float h, float id, float role)
            {
                if (role < 0.5)
                {
                    return Current(h, id);
                }

                float root = 0.16 + (role - 1.0) * 0.26 + Hash(float2(id, role)) * 0.08;
                float angle = id * 2.4 + role * 2.1;
                float3 p = Current(root, id);
                float f = floor(_EffectTime * 15.0) + id * 17.0 + role * 9.0;
                p += float3(h * (0.45 + Hash(float2(id, role + 9.0)) * 0.45) / _Stretch, cos(angle) * h * 0.62, sin(angle) * h * 0.62) * _EffectSize;
                p.yz += float2(Jag(h, 14.0, f), Jag(h, 17.0, f + 7.0)) * sin(h * VFX_PI) * 0.10 * _EffectSize;
                return p;
            }

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                float h = input.positionOS.x;
                float id = input.positionOS.y;
                float role = input.data.x;
                float t = _EffectTime;
                float gate = step(id, _Quantity - 0.5);
                float spark = 0.3 + 0.7 * step(0.32, Hash(float2(floor(t * 13.0), id * 7.0 + role * 11.0)));
                output.fade = gate * (role < 0.5 ? (id < 0.5 ? 1.0 : 0.48) : spark * 0.55) * (role < 0.5 ? 1.0 : 1.0 - smoothstep(0.65, 1.0, h));
                float width = (role < 0.5 ? (id < 0.5 ? 0.34 : 0.080) : 0.065 * (1.0 - h * 0.82)) * _EffectSize;

                float3 positionVS = SourceToView(ArcPoint(h, id, role));
                float3 ahead = SourceToView(ArcPoint(min(1.0, h + 0.035), id, role));
                float3 behind = SourceToView(ArcPoint(max(0.0, h - 0.035), id, role));
                float2 tangent = ahead.xy - behind.xy;
                float len = length(tangent);
                float2 normal = len > 0.00001 ? float2(-tangent.y, tangent.x) / len : float2(0.0, 1.0);
                positionVS.xy += normal * input.positionOS.z * width * RootScale();
                output.positionCS = StageViewToClip(positionVS, output.stagePosition);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float edge = abs(input.uv.y * 2.0 - 1.0);
                float core = exp(-edge * edge * 130.0);
                float sheath = exp(-edge * edge * 26.0);
                float halo = exp(-edge * edge * 5.0);
                float alpha = (core + sheath * 0.5 + halo * 0.23) * (1.0 - smoothstep(0.75, 1.0, edge)) * input.fade;
                return float4(_EffectColor.rgb * (0.9 + sheath * 0.65) + core * 1.8, saturate(alpha) * StageAlpha(input.stagePosition));
            }
            ENDHLSL
        }
    }
}
