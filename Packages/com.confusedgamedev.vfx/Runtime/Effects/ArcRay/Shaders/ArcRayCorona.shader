Shader "ConfusedGameDev/Vfx/ArcRay Corona"
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

            float3 CoronaPoint(float h, float id, float end)
            {
                float frame = floor(_EffectTime * 15.0 + id * 0.3);
                float angle = id * 2.39996 + end * 0.7;
                float reach = (end < 0.0 ? 0.62 : 1.05) * (0.55 + Hash(float2(id, end)) * 0.6) * _EffectSize;
                float cell = h * 18.0;
                float k = floor(cell);
                float j = lerp(Hash(float2(k, frame + id * 13.0)), Hash(float2(k + 1.0, frame + id * 13.0)), frac(cell)) - 0.5;
                float r = h * reach;
                float taper = j * _EffectSize * sin(h * VFX_PI);
                return float3(end * 2.4 + (sin(id * 4.7) * r * 0.38 + taper * 0.10) / _Stretch, cos(angle) * r + taper * 0.16, sin(angle) * r + taper * 0.13);
            }

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                float h = input.positionOS.x;
                float id = input.positionOS.y;
                float end = input.data.x;
                float t = _EffectTime;
                float pulse = 0.2 + 0.8 * step(0.38, Hash(float2(floor(t * 12.0 + id * 0.3), id + end * 12.0)));
                output.fade = pulse * (1.0 - smoothstep(0.55, 1.0, h));

                float3 positionVS = SourceToView(CoronaPoint(h, id, end));
                float3 ahead = SourceToView(CoronaPoint(min(1.0, h + 0.04), id, end));
                float3 behind = SourceToView(CoronaPoint(max(0.0, h - 0.04), id, end));
                float2 d = ahead.xy - behind.xy;
                float len = length(d);
                float2 normal = len > 0.00001 ? float2(-d.y, d.x) / len : float2(0.0, 1.0);
                positionVS.xy += normal * input.positionOS.z * (0.115 * (1.0 - h * 0.85)) * _EffectSize * RootScale();
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
