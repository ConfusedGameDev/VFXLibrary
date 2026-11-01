Shader "ConfusedGameDev/Vfx/IceShard Trails"
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

            #define VFX_VARIANT 2
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxProjectile.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 stream : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float phase : TEXCOORD1;
                float3 stagePosition : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                output.phase = input.stream.w;

                float h = input.positionOS.x;
                float t = _EffectTime;
                float wave = sin(h * VFX_PI);
                float radius = input.stream.z * wave;
                float a = input.stream.x + h * 0.7 + sin(t * 0.6 + input.stream.w) * 0.12;
                float width = 0.009 + wave * 0.025;

                float3 p = float3(0.85 - 0.3 * _EffectSize - h * input.stream.y, cos(a) * radius, sin(a) * radius);
                float attach = lerp(_EffectSize, 1.0, smoothstep(0.0, 0.65, h));
                p.yz *= attach;
                p.x += 0.3 * (_EffectSize - 1.0) * smoothstep(0.0, 1.0, h);
                p += float3(0.0, input.positionOS.yz) * width * attach;
                output.positionCS = StageClip(p, output.stagePosition);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float h = input.uv.x;
                float frost = Noise2(float2(h * 19.0 + _EffectTime * 1.8, input.uv.y * 7.0 + input.phase));
                float alpha = pow(abs(1.0 - h), 1.5) * smoothstep(0.0, 0.14, h) * (0.12 + 0.18 * ToonStep(0.5, frost));
                return float4(ToonShade(_EffectColor.rgb, 0.53), saturate(alpha * _EffectDetail) * StageAlpha(input.stagePosition));
            }
            ENDHLSL
        }
    }
}
