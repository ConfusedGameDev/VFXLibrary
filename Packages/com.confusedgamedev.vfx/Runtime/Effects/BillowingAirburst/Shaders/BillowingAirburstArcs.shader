Shader "ConfusedGameDev/Vfx/BillowingAirburst Arcs"
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

            #define VFX_VARIANT 11
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "BillowingAirburstCommon.hlsl"

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
                float arc : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            float3 Ribbon(float u, float t, float arc)
            {
                float phase = arc * 3.8 + _BurstOffset.x * 0.11;
                float angle = u * (3.35 - arc * 0.45) + arc * 2.6 + t * 0.55;
                float launch = 1.0 - exp(-max(0.0, t - 0.035) * 24.0);
                float r = (2.02 + arc * 0.16 + 0.20 * sin(u * 13.0 - t * 3.4 + phase) + 0.10 * sin(u * 29.0 + t * 5.0)) * launch;
                float3 p = float3(cos(angle) * r, sin(u * 9.0 - t * 3.8 + phase) * 0.30 + sin(u * 19.0 + t * 4.0) * 0.11, sin(angle) * r);
                float tilt = 0.35 + arc * 0.86;
                float y = p.y * cos(tilt) - p.z * sin(tilt);
                p.z = p.y * sin(tilt) + p.z * cos(tilt);
                p.y = y;
                p.y += arc * 0.16 - (1.0 - arc) * (u - 0.5) * 0.85;
                return p;
            }

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                if (_EffectTime <= 0.055 || _EffectTime >= 1.10)
                {
                    return output;
                }

                float arc = input.data.x;
                float2 uv = input.uv;
                output.uv = uv;
                output.arc = arc;
                float t = max(0.0, _EffectTime - arc * 0.035);
                float3 positionVS = SourceToView(Ribbon(uv.x, t, arc) * _EffectSize);
                float3 following = SourceToView(Ribbon(uv.x + 0.004, t, arc) * _EffectSize);
                float2 tangent = following.xy - positionVS.xy;
                tangent = length(tangent) > 0.0001 ? normalize(tangent) : float2(1.0, 0.0);
                float width = (0.10 + 0.34 * pow(max(0.0, sin(uv.x * 3.141593)), 0.7)) * (0.68 + 0.32 * sin(uv.x * 23.0 - t * 6.0 + arc));
                width *= 1.0 - smoothstep(0.5, 1.0, t) * 0.55;
                float twist = uv.x * 10.0 - t * 4.0 + arc * 0.9;
                width *= (0.65 + 0.35 * sin(twist)) * lerp(1.0, 0.24, arc);
                float scale = _EffectSize * RootScale();
                positionVS.z += (uv.y - 0.5) * width * sin(twist) * scale;
                positionVS.xy += float2(-tangent.y, tangent.x) * (uv.y - 0.5) * width * scale;
                output.positionCS = TransformWViewToHClip(positionVS);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 uv = input.uv;
                float arc = input.arc;
                float t = _EffectTime - arc * 0.035;
                float folds = Noise3(float3(uv.x * 15.0, uv.y * 1.9, _EffectTime * 1.8) + _BurstOffset + arc * 5.0);
                float tear = smoothstep(lerp(0.58, 0.34, arc), lerp(1.06, 0.85, arc), t);
                float matter = folds * 0.65 + sin(uv.x * 3.141593) * 0.35;
                float coverage = smoothstep(tear - 0.05, tear + 0.065, matter);
                float edge = abs(uv.y - 0.5) * 2.0;
                float alpha = (1.0 - smoothstep(0.62, 1.0, edge)) * pow(max(0.0, sin(uv.x * 3.141593)), 0.42) * coverage;
                alpha *= smoothstep(0.055, 0.15, t) * (1.0 - smoothstep(0.75, 1.08, t));
                clip(alpha - 0.005);
                float crease = Sq(0.5 + 0.5 * sin(uv.x * 33.0 - _EffectTime * 7.0 + arc * 4.0));
                float3 tint = lerp(_EffectColor.rgb, float3(1.0, 0.83, 0.37), crease * 0.55);
                return float4(tint * (1.25 + folds * 0.65) * (1.0 - arc * 0.18) * 0.5, saturate(alpha));
            }
            ENDHLSL
        }
    }
}
