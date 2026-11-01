Shader "ConfusedGameDev/Vfx/DustDevil Debris"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+4" }

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

            #define VFX_VARIANT 1
            #define VFX_LAYER_DEBRIS
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxVortex.hlsl"
            ENDHLSL
        }
    }
}
