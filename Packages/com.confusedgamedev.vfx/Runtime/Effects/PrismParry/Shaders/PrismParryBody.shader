Shader "ConfusedGameDev/Vfx/PrismParry Body"
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

            #define VFX_VARIANT 1
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBeamUtility.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
                float4 data : TEXCOORD1;
                float2 id : TEXCOORD2;
                float3 center : TEXCOORD3;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS : TEXCOORD0;
                float3 p : TEXCOORD1;
                float alpha : TEXCOORD2;
                float tone : TEXCOORD3;
                float part : TEXCOORD4;
                float2 uv : TEXCOORD5;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float3 p = input.positionOS;
                float3 n = input.normalOS;
                float3 c = input.center;
                float3 q = p - c;
                float4 data = input.data;
                float unit = input.id.x;
                float t = _EffectTime;
                output.alpha = 1.0;
                output.tone = data.w;
                output.part = data.x;
                output.uv = input.uv;

                float life = t / 0.55;
                float pressure = sin(saturate(life / 0.34) * VFX_PI);
                float rebound = sin(saturate((life - 0.34) / 0.27) * VFX_PI);
                float strength = data.x < 0.01 ? 0.54 : 0.16 * (1.0 - data.x * 0.45);
                p.x -= pressure * strength;
                p.x += rebound * strength * 0.27;
                if (data.z < 1.5)
                {
                    p.y += (c.y - 0.9) * pressure * 0.10;
                    p.z += c.z * pressure * 0.10;
                }
                if (data.z > 1.5 && data.z < 2.5)
                {
                    float spread = Ease((life - 0.25) / 0.65);
                    p = c + q * (1.0 - spread * 0.6);
                    p.y += cos(data.y) * spread * 1.0;
                    p.z += sin(data.y) * spread * 1.0;
                    p.x += spread * 0.35;
                }
                p *= _EffectSize;
                output.alpha = smoothstep(0.0, 0.06, life) * (1.0 - smoothstep(0.52, 1.0, life));
                if (data.z > 2.5)
                {
                    output.alpha *= 1.0 - smoothstep(0.08, 0.22, life);
                }
                if (unit >= 0.0)
                {
                    output.alpha *= step(unit + 0.5, _Quantity);
                }

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
                color = lerp(color, float3(1.0, 1.0, 1.0), 0.48 * (1.0 - smoothstep(0.0, 0.23, t)));
                color += _EffectColor.rgb * 0.08 * pow(0.5 + 0.5 * sin(p.y * (10.0 + _EffectDetail * 12.0) + p.z * 11.0), 12.0);
                clip(alpha - 0.003);
                return float4(color, saturate(alpha));
            }
            ENDHLSL
        }
    }
}
