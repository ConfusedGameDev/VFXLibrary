Shader "ConfusedGameDev/Vfx/SpatialSmear Edge"
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

            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBladeTrail.hlsl"

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float age = saturate(input.age);
                float y = input.uv.y;
                float fade = pow(abs(1.0 - age), 1.35);
                float aa = max(fwidth(y), 0.002);
                float alpha = (1.0 - smoothstep(0.01, 0.022 + aa, 1.0 - y)) * 0.95 * fade;
                clip(alpha - 0.002);
                return float4(lerp(_EffectColor.rgb, float3(0.86, 1.0, 1.0), 0.8), saturate(alpha));
            }
            ENDHLSL
        }
    }
}
