Shader "ConfusedGameDev/Vfx/ArcaneMissile Particles"
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

            #define VFX_VARIANT 3
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
                float size = 0.04 + seed.w * 0.1;
                float alpha = pow(abs(1.0 - life), 1.5);
                float2 shape = float2(2.6, 0.6);

                float spiral = life * 12.0 - t * 3.0 + (_Quantity == 3.0 ? floor(seed.x * 3.0) * 2.094 : floor(seed.x * _Quantity) * 6.283185307 / _Quantity);
                float ring = (0.26 * lerp(_EffectSize, 1.0, smoothstep(0.0, 0.35, life)) + life * 0.16) * _Spread;
                p.yz = float2(cos(spiral), sin(spiral)) * ring + p.yz * 0.07;
                shape = float2(2.0, 0.6);

                output.alpha = alpha;
                float3 positionVS = SourceToView(p);
                positionVS.xy += input.positionOS.xy * size * shape * RootScale();
                output.positionCS = StageViewToClip(positionVS, output.stagePosition);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 q = input.uv * 2.0 - 1.0;
                float d = length(q);
                clip(1.0 - d);


                float alpha = Band(abs(q.x) + abs(q.y) - 0.64, 0.05) + exp(-d * d * 35.0) * 0.4;

                float3 color = ToonShade(_EffectColor.rgb, 0.46 + (1.0 - d) * 0.4);
                return float4(color, saturate(alpha * input.alpha * _EffectDetail) * StageAlpha(input.stagePosition));
            }
            ENDHLSL
        }
    }
}
