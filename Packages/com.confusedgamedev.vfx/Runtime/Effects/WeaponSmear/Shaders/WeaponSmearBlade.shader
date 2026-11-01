Shader "ConfusedGameDev/Vfx/WeaponSmear Blade"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+1" }

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

            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBladeTrail.hlsl"

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float age = saturate(input.age);
                float y = input.uv.y;
                float fade = pow(abs(1.0 - age), 1.35);
                float lines = BladeLines(y, 0.005);
                // The fresh leading face reads across the whole blade, not just at its tip.
                float head = 1.0 - smoothstep(0.0, 0.28, age);
                float body = lerp(0.12 + 0.35 * y, 0.42 + 0.12 * y, head);
                float alpha = (body + lines * 0.13 * _EffectDetail) * smoothstep(0.0, 0.08, y) * fade;
                clip(alpha - 0.002);
                return float4(_EffectColor.rgb, saturate(alpha));
            }
            ENDHLSL
        }
    }
}
