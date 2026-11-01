Shader "ConfusedGameDev/Vfx/Object Vegetation"
{
    Properties
    {
        [HDR] _Primary("Primary", Color) = (1, 1, 1, 1)
        _Secondary("Secondary", Color) = (1, 1, 1, 1)
        _Accent("Accent", Color) = (1, 1, 1, 1)
        _Paint("Paint", Range(0, 1)) = 1
    }

    SubShader
    {
        Tags { "RenderType" = "TransparentCutout" "RenderPipeline" = "UniversalPipeline" "Queue" = "AlphaTest" }
        Cull Off

        Pass
        {
            Name "Unlit"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma target 3.0
            #pragma vertex VegetationVertex
            #pragma fragment VegetationFragment
            #pragma multi_compile_instancing
            #include "VfxObjectVegetation.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }
            ZWrite On
            ColorMask 0

            HLSLPROGRAM
            #pragma target 3.0
            #pragma vertex VegetationShadowVertex
            #pragma fragment VegetationCutoutFragment
            #pragma multi_compile_instancing
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
            #include "VfxObjectVegetation.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }
            ZWrite On
            ColorMask R

            HLSLPROGRAM
            #pragma target 3.0
            #pragma vertex VegetationVertex
            #pragma fragment VegetationCutoutFragment
            #pragma multi_compile_instancing
            #include "VfxObjectVegetation.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "DepthNormals"
            Tags { "LightMode" = "DepthNormals" }
            ZWrite On

            HLSLPROGRAM
            #pragma target 3.0
            #pragma vertex VegetationVertex
            #pragma fragment VegetationNormalsFragment
            #pragma multi_compile_instancing
            #include "VfxObjectVegetation.hlsl"
            ENDHLSL
        }
    }
}
