Shader "ConfusedGameDev/Vfx/DimensionalRend Cuts"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent" }

        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Front

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
                float4 screen : TEXCOORD0;
                float2 shift : TEXCOORD1;
                float alpha : TEXCOORD2;
                float age : TEXCOORD3;
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

                if (_PanelCount <= 0.0 || _EffectTime < 0.2 || _EffectTime >= 1.2)
                {
                    return output;
                }

                float exitProgress = smoothstep(REND_RELEASE, REND_EXIT, localTime);
                float age = _EffectTime - (0.2 + 0.36 * i / max(1.0, _PanelCount - 1.0));
                float sweep = smoothstep(0.0, 0.06, age);
                float alive = step(i + 0.5, _PanelCount) * step(0.0, age) * (1.0 - step(REND_EXIT, localTime));
                float along = (position.x + 1.0) * 0.5;
                output.age = age;
                output.exit = exitProgress;
                output.alpha = alive;

                float3 q = position;
                q.x = lerp(-1.0, sweep * 2.0 - 1.0, along);
                float spatialTaper = (1.0 - q.x) * 0.5;
                float3x3 frame = Rf(i);
                float anchor = frame[0].y >= 0.0 ? -1.0 : 1.0;
                q.xy = RendPanel(i, q.x, position.y + 1.0);
                q.x = (anchor + (q.x - anchor) * (1.0 + 0.8 * exitProgress)) * Rl(i);
                q.z *= 0.008 * spatialTaper;
                q *= 2.0;

                float3 p = RendPanelCenter(i) + mul(q, frame) * _EffectSize;
                output.positionCS = TransformObjectToHClip(ToUnity(p));
                output.screen = ComputeScreenPos(output.positionCS);
                output.shift = ScreenShift(frame[0]);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                clip(input.alpha - 0.003);
                float reveal = smoothstep(0.0, 0.04, input.age);
                float fade = 1.0 - input.exit;
                float3 background = DisplacedScene(input.screen, input.shift, 2.0 * reveal * fade);
                float alpha = input.alpha * fade * fade;
                clip(alpha - 0.003);
                return float4(background, alpha);
            }
            ENDHLSL
        }
    }
}
