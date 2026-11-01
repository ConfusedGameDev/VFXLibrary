Shader "ConfusedGameDev/Vfx/SoulSiphon Droplets"
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

            #define VFX_VARIANT 5
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBeam.hlsl"

            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBeamUtility.hlsl"
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxBeamDroplets.hlsl"
            ENDHLSL
        }
    }
}
