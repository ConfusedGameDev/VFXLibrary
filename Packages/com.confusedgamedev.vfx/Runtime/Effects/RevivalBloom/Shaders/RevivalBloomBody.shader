Shader "ConfusedGameDev/Vfx/RevivalBloom Body"
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

            #define VFX_VARIANT 9
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBeamUtility.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
                float4 data : TEXCOORD1;
                float2 id : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS : TEXCOORD0;
                float3 p : TEXCOORD1;
                float alpha : TEXCOORD2;
                float tone : TEXCOORD3;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float3 p = input.positionOS;
                float3 n = input.normalOS;
                float4 data = input.data;
                float unit = input.id.x;
                float t = _EffectTime;
                output.alpha = 1.0;
                output.tone = data.w;

                float phase = data.x;
                float angle = data.y;
                float ring = data.z;
                float ringCount = max(1.0, floor((_Quantity + 1.0 - ring) / 2.0));
                if (unit >= 0.0 && abs(_Quantity - 14.0) > 0.1)
                {
                    float index = floor(unit / 2.0);
                    phase = index / ringCount;
                    angle = (index + ring * 0.5) * 6.28318530718 / ringCount;
                }

                float life = t / 2.2;
                float gather = Ease(life / 0.17);
                float rise = Ease((life - 0.12) / 0.46);
                float open = Ease((life - 0.26 - phase * 0.035) / 0.38);
                float dissolve = smoothstep(0.68, 1.0, life);
                if (ring < 1.5)
                {
                    // A petal unfolds from its base: h along it, q.x across, q.z through.
                    float3 q = p;
                    float h = q.y;
                    float spread = 0.11 + open * (0.94 - ring * 0.20);
                    float bend = 0.25 * open;
                    float radial = (1.0 - gather) * 0.43 + 0.10 + h * spread + h * h * bend;
                    float height = 0.05 + rise * 0.29 + h * (0.11 + rise * 1.65) - h * h * 0.38 * open;
                    float dr = spread + 2.0 * h * bend;
                    float dy = 0.11 + rise * 1.65 - h * 0.76 * open;
                    float2 profile = normalize(float2(dy, -dr));
                    radial += q.z * profile.x;
                    height += q.z * profile.y;
                    float widthScale = 0.34 + rise * 0.66;
                    if (_Quantity > 14.0)
                    {
                        float halfGap = (radial - q.z * profile.x) * tan(VFX_PI / ringCount) * 0.82;
                        widthScale = min(widthScale * 7.0 / ringCount, halfGap / max(abs(q.x), 0.012));
                    }

                    float c = cos(angle);
                    float s = sin(angle);
                    p = float3(c * radial - q.x * widthScale * s, height + dissolve * 0.32, s * radial + q.x * widthScale * c);
                    n = normalize(float3(c * profile.x, profile.y, s * profile.x) * n.z + float3(-s, 0.0, c) * n.x + float3(c * dr, dy, s * dr) * n.y);
                    output.alpha = smoothstep(0.0, 0.08, life) * (1.0 - dissolve) * step(unit + 0.5, _Quantity);
                }
                else
                {
                    p.y += rise * 2.05 + dissolve * 0.2;
                    p.xz *= 1.0 + rise * 0.25;
                    output.alpha = smoothstep(0.23, 0.39, life) * (1.0 - smoothstep(0.7, 0.98, life));
                }

                p *= _EffectSize;

                output.p = p;
                output.normalWS = TransformObjectToWorldNormal(ToUnity(n));
                output.positionCS = TransformObjectToHClip(ToUnity(p));
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float3 p = input.p;
                float t = _EffectTime;
                float3 color = LitColor(input.normalWS, input.tone);
                float alpha = input.alpha;
                color = lerp(color, float3(1.0, 0.98, 0.69), smoothstep(0.3, 2.0, p.y / _EffectSize) * 0.32);
                float vein = pow(0.5 + 0.5 * cos((p.x + p.z) * (10.0 + _EffectDetail * 9.0)), 18.0);
                color += _EffectColor.rgb * vein * 0.07;

                clip(alpha - 0.003);
                return float4(color, saturate(alpha));
            }
            ENDHLSL
        }
    }
}
