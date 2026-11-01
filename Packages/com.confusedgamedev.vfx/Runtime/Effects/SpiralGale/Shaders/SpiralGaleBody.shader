Shader "ConfusedGameDev/Vfx/SpiralGale Body"
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

            #define VFX_VARIANT 6
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxProjectile.hlsl"

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
                float2 uv : TEXCOORD0;
                float3 local : TEXCOORD1;
                float phase : TEXCOORD2;
                float3 stagePosition : TEXCOORD3;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                float t = _EffectTime;
                float phase = input.data.x;
                output.phase = phase;
                float3 p = input.positionOS;
                p.yz = Rotate(p.yz, -t * 2.4 + phase * 0.1);
                p.yz *= 1.0 + 0.08 * sin(input.uv.x * 12.0 - t * 5.0 + phase);
                p *= _EffectSize;
                output.local = p;
                output.positionCS = StageClip(p, output.stagePosition);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 uv = input.uv;
                float t = _EffectTime;
                float3 n = normalize(cross(ddx(input.local), ddy(input.local)));
                float shade = 0.25 + 0.65 * abs(dot(n, normalize(float3(-0.4, 0.8, 0.5))));
                float flow = Noise2(float2(uv.x * 8.0 + t * 1.6, input.phase * 3.4 + uv.y * 2.0));
                float alpha = smoothstep(0.0, 0.06, uv.x) * (1.0 - smoothstep(0.8, 1.0, uv.x)) * smoothstep(0.05, 0.20, flow) * 0.85;
                shade = 0.19 + shade * 0.30 + pow(max(0.0, sin(uv.y * VFX_PI * 2.0)), 4.0) * 0.27 + pow(max(0.0, sin(uv.x * 12.0 + t * 6.0 + input.phase)), 8.0) * 0.16;
                clip(alpha - 0.003);
                return float4(ToonShade(_EffectColor.rgb, shade), alpha * StageAlpha(input.stagePosition));
            }
            ENDHLSL
        }
    }
}
