Shader "ConfusedGameDev/Vfx/ArcaneMissile Trails"
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

            #define VFX_VARIANT 3
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxProjectile.hlsl"

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
                float quantityFade : TEXCOORD1;
                float3 stagePosition : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                float h = input.positionOS.x;
                float arm = input.positionOS.y;
                output.quantityFade = step(arm, _Quantity - 0.5);
                float a = arm * (_Quantity == 3.0 ? 2.094395 : 6.283185307 / _Quantity) - _EffectTime * 3.0 + h * 12.0;
                float r = (0.26 * lerp(_EffectSize, 1.0, smoothstep(0.0, 0.35, h)) + h * 0.16) * _Spread;
                float3 positionVS = SourceToView(float3(0.85 - h * 3.5, cos(a) * r, sin(a) * r));
                positionVS.y += input.positionOS.z * (0.02 + (1.0 - h) * 0.045) * RootScale();
                output.positionCS = StageViewToClip(positionVS, output.stagePosition);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                clip(input.quantityFade - 0.5);
                float t = _EffectTime;
                float h = input.uv.x;
                float edge = abs(input.uv.y * 2.0 - 1.0);
                float a = (1.0 - ToonStep(0.78, edge)) * pow(abs(1.0 - h), 1.2);
                float rune = pow(max(0.0, cos(h * 44.0 + t * 5.0)), 10.0);
                float packet = 0.32 + 0.55 * rune + 0.13 * sin(h * 32.0 + t * 6.0);
                float alpha = a * (0.5 + 0.5 * ToonStep(0.55, packet)) * _EffectDetail;
                return float4(ToonShade(_EffectColor.rgb, 0.45 + packet * 0.4), saturate(alpha) * StageAlpha(input.stagePosition));
            }
            ENDHLSL
        }
    }
}
