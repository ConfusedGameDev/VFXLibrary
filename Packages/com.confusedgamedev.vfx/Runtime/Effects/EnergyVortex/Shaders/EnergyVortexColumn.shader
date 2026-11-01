Shader "ConfusedGameDev/Vfx/EnergyVortex Column"
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
            #define VFX_LAYER_COLUMN
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxVortex.hlsl"
            ENDHLSL
        }
    }
}
