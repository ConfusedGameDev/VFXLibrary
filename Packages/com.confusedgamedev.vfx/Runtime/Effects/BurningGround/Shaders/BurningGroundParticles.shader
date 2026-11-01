Shader "ConfusedGameDev/Vfx/BurningGround Particles"
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

            #define VFX_VARIANT 1
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxGround.hlsl"

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
                float seed : TEXCOORD2;
                float3 stagePosition : TEXCOORD3;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            // UV distortion and two erosion layers, so each tongue burns away from its edges.
            float3 FlameErosion(float2 uv, float t, float seed)
            {
                float2 p = float2(uv.x + uv.y * 0.65, uv.y);
                float warp = Noise2(p * float2(3.1, 2.7) + float2(seed, t * -0.31));
                p.x += (warp - 0.5) * 0.6;
                float broad = Noise2(p * float2(4.0, 2.2) + float2(seed * 3.7, -t * 0.85));
                float fine = Noise2(p * float2(10.5, 5.0) + float2(seed * 7.1, -t * 1.35));
                float erosion = broad * 0.72 + fine * 0.28;
                float interior = 1.0 - abs(uv.x * 2.0 - 1.0);
                float shape = interior - (1.0 - erosion) * 0.67;
                float aa = max(fwidth(shape) * 0.8, 0.018);
                float mask = smoothstep(-aa, aa + 0.07, shape);
                float heat = saturate(shape * 0.9 + broad * 0.25);
                float edge = exp(-abs(shape) * 24.0) * smoothstep(0.28, 0.58, erosion);
                return float3(mask, heat, edge);
            }

            float3 FlameColor(float3 tint, float heat)
            {
                float3 c = lerp(tint * 0.065, tint * 1.35, smoothstep(0.06, 0.48, heat));
                return lerp(c, tint * 1.6 + float3(1.0, 0.85, 0.50), smoothstep(0.48, 0.84, heat));
            }

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                output.seed = input.seed.w;
                if (input.id.x >= _ParticleCount)
                {
                    return output;
                }

                float4 seed = input.seed;
                float t = VFX_GROUND_TIME;
                float a = seed.x * VFX_PI * 2.0;
                float r = sqrt(seed.z);
                float life = frac(seed.y + t * 0.35);
                float spin = a + t * 0.15;

                float3 p = float3(cos(spin) * r * 1.85, life * 1.4, sin(spin) * r * 1.85);
                float alpha = sin(life * VFX_PI) * 0.55;
                float size = 0.04 + seed.w * 0.055;
                float2 shape = float2(1.0, 1.0);

                p.y = life * (0.3 + r * 0.7);
                p.xz += float2(sin(t * 2.0 + a), cos(t * 2.3 + a)) * life * 0.12;
                shape = float2(0.8, 3.6);
                size = 0.07 + seed.w * 0.10;


                output.alpha = alpha;
                float3 positionVS = SourceToView(p);
                positionVS.xy += input.positionOS.xy * size * shape * RootScale();
                output.positionCS = GroundViewToClip(positionVS, seed.x * 37.0, output.stagePosition);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 uv = input.uv;
                float2 q = uv * 2.0 - 1.0;
                float d = length(q);
                clip(1.0 - d);

                float alpha;
                float3 color = lerp(_EffectColor.rgb, float3(1.0, 1.0, 1.0), pow(abs(1.0 - d), 8.0) * 0.35);

                float3 burn = FlameErosion(float2(uv.x, uv.y * 1.3), VFX_GROUND_TIME * 1.8, input.seed * 9.0);
                alpha = burn.x * pow(abs(1.0 - uv.y), 0.7) * smoothstep(0.0, 0.2, uv.y);
                color = FlameColor(_EffectColor.rgb, burn.y * 0.7 + (1.0 - uv.y) * 0.3);


                return Staged(float4(color, alpha * input.alpha * _EffectDetail), input.stagePosition);
            }
            ENDHLSL
        }
    }
}
