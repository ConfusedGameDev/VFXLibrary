Shader "ConfusedGameDev/Vfx/IceShard Particles"
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

            #define VFX_VARIANT 2
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxProjectile.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 seed : TEXCOORD1;
                float2 id : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float alpha : TEXCOORD1;
                float3 stagePosition : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                if (input.id.x >= _ParticleCount)
                {
                    return output;
                }

                float4 seed = input.seed;
                float t = _EffectTime;
                float a = seed.x * VFX_PI * 2.0;
                float r = sqrt(seed.z);
                float life = frac(seed.y + t * 0.65);

                float3 p = float3(0.85 - life * 3.6, sin(a) * r * (0.05 + life * 0.38), cos(a) * r * (0.05 + life * 0.38));
                p.yz *= 1.25;
                p.y -= life * life * 0.4;
                float size = (0.04 + seed.w * 0.1) * 0.42;
                output.alpha = pow(abs(1.0 - life), 1.5) * (0.35 + 0.35 * pow(max(0.0, sin(t * 4.0 + seed.z * 31.0)), 6.0));

                float spin = t * (1.0 + seed.z * 3.0) + a;
                float c = cos(spin);
                float s = sin(spin);
                float3 shard = input.positionOS * float3(2.0, 0.55, 0.65) * size;
                shard.xy = float2(c * shard.x + s * shard.y, -s * shard.x + c * shard.y);
                output.positionCS = StageClip(p + shard, output.stagePosition);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float d = length(input.uv * 2.0 - 1.0);
                float3 color = ToonShade(_EffectColor.rgb, 0.46 + (1.0 - d) * 0.4);
                return float4(color, saturate(0.8 * input.alpha * _EffectDetail) * StageAlpha(input.stagePosition));
            }
            ENDHLSL
        }
    }
}
