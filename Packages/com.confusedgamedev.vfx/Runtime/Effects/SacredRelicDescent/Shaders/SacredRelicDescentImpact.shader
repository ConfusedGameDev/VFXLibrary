Shader "ConfusedGameDev/Vfx/SacredRelicDescent Impact"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+2" }

        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
            Blend One One
            ZWrite Off
            Cull Off

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #define VFX_VARIANT 18
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBurst.hlsl"
            #include "SacredRelicDescentCommon.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                if (_ImpactAge < 0.0 || _ImpactAge >= 0.65)
                {
                    return output;
                }

                output.uv = input.uv;
                output.positionCS = TransformWViewToHClip(SourceToView(RelicFloor(input.positionOS, 0.045)));
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float age = max(0.0, _ImpactAge);
                float2 p = (input.uv * 2.0 - 1.0) * 5.0;
                float r = length(p);
                float a = atan2(p.y, p.x);
                float front = 0.1 + 4.4 * (1.0 - pow(abs(1.0 - saturate(age / 0.65)), 3.0));
                float ring = exp(-Sq((r - front) / 0.11)) * (1.0 - smoothstep(0.3, 0.65, age));
                float water = RelicWater(p, age);
                ring *= lerp(1.0, 0.12 + 0.88 * water, saturate(_EffectDetail));
                float wake = exp(-Sq((r - front + 0.22) / 0.24)) * (1.0 - smoothstep(0.25, 0.65, age)) * water * 0.24;
                [unroll]
                for (int j = 1; j < 5; j++)
                {
                    float k = float(j);
                    float behind = front * (1.0 - k * 0.11);
                    float pressure = exp(-Sq((r - behind) / (0.055 + k * 0.016)));
                    wake += pressure * (0.23 - k * 0.027) * (0.22 + 0.78 * RelicWater(p, age - k * 0.018)) * (1.0 - smoothstep(0.22, 0.65, age)) * smoothstep(0.015, 0.07, age);
                }

                float peak = smoothstep(0.0, 0.045, age) * (1.0 - smoothstep(0.08, 0.2, age));
                float flash = exp(-r * r * 3.5) * peak;
                float rays = pow(max(0.0, cos(a * 9.0 + 0.7)), 18.0) * exp(-r * 1.7) * peak;
                float3 color = lerp(_EffectColor.rgb, float3(1.0, 1.0, 1.0), saturate(flash + rays));
                float alpha = (ring * 0.8 + wake + flash + rays) * _Cancel;
                clip(alpha - 0.0005);
                return Magic(color, alpha);
            }
            ENDHLSL
        }
    }
}
