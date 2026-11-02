// Flat colour pieces, plus the arc flashes and missile smoke, which face the camera.
Shader "ConfusedGameDev/Vfx/Object Firing"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        [Enum(Flat, 0, ArcCore, 1, ArcHalo, 2, Smoke, 3)] _Mode("Mode", Float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("Source Blend", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("Destination Blend", Float) = 10
        [Enum(UnityEngine.Rendering.CullMode)] _Cull("Cull", Float) = 2
    }

    SubShader
    {
        Tags { "RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline" "Queue" = "Transparent" }

        Pass
        {
            Name "Firing"
            Tags { "LightMode" = "UniversalForward" }
            Blend [_SrcBlend] [_DstBlend]
            ZWrite Off
            Cull [_Cull]

            HLSLPROGRAM
            #pragma vertex Vertex
            #pragma fragment Fragment
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _Color;
                float _Mode;
                float _SrcBlend;
                float _DstBlend;
                float _Cull;
            CBUFFER_END

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vertex(Attributes input)
            {
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
                output.uv = input.uv;
                if (_Mode > 0.5)
                {
                    float3 view = TransformWorldToView(TransformObjectToWorld(float3(0, 0, 0)));
                    view.xy += input.positionOS.xy * length(UNITY_MATRIX_M[0].xyz);
                    output.positionCS = TransformWViewToHClip(view);
                }
                else
                {
                    output.positionCS = TransformObjectToHClip(input.positionOS);
                }
                return output;
            }

            float4 Fragment(Varyings input) : SV_Target
            {
                if (_Mode < 0.5)
                {
                    return _Color;
                }

                float2 p = input.uv * 2.0 - 1.0;
                float r = length(p);

                if (_Mode > 2.5)
                {
                    float2 cell = input.uv * 48.0;
                    float cloud = 0.85 + 0.10 * sin(cell.x * 0.63 + cell.y * 0.43) + 0.05 * sin(cell.x * 1.47 - cell.y * 0.77);
                    return float4(_Color.rgb, pow(max(0.0, 1.0 - r), 1.3) * cloud * _Color.a);
                }

                float hot = exp(-r * r * 55.0);
                float halo = exp(-r * r * 5.0);
                float streak = exp(-p.y * p.y * 900.0) * exp(-abs(p.x) * 5.0);
                float edge = 1.0 - smoothstep(0.75, 1.0, r);
                if (_Mode > 1.5)
                {
                    float3 color = lerp(float3(0.018, 0.12, 1.0), float3(0.8, 0.97, 1.0), hot);
                    return float4(color, (halo * 0.45 + streak * 0.15) * _Color.a * edge);
                }
                return float4(float3(0.85, 0.98, 1.0) + hot, exp(-r * r * 14.0) * _Color.a * edge);
            }
            ENDHLSL
        }
    }
}
