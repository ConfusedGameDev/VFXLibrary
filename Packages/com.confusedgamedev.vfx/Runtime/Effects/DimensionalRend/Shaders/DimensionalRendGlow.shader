Shader "ConfusedGameDev/Vfx/DimensionalRend Glow"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+1" }

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
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "DimensionalRendCommon.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float4 data : TEXCOORD1;
                float2 id : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float echo : TEXCOORD0;
                float band : TEXCOORD1;
                float taper : TEXCOORD2;
                float alpha : TEXCOORD3;
                float exit : TEXCOORD4;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float i = input.id.x;
                float3 position = input.positionOS;
                float localTime = _EffectTime;
                float echo = 0.0;

                echo = input.data.x;
                if (_EffectTime <= 0.0 || _EffectTime >= 1.9)
                {
                    return output;
                }

                localTime -= echo * 0.12;
                if (echo > 0.5)
                {
                    localTime = min(localTime, REND_RELEASE + 0.10);
                }

                float age = localTime - Rb(i);
                float sweep = smoothstep(0.0, 0.06, age);
                float exitProgress = smoothstep(REND_RELEASE, REND_EXIT, localTime);
                float alive = step(i + 0.5, _Quantity) * step(0.0, age) * (1.0 - step(REND_EXIT, localTime));
                float along = (position.x + 1.0) * 0.5;
                output.echo = echo;
                output.exit = exitProgress;
                output.alpha = alive;

                float3 q = position;
                float guide = step(i + 0.5, _Quantity) * step(i, 2.0) * smoothstep(0.01, 0.10, _EffectTime) * (1.0 - smoothstep(0.14, 0.2, _EffectTime));
                guide *= 1.0 - step(0.5, echo);
                output.alpha = max(alive, guide * 0.24);
                if (echo > 0.5)
                {
                    output.alpha *= smoothstep(0.98, 1.03, _EffectTime) * 0.65;
                    output.exit = smoothstep(1.15, 1.9, _EffectTime);
                }
                if (age < 0.0)
                {
                    sweep = 1.0;
                }

                q.x = lerp(-1.0, sweep * 2.0 - 1.0, along);
                float taper = pow(max(0.0, 1.0 - q.x * q.x), 0.7);
                output.band = position.y * taper;
                output.taper = taper;

                float3x3 frame = Rf(i);
                float anchor = frame[0].y >= 0.0 ? -1.0 : 1.0;
                q.x = (anchor + (q.x - anchor) * (1.0 + 0.8 * exitProgress)) * Rl(i);
                q.yz *= Rw(i) * 5.5 * 0.375 * taper;
                if (echo > 0.5)
                {
                    q.yz *= 1.5;
                }
                if (age < 0.0)
                {
                    q.yz *= 0.10;
                }

                // Only the soft halo faces the camera; its axis and depth follow the 3D cut.
                float3 mv = SourceToView(Rc(i) + frame[0] * q.x * _EffectSize);
                float3 direction = SourceDirToView(frame[0]);
                float2 across = normalize(float2(-direction.y, direction.x) + float2(0.00001, 0.0));
                mv.xy += across * q.y * _EffectSize * RootScale();
                output.positionCS = TransformWViewToHClip(mv);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                clip(input.alpha - 0.003);
                float radial = abs(input.band) / max(0.00001, input.taper) * 5.5;
                float halo = (exp(-pow((radial - 1.02) * 1.3, 2.0)) * 0.60 + exp(-pow((radial - 1.0) * 0.53, 2.0)) * 0.16) * smoothstep(0.73, 1.10, radial);
                float distanceToBlade = abs(input.band) - (0.65 / 5.5) * max(input.taper, 0.0);
                float aa = clamp(fwidth(distanceToBlade), 0.0001, 0.5 / 5.5);
                float blade = (1.0 - smoothstep(-aa, aa, distanceToBlade)) * step(0.001, input.taper);
                float alpha = max(halo * (0.55 + 0.45 * _EffectDetail), blade) * input.alpha * pow(abs(1.0 - input.exit), input.echo > 0.5 ? 1.0 : 2.0);
                float3 color = lerp(_EffectColor.rgb, lerp(_EffectColor.rgb, float3(1.0, 1.0, 1.0), input.echo > 0.5 ? 0.55 : 0.88) * 1.35, blade);
                clip(alpha - 0.003);
                return float4(color, saturate(alpha));
            }
            ENDHLSL
        }
    }
}
