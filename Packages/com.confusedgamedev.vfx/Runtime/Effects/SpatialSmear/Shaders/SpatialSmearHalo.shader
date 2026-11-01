Shader "ConfusedGameDev/Vfx/SpatialSmear Halo"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+2" }

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

            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBladeTrail.hlsl"

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float age = saturate(input.age);
                float y = input.uv.y;
                float fade = pow(abs(1.0 - age), 1.35);
                float alpha = exp(-Sq((1.0 - y) * 7.5)) * 0.16 * _EffectDetail * fade;
                alpha += BladeLines(y, 0.004) * 0.055 * _EffectDetail * fade;
                clip(alpha - 0.002);
                return float4(_EffectColor.rgb, saturate(alpha));
            }
            ENDHLSL
        }
    }
}
