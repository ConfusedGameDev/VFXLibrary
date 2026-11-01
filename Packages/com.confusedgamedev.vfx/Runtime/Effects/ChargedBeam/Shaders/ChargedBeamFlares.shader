Shader "ConfusedGameDev/Vfx/ChargedBeam Flares"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+4" }

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

            #define VFX_VARIANT 2
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBeam.hlsl"

            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBeamFlare.hlsl"
            ENDHLSL
        }
    }
}
