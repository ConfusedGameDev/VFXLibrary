Shader "ConfusedGameDev/Vfx/FireVortex Ground"
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
            Cull Off

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #define VFX_VARIANT 2
            #define VFX_LAYER_GROUND
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxVortex.hlsl"
            ENDHLSL
        }
    }
}
