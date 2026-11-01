Shader "ConfusedGameDev/Vfx/PlasmaBolt Envelope"
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
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxProjectile.hlsl"

            #define RIBBON_ENVELOPE 1
            #include "PlasmaBoltRibbon.hlsl"
            ENDHLSL
        }
    }
}
